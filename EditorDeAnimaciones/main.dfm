�
 TFORM1 06  TPF0TForm1Form1Left� TopJWidth�Height�BorderIconsbiSystemMenu
biMinimize CaptionAlineador de animacionesColor��� Font.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style Menu	MainMenu1OldCreateOrder	PositionpoScreenCenterOnCloseQueryFormCloseQueryOnCreate
FormCreate	OnDestroyFormDestroyPixelsPerInch`
TextHeight TBevelBevel4LeftTop|Width�Height  TBevelBevel1LeftTop Width� HeightU  TBevelBevel3Left� Top WidthHeight  TBevelBevel2Left� Top<WidthHeight9  TLabelLabelMensajeLeftTop�Width�HeightAutoSizeFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style 
ParentFont  TLabelLabel2LeftLTopDWidthHeightHint
IncrementoCaptionInc:ParentShowHintShowHint	  TLabelLabel3LeftTopDWidthHeightHintComienza en...CaptionBase:  TLabelLabel4Left� TopDWidthHeightHintNro de animacionesCaptionNro:ParentShowHintShowHint	  TLabel
ColorTransLeftTop$WidthHeightAutoSizeColor  ( ParentColorOnClickColorTransClick  TImagePantallaLeft� Top@Width Height OnMouseDownPantallaMouseDown  TLabelLabel1Left� TopWidth� HeightCaption    La animación está dirigida al:  TLabelLabel5Left�Top%Width$HeightHint)   Máxima diferencia de color (256 niveles)CaptionUmbral:ParentShowHintShowHint	  TEditEditIncLeft`Top@Width%HeightTabOrderText10  TEditEditBaseLeft(Top@Width!HeightTabOrderText0  TButtonButton1Left� Top$WidthEHeightCaptionTransparente:TabOrderOnClickButton1Click  TMemoMemo1LeftTopTWidth� Height� 
ScrollBars
ssVerticalTabOrder OnChangeMemo1Change  TButtonButton2LeftTop$Width9HeightCaptionAbrir listaTabOrderOnClickButton2Click  TButtonButton3LeftTop\Width� HeightCaptionGenerar listaTabOrderOnClickButton3Click  TButtonButton4LeftHTop$WidthIHeightCaptionGuardar listaTabOrderOnClickButton4Click  TButtonButton5Left� Top$Width-HeightCaptionLimpiarTabOrderOnClickButton5Click  TEditEditNroLeft� Top@Width!HeightTabOrderText8  
TScrollBar	ScrollBarLeftTopZWidth� HeightMax PageSize TabOrder	OnChangeScrollBarChange  TButtonButton6Left� TopZWidth1HeightCaptionAnimarTabOrder
OnClickButton6Click  	TComboBoxCB_dirLeftXTopWidth� HeightStylecsDropDownList
ItemHeightTabOrderOnChangeCB_dirChangeItems.StringsNorteSurOesteNorOesteSurOeste   	TCheckBoxCB_autoColorLeft@Top$WidthMHeightHint&El color del pixel superior izquierdo.Caption   AutomáticoChecked	ParentShowHintShowHint	State	cbCheckedTabOrder  TEditEdit1Left�Top"WidthHeightTabOrderText10OnChangeEdit1Change  TButtonButton7LeftTopWidthQHeightCaption   Abrir ImágenesTabOrderOnClickProcesar1click  TButtonButton10Left`TopWidtheHeightCaption   Modificar AnimaciónTabOrderOnClickModificaranimacin1Click  TButtonButton11LeftTop<Width� HeightCaption"Convertir comas en saltos de lineaTabOrderOnClickButton11Click  	TComboBoxcb_animacionLeft� TopBWidthUHeightStylecsDropDownList
ItemHeightTabOrderOnChangecb_animacionChangeItems.Strings	Ver Todos
MovimientoAtaques   	TComboBoxcb_estiloAtaqueLeft(TopBWidthqHeightStylecsDropDownList
ItemHeightTabOrderItems.StringsNormal (5,6,7,7)Continuo (5,6,7,6) Normal2 (7,5,6,6)Inverso (6,5,7,7)   	TComboBoxCB_NroAtaqueLeft�TopBWidth5HeightStylecsDropDownList
ItemHeightTabOrderItems.StringsA1A2A3A4A5   TOpenDialog
OpenDialog
DefaultExtbmpFilterImagen BMP|*.bmp
InitialDir
.\imagenesOptions
ofReadOnlyofHideReadOnlyofPathMustExistofFileMustExist TitleAbrir BMP inicialLeft� Topl  	TMainMenu	MainMenu1Left� Topl 	TMenuItemExit1CaptionArchivo 	TMenuItemProcesarimgenes1Caption   Abrir lista de imágenesOnClickProcesar1click  	TMenuItemModificaranimacin1Caption   Modificar animaciónOnClickModificaranimacin1Click  	TMenuItemN1Caption-  	TMenuItemSalir1CaptionSalirOnClickSalir1Click   	TMenuItemResultados1Caption
Resultados 	TMenuItemCrearanimacincondirecciones1Caption,   Alinear animación con las cinco direccionesOnClick!Crearanimacincondirecciones1Click  	TMenuItemCrearanimacinsimple1Caption*   Alinear animación con una sola direcciónOnClickCrearanimacinsimple1Click  	TMenuItemAlinearparagrficoesttico1Caption   Alinear para gráfico estáticoOnClickAlinearparagrficoesttico1Click  	TMenuItemN2Caption-  	TMenuItemFondoMagenta1Caption6Fondo Magenta, reescala colores evitando el rgb(0,0,0)
GroupIndex	RadioItem	OnClickFondo1Click  	TMenuItemFondoNegro1Caption$Fondo Negro, no modifica los coloresChecked	
GroupIndex	RadioItem	OnClickFondo1Click  	TMenuItemN3Caption-
GroupIndex  	TMenuItemGuardararchivoBMP1CaptionGuardar archivo BMPChecked	
GroupIndexOnClickGuardararchivoBMP1Click   	TMenuItemPistas1CaptionPistas 	TMenuItemAlineaciondemonstruos1CaptionAlineacion de monstruosOnClickAlineaciondemonstruos1Click  	TMenuItemNroFrameParado1CaptionNro Frame ParadoOnClickNroFrameParado1Click    TOpenDialogOpenDialogL
DefaultExtlanFilterLista de claves|*.lan
InitialDir
.\imagenesTitleAbrir lista de framesLeftTopp  TSaveDialogSaveDialogL
DefaultExtlanFilterLista de claves|*.lan
InitialDir.\animacionesOptionsofOverwritePromptofHideReadOnly TitleGuardar lista de framesLeft<Topl  TTimerTimerEnabledIntervaloOnTimer
TimerTimerLeft� Topl  TColorDialogColorDialogCtl3D	CustomColors.StringsColorA=280000ColorB=002800ColorC=000028ColorD=000000  LeftTopl  TOpenDialogOpenDialogA
DefaultExtbinFilter   Animación|*.cr9
InitialDir.\animacionesOptionsofHideReadOnlyofFileMustExist TitleAbrir animacionLeft@Topl   