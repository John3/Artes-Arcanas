�
 TFORM1 0�
  TPF0TForm1Form1Left�Top`Width'Height�Caption4   Recorta zonas no usadas o transparentes de imágenesColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style Menu	MainMenu1OldCreateOrder	PositionpoScreenCenterOnCreate
FormCreate	OnDestroyFormDestroyPixelsPerInch`
TextHeight TPanelPanel2Left TopWidthHeight�AlignalClient
BevelOuter	bvLoweredTabOrder 	TPaintBoxPantallaLeftTopWidthHeight�AlignalClientColorclBlackParentColorOnPaintPantallaPaint   TPanelPanel1Left Top WidthHeightAlignalTopTabOrder  TLabel
ColorTransLeftlTopWidth-HeightAutoSizeColor  ( ParentColorOnClickColorTransClick  TLabelLabel1Left,TopWidthMHeightHint"Recortar si la diferencia es menorCaptionUmbral (std=12):ParentShowHintShowHint	  TButtonButton2LeftTopWidthaHeightCaptionColor transparente:TabOrder OnClickButton2Click  	TCheckBoxCB_autoColorLeft� TopWidth}HeightHint&El color del pixel superior izquierdo.Caption   Color automático (0,0)Checked	ParentShowHintShowHint	State	cbCheckedTabOrder  TEditE_UmbralLeft|TopWidthHeightTabOrderText12  	TCheckBox	CB_escalaLeft�TopWidthiHeightHint9Asegura que el color negro pueda usarse como transparenteCaptionAjustar a [8..255]Checked	ParentShowHintShowHint	State	cbCheckedTabOrder   	TMainMenu	MainMenu1Left� TopX 	TMenuItemExit1CaptionArchivo 	TMenuItemProcesarimgenes1CaptionAbrir imagenOnClickAbrirArchivo  	TMenuItemN2Caption-  	TMenuItemGuardarimagenoptimizada1CaptionGuardar imagenOnClickGuardarimagenoptimizada1Click  	TMenuItemN1Caption-  	TMenuItemSalir1CaptionSalirOnClickSalir1Click   	TMenuItemHerramientas1CaptionHerramientas 	TMenuItemPintardemagenta1Caption"Optimizar (Corta partes no usadas)OnClickPintardemagenta1Click  	TMenuItemN3Caption-  	TMenuItemObtenermscaraAND1Caption   Obtener máscara ANDOnClickButton1Click  	TMenuItemObtenermscaraOR1Caption   Obtener máscara OROnClick	up1dClick  	TMenuItemN4Caption-  	TMenuItemEnfondonegro1CaptionEn fondo negroOnClickEnfondonegro1Click    TSaveDialog
SaveDialog
DefaultExtbmpFilter   Imágenes BMP|*.bmp
InitialDirc:\akar\anisOptionsofOverwritePromptofHideReadOnly TitleGuardar lista de framesLeft`TopX  TColorDialogColorDialogCtl3D	CustomColors.StringsColorA=280000ColorB=002800ColorC=000028ColorD=000000  Left� TopX  TOpenDialog
OpenDialog
DefaultExtbmpFilterImagen BMP|*.bmp
InitialDirc:\arkhos\anisOptions
ofReadOnlyofHideReadOnlyofPathMustExistofFileMustExist TitleAbrir BMP inicialLeft� TopX   