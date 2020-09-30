
(* Yacc parser template (TP Yacc V3.0), V1.2 6-17-91 AG *)

(* global definitions: *)

{$mode delphi}
{$H+}
// ---------------------------------------------------
// parser.y
// (c) 2020 Jens Kallup <kallup.jens@web.de>
// all rightd reserved.
//
// only for non-profit projects !
// ---------------------------------------------------
unit parser;

interface
uses
  Forms, Dialogs, Classes, SysUtils, lexlib, yacclib,
  LCLType, c64_locale;

var
  line_no: Integer;

type
  TtokenType =  (
    tt1Bit   =  1,
    tt2Bit   =  2,
    tt4Bit   =  4,   //
    tt8Bit   =  8,
    tt16Bit  = 16,
    tt32Bit  = 32,
    tt64Bit  = 64
  );

type
  // -----------------------------------------
  // I love exception handlers : )
  // they make source code more readable ...
  // -----------------------------------------
  Tc64Exception = class
  public
    class procedure RaiseError(param: Integer          ); overload;
    class procedure RaiseError(param: String           ); overload;
    class procedure RaiseError(param: String; s: String); overload;
  end;

type
  // ------------------------------
  // the mother of all "nodes" ...
  // ------------------------------
  Tc64Node = class(TObject)
  private
  public
    constructor Create;
    destructor Destroy;
  end;

  Tc64Symbol = class(Tc64Node)
  private
    FSymbol : String;
    FType   : Integer;
    procedure SetSymbol(s: String ); overload;
    procedure SetSymbol(t: Integer); overload;
  public
    constructor Create(t: Integer; s: String);
    destructor Destroy;
    property Value: String read FSymbol write SetSymbol;
  end;

  // ---------------------------------
  // boolean nodes are atomic 0/1 ...
  // ---------------------------------
  Tc64Boolean = class(Tc64Node)
  private
    FValue: Boolean;
    procedure SetValue(v: Boolean);
  public
    constructor Create;
    destructor Destroy;
    property Value: Boolean read FValue write SetValue;
  end;

  // -----------------------------------
  // integer nodes are not reele nodes!
  // -----------------------------------
  Tc64Integer = class(Tc64Node)
  private
    FValue: Integer;
    procedure SetValue(v: Integer);
  public
    constructor Create;
    destructor Destroy;
    property Value: Integer read FValue write SetValue;
  end;

  // -----------------------------
  // reele nodes can be integers!
  // -----------------------------
  Tc64Real = class(Tc64Node)
  private
    FValue: Real;
    procedure SetValue(v: Real);
  public
    constructor Create;
    destructor Destroy;
    property Value: Real read FValue write SetValue;
  end;

  // -------------------------------------
  // here we go to the string handler ...
  // -------------------------------------
  Tc64String = class(Tc64Node)
  private
    FidentName: String;
    FidentStr : String;
    procedure SetIdentName(v: String);
  public
    constructor Create; overload;
    constructor Create(s: String); overload;

    destructor Destroy;
    property identName: String read FidentName write SetIdentName;
  end;

  // -------------------------------------------------
  // and this is the identifier, a sub type of string
  // without qoutes - see keywords ...
  // -------------------------------------------------
  Tc64Identifier = class(Tc64Node)
  private
    Fname: String;
    procedure SetValue(s: String);
  public
    constructor Create           ; overload;
    constructor Create(s: String); overload;
    destructor Destroy;
    property Value: String read Fname write SetValue;
  end;

type
  // -----------------------------------------------
  // variant tp hold the "result" type of internal
  // used functions return value.
  // this allows to push up more than one result
  // type at one time ...
  // -----------------------------------------------
  Tc64Variant = class
  public
    v_type       : Integer;         // type of variant: self
    v_symbol     : Tc64Symbol;      // +-*/() ...
    v_bool       : Tc64Boolean;     // T_BOOL
    v_integer    : Tc64Integer;     // T_INTEGER
    v_real       : Tc64Real;        // T_REAL
    v_identifier : Tc64Identifier;  // T_IDENT
    v_string     : Tc64String;      // T_STRING
  end;

