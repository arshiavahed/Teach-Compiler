unit UClassic;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFClassic = class(TForm)
    PanelTop: TPanel;
    PanelLeft: TPanel;
    PanelClient: TPanel;
    MemoInp: TMemo;
    MemoOut: TMemo;
    BtnSave: TButton;
    BtnRun: TButton;
    ComboInp: TComboBox;
    BtnCode: TButton;
    BtnTranslator: TButton;
    BtnParser: TButton;
    BtnDecision: TButton;
    BtnIrregular: TButton;
    BtnStr: TButton;
    BtnNum: TButton;
    BtnInt: TButton;
    BtnId: TButton;
    BtnUnread: TButton;
    procedure FormActivate(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure ComboInpChange(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
    procedure BtnUnreadClick(Sender: TObject);
    procedure BtnIdClick(Sender: TObject);
    procedure BtnIntClick(Sender: TObject);
    procedure BtnNumClick(Sender: TObject);
    procedure BtnStrClick(Sender: TObject);
    procedure BtnIrregularClick(Sender: TObject);
    procedure BtnDecisionClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FClassic: TFClassic;

implementation

{$R *.dfm}

uses
  USyntaxLine, IOUtils;

var
  Inp: TSyntaxLine;

procedure TFClassic.BtnDecisionClick(Sender: TObject);
var
  S: String;
begin
  case Inp.WhichIs(['$if', '$while', '$for', '#id']) of

    0:
      begin
        S := Inp.SkipKey('if');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep('!=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipKey('then');
      end;

    1:
      begin
        S := Inp.SkipKey('while');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep('=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipKey('do');
      end;

    2:
      begin
        S := Inp.SkipKey('for');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep(':=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipKey('to');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipKey('do');
      end;

    3:
      begin
        S := Inp.SkipId;
        S := S + ' ' + Inp.SkipSep(':=');
        S := S + ' ' + Inp.SkipId;
        S := S + ' ' + Inp.SkipSep('+');
        S := S + ' ' + Inp.SkipId;
      end;

  else
    Inp.SyntaxError('if , while , for , id Expected');
  end;

  MemoOut.Lines.Text := S;
end;

procedure TFClassic.BtnIdClick(Sender: TObject);
begin
  MemoOut.Lines.Text:= Inp.SkipId;
end;

procedure TFClassic.BtnIntClick(Sender: TObject);
begin
  MemoOut.Lines.Text:= Inp.SkipInt.ToString;
end;

procedure TFClassic.BtnIrregularClick(Sender: TObject);
var
  S: String;
begin
  // for #id := #int to #int do
  S := Inp.Skip('$for');
  S := S + ' ' + Inp.Skip('#id');
  S := S + ' ' + Inp.Skip(':= ');
  S := S + ' ' + Inp.Skip('#int');
  S := S + ' ' + Inp.Skip('$to');
  S := S + ' ' + Inp.Skip('#int');
  S := S + ' ' + Inp.Skip('$do');
  MemoOut.Lines.Text := S;
end;

procedure TFClassic.BtnNumClick(Sender: TObject);
begin
  MemoOut.Lines.Text:= Inp.SkipNum.ToString;
end;

procedure TFClassic.BtnRunClick(Sender: TObject);
var
  F: String;
begin
  F := UpperCase(ComboInp.Text);
  if F = 'UNREAD.TXT' then
    BtnUnread.Click
  else if F = 'INT.TXT' then
    BtnInt.Click
  else if F = 'ID.TXT' then
    BtnId.Click
  else if F = 'NUM.TXT' then
    BtnNum.Click
  else if F = 'STR.TXT' then
    BtnStr.Click
  else if F = 'IRREGULAR.TXT' then
    BtnIrregular.Click
  else if F = 'DECISION.TXT' then
    BtnDecision.Click
  else if F = 'PARSER.TXT' then
    BtnParser.Click
  else if F = 'TRANSLATOR.TXT' then
    BtnTranslator.Click
  else if F = 'CODE.TXT' then
    BtnCode.Click;
end;

procedure TFClassic.BtnSaveClick(Sender: TObject);
begin
  MemoInp.Lines.SaveToFile(ComboInp.Text);
  Inp.LoadFile(ComboInp.Text);
end;

procedure TFClassic.BtnStrClick(Sender: TObject);
begin
  MemoOut.Lines.Text:= Inp.SkipStrQuot;
end;

procedure TFClassic.BtnUnreadClick(Sender: TObject);
begin
  MemoOut.Lines.Text:= Inp.SkipUnread;
end;

procedure TFClassic.ComboInpChange(Sender: TObject);
begin
  MemoInp.Lines.LoadFromFile(ComboInp.Text);
  Inp.LoadFile(ComboInp.Text);
end;

procedure TFClassic.FormActivate(Sender: TObject);
var
  i: Integer;
  F: TArray<string>;
begin
  F := TDirectory.GetFiles(TDirectory.GetCurrentDirectory, '*.txt');
  for i := 0 to High(F) do
    F[i] := TPath.GetFileName(F[i]);

  ComboInp.Items.Clear;
  ComboInp.Items.AddStrings(F);
  ComboInp.ItemIndex := 0;

  MemoInp.Lines.LoadFromFile(ComboInp.Text);
  Inp.LoadFile(ComboInp.Text);
end;

end.
