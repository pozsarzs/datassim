{ +--------------------------------------------------------------------------+ }
{ | DATASSim * Simulator for DATAS machine code                              | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | lst2bin.pas                                                              | }
{ | Source list to binary file converter (Turbo Pascal 3.0 CP/M and DOS)     | }
{ +--------------------------------------------------------------------------+ }
{
  This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.
}

program lst2bin;
type
  TFilename =    string[12];
  TMemcell=      record
    data:        array[0..3] of byte;
  end;
var
  address, data: byte;
  error:         byte;
  line:          byte;
  memory:        array[0..99] of TMemcell;

{ LOAD LST FILE TO MEMORY }
function lst2mem(filename: TFilename): byte;
var
  address: byte;
  b:       byte;
  i1, i2:  integer;
  ec:      integer;
  lstfile: text;
  s1, s2:  string[255];
begin
  assign(lstfile, filename);
  {$I-}
    reset(lstfile);
  {$I+}
  if ioresult <> 0 then
  begin
    lst2mem := 1;
    exit;
  end;
  line := 0;
  repeat
    readln(lstfile, s1);
    line := line + 1;
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
        lst2mem := 3;
        close(lstfile);
        exit;
      end;
      { check content }
      for b := 1 to 10 do
        if not ((s2[b] >= #48) and (s2[b] <= #57)) then
        begin
          lst2mem := 4;
          close(lstfile);
          exit;
        end;
      { load to memory }
      val(s2[1] + s2[2], i1, ec);
      address := i1;
      for b := 0 to 3 do
      begin
        val(s2[3 + b * 2] + s2[4 + b * 2], i2, ec);
        memory[address].data[b]:= i2;
      end;
    end;
  until eof(lstfile);
  close(lstfile);
  lst2mem := 0;
end;

{ SAVE BINARY FILE FROM MEMORY }
function mem2bin(filename: TFilename): byte;
var
  binfile: file of byte;
begin
  assign(binfile, filename);
  {$I-}
    rewrite(binfile);
  {$I+}
  if ioresult <> 0 then
  begin
    mem2bin := 2;
    exit;
  end;
  for address := 0 to 99 do
    for data := 0 to 3 do
      write(binfile, memory[address].data[data]);
  close(binfile);
  mem2bin := 0;
end;

begin
  error := 0;
  line := 0;
  if paramcount > 1 then
  begin
    for address := 0 to 99 do
      for data := 0 to 3 do
        memory[address].data[data] := 0;
    error := lst2mem(paramstr(1));
    if error = 0 then error := mem2bin(paramstr(2));
    case error of
      1: writeln('File read error!');
      2: writeln('File write error!');
      3: writeln('Too short line: ', line);
      4: writeln('Illegal character in: ', line) ;
    end;
  end else writeln('Usage lst2bin.com input.lst output.bin');
  halt;
end.
