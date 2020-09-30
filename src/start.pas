unit start;

{$mode objfpc}{$H+}

interface

uses
  Windows, LResources,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  ExtCtrls, Grids, Buttons, StdCtrls, ValEdit, SynHighlighterPas,
  SynEdit, LCLType,
  DOM, XMLRead, XMLWrite, Types,
  C64BASIC, parser;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    saveProjectButton: TBitBtn;
    Image18: TImage;
    projectPanel: TPanel;
    projectTypeListBox: TListBox;
    DrawGrid1: TDrawGrid;
    Image15: TImage;
    neuProjectEdit: TEdit;
    Image1: TImage;
    Image2: TImage;
    filePanel: TPanel;
    projectView: TTreeView;
    SaveDialog1: TSaveDialog;
    ScrollBox3: TScrollBox;
    objInspector: TTabSheet;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpeedButton5: TSpeedButton;
    projectFolder: TStaticText;
    TabSheet7: TTabSheet;
    ValueListEditor1: TValueListEditor;
    Image3: TImage;
    Image6: TImage;
    PageControl3: TPageControl;
    PageControl6: TPageControl;
    PageControl8: TPageControl;
    PageControl9: TPageControl;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    projectScrollBox: TScrollBox;
    ScrollBox4: TScrollBox;
    ScrollBox5: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    Splitter5: TSplitter;
    Splitter6: TSplitter;
    TabSheet10: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet9: TTabSheet;
    ControlBar2: TControlBar;
    ControlPanel2: TPanel;
    logBufferList: TStringGrid;
    TabSheet3: TTabSheet;
    ErrorOutput1: TDrawGrid;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    N1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel2a: TPanel;
    PageControl1: TPageControl;
    PageControl4: TPageControl;
    Panel1: TPanel;
    saveProject: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar1: TStatusBar;
    SynPasSyn1: TSynPasSyn;
    TabSheet1: TTabSheet;
    TabSheet5: TTabSheet;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure clickNewDocument(Sender: TObject);
    procedure docComboBoxOnChange(Sender: TObject);
    procedure neuProjectEditChange(Sender: TObject);
    procedure projectTypeListBoxDblClick(Sender: TObject);
    procedure projectTypeListBoxDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure progButtonOnClick(Sender: TObject);
    procedure projectViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure projectViewCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SpeedButton5Click(Sender: TObject);
    procedure mySynEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    mainFileName: String;
    SynEditor: Array of TSynEdit;
    RootNode, parentNode1, parentNode2, nameNode: TDOMNode;
    projectFileName: String;
    projectOpenID: Integer;
    dosProjectFiles: TStringList;
    winProjectFiles: TStringList;
    binProjectFiles: TStringList;
    progBar: TProgressBar;
    progButton : TButton;
    xmldoc: TXMLDocument;
    newDocPanel: TPanel;
    newDoc: TButton;
    newDocComboBox: TComboBox;

    Page1, Page2: TPageControl;

    projectSystemType: String;
    projectSystemARCH: String;
    projectSystemOS  : String;
    projectSystemBITS: String;
    projectSystemName: String;
    projectSystemMainFile: String;

  public

  end;

var
  Form1: TForm1;
  compileProjectType: Integer = 0;

implementation

{$R *.lfm}

{ TForm1 }

function GetCharFromVirtualKey(Key: Word): string;
var
    keyboardState: TKeyboardState;
    asciiResult: Integer;
begin
    GetKeyboardState(keyboardState) ;

    SetLength(Result, 1);
    asciiResult := ToAscii(key, MapVirtualKey(key, 0), keyboardState, @Result[1], 0) ;
    case asciiResult of
      0: Result := '';
      1: SetLength(Result, 1) ;
      2:;
      else
        Result := '';
    end;
end;

procedure TForm1.clickNewDocument(Sender: TObject);
var
  i: Integer;
  found: Boolean;
  s: TMemoryStream;
  viewNode: TTreeNode;
  TabSheetA, TabSheetB, TabSheetC: TTabSheet;
