{ +--------------------------------------------------------------------------+ }
{ | DATASSim * Simulator for DATAS machine code                              | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | declare.pas                                                              | }
{ | Main program (Turbo Pascal 3.0 CP/M and DOS)                             | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

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
  trace:        boolean;                                       { turn tracking }
const
  COMMARRSIZE = 15;
  INSTARRSIZE = 19;
  COMMENT =     ';';
  { UNCOMMENT CORRESPONDING LINES: }
  HEADER1 =     'DATASSim v0.1 for CP/M';
  { HEADER1 =     'DATASSim v0.1 for DOS'; }
  { HEADER1 =     'DATASSim v0.1'; }
  HEADER2 =     '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>';
  HEADER3 =     'Licence: EUPL v1.2';
  HINT =        'Type ''help [command]'' or ''help code'' for more information.';
  PROMPT1 =     'SIM>';
  PROMPT2 =     'PRG>';
  COMMANDS:     array[0..COMMARRSIZE] of string[7] = (
                'break',  'comment','deposit','dump',   'examine','export',
                'fill',   'help',   'import', 'load',   'quit',   'reset',
                'run',    'save',   'step',   'trace');
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
                'run program step-by-step from AA address',
                'turn tracking on and off'),(
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
                'step [AA]                ',
                'trace [on|off]           '));
  INST_INF:     array[0..INSTARRSIZE] of string[46] = (
                'name      OC D1 D2 D3  operation',
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
                'D1-3: operands',
                '(Dx): value at Dx address',
                's:    sign of the number [0/1, +/-]',
                'd:    decimal number [0..9]');
  MESSAGE:      array[0..31] of string[39] = (
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
                'Step-by-step execution from address ',
                'Trace on.',
                'Trace off.');