type
  // -----------------------------------
  // holds informations about a "token"
  // -----------------------------------
  Tc64Token = class(TObject)
  private
    FTokenName: String;
    FTokenType: Tc64Variant;
    procedure SetTokenName(v: String);
    procedure SetTokenType(v: Tc64Variant);
  public
    constructor Create(t: Integer);
    destructor Destroy;
    property TokenName: String      read FTokenName write SetTokenName;
    property TokenType: Tc64Variant read FTokenType write SetTokenType;
  end;

type
  c64_token      = Tc64Token;
  c64_node       = Tc64Node;
  c64_symbol     = Tc64Symbol;

  c64_boolean    = Tc64Boolean;
  c64_integer    = Tc64Integer;
  c64_real       = Tc64Real;
  c64_string     = Tc64String;
  c64_identifier = Tc64Identifier;

var
  variant: Tc64Variant;

  procedure yyerror    (s: String);
  procedure c64_parser (s: String);

implementation

const T_TOKEN = 257;
const T_PLUS = 258;
const T_MINUS = 259;
const T_TIMES = 260;
const T_DIVIDE = 261;
const T_LBRACE = 262;
const T_RBRACE = 263;
const T_BOOL = 264;
const T_INTEGER = 265;
const T_REAL = 266;
const T_IDENTIFIER = 267;
const T_END = 268;
const T_REM = 269;
const T_PRINT = 270;
const T_STRING = 271;

// --------------------------------------------------------------------
// some exception types, to flatten the source code ...
// --------------------------------------------------------------------
class procedure Tc64Exception.RaiseError(param: Integer);begin
  yyerror(Format(RES_EXCEPTION_ERROR + ': %d', [param]));
end;
class procedure Tc64Exception.RaiseError(param: String);begin
  yyerror(Format(RES_EXCEPTION_ERROR + ': %s', [param]));
end;
class procedure Tc64Exception.RaiseError(param: String; s:String);begin
  yyerror(
    Format(
      RES_EXCEPTION_ERROR      + ': %s' +
      LineEnding + RES_IN_LINE + ': %s' , [param, s]
    )
  );
end;

// --------------------------------------
// base "node" for the AST for C64 BASIC
// --------------------------------------
constructor Tc64Node.Create;
begin
  inherited;
end;
destructor Tc64Node.Destroy;
begin
  inherited;
end;

constructor Tc64Symbol.Create(t: Integer; s: String);
begin
  inherited Create;
  FSymbol := s;
end;
destructor Tc64Symbol.Destroy;
begin
  FSymbol := '';
  inherited;
end;
procedure Tc64Symbol.SetSymbol(s: String);
begin
  FSymbol := s;
end;
procedure Tc64Symbol.SetSymbol(t: Integer);
begin
  FType := t;
end;

// ----------------------------------------------
// base "Boolean" node for the AST for C64 BASIC
// ----------------------------------------------
constructor Tc64Boolean.Create;
begin
  inherited;
end;
destructor  Tc64Boolean.Destroy;
begin
  inherited;
end;
procedure Tc64Boolean.SetValue(v: Boolean);
begin
  FValue := v;
end;

// ----------------------------------------------
// base "Integer" node for the AST for C64 BASIC
// ----------------------------------------------
constructor Tc64Integer.Create;
begin
  inherited;
end;
destructor Tc64Integer.Destroy;
begin
  inherited;
end;
procedure Tc64Integer.SetValue(v: Integer);
begin
  FValue := v;
end;

// -------------------------------------------
// base "Real" node for the AST for C64 BASIC
// -------------------------------------------
constructor Tc64Real.Create;
begin
  inherited;
  Value := 0.00;
end;
destructor Tc64Real.Destroy;
begin
  inherited;
