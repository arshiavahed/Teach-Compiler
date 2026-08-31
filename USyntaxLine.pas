unit USyntaxLine;

interface

uses Dialogs, SysUtils, IOUtils, Character, Types, Generics.Collections;

type
  TStrList = array of string;

  TStackRec<T> = record
    Stk: TStack<T>;
    class operator Initialize(out Dest: TStackRec<T>);
    class operator Finalize(var Dest: TStackRec<T>);
    procedure Push(const Value: T); inline;
    function Pop: T; inline;
    function Peek: T; inline;
  end;

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
    function IsNum: Boolean;
    function SkipNum: Double;
    function IsStr: Boolean;
    function SkipStrQuot: string;
    function SkipStrVal: string;
    // Irregular
    function IsSep(Sep: string): Boolean;
    function SkipSep(Sep: string): string;
    function IsKey(Key: string): Boolean;
    function SkipKey(Key: string): string;
    // Advanced
    function IsNext(Any: string): Boolean;
    function Skip(Any: string): string;
    // Advanced
    function WhichIs(L: TStrList): Integer;
    function InList(L: TStrList): Boolean;
    // Parser
    function SkipSXY: string;
    function SkipSPNV: string;
    // Translator
    function SkipDepth: Integer;
    function SkipExpVal: Double;
  end;
implementation

uses Math;

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

function TSyntaxLine.InList(L: TStrList): Boolean;
begin
  Result := WhichIs(L) <> -1;
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

function TSyntaxLine.IsKey(Key: string): Boolean;
begin
  Result := IsId and (Copy(Text, Pos, NewPos - Pos).ToUpper = Key.ToUpper);
end;

function TSyntaxLine.IsNext(Any: string): Boolean;
var
  T: string;
begin
  SkipUnread;

  T := Any.ToUpper;
  if T = '#ID' then
    Result := IsId
  else if T = '#INT' then
    Result := IsInt
  else if T = '#NUM' then
    Result := IsNum
  else if T = '#STR' then
    Result := IsStr
  else if (Any.Length >= 2) and (Any[1] = '$') then
    Result := IsKey(Copy(Any, 2))
  else
    Result := IsSep(Any);
end;

function TSyntaxLine.IsNum: Boolean;
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
        else if Text[p] = '.' then
          State := 3
        else if Text[p].ToUpper = 'E' then
          State := 5
        else
          Break;
      3:
        if Text[p].IsDigit then
          State := 4
        else
          Break;
      4:
        if Text[p].IsDigit then
          State := 4
        else if Text[p].ToUpper = 'E' then
          State := 5
        else
          Break;
      5:
        if Text[p] in ['+', '-'] then
          State := 6
        else if Text[p].IsDigit then
          State := 7
        else
          Break;
      6:
        if Text[p].IsDigit then
          State := 7
        else
          Break;
      7:
        if Text[p].IsDigit then
          State := 7
        else
          Break;
    end;

  Result := State in [2, 4, 7];
  if Result then
    NewPos := p;
end;

function TSyntaxLine.IsSep(Sep: string): Boolean;
begin
  SkipUnread;

  Result := Copy(Text, Pos, Sep.Length).ToUpper = Sep.ToUpper;

  if Result then
    NewPos := Pos + Sep.Length;
end;

function TSyntaxLine.IsStr: Boolean;
var
  p, State: Integer;
