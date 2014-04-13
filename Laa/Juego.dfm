object JForm: TJForm
  Left = 1018
  Top = 240
  Cursor = 1
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = 'LAA'
  ClientHeight = 35
  ClientWidth = 152
  Color = clBlack
  Font.Charset = ANSI_CHARSET
  Font.Color = 10541248
  Font.Height = -15
  Font.Name = 'Times New Roman'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poDefault
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseDown = PantallaMouseDown
  OnMouseMove = FormMouseMove
  PixelsPerInch = 96
  TextHeight = 17
  object PBInterfaz: TPaintBox
    Left = 0
    Top = 352
    Width = 640
    Height = 128
    Cursor = 1
    OnMouseDown = PBInterfazMouseDown
    OnMouseMove = PBInterfazMouseMove
    OnPaint = PBInterfazPaint
  end
  object E_Identificador: TEdit
    Left = 300
    Top = 204
    Width = 200
    Height = 21
    AutoSize = False
    BorderStyle = bsNone
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = 7190204
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = []
    MaxLength = 16
    ParentFont = False
    TabOrder = 1
    Visible = False
    OnKeyPress = EditKeyPress
  end
  object EditMensaje: TEdit
    Left = 160
    Top = 354
    Width = 350
    Height = 13
    TabStop = False
    AutoSelect = False
    AutoSize = False
    BorderStyle = bsNone
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MaxLength = 79
    ParentFont = False
    TabOrder = 0
    Visible = False
    OnKeyPress = EditMensajeKeyPress
  end
  object E_contrasenna: TEdit
    Left = 316
    Top = 252
    Width = 116
    Height = 21
    AutoSize = False
    BorderStyle = bsNone
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = 7190204
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = []
    MaxLength = 13
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 3
    Visible = False
    OnKeyPress = EditKeyPress
  end
  object E_nombre: TEdit
    Left = 88
    Top = 150
    Width = 142
    Height = 21
    AutoSize = False
    BorderStyle = bsNone
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = []
    MaxLength = 16
    ParentFont = False
    TabOrder = 2
    Visible = False
    OnKeyPress = EditKeyPress
  end
  object E_confirmar: TEdit
    Left = 112
    Top = 314
    Width = 116
    Height = 21
    AutoSize = False
    BorderStyle = bsNone
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = 7190204
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = []
    MaxLength = 13
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 4
    Visible = False
    OnKeyPress = EditKeyPress
  end
end
