{ +--------------------------------------------------------------------------+ }
{ | DATASSim * Simulator for DATAS machine code                              | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_run.pas                                                              | }
{ | 'RUN' command                                                            | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

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
var
  ec:   integer;
  r, o: real;
  s:    string[6]; 
begin
  opcode07 := 0;
  write(PROMPT2);
  readln(s);
  { check input data }
  val(s, r, ec);
  if (ec = 0) and (r >= -99999.0) and (r <= 99999.0) then
  begin
    r := round(r);
    { convert real to bytes }
    o := abs(trunc(r));
    mem[d1].data[3] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d1].data[2] := round(o - 100 * trunc(o / 100));
    o := trunc(o / 100);
    mem[d1].data[1] := round(o);
    mem[d1].data[1] := mem[d1].data[1] - (mem[d1].data[1] div 10) * 10;
    if r < 0 then mem[d1].data[1] := mem[d1].data[1] + 10;
  end else opcode07 := 1;
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'WRITE' }
function opcode08(d1, d2, d3: byte): byte;
begin
  opcode08 := 0;
  if mem[d1].data[1] div 10 = 1 then write('-');
  writeln(mem[d1].data[1] mod 10,
          addzero(mem[d1].data[2]),
          addzero(mem[d1].data[3])); 
  prg_counter := prg_counter + 1;
end;

{ INSTRUCTION 'SQRT' }
function opcode09(d1, d2, d3: byte): byte;
var
  r, n, o: real;
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
    n := sqrt(r);
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
var
  r, n, o: real;
begin
  opcode10 := 0;
  { check input data }
  if mem[d1].data[1] div 10 > 1 then opcode10 := 1 else
  begin
    { convert bytes to real }
    r := (mem[d1].data[1] mod 10) * 10000 +
          mem[d1].data[2] * 100 +
          mem[d1].data[3];
    if mem[d1].data[1] div 10 = 1 then r := r * (-1);
    { operation }
    n := abs(r);
    { overflow }
    if (n > 99999.0) or (n < -99999.0) then opcode10 := 2;
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
  { run program in memory }
  prg_status := 1;
  repeat
    d0 := mem[prg_counter].data[0];
    d1 := mem[prg_counter].data[1];
    d2 := mem[prg_counter].data[2];
    d3 := mem[prg_counter].data[3];
    prg_error := 0;
    { show actual line (memory cell) }
    if trace then
      writeln(addzero(prg_counter),': ',
              addzero(d0), ' ',
              addzero(d1), ' ',
              addzero(d2), ' ',
              addzero(d3));
    { call operation }
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
    if prg_counter >= 100 then
    begin
      prg_error := 98;
      prg_status := 0;
    end;
    if prg_counter = breakpoint then
    begin
      prg_error := 97;
      prg_status := 0;
    end;
    { show error messages }
    case prg_error of
       1: writeln(prg_counter, ': Incorrect input data.');
       2: writeln(prg_counter, ': Overflow occurred.');
       3: writeln(prg_counter, ': Incorrect jump mode.');
       4: writeln(prg_counter, ': Incorrect input data. [-99999..99999].');
      97: writeln(prg_counter, 'The program stops at the breakpoint.');
      98: writeln('The program has run out of memory.');
      99: writeln(prg_counter, ': No such instruction.');
    end;
    { step-by-step running}
    if sbs then waitforkey;
  until prg_status = 0;
end;
