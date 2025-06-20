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
  bp:           byte;                          { breakpoint address}
  com:          TCommand;                      { command line content}
  mem:          array[0..99] of TMemcell;      { 'memory' }
  pc:           byte;                          { program counter }
  q:            boolean;
  splitted:     array[0..7] of TSplitted;      { splitted command }
  s:            string[255];
const
  COMMARRSIZE = 14;
  COMMANDS:     array[0..COMMARRSIZE] of string[7] = (
                'break',  'comment','deposit','examine','export', 'fill',
                'help',   'import', 'load',   'quit',   'reset',  'run',
                'save',   'step',   'dump');
  COMMANDS_INF: array[0..1,0..COMMARRSIZE] of string[32] = ((
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                ''),(
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                ''));
  COMMENT =     ';';
  HEADER1 =     'DATASSim v0.1 for CP/M and DOS';
  HEADER2 =     '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>';
  HEADER3 =     'Licence: EUPL v1.2';
  HINT =        'Type "h" for useable commands.';
  MESSAGE:      array[0..12] of string[32] = (
                'No such command!',
                'm1',
                'm2',
                'm3',
                'm4',
                'm5',
                'm6',
                'm7',
                'm8',
                'm9',
                'm10',
                'm11',
                'm12');
  PROMPT =      'SIM>';

{ set and reset breakpoint }
{ parameters: AA or }
procedure cmd_break(p1: Tsplitted);
begin
end;

{ set comment }
{ 'comment' or AA 'comment' }
procedure cmd_comment(p1, p2: Tsplitted);
begin
end;

{ deposit data in memory }
{ parameters: AA D1 D2 D3 D4}
procedure cmd_deposit(p1, p2, p3, p4, p5: Tsplitted);
begin
end;

{ examine data in memory }
{ parameters: AA D1 D2 D3 D4}
procedure cmd_examine;
begin
end;
{ parameters: AA D1 D2 D3 D4}
procedure cmd_export;
begin
end;

{ fill memory with data }
{ parameters: AA count D1 D2 D3 D4}
procedure cmd_fill(p1, p2, p3, p4, p5, p6: Tsplitted);
var
  ip1, ip2, ip3, ip4, ip5, ip6, ec: integer;
  b: byte;
  e: byte;
begin
  { check parameters }
  val(p1, ip1, ec);
  writeln(ip1);
  if ec = 0
  then
    if (ip1 >= 0) and (ip1 <= 99) then
    begin
      val(p2, ip2, ec);
      writeln(p2);
      if ec = 0
      then
        if (ip2 >= 1) and (ip2 <= 100) then
        begin
          val(p3, ip3, ec);
          writeln(ip3);
          if ec = 0
          then
            if (ip3 >= 0) and (ip3 <= 99) then
            begin
              val(p4, ip4, ec);
              writeln(ip4);
              if ec = 0
              then
                if (ip4 >= 0) and (ip4 <= 99) then
                begin
                  val(p5, ip5, ec);
                  writeln(ip5);
                  if ec = 0
                  then
                    if (ip5 >= 0) and (ip5 <= 99) then
                    begin
                      val(p6, ip6, ec);
                      writeln(ip6);
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
    11: writeln(MESSAGE[1]);
    12: writeln(MESSAGE[2]);
    21: writeln(MESSAGE[3]);
    22: writeln(MESSAGE[4]);
    31: writeln(MESSAGE[5]);
    32: writeln(MESSAGE[6]);
    41: writeln(MESSAGE[7]);
    42: writeln(MESSAGE[8]);
    51: writeln(MESSAGE[9]);
    52: writeln(MESSAGE[10]);
    61: writeln(MESSAGE[11]);
    62: writeln(MESSAGE[12]);
  else
    begin
      for b := ip1 to ip1 + ip2 do
        if (ip1 + ip2) <= 99 then
        begin
          writeln(b);
          mem[b].data[0] := ip3;
          mem[b].data[1] := ip4;
          mem[b].data[2] := ip5;
          mem[b].data[3] := ip6;
        end;
    end;
  end;
end;

{ parameters: AA D1 D2 D3 D4}
procedure cmd_help;
begin
end;
{ parameters: AA D1 D2 D3 D4}
procedure cmd_import;
begin
end;
{ parameters: AA D1 D2 D3 D4}
procedure cmd_load;
begin
end;
{ parameters: AA D1 D2 D3 D4}
procedure cmd_quit;
begin
end;
{ parameters: AA D1 D2 D3 D4}
procedure cmd_reset;
begin
end;
{ parameters: AA D1 D2 D3 D4}
procedure cmd_run;
begin
end;
{ parameters: AA D1 D2 D3 D4}
procedure cmd_save;
begin
end;

{ parameters: AA D1 D2 D3 D4}
procedure cmd_step;
begin
end;

{ dump memory content }
{ parameters: AA count }
procedure cmd_dump;
var
  b: byte;
begin
  for b:= 0 to 99 do
  begin
    write(b, '|',mem[b].data[0],'  ',mem[b].data[1],'  ',mem[b].data[2],'  ',mem[b].data[3]);
    writeln;
  end;
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
      while (command[length(command)] = #32) or
            (command[length(command)] = #9) do
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
          writeln(splitted[1], splitted[2], splitted[3], splitted[4], splitted[5], splitted[6]);
        if o then
        begin
          case b of
              0: cmd_help;
              5: cmd_fill(splitted[1], splitted[2], splitted[3],
                          splitted[4], splitted[5], splitted[6]);
              9: parsingcommand := true;
              14: cmd_dump;
        end;
      end else
        writeln(MESSAGE[0]);
   end;
  end;
end;

begin
  writeln(HEADER1);
  writeln(HEADER2);
  writeln(HEADER3);
  for b := 1 to length(HEADER2) do write('-');
  writeln;
  writeln(HINT);
  { initialize memory, breakpoint and program counter }
  parsingcommand('fill 00 100 00 00 00 00');
  bp := 255;
  pc := 0;
  q := false;
  repeat
    write(PROMPT); readln(com);
    q := parsingcommand(com);
  until q = true;
  halt(0);
end.