begin
  if Length(Trim(neuProjectEdit.Text)) < 4 then
  begin
    ShowMessage('Dokument-Name müss mindestens 4 Zeichen besitzen !'+#13+
    'Letzte Aktion abgebrochen.');
    exit;
  end;

  for i := 0 to dosProjectFiles.Count - 1 do
  begin
    if dosProjectFiles[i] = Trim(neuProjectEdit.Text) then
    begin
      ShowMessage('Datei bereits in Liste vorhanden !');
      exit;
    end;
  end;
  dosProjectFiles.Add(Trim(neuProjectEdit.Text));

  if not Assigned(Page1) then
  begin
    Page1 := TPageControl.Create(filePanel);
    Page1.Parent := filePanel;
    Page1.Align  := alClient;
    Page1.Show;
  end;

  TabSheetA := TTabSheet.Create(Page1);
  TabSheetA.Parent  := Page1;
  TabSheetA.Align   := alClient;
  TabSheetA.Caption := Trim(neuProjectEdit.Text);
  TabSheetA.Show;

  Page2 := TPageControl.Create(TabSheetA);
  Page2.Parent := TabSheetA;
  Page2.Align  := alClient;
  Page2.TabPosition := tpBottom;
  Page2.Show;

  TabSheetB := TTabSheet.Create(Page2);
  TabSheetB.Parent  := Page2;
  TabSheetB.Align   := alClient;
  TabSheetB.Caption := 'Quelltext';
  TabSheetB.Show;

  TabSheetC := TTabSheet.Create(Page2);
  TabSheetC.Parent  := Page2;
  TabSheetC.Align   := alClient;
  TabSheetC.Caption := 'Designer';
  TabSheetC.Show;

  SynEditor[0] := TSynEdit.Create(TabSheetB);
  SynEditor[0].Parent := TabSheetB;
  SynEditor[0].Align  := alClient;
  SynEditor[0].OnKeyDown := @mySynEditKeyDown;
  SynEditor[0].Show;

  projectView.Items.Clear;
  projectView.ReadOnly := true;
  viewNode := projectView.Items.Add(nil,'Programm-Daten');
  viewNode.ImageIndex := 0;

  objInspector.Visible := false;

  try
    xmlDoc := TXMLDocument.Create;

    // create root node
    RootNode := xmlDoc.CreateElement('project');
    xmlDoc.AppendChild(RootNode);

    // create parent node
    RootNode    := xmlDoc.DocumentElement;
    parentNode1 := xmlDoc.CreateElement('forms');
    parentNode2 := xmlDoc.CreateElement('files');

    case projectTypeListBox.ItemIndex of
      1:  begin
          TDOMElement(RootNode).SetAttribute('os'  , 'vice');
          TDOMElement(RootNode).SetAttribute('arch', 'c64');
          TDOMElement(RootNode).SetAttribute('bits', '16');
          TDOMElement(RootNode).SetAttribute('main', mainFileName);
          TDOMElement(RootNode).SetAttribute('make', neuProjectEdit.Text);
          TDOMElement(RootNode).SetAttribute('type', 'basic');
      end;
      2:  begin
          TDOMElement(RootNode).SetAttribute('os', 'vice');
          TDOMElement(RootNode).SetAttribute('arch', 'c64');
          TDOMElement(RootNode).SetAttribute('bits', '16');
          TDOMElement(RootNode).SetAttribute('main', mainFileName);
          TDOMElement(RootNode).SetAttribute('make', neuProjectEdit.Text);
          TDOMElement(RootNode).SetAttribute('type', 'pascal');
      end;
      3:  begin
          TDOMElement(RootNode).SetAttribute('os', 'vice');
          TDOMElement(RootNode).SetAttribute('arch', 'c64');
          TDOMElement(RootNode).SetAttribute('bits', '16');
          TDOMElement(RootNode).SetAttribute('main', mainFileName);
          TDOMElement(RootNode).SetAttribute('make', neuProjectEdit.Text);
          TDOMElement(RootNode).SetAttribute('type', 'assembler');
      end;
    end;

    RootNode.AppendChild(parentNode1);
    RootNode.AppendChild(parentNode2);

    // create child node
    parentNode1 := xmlDoc.CreateElement('file');
    nameNode := xmlDoc.CreateTextNode('');
    parentNode1.AppendChild(nameNode);
    RootNode.ChildNodes.Item[0].AppendChild(parentNode1);

    // create child node
    for i := 0 to dosProjectFiles.Count - 1 do
    begin
      parentNode2 := xmlDoc.CreateElement('file');
      nameNode := xmlDoc.CreateTextNode(Trim(dosProjectFiles[i]));
      parentNode2.AppendChild(nameNode);
      RootNode.ChildNodes.Item[1].AppendChild(parentNode2);
    end;

    writeXMLFile(xmlDoc, projectFileName);
  finally
    xmldoc.Free;
  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var
  Datei: TFileStream;
  Buffer: String;

  TabSheetA, TabSheetB, TabSheetC: TTabSheet;
  Page11, Page22: TPageControl;
begin
  OpenDialog1 := TOpenDialog.Create(self);
  if OpenDialog1.Execute = true then
  begin
    ShowMessage(OpenDialog1.FileName);
    Datei := TFileStream.Create(OpenDialog1.FileName,fmOpenRead);
    SetLength(Buffer,Datei.Size+1);
    Datei.ReadBuffer(Buffer[1],Datei.Size);
    Datei.Free;

    Page11 := TPageControl.Create(filePanel);
    Page11.Align := alClient;

    TabSheetA := TTabSheet.Create(Page11);
    TabSheetA.Parent  := Page11;
    TabSheetA.Align   := alClient;
    TabSheetA.Caption := 'Unbenannt';
    TabSheetA.Show;

    Page22 := TPageControl.Create(TabSheetA);
    Page22.Parent := TabSheetA;
    Page22.Align  := alClient;
    Page22.TabPosition := tpBottom;
    Page22.Show;

    TabSheetB := TTabSheet.Create(Page2);
    TabSheetB.Parent  := Page22;
    TabSheetB.Align   := alClient;
    TabSheetB.Caption := 'Quelltext';
    TabSheetB.Show;

    TabSheetC := TTabSheet.Create(Page2);
    TabSheetC.Parent  := Page22;
    TabSheetC.Align   := alClient;
    TabSheetC.Caption := 'Designer';
    TabSheetC.Show;

    SynEditor[0] := TSynEdit.Create(TabSheetA);
    SynEditor[0].Parent := TabSheetA;
    SynEditor[0].Align := alClient;
    SynEditor[0].InsertTextAtCaret(Buffer);
    SynEditor[0].Show;
  end;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
var
  i: Integer;
begin
  saveProject := TSaveDialog.Create(self);
  if saveProject.Execute = true then
  begin
//    i := PageControl1.;
  end;
  saveProject.Free;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  Application.Terminate;
  Close;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  saveProject := TSaveDialog.Create(self);
  saveProject.Execute;
  saveProject.Free;
end;

procedure TForm1.projectViewCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if cdsSelected in State then
  begin
    projectView.Canvas.Brush.Color := clBlue;
    projectView.Canvas.Font .Style := Font.Style + [fsBold];
    projectView.Canvas.Font .Color := clYellow;
  end else
  begin
    projectView.Canvas.Brush.Color := clWhite;
    projectView.Canvas.Font .Color := clBlue;
  end;
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
  BitBtn2Click(Sender);
