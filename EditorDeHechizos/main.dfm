�
 TFORM1 0J  TPF0TForm1Form1Left�Top~WidthWHeight�CaptionManual arcanoColor` Font.CharsetANSI_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameBook Antiqua
Font.Style Menu	MainMenu1OldCreateOrder	PositionpoScreenCenter
OnActivateFormActivateOnCreate
FormCreate	OnDestroyFormDestroyPixelsPerInch`
TextHeight TLabelLabel1LeftTopWidthNHeightCaptionConjuro:Font.CharsetANSI_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameBook Antiqua
Font.StylefsBold 
ParentFont  TBevelBevel1LeftTopWidth*Height*  	TPaintBoxPaintBoxLeftTopWidth(Height(OnPaintPaintBoxPaint  TLabelLabel6Left@TopdWidth*HeightHint&   Mínimo de sabiduría sobre 20 puntos.CaptionSAB:ParentShowHintShowHint	  TLabelLabel7Left� TopdWidth'HeightHint(   Mínimo de inteligencia sobre 20 puntos.CaptionINT:ParentShowHintShowHint	  TLabelLabel8Left�TopdWidthjHeightHint   Maná gastado por el conjuroCaption   Nivel maná:ParentShowHintShowHint	  TLabelLabel9LeftTop� Width� HeightCaptionCosto (mo, 1 a 650):  TLabelLabel5LeftTop� Width� HeightCaptionTipo de conjuro:  TLabelLabel10Left�Top� WidthUHeightCaption	Anim. Fx:Visible  TLabelLabel11LeftTop8Width� HeightHint(   Mínimo de inteligencia sobre 20 puntos.CaptionNombre conjuro:ParentShowHintShowHint	  TLabelLabel12LeftTopdWidthvHeightHint   Maná gastado por el conjuroCaptionNivel Avatar:ParentShowHintShowHint	  TLabelLabel13Left<Top� WidthEHeightCaptionEscuela:  	TComboBoxCmbConjurosLefthTopWidth� HeightStylecsDropDownListFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 
ItemHeight
ParentFontTabOrder OnChangeCmbConjurosChange  TEditEdtSABLeftlTop`Width%HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrderText0  TEditEdtINTLeft� Top`Width%HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrderText0  TEditEdtManaLeftTop`Width%HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrderText0  TEditEdtCostoLeft� Top� Width1HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrderText0  	TCheckBox
chkInicialLeftTop� Width� HeightHint-Al crear el personaje, si cumple los niveles.CaptionConjuro inicialParentShowHintShowHint	TabOrder  	TComboBoxcmbTipoLeft� Top� WidthQHeightStylecsDropDownListFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 
ItemHeight
ParentFontTabOrderOnChangecmbTipoChangeItems.Strings   Conjuro de combate con daño#Modificador de estatus de monstruos!Utiliza un objeto del inventario.   	TCheckBoxChkSoloJugadoresLeftTop Width� HeightCaption   Sólo afecta a jugadoresTabOrder  	TCheckBoxChkObjetivoLeftTopWidthUHeightCaption"Puede lanzar a un objetivo marcadoTabOrder
  	TCheckBoxChkAsimismoLeftTop� Width� HeightCaption   Puede lanzarse a sí mismoTabOrder	  TEditEdtAnimacionLeftTop� Width%HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrderText0Visible  	TGroupBoxgrpDannoLeftTopPWidth6HeightMCaption   Descripción de daño:TabOrder TLabelLabel2Left� Top"WidthvHeightCaption   Tipo de daño:  TLabelLabel3LeftTop"Width3HeightCaption   Daño:  TLabelLabel4LeftpTop"Width
HeightCaptiona  	TComboBoxCmbTipoDannoLeft4TopWidth� HeightStylecsDropDownListFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 
ItemHeight
ParentFontTabOrderItems.StringsCortantePunzanteContundenteVenenoFuegoHieloRayoMagia   TEditEdtDBaseLeftDTopWidth%HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrder Text0  TEditEdtDBonoLeft� TopWidth%HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrderText0   TEdit	EdtNombreLeft� Top4Width�HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrder  TEditEdtNivelLeft� Top`Width%HeightFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 	MaxLength
ParentFontTabOrderText0  	TComboBox
cmbEscuelaLeft�Top� Width� HeightStylecsDropDownListFont.CharsetANSI_CHARSET
Font.ColorclBlackFont.Height�	Font.NameBook Antiqua
Font.Style 
ItemHeight
ParentFontTabOrderItems.Strings   Abjuración   Adivinación   Alteración   ConjuraciónEncantamiento
   Evocación   IlusiónNecromancia   	TCheckBoxChkConjuroAgresivoLeftTop8Width� HeightCaptionConjuro AgresivoTabOrder  TButtonButton1Left� Top� WidthAHeightCaptionCalc.TabOrderOnClickButton1Click  	TMainMenu	MainMenu1Left Top4 	TMenuItemArchivo1CaptionArchivo 	TMenuItemAbrir1CaptionAbrirOnClickAbrir1Click  	TMenuItemN1Caption-  	TMenuItemGuardar1CaptionGuardarOnClickGuardar1Click  	TMenuItemN2Caption-  	TMenuItemSalir1CaptionSalirOnClickSalir1Click   	TMenuItemHerramientas1CaptionHerramientas 	TMenuItemLimpiarcadenas1CaptionLimpiar cadenasOnClickLimpiarcadenas1Click  	TMenuItemGuardarTextoHtml1CaptionLista de Conjuros -> HTMLOnClickGuardarTextoHtml1Click  	TMenuItem"GuardartextoHtmlconjurosdecombate1CaptionConjuros de combate -> HTMLOnClick'GuardartextoHtmlconjurosdecombate1Click     