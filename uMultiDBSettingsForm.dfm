object frmMultiDBSettings: TfrmMultiDBSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
  ClientHeight = 343
  ClientWidth = 421
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object lcSettings: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 421
    Height = 343
    Align = alClient
    TabOrder = 0
    LayoutLookAndFeel = dmSkin.dxLayoutSkinLookAndFeel
    object cbDBType: TcxComboBox
      Left = 143
      Top = 12
      Properties.Items.Strings = (
        'PostgreSQL'
        'MS SQL'
        'Oracle')
      Properties.OnChange = cbDBTypePropertiesChange
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 0
      Width = 266
    end
    object edHost: TcxTextEdit
      Left = 143
      Top = 40
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 1
      Width = 266
    end
    object edPort: TcxSpinEdit
      Left = 143
      Top = 68
      Properties.MaxValue = 65535.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 2
      Value = 5432
      Width = 266
    end
    object edDatabase: TcxTextEdit
      Left = 143
      Top = 96
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 3
      Text = 'postgres'
      Width = 266
    end
    object edUsername: TcxTextEdit
      Left = 143
      Top = 124
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 4
      Width = 266
    end
    object edPassword: TcxTextEdit
      Left = 143
      Top = 152
      Properties.EchoMode = eemPassword
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 5
      Width = 266
    end
    object btnOk: TBitBtn
      Left = 103
      Top = 306
      Width = 104
      Height = 25
      Caption = 'OK'
      Default = True
      NumGlyphs = 2
      TabOrder = 8
      OnClick = btnOkClick
    end
    object btnCancel: TBitBtn
      Left = 214
      Top = 306
      Width = 94
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 9
    end
    object btnTest: TBitBtn
      Left = 315
      Top = 306
      Width = 94
      Height = 25
      Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100
      NumGlyphs = 2
      TabOrder = 10
      OnClick = btnTestClick
    end
    object edMaxPoolItems: TcxSpinEdit
      Left = 143
      Top = 180
      Properties.MaxValue = 100.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 6
      Value = 6
      Width = 266
    end
    object edPoolTimeout: TcxSpinEdit
      Left = 143
      Top = 218
      Properties.MaxValue = 5000.000000000000000000
      Properties.MinValue = 250.000000000000000000
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 7
      Value = 250
      Width = 266
    end
    object lcSettingsGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object liDBType: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1058#1080#1087' '#1041#1044
      Control = cbDBType
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liHost: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1057#1077#1088#1074#1077#1088
      Control = edHost
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liPort: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1055#1086#1088#1090
      Control = edPort
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liDatabase: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
      Control = edDatabase
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liUsername: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1051#1086#1075#1080#1085
      Control = edUsername
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object liPassword: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = #1055#1072#1088#1086#1083#1100
      Control = edPassword
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 5
    end
    object lgActions: TdxLayoutGroup
      Parent = lcSettingsGroup_Root
      AlignHorz = ahClient
      AlignVert = avBottom
      CaptionOptions.Text = 'New Group'
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 8
    end
    object liOk: TdxLayoutItem
      Parent = lgActions
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
      Parent = lgActions
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
    object liTest: TdxLayoutItem
      Parent = lgActions
      AlignHorz = ahRight
      AlignVert = avClient
      CaptionOptions.Text = 'BitBtn1'
      CaptionOptions.Visible = False
      Control = btnTest
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 94
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liMaxPoolItems: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      CaptionOptions.Text = #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1082#1086#1083'-'#1074#1086#13#10#1089#1086#1077#1076#1080#1085#1077#1085#1080#1081
      CaptionOptions.WordWrap = True
      Control = edMaxPoolItems
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 6
    end
    object liPoolTimeout: TdxLayoutItem
      Parent = lcSettingsGroup_Root
      CaptionOptions.Text = #1058#1072#1081#1084#1072#1091#1090' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
      Control = edPoolTimeout
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 7
    end
  end
end