end;

procedure TForm1.mySynEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s: String;
begin
  if ( (Key >= VK_A) and (Key <= VK_Z) ) then
  begin
    s := GetCharFromVirtualKey(Key);
    Application.ProcessMessages;

    (Sender as TSynEdit).InsertTextAtCaret(
    UpperCase(s).Substring(0,1));
  end;
end;

procedure TForm1.neuProjectEditChange(Sender: TObject);
begin
  neuProjectEdit.Brush.Color := clWhite;
  neuProjectEdit.Font .Color := clBlack;

  if FileExists(
  Trim(GetCurrentDir +
  DirectorySeparator + neuProjectEdit.Text) + '.project') then
  begin
    neuProjectEdit.Brush.Color := clRed;
    neuProjectEdit.Font .Color := clYellow;
  end;
end;

{ build application }
procedure TForm1.progButtonOnClick(Sender: TObject);
  function DeleteLastChar(
    const AText: String;
    AChar:Char): String;
  begin
    if AText.IsEmpty then
    exit(AText);

    if AText.Chars[AText.Length-1]=AChar then
    exit(AText.Substring(0,AText.Length-1));
    Result := AText;
  end;
  procedure DeleteLastComma(var AText:String); inline;
  begin
    AText := DeleteLastChar(AText,',');
  end;
var
  s: String;
begin
  progBar := TProgressBar.Create(newDocPanel);
  with progBar do
  begin
    Parent := newDocPanel;
    Top := 115;
    Left := 72;
    Height := 25;
    Width := 128;
    show;
  end;

  SynEditor[0].Lines.SaveToFile(mainFileName);
  c64_parser(mainFileName);
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var
  i: Integer;
  prjImageBox: TImage;
  buildImage : Timage;
var
  Datei: TFileStream;
  Buffer: String;
  found: Boolean;
  s: TMemoryStream;
  doc: TXMLDocument;
var
  TabSheetA, TabSheetB, TabSheetC: TTabSheet;
