{ +--------------------------------------------------------------------------+ }
{ | DATASSim * Simulator for DATAS machine code                              | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | datassim.pas                                                             | }
{ | Main program (Turbo Pascal 3.0 CP/M and DOS)                             | }
{ +--------------------------------------------------------------------------+ }
{
  This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.
}

program datassim;
type
  TCommand =    string[255];
  TFilename =   string[12];
  TSplitted =   string[64];
  TMemcell =    record
    comment:    string[64];
    data:       array[0..3] of byte;
  end;
var
  b:            byte;
  bp:           byte;                                     { breakpoint address }
  com:          TCommand;                               { command line content }
  mem:          array[0..99] of TMemcell;                           { 'memory' }
  pc:           byte;                                        { program counter }
  q:            boolean;
  s:            string[255];
  splitted:     array[0..7] of TSplitted;                   { splitted command }
const
  COMMARRSIZE = 14;
  COMMANDS:     array[0..COMMARRSIZE] of string[7] = (
                'break',  'comment','deposit','dump',   'examine','export',
                'fill',   'help',   'import', 'load',   'quit',   'reset',
                'run',    'save',   'step');
  COMMANDS_INF: array[0..1,0..COMMARRSIZE] of string[63] = ((
                'set and reset breakpoint at AA address',
                'add or remove a sigle-line note for program or AA address',
                'deposit D1-4 value at AA address',
                'print the value of memory cell number CN from AA',
                'examine value at AA address',
                'export memory content to a binary file',
                'fill the memory cell number CN from AA with the value D1-4',
                'help with using the program',
                'import memory content from a binary file',
                'load source code',
                'exit the simulator program',
                'reset simulator',
                'run program from AA address',
                'save source code',
                'run program step-by-step from AA address'),(
                'break [AA]',
                'comment [My\ new\ program] | AA [Jump\ to\ 12]',
                'deposit AA D1 D2 D3 D4',
                'dump AA CN',
                'examine AA',
                'export filename.bin',
                'fill AA CN D1 D2 D3 D4',
                'help [command]',
                'import filename.bin',
                'load filename.lst',
                'quit',
                'reset',
                'run [AA]',
                'save filename.lst',
                'step'));
  COMMENT =     ';';
  HEADER1 =     'DATASSim v0.1 for CP/M and DOS';
  HEADER2 =     '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>';
  HEADER3 =     'Licence: EUPL v1.2';
  HINT =        'Type "h" for useable commands.';
  MESSAGE:      array[0..11] of string[39] = (
                'No such command!',
                ' 1st ',
                ' 2nd ',
                ' 3rd ',
                ' 4th ',
                ' 5th ',
                ' 6th ',
                'The',
                'parameter is incorrect.',
                'parameter value is incorrect: ',
                'The breakpoint is deleted.',
                'The breakpoint is set to this address: ');
  PROMPT =      'SIM>';

{ COMMAND 'break' }
procedure cmd_break(p1: TSplitted);
var
  e:   byte;
  ec:  integer;
  ip1: integer;
begin
  if length(p1) = 0 then
  begin
    bp := 255;
    writeln(MESSAGE[10])
  end else
  begin
    val(p1, ip1, ec);
    if ec = 0
    then
      if (ip1 >= 0) and (ip1 <= 99) then e := 0 else e := 11
    else e := 12;
    case e of
      11: writeln(MESSAGE[7]+MESSAGE[1]+MESSAGE[8]);
      12: writeln(MESSAGE[7]+MESSAGE[1]+MESSAGE[9]+'[0-99]');
    else
      begin
        bp := ip1;
        writeln(MESSAGE[11])
      end;
    end;
  end;
end;

{ COMMAND 'comment' }
procedure cmd_comment(p1, p2: TSplitted);
begin
end;

{ COMMAND 'deposit' }
procedure cmd_deposit(p1, p2, p3, p4, p5: TSplitted);
begin
end;

{ COMMAND 'dump' }
procedure cmd_dump(p1, p2: TSplitted);
begin
end;

{ COMMAND 'examine' }
procedure cmd_examine(p1: TSplitted);
begin
end;

{ COMMAND 'export' }
procedure cmd_export(p1: TSplitted);
begin
end;

{ COMMAND 'fill' }
procedure cmd_fill(p1, p2, p3, p4, p5, p6: TSplitted);
var
  ip1, ip2, ip3, ip4, ip5, ip6: integer;
  ec:                           integer;
  b:                            byte;
  e:                            byte;
begin
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
    11: writeln(MESSAGE[7]+MESSAGE[1]+MESSAGE[8]);
    12: writeln(MESSAGE[7]+MESSAGE[1]+MESSAGE[9]+'[0-99]');
    21: writeln(MESSAGE[7]+MESSAGE[2]+MESSAGE[8]);
    22: writeln(MESSAGE[7]+MESSAGE[2]+MESSAGE[9]+'[1-100]');
    31: writeln(MESSAGE[7]+MESSAGE[3]+MESSAGE[8]);
    32: writeln(MESSAGE[7]+MESSAGE[3]+MESSAGE[9]+'[0-99]');
    41: writeln(MESSAGE[7]+MESSAGE[4]+MESSAGE[8]);
    42: writeln(MESSAGE[7]+MESSAGE[4]+MESSAGE[9]+'[0-99]');
    51: writeln(MESSAGE[7]+MESSAGE[5]+MESSAGE[8]);
    52: writeln(MESSAGE[7]+MESSAGE[5]+MESSAGE[9]+'[0-99]');
    61: writeln(MESSAGE[7]+MESSAGE[6]+MESSAGE[8]);
    62: writeln(MESSAGE[7]+MESSAGE[6]+MESSAGE[9]+'[0-99]');
  else
    begin
      for b := ip1 to ip1 + ip2 do
        if (ip1 + ip2) <= 99 then
        begin
          mem[b].data[0] := ip3;
          mem[b].data[1] := ip4;
          mem[b].data[2] := ip5;
          mem[b].data[3] := ip6;
        end;
    end;
  end;
end;

{ COMMAND 'help' }
procedure cmd_help(p1: TSplitted);
begin
end;

{ COMMAND 'import' }
procedure cmd_import(p1: TSplitted);
begin
end;

{ COMMAND 'load' }
procedure cmd_load(p1: TSplitted);
begin
end;

{ COMMAND 'reset' }
procedure cmd_reset;
begin
end;

{ COMMAND 'run' }
procedure cmd_run(p1: TSplitted);
begin
end;

{ COMMAND 'save' }
procedure cmd_save(p1: TSplitted);
begin
end;

{ COMMAND 'step' }
procedure cmd_step(p1: TSplitted);
begin
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
          12: cmd_run(splitted[1]);
          13: cmd_save(splitted[1]);
          14: cmd_step(splitted[1]);
        end;
      end else writeln(MESSAGE[0]);
    end;
  end;
end;

begin
  { show information and command line hint}
  writeln(HEADER1);
  writeln(HEADER2);
  writeln(HEADER3);
  for b := 1 to length(HEADER2) do write('-');
  writeln;
  writeln(HINT);
  { initialize memory, breakpoint and program counter }
  q := parsingcommand('fill 00 100 00 00 00 00');
  bp := 255;
  pc := 0;
  q := false;
  { main operation }
  repeat
    write(PROMPT); readln(com);
    q := parsingcommand(com);
  until q = true;
  halt(0);
end.
