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
    // Regular
    function IsUnread: Boolean;
    function SkipUnread: string;
    function IsId: Boolean;
    function SkipId: string;
    function IsInt: Boolean;
    function SkipInt: Integer;
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

function TSyntaxLine.IsId: Boolean;
var
  p, State: Integer;
begin
  SkipUnread;
  State := 0;

  for p := Pos to High(Text) do
    case State of
      0:
        if Text[p].IsLetter then
          State := 1
        else
          Break;

      1:
        if Text[p].IsLetterOrDigit then
          State := 1
        else
          Break;
    end;

  Result := State in [1];
  if Result then NewPos := p;
end;

function TSyntaxLine.IsInt: Boolean;
var
  p, State: Integer;
begin
  SkipUnread;
  State := 0;

  for p := Pos to High(Text) do
    case State of
      0:
        if Text[p] in ['+', '-'] then
          State := 1
        else if Text[p].IsDigit then
          State := 2
        else
          Break;

      1:
        if Text[p].IsDigit then
          State := 2
        else
          Break;
      2:
        if Text[p].IsDigit then
          State := 2
        else
          Break;
    end;

  Result := State in [2];
  if Result then NewPos := p;
end;

function TSyntaxLine.IsUnread: Boolean;
var
  P, State: Integer;
begin
  //  SkipUnread;
  State := 0;

  for P := Pos to High(Text) do
    case State of
      0:
        if Text[p] = '/' then
          State := 1
        else if Text[p].IsWhiteSpace then
          State := 5
        else
          Break;
      1:
        if Text[p] = '*' then
          State := 2
        else if Text[p] = '/' then
          State := 6
        else
          Break;
      2:
        if Text[p] = '*' then
          State := 3
        else
          State := 2;
      3:
        if Text[p] = '*' then
          State := 3
        else if Text[p] = '/' then
          State := 4
        else
          State := 2;
      4:
        Break;
      5:
        if Text[p].IsWhiteSpace then
          State := 5
        else
          Break;
      6:
        if Text[p] in [#10, #13] then
          State := 7
        else
          State := 6;
      7:
        Break;
    end;

  Result := State in [4, 5, 7];
  if Result then NewPos := P;
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

function TSyntaxLine.SkipId: string;
begin
  if IsId then
    Result := JumpTo(NewPos)
  else
    SyntaxError('Invalid id');
end;

function TSyntaxLine.SkipInt: Integer;
begin
  if IsInt then
    Result := JumpTo(NewPos).ToInteger
  else
    SyntaxError('Invalid integer');
end;

function TSyntaxLine.SkipUnread: string;
begin
  Result := '';
  while IsUnread do
    Result := Result + JumpTo(NewPos);
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
