unit USyntaxLine;

interface

uses Dialogs, SysUtils, IOUtils, Character, Types, Generics.Collections;

type
  TSyntaxLine = record
  private const
    EofCh = #1;
  private
    Text: string;
    Pos, NewPos: Integer;
    Loc: TPoint;
  public
    procedure Clear;
    procedure SetText(L: string);
    procedure LoadFile(FName: string);
    function JumpTo(APos: Integer): string;
    function IsEof: Boolean;
    function CurrentLine: string;
    procedure SyntaxError(Msg: string);
  end;
implementation

{ TSyntaxLine }

procedure TSyntaxLine.Clear;
begin
  Text := '';
  Pos := 1;
  Loc := Point(1, 1);
end;

function TSyntaxLine.CurrentLine: string;
var
  p1, p2: Integer;
begin
  for p1 := Pos downto 1 do
    if Text[p1] in [#10, #13] then
      Break;

  for p2 := Pos to High(Text) do
    if Text[p2] in [#10, #13] then
      Break;

  Result := Copy(Text, p1 + 1, p2 - p1 - 1);
end;

function TSyntaxLine.IsEof: Boolean;
begin
  Result := (Pos > High(Text)) or (Text[Pos] = EofCh);
end;

function TSyntaxLine.JumpTo(APos: Integer): string;
begin
  Result := '';
  while Pos < APos do
  begin
    Result := Result + Text[Pos];

    if Text[Pos] = #10 then
    begin
      Inc(Loc.X);
      Loc.Y := 1;
    end
    else
      Inc(Loc.Y);

    Inc(Pos);
  end;
end;

procedure TSyntaxLine.LoadFile(FName: string);
begin
  Clear;
  Text := TFile.ReadAllText(FName) + EofCh;
end;

procedure TSyntaxLine.SetText(L: string);
begin
  Clear;
  Text := L + EofCh;
end;

procedure TSyntaxLine.SyntaxError(Msg: string);
var
  Pt, Ln, Ch: string;
begin
  Ln := 'Line = ' + CurrentLine;
  Ch := 'Ch = ' + Text[Pos];
  Pt := 'Loc = (' + Loc.X.ToString + ', ' + Loc.Y.ToString + ')';

  MessageDlg(Msg + #10#10 + Ln + #10 + Ch + #10 + Pt, mtError, [mbOK], 0);
  Abort;
end;

end.
