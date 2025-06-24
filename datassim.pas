{ +--------------------------------------------------------------------------+ }
{ | DATASSim * Simulator for DATAS machine code                              | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | datassim.pas                                                             | }
{ | Main program (Turbo Pascal 3.0 CP/M and DOS)                             | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

program datassim;
type
  TCommand =    string[255];
  TFilename =   string[12];
  TSplitted =   string[64];
  TMemcell =    record
    data:       array[0..3] of byte;
    comment:    string[64];
  end;
  TTwoDigit =   string[2];
var
  b:            byte;
  breakpoint:   byte;                                     { breakpoint address }
  com:          TCommand;                               { command line content }
  mem:          array[0..99] of TMemcell;                           { 'memory' }
  prg_counter:  byte;                                        { program counter }
  prg_status:   byte;                   { program status 0/1/2 stop/run/paused }
  quit:         boolean;
  splitted:     array[0..7] of TSplitted;                   { splitted command }
const
  COMMARRSIZE = 14;
  INSTARRSIZE = 19;
  COMMENT =     ';';
  HEADER1 =     'DATASSim v0.1 for CP/M and DOS';
  HEADER2 =     '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>';
  HEADER3 =     'Licence: EUPL v1.2';
  HINT =        'Type ''help [command]'' or ''help code'' for more information.';
  PROMPT =      'SIM>';
  COMMANDS:     array[0..COMMARRSIZE] of string[7] = (
                'break',  'comment','deposit','dump',   'examine','export',
                'fill',   'help',   'import', 'load',   'quit',   'reset',
                'run',    'save',   'step');
  COMMANDS_INF: array[0..1,0..COMMARRSIZE] of string[63] = ((
                'set, get and reset breakpoint address',
                'add or remove a sigle-line note for AA address',
                'store D0-3 value at AA address',
                'print the value of memory cell number CN from AA',
                'examine value at AA address',
                'export memory content to a binary file',
                'fill the memory cell number CN from AA with the value D0-3',
                'help with using the program',
                'import memory content from a binary file',
                'load source code',
                'exit the simulator program',
                'reset simulator',
                'run program from AA address',
                'save source code',
                'run program step-by-step from AA address'),(
                'break [AA|-]             ',
                'comment AA Jump\ to\ 12|-',
                'deposit AA D0 D1 D2 D3   ',
                'dump AA CN               ',
                'examine AA               ',
                'export filename.bin      ',
                'fill AA CN D0 D1 D2 D3   ',
                'help [command]           ',
                'import filename.bin      ',
                'load filename.lst        ',
                'quit                     ',
                'reset                    ',
                'run [AA]                 ',
                'save filename.lst        ',
                'step                     '));
  INST_INF:     array[0..INSTARRSIZE] of string[46] = (
                'name      OC D0 D1 D2  operation',
                '----------------------------------------------',
                '          00 sd dd dd  value at this address' ,
                'ADD       01 dd dd dd  (D3)=(D1) + (D2)',
                'SUBTRACT  02 dd dd dd  (D3)=(D1) - (D2)',
                'MULTIPLY  03 dd dd dd  (D3)=(D1) * (D2)',
                'DIVIDE    04 dd dd dd  (D3)=(D1) div (D2)',
                'BRANCH    05 00 00 dd  jump to D3',
                '          05 01 dd dd  if D2<0 then jump to D3',
                '          05 02 dd dd  if D2>0 then jump to D3',
                'HALT      06 00 00 00  stop at this address',
                'READ      07 dd 00 00  read a value to D1',
                'WRITE     08 dd 00 00  write a value from D1',
                'SQRT      09 dd 00 dd  (D3)=sqrt(D1)',
                'ABS       10 dd 00 dd  (D3)=|D1|',
                'OC:   operation code',
                'D0-2: operands',
                '(Dx): value at Dx address',
                's:    sign of the number [0/1, +/-]',
                'd:    decimal number [0..9]');
  MESSAGE:      array[0..29] of string[39] = (
                'No such command!',
                'The 1st ',
                'The 2nd ',
                'The 3rd ',
                'The 4th ',
                'The 5th ',
                'The 6th ',
                'parameter is bad or missing.',
                'parameter value is incorrect.',
                'No breakpoint set.',
                'The breakpoint is at address ',
                'The breakpoint is deleted.',
                'The breakpoint is set to address ',
                'The commment is deleted from ',
                'The commment is added to ',
                'The value is stored at address ',
                'The value at address ',
                'Memory content is exported to ',
                'Cannot write ',
                'Memory cells are filled with ',
                'Memory content is imported from ',
                'Cannot read ',
                'The binary file size is small.',
                'Memory content is loaded from ',
                'Too short line: ',
                'Illegal character in: ',
                'The simulator has been reset.',
                'Memory content is saved to ',
                'Run program from address ',
                'Step-by-step execution from address ');

{ INSERT ZERO BEFORE [0-9] }
function addzero(v: integer): TTwoDigit;
var
  u: TTwoDigit;
begin
  str(v:0, u);
  if length(u) = 1 then u := '0' + u;
   addzero := u;
end;

{ COMMAND 'break' }
procedure cmd_break(p1: TSplitted);
var
  e:   byte;
  ec:  integer;
  ip1: integer;
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get breakpoint address }
    if breakpoint = 255
      then writeln(MESSAGE[9])
      else writeln(MESSAGE[10], addzero(breakpoint));
  end else
  begin
    if p1 = '-' then
    begin
      { reset breakpoint }
      breakpoint := 255;
      writeln(MESSAGE[11])
    end else
    begin
      { set breakpoint address }
      val(p1, ip1, ec);
      if ec = 0
      then
        if (ip1 >= 0) and (ip1 <= 99) then e := 0 else e := 11
      else e := 12;
      case e of
        11: writeln(MESSAGE[1] + MESSAGE[8]);
        12: writeln(MESSAGE[1] + MESSAGE[7]);
      else
        begin
          breakpoint := ip1;
          writeln(MESSAGE[12], addzero(ip1));
        end;
      end;
    end;
  end;
