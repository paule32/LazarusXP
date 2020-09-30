// ---------------------------------------------------
// c64_locale.pas
// (c) 2020 Jens Kallup <kallup.jens@web.de>
// all rightd reserved.
//
// only for non-profit projects !
// ---------------------------------------------------
unit c64_locale;
{$macro on}
{$define locale_country:=de}

{$mode delphi}
{$H+}

interface
resourcestring
  {$if locale_country=de}         // german locale
  RES_ERROR = 'Fehler';
  RES_WARN  = 'Warnung';
  RES_INFO  = 'Information';
  RES_IN_LINE = 'in Zeile';
  RES_EXCEPTION_ERROR = 'Ausnahme-Fehler';
  RES_UNKNOWN_CHAR = 'unbekanntes Zeichen';
  RES_UNKNOWN_INTERNAL_ERROR = 'interner Fehler';
  {$elseif locale_country=en}     // english locale
  RES_ERROR = 'error';
  RES_WARN  = 'warning';
  RES_INFO  = 'information';
  RES_IN_LINE = 'at line';
  RES_EXCEPTIOM_ERROR = 'exception-error';
  RES_UNKNOWN_CHAR = 'unknown character';
  RES_UNKNOWN_INTERNAL_ERROR = 'internal error';
  {$else}
  {$fatal no locale was set.}
  {$ifend}

implementation

end.

