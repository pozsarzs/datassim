{ +--------------------------------------------------------------------------+ }
{ | Ansi unit * ANSI screen handler for BeOS                                 | }
{ | Copyright (C) 2004 Pozsar Zsolt <pozsarzs@axelero.hu>                    | }
{ | ansi.pp                                                                  | }
{ | FreePascal unit file                                                     | }
{ +--------------------------------------------------------------------------+ }

program dts2bin;
type
  TFilename = string[12];
  TMemcell= record
    data: array[0..3] of byte;
  end;
var
  address, data: byte;
  error: byte;
  line: byte;
  memory: array[0..99] of TMemcell;

{ load dts file }
function dts2mem(filename: TFilename): byte;
var

  address: byte;
  data: array[0..4] of byte;
  b: byte;
  i1, i2: integer;
  ec: integer;
  dtsfile: text;
  s1, s2: string[255];
begin

  assign(dtsfile, filename);
  {$I-}
    reset(dtsfile);
  {$I+}
  if ioresult <> 0 then
  begin
    dts2mem := 1;
    exit;
  end;
  line := 0;
  repeat
    readln(dtsfile, s1);
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
        dts2mem := 3;
        close(dtsfile);
        exit;
      end;
      { check content }
      for b := 1 to 10 do
        if not ((s2[b] >= #48) and (s2[b] <= #57)) then
        begin
          dts2mem := 4;
          close(dtsfile);
          exit;
        end;
      { load to memory }
      val(s2[1] + s2[2], i1, ec);
      address := i1;
      write(address,': ');
      for b := 0 to 3 do
      begin
        val(s2[3 + b * 2] + s2[4 + b * 2], i2, ec);
        memory[address].data[b]:= i2;
        write(memory[address].data[b],' ');
      end;
      writeln;
    end;
  until eof(dtsfile);
  close(dtsfile);
  dts2mem := 0;
end;

{ save binary file }
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

    error := dts2mem(paramstr(1));
    if error = 0 then error := mem2bin(paramstr(2));
    case error of
      1: writeln('File read error!');
      2: writeln('File write error!');
      3: writeln('Too short line: ', line);
      4: writeln('Illegal character in: ', line) ;
    end;
  end else writeln('Usage dts2bin.com input.dts output.bin');
  halt(error);
end.