end;

{ COMMAND 'comment' }
procedure cmd_comment(p1, p2: TSplitted);
var
  b:   byte;
  ip1: integer;
  ec:  integer;
  e:   byte;
begin
  e := 0;
  { check parameters }
  val(p1, ip1, ec);
  if length(p2) = 0 then e := 22;
  if ec = 0
  then
    if (ip1 >= 0) and (ip1 <= 99) then e := 0 else e := 11
  else e := 12;
  case e of
    11: writeln(MESSAGE[1] + MESSAGE[8]);
    12: writeln(MESSAGE[1] + MESSAGE[7]);
    22: writeln(MESSAGE[2] + MESSAGE[7]);
  else
    if p2 = '-' then
    begin
      { delete comment }
      mem[ip1].comment := '';
      writeln(MESSAGE[13] + p1 + '.');
    end else
    begin
      { add comment }
      mem[ip1].comment := '';
      for b := 1 to length(p2) do
        if p2[b] <> #92 then mem[ip1].comment := mem[ip1].comment + p2;
      writeln(MESSAGE[14] + p1 + '.');
    end;  
  end;
end;

{ COMMAND 'deposit' }
procedure cmd_deposit(p1, p2, p3, p4, p5: TSplitted);
var
  ip1, ip2, ip3, ip4, ip5: integer;
  ec:                      integer;
  e:                       byte;
