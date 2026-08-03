object frSettings: TfrSettings
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
  ClientHeight = 222
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object lcConnectionSettings: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 393
    Height = 222
    Align = alClient
    TabOrder = 0
    LayoutLookAndFeel = dmSkin.dxLayoutSkinLookAndFeel
    ExplicitHeight = 322
    object edPort: TcxSpinEdit
      Left = 85
      Top = 40
      Properties.MaxValue = 65535.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 1
      Value = 5432
      Width = 296
    end
    object edPassword: TcxTextEdit
      Left = 85
      Top = 124
      Properties.EchoMode = eemPassword
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 4
      Width = 296
    end
    object btnOk: TBitBtn
      Left = 176
      Top = 185
      Width = 104
      Height = 25
      Caption = 'OK'
      Default = True
      NumGlyphs = 2
      TabOrder = 5
      OnClick = btnOkClick
    end
    object btnCancel: TBitBtn
      Left = 287
      Top = 185
      Width = 94
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 6
    end
    object edLogin: TcxTextEdit
      Left = 85
      Top = 96
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 3
      Width = 296
    end
    object edDatabase: TcxTextEdit
      Left = 85
      Top = 68
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 2
      Text = 'postgres'
      Width = 296
    end
    object edServer: TcxTextEdit
      Left = 85
      Top = 12
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 0
      Text = 'localhost'
      Width = 296
    end
    object lcConnectionSettingsGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object liPort: TdxLayoutItem
      Parent = lcConnectionSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1055#1086#1088#1090
      Control = edPort
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liPassword: TdxLayoutItem
      Parent = lcConnectionSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1055#1072#1088#1086#1083#1100
      Control = edPassword
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object lgAction: TdxLayoutGroup
      Parent = lcConnectionSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avBottom
      CaptionOptions.Text = 'New Group'
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 5
    end
    object liOk: TdxLayoutItem
      Parent = lgAction
      AlignHorz = ahRight
      AlignVert = avClient
      CaptionOptions.Text = 'BitBtn1'
      CaptionOptions.Visible = False
      Control = btnOk
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 104
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liCancel: TdxLayoutItem
      Parent = lgAction
      AlignHorz = ahRight
      AlignVert = avClient
      CaptionOptions.Text = 'BitBtn1'
      CaptionOptions.Visible = False
      Control = btnCancel
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 94
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liLogin: TdxLayoutItem
      Parent = lcConnectionSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1051#1086#1075#1080#1085
      Control = edLogin
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liDatabase: TdxLayoutItem
      Parent = lcConnectionSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
      Control = edDatabase
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liServer: TdxLayoutItem
      Parent = lcConnectionSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1057#1077#1088#1074#1077#1088
      Control = edServer
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 0
    end
  end
end
