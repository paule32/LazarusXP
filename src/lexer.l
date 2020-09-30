// ---------------------------------------------------
// lexer.l
// (c) 2020 Jens Kallup <kallup.jens@web.de>
// all rightd reserved.
//
// only for non-profit projects !
// ---------------------------------------------------
%{
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
%}

%%

[ \t\f\r]             begin end;
"-"                   begin return(_TOKEN(T_MINUS ,'+')); end;
"+"                   begin return(_TOKEN(T_PLUS  ,'-')); end;
"*"                   begin return(_TOKEN(T_TIMES ,'*')); end;
"/"                   begin return(_TOKEN(T_DIVIDE,'/')); end;
"("                   begin return(_TOKEN(T_LBRACE,'(')); end;
")"                   begin return(_TOKEN(T_RBRACE,')')); end;
[1-9]+[0-9]*          begin return(_TOKEN(T_INTEGER,StrToInt  (yytext))); end;
[0-9]+\.[0-9]+        begin return(_TOKEN(T_REAL   ,StrToFloat(yytext))); end;
[pP][rR][iI][nN][tT]  begin
    return(_TOKEN(T_PRINT ,yytext));
    end;
[rR][eE][mM]  begin
    return(_TOKEN(T_REM,yytext));
    end;
[A-Za-z][A-Za-z0-9_]* begin
    return(_TOKEN(T_IDENTIFIER  ,yytext));
    end;

\n  begin
    inc(line_no);
    end;
.   begin
    yyerror(Format('%d: ' +
    RES_UNKNOWN_CHAR      + ': %s', [1,yytext]));
    end;

%%