begin
  e := 0;
  { check parameters }
  val(p1, ip1, ec);
  if ec = 0
  then
    if (ip1 >= 0) and (ip1 <= 99) then
    begin
      val(p2, ip2, ec);
      if ec = 0
      then
        if (ip2 >= 0) and (ip2 <= 99) then
        begin
          val(p3, ip3, ec);
          if ec = 0
          then
            if (ip3 >= 0) and (ip3 <= 99) then
            begin
              val(p4, ip4, ec);
              if ec = 0
              then
                if (ip4 >= 0) and (ip4 <= 99) then
                begin
                  val(p5, ip5, ec);
                  if ec = 0
                  then
                    if (ip5 >= 0) and (ip5 <= 99) then e := 0 else e := 51
                  else e := 52;
                end else e := 41
              else e := 42;
            end else e := 31
          else e := 32;
        end else e := 21
      else e := 22;
    end else e := 11
  else e := 12;
  case e of
    11: writeln(MESSAGE[1] + MESSAGE[8]);
    12: writeln(MESSAGE[1] + MESSAGE[7]);
    21: writeln(MESSAGE[2] + MESSAGE[8]);
    22: writeln(MESSAGE[2] + MESSAGE[7]);
    31: writeln(MESSAGE[3] + MESSAGE[8]);
    32: writeln(MESSAGE[3] + MESSAGE[7]);
    41: writeln(MESSAGE[4] + MESSAGE[8]);
    42: writeln(MESSAGE[4] + MESSAGE[7]);
    51: writeln(MESSAGE[5] + MESSAGE[8]);
    52: writeln(MESSAGE[5] + MESSAGE[7]);
  else
    begin
      { store values }
      mem[ip1].data[0] := ip2;
      mem[ip1].data[1] := ip3;
      mem[ip1].data[2] := ip4;
      mem[ip1].data[3] := ip5;
      writeln(MESSAGE[15], addzero(ip1), '.')
    end;
  end;
end;

{ COMMAND 'dump' }
procedure cmd_dump(p1, p2: TSplitted);
var
  b:        byte;
  ip1, ip2: integer;
  ec:       integer;
  e:        byte;
begin
  e := 0;
  { check parameters }
  val(p1, ip1, ec);
  if ec = 0
  then
    if (ip1 >= 0) and (ip1 <= 99) then
    begin
      val(p2, ip2, ec);
      if ec = 0
      then
        if (ip2 >= 1) and (ip2 <= 100) then e := 0 else e := 21
      else e := 22;
    end else e := 11
  else e := 12;
  case e of
    11: writeln(MESSAGE[1] + MESSAGE[8]);
    12: writeln(MESSAGE[1] + MESSAGE[7]);
    21: writeln(MESSAGE[2] + MESSAGE[8]);
    22: writeln(MESSAGE[2] + MESSAGE[7]);
  else
    begin
      { show memory content with comment }
      for b := ip1 to ip1 + ip2 - 1 do
      if b <= 99 then
      begin
        write(addzero(b), ': ');
        write(addzero(mem[b].data[0]), '  ');
        write(addzero(mem[b].data[1]), '  ');
        write(addzero(mem[b].data[2]), '  ');
        write(addzero(mem[b].data[3]), '  ');
        if length(mem[b].comment) > 0 then write(';' + mem[b].comment);
        writeln;
      end;
    end;
  end;
end;

{ COMMAND 'examine' }
procedure cmd_examine(p1: TSplitted);
var
  e:   byte;
  ec:  integer;
  ip1: integer;
begin
  e := 0;
  { check parameters }
  val(p1, ip1, ec);
  if ec = 0
  then
    if (ip1 >= 0) and (ip1 <= 99) then e := 0 else e := 11
  else e := 12;
  case e of
    11: writeln(MESSAGE[1] + MESSAGE[8]);
    12: writeln(MESSAGE[1] + MESSAGE[7]);
  else
    begin
      { show content of memory cell }
      write(MESSAGE[16], addzero(ip1), ': ');
      write(addzero(mem[ip1].data[0]), '  ');
      write(addzero(mem[ip1].data[1]), '  ');
      write(addzero(mem[ip1].data[2]), '  ');
      writeln(addzero(mem[ip1].data[3]), '.');
    end;
  end;
end;

{ COMMAND 'export' }
procedure cmd_export(p1: TSplitted);
var
  address, data: byte;
  binfile:       file of byte;
  e:             byte;
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then e := 12 else
  begin
    assign(binfile, p1);
    {$I-}
      rewrite(binfile);
    {$I+}
    if ioresult <> 0 then e := 2 else
    begin
      { write memory content to binary file }
      for address := 0 to 99 do
        for data := 0 to 3 do
          write(binfile, mem[address].data[data]);
      close(binfile);
    end;
  end;
  case e of
     2: writeln(MESSAGE[18] + p1 + '.');
    12: writeln(MESSAGE[1] + MESSAGE[7]);
  else
    writeln(MESSAGE[17] + p1 + '.');
  end;