end;
procedure Tc64Real.SetValue(v: Real);
begin
  FValue := v;
end;

// ---------------------------------------------
// base "String" node for the AST for C64 BASIC
// ---------------------------------------------
constructor Tc64String.Create;
begin
  inherited Create;
  FidentName := '';
  FidentStr  := '';
end;
constructor Tc64String.Create(s: String);
begin
  inherited Create;
  FidentName :=  s;
  FidentStr  := '';
end;
destructor Tc64String.Destroy;
begin
  FidentName := '';
  FidentStr  := '';
  inherited;
end;
procedure Tc64String.SetIdentName(v: String);
begin
  FidentName := v;
end;

// -------------------------------------------------
// base "Identifier" node for the AST for C64 BASIC
// -------------------------------------------------
constructor Tc64Identifier.Create;
begin
  inherited Create;
end;
constructor Tc64Identifier.Create(s: String);
begin
  inherited Create;
  Fname := s;
end;
destructor Tc64Identifier.Destroy;
begin
  inherited;
end;
procedure Tc64Identifier.SetValue(s: String);
begin
  Fname := s;
end;

// -----------------------------
// just a "token" container ...
// -----------------------------
constructor Tc64Token.Create(t: Integer);
begin
  inherited Create;
  FTokenType        := Tc64Variant.Create;
  FTokenType.v_type := t;
  case t of
    T_LBRACE:     begin FTokenType.v_symbol := Tc64Symbol . Create(t,'('); end;
    T_RBRACE:     begin FTokenType.v_symbol := Tc64Symbol . Create(t,')'); end;

    T_PLUS:       begin FTokenType.v_symbol := Tc64Symbol . Create(t,'+'); end;
    T_MINUS:      begin FTokenType.v_symbol := Tc64Symbol . Create(t,'-'); end;
    T_TIMES:      begin FTokenType.v_symbol := Tc64Symbol . Create(t,'*'); end;
    T_DIVIDE:     begin FTokenType.v_symbol := Tc64Symbol . Create(t,'/'); end;

    T_BOOL:       begin FTokenType.v_bool       := Tc64Boolean   .Create; end;
    T_INTEGER:    begin FTokenType.v_integer    := Tc64Integer   .Create; end;
    T_REAL:       begin FTokenType.v_real       := Tc64Real      .Create; end;

    T_IDENTIFIER: begin FTokenType.v_identifier := Tc64Identifier.Create; end;
    T_STRING:     begin FTokenType.v_string     := Tc64String    .Create; end;
  end;
end;
destructor Tc64Token.Destroy;
begin
  inherited;
end;
procedure Tc64Token.SetTokenName(v: String);
begin
  FTokenName := v;
end;
procedure Tc64Token.SetTokenType(v: Tc64Variant);
begin
//  case v.v_type of
//    T_BOOL:       begin TokenType := v.v_bool;    end;
//    T_INTEGER:    begin TokenType := v.v_integer; end;
//    T_REAL:       begin TokenType.v_real       := Tc64Real      .Create; end;
//    T_IDENTIFIER: begin TokenType.v_identifier := Tc64Identifier.Create; end;
//    T_STRING:     begin TokenType.v_string     := Tc64String    .Create; end;
//  end;
(*
  if not Assigned(FTokenType) then
  FTokenType := Tc64Variant.Create;
  FTokenType.v_type := self;
  Ftype.v_token.TokenType := v;*)
end;

// -------------------------------------------------
// yyerror, simply give message text, and try
// to recover old state (close all files, clean-up)
// -------------------------------------------------
procedure yyerror(s: String);
var
  BoxStyle: Integer;
begin
  BoxStyle := MB_ICONERROR + MB_OK;
  Application.MessageBox(
    PChar(Format(
      RES_ERROR+':%d: %s',[line_no,s])),PChar(
      RES_ERROR) ,
    BoxStyle
  );
end;


