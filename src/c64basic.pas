unit C64BASIC;

interface

uses
  Dialogs, Classes, SysUtils, parser;

type
  // c64 Byte-Code hex.   // dec.   BASIC-Addr.
  c64_Token = (
    c64_EOF       = $00,  // EOF - End Of File

    c64_END       = $80,  // 128    $a831
    c64_FOR       = $81,  // 129    $a742
    c64_NEXT      = $82,  // 130    $ad1d
    c64_DATA      = $83,  // 131    $a
    c64_INPUT1    = $84,  // 132
    c64_INPUT2    = $85,  // 133
    c64_DIM       = $86,  // 134    $b081
    c64_READ      = $87,  // 135    $ac06
    c64_LET       = $88,  // 136    $a9a5
    c64_GOTO      = $89,  // 137
    c64_RUN       = $8a,  // 138
    c64_IF        = $8b,
    c64_RESTORE   = $8c,
    c64_GOSUB     = $8d,
    c64_RETURN    = $8e,
    c64_REM       = $8f,
    c64_STOP      = $90,
    c64_ON        = $91,
    c64_WAIT      = $92,
    c64_LOAD      = $93,
    c64_SAVE      = $94,
    c64_VERIFY    = $95,
    c64_DEF       = $96,
    c64_POKE      = $97,
    c64_PRINT1    = $98,
    c64_PRINT2    = $99   //
  );
var
  c64_TokenStream: Array[0..$ffff] of Char;

implementation

end.