end;

{ COMMAND 'fill' }
procedure cmd_fill(p1, p2, p3, p4, p5, p6: TSplitted);
var
  ip1, ip2, ip3, ip4, ip5, ip6: integer;
  ec:                           integer;
  b:                            byte;
  e:                            byte;
begin
  e := 0;
  { check parameters }
  val(p1, ip1, ec);
  if ec = 0
  then
    if (ip1 >= 0) and (ip1 <= 99) then
    begin
      val(p2, ip2, ec);
      if ec = 0
      then
        if (ip2 >= 1) and (ip2 <= 100) then
        begin
          val(p3, ip3, ec);
          if ec = 0
          then
            if (ip3 >= 0) and (ip3 <= 99) then
            begin
              val(p4, ip4, ec);
              if ec = 0
              then
                if (ip4 >= 0) and (ip4 <= 99) then
                begin
                  val(p5, ip5, ec);
                  if ec = 0
                  then
                    if (ip5 >= 0) and (ip5 <= 99) then
                    begin
                      val(p6, ip6, ec);
                      if ec = 0
                      then
                        if (ip6 >= 0) and (ip6 <= 99) then e := 0 else e := 61
                      else e := 62;
                    end else e := 51
                  else e := 52;
                end else e := 41
              else e := 42;
            end else e := 31
          else e := 32;
        end else e := 21
      else e := 22;
    end else e := 11
  else e := 12;
  case e of
    11: writeln(MESSAGE[1] + MESSAGE[8]);
    12: writeln(MESSAGE[1] + MESSAGE[7]);
    21: writeln(MESSAGE[2] + MESSAGE[8]);
    22: writeln(MESSAGE[2] + MESSAGE[7]);
    31: writeln(MESSAGE[3] + MESSAGE[8]);
    32: writeln(MESSAGE[3] + MESSAGE[7]);
    41: writeln(MESSAGE[4] + MESSAGE[8]);
    42: writeln(MESSAGE[4] + MESSAGE[7]);
    51: writeln(MESSAGE[5] + MESSAGE[8]);
    52: writeln(MESSAGE[5] + MESSAGE[7]);
    61: writeln(MESSAGE[6] + MESSAGE[8]);
    62: writeln(MESSAGE[6] + MESSAGE[7]);
  else
    begin
      for b := ip1 to ip1 + ip2 - 1 do
        if b <= 99 then
        begin
          mem[b].data[0] := ip3;
          mem[b].data[1] := ip4;
          mem[b].data[2] := ip5;
          mem[b].data[3] := ip6;
        end;
      writeln(MESSAGE[19] + p3 + ' ' + p4 + ' ' + p5 + ' ' + p6 + '.');
    end;
  end;
end;

{ COMMAND 'help' }
procedure cmd_help(p1: TSplitted);
var
  l: boolean;