begin
  SkipUnread;
  State := 0;

  for p := Pos to High(Text) do
    case State of
      0:
        if Text[p] = '''' then
          State := 1
        else if Text[p] = '#' then
          State := 3
        else
          Break;

      1:
        if Text[p] = '''' then
          State := 2
        else if Text[p] in [#10, #13] then
          Break
        else
          State := 1;

      2:
        if Text[p] = '''' then
          State := 1
        else if Text[p] = '#' then
          State := 3
        else
          Break;

      3:
        if Text[p].IsDigit then
          State := 4
        else
          Break;

      4:
        if Text[p] = '''' then
          State := 1
        else if Text[p] = '#' then
          State := 3
        else if Text[p].IsDigit then
          State := 4
        else
          Break;
    end;

  Result := State in [2, 4];
  if Result then
    NewPos := p;
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

function TSyntaxLine.Skip(Any: string): string;
var
  T: string;
begin
  T := Any.ToUpper;
  if T = '#ID' then
    Result := SkipId
  else if T = '#INT' then
    Result := SkipInt.ToString
  else if T = '#NUM' then
    Result := SkipNum.ToString
  else if T = '#STRQUOT' then
    Result := SkipStrQuot
  else if T = '#STRVAL' then
    Result := SkipStrVal
  else if (Any.Length >= 2) and (Any[1] = '$') then
    Result := SkipKey(Copy(Any, 2))
  else
    Result := SkipSep(Any);
end;

function TSyntaxLine.SkipDepth: Integer;

  procedure SkipS; forward;
  procedure SkipL; forward;
  procedure SkipL1; forward;

  type
  TSemanticStack = TStackRec<Integer>;
  TSemanticAction = (saZero, saInc, saMax);

  var
  SS: TSemanticStack;

  procedure DoAction(Act: TSemanticAction);
  begin
    case Act of
      saZero:
        SS.Push(0);
      saInc:
        SS.Push(SS.Pop + 1);
      saMax:
        SS.Push(Max(SS.Pop, SS.Pop));
    end;
  end;

  procedure SkipS;
  begin
    case WhichIs(['(', 'a']) of
      0:
        begin
          Skip('(');
          SkipL;
          Skip(')');
          DoAction(saInc);
        end;

      1:
        begin
          Skip('a');
          DoAction(saZero);
        end;
    else
      SyntaxError('"( , a" expected')
    end;
  end;

  procedure SkipL;
  begin
    SkipS;
    SkipL1;
  end;

  procedure SkipL1;
  begin
    if IsNext(',') then
    begin
      Skip(',');
      SkipS;
      DoAction(saMax);
      SkipL1;
    end
    else
      { null };
  end;

begin
  SkipS;
  Result := SS.Pop;
end;

function TSyntaxLine.SkipExpVal: Double;

procedure SkipA; forward;
procedure SkipA1; forward;
procedure SkipM; forward;
procedure SkipM1; forward;
procedure SkipP; forward;

type
  TSemanticStack = TStackRec<Double>;
  TSemanticAction = (saAdd, saSub, saMul, saDiv, saNeg, saNum);

var
  SS: TSemanticStack;

procedure DoAction(Act: TSemanticAction; TokenVal: Double = 0);
var
  L, R: Double;
begin
  case Act of
    saAdd:
      SS.Push(SS.Pop+ SS.Pop);
    saSub:
      begin
        R:= SS.Pop;
        L:= SS.Pop;
        SS.Push(L- R);
      end;
    saMul:
      SS.Push(SS.Pop* SS.Pop);
    saDiv:
      begin
        R:= SS.Pop;
        L:= SS.Pop;
        SS.Push(L/ R);
      end;
    saNeg:
      SS.Push(-SS.Pop);
    saNum:
      SS.Push(TokenVal);
  end;
end;

procedure SkipA;
begin
    SkipM;
    SkipA1;
end;

procedure SkipA1;
begin
    if IsSep('+') then
    begin
        Skip('+');
        SkipM;
        DoAction(saAdd);
        SkipA1;
    end
    else if IsSep('-') then
    begin
        Skip('-');
        SkipM;
        DoAction(saSub);
        SkipA1;
    end
    else
        { null };
end;

procedure SkipM;
begin
    SkipP;
    SkipM1;
end;

procedure SkipM1;
begin
    if IsSep('*') then
    begin
        Skip('*');
        SkipP;
        DoAction(saMul);
        SkipM1;
    end
    else if IsSep('/') then
    begin
        Skip('/');
        SkipP;
        DoAction(saDiv);
        SkipM1;
    end
    else
        { null };
end;

procedure SkipP;
begin
    case WhichIs(['-', '(', '#num']) of
        0:
            begin
                Skip('-');
                SkipP;
                DoAction(saNeg);
            end;
        1:
            begin
                Skip('(');
                SkipA;
                Skip(')');
            end;
        2:
            DoAction(saNum, SkipNum);
    else
        SyntaxError('" - , ( , num expected"');
    end;
end;

begin
  SkipA;
  Result:= SS.Pop;
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

function TSyntaxLine.SkipKey(Key: string): string;
begin
  if IsKey(Key) then
    Result := JumpTo(NewPos)
  else
    SyntaxError('"' + Key + '" Expected');
end;

function TSyntaxLine.SkipNum: Double;
begin
  if IsNum then
    Result := JumpTo(NewPos).ToDouble
  else
    SyntaxError('Invalid number');
end;

function TSyntaxLine.SkipSep(Sep: string): string;
begin
  if IsSep(Sep) then
    Result := JumpTo(NewPos)
  else
    SyntaxError('"' + Sep + '" Expected');
end;

function TSyntaxLine.SkipSPNV: string;

  procedure SkipS; forward;
  procedure SkipP; forward;
  procedure SkipN; forward;
  procedure SkipV; forward;

  procedure SkipS;
  begin
    case WhichIs(['d', 'e', 'b', 'c']) of
      0, 1:
        begin
          SkipP;
          Result := Result + Skip('a');
          SkipN;
        end;

      2:
        begin
          SkipV;
          SkipP;
        end;

      3:
        Result := Result + Skip('c');

    else
      SyntaxError('"d, e, b, c" Expected');
    end;
  end;

  procedure SkipP;
  begin
    case WhichIs(['d', 'e']) of
      0:
        begin
          Result := Result + Skip('d');
          SkipN;
          SkipP;
        end;

      1:
        Result := Result + Skip('e');

    else
      SyntaxError('"d, e" Expected');
    end;
  end;

  procedure SkipN;
  begin
    case WhichIs(['b', 'd', 'e', EofCh]) of
      0:
        begin
          SkipV;
          Result := Result + Skip('a');
        end;

      1..3:
        { null };

    else
      SyntaxError('"b, d, e, Eof" Expected');
    end;
  end;

  procedure SkipV;
  begin
    Result := Result + Skip('b');
  end;

begin
  Result := '';
  SkipS;
end;

function TSyntaxLine.SkipStrQuot: string;
begin
  if IsStr then
    Result := JumpTo(NewPos)
  else
    SyntaxError('Invalid string');
end;

function TSyntaxLine.SkipStrVal: string;
begin
  { TODO : For Future }
end;

function TSyntaxLine.SkipSXY: string;

  procedure SkipS; forward;
  procedure SkipX; forward;
  procedure SkipY; forward;

  procedure SkipS;
  begin
    SkipX;
    Result := Result + Skip('d');
    SkipY;
  end;

  procedure SkipX;
  begin
    if IsNext('a') then
    begin
      Result:= Result + Skip('a');
      SkipX;
    end
    else
      { null };
  end;

  procedure SkipY;
  begin
    if IsNext('b') then
    begin
      Result:= Result + Skip('b');
      SkipY;
      SkipS;
    end
    else
      { null };
  end;

  begin
    Result := '';
    SkipS;
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

function TSyntaxLine.WhichIs(L: TStrList): Integer;
var
  i: Integer;
begin
  SkipUnread;

  Result := -1;
  for i := 0 to High(L) do
    if IsNext(L[i]) then
      Exit(i);
end;

{ TStackRec<T> }

class operator TStackRec<T>.Finalize(var Dest: TStackRec<T>);
begin
  Dest.Stk.Free;
end;

class operator TStackRec<T>.Initialize(out Dest: TStackRec<T>);
begin
  Dest.Stk := TStack<T>.Create;
end;

function TStackRec<T>.Peek: T;
begin
  Result := Stk.Peek;
end;

function TStackRec<T>.Pop: T;
begin
  Result := Stk.Pop;
end;

procedure TStackRec<T>.Push(const Value: T);
begin
  Stk.Push(Value);
end;

end.
