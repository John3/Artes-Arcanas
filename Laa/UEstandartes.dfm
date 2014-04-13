object FEstandartes: TFEstandartes
  Left = 262
  Top = 111
  BorderStyle = bsNone
  ClientHeight = 272
  ClientWidth = 480
  Color = clBlack
  Ctl3D = False
  Font.Charset = ANSI_CHARSET
  Font.Color = 12644596
  Font.Height = -15
  Font.Name = 'Times New Roman'
  Font.Style = [fsBold]
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 17
  object lbColor: TLabel
    Left = 284
    Top = 104
    Width = 17
    Height = 19
    AutoSize = False
    Caption = '0'
    Transparent = True
  end
  object cb_disenno: TComboBox
    Left = 72
    Top = 72
    Width = 273
    Height = 25
    Style = csDropDownList
    Color = clBlack
    ItemHeight = 17
    TabOrder = 1
    OnChange = cb_disennoChange
    Items.Strings = (
      'Tres bandas, Cruz y Rosa'
      'Calavera, Flor de lis, Araña y Caduceo'
      'Estrella, Águila, Rayo y Sol'
      'Unicornio, León y Coronas')
  end
  object sb_color: TScrollBar
    Left = 72
    Top = 104
    Width = 200
    Height = 18
    Max = 9
    PageSize = 0
    TabOrder = 2
    OnChange = sb_colorChange
  end
  object sb_rojo: TScrollBar
    Left = 72
    Top = 128
    Width = 121
    Height = 18
    Max = 3
    PageSize = 0
    TabOrder = 3
    OnChange = sb_rojoChange
  end
  object sb_verde: TScrollBar
    Left = 72
    Top = 152
    Width = 121
    Height = 18
    Max = 3
    PageSize = 0
    TabOrder = 4
    OnChange = sb_verdeChange
  end
  object sb_azul: TScrollBar
    Left = 72
    Top = 176
    Width = 121
    Height = 18
    Max = 3
    PageSize = 0
    TabOrder = 5
    OnChange = sb_azulChange
  end
  object EditCodigo: TEdit
    Left = 72
    Top = 202
    Width = 192
    Height = 23
    Color = clBlack
    TabOrder = 6
    OnChange = EditCodigoChange
  end
  object cb_Predef: TComboBox
    Left = 16
    Top = 36
    Width = 329
    Height = 25
    Style = csDropDownList
    Color = clBlack
    ItemHeight = 17
    TabOrder = 0
    OnChange = cb_PredefChange
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 115
    OnTimer = GTimer1Timer
    Left = 260
    Top = 4
  end
end