begin
  { show information about machine code }
  if p1 = 'code' then
  begin
    for b := 0 to INSTARRSIZE do
      if b = 15 then writeln(INST_INF[1]) else
        if b > 15 then writeln(INST_INF[b - 1]) else writeln(INST_INF[b]);
  end else
  begin
    l := false;
    { show description about all or selected command(s) }
    for b := 0 to COMMARRSIZE do
      if (length(p1) = 0) or (COMMANDS[b] = p1) then
      begin 
        l := true; 
        writeln(COMMANDS_INF[1, b] + #9 + COMMANDS_INF[0, b]);
      end;    
    if not l then writeln(MESSAGE[0]);
  end;
end;

{ COMMAND 'import' }
procedure cmd_import(p1: TSplitted);
var
  address, data: byte;
  binfile:       file of byte;
  e:             byte;
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then e := 12 else
  begin
    assign(binfile, p1);
    {$I-}
      reset(binfile);
    {$I+}
    if ioresult <> 0 then e := 2 else
    begin
      for address := 0 to 99 do
        for data := 0 to 3 do
          mem[address].data[data] := 0;
      {$I-}
        { read binary file content }
        for address := 0 to 99 do
          for data := 0 to 3 do
            read(binfile, mem[address].data[data]);
      {$I+}
      if ioresult <> 0 then e := 3;
      close(binfile);
    end;
  end;
  case e of
     2: writeln(MESSAGE[21] + p1 + '.');
     3: writeln(MESSAGE[22]);
    12: writeln(MESSAGE[1] + MESSAGE[7]);
  else
    writeln(MESSAGE[20] + p1 + '.');
  end;
end;

{ COMMAND 'load' }
procedure cmd_load(p1: TSplitted);
var
  address, data: byte;
  b:             byte;
  i1, i2:        integer;
  e:             byte;
  ec:            integer;
  line:          byte;
  lstfile:       text;
  s1, s2:        string[255];
label error;
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then e := 12 else
  begin
    assign(lstfile, p1);
    {$I-}
      reset(lstfile);
    {$I+}
    if ioresult <> 0 then e := 2 else
    begin
      for address := 0 to 99 do
        for data := 0 to 3 do
          mem[address].data[data] := 0;
      { read text file content }
      line := 0;
      repeat
        readln(lstfile, s1);
        line := line + 1;
        { get data }
        s2 := '';
        { remove all space and tabulator }
        for b := 1 to length(s1) do
          if (s1[b] <> #32) and (s1[b] <> #9) then s2 := s2 + s1[b];
        { check comment sign }
        if s2[1] <> ';' then
        begin
          { check length of line }
          if length(s2) < 10 then
          begin
            e := 3;
            close(lstfile);
            goto error;
          end;
          { check content }
          for b := 1 to 10 do
            if not ((s2[b] >= #48) and (s2[b] <= #57)) then
            begin
              e := 4;
              close(lstfile);
              goto error;
            end;
          { load to memory }
          val(s2[1] + s2[2], i1, ec);
          address := i1;
          for b := 0 to 3 do
          begin
            val(s2[3 + b * 2] + s2[4 + b * 2], i2, ec);
            mem[address].data[b]:= i2;
          end;
          { get comment }
          b := 1;
          repeat
            b := b + 1;
          until (s1[b] = ';') or (b = length(s1));
          { load to memory }
          if b + 1 < length(s1) then
            for b := b + 1 to length(s1) do
             mem[address].comment := mem[address].comment + s1[b];
        end;
      until (eof(lstfile)) or (line = 99);
      close(lstfile);
    end;
  end;
error:  
  case e of
     2: writeln(MESSAGE[21] + p1 + '.');
     3: writeln(MESSAGE[24], line);
     4: writeln(MESSAGE[25], line);
    12: writeln(MESSAGE[1] + MESSAGE[7]);
  else
    writeln(MESSAGE[23] + p1 + '.');
  end;
end;

{ COMMAND 'reset' }
procedure cmd_reset;
var
  address, data: byte;
begin
  for address := 0 to 99 do
  begin
    for data := 0 to 3 do
      mem[address].data[data] := 0;
    mem[address].comment := '';
  end;  
  breakpoint := 255;
  prg_counter := 0;
  prg_status := 0;
  writeln(MESSAGE[26]);
end;

{ COMMAND 'save' }
procedure cmd_save(p1: TSplitted);
var
  address, data: byte;
  lstfile:       text;
  e:             byte;
  s:             string[255];
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then e := 12 else
  begin
    assign(lstfile, p1);
    {$I-}
      rewrite(lstfile);
    {$I+}
    if ioresult <> 0 then e := 2 else
    begin
      { write memory content to text file }
      for address := 0 to 99 do
      begin
        s := addzero(address) + '  ';
        for data := 0 to 3 do
          s := s + addzero(mem[address].data[data]) + ' ';
        if length(mem[address].comment) > 0 then s := s + ';' + mem[address].comment;
        writeln(lstfile, s);
      end;
      close(lstfile);
    end;
  end;
  case e of
     2: writeln(MESSAGE[18] + p1 + '.');
    12: writeln(MESSAGE[1] + MESSAGE[7]);
  else
    writeln(MESSAGE[17] + p1 + '.');
  end;
end;

{ COMMAND 'run' }
procedure cmd_run(sbs: boolean; p1: TSplitted);
var
  e:   byte;
  ec:  integer;
  ip1: integer;
  d0, d1, d2, d3: byte;
  prg_error: byte;

{ INSTRUCTION 'ADD' }
function opcode01(d1, d2, d3: byte): byte;
var
  r, m, n, o: real;
begin
  opcode01 := 0;
  { check input data }
  if mem[d1].data[1] div 10 > 1 then opcode01 := 1 else
  begin
    { convert bytes to real }
    r := (mem[d1].data[1] mod 10) * 10000 +
          mem[d1].data[2] * 100 +
          mem[d1].data[3];
    if mem[d1].data[1] div 10 = 1 then r := r * (-1);
    m := (mem[d2].data[1] mod 10) * 10000 +
          mem[d2].data[2] * 100 + 
          mem[d2].data[3]; 
    if mem[d2].data[1] div 10 = 1 then m := m * (-1);
    { operation }
    n := r + m;
    { overflow }
    if (n > 99999.0) or (n < -99999.0) then opcode01 := 2;
    { convert real to bytes }
    o := abs(trunc(n));
    mem[d3].data[3] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[2] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[1] := round(o);
    mem[d3].data[1] := mem[d3].data[1] - (mem[d3].data[1] div 10) * 10;
    if n < 0 then mem[d3].data[1] := mem[d3].data[1] + 10;
  end;
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'SUBTRACT' }
function opcode02(d1, d2, d3: byte): byte;
var
  r, m, n, o: real;
begin
  opcode02 := 0;
  { check input data }
  if mem[d1].data[1] div 10 > 1 then opcode02 := 1 else
  begin
    { convert bytes to real }
    r := (mem[d1].data[1] mod 10) * 10000 +
          mem[d1].data[2] * 100 +
          mem[d1].data[3];
    if mem[d1].data[1] div 10 = 1 then r := r * (-1);
    m := (mem[d2].data[1] mod 10) * 10000 +
          mem[d2].data[2] * 100 +
          mem[d2].data[3];
    if mem[d2].data[1] div 10 = 1 then m := m * (-1);
    { operation }
    n := r - m;
    { overflow }
    if (n > 99999.0) or (n < -99999.0) then opcode02 := 2;
    { convert real to bytes }
    o := abs(trunc(n));
    mem[d3].data[3] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[2] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[1] := round(o);
    mem[d3].data[1] := mem[d3].data[1] - (mem[d3].data[1] div 10) * 10;
    if n < 0 then mem[d3].data[1] := mem[d3].data[1] + 10;
  end;
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'MULTIPLY' }
function opcode03(d1, d2, d3: byte): byte;
var
  r, m, n, o: real;
begin
  opcode03 := 0;
  { check input data }
  if mem[d1].data[1] div 10 > 1 then opcode03 := 1 else
  begin
    { convert bytes to real }
    r := (mem[d1].data[1] mod 10) * 10000 +
          mem[d1].data[2] * 100 +
          mem[d1].data[3];
    if mem[d1].data[1] div 10 = 1 then r := r * (-1);
    m := (mem[d2].data[1] mod 10) * 10000 +
          mem[d2].data[2] * 100 +
          mem[d2].data[3];
    if mem[d2].data[1] div 10 = 1 then m := m * (-1);
    { operation }
    n := r * m;
    { overflow }
    if (n > 99999.0) or (n < -99999.0) then opcode03 := 2;
    { convert real to bytes }
    o := abs(trunc(n));
    mem[d3].data[3] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[2] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[1] := round(o);
    mem[d3].data[1] := mem[d3].data[1] - (mem[d3].data[1] div 10) * 10;
    if n < 0 then mem[d3].data[1] := mem[d3].data[1] + 10;
  end;
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'DIVIDE' }
function opcode04(d1, d2, d3: byte): byte;
var
  r, m, n, o: real;
begin
  opcode04 := 0;
  { check input data }
  if mem[d1].data[1] div 10 > 1 then opcode04 := 1 else
  begin
    { convert bytes to real }
    r := (mem[d1].data[1] mod 10) * 10000 +
          mem[d1].data[2] * 100 +
          mem[d1].data[3];
    if mem[d1].data[1] div 10 = 1 then r := r * (-1);
    m := (mem[d2].data[1] mod 10) * 10000 +
          mem[d2].data[2] * 100 +
          mem[d2].data[3];
    if mem[d2].data[1] div 10 = 1 then m := m * (-1);
    { operation }
    n := r / m;
    { overflow }
    if (n > 99999.0) or (n < -99999.0) then opcode04 := 2;
    { convert real to bytes }
    o := abs(trunc(n));
    mem[d3].data[3] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[2] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[1] := round(o);
    mem[d3].data[1] := mem[d3].data[1] - (mem[d3].data[1] div 10) * 10;
    if n < 0 then mem[d3].data[1] := mem[d3].data[1] + 10;
  end;
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'BRANCH' }
function opcode05(d1, d2, d3: byte): byte;
begin
  opcode05 := 0;
  case d1 of
    0: prg_counter := d3;
    1: if d2 < 0 then prg_counter := d3;
    2: if d2 > 0 then prg_counter := d3;
  else
    opcode05 := 3;
  end;
