
(* lexical analyzer template (TP Lex V3.0), V1.0 3-2-91 AG *)

(* global definitions: *)
// ---------------------------------------------------
// lexer.l
// (c) 2020 Jens Kallup <kallup.jens@web.de>
// all rightd reserved.
//
// only for non-profit projects !
// ---------------------------------------------------
function _TOKEN(c: Integer; s: String): Integer; overload;
begin
  variant := Tc64Variant.Create;
  variant.v_type := c;
  case c of
    T_IDENTIFIER: begin
      variant.v_identifier := Tc64Identifier.Create(s);
      variant.v_type       := c;
      yylval.yyc64_identifier := variant.v_identifier;
    end;
    T_STRING: begin
      variant.v_string    := Tc64String.Create(s);
      yylval.yyc64_string := variant.v_string;
    end
  end;
  Result := c;
end;
function _TOKEN(c: Integer; v: Integer): Integer; overload;
begin
  yylval.yyc64_integer := Tc64Integer.Create;
  yylval.yyc64_integer.value := v;
  Result := c;
end;
function _TOKEN(c: Integer; v: Real): Integer; overload;
begin
  yylval.yyc64_real := Tc64Real.Create;
  yylval.yyc64_real.value := v;
  Result := c;
end;


function yylex : Integer;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)

begin
  (* actions: *)
  case yyruleno of
  1:
                      begin end;
  2:
                      begin return(_TOKEN(T_MINUS ,'+')); end;
  3:
                      begin return(_TOKEN(T_PLUS  ,'-')); end;
  4:
                      begin return(_TOKEN(T_TIMES ,'*')); end;
  5:
                      begin return(_TOKEN(T_DIVIDE,'/')); end;
  6:
                      begin return(_TOKEN(T_LBRACE,'(')); end;
  7:
                      begin return(_TOKEN(T_RBRACE,')')); end;
  8:
                      begin return(_TOKEN(T_INTEGER,StrToInt  (yytext))); end;
  9:
                      begin return(_TOKEN(T_REAL   ,StrToFloat(yytext))); end;
  10:
                      begin
    return(_TOKEN(T_PRINT ,yytext));
    end;
  11:
              begin
    return(_TOKEN(T_REM,yytext));
    end;
  12:
                      begin
    return(_TOKEN(T_IDENTIFIER  ,yytext));
    end;

  13:
    begin
    inc(line_no);
    end;
  14:
    begin
    yyerror(Format('%d: ' +
    RES_UNKNOWN_CHAR      + ': %s', [1,yytext]));
    end;

  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 37;