begin
  if projectOpenID > 0 then
  begin
    try
      projectTypeListBox.Show;

      if Assigned(progBar) then
      begin
        progBar.Parent := nil;
        Application.ReleaseComponent(progBar);
        progBar := nil;
      end;

      if Assigned(progButton) then
      begin
        progButton.Parent := nil;
        Application.ReleaseComponent(progButton);
        progButton := nil;
      end;

      if Assigned(buildImage.Picture) then
      begin
        buildImage.Picture.Free;
        buildImage.Parent := nil;
        Application.ReleaseComponent(buildImage);
        buildImage := nil;
      end;

      if Assigned(newDocPanel) then
      begin
        newDocPanel.Parent := nil;
        Application.ReleaseComponent(newDocPanel);
        newDocPanel := nil;
      end;

      if Assigned(newDocComboBox) then
      begin
        ActiveControl := niL;
        neuProjectEdit.SetFocus;
        newDocComboBox.ItemIndex := -1;
        newDocComboBox.Text := '';
        newDocComboBox.Items.Clear;
        Application.RemoveComponent(newDocComboBox);
        newDocComboBox := nil;
      end;

      dosProjectFiles.Clear;

      Page2.Parent := nil; Application.RemoveComponent(Page2); Page2 := nil;
      Page1.Parent := nil; Application.RemoveComponent(Page1); Page1 := nil;

      neuProjectEdit.Text := '';
      projectOpenID := 0;
      projectFileName := '';
      exit;
    except
      ;   // empty
    end;
  end;

  TabSheetA := nil;
  TabSheetB := nil;
  TabSheetC := nil;

  Page1 := nil;
  Page2 := nil;

  SynEditor[0] := nil;

  with neuProjectEdit do
  begin
    SetFocus;
    Brush.Color := clRed;
    Font .Color := clYellow;
  end;

  if Length(projectFileName) > 0 then
  begin
    projectFolder.Caption :=
    GetCurrentDir +
    DirectorySeparator +
    ExtractFileName(Trim(projectFileName)) +
    '.project';
    if FileExists(projectFolder.Caption) then
    begin
      ShowMessage('Project unter den gleichen Namen bereits vorhanden !');
      //exit; todo
    end;
  end else
  begin
    if Length(Trim(neuProjectEdit.Text)) < 4 then
    begin
      ShowMessage('Projekt-Name nicht angegeben.' + #13+
      'zu wenig Zeichen.');
      exit;
    end else
    projectFileName := ExtractFileName(Trim(neuProjectEdit.Text));
  end;

  if ExtractFileExt(projectFileName) <> '.project' then
  begin
    SaveDialog1.Title := 'Speichern des Projekts ...';
    SaveDialog1.FileName := ExtractFileName(projectFileName) + '.project';
    SaveDialog1.InitialDir := ExtractFilePath(SaveDialog1.FileName);
  end else
  begin
    SaveDialog1.Title := 'Speichern des Projekts ...';
    SaveDialog1.FileName := ExtractFileName(projectFileName);
    SaveDialog1.InitialDir := ExtractFilePath(SaveDialog1.FileName);
  end;

  if SaveDialog1.Execute = true then
  begin
    if FileExists(SaveDialog1.FileName) then
    begin
      ShowMessage('Projekt wird überschrieben !');
      with neuProjectEdit do
      begin
        SetFocus;
        Brush.Color := clLime;
        Font .Color := clBlack;
      end;
    end else
    begin
      with neuProjectEdit do
      begin
        SetFocus;
        Brush.Color := clWhite;
        Font .Color := clBlack;
      end;
    end;
  end; // else exit;

  newDocPanel := TPanel.Create(projectScrollBox);
  with newDocPanel do
  begin
    Parent := projectScrollBox;
    Top := 154;
    Height := 160;
    Width := 210;
    Left := 0;
    Show;
  end;

  case projectTypeListBox.ItemIndex of
    1,2,3,5,6,8,0,10,12,13,15,17,18,19:
    begin
      compileProjectType := projectTypeListBox.ItemIndex;
      projectTypeListBox.Hide;
      prjImageBox := TImage.Create(newDocPanel);
      with prjImageBox do
      begin
        Parent := newDocPanel;
        Top := 5;
        Left := 8;
        Width := 56;
        Height := 56;
        Stretch := true;

        case projectTypeListBox.ItemIndex of
          1: begin
             Picture := TPicture.Create;
             Picture.LoadFromFile('img' + DirectorySeparator + 'c64.jpg'  );
             mainFileName := 'main.bas';
             dosProjectFiles.Add('main.bas');
             projectOpenID := 1;
          end;
          2: begin
             Picture := TPicture.Create;
             Picture.LoadFromFile('img' + DirectorySeparator + 'c64.jpg'  );
             mainFileName := 'main.pas';
             dosProjectFiles.Add('main.pas');
             projectOpenID := 2;
          end;
          3: begin
            Picture := TPicture.Create;
            Picture.LoadFromFile('img' + DirectorySeparator + 'c64.jpg'  );
            mainFileName := 'main.asm';
            dosProjectFiles.Add('main.asm');
            projectOpenID := 3;
          end else begin
             Picture := TPicture.Create;
             Picture.LoadFromFile('img' + DirectorySeparator + 'msdos.jpg');
             dosProjectFiles.Add('main.pas');
             projectOpenID := 3;
          end;
        end;
        Show;
      end;
      buildImage := TImage.Create(newDocPanel);
      with buildImage do
      begin
        Parent := newDocPanel;
        Top := 84;
        Left := 8;
        Width := 56;
        Height := 56;
        Stretch := true;
        Picture.LoadFromFile('img\build.png');
      end;
      progButton := TButton.Create(newDocPanel);
      with progButton do
      begin
        Parent := newDocPanel;
        Top := 84;
        Left := 72;
        Width := 128;
        Height := 25;
        Caption := 'Erstellen';
        onClick := @progButtonOnClick;
        Show;
      end;

      newDoc := TButton.Create(newDocPanel);
      with newDoc do
      begin
        Parent := newDocPanel;
        Top := 5;
        Height := 25;
        Left := 72;
        Width := 128;
        Caption := 'Neues Dokument';
        onClick := @clickNewDocument;
        show;
      end;
      newDocComboBox := TComboBox.Create(newDocPanel);
      with newDocComboBox do
      begin
        Parent := newDocPanel;
        ReadOnly := true;
        Style := csDropDown;
        Top := 35;
        Height := 25;
        Left := 72;
        Width := 128;
        Items.Add('prg - Programm');
        Items.Add('fmt - Formular');
        AutoDropDown := true;
        Text := 'Bitte auswählen...';
        onChange := @docComboBoxOnChange;
        show;
      end;
      projectFileName := SaveDialog1.FileName;
      try
        xmlDoc := TXMLDocument.Create;

        // create root node
        RootNode := xmlDoc.CreateElement('project');
        xmlDoc.AppendChild(RootNode);

        // create parent node
        RootNode    := xmlDoc.DocumentElement;
        parentNode1 := xmlDoc.CreateElement('forms');
        parentNode2 := xmlDoc.CreateElement('files');

        ShowMessage('--> ' + mainFileName);

        case projectOpenID of
          1:  begin
              TDOMElement(RootNode).SetAttribute('os', 'vice');
              TDOMElement(RootNode).SetAttribute('arch', 'c64');
              TDOMElement(RootNode).SetAttribute('bits', '16');
              TDOMElement(RootNode).SetAttribute('main', mainFileName);
              TDOMElement(RootNode).SetAttribute('make', neuProjectEdit.Text);
              TDOMElement(RootNode).SetAttribute('type', 'basic');
          end;
          2: begin
              TDOMElement(RootNode).SetAttribute('os', 'vice');
              TDOMElement(RootNode).SetAttribute('arch', 'c64');
              TDOMElement(RootNode).SetAttribute('bits', '16');
              TDOMElement(RootNode).SetAttribute('main', mainFileName);
              TDOMElement(RootNode).SetAttribute('make', neuProjectEdit.Text);
              TDOMElement(RootNode).SetAttribute('type', 'pascal');
          end;
          3:  begin
              TDOMElement(RootNode).SetAttribute('os', 'vice');
              TDOMElement(RootNode).SetAttribute('arch', 'c64');
              TDOMElement(RootNode).SetAttribute('bits', '16');
              TDOMElement(RootNode).SetAttribute('main', mainFileName);
              TDOMElement(RootNode).SetAttribute('make', neuProjectEdit.Text);
              TDOMElement(RootNode).SetAttribute('type', 'assembler');
          end;
        end;

        RootNode.AppendChild(parentNode1);
        RootNode.AppendChild(parentNode2);

        // create child node
        parentNode1 := xmlDoc.CreateElement('file');
        nameNode := xmlDoc.CreateTextNode('');
        parentNode1.AppendChild(nameNode);
        RootNode.ChildNodes.Item[0].AppendChild(parentNode1);

        // create child node
        for i := 0 to dosProjectFiles.Count - 1 do
        begin
          parentNode2 := xmlDoc.CreateElement('file');
          nameNode := xmlDoc.CreateTextNode(Trim(dosProjectFiles[i]));
          parentNode2.AppendChild(nameNode);
          RootNode.ChildNodes.Item[1].AppendChild(parentNode2);
        end;

        writeXMLFile(xmlDoc, projectFileName);

        if Page1 <> nil then
        Page1.Free;
        Page1 := TPageControl.Create(filePanel);
        Page1.Parent := filePanel;
        Page1.Align  := alClient;
        Page1.Show;

        if FileExists(
        ExtractFilePath(SaveDialog1.FileName) +
        DirectorySeparator + mainFileName) then
        begin
          Datei := TFileStream.Create(mainFileName,fmOpenRead);
          SetLength(Buffer,Datei.Size+1);
          Datei.ReadBuffer(Buffer[1],Datei.Size);
          Datei.Free;
        end else
        begin
          if mainFileName = 'main.pas' then
          begin
            Buffer :=
            'program ' + Trim(neuProjectEdit.Text) + ';' + #13 +
            'begin' + #13 +
            'end.'  + #13 ;
          end else
          if mainFileName = 'main.bas' then
          begin
            Buffer := '10 PRINT "Hallo Welt !"' + #13;
          end else
          if mainFileName = 'main.asm' then
          begin
            Buffer := '; Assembler-Kommentar-Zeile';
          end;
        end;

        if Assigned(TabSheetA) then
        begin
          TabSheetA.Free;
          Application.ProcessMessages;
        end;
        TabSheetA := TTabSheet.Create(Page1);
        TabSheetA.Parent  := Page1;
        TabSheetA.Align   := alClient;
        TabSheetA.Caption := mainFileName;
        TabSheetA.Show;

        if Assigned(Page2) then
        begin
          Page2.Free;
          Application.ProcessMessages;
        end;
        Page2 := TPageControl.Create(TabSheetA);
        Page2.Parent := TabSheetA;
        Page2.Align  := alClient;
        Page2.TabPosition := tpBottom;
        Page2.Show;

        if Assigned(TabSheetB) then
        begin
          TabSheetB.Free;
          Application.ProcessMessages;
        end;
        TabSheetB := TTabSheet.Create(Page2);
        TabSheetB.Parent  := Page2;
        TabSheetB.Align   := alClient;
        TabSheetB.Caption := 'Quelltext';
        TabSheetB.Show;

        if Assigned(TabSheetC) then
        begin
          TabSheetC.Free;
          Application.ProcessMessages;
        end;
        TabSheetC := TTabSheet.Create(Page2);
        TabSheetC.Parent  := Page2;
        TabSheetC.Align   := alClient;
        TabSheetC.Caption := 'Designer';
        TabSheetC.Show;

        if Assigned(SynEditor[0]) then
        begin
          SynEditor[0].Free;
          Application.ProcessMessages;
        end;
        SynEditor[0] := TSynEdit.Create(TabSheetB);
        SynEditor[0].Parent := TabSheetB;
        SynEditor[0].Align  := alClient;
        SynEditor[0].InsertTextAtCaret(Buffer);
        SynEditor[0].OnKeyDown := @mySynEditKeyDown;
        SynEditor[0].Show;

        SynEditor[0].Lines.Delete(
        SynEditor[0].Lines.Count);

        neuProjectEdit.Text := mainFileName;
      finally
        xmldoc.Free;
      end;
    end else
    begin
      newDocPanel.Parent := nil;
      Application.RemoveComponent(newDocPanel);
      newDocPanel := nil;
      projectTypeListBox.Top := 144;
      projectTypeListBox.BringToFront;
      projectTypeListBox.Show;
    end
  end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  i: Integer;
  prjImageBox: TImage;
  buildImage : Timage;
  s1, s2 : String;