end;

{ INSTRUCTION 'HALT' }
function opcode06(d1, d2, d3: byte): byte;
begin
  prg_status := 0;
  opcode06 := 0;
end;

{ INSTRUCTION 'READ' }
function opcode07(d1, d2, d3: byte): byte;
begin
  opcode07 := 0;
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'WRITE' }
function opcode08(d1, d2, d3: byte): byte;
begin
  opcode08 := 0;
  writeln(mem[d1].data[0] mod 10, addzero(mem[d1].data[2]),
          addzero(mem[d1].data[2])); 
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'SQRT' }
function opcode09(d1, d2, d3: byte): byte;
var
  r, m, n, o: real;
begin
  opcode09 := 0;
  { check input data }
  if mem[d1].data[1] div 10 > 1 then opcode09 := 1 else
  begin
    { convert bytes to real }
    r := (mem[d1].data[1] mod 10) * 10000 +
          mem[d1].data[2] * 100 +
          mem[d1].data[3];
    if mem[d1].data[1] div 10 = 1 then r := r * (-1);
    { operation }
    n := r * r;
    { overflow }
    if (n > 99999.0) or (n < -99999.0) then opcode09 := 2;
    { convert real to bytes }
    o := abs(trunc(n));
    mem[d3].data[3] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[2] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d3].data[1] := round(o);
    mem[d3].data[1] := mem[d3].data[1] - (mem[d3].data[1] div 10) * 10;
    if n < 0 then mem[d3].data[1] := mem[d3].data[1] + 10;
  end;
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'ABS' }
function opcode10(d1, d2, d3: byte): byte;
begin
  opcode10 := 0;
  prg_counter := prg_counter + 1;