yynmatches = 37;
yyntrans   = 58;
yynstates  = 28;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  1,
  14,
  { 3: }
  2,
  14,
  { 4: }
  3,
  14,
  { 5: }
  4,
  14,
  { 6: }
  5,
  14,
  { 7: }
  6,
  14,
  { 8: }
  7,
  14,
  { 9: }
  8,
  14,
  { 10: }
  14,
  { 11: }
  12,
  14,
  { 12: }
  12,
  14,
  { 13: }
  12,
  14,
  { 14: }
  13,
  { 15: }
  14,
  { 16: }
  8,
  { 17: }
  8,
  { 18: }
  { 19: }
  { 20: }
  12,
  { 21: }
  12,
  { 22: }
  12,
  { 23: }
  9,
  { 24: }
  12,
  { 25: }
  11,
  12,
  { 26: }
  12,
  { 27: }
  10,
  12
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
  1,
  14,
{ 3: }
  2,
  14,
{ 4: }
  3,
  14,
{ 5: }
  4,
  14,
{ 6: }
  5,
  14,
{ 7: }
  6,
  14,
{ 8: }
  7,
  14,
{ 9: }
  8,
  14,
{ 10: }
  14,
{ 11: }
  12,
  14,
{ 12: }
  12,
  14,
{ 13: }
  12,
  14,
{ 14: }
  13,
{ 15: }
  14,
{ 16: }
  8,
{ 17: }
  8,
{ 18: }
{ 19: }
{ 20: }
  12,
{ 21: }
  12,
{ 22: }
  12,
{ 23: }
  9,
{ 24: }
  12,
{ 25: }
  11,
  12,
{ 26: }
  12,
{ 27: }
  10,
  12
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#8,#11,#14..#31,'!'..'''',',','.',':'..'@',
            '['..'`','{'..#255 ]; s: 15),
  ( cc: [ #9,#12,#13,' ' ]; s: 2),
  ( cc: [ #10 ]; s: 14),
  ( cc: [ '(' ]; s: 7),
  ( cc: [ ')' ]; s: 8),
  ( cc: [ '*' ]; s: 5),
  ( cc: [ '+' ]; s: 4),
  ( cc: [ '-' ]; s: 3),
  ( cc: [ '/' ]; s: 6),
  ( cc: [ '0' ]; s: 10),
  ( cc: [ '1'..'9' ]; s: 9),
  ( cc: [ 'A'..'O','Q','S'..'Z','a'..'o','q','s'..'z' ]; s: 13),
  ( cc: [ 'P','p' ]; s: 11),
  ( cc: [ 'R','r' ]; s: 12),
{ 1: }
  ( cc: [ #1..#8,#11,#14..#31,'!'..'''',',','.',':'..'@',
            '['..'`','{'..#255 ]; s: 15),
  ( cc: [ #9,#12,#13,' ' ]; s: 2),
  ( cc: [ #10 ]; s: 14),
  ( cc: [ '(' ]; s: 7),
  ( cc: [ ')' ]; s: 8),
  ( cc: [ '*' ]; s: 5),
  ( cc: [ '+' ]; s: 4),
  ( cc: [ '-' ]; s: 3),
  ( cc: [ '/' ]; s: 6),
  ( cc: [ '0' ]; s: 10),
  ( cc: [ '1'..'9' ]; s: 9),
  ( cc: [ 'A'..'O','Q','S'..'Z','a'..'o','q','s'..'z' ]; s: 13),
  ( cc: [ 'P','p' ]; s: 11),
  ( cc: [ 'R','r' ]; s: 12),
{ 2: }
{ 3: }
{ 4: }
{ 5: }
{ 6: }
{ 7: }
{ 8: }
{ 9: }
  ( cc: [ '.' ]; s: 18),
  ( cc: [ '0' ]; s: 17),
  ( cc: [ '1'..'9' ]; s: 16),
{ 10: }
  ( cc: [ '.' ]; s: 18),
  ( cc: [ '0'..'9' ]; s: 19),
{ 11: }
  ( cc: [ '0'..'9','A'..'Q','S'..'Z','_','a'..'q','s'..'z' ]; s: 21),
  ( cc: [ 'R','r' ]; s: 20),
{ 12: }
  ( cc: [ '0'..'9','A'..'D','F'..'Z','_','a'..'d','f'..'z' ]; s: 21),
  ( cc: [ 'E','e' ]; s: 22),
{ 13: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 21),
{ 14: }
{ 15: }
{ 16: }
  ( cc: [ '.' ]; s: 18),
  ( cc: [ '0' ]; s: 17),
  ( cc: [ '1'..'9' ]; s: 16),
{ 17: }
  ( cc: [ '.' ]; s: 18),
  ( cc: [ '0'..'9' ]; s: 17),
{ 18: }
  ( cc: [ '0'..'9' ]; s: 23),
{ 19: }
  ( cc: [ '.' ]; s: 18),
  ( cc: [ '0'..'9' ]; s: 19),
{ 20: }
  ( cc: [ '0'..'9','A'..'H','J'..'Z','_','a'..'h','j'..'z' ]; s: 21),
  ( cc: [ 'I','i' ]; s: 24),
{ 21: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 21),
{ 22: }
  ( cc: [ '0'..'9','A'..'L','N'..'Z','_','a'..'l','n'..'z' ]; s: 21),
  ( cc: [ 'M','m' ]; s: 25),
{ 23: }
  ( cc: [ '0'..'9' ]; s: 23),
{ 24: }
  ( cc: [ '0'..'9','A'..'M','O'..'Z','_','a'..'m','o'..'z' ]; s: 21),
  ( cc: [ 'N','n' ]; s: 26),
{ 25: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 21),
{ 26: }
  ( cc: [ '0'..'9','A'..'S','U'..'Z','_','a'..'s','u'..'z' ]; s: 21),
  ( cc: [ 'T','t' ]; s: 27),
{ 27: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 21)
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 5,
{ 5: } 7,
{ 6: } 9,
{ 7: } 11,
{ 8: } 13,
{ 9: } 15,
{ 10: } 17,
{ 11: } 18,
{ 12: } 20,
{ 13: } 22,
{ 14: } 24,
{ 15: } 25,
{ 16: } 26,
{ 17: } 27,
{ 18: } 28,
{ 19: } 28,
{ 20: } 28,
{ 21: } 29,
{ 22: } 30,
{ 23: } 31,
{ 24: } 32,
{ 25: } 33,
{ 26: } 35,
{ 27: } 36
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 4,
{ 4: } 6,
{ 5: } 8,
{ 6: } 10,
{ 7: } 12,
{ 8: } 14,
{ 9: } 16,
{ 10: } 17,
{ 11: } 19,
{ 12: } 21,
{ 13: } 23,
{ 14: } 24,
{ 15: } 25,
{ 16: } 26,
{ 17: } 27,
{ 18: } 27,
{ 19: } 27,
{ 20: } 28,
{ 21: } 29,
{ 22: } 30,
{ 23: } 31,
{ 24: } 32,
{ 25: } 34,
{ 26: } 35,
{ 27: } 37
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 5,
{ 5: } 7,
{ 6: } 9,
{ 7: } 11,
{ 8: } 13,
{ 9: } 15,
{ 10: } 17,
{ 11: } 18,
{ 12: } 20,
{ 13: } 22,
{ 14: } 24,
{ 15: } 25,
{ 16: } 26,
{ 17: } 27,
{ 18: } 28,
{ 19: } 28,
{ 20: } 28,
{ 21: } 29,
{ 22: } 30,
{ 23: } 31,
{ 24: } 32,
{ 25: } 33,
{ 26: } 35,
{ 27: } 36
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 4,
{ 4: } 6,
{ 5: } 8,
{ 6: } 10,
{ 7: } 12,
{ 8: } 14,
{ 9: } 16,
{ 10: } 17,
{ 11: } 19,
{ 12: } 21,
{ 13: } 23,
{ 14: } 24,
{ 15: } 25,
{ 16: } 26,
{ 17: } 27,
{ 18: } 27,
{ 19: } 27,
{ 20: } 28,
{ 21: } 29,
{ 22: } 30,
{ 23: } 31,
{ 24: } 32,
{ 25: } 34,
{ 26: } 35,
{ 27: } 37
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 15,
{ 2: } 29,
{ 3: } 29,
{ 4: } 29,
{ 5: } 29,
{ 6: } 29,
{ 7: } 29,
{ 8: } 29,
{ 9: } 29,
{ 10: } 32,
{ 11: } 34,
{ 12: } 36,
{ 13: } 38,
{ 14: } 39,
{ 15: } 39,
{ 16: } 39,
{ 17: } 42,
{ 18: } 44,
{ 19: } 45,
{ 20: } 47,
{ 21: } 49,
{ 22: } 50,
{ 23: } 52,
{ 24: } 53,
{ 25: } 55,
{ 26: } 56,
{ 27: } 58
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 14,
{ 1: } 28,
{ 2: } 28,
{ 3: } 28,
{ 4: } 28,
{ 5: } 28,
{ 6: } 28,
{ 7: } 28,
{ 8: } 28,
{ 9: } 31,
{ 10: } 33,
{ 11: } 35,
{ 12: } 37,
{ 13: } 38,
{ 14: } 38,
{ 15: } 38,
{ 16: } 41,
{ 17: } 43,
{ 18: } 44,
{ 19: } 46,
{ 20: } 48,
{ 21: } 49,
{ 22: } 51,
{ 23: } 52,
{ 24: } 54,
{ 25: } 55,
{ 26: } 57,
{ 27: } 58
);


var yyn : Integer;

label start, scan, action;

begin

start:

  (* initialize: *)

  yynew;

scan:

  (* mark positions and matches: *)

  for yyn := yykl[yystate] to     yykh[yystate] do yymark(yyk[yyn]);
  for yyn := yymh[yystate] downto yyml[yystate] do yymatch(yym[yyn]);

  if yytl[yystate]>yyth[yystate] then goto action; (* dead state *)

  (* get next character: *)

  yyscan;

  (* determine action: *)

  yyn := yytl[yystate];
  while (yyn<=yyth[yystate]) and not (yyactchar in yyt[yyn].cc) do inc(yyn);
  if yyn>yyth[yystate] then goto action;
    (* no transition on yyactchar in this state *)

  (* switch to new state: *)

  yystate := yyt[yyn].s;

  goto scan;

action:

  (* execute action: *)

  if yyfind(yyrule) then
    begin
      yyaction(yyrule);
      if yyreject then goto action;
    end
  else if not yydefault and yywrap() then
    begin
      yyclear;
      return(0);
    end;

  if not yydone then goto start;

  yylex := yyretval;

end(*yylex*);



