object FClassic: TFClassic
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Classic Syntaxes'
  ClientHeight = 612
  ClientWidth = 988
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnActivate = FormActivate
  TextHeight = 28
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 988
    Height = 40
    Align = alTop
    TabOrder = 0
    object BtnSave: TButton
      Left = 1
      Top = 1
      Width = 109
      Height = 38
      Align = alLeft
      Caption = 'Save'
      TabOrder = 0
      OnClick = BtnSaveClick
    end
    object BtnRun: TButton
      Left = 255
      Top = 1
      Width = 109
      Height = 38
      Align = alLeft
      Caption = 'Run'
      TabOrder = 1
      OnClick = BtnRunClick
    end
    object ComboInp: TComboBox
      Left = 110
      Top = 1
      Width = 145
      Height = 36
      Align = alLeft
      Style = csDropDownList
      DropDownCount = 0
      TabOrder = 2
      OnChange = ComboInpChange
    end
  end
  object PanelLeft: TPanel
    Left = 0
    Top = 40
    Width = 110
    Height = 572
    Align = alLeft
    TabOrder = 1
    object BtnCode: TButton
      Left = 1
      Top = 361
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Code'
      TabOrder = 0
      ExplicitLeft = 64
      ExplicitTop = 272
      ExplicitWidth = 75
    end
    object BtnTranslator: TButton
      Left = 1
      Top = 321
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Translator'
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnParser: TButton
      Left = 1
      Top = 281
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Parser'
      TabOrder = 2
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnDecision: TButton
      Left = 1
      Top = 241
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Decision'
      TabOrder = 3
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnIrregular: TButton
      Left = 1
      Top = 201
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Irregular'
      TabOrder = 4
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnStr: TButton
      Left = 1
      Top = 161
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Str'
      TabOrder = 5
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnNum: TButton
      Left = 1
      Top = 121
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Num'
      TabOrder = 6
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnInt: TButton
      Left = 1
      Top = 81
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Int'
      TabOrder = 7
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnId: TButton
      Left = 1
      Top = 41
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Id'
      TabOrder = 8
      OnClick = BtnIdClick
      ExplicitLeft = 2
      ExplicitTop = 9
    end
    object BtnUnread: TButton
      Left = 1
      Top = 1
      Width = 108
      Height = 40
      Align = alTop
      Caption = 'Unread'
      TabOrder = 9
      OnClick = BtnUnreadClick
      ExplicitLeft = 2
      ExplicitTop = 9
    end
  end
  object PanelClient: TPanel
    Left = 110
    Top = 40
    Width = 878
    Height = 572
    Align = alClient
    TabOrder = 2
    object MemoInp: TMemo
      Left = 1
      Top = 1
      Width = 876
      Height = 286
      Align = alTop
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -23
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      Lines.Strings = (
        'MemoInp')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
    end
    object MemoOut: TMemo
      Left = 1
      Top = 287
      Width = 876
      Height = 284
      Align = alClient
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -23
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      Lines.Strings = (
        'MemoOut')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 1
      WordWrap = False
    end
  end
end