end;

begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then prg_counter := 0 else
  begin
    val(p1, ip1, ec);
    if ec = 0
    then
      if (ip1 >= 0) and (ip1 <= 99) then e := 0 else e := 11
    else e := 12;
    case e of
      11: writeln(MESSAGE[1] + MESSAGE[8]);
      12: writeln(MESSAGE[1] + MESSAGE[7]);
    end;
    prg_counter := ip1;
  end;
  if sbs
    then writeln(MESSAGE[29], addzero(prg_counter))
    else writeln(MESSAGE[28], addzero(prg_counter));
  prg_status := 1;
  repeat
    d0 := mem[prg_counter].data[0];
    d1 := mem[prg_counter].data[1];
    d2 := mem[prg_counter].data[2];
    d3 := mem[prg_counter].data[3];
    prg_error := 0;

    writeln(addzero(prg_counter),': ', addzero(d0), ' ', addzero(d1), ' ', addzero(d2), ' ', addzero(d3));
          
    case d0 of
       0: prg_counter := prg_counter + 1;
       1: prg_error := opcode01(d1, d2, d3);
       2: prg_error := opcode02(d1, d2, d3);
       3: prg_error := opcode03(d1, d2, d3);
       4: prg_error := opcode04(d1, d2, d3);
       5: prg_error := opcode05(d1, d2, d3);
       6: prg_error := opcode06(d1, d2, d3);
       7: prg_error := opcode07(d1, d2, d3);
       8: prg_error := opcode08(d1, d2, d3);
       9: prg_error := opcode09(d1, d2, d3);
      10: prg_error := opcode10(d1, d2, d3);
    else
      prg_error := 99;
    end;
    if prg_counter = 100 then
    begin
      prg_error := 98;
      prg_status := 0;
    end;
    case prg_error of
       1: writeln(prg_counter, ': Incorrect input data.');
       2: writeln(prg_counter, ': Overflow occurred.');
       3: writeln(prg_counter, ': Incorrect jump mode.');
      98: writeln('The program has run out of memory.');
      99: writeln(prg_counter, ': No such instruction.');
    end;
  until prg_status = 0;