type YYSType = record case Integer of
                 1 : ( yyc64_boolean : c64_boolean );
                 2 : ( yyc64_identifier : c64_identifier );
                 3 : ( yyc64_integer : c64_integer );
                 4 : ( yyc64_node : c64_node );
                 5 : ( yyc64_real : c64_real );
                 6 : ( yyc64_string : c64_string );
                 7 : ( yyc64_symbol : c64_symbol );
                 8 : ( yyc64_token : c64_token );
               end(*YYSType*);

var yylval : YYSType;

function yylex : Integer; forward;

function yyparse : Integer;

var yystate, yysp, yyn : Integer;
    yys : array [1..yymaxdepth] of Integer;
    yyv : array [1..yymaxdepth] of YYSType;
    yyval : YYSType;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)
begin
  (* actions: *)
  case yyruleno of
   1 : begin
       end;
   2 : begin
         yyval := yyv[yysp-2];
       end;
   3 : begin
       end;
   4 : begin
         ShowMessage('printer'); 
       end;
   5 : begin
         ShowMessage('remmer' ); 
       end;
   6 : begin
         
         showmessage('cxycycxycxyc');
         ShowMessage(yyv[yysp-0].yyc64_identifier.value);
         yyval.yyc64_identifier := Tc64Identifier.Create(yyv[yysp-0].yyc64_identifier.value);
         yyv[yysp-0].yyc64_identifier.Free;
         
       end;
  end;
end(*yyaction*);

(* parse table: *)

type YYARec = record
                sym, act : Integer;
              end;
     YYRRec = record
                len, sym : Integer;
              end;

const

yynacts   = 6;
yyngotos  = 2;
yynstates = 6;
yynrules  = 6;

yya : array [1..yynacts] of YYARec = (
{ 0: }
{ 1: }
  ( sym: 0; act: 0 ),
  ( sym: 265; act: 2 ),
{ 2: }
  ( sym: 269; act: 4 ),
  ( sym: 270; act: 5 ),
  ( sym: 0; act: -3 ),
  ( sym: 265; act: -3 )
{ 3: }
{ 4: }
{ 5: }
);

yyg : array [1..yyngotos] of YYARec = (
{ 0: }
  ( sym: -6; act: 1 ),
{ 1: }
{ 2: }
  ( sym: -7; act: 3 )
{ 3: }
{ 4: }
{ 5: }
);

yyd : array [0..yynstates-1] of Integer = (
{ 0: } -1,
{ 1: } 0,
{ 2: } 0,
{ 3: } -2,
{ 4: } -5,
{ 5: } -4
);

yyal : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 3,
{ 3: } 7,
{ 4: } 7,
{ 5: } 7
);

yyah : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 2,
{ 2: } 6,
{ 3: } 6,
{ 4: } 6,
{ 5: } 6
);

yygl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 2,
{ 2: } 2,
{ 3: } 3,
{ 4: } 3,
{ 5: } 3
);

yygh : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 2,
{ 3: } 2,
{ 4: } 2,
{ 5: } 2
);

yyr : array [1..yynrules] of YYRRec = (
{ 1: } ( len: 0; sym: -6 ),
{ 2: } ( len: 3; sym: -6 ),
{ 3: } ( len: 0; sym: -7 ),
{ 4: } ( len: 1; sym: -7 ),
{ 5: } ( len: 1; sym: -7 ),
{ 6: } ( len: 1; sym: -2 )
);


const _error = 256; (* error token *)

function yyact(state, sym : Integer; var act : Integer) : Boolean;
  (* search action table *)
  var k : Integer;
  begin
    k := yyal[state];
    while (k<=yyah[state]) and (yya[k].sym<>sym) do inc(k);
    if k>yyah[state] then
      yyact := false
    else
      begin
        act := yya[k].act;
        yyact := true;
      end;
  end(*yyact*);

