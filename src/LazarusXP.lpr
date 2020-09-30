program LazarusXP;

uses
  c64_locale,

  Interfaces,
  Forms, start, C64BASIC, parser;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