end;

{ PARSING COMMANDS }
function parsingcommand(command: TCommand): boolean;
var
  a, b: byte;
  s:    string[255];
  o:    boolean;
label
  break1, break2, break3, break4;
begin
  parsingcommand := false;
  if (length(command) > 0) then
  begin
    { remove space and tab from start of line }
    while (command[1] = #32) or (command[1] = #9) do
      delete(command, 1, 1);
    { remove space and tab from end of line }
    while (command[length(command)] = #32) or (command[length(command)] = #9) do
      delete(command, length(command), 1);
    { remove extra space and tab from line }
    for b := 1 to 255 do
    begin
      if b = length(command) then goto break1;
      if command[b] <> #32 then o := false;
      if (command[b] = #32) and o then command[b] :='@';
      if command[b] = #32 then o := true;
    end;
  break1:
    s := '';
    for b := 1 to length(command) do
      if command[b] <> '@' then s := s + command[b];
    command := s;
    { split command to 8 slices }
    for b := 0 to 7 do
      splitted[b] := '';
    for a := 1 to length(command) do
      if (command[a] = #32) and (command[a - 1] <> #92)
        then goto break2
        else splitted[0] := splitted[0] + command[a];
  break2:
    for b:= 1 to 7 do
    begin
      for a := a + 1 to length(command) do
        if (command[a] = #32) and (command[a - 1] <> #92)
          then goto break3
          else splitted[b] := splitted[b] + command[a];
    break3:
    end;
    { parse command }
    o := false;
    if splitted[0][1] <> COMMENT then
    begin
      for b := 0 to COMMARRSIZE do
        if splitted[0] = COMMANDS[b] then
        begin
          o := true;
          goto break4;
        end;
    break4:
      if o then
      begin
        case b of
           0: cmd_break(splitted[1]);
           1: cmd_comment(splitted[1], splitted[2]);
           2: cmd_deposit(splitted[1], splitted[2], splitted[3],
                          splitted[4], splitted[5]);
           3: cmd_dump(splitted[1], splitted[2]);
           4: cmd_examine(splitted[1]);
           5: cmd_export(splitted[1]);
           6: cmd_fill(splitted[1], splitted[2], splitted[3],
                       splitted[4], splitted[5], splitted[6]);
           7: cmd_help(splitted[1]);
           8: cmd_import(splitted[1]);
           9: cmd_load(splitted[1]);
          10: parsingcommand := true;
          11: cmd_reset;
          12: cmd_run(false, splitted[1]);
          13: cmd_save(splitted[1]);
          14: cmd_run(true, splitted[1]);
        end;
      end else writeln(MESSAGE[0]);
    end;
  end;
end;

begin
  { show program information }
  writeln(HEADER1);
  writeln(HEADER2);
  writeln(HEADER3);
  for b := 1 to length(HEADER2) do write('-');
  writeln;
  { initialize memory, breakpoint and program counter }
  cmd_reset;
  writeln(HINT);
  { main operation }
  repeat
    write(PROMPT); readln(com);
    quit := parsingcommand(com);
  until quit = true;
  halt(0);
end.

