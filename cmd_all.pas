{ +--------------------------------------------------------------------------+ }
{ | DATASSim * Simulator for DATAS machine code                              | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_all.pas                                                              | }
{ | All command without 'RUN'                                                | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

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
      else writeln(MESSAGE[10], addzero(breakpoint), '.');
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
          writeln(MESSAGE[12], addzero(breakpoint), '.');
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
        write(addzero(mem[b].data[0]), ' ');
        write(addzero(mem[b].data[1]), ' ');
        write(addzero(mem[b].data[2]), ' ');
        write(addzero(mem[b].data[3]), ' ');
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

{ COMMAND 'trace' }
procedure cmd_trace(p1: TSplitted);
var
 e: byte;
begin
  e := 0;
  { check parameters and set value }
  if length(p1) = 0 then trace := not trace else
    if upcase(p1) = 'ON' then trace := true else
      if upcase(p1) = 'OFF' then trace := false else
      e := 11;
  if e = 11
    then writeln(MESSAGE[1] + MESSAGE[8])
    else
      if trace then writeln(MESSAGE[30]) else writeln(MESSAGE[31]);
end;
