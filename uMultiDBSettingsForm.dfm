object frmMultiDBSettings: TfrmMultiDBSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
  ClientHeight = 306
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object lcSettings: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 420
    Height = 306
    Align = alClient
    TabOrder = 0
    object cbDBType: TcxComboBox
      Left = 85
      Top = 12
      Properties.Items.Strings = (
        'PostgreSQL'
        'MS SQL'
        'Oracle')
      Properties.OnChange = cbDBTypePropertiesChange
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      Style.ButtonStyle = bts3D
      Style.PopupBorderStyle = epbsFrame3D
      TabOrder = 0
      Width = 323
    end
    object edHost: TcxTextEdit
      Left = 85
      Top = 42
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 1
      Width = 323
    end
    object edPort: TcxSpinEdit
      Left = 85
      Top = 72
      Properties.MaxValue = 65535.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      Style.ButtonStyle = bts3D
      TabOrder = 2
      Value = 5432
      Width = 323
    end
    object edDatabase: TcxTextEdit
      Left = 85
      Top = 102
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 3
      Text = 'postgres'
      Width = 323
    end
    object edUsername: TcxTextEdit
      Left = 85
      Top = 132
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 4
      Width = 323
    end
    object edPassword: TcxTextEdit
      Left = 85
      Top = 162
      Properties.EchoMode = eemPassword
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebs3D
      Style.HotTrack = False
      Style.TransparentBorder = False
      TabOrder = 5
      Width = 323
    end
    object btnOk: TBitBtn
      Left = 102
      Top = 269
      Width = 104
      Height = 25
      Caption = 'OK'
      Default = True
      NumGlyphs = 2
      TabOrder = 6
      OnClick = btnOkClick
    end
    object btnCancel: TBitBtn
      Left = 213
      Top = 269
      Width = 94
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 7
    end
    object btnTest: TBitBtn
      Left = 314
      Top = 269
      Width = 94
      Height = 25
      Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100
      NumGlyphs = 2
      TabOrder = 8
      OnClick = btnTestClick
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
      ControlOptions.OriginalHeight = 23
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
      ControlOptions.OriginalHeight = 23
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
      ControlOptions.OriginalHeight = 23
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
      ControlOptions.OriginalHeight = 23
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
      ControlOptions.OriginalHeight = 23
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
      ControlOptions.OriginalHeight = 23
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
      Index = 6
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
  end
end