function yygoto(state, sym : Integer; var nstate : Integer) : Boolean;
  (* search goto table *)
  var k : Integer;
  begin
    k := yygl[state];
    while (k<=yygh[state]) and (yyg[k].sym<>sym) do inc(k);
    if k>yygh[state] then
      yygoto := false
    else
      begin
        nstate := yyg[k].act;
        yygoto := true;
      end;
  end(*yygoto*);

label parse, next, error, errlab, shift, reduce, accept, abort;

begin(*yyparse*)

  (* initialize: *)

  yystate := 0; yychar := -1; yynerrs := 0; yyerrflag := 0; yysp := 0;

{$ifdef yydebug}
  yydebug := true;
{$else}
  yydebug := false;
{$endif}

parse:

  (* push state and value: *)

  inc(yysp);
  if yysp>yymaxdepth then
    begin
      yyerror('yyparse stack overflow');
      goto abort;
    end;
  yys[yysp] := yystate; yyv[yysp] := yyval;

next:

  if (yyd[yystate]=0) and (yychar=-1) then
    (* get next symbol *)
    begin
      yychar := yylex; if yychar<0 then yychar := 0;
    end;

  if yydebug then writeln('state ', yystate, ', char ', yychar);

  (* determine parse action: *)

  yyn := yyd[yystate];
  if yyn<>0 then goto reduce; (* simple state *)

  (* no default action; search parse table *)

  if not yyact(yystate, yychar, yyn) then goto error
  else if yyn>0 then                      goto shift
  else if yyn<0 then                      goto reduce
  else                                    goto accept;

error:

  (* error; start error recovery: *)

  if yyerrflag=0 then yyerror('syntax error');

errlab:

  if yyerrflag=0 then inc(yynerrs);     (* new error *)

  if yyerrflag<=2 then                  (* incomplete recovery; try again *)
    begin
      yyerrflag := 3;
      (* uncover a state with shift action on error token *)
      while (yysp>0) and not ( yyact(yys[yysp], _error, yyn) and
                               (yyn>0) ) do
        begin
          if yydebug then
            if yysp>1 then
              writeln('error recovery pops state ', yys[yysp], ', uncovers ',
                      yys[yysp-1])
            else
              writeln('error recovery fails ... abort');
          dec(yysp);
        end;
      if yysp=0 then goto abort; (* parser has fallen from stack; abort *)
      yystate := yyn;            (* simulate shift on error *)
      goto parse;
    end
  else                                  (* no shift yet; discard symbol *)
    begin
      if yydebug then writeln('error recovery discards char ', yychar);
      if yychar=0 then goto abort; (* end of input; abort *)
      yychar := -1; goto next;     (* clear lookahead char and try again *)
    end;

shift:

  (* go to new state, clear lookahead character: *)

  yystate := yyn; yychar := -1; yyval := yylval;
  if yyerrflag>0 then dec(yyerrflag);

  goto parse;

reduce:

  (* execute action, pop rule from stack, and go to next state: *)

  if yydebug then writeln('reduce ', -yyn);

  yyflag := yyfnone; yyaction(-yyn);
  dec(yysp, yyr[-yyn].len);
  if yygoto(yys[yysp], yyr[-yyn].sym, yyn) then yystate := yyn;

  (* handle action calls to yyaccept, yyabort and yyerror: *)

  case yyflag of
    yyfaccept : goto accept;
    yyfabort  : goto abort;
    yyferror  : goto errlab;
  end;

  goto parse;

accept:

  yyparse := 0; exit;

abort:

  yyparse := 1; exit;

end(*yyparse*);


{$include lexer.pas}

// ------------------------------------------
// yyparse: entry point for mainFileName ...
// ------------------------------------------
procedure c64_parser(s: String);
var
  srcFile: TextFile;
begin
  try
    Assign(srcFile, s);
    Reset(srcFile);
    yyinput := srcFile;
    line_no := 0;
    yyparse ;
    CloseFile(srcFile);
  except
    on e: Exception do begin
    end;
  end;
end;

end.