var
  Datei: TFileStream;
  Buffer: String;
  found: Boolean;
  s: TMemoryStream;
  Child: TDOMNode;
var
  treeNode1, treeNode2: TTreeNode;
  TabSheetA, TabSheetB, TabSheetC: TTabSheet;
begin
  if projectOpenID > 0 then
  begin
    try
      projectTypeListBox.Show;

      if Assigned(progBar) then
      begin
        progBar.Parent := nil;
        Application.ReleaseComponent(progBar);
        progBar := nil;
      end;

      if Assigned(progButton) then
      begin
        progButton.Parent := nil;
        Application.ReleaseComponent(progButton);
        progButton := nil;
      end;

      if Assigned(buildImage.Picture) then
      begin
        buildImage.Picture.Free;
        buildImage.Parent := nil;
        Application.ReleaseComponent(buildImage);
        buildImage := nil;
      end;

      if Assigned(newDocPanel) then
      begin
        newDocPanel.Parent := nil;
        Application.ReleaseComponent(newDocPanel);
        newDocPanel := nil;
      end;

      if Assigned(newDocComboBox) then
      begin
        ActiveControl := niL;
        neuProjectEdit.SetFocus;
        newDocComboBox.ItemIndex := -1;
        newDocComboBox.Text := '';
        newDocComboBox.Items.Clear;
        Application.RemoveComponent(newDocComboBox);
        newDocComboBox := nil;
      end;

      dosProjectFiles.Clear;

      Page2.Parent := nil; Application.RemoveComponent(Page2); Page2 := nil;
      Page1.Parent := nil; Application.RemoveComponent(Page1); Page1 := nil;

      neuProjectEdit.Text := '';
      projectOpenID := 0;
      projectFileName := '';
      exit;
    except
      ;   // empty
    end;
  end;

  TabSheetA := nil;
  TabSheetB := nil;
  TabSheetC := nil;

  Page1 := nil;
  Page2 := nil;

  SynEditor[0] := nil;

  with neuProjectEdit do
  begin
    SetFocus;
    Brush.Color := clRed;
    Font .Color := clYellow;
  end;

  if OpenDialog1.Execute then
  begin
    if ExtractFileExt(Trim(OpenDialog1.FileName)) <> '.project' then
    begin
      ShowMessage('Projekt kann nicht geäffnet werden.');
      exit;
    end;
    if not FileExists(Trim(OpenDialog1.FileName)) then
    begin
      ShowMessage('Projekt existiert nicht.' + #13 +
      'kann nicht geöffnet werden.');
      exit;
    end;
  end else
  begin
    ShowMessage('beim öffnen des Projektes ist etwas schief gelaufen.');
    exit;
  end;

  neuProjectEdit.Text := ExtractFileName(Trim(OpenDialog1.FileName));
  neuProjectEdit.Brush.Color := clWhite;
  neuProjectEdit.Font .Color := clBlack;

  try
    xmlDoc := TXMLDocument.Create;

    ReadXMLFile(xmlDoc,Trim(OpenDialog1.FileName));

    RootNode := xmlDoc.DocumentElement;
    if LowerCase(RootNode.NodeName) <> 'project' then
    begin
      ShowMessage('kann Format nicht lesen.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;

    if LowerCase(RootNode.Attributes.Item[0].NodeName) <> 'os' then
    begin
      ShowMessage('kann Format nicht lesen.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;
    projectSystemOS :=
    LowerCase(RootNode.Attributes.Item[0].NodeValue);
    if projectSystemOS <> 'vice' then
    begin
      ShowMessage('nur VICE C64 unterstützt.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;

    if LowerCase(RootNode.Attributes.Item[1].NodeName) <> 'arch' then
    begin
      ShowMessage('kann Format nicht lesen.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;

    projectSystemARCH :=
    LowerCase(RootNode.Attributes.Item[1].NodeValue);

    if LowerCase(RootNode.Attributes.Item[2].NodeName) <> 'bits' then
    begin
      ShowMessage('kann Format nicht lesen.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;
    projectSystemBITS :=
    LowerCase(RootNode.Attributes.Item[2].NodeValue);
    if projectSystemBITS <> '16' then
    begin
      ShowMessage('nur 16-Bit Modus unterstützte.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;

    if LowerCase(RootNode.Attributes.Item[3].NodeName) <> 'main' then
    begin
      ShowMessage('kann Format nicht lesen.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;
    projectSystemMainFile :=
    LowerCase(RootNode.Attributes.Item[3].NodeValue);
    mainFileName := projectSystemMainFile;

    if LowerCase(RootNode.Attributes.Item[4].NodeName) <> 'make' then
    begin
      ShowMessage('kann Format nicht lesen.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;
    projectSystemName :=
    LowerCase(RootNode.Attributes.Item[4].NodeValue);
    neuProjectEdit.Text := projectSystemName;

    if LowerCase(RootNode.Attributes.Item[5].NodeName) <> 'type' then
    begin
      ShowMessage('kann Format nicht lesen.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;
    projectSystemType :=
    LowerCase(RootNode.Attributes.Item[5].NodeValue);
    mainFileName := projectSystemMainFile;

    if RootNode.FirstChild.NodeName <> 'forms' then
    begin
      ShowMessage('Projekt-Datei hat falsches Format.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;
    child := RootNode.FindNode('files');
    if LowerCase(LowerCase(child.NodeName)) <> 'files' then
    begin
      ShowMessage('Projekt-Datei hat falsches Format.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;

    projectView.Items.Clear;
    dosProjectFiles  .Clear;

    treeNode1 := projectView.Items.Add(nil,'Formulare');
    treeNode2 := projectView.Items.Add(nil,'Programme');

    for i := 0 to child.ChildNodes.Count - 1 do
    begin
      s1 := LowerCase(child.ChildNodes.Item[i].ChildNodes.Item[0].NodeName );
      s2 := LowerCase(child.ChildNodes.Item[i].ChildNodes.Item[0].NodeValue);

      s1 := StringReplace(s1,'#text','',[rfReplaceAll]);
      s2 := StringReplace(s2,'#text','',[rfReplaceAll]);

      s1 := Trim(s1);
      s2 := Trim(s2);

      dosProjectFiles.Add(s2);
      projectView.Items.AddChild(projectView.Items[1],s2);

      PageControl6.ActivePage := TabSheet7;
      PageControl6.PageIndex  := 2;
    end;

    projectPanel.Top := 220;
    saveProjectButton.Visible := true;

    BitBtn2.Top := 64;
    saveProjectButton.Top := 0;

    newDocPanel := TPanel.Create(projectScrollBox);
    with newDocPanel do
    begin
      Parent := projectScrollBox;
      BevelInner := bvNone;
      BevelOuter := bvNone;
      Top := 48;
      Height := 160;
      Width := 210;
      Left := 0;
      Show;
    end;

    if projectSystemARCH = 'c64' then
    begin
      prjImageBox := TImage.Create(newDocPanel);
      with prjImageBox do
      begin
        Parent := newDocPanel;
        Top := 5;
        Left := 8;
        Width := 56;
        Height := 56;
        Stretch := true;

        Picture := TPicture.Create;
        Picture.LoadFromFile('img' + DirectorySeparator + 'c64.jpg'  );
        projectOpenID := 1;
      end;
    end else
    begin
      ShowMessage('nur C64 Architektur unterstützt.');
      RootNode.Free;
      xmlDoc.Free;
      exit;
    end;

    buildImage := TImage.Create(newDocPanel);
    with buildImage do
    begin
      Parent := newDocPanel;
      Top := 84;
      Left := 8;
      Width := 56;
      Height := 56;
      Stretch := true;
      Picture.LoadFromFile('img\build.png');
    end;
    progButton := TButton.Create(newDocPanel);
    with progButton do
    begin
      Parent := newDocPanel;
      Top := 84;
      Left := 72;
      Width := 128;
      Height := 25;
      Caption := 'Erstellen';
      onClick := @progButtonOnClick;
      Show;
    end;

    newDoc := TButton.Create(newDocPanel);
    with newDoc do
    begin
      Parent := newDocPanel;
      Top := 5;
      Height := 25;
      Left := 72;
      Width := 128;
      Caption := 'Neues Dokument';
      onClick := @clickNewDocument;
      show;
    end;
    newDocComboBox := TComboBox.Create(newDocPanel);
    with newDocComboBox do
    begin
      Parent := newDocPanel;
      ReadOnly := true;
      Style := csDropDown;
      Top := 35;
      Height := 25;
      Left := 72;
      Width := 128;
      Items.Add('prg - Programm');
      Items.Add('fmt - Formular');
      AutoDropDown := true;
      Text := 'Bitte auswählen...';
      onChange := @docComboBoxOnChange;
      show;
    end;

    Page1 := TPageControl.Create(filePanel);
    tabSheetA := Page1.AddTabSheet;
    with Page1 do
    begin
      Parent := filePanel;
      Align  := alClient;
      Font.Name := 'Arial';
      Font.Size := 10;
      Font.Color := clBlack;
      Show;
    end;

    mainFileName :=
    ExtractFilePath(OpenDialog1.FileName) +
    DirectorySeparator + mainFileName     ;

    if FileExists(mainFileName) then
    begin
      Datei := TFileStream.Create(mainFileName,fmOpenRead);
      SetLength(Buffer,Datei.Size);
      Datei.ReadBuffer(Buffer[1],Datei.Size);
      Datei.Free;
    end else
    begin
      mainFileName := ExtractFileName(mainFileName);
      if mainFileName = 'main.pas' then
      begin
        Buffer :=
        'program ' + Trim(neuProjectEdit.Text) + ';' + #13 +
        'begin' + #13 +
        'end.'  + #13 ;
      end else
      if mainFileName = 'main.bas' then
      begin
        Buffer := '10 PRINT "Hallo Welt !"' + #13;
      end else
      if mainFileName = 'main.asm' then
      begin
        Buffer := '; Assembler-Kommentar-Zeile';
      end;
    end;

    with TabSheetA do
    begin
      Parent     := Page1;
      Align      := alClient;
      Font.Name  := 'Arial';
      Font.Size  := 10;
      Font.Color := clBlack;
      Caption    := mainFileName;
      Show;
    end;

    if Assigned(Page2) then
    begin
      Page2.Free;
      Application.ProcessMessages;
    end;
    Page2 := TPageControl.Create(TabSheetA);
    Page2.Parent := TabSheetA;
    Page2.Align  := alClient;
    Page2.TabPosition := tpBottom;
    Page2.Show;

    if Assigned(TabSheetB) then
    begin
      TabSheetB.Free;
      Application.ProcessMessages;
    end;
    TabSheetB := TTabSheet.Create(Page2);
    with TabSheetB do
    begin
      Parent  := Page2;
      Align   := alClient;
      Font.Color := clBlack;
      Caption := 'Quelltext';
      Show;
    end;

    if Assigned(TabSheetC) then
    begin
      TabSheetC.Free;
      Application.ProcessMessages;
    end;
    TabSheetC := TTabSheet.Create(Page2);
    TabSheetC.Parent  := Page2;
    TabSheetC.Align   := alClient;
    TabSheetC.Caption := 'Designer';
    TabSheetC.Show;

    if Assigned(SynEditor[0]) then
    begin
      SynEditor[0].Free;
      Application.ProcessMessages;
    end;
    SynEditor[0] := TSynEdit.Create(TabSheetB);
    SynEditor[0].Parent := TabSheetB;
    SynEditor[0].Align  := alClient;
    SynEditor[0].InsertTextAtCaret(Buffer);
    SynEditor[0].OnKeyDown := @mySynEditKeyDown;
    SynEditor[0].Show;

    neuProjectEdit.Text := mainFileName;
    projectTypeListBox.Hide;

  finally
    xmlDoc.Free;
  end;
end;

procedure TForm1.docComboBoxOnChange(Sender: TObject);
begin
  case newDocComboBox.ItemIndex of
    0: newDocComboBox.Text := 'prg - Programm';
    1: newDocComboBox.Text := 'fmt - Formular' else
       newDocComboBox.Text := 'Bitte auswählen...';
  end;
end;

procedure TForm1.projectTypeListBoxDblClick(Sender: TObject);
var
  Index: Integer;
  s: String;
begin
  index := projectTypeListBox.ItemIndex;
  case Index of
    1,2,3,5,6,8,9,10,12,13,15,17,18,19:
    begin
      compileProjectType := Index;
      {  1 - 16-Bit MSDOS com }
      {  2 - 16-Bit MSDOS sys }

      {  4 - 16-Bit MSDOS exe }
      {  5 - 16-Bit MSDOS dll - native }
      {  6 - 16-Bit MSDOS dll - native (emx) }

      {  8 - 16-Bit MS-DOS  EXE - Windows 3.1 Console          }
      {  9 - 16-Bit MS-DOS  EXE - Windows 3.1 GUI native       }
      { 10 - 16-Bit MS-DOS  EXE - Windows 3.1 GUI native (emx) }

      { 12 - 32-Bit MS-DOS  EXE - Windows 3.1 Console          }
      { 13 - 32-Bit MS-DOS  EXE - Windows 3.1 GUI native (emx) }

      { 15 - 32-Bit MS-Windows 3.1  EXE - GUI native (emx) }

      { 17 - 32-Bit MS-Windows 10  EXE    }
      { 18 - 32-Bit MS-Windows 10  DLL    }
      { 19 - 32-Bit MS-Windows 10  Driver }

      ShowMessage(projectTypeListBox.GetSelectedText);
    end;
  end;
end;

procedure TForm1.projectTypeListBoxDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  (Control as TListBox).BeginUpdateBounds;
  with (Control as TListBox).Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(arect);
    case Index of
      0, 4, 7, 11, 15, 18, 20:
      begin
        Brush.Color := clBlue;
        Font .Color := clYellow;
      end else
      begin
        if odSelected in State then
        begin
          Brush.Color := clYellow;
          Font .Color := clBlack;
        end else
        begin
          Brush.Color := clWhite;
          Font .Color := clBlack;
        end;
      end;
    end;
    TextOut(ARect.Left, ARect.Top, (Control as TListBox).Items[Index]);
    Font.Color := clBlack;
  end;
  (Control as TListBox).EndUpdateBounds;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  dosProjectFiles := TStringList.Create;
  winProjectFiles := TStringList.Create;
  binProjectFiles := TStringList.Create;

  logBufferList.Columns.Items[0].Width := 100;

  projectFolder.Caption := GetCurrentDir;
  projectFileName := '';
  neuProjectEdit.Text := '';

  Page1 := nil;
  Page2 := nil;

  SetLength(SynEditor,2);
  projectOpenID := 0;

  projectTypeListBox.Height := 350;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  dosProjectFiles.Clear;
  winProjectFiles.Clear;
  binProjectFiles.Clear;

  dosProjectFiles.Free;
  winProjectFiles.Free;
  binProjectFiles.Free;
end;

procedure TForm1.Image1Click(Sender: TObject);
var
  i: Integer;
  found: Boolean;
  s: TMemoryStream;
  doc: TXMLDocument;
var
  TabSheetA, TabSheetB, TabSheetC: TTabSheet;
begin
  if not Assigned(Page1) then
  begin
    Page1 := TPageControl.Create(filePanel);
    Page1.Parent := filePanel;
    Page1.Align  := alClient;
    Page1.Show;
  end;

  TabSheetA := TTabSheet.Create(Page1);
  TabSheetA.Parent  := Page1;
  TabSheetA.Align   := alClient;
  TabSheetA.Caption := 'Unbenannt.txt';
  TabSheetA.Show;

  Page2 := TPageControl.Create(TabSheetA);
  Page2.Parent := TabSheetA;
  Page2.Align  := alClient;
  Page2.TabPosition := tpBottom;
  Page2.Show;

  TabSheetB := TTabSheet.Create(Page2);
  TabSheetB.Parent  := Page2;
  TabSheetB.Align   := alClient;
  TabSheetB.Caption := 'Quelltext';
  TabSheetB.Show;

  TabSheetC := TTabSheet.Create(Page2);
  TabSheetC.Parent  := Page2;
  TabSheetC.Align   := alClient;
  TabSheetC.Caption := 'Designer';
  TabSheetC.Show;

  SynEditor[0] := TSynEdit.Create(TabSheetB);
  SynEditor[0].Parent := TabSheetB;
  SynEditor[0].Align  := alClient;
  SynEditor[0].Show;
end;

procedure TForm1.projectViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
  var PaintImages, DefaultDraw: Boolean);
var
  Rec: TRect;
  Style: TTextStyle;
begin
  FillChar(Style, SizeOf(TTextStyle), 0);
  PaintImages      := True;
  Style.Opaque     := True;
  Style.SystemFont := False;

  if cdsSelected in State then
  begin
    TCustomTreeView(Sender).Canvas.Brush.Color := clBlue;
    TCustomTreeView(Sender).Canvas.Font .Style := Font.Style + [fsBold];
    TCustomTreeView(Sender).Canvas.Font .Color := clYellow;
  end else
  begin
    TCustomTreeView(Sender).Canvas.Brush.Color := clWhite;
    TCustomTreeView(Sender).Canvas.Font .Color := clNavy;
  end;

  case node.Level of
    0:
    begin
      TCustomTreeView(Sender).canvas.Font.Name  := 'Arial';
      TCustomTreeView(Sender).canvas.Font.Color := clRed;
      TCustomTreeView(Sender).canvas.Font.Style := [fsbold];
    end;
    1:
    begin
      TCustomTreeView(Sender).canvas.Font.Name  := 'Arial';
      TCustomTreeView(Sender).canvas.Font.Style := [fsBold];
      TCustomTreeView(Sender).canvas.Font.Color := clBlack;

        if cdsSelected in State then
  begin
    TCustomTreeView(Sender).Canvas.Brush.Color := clBlue;
    TCustomTreeView(Sender).Canvas.Font .Style := Font.Style + [fsBold];
    TCustomTreeView(Sender).Canvas.Font .Color := clYellow;
  end else
  begin
    TCustomTreeView(Sender).Canvas.Brush.Color := clWhite;
    TCustomTreeView(Sender).Canvas.Font .Color := clNavy;
  end;
    end;
  end;

  Rec := Node.DisplayRect(True);
  TCustomTreeView(Sender).canvas.TextRect(Rec, Rec.Left + 2, Rec.Top, Node.Text, Style);
end;

end.

