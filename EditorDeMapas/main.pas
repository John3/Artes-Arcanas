(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit main;
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Menus,
  Graficos,Directdraw, ComCtrls,objetos,Demonios,Tablero;

const
    maximo=63;
    maximoTiles=255;
    maxItems=8;
    Tamanno=255;

    cd_Nulo=$FFFF;
    cd_Nulo_byte=$FF;

    //flags de tiles
    ft_Nodibujar=$20;
    ft_Ocupado=$80;
    ft_Tapado=$40;//Por ejemplo: un techo.

    INICIO_RISCOS=200;
    INICIO_MODULOS=INICIO_EDIFICIOS+100;
    INICIO_SPRITES=$300;
    TITULO_APLICACION='Editor de Mapas';

  MC_DescripcionComercio:array[0..MAX_TIPOS_COMERCIO] of string[6]=(
    '','Simple','Enanos','Elfos','Orcos','Enanos',
    'Elfos','','','','','',
    '','','','','','','','Drow','','','','','','','','','','','','');

type

  Tlinea=array[0..32000] of byte;

  TmapaCompreso=array[0..maximo,0..maximo] of byte;
  TmapaTiles=array[0..maximoTiles,0..maximoTiles] of byte;

  TMapaDescriptivo=array[0..maximo,0..maximo] of byte;

  Tdescripcion=record // Uso temporal
    posx_t,posy_t:smallint;
    terreno:byte;
    TerrenoSeleccionado:byte;
  end;

  TFCmundo = class(TForm)
    PB_Mmapa: TPaintBox;
    c_GTerreno: TCheckBox;
    LabelMensaje: TLabel;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    N1: TMenuItem;
    Salir1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ScrollBarY: TScrollBar;
    ScrollBarX: TScrollBar;
    C_AlphaT: TCheckBox;
    Bevel1: TBevel;
    pageControl1: TPageControl;
    TS_terreno: TTabSheet;
    TS_graficos: TTabSheet;
    TS_NPC: TTabSheet;
    CB_terreno: TComboBox;
    CB_graficos: TComboBox;
    Label1: TLabel;
    RB_codigo1_G: TRadioButton;
    RB_auto_G: TRadioButton;
    RB_borrar_G: TRadioButton;
    RB_codigo2_G: TRadioButton;
    Cb_edificios: TComboBox;
    c_transparente: TCheckBox;
    c_marcas: TCheckBox;
    c_edificiosMM: TCheckBox;
    RB_riscos: TRadioButton;
    CB_riscos: TComboBox;
    cb_modulos: TComboBox;
    RB_muros: TRadioButton;
    Label2: TLabel;
    E_nombre: TEdit;
    TS_General: TTabSheet;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    E_norte: TEdit;
    e_sur: TEdit;
    e_oeste: TEdit;
    e_este: TEdit;
    Label8: TLabel;
    e_texto_npc: TEdit;
    cb_tipo_npc: TComboBox;
    Label9: TLabel;
    e_dato1_npc: TEdit;
    TS_Sensor: TTabSheet;
    cb_tipo_sensor: TComboBox;
    Label10: TLabel;
    e_llave2_sensor: TEdit;
    Label_ds1: TLabel;
    e_dato1_sensor: TEdit;
    e_dato2_sensor: TEdit;
    Label_ds2: TLabel;
    Label_ds3: TLabel;
    e_dato3_sensor: TEdit;
    e_dato4_sensor: TEdit;
    TS_Nido: TTabSheet;
    cb_tipo_nido: TComboBox;
    e_dato1_nido: TEdit;
    Label30c: TLabel;
    Label15: TLabel;
    e_texto_sensor: TEdit;
    c_borrar_npc: TCheckBox;
    c_borrar_sensor: TCheckBox;
    c_borrar_nido: TCheckBox;
    cb_me_npc: TCheckBox;
    cb_me_sensor: TCheckBox;
    cb_me_nido: TCheckBox;
    TS_Comerciante: TTabSheet;
    Label17: TLabel;
    CbBorrarComerciante: TCheckBox;
    Cb_ME_Comerciante: TCheckBox;
    CmbTipoComerciante: TComboBox;
    EdtTextoComerciante: TEdit;
    Label18: TLabel;
    c_Techos: TCheckBox;
    cb_me_Graficos: TCheckBox;
    RB_sprites: TRadioButton;
    cb_sprites: TComboBox;
    cbTipoClimaMapa: TComboBox;
    Label16: TLabel;
    Label19: TLabel;
    Lb_PosicionGuardada: TLabel;
    Btn_AsignarPos: TButton;
    cmbAniComerciante: TComboBox;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    cbTipoMapa: TComboBox;
    Button1: TButton;
    cbFx: TComboBox;
    cb_reflejo: TCheckBox;
    cb_testE: TCheckBox;
    Button2: TButton;
    cbDefTerMiniMapa: TCheckBox;
    Button3: TButton;
    CmbObjetoLlave: TComboBox;
    Label23: TLabel;
    E_RetornoX: TEdit;
    E_RetornoY: TEdit;
    Btn_AsignarPosRET: TButton;
    Label24: TLabel;
    c_normales: TCheckBox;
    BtnObjeto2: TButton;
    c_sprites: TCheckBox;
    Label25: TLabel;
    CB_levitacion: TCheckBox;
    cb_transparente: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    cb_sensible_flags: TCheckBox;
    cb_inverso: TCheckBox;
    cb_flag_grafico: TComboBox;
    TS_Banderas: TTabSheet;
    cb_flag: TComboBox;
    Label26: TLabel;
    Label27: TLabel;
    cb_efS: TComboBox;
    c_flag_activo: TCheckBox;
    Bevel3: TBevel;
    E_flag_d1: TEdit;
    Label28: TLabel;
    E_flag_d2: TEdit;
    Label29: TLabel;
    Button6: TButton;
    c_limpiar_flag: TCheckBox;
    b_se1: TButton;
    b_se2: TButton;
    b_se3: TButton;
    b_se4: TButton;
    cb_ilusion: TCheckBox;
    Label_ds4: TLabel;
    c_consumirLlave: TCheckBox;
    c_solofantasma: TCheckBox;
    c_soloclan: TCheckBox;
    c_soloaprendiz: TCheckBox;
    E_RetornoM: TEdit;
    c_repeler: TCheckBox;
    c_ParteDelCastillo: TCheckBox;
    cb_efC: TComboBox;
    Label11: TLabel;
    cb_borrar: TCheckBox;
    cb_AbismoVacio: TCheckBox;
    BtnAyudaLlave: TButton;
    N2: TMenuItem;
    GuardarMiniMapa1: TMenuItem;
    MD51: TMenuItem;
    Button7: TButton;
    Button8: TButton;
    NuevoMapa1: TMenuItem;
    AbrirMapa1: TMenuItem;
    GuardarMapa1: TMenuItem;
    procedure Salir1Click(Sender: TObject);
    procedure AbrirMapa1Click(Sender: TObject);
    procedure GuardarMapa1Click(Sender: TObject);
    procedure NuevoMapa1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PB_MmapaPaint(Sender: TObject);
    procedure PB_MmapaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PB_MmapaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PB_MmapaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScrollBarYChange(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RB_terrenoClick(Sender: TObject);
    procedure RB_ObjetosClick(Sender: TObject);
    procedure c_GTerrenoClick(Sender: TObject);
    procedure pageControl1Change(Sender: TObject);
    procedure RB_codigo1_GClick(Sender: TObject);
    procedure RB_codigo2_GClick(Sender: TObject);
    procedure CB_graficosClick(Sender: TObject);
    procedure Cb_edificiosClick(Sender: TObject);
    procedure c_edificiosMMClick(Sender: TObject);
    procedure RB_riscosClick(Sender: TObject);
    procedure CB_riscosClick(Sender: TObject);
    procedure RB_murosClick(Sender: TObject);
    procedure cb_modulosClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RB_spritesClick(Sender: TObject);
    procedure cb_spritesClick(Sender: TObject);
    procedure Btn_AsignarPosClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RB_borrar_GEnter(Sender: TObject);
    procedure Btn_AsignarPosRETClick(Sender: TObject);
    procedure BtnObjeto2Click(Sender: TObject);
    procedure cb_tipo_sensorChange(Sender: TObject);
    procedure cb_me_nidoClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cb_sensible_flagsClick(Sender: TObject);
    procedure cb_flagChange(Sender: TObject);
    procedure c_flag_activoClick(Sender: TObject);
    procedure cb_efSChange(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure E_flag_Change(Sender: TObject);
    procedure c_limpiar_flagClick(Sender: TObject);
    procedure boton_flagsClick(Sender: TObject);
    procedure cb_efCChange(Sender: TObject);
    procedure cb_AbismoVacioClick(Sender: TObject);
    procedure BtnAyudaLlaveClick(Sender: TObject);
    procedure GuardarMiniMapa1Click(Sender: TObject);
    procedure MD51Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
    Mapacompreso:TMapaCompreso;
    Mapa:TMapaDescriptivo;
    MapaTiles:TMapaTiles;
    Nr_Graficos:word;
    Nr_Sensores,Nr_nidos,Nr_comerciantes,Nr_NPC:byte;

    LosFlagsCalabozo:integer;
    LosFlagsAutoLimpiables:integer;
    ElComportamientoFlag:TArreglo32bytes;
    ElDato1Flag:TArreglo32bytes;//32 bytes, 72 en total
    ElDato2Flag:TArreglo32bytes;//32 bytes, 104 en total

    Grafico:array[0..max_graficos] of Tgrafico;
    Sensor:array[0..max_sensores] of Tsensor;
    Nido:array[0..max_nidos] of TNidoCriaturas;
    Comerciante:array[0..max_comerciantes] of Tcomerciante_Mapa;
//    NPC:array[0..max_npc] of TNPC_mapa;

    TextoSensor:TListaTextoSensor;
    TextoComerciante:TListaTextoComerciante;
    GraficoAcolocar:Tgrafico;
    Pergamino_Mapa:IDirectDrawSurface7;

    MarcaGrafico,MarcaGraficoTecho,MarcaGraficoPiso,MarcaActorSensor:TElementoGrafico;
    //Graficos DD:
    grTab:TcoleccionGraficosTablero;
    Ritmo_Tablero:integer;
    //Otros
    DatosInicialesComercio:TArchivoComercios;
    //Interface
    anteriorX,anteriorY:integer;
    desTemp:Tdescripcion;
    ColocandoGrafico,DibujandoMiniMapa,DibujarMapaReal:boolean;
    //Otros auxiliares
    ID_MAPA:byte;
    NroMapa_marcado,posX_marcado,posY_marcado:byte;//Para definir portales.

    NombresCortosSensores:TstringList;

    CambiosRealizados:boolean;
    procedure InicializarTablero;
    procedure ActualizarTableroTiles(limites:Trect);
    procedure DibujarMapa;
    procedure DibujarMiniMapa(limites:Trect);
    procedure BrochearEnMiniMapa(px,py:integer);
    procedure DibujarEnMiniMapa(x,y:integer);
    function getTerrenoXY(x,y:integer):byte;//tiles
    function getInfoTileXY(x,y:integer):byte;//tiles
    function getTerreno(x,y:integer):integer;//areas
    procedure ScreenToTablero(var x,y:integer);//calcular posicion en el tablero
    procedure ScreenToTiles(var x,y:integer);//calcular posicion en el tablero
    function DeterminarAutoGraficoPorTerreno(terreno:integer):integer;
    procedure ColocarGrafico(x,y,codigoFlagsDelGrafico:integer;reflejado:boolean);
    procedure BorrarGrafico(x,y:integer);
    procedure recuperar(nombre:string);
    procedure guardar(const nombre:string);
//    procedure LlenarDatosNPC(x,y:integer);
    procedure LlenarDatosGrafico(x,y:integer);
    procedure LlenarDatosNido(x,y:integer);
    procedure LlenarDatosSensor(x,y:integer);
    procedure LlenarDatosComerciante(x,y:integer);

    function ColocarSensor(x,y:integer):boolean;
    function BorrarSensor(x,y:integer):boolean;
    function ColocarNido(x,y:integer):boolean;
    function BorrarNido(x,y:integer):boolean;
    function ColocarComerciante(x,y:integer):boolean;
    function BorrarComerciante(x,y:integer):boolean;
{
    function ColocarNPC(x,y:integer):boolean;
    function BorrarNPC(x,y:integer):boolean;
}
    procedure ActualizarLabelPosicionGuardada;
    procedure ReflejarMapa(horizontal:boolean);
    procedure RealizarSeleccionObjeto(x,y:integer);
  public
    { Public declarations }
  end;

var
  FCmundo: TFCmundo;


implementation

{$R *.DFM}

uses Graficador,SScreen,def_Banderas,JPEG,MD5;

var nomGra:TnombresGraficos;

    Paleta_Pergamino_Mapa:array[0..191] of word;

function validar(EditValidado:Tedit;minimo,maximo,determinado:integer):integer;
//deFabrica indica el valor a devolver si ocurre un error
var codigo:integer;
begin
  val(EditValidado.text,result,codigo);
  if codigo<>0 then result:=determinado
  else
    if result<minimo then result:=minimo
    else
      if result>maximo then result:=maximo;
  EditValidado.text:=intastr(result);
end;

function guardarValor(EditValidado:Tedit;minimo,maximo,determinado:integer):integer;
//deFabrica indica el valor a devolver si ocurre un error
var codigo:integer;
begin
  val(EditValidado.text,result,codigo);
  if codigo<>0 then result:=determinado
  else
    if result<minimo then result:=minimo
    else
      if result>maximo then result:=maximo;
end;


function TraducirACodigosSprites(indice:integer):byte;
begin
  case indice of
    1:result:=fxFundicion;
    2:result:=fxFlamaAzul;
    3:result:=fxFlamaAltar1;
    4:result:=fxFlamaAltar2;
    5:result:=fxExplosion1;
    6:result:=fxExplosion2;
    7:result:=fxExplosion3;
    8:result:=fxHumoChimenea;
    9:result:=fxHumo;
    10:result:=anEstandarte;
    11:result:=fxFlamaBlanca;
    12:result:=fxAntorcha1;
    13:result:=fxAntorcha2;
    14:result:=fxAntorcha3;
    15:result:=fxAntorchaR;
    16:result:=fxAntorchaG;
    17:result:=fxAntorchaB;
    18:result:=fxAltar1;
    19:result:=fxAltar2;
    20:result:=fxAltar3;
    21:result:=fxAltarR;
    22:result:=fxAltarG;
    23:result:=fxAltarB;
    24:result:=fxPortal;
    25:result:=fxPortal1;
    26:result:=fxPortal2;
    27:result:=fxPortal3;
    28:result:=fxPersonalizado0;
    29:result:=fx0R;
    30:result:=fx0G;
    31:result:=fx0B;
    32:result:=fxPersonalizado1;
    33:result:=fx1R;
    34:result:=fx1G;
    35:result:=fx1B;
    36:result:=fxPersonalizado2;
    37:result:=fx2R;
    38:result:=fx2G;
    39:result:=fx2B;
  else
    result:=fxFogata;
  end;
end;

function TraducirAIndiceSprites(codigo:byte):integer;
begin
  case codigo of
    fxFundicion:result:=1;
    fxFlamaAzul:result:=2;
    fxFlamaAltar1:result:=3;
    fxFlamaAltar2:result:=4;
    fxExplosion1:result:=5;
    fxExplosion2:result:=6;
    fxExplosion3:result:=7;
    fxHumoChimenea:result:=8;
    fxHumo:result:=9;
    anEstandarte:result:=10;
    fxFlamaBlanca:result:=11;
    fxAntorcha1:result:=12;
    fxAntorcha2:result:=13;
    fxAntorcha3:result:=14;
    fxAntorchaR:result:=15;
    fxAntorchaG:result:=16;
    fxAntorchaB:result:=17;
    fxAltar1:result:=18;
    fxAltar2:result:=19;
    fxAltar3:result:=20;
    fxAltarR:result:=21;
    fxAltarG:result:=22;
    fxAltarB:result:=23;
    fxPortal:result:=24;
    fxPortal1:result:=25;
    fxPortal2:result:=26;
    fxPortal3:result:=27;
    fxPersonalizado0:result:=28;
    fx0R:result:=29;
    fx0G:result:=30;
    fx0B:result:=31;
    fxPersonalizado1:result:=32;
    fx1R:result:=33;
    fx1G:result:=34;
    fx1B:result:=35;
    fxPersonalizado2:result:=36;
    fx2R:result:=37;
    fx2G:result:=38;
    fx2B:result:=39;
  else
    result:=0;
  end;
end;

function LeerPaletaPergaminoMapa:boolean;
var f:file;
begin
  {$I-}
  assignFile(f,rutaGraficosTablero+'grf\Mapa.pal');
  reset(f,1);
  blockread(f,Paleta_Pergamino_Mapa,sizeOf(Paleta_Pergamino_Mapa));
  closefile(f);
  {$I+}
  result:=IOresult=0;
end;

procedure TFCmundo.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TFCmundo.AbrirMapa1Click(Sender: TObject);
begin
  if opendialog.Execute then
    Recuperar(opendialog.Filename);
end;

procedure TFCmundo.GuardarMapa1Click(Sender: TObject);
var i,code:integer;
    cad:string;
begin
  savedialog.FileName:=openDialog.filename;
  with savedialog do
  if Execute then
  begin
    Guardar(Filename);
    cad:=ExtractFileName(filename);
    delete(cad,length(cad)-3,4);
    val(cad,i,code);
    if (code<>0) or (i<0) or (i>MAX_TOTAL_MAPAS) then
      showmessage('El mapa fue guardado con el nombre indicado, sin embargo para que funcionen en el juego el nombre de los archivos de mapas debe ser un número de 0 a 254.'+#13+#13+
        'En el servidor los mapas deben tener nombres consecutivos de 0 hasta el número indicado en "Número de mapas" del archivo "opciones.txt" del servidor.'+#13+#13+
        'Es necesario que los programas cliente y servidor tengan el mismo juego de mapas.');
  end;
end;

procedure TFCmundo.ScreenToTablero(var x,y:integer);//calcular posicion en el tablero
begin
  x:=((x div ancho_tile)-13+scrollbarx.position) div 4;
  y:=((y div alto_tile)-11+scrollbary.position) div 4;
  limitar(x,y);
end;

procedure TFCmundo.ScreenToTiles(var x,y:integer);//calcular posicion en el tablero
begin
  x:=(((x{+12}) div ancho_tile)-13+scrollbarx.position);
  y:=(((y{+8}) div alto_tile)-11+scrollbary.position);
  limitarExt(x,y);
end;

procedure TFCmundo.InicializarTablero;
var i,j:integer;
begin
  for j:=0 to maximo do
    for i:=0 to maximo do
      Mapa[i,j]:=CB_terreno.itemindex;
  Nr_Graficos:=0;
  Nr_Sensores:=0;
  Nr_nidos:=0;
  Nr_comerciantes:=0;
//Nr_NPC:=0;
  //Ahora de los formularios:
  e_nombre.text:='';
  cbTipoClimaMapa.itemindex:=0;
  cbTipoMapa.itemindex:=0;
  e_norte.text:='255';
  e_sur.text:='255';
  e_este.text:='255';
  e_oeste.text:='255';
  cb_AbismoVacio.Checked:=false;
  FillChar(mapaTiles,sizeOf(mapaTiles),0);
  ActualizarTableroTiles(rect(0,0,maximo,maximo));
end;

function TFCmundo.getInfoTileXY(x,y:integer):byte;//tiles
begin
  limitarExt(x,y);
  result:=mapaTiles[x,y];
end;

function TFCmundo.getTerrenoXY(x,y:integer):byte;
begin
  limitarExt(x,y);
  result:=mapaTiles[x,y] and $1F;
end;

function TFCmundo.getTerreno(x,y:integer):integer;
begin
  limitar(x,y);
  result:=mapa[x,y] and $1F;
end;

procedure TFCmundo.ActualizarTableroTiles(limites:Trect);
var terreno,i,j,a,b:integer;
    s,e,n,code:integer;

  function NoEsPiso(x,y:integer):bytebool;
  //Para que cuevas(abismos) y montañas se vean mejor al asignar terreno a las esquinas
  begin
    limitar(x,y);
    x:=Mapa[x,y];
    result:=(x<=16) or (x>=28);
  end;

begin
with limites do
begin
  if Top<0 then Top:=0;
  if left<0 then left:=0;
  if bottom>maximo then bottom:=maximo;
  if Right>maximo then Right:=maximo;
  for j:=top to bottom do
    for i:=left to right do
    begin
      terreno:=mapa[i,j];
{      if (terreno<20) or (terreno>26) then}
      begin
        //Pedazo superior izquierdo
        n:=terreno;
        if ((getTerreno(i-1,j)=getTerreno(i-1,j-1)) and
             (getTerreno(i,j-1)<>getTerreno(i,j)))or
           ((getTerreno(i,j-1)=getTerreno(i-1,j-1)) and
             (getTerreno(i-1,j)<>getTerreno(i,j))) then
            begin
              if NoEsPiso(i-1,j-1) or (getTerreno(i-1,j)=getTerreno(i,j-1)) then
                n:=getTerreno(i-1,j-1)
            end
          else
            if (getTerreno(i-1,j)=getTerreno(i,j-1)) and
                 ((getTerreno(i,j)<getTerreno(i-1,j)) or
                  (getTerreno(i,j)<>getTerreno(i-1,j-1))) then
                n:=getTerreno(i-1,j);
        //Pedazo superior derecho
        e:=terreno;
        if ((getTerreno(i+1,j)=getTerreno(i+1,j-1)) and
             (getTerreno(i,j-1)<>getTerreno(i,j)))or
           ((getTerreno(i,j-1)=getTerreno(i+1,j-1)) and
             (getTerreno(i+1,j)<>getTerreno(i,j))) then
            begin
              if NoEsPiso(i+1,j-1) or (getTerreno(i+1,j)=getTerreno(i,j-1)) then
                e:=getTerreno(i+1,j-1)
            end
        else
            if (getTerreno(i+1,j)=getTerreno(i,j-1)) and
                 ((getTerreno(i,j)<getTerreno(i+1,j)) or
                  (getTerreno(i,j)<>getTerreno(i+1,j-1)))then
                e:=getTerreno(i+1,j);
        //Pedazo inferior izquierdo
        s:=terreno;
        if ((getTerreno(i-1,j)=getTerreno(i-1,j+1)) and
             (getTerreno(i,j+1)<>getTerreno(i,j)))or
           ((getTerreno(i,j+1)=getTerreno(i-1,j+1)) and
             (getTerreno(i-1,j)<>getTerreno(i,j))) then
            begin
              if noEsPiso(i-1,j+1) or (getTerreno(i-1,j)=getTerreno(i,j+1))then
                s:=getTerreno(i-1,j+1)
            end
        else
            if (getTerreno(i-1,j)=getTerreno(i,j+1)) and
                 ((getTerreno(i,j)<getTerreno(i-1,j)) or
                  (getTerreno(i,j)<>getTerreno(i-1,j+1)))then
                s:=getTerreno(i-1,j);
        for a:=0 to 3 do
          for b:=0 to 3 do
          begin
            code:=terreno;
            //Control de pisos de interior:
            if (a+b<=1) then  //pedazo superior izquierdo
              code:=n
            else if (a-b>=3) then //pedazo superior derecho
                   code:=e
               else if (b-a>=3) then //pedazo inferior izquierdo
                        code:=s;
{            if (code>=20) and (code<=26) then
              code:=terreno;}
            mapaTiles[i*4+a,j*4+b]:=(mapaTiles[i*4+a,j*4+b] and $E0) or (code and $1F);
          end;
      end
{      else
        for a:=0 to 3 do
          for b:=0 to 3 do
            mapaTiles[i*4+a,j*4+b]:=code;}
    end
end;
end;

procedure TFCmundo.NuevoMapa1Click(Sender: TObject);
begin
  InicializarTablero;
  DibujarMiniMapa(rect(0,0,maximo,maximo));
  DibujarMapa;
  E_nombre.text:='';
  caption:=TITULO_APLICACION;
  PB_MMapa.repaint;
end;

function CrearImagenDeMarcas:Tbitmap;
begin
  result:=CrearBackBufferDD(ancho_tile,alto_tile*4);
  with result.canvas do
  begin
    brush.style:=bsClear;
    BitBlt(handle,0,0,ancho_tile,alto_tile*4,0,0,0,blackness);
    pen.color:=$004000;
    Ellipse(1,1,ancho_tile-1,alto_tile-1);
{    moveto(ancho_tile shr 1,0);
    lineto(ancho_tile shr 1,alto_tile);}
    moveto(0,alto_tile shr 1);
    lineto(ancho_tile,alto_tile shr 1);
    pen.color:=cllime;
    Ellipse(0,0,ancho_tile,alto_tile);
{    moveto(ancho_tile shr 1-1,0);
    lineto(ancho_tile shr 1-1,alto_tile);}
    moveto(0,alto_tile shr 1-1);
    lineto(ancho_tile,alto_tile shr 1-1);

    pen.color:=$004040;
    Ellipse(3,3+alto_tile,ancho_tile-3,alto_tile shl 1-3);
    moveto(0,alto_tile);
    lineto(ancho_tile,alto_tile shl 1);
    moveto(ancho_tile,alto_tile);
    lineto(0,alto_tile shl 1);
    pen.color:=clyellow;
    Ellipse(2,2+alto_tile,ancho_tile-2,alto_tile shl 1-2);
    moveto(1,alto_tile);
    lineto(ancho_tile,alto_tile shl 1-1);
    moveto(ancho_tile,alto_tile-1);
    lineto(0,alto_tile shl 1-1);

    pen.color:=$000040;
    rectangle(1,1+alto_tile shl 1,ancho_tile-1,alto_tile-1+alto_tile shl 1);
    moveto(ancho_tile shr 1,alto_tile shl 1);
    lineto(ancho_tile shr 1,alto_tile+alto_tile shl 1);
{    moveto(0,alto_tile shr 1+alto_tile shl 1);
    lineto(ancho_tile,alto_tile shr 1+alto_tile shl 1);}
    pen.color:=clred;
    rectangle(0,alto_tile shl 1,ancho_tile,alto_tile+alto_tile shl 1);
    moveto(ancho_tile shr 1-1,+alto_tile shl 1);
    lineto(ancho_tile shr 1-1,alto_tile+alto_tile shl 1);
{    moveto(0,alto_tile shr 1-1+alto_tile shl 1);
    lineto(ancho_tile,alto_tile shr 1-1+alto_tile shl 1);}

    pen.color:=$202020;
    rectangle(1,alto_tile*3+1,ancho_tile,alto_tile shl 2);
    pen.color:=clwhite;
    rectangle(0,alto_tile*3,ancho_tile-1,alto_tile shl 2-1);
    brush.style:=bssolid;
    brush.color:=clblack;
    fillrect(rect(0,alto_tile*3+3,ancho_tile,alto_tile shl 2-3));
    fillrect(rect(4,alto_tile*3,ancho_tile-5,alto_tile shl 2));
  end;
end;

procedure TFCmundo.FormCreate(Sender: TObject);
var i:integer;
    imagenMarcas,imgMarca:Tbitmap;
  function RecuperarDatosInicialesComercios:boolean;
  var f:File of TArchivoComercios;
  begin
    FillChar(DatosInicialesComercio,sizeof(DatosInicialesComercio),0);
    assignFile(f,'..\laa\bin\comercio.b');
    reset(f);
    {$I-}
    read(f,DatosInicialesComercio);
    {$I+}
    result:=IOResult=0;
    closeFile(f);
  end;
begin
  CambiosRealizados:=false;
  ID_MAPA:=255;
  NroMapa_marcado:=0;
  posX_marcado:=0;
  posY_marcado:=0;
  CB_terreno.itemindex:=8;
  OpenDialog.InitialDir:=rutaGraficosTablero+'bin';
  SaveDialog.InitialDir:=rutaGraficosTablero+'bin';
  ControlStyle:=ControlStyle+[csOpaque]-[csDoubleClicks];
  with PB_Mmapa do ControlStyle:=ControlStyle+[csOpaque]-[csDoubleClicks];
  DibujandoMiniMapa:=false;
  DibujarMapaReal:=true;
  ColocandoGrafico:=false;
  with desTemp do
  begin
    posx_t:=0;
    posy_t:=0;
    terreno:=0;
    terrenoSeleccionado:=cd_Nulo_byte;
  end;
  Graficos.FijarRutaRecuperacionArchivos(rutaGraficosTablero);
  with FEsperar do
  begin
    InicializarDirectDraw(self.handle,true,screen.width,screen.height);
    InicializarEfectos(rutaGraficosTablero+CrptGDD);
    Mensaje(40,'Recuperando Calabozos');
    InicializarConstantesTablero(rutaGraficosTablero+'bin\',@nomGra);
    grTab:=TcoleccionGraficosTablero.create;
    InicializarMonstruos(rutaGraficosTablero+'bin\std.mon');
    InicializarColeccionObjetos(rutaGraficosTablero+'bin\obj.b');
    Mensaje(50,'Creando nuevo mapa');
  end;
  RecuperarDatosInicialesComercios;
  for i:=Inicio_tipo_monstruos to Fin_tipo_monstruos do
    cb_tipo_nido.items.Add(InfMon[i].nombre);
  for i:=0 to Fin_tipo_monstruos do
    cmbAniComerciante.items.Add(InfMon[i].nombre);
  cmbObjetoLlave.Items.Add('<SIN LLAVE>');
  cmbObjetoLlave.Items.Add('<BANDERA DE MAPA ACTIVA: 0 a 31>');
  cmbObjetoLlave.Items.Add('<MINIMO NIVEL DE HONOR: 0 a 100>');
  cmbObjetoLlave.Items.Add('<<ESPECIAL>>');
  for i:=4 to 255 do
    cmbObjetoLlave.Items.Add(NomObj[i]);
  for i:=0 to INICIO_RISCOS-1 do
    cb_graficos.items.Add(NomGra[i]);
  for i:=INICIO_RISCOS to INICIO_EDIFICIOS-1 do
    cb_riscos.items.Add(NomGra[i]);
  for i:=INICIO_EDIFICIOS to INICIO_MODULOS-1 do
    cb_edificios.items.Add(NomGra[i]);
  for i:=INICIO_MODULOS to MAX_OBJETOS_GRAFICOS-1 do//el ultimo está reservado
    cb_modulos.items.Add(NomGra[i]);
  for i:=0 to MAX_TIPOS_COMERCIO do
    CmbTipoComerciante.Items.Add(trim(MC_nombresComerciantes[i]+' '+MC_DescripcionComercio[i]));
  for i:=0 to 31 do
  begin
    cb_flag_grafico.items.add('Bandera '+inttostr(i));
    cb_flag.items.add('Bandera '+inttostr(i));
  end;
  cb_flag.itemindex:=0;
  cb_flagChange(cb_flag);
  cb_flag_grafico.itemindex:=0;
  CmbTipoComerciante.itemindex:=0;
  Cb_graficos.itemindex:=0;
  Cb_edificios.itemindex:=0;
  CB_riscos.ItemIndex:=0;
  CB_modulos.ItemIndex:=0;
  CB_sprites.ItemIndex:=0;
  cb_tipo_npc.ItemIndex:=0;
  cb_tipo_nido.ItemIndex:=0;
  cb_tipo_sensor.ItemIndex:=0;
  cmbAniComerciante.ItemIndex:=0;
  cmbObjetoLlave.ItemIndex:=0;
  CrearSuperficieDeBMP(Pergamino_Mapa,rutaGraficosTablero+'grf\Mapa'+ExtArc);
  LeerPaletaPergaminoMapa;
  imagenMarcas:=CrearImagenDeMarcas();
  imgMarca:=CrearBackBufferDD(ancho_tile,alto_tile);
  BitBlt(imgMarca.canvas.handle,0,0,ancho_tile,alto_tile,imagenMarcas.canvas.handle,0,0,SRCCOPY);
  MarcaGraficoPiso:=TElementoGrafico.create(imgMarca,0,0,0,0);
  BitBlt(imgMarca.canvas.handle,0,0,ancho_tile,alto_tile,imagenMarcas.canvas.handle,0,alto_tile,SRCCOPY);
  MarcaGrafico:=TElementoGrafico.create(imgMarca,0,0,0,0);
  BitBlt(imgMarca.canvas.handle,0,0,ancho_tile,alto_tile,imagenMarcas.canvas.handle,0,alto_tile*2,SRCCOPY);
  MarcaGraficoTecho:=TElementoGrafico.create(imgMarca,0,0,0,0);
  BitBlt(imgMarca.canvas.handle,0,0,ancho_tile,alto_tile,imagenMarcas.canvas.handle,0,alto_tile*3,SRCCOPY);
  MarcaActorSensor:=TElementoGrafico.create(imgMarca,0,0,0,0);
    imgMarca.free;
  imagenMarcas.free;

  InicializarTablero;
  DibujarMiniMapa(rect(0,0,maximo,maximo));
  DibujarMapa;

  PageControl1Change(nil);
  TextoDDraw.alineacionX:=axCentro;
  cbFx.ItemIndex:=0;
  NombresCortosSensores:=Tstringlist.create;
  for i:=0 to cb_tipo_Sensor.Items.Count-1 do
    NombresCortosSensores.Add(copy(cb_tipo_Sensor.Items[i],1,pos(':',cb_tipo_Sensor.Items[i])-1));
  PageControl1.ActivePage:=Ts_general;
  Caption:=Caption+GetVersion;
end;

procedure TFCMundo.DibujarMiniMapa(limites:Trect);
const Zona_Origen:Trect=(left:0;top:0;right:128;bottom:128);
var lpDDSurfaceDesc:TDDSurfaceDesc2;
    contaO:pointer;
    TotalPixeles:integer;
    indice,base,i2,j2:integer;
    SuperficieDD:IDirectDrawSurface7;
begin
  SuperficieDD:=Pergamino_mapa;
  FillChar(lpDDSurfaceDesc, SizeOf(lpDDSurfaceDesc),#0);//Llena de ceros.
  lpDDSurfaceDesc.dwSize := sizeof(lpDDSurfaceDesc);
  lpDDSurfaceDesc.dwFlags := DDSD_CAPS or DDSD_LPSURFACE or DDSD_PITCH;
  if SuperficieDD.lock(@Zona_Origen,lpDDSurfaceDesc,DDLOCK_WAIT,0)=DD_OK then
  begin
    ContaO:=lpDDSurfaceDesc.lpSurface;
    with Zona_Origen do
      TotalPixeles:=integer(ContaO)+((bottom-top)*lpDDSurfaceDesc.lPitch)-2;
    indice:=0;
    while integer(contaO)<TotalPixeles do
    begin
      i2:=(indice and $7F) shl 1;
      j2:=(indice shr 6) and $FE;
      base:=0;
      if c_edificiosMM.Checked then
      begin
        if bytebool(MapaTiles[i2,j2] and ft_Ocupado) then inc(base,32);
        if bytebool(MapaTiles[i2+1,j2] and ft_Ocupado) then inc(base,32);
        if bytebool(MapaTiles[i2,j2+1] and ft_Ocupado) then inc(base,32);
        if bytebool(MapaTiles[i2+1,j2+1] and ft_Ocupado) then inc(base,32);
      end;
      word(contaO^):=Paleta_pergamino_mapa[mapaTiles[i2,j2] and $1F+base];
      word(contaO^):=((word(contaO^) and mskTrans) + Paleta_pergamino_mapa[mapaTiles[i2+1,j2+1] and $1F+base]) shr 1;
      word(contaO^):=((word(contaO^) and mskTrans) + Paleta_pergamino_mapa[mapaTiles[i2+1,j2] and $1F+base]) shr 1;
      word(contaO^):=((word(contaO^) and mskTrans) + Paleta_pergamino_mapa[mapaTiles[i2,j2+1] and $1F+base]) shr 1;
      inc(indice);
      inc(integer(ContaO),2);
    end;
    SuperficieDD.unlock(@Zona_Origen);
  end;
end;

procedure TFCmundo.PB_MmapaPaint(Sender: TObject);
var indice:integer;
begin
  with PB_MMapa.canvas do
  begin
    CopiarSuperficieACanvas(handle,0,0,128,128,Pergamino_mapa,0,0);
    //area visible
    brush.color:=clwhite;
    FrameRect(rect((Scrollbarx.position div 2)-6,
      (Scrollbary.position div 2)-6,
      (Scrollbarx.position div 2)+7,
      (Scrollbary.position div 2)+6));
    brush.color:=clyellow;
    //zona de efecto de bandera actual
    if pageControl1.ActivePage=TS_Banderas then
    begin
      indice:=cb_flag.itemindex and $1F;
      if ElComportamientoFlag[indice]<>0 then
        frameRect(rect(elDato1Flag[indice] shr 1-2,elDato2Flag[indice] shr 1-2,
          elDato1Flag[indice] shr 1+2,elDato2Flag[indice] shr 1+2));
    end
    else if pageControl1.ActivePage=TS_Nido then
    begin
      for indice:=0 to Nr_nidos-1 do
        with Nido[indice] do
          frameRect(rect(posx shr 1,posy shr 1,posx shr 1,posy shr 1));
    end
    else if pageControl1.ActivePage=TS_sensor then
    begin
      for indice:=0 to Nr_sensores-1 do
        with sensor[indice] do
          frameRect(rect(posx shr 1,posy shr 1,posx shr 1,posy shr 1));
    end
    else if pageControl1.ActivePage=TS_comerciante then
    begin
      for indice:=0 to Nr_comerciantes-1 do
        with comerciante[indice] do
          frameRect(rect(posx shr 1,posy shr 1,posx shr 1,posy shr 1));
    end
  end;
end;

procedure TFCmundo.PB_MmapaMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if [ssright]=shift then
  begin
    if (PageControl1.ActivePage=TS_terreno) and cbDefTerMiniMapa.Checked then
    begin
      CopiarSuperficieACanvas(PB_MMapa.canvas.handle,0,0,128,128,Pergamino_mapa,0,0);
      anteriorX:=x div 2;
      anteriorY:=y div 2;
      BrochearEnMiniMapa(anteriorx,anteriory);
    end
  end else
  if [ssleft]=shift then
  begin
    if (y*2<>Scrollbary.position) and (x*2<>Scrollbarx.position) then
      DibujarMapaReal:=false;
    Scrollbarx.position:=x*2;
    Scrollbary.position:=y*2;
  end;
end;

procedure TFCmundo.PB_MmapaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PB_MMapa.repaint;
end;

procedure TFCmundo.PB_MmapaMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var destinox,destinoy,deltax,deltay,i:integer;
begin
  if [ssright]=shift then
  begin
    if (PageControl1.ActivePage=TS_terreno) and cbDefTerMiniMapa.Checked then
    begin
      x:=x div 2;
      y:=y div 2;
      destinox:=anteriorx;
      destinoy:=anteriory;
      anteriorx:=x;
      anteriory:=y;
      deltax:=destinox-x;
      deltay:=destinoy-y;
      if (deltax<>0) or (deltay<>0) then
      begin
        if abs(deltax)>abs(deltay) then
        begin
          if deltax<0 then
          begin
            //intercambiar destinox con x
            i:=destinox;destinox:=x;x:=i;
            y:=destinoy;
          end;
          if deltay=0 then
            for i:=x to destinox do
              BrochearEnMiniMapa(i,y)
          else
            for i:=x to destinox do
              BrochearEnMiniMapa(i,y+((i-x)*deltay) div deltax)
        end
        else
        begin
          if deltay<0 then
          begin
            //intercambiar destinoy con y
            i:=destinoy;destinoy:=y;y:=i;
            x:=destinox;
          end;
          if deltax=0 then
            for i:=y to destinoy do
              BrochearEnMiniMapa(x,i)
          else
            for i:=y to destinoy do
              BrochearEnMiniMapa(x+((i-y)*deltax) div deltay,i)
        end
      end;
    end;
  end
  else
  if [ssleft]=shift then
  begin
    if (y*2<>Scrollbary.position) and (x*2<>Scrollbarx.position) then
      DibujarMapaReal:=false;
    Scrollbarx.position:=x*2;
    Scrollbary.position:=y*2;
  end;
end;

procedure TFCmundo.DibujarEnMiniMapa(x,y:integer);
var posx,posy:integer;
begin
  if y<0 then y:=0;
  if x<0 then x:=0;
  if y>maximo then y:=maximo;
  if x>maximo then x:=maximo;
  if Mapa[x,y]<>CB_terreno.itemindex then
  begin
    Mapa[x,y]:=(Mapa[x,y] and $E0) or (CB_terreno.itemindex and $1F);
    ActualizarTableroTiles(rect(x-1,y-1,x+1,y+1));
    DibujarMiniMapa(rect(x,y,x,y));
    posx:=x*2;
    posy:=y*2;
    CopiarSuperficieACanvas(PB_MMapa.canvas.handle,posx,posy,2,2,Pergamino_mapa,posx,posy);
    if (x>(Scrollbarx.position div 4)-5) and (x<(Scrollbarx.position div 4)+5) and
       (y>(Scrollbary.position div 4)-4) and (y<(Scrollbary.position div 4)+4) then
      DibujarMapa;
  end;
end;

procedure TFCmundo.BrochearEnMiniMapa(px,py:integer);
var x,y:integer;
    NecesitaDibujarse:boolean;
begin
  NecesitaDibujarse:=false;
  for y:=py-2 to py+2 do
    if (y<=maximo) and (y>=0) then
    for x:=px-2 to px+2 do
      if (x>=0) and (x<=maximo) then
        if Mapa[x,y]<>CB_terreno.itemindex then
        begin
          Mapa[x,y]:=(Mapa[x,y] and $E0) or (CB_terreno.itemindex and $1F);
          ActualizarTableroTiles(rect(x-1,y-1,x+1,y+1));
          if (x>(Scrollbarx.position div 4)-5) and (x<(Scrollbarx.position div 4)+5) and
             (y>(Scrollbary.position div 4)-4) and (y<(Scrollbary.position div 4)+4) then
            NecesitaDibujarse:=true;
        end;
  if NecesitaDibujarse then
    DibujarMapa;
  DibujarMiniMapa(rect(0,0,128,128));
  CopiarSuperficieACanvas(PB_MMapa.canvas.handle,0,0,128,128,Pergamino_mapa,0,0);
end;

procedure TFCmundo.DibujarMapa;
//  DIBUJAR TERRENO DEL MAPA
var i,j,pi,pj,x,y,ter_i:integer;
    px,py:integer;
    nro_mez:integer;//para pseudo tiles entre terrenos:-1=sin transparencia
    mos_i,mos_j,codigoDelGrafico:integer;
    coord:Tposicion;
    ter,ter_Base:integer;//Terreno de esquinas
    rOrigen,rDestino:Trect;
    //Otros
    efectos:byte;
    cad:string;

  procedure DeterminarMosaico;
  //necesita ter,x,y,Ritmo_Tablero,px,py
  //modifica mos_1,mos_j,rdestino,rorigen
  begin
    //movimiento de líquidos
    case ter of
      30,28:
      begin
        mos_j:=(Ritmo_Tablero+y+33101) mod 9;
        mos_i:=(x+32000+
          round(cos((y mod 6))*2)
          ) mod 6;
      end;
      29,31:
      begin
        mos_j:=(Ritmo_Tablero+y+33109) mod 9;
        mos_i:=(x+31017+(y+31021)*4)mod 6;
      end
      else
      begin
        case (px+py) mod 3 of
          0:mos_i:=1+random(4);
          1:mos_i:=random(6);
          else mos_i:=random(3)+random(4);
        end;
        if LongBool((x xor y)and $1) xor (mos_i<=2) then //Tablero ajedrezado
          mos_i:=5-mos_i;
        mos_j:=random(3);
      end;
    end;
    //Direct Draw://144,24
    with rOrigen do
    begin
      Left:=(ter and $3)*144+mos_i*ancho_tile;
      top:=(ter shr 2)*48+mos_j*alto_tile;
      Right:=left+ancho_tile;
      bottom:=top+alto_tile;
    end;
    with rDestino do
    begin
      Left:=i*ancho_tile-12;
      top:=j*alto_tile-8;
      Right:=left+ancho_tile;
      bottom:=top+alto_tile;
    end;
  end;

  procedure DibujarPseudoMosaico;
  begin
   if (ter<>ter_Base) then
//   if (ter<20) or (ter>26) then
   begin
    DeterminarMosaico;
    if EstaEnPantalla(rDestino,rOrigen,false) then
      BltAlphaTile(rDestino,GrTab.SuperficieTerreno,ROrigen,nro_mez);
   end;
  end;

  procedure VerificarMosaicosAlpha;
    var Tiempo:TDateTime;
        i:integer;
  begin
    tiempo:=now;
    rdestino:=rect(100,100,100+ancho_tile,100+alto_tile);
    rorigen:=rect(0,0,ancho_tile,alto_tile);
    for i:=0 to 99999 do
      BltAlphaTile(rDestino,GrTab.SuperficieTerreno,ROrigen,0);
    showmessage(floatToStr((now-Tiempo)*86400.0));
  end;

  procedure DibujarMosaicosAlpha;
  begin
// PSEUDO MOSAICOS //
//*******************
    ter_Base:=ter;
//  if (ter_Base<20) or (ter_Base>26) then
//    begin
      ter_i:=getTerrenoXY(px+2,py+2);
      //conector
      if (pj=0) and (pi=0) then
      begin
        if getTerrenoXY(px-1,py-1)=getTerrenoXY(px,py-1) then
        begin
          if getTerrenoXY(px-1,py)<>getTerrenoXY(px,py) then
          begin
            ter:=getTerrenoXY(px-1,py);
            nro_mez:=MZ_v;
            DibujarPseudoMosaico;
          end;
          ter:=getTerrenoXY(px,py-1);
          nro_mez:=MZ_h;
          DibujarPseudoMosaico;
        end
        else
        begin
          if getTerrenoXY(px-1,py-1)=getTerrenoXY(px-1,py) then
          begin
            if getTerrenoXY(px,py-1)<>getTerrenoXY(px,py) then
            begin
              ter:=getTerrenoXY(px,py-1);
              nro_mez:=MZ_h;
              DibujarPseudoMosaico;
            end;
            ter:=getTerrenoXY(px-1,py);
            nro_mez:=MZ_v;
            DibujarPseudoMosaico;
          end
          else
            if getTerrenoXY(px-1,py)=getTerrenoXY(px,py) then
            begin
              if getTerrenoXY(px-1,py)<>getTerrenoXY(px,py-1) then
              begin
                ter:=getTerrenoXY(px-1,py-1);
                nro_mez:=MZ_h;
                DibujarPseudoMosaico;
              end;
              if getTerrenoXY(px,py)<>getTerrenoXY(px-1,py) then
              begin
                ter:=getTerrenoXY(px-1,py-1);
                nro_mez:=MZ_id;
                DibujarPseudoMosaico;
              end;
            end
            else
            begin
              ter:=getTerrenoXY(px-1,py);
              nro_mez:=MZ_v;
              DibujarPseudoMosaico;
              if getTerrenoXY(px,py)<>getTerrenoXY(px-1,py) then
              begin
                ter:=getTerrenoXY(px-1,py-1);
                nro_mez:=MZ_id;
                DibujarPseudoMosaico;
              end;
            end;
            if getTerrenoXY(px,py-1)<>getTerrenoXY(px,py) then
            begin
              ter:=getTerrenoXY(px,py-1);
              nro_mez:=MZ_ii;
              DibujarPseudoMosaico;
            end;
        end;
      end// fin de conector (0,0)
      else
      if (pj=0) and (pi=2) then
      begin
        ter:=getTerrenoXY(px+2,py-1);
        nro_mez:=MZ_h;
        DibujarPseudoMosaico;
      end
      else
      if (pi=0) and (pj=2) then
      begin
        ter:=getTerrenoXY(px-1,py+2);
        nro_mez:=MZ_v;
        DibujarPseudoMosaico;
      end
      else
      begin
        // esquina superior izquierda
        nro_mez:=MZ_nulo;
        if (pi<=1) and (pj<=1) then
        begin
          if getTerrenoXY(px,py)<>ter_i then
          // diagonal
          begin
            if (pj+pi=1) then
            begin
              ter:=ter_i;
              nro_mez:=MZ_si;
            end
            else if (pj+pi=2) then
            begin
              ter:=getTerrenoXY(px,py);
              nro_mez:=MZ_id;
            end;
          end;
        end
        else
        // esquina superior derecha
        if (pi>=3) and (pj<=1) then
        begin
          if getTerrenoXY(px+3,py)<>ter_i then
          // diagonal
          begin
            if (pi-pj=3) then
            begin
              ter:=ter_i;
              nro_mez:=MZ_sd;
            end
            else if (pi-pj=2) then
            begin
              ter:=getTerrenoXY(px+3,py);
              nro_mez:=MZ_ii;
            end;
          end;
        end
        else
        // esquina inferior izquierda
        if (pi<=1) and (pj>=3) then
        begin
          if getTerrenoXY(px,py+3)<>ter_i then
          // diagonal
          begin
            if (pj-pi=3) then
            begin
              ter:=ter_i;
              nro_mez:=MZ_ii;
            end
            else if (pj-pi=2) then
            begin
              ter:=getTerrenoXY(px,py+3);
              nro_mez:=MZ_sd;
            end;
          end;
        end
        else
        // esquina inferior derecha
        if (pi=3) and (pj=3) then
        begin
          if {(getTerrenoXY(px+3,py+4)<>ter_i) and (getTerrenoXY(px+4,py+3)<>ter_i)}
            (getTerrenoXY(px+3,py+4)=getTerrenoXY(px+4,py+3)) then
          // diagonal
          begin
            ter:=getTerrenoXY(px+3,py+4);
            nro_mez:=MZ_si;
          end;
        end;
        if (nro_mez<>MZ_nulo) then
          DibujarPseudoMosaico;
      end;
      nro_mez:=MZ_nulo;
      if (pj=0) then
      begin
        if (pi=1) then
          if getTerrenoXY(px,py-1)<>getTerrenoXY(px+2,py-2) then
          begin
            ter:=getTerrenoXY(px+2,py-2);
            nro_mez:=MZ_ii;
          end
          else
          begin
            ter:=getTerrenoXY(px+1,py-1);
            nro_mez:=MZ_h2;
          end;
        if (pi=3) then
          if (getTerrenoXY(px+4,py-1)<>getTerrenoXY(px+2,py-2)) and
            (getTerrenoXY(px+4,py-1)=getTerrenoXY(px+3,py)) then
          begin
            ter:=getTerrenoXY(px+2,py-2);
            nro_mez:=MZ_id;
          end
          else
          begin
            ter:=getTerrenoXY(px+3,py-1);
            nro_mez:=MZ_h2;
          end;
      end;
      if (pi=0) then
      begin
        if (pj=1) then
          if getTerrenoXY(px-1,py)<>getTerrenoXY(px-2,py+2) then
          begin
            ter:=getTerrenoXY(px-2,py+2);
            nro_mez:=MZ_sd;
          end
          else
          begin
            ter:=getTerrenoXY(px-1,py+1);
            nro_mez:=MZ_v2;
          end;
        if (pj=3) then
          if (getTerrenoXY(px-1,py+4)<>getTerrenoXY(px-2,py+2)) and
            (getTerrenoXY(px-1,py+4)=getTerrenoXY(px,py+3)) then
          begin
            ter:=getTerrenoXY(px-2,py+2);
            nro_mez:=MZ_id;
          end
          else
          begin
            ter:=getTerrenoXY(px-1,py+3);
            nro_mez:=MZ_v2;
          end;
      end;
      if (nro_mez<>MZ_nulo) then
        DibujarPseudoMosaico;
  end;
begin
//Gráficos
  coord.x:=ScrollBarx.position;
  coord.y:=ScrollBary.position;
  for i:=0 to 27 do
    for j:=0 to 23 do
    begin
      x:=i+coord.x-13;
      y:=j+coord.y-11;
      px:=x and $FFFFFFFC;
      py:=y and $FFFFFFFC;
      pi:=x and $3;
      pj:=y and $3;
      RandSeed:=((x+31)*(y+17)*197+(x+37)*11+y*23)*97;
//Tiles:
      ter:=getInfoTileXY(x,y);
      if not (((c_GTerreno.checked) and (not c_transparente.checked)) and bytebool(ter and ft_Nodibujar)) then
      begin
        ter:=ter and $1F;
        if not (C_AlphaT.Checked) and (ter=0) then ter:=CB_terreno.ItemIndex;
        DeterminarMosaico;
        if EstaEnPantalla(rDestino,rOrigen,false) then
          SuperficieRender.BltFast(rDestino.left,rDestino.top,GrTab.SuperficieTerreno,@rOrigen,DDBLTFAST_NOCOLORKEY);
        if C_AlphaT.Checked then
          DibujarMosaicosAlpha;
      end;
    end;
//DIBUJAR OBJETOS.
  //Referencia al mapa global
if c_transparente.Checked then
  efectos:=fgfx_TransparenteForzado
else
  efectos:=0;
if (c_GTerreno.checked or c_Techos.checked or c_normales.checked or c_sprites.checked) then
begin
  for ter:=0 to Nr_Graficos-1 do
  with grafico[ter] do
  begin
  codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
  if codigoDelGrafico<=MAX_OBJETOS_GRAFICOS then
    //Pisos
    if (InfGra[codigoDelGrafico].tipo>=tg_Piso) and (c_GTerreno.checked) then
    begin
      if (posy+15>coord.y) and (posy-40<coord.y) and
      (posx+19>coord.x) and (posx-20<coord.x) then
        if GrTab.Grafico[codigoDelGrafico]<>nil then //Seguridad necesaria
        begin
          x:=(posx+9-coord.x)*ancho_tile;
          y:=(posy-InfGra[codigoDelGrafico].aliny+11-coord.y)*alto_tile;
          GrTab.Grafico[codigoDelGrafico].draw(x,y,efectos or flagsGrafico);
        end;
    end;
  end;
  for ter:=0 to Nr_Graficos-1 do
  with grafico[ter] do
  begin
    codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
    if codigoDelGrafico>MAX_OBJETOS_GRAFICOS then
    begin
      if C_sprites.Checked then
      begin
        //Sprites
        x:=(posx+13-coord.x)*ancho_tile;
        y:=(posy+11-coord.y)*alto_tile;
        MarcaGrafico.draw(x,y,$0);
        MarcaActorSensor.draw(x-12,y-8,$0);
        cad:=cb_sprites.Items[TraducirAIndiceSprites(codigoDelGrafico and $FF)];
        if bytebool(flagsGrafico and fgfx_espejo) then cad:=cad+'+R';
        TextoDDraw.textOut(x,y-8,cad);
      end;
    end
    else
      //techos y muros
      if (InfGra[codigoDelGrafico].tipo<tg_piso) and
        ((InfGra[codigoDelGrafico].tipo<>tg_techo) or C_techos.Checked) and
        ((InfGra[codigoDelGrafico].tipo<>tg_normal) or C_normales.Checked) then
      begin
        if (posy+15>coord.y) and (posy-40<coord.y) and
        (posx+19>coord.x) and (posx-20<coord.x) then
          if GrTab.Grafico[codigoDelGrafico]<>nil then //Seguridad necesaria
          begin
            x:=(posx+9-coord.x)*ancho_tile;
            y:=(posy-InfGra[codigoDelGrafico].aliny+11-coord.y)*alto_tile;
            GrTab.Grafico[codigoDelGrafico].draw(x,y,efectos or flagsGrafico);
          end;
      end;
  end;
end;
  //Marcas
if c_marcas.checked then
begin
  TextoDDraw.color:=$FFE0E0;
  for i:=0 to Nr_Graficos-1 do
  with grafico[i] do
  begin
    codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
    if codigoDelGrafico<=MAX_OBJETOS_GRAFICOS then
    if (posy+15>coord.y) and (posy-40<coord.y) and
    (posx+19>coord.x) and (posx-20<coord.x) then
//       if GrTab.Grafico[codigo]<>nil then //no controlar por que no dibujamos el grafico de GrTab
        begin
          x:=(posx+13-coord.x)*ancho_tile;
          y:=(posy+11-coord.y)*alto_tile;
          if InfGra[codigoDelGrafico].tipo=tg_techo then
          begin
            if C_techos.Checked then
              MarcaGraficoTecho.draw(x,y,$0)
          end
          else
            if InfGra[codigoDelGrafico].tipo>=tg_piso then
            begin
              if C_gterreno.Checked then
                MarcaGraficoPiso.draw(x,y,$0)
            end
            else
            begin
              if C_normales.Checked then
                MarcaGrafico.draw(x,y,$0);
            end;
          cad:='';
          if (flagsGrafico and fgfx_Levitacion)<>0 then cad:=cad+'L';
          if (flagsGrafico and fgfx_Ilusion)<>0 then cad:=cad+'I';
          if cad<>'' then TextoDDraw.textOut(x+12,y,cad);
        end;
  end;
  TextoDDraw.color:=$30FFA0;
  for i:=0 to Nr_Comerciantes-1 do
  with comerciante[i] do
  begin
    if (posy+15>coord.y) and (posy-40<coord.y) and
    (posx+19>coord.x) and (posx-20<coord.x) then
      begin
        x:=(posx+13-coord.x)*ancho_tile;
        y:=(posy+11-coord.y)*alto_tile;
        MarcaActorSensor.draw(x,y,$0);
        TextoDDraw.textOut(x+12,y+12,CmbAniComerciante.Items[MonstruoComerciante]);
        TextoDDraw.textOut(x+12,y,CmbTipoComerciante.Items[tipo]);
      end;
  end;
  TextoDDraw.color:=$FFFFFF;
  for i:=0 to Nr_Sensores-1 do
  with sensor[i] do
  begin
    if (posy+15>coord.y) and (posy-40<coord.y) and
    (posx+19>coord.x) and (posx-20<coord.x) then
      begin
        x:=(posx+13-coord.x)*ancho_tile;
        y:=(posy+11-coord.y)*alto_tile;
        MarcaActorSensor.draw(x,y,$0);
        cad:='';
        if (flagsSensor and fs_ParteDelCastillo)<>0 then cad:=cad+'+';
        if (flagsSensor and fs_consumirLlave)<>0 then cad:=cad+'c';
        if (flagsSensor and fs_soloclan)<>0 then cad:=cad+'K';
        if (flagsSensor and fs_solofantasma)<>0 then cad:=cad+'F';
        if (flagsSensor and fs_soloAprendiz)<>0 then cad:=cad+'A';
        if (flagsSensor and fs_repelerAvatar)<>0 then cad:=cad+'*';
        TextoDDraw.textOut(x+12,y+12,cad);
        TextoDDraw.textOut(x+12,y,NombresCortosSensores.Strings[integer(tipo)]);
      end;
  end;
  TextoDDraw.color:=$FFF0A0;
  for i:=0 to Nr_Nidos-1 do
  with Nido[i] do
  begin
    if (posy+15>coord.y) and (posy-40<coord.y) and
    (posx+19>coord.x) and (posx-20<coord.x) then
      begin
        x:=(posx+13-coord.x)*ancho_tile;
        y:=(posy+11-coord.y)*alto_tile;
        MarcaActorSensor.draw(x,y,$0);
        TextoDDraw.textOut(x+12,y+12,'('+inttostr(cantidad)+')');
        TextoDDraw.textOut(x+12,y,cb_tipo_nido.Items[tipo-Inicio_tipo_monstruos]);
      end;
  end;
end;
  TextoDDraw.color:=$40D0FF;
//Gráfico a colocar, en transparente
  if ColocandoGrafico then
  with GraficoAcolocar do
  begin
    codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
    if codigoDelGrafico>MAX_OBJETOS_GRAFICOS then
    begin
      //Sprites
      if (posy+15>coord.y) and (posy-40<coord.y) and
      (posx+19>coord.x) and (posx-20<coord.x) then
        begin
          x:=(posx+13-coord.x)*ancho_tile;
          y:=(posy+11-coord.y)*alto_tile;
          MarcaGrafico.draw(x,y,$0);
          MarcaActorSensor.draw(x-12,y-8,$0);
          cad:=cb_sprites.Items[TraducirAIndiceSprites(codigoDelGrafico and $FF)];
          if bytebool(flagsGrafico and fgfx_espejo) then cad:=cad+'+R';
          TextoDDraw.textOut(x,y-8,cad);
        end;
    end
    else
      if GrTab.Grafico[codigoDelGrafico]<>nil then //Seguridad necesaria
      begin//Gráficos:
        x:=(posx+9-coord.x)*ancho_tile;
        y:=(posy-InfGra[codigoDelGrafico].aliny+11-coord.y)*alto_tile;
        GrTab.Grafico[codigoDelGrafico].draw(x,y,fgfx_TransparenteForzado or FlagsGrafico);
        x:=x+(ancho_tile shl 2);
        y:=y+InfGra[codigoDelGrafico].aliny*alto_tile;
        if InfGra[codigoDelGrafico].tipo=tg_techo then
          MarcaGraficoTecho.draw(x,y,fgfx_TransparenteForzado)
        else
          MarcaGrafico.draw(x,y,fgfx_TransparenteForzado);
      end;
  end;
  flip(ClientToScreen(point(0,0)));
end;

procedure TFCmundo.ScrollBarYChange(Sender: TObject);
begin
  if DibujarMapaReal then
  begin
    DibujarMapa;
    PB_MMapa.repaint;
  end;
  DibujarMapaReal:=true;
end;

procedure TFCmundo.FormPaint(Sender: TObject);
begin
  CopiarSuperficieACanvas(self.Canvas.Handle,0,0,ancho_dd,alto_dd,SuperficieRender,0,0);
end;

procedure OrdenadoRapido(var datos:array of TGrafico;nro_elementos:integer);
// TElemento=TGrafico;
  function funcionOrdinal(const elemento:TGrafico):integer;
  //Define el valor Z del grafico.
  begin
    result:=((elemento.posy) shl 9) or elemento.sub_z;
  end;
// Quick Sort
  procedure ordenar(primero,ultimo:integer);
  var i,j,central:integer;
    temp:TGrafico;
  begin
    i:=primero;j:=ultimo;
    central:=funcionOrdinal(datos[(primero+ultimo) div 2]);//encontrar elemento pivote central
    repeat
      while funcionOrdinal(datos[i])<Central do inc(i);
      while funcionOrdinal(datos[j])>Central do dec(j);
      if i<=j then
      begin
        temp:=datos[i];datos[i]:=datos[j];datos[j]:=temp;//swap
        inc(i);dec(j);
      end;
    until i>j;
    if primero<j then ordenar(primero,j);
    if i<ultimo then ordenar(i,ultimo);
  end;
begin
  Ordenar(0,nro_elementos-1);
end;

procedure TFCmundo.BorrarGrafico(x,y:integer);
var i,j,k,p_x,p_y,codigoDelGrafico:integer;
    reflejado,OcultaAlgunasCasillas:bytebool;
begin
  for k:=0 to Nr_graficos-1 do
  with Grafico[k] do
  begin
    if (posx<>x) or (posy<>y) then continue;
    codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
    if (codigoDelGrafico>MAX_OBJETOS_GRAFICOS) and (not c_sprites.checked) then continue;
    if (codigoDelGrafico>MAX_OBJETOS_GRAFICOS) or
       ((InfGra[codigoDelGrafico].tipo=tg_techo) and (c_techos.checked)) or
       ((InfGra[codigoDelGrafico].tipo=tg_normal) and (c_normales.checked)) or
       ((InfGra[codigoDelGrafico].tipo>=tg_piso) and (c_gterreno.checked)) then
    begin
      if cb_borrar.Checked then
        case MessageDlg('¿Desea borrar el gráfico "'+nomgra[codigoDelGrafico]+'"?',mtConfirmation,mbYesNoCancel,0) of
          mrCancel:exit;
          mrNo:continue;
        end;
      //Trabajar con el elemento a ser borrado:
      //Modificar mapa de tiles:
      if codigoDelGrafico<=MAX_OBJETOS_GRAFICOS then
        with InfGra[codigoDelGrafico] do
        begin
          dec(x,4);
          dec(y,aliny);
          reflejado:=byteBool(flagsGrafico and fgfx_Espejo);
          OcultaAlgunasCasillas:=(flagsGrafico and (fgfx_Levitacion or fgfx_Ilusion or fgfx_TransparenteNatural))=0;
          for i:=0 to 7 do
            for j:=0 to 7 do
            begin
              if reflejado then
                p_x:=x+8-i
              else
                p_x:=x+i;
              p_y:=y+j;
              if enlimites(p_x,p_y) then
                if bytebool(casillaOcupada[j] and mascarB[i]) then
                  MapaTiles[p_x,P_y]:=MapaTiles[p_x,p_y] xor ft_Ocupado;
              if OcultaAlgunasCasillas then
              if (tipo>=tg_piso) then
              begin
                if enlimites_MenosFronteras(p_x,p_y) then
                  if bytebool(casillaOculta[j] and mascarB[i]) then
                    MapaTiles[p_x,P_y]:=MapaTiles[p_x,p_y] xor ft_Nodibujar;
              end;
            end;
        end;//with
      dec(Nr_graficos);
      Grafico[k]:=Grafico[Nr_graficos];
      OrdenadoRapido(grafico,Nr_graficos);
      exit;
    end;
  end;
end;

function TFCmundo.DeterminarAutoGraficoPorTerreno(terreno:integer):integer;
begin
  randomize;
  case terreno of
    4,7..9:result:=random(10);
    12:result:=8;
    1,2:result:=random(2)*2;
    5,6:result:=120;
    else
      result:=cd_nulo;
  end;
end;

procedure TFCmundo.ColocarGrafico(x,y,codigoFlagsDelGrafico:integer;reflejado:boolean);
var i,j,p_x,p_y,codigo_del_Grafico:integer;
    OcultaAlgunasCasillas:bytebool;
  procedure AgregarElGraficoALaLista(Valor_SubZ:byte);
  begin
    with Grafico[Nr_graficos] do
    begin
      codigoFlags:=codigoFlagsDelGrafico;
      posx:=x;
      posy:=y;
      flagsGrafico:=$0;
      if reflejado then
        flagsGrafico:=flagsGrafico or fgfx_Espejo;
      if cb_levitacion.Checked then
        flagsGrafico:=flagsGrafico or fgfx_Levitacion;
      if cb_Ilusion.Checked then
        flagsGrafico:=flagsGrafico or fgfx_Ilusion;
      if cb_transparente.Checked then
        flagsGrafico:=flagsGrafico or fgfx_TransparenteNatural;
      if cb_sensible_flags.Checked then
      begin
        flagsGrafico:=flagsGrafico or fgfx_SensibleAFlags;
        if cb_inverso.Checked then
          codigoFlags:=codigoFlags or MskFlagInverso;
        codigoFlags:=codigoFlags or ((cb_flag_grafico.itemindex and $1F) shl DzSensibilidadFlags);
      end;
      sub_z:=Valor_SubZ;
      OcultaAlgunasCasillas:=(flagsGrafico and (fgfx_Levitacion or fgfx_Ilusion or fgfx_TransparenteNatural))=0;
    end;
    inc(Nr_graficos);
    OrdenadoRapido(grafico,Nr_graficos);
  end;
begin
  codigo_del_Grafico:=codigoFlagsDelGrafico and MskCodigoGrafico;
  if enLimites(x,y) then
  if Nr_Graficos<=max_Graficos then
  if codigo_del_Grafico>MAX_OBJETOS_GRAFICOS then
    AgregarElGraficoALaLista(255)//sprite.
  else
    if GrTab.grafico[codigo_del_Grafico]<>nil then
    begin
      AgregarElGraficoALaLista(InfGra[codigo_del_Grafico].sub_valorZ);
      //Modificar mapa de tiles:
      with InfGra[codigo_del_Grafico] do
      begin
        dec(x,4);
        dec(y,aliny);
        for i:=0 to 7 do
          for j:=0 to 7 do
          begin
            if reflejado then
              p_x:=x+8-i
            else
              p_x:=x+i;
            p_y:=y+j;
            if enlimites(p_x,p_y) then
              if bytebool(casillaOcupada[j] and mascarB[i]) then
                MapaTiles[p_x,P_y]:=MapaTiles[p_x,p_y] xor ft_Ocupado;
            if OcultaAlgunasCasillas then
            if tipo>=tg_piso then
            begin
              if enlimites_MenosFronteras(p_x,p_y) then
                if bytebool(casillaOculta[j] and mascarB[i]) then
                  MapaTiles[p_x,P_y]:=MapaTiles[p_x,p_y] xor ft_Nodibujar;
            end;
          end;
      end;//with
    end;
end;

procedure TFCmundo.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var codg:integer;
    AgregarEfectoEspejo:boolean;
begin
  if (x<ancho_dd) and (y<alto_dd) then
  begin
    if [ssRight]=shift then
    begin
      anteriorX:=x;
      anteriorY:=y;
      ScreenToTablero(x,y);
      DesTemp.TerrenoSeleccionado:=getTerreno(x,y);
    end
    else if [ssleft]=shift then
    begin
      CambiosRealizados:=true;
      if (PageControl1.ActivePage=TS_General) or (PageControl1.ActivePage=TS_Banderas) then
      begin
        ScreenToTiles(x,y);
        NroMapa_marcado:=ID_MAPA;
        posX_marcado:=x;
        posY_marcado:=y;
        ActualizarLabelPosicionGuardada
      end
      else
      if PageControl1.ActivePage=TS_terreno then
      begin
        CopiarSuperficieACanvas(PB_MMapa.canvas.handle,0,0,128,128,Pergamino_mapa,0,0);
        ScreenToTablero(x,y);
        DibujarEnMiniMapa(x,y);
        DibujandoMiniMapa:=true;
      end
      else
      if PageControl1.ActivePage=TS_graficos then
      begin
        codg:=cd_nulo;
        AgregarEfectoEspejo:=false;
        ScreenToTiles(x,y);
        if RB_codigo1_g.Checked then
          codg:=CB_graficos.ItemIndex
        else if RB_codigo2_g.Checked then
          codg:=CB_edificios.ItemIndex+INICIO_EDIFICIOS
        else if RB_muros.Checked then
          codg:=CB_modulos.ItemIndex+INICIO_MODULOS
        else if RB_riscos.Checked then
          codg:=CB_riscos.ItemIndex+INICIO_RISCOS
        else if RB_Sprites.checked then
          codg:=INICIO_SPRITES+TraducirACodigosSprites(CB_sprites.ItemIndex)
        else if RB_auto_g.Checked then
        begin
          codg:=DeterminarAutoGraficoPorTerreno(getterrenoXY(x,y));
          if random(2)=0 then AgregarEfectoEspejo:=true;
        end
        else if RB_borrar_g.checked then
        begin
          BorrarGrafico(x,y);
          x:=x shr 2;
          y:=y shr 2;
          LAbelMensaje.caption:='Gráfico borrado';
          if c_edificiosMM.checked then
          begin
            DibujarMiniMapa(rect(x-2,y-2,x+2,y+2));
            PB_MMapa.repaint;
          end;
        end;
        if codg<>cd_nulo then
        with graficoAcolocar do
        begin
          posx:=x;
          posy:=y;
          codigoFlags:=codg;
          flagsGrafico:=$0;
          if cb_reflejo.Checked xor AgregarEfectoEspejo then
            flagsGrafico:=flagsGrafico or fgfx_Espejo;
          if CB_levitacion.Checked then
            flagsGrafico:=flagsGrafico or fgfx_Levitacion;
          if cb_Ilusion.Checked then
            flagsGrafico:=flagsGrafico or fgfx_Ilusion;
          if cb_transparente.checked then
            flagsGrafico:=flagsGrafico or fgfx_TransparenteNatural;
          if cb_sensible_flags.Checked then
          begin
            flagsGrafico:=flagsGrafico or fgfx_SensibleAFlags;
            if cb_inverso.Checked then
              codigoFlags:=codigoFlags or MskFlagInverso;
            codigoFlags:=codigoFlags or ((cb_flag_grafico.itemindex and $1F) shl DzSensibilidadFlags);
          end;
          //indicar que estamos por colocar un grafico
          ColocandoGrafico:=true;
        end;
        DibujarMapa;
      end
      else
      if PageControl1.ActivePage=TS_Sensor then
      begin
        ScreenToTiles(x,y);
        if C_borrar_sensor.checked then
        begin
          if BorrarSensor(x,y) then
          begin
            labelmensaje.Caption:='Sensor Borrado';
            DibujarMapa;
          end
        end
        else
          if ColocarSensor(x,y) then
          begin
            labelmensaje.Caption:='Sensor nro:'+inttostr(Nr_sensores)+' colocado en:'+
              inttostr(x)+','+inttostr(y);
            DibujarMapa;
          end
      end
      else
      if PageControl1.ActivePage=TS_Nido then
      begin
        ScreenToTiles(x,y);
        if C_borrar_Nido.checked then
        begin
          if BorrarNido(x,y) then
          begin
            labelmensaje.Caption:='Nido Borrado';
            DibujarMapa;
          end
        end
        else
          if ColocarNido(x,y) then
          begin
            labelmensaje.Caption:='Nido nro:'+inttostr(Nr_Nidos)+' colocado en:'+
              inttostr(x)+','+inttostr(y);
            DibujarMapa;
          end
      end
      else
      if PageControl1.ActivePage=TS_Comerciante then //Proximamente NPCS con textos como juego de aventura!!!
      begin
        ScreenToTiles(x,y);
        if CbBorrarComerciante.checked then
        begin
          if BorrarComerciante(x,y) then
          begin
            labelmensaje.Caption:='Comerciante Borrado';
            DibujarMapa;
          end
        end
        else
          if ColocarComerciante(x,y) then
          begin
            labelmensaje.Caption:='Comerciante nro:'+inttostr(Nr_Comerciantes)+' colocado en:'+
              inttostr(x)+','+inttostr(y);
            DibujarMapa;
          end
      end
{      if PageControl1.ActivePage=TS_NPC then //Proximamente NPCS con textos como juego de aventura!!!
      begin
        ScreenToTiles(x,y);
        if C_borrar_npc.checked then
        begin
          if Borrarnpc(x,y) then
          begin
            labelmensaje.Caption:='NPC Borrado';
            DibujarMapa;
          end
        end
        else
          if ColocarNPC(x,y) then
          begin
            labelmensaje.Caption:='NPC nro:'+inttostr(Nr_NPC)+' colocado en:'+
              inttostr(x)+','+inttostr(y);
            DibujarMapa;
          end
      end}
    end
    else if [ssleft,ssright]=shift then
    begin
      ColocandoGrafico:=false;
      DibujarMapa;
    end;
  end;
end;

procedure TFCmundo.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if DibujandoMiniMapa then
  begin
    PB_MMapa.repaint;
    DibujandoMiniMapa:=false;
  end
  else
    if PageControl1.ActivePage=TS_terreno then
    begin
      if desTemp.TerrenoSeleccionado<>cd_nulo_byte then
      begin
        cb_terreno.ItemIndex:=desTemp.TerrenoSeleccionado;
        desTemp.TerrenoSeleccionado:=cd_Nulo_byte;
      end;
    end
    else if PageControl1.ActivePage=TS_graficos then
    if colocandoGrafico then
    begin
      ScreenToTiles(x,y);
      with graficoAcolocar do
        colocarGrafico(posx,posy,codigoFlags,bytebool(flagsGrafico and fgfx_Espejo));
      ColocandoGrafico:=false;
      DibujarMapa;
      LAbelMensaje.caption:='Coordenadas:'+inttostr(x)+','+inttostr(y)+' Nro:'+inttostr(Nr_graficos);
      x:=x shr 2;
      y:=y shr 2;
      if c_edificiosMM.checked then
      begin
        DibujarMiniMapa(rect(x-2,y-2,x+2,y+2));
        PB_MMapa.repaint;
      end;
    end;
  ColocandoGrafico:=false;
end;

procedure TFCmundo.RealizarSeleccionObjeto(x,y:integer);
var terreno:integer;
begin
{  if PageControl1.ActivePage=TS_NPC then
  begin
    if cb_me_npc.Checked then
      LlenarDatosNPC(x,y)
  end
  else}
  if PageControl1.ActivePage=TS_Graficos then
  begin
    if Cb_ME_Graficos.Checked then
      LlenarDatosGrafico(x,y)
  end
  else
  if PageControl1.ActivePage=TS_Comerciante then
  begin
    if cb_me_Comerciante.Checked then
      LlenarDatosComerciante(x,y)
  end
  else
  if PageControl1.ActivePage=TS_Nido then
  begin
    if cb_me_nido.Checked then
      LlenarDatosNido(x,y)
  end
  else
  if PageControl1.ActivePage=TS_Sensor then
  begin
    if cb_me_sensor.Checked then
      LlenarDatosSensor(x,y)
  end
  else
  begin
    terreno:=getTerrenoxy(x,y);
    if (Terreno<>desTemp.terreno) then
    begin
      LabelMensaje.caption:='Terreno:'+CB_terreno.Items[Terreno];
      desTemp.terreno:=Terreno;
    end;
  end;
  desTemp.posX_t:=x;
  desTemp.posY_t:=y;
end;

procedure TFCmundo.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var deltax,deltay:integer;
begin
  if (x>=ancho_dd) or (y>=alto_dd) then
  begin
    if DibujandoMiniMapa then
    begin
      PB_MMapa.repaint;
      DibujandoMiniMapa:=false;
    end;
  end
  else
  begin
    if [ssLeft]=shift then
    begin
      if PageControl1.ActivePage=TS_terreno then
      begin
        if not DibujandoMiniMapa then
        begin
          CopiarSuperficieACanvas(PB_MMapa.canvas.handle,0,0,128,128,Pergamino_mapa,0,0);
          DibujandoMiniMapa:=true;
        end;
        ScreenToTablero(x,y);
        DibujarEnMiniMapa(x,y);
      end;
      if colocandoGrafico then
      begin
        ScreenToTiles(x,y);
        with graficoAcolocar do
        begin
          posx:=x;
          posy:=y;
        end;
        DibujarMapa;
        LAbelMensaje.caption:='Coordenadas:'+inttostr(x)+','+inttostr(y)+' Nro:'+inttostr(Nr_graficos);
      end;
    end
    else
    if [ssRight]=shift then
    begin
      desTemp.TerrenoSeleccionado:=cd_Nulo_byte;
      deltax:=(anteriorx-x)*4 div ancho_tile;
      deltay:=(anteriory-y)*4 div alto_tile;
      if deltax<>0 then
      begin
        if deltay<>0 then DibujarMapaReal:=false;//para que no dibuje ahora
        ScrollBarx.position:=ScrollBarx.position+deltax;
        anteriorX:=x;
      end;
      if deltay<>0 then
      begin
        ScrollBary.position:=ScrollBary.position+deltay;
        anteriorY:=y;
      end;
    end
    else
    //Mensajes:
    begin
      ScreenToTiles(x,y);
      if ((x<>desTemp.posX_t) or (y<>desTemp.posy_t)) then
        RealizarSeleccionObjeto(x,y);
    end
  end
end;

procedure TFCmundo.RB_terrenoClick(Sender: TObject);
begin
  activeControl:=cb_terreno;
end;

procedure TFCmundo.RB_ObjetosClick(Sender: TObject);
begin
  activeControl:=cb_graficos;
end;

//{$DEFINE COMPATIBILIDAD_SENSOR}
procedure TFCmundo.recuperar(nombre:string);
var i,j,k,x,y,p_x,p_y,codigoDelGrafico:integer;
    reflejado,OcultaAlgunasCasillas:bytebool;
    f:file;
    //auxiliares temporales
    DatosMapa:TDatosMapa;
    DatosMapaExt:TDatosMapaExtendido;
begin
  assignFile(f,nombre);
  fileMode:=0;
  reset(f,1);
  blockread(f,DatosMapa,SizeOf(DatosMapa));
//Inicializar variables:
  with DatosMapa do
  begin
    Nr_Graficos:=N_Graficos;
    {$ifdef COMPATIBILIDAD_SENSOR}
    if N_sensores_old>0 then
      Nr_Sensores:=N_Sensores_old
    else
    {$endif}
      Nr_Sensores:=N_Sensores;
    Nr_nidos:=N_nidos;
//    Nr_NPC:=N_NPC;
    Nr_Comerciantes:=N_Comerciantes;
    E_nombre.text:=nombre;
    if longbool(BanderasMapa and bmEsMapaCombate) and longbool(BanderasMapa and bmEsMapaSeguro) then
      cbTipoMapa.itemIndex:=3
    else
      if longbool(BanderasMapa and bmEsMapaCombate) then
        cbTipoMapa.itemIndex:=1
      else
        if longbool(BanderasMapa and bmEsMapaSeguro) then
          cbTipoMapa.itemIndex:=2
        else
          cbTipoMapa.itemIndex:=0;
    cbTipoClimaMapa.itemIndex:=BanderasMapa shr 12;//Sincronizar con mskSonidosMapas
    E_norte.text:=inttostr(MapaNorte);
    E_sur.text:=inttostr(MapaSur);
    E_este.text:=inttostr(MapaEste);
    E_oeste.text:=inttostr(MapaOeste);
    cb_AbismoVacio.Checked:=(BanderasMapa and bmAbismoVacio)<>0;

  end;
  blockread(f,MapaCompreso,SizeOf(MapaCompreso));
//Leer con bucles:
  //Loops de contenido
//Nr_Graficos,Nr_Sensores,Nr_nidos,Nr_PNJ
  for i:=0 to nr_graficos-1 do
    blockread(f,Grafico[i],SizeOf(Grafico[i]));
  {$ifdef COMPATIBILIDAD_SENSOR}
  if (DatosMapa.N_sensores_old>0) then
  begin
    for i:=0 to Nr_Sensores-1 do
    begin
      blockread(f,Sensor[i],SizeOf(Sensor[i])-2);
      Sensor[i].dato4:=0;
      Sensor[i].flagsSensor:=0;
      blockread(f,TextoSensor[i],SizeOf(TextoSensor[i]));
    end;
    showmessage('El mapa '+nombre+' necesita ser actualizado');
  end
  else
  {$endif}
  for i:=0 to Nr_Sensores-1 do
  begin
    blockread(f,Sensor[i],SizeOf(Sensor[i]));;
    blockread(f,TextoSensor[i],SizeOf(TextoSensor[i]));
  end;
  for i:=0 to Nr_nidos-1 do
    blockread(f,Nido[i],SizeOf(Nido[i]));
  for i:=0 to Nr_comerciantes-1 do
  begin
    blockread(f,Comerciante[i],SizeOf(Comerciante[i]));
    blockread(f,TextoComerciante[i],SizeOf(TextoComerciante[i]));
  end;
{  for i:=0 to Nr_npc-1 do
    blockread(f,Npc[i],SizeOf(Npc[i]));}
  fillchar(DatosMapaExt,sizeOf(DatosMapaExt),0);
  if DatosMapa.BytesDatosExtendidos>0 then
  begin
    k:=sizeOf(DatosMapaExt);
    if k>DatosMapa.BytesDatosExtendidos then k:=DatosMapa.BytesDatosExtendidos;
    blockread(f,DatosMapaExt,k);
  end;
  with DatosMapaExt do
  begin
    E_RetornoX.text:=inttostr(posX_PalabraRetorno);
    E_RetornoY.text:=inttostr(posY_PalabraRetorno);
    E_RetornoM.text:=inttostr(mapa_PalabraRetorno);
    LosFlagsCalabozo:=FlagsCalabozo;
    LosFlagsAutoLimpiables:=FlagsAutolimpiables;
    ElComportamientoFlag:=ComportamientoFlag;
    ElDato1Flag:=Dato1Flag;
    ElDato2Flag:=Dato2Flag;
  end;
  closeFile(f);
  //Preparar mapa:
  for j:=0 to maximo do
    for i:=0 to maximo do
      mapa[i,j]:=Mapacompreso[i,j] and $1F;
  FillChar(mapaTiles,sizeOf(mapaTiles),0);
  ActualizarTableroTiles(rect(0,0,maximo,maximo));
  //En mapa de tiles
  for k:=0 to nr_graficos-1 do
  begin
    //Modificar mapa de tiles:
    codigoDelGrafico:=grafico[k].codigoFlags and MskCodigoGrafico;
    if codigoDelGrafico<=MAX_OBJETOS_GRAFICOS then
    with InfGra[codigoDelGrafico] do
    begin
      x:=grafico[k].posx-4;
      y:=grafico[k].posy-aliny;
      reflejado:=byteBool(grafico[k].flagsGrafico and fgfx_Espejo);
      OcultaAlgunasCasillas:=(grafico[k].flagsGrafico and (fgfx_Levitacion or fgfx_Ilusion or fgfx_TransparenteNatural))=0;
      for i:=0 to 7 do
        for j:=0 to 7 do
        begin
          if reflejado then
            p_x:=x+7-i
          else
            p_x:=x+i;
          p_y:=y+j;
          if enlimites(p_x,p_y) then
            if bytebool(casillaOcupada[j] and mascarB[i]) then
              MapaTiles[p_x,P_y]:=MapaTiles[p_x,p_y] xor ft_Ocupado;
          if OcultaAlgunasCasillas then
          if tipo>=tg_piso then
          begin
            if reflejado then inc(p_x);
            if enlimites_MenosFronteras(p_x,p_y) then
              if bytebool(casillaOculta[j] and mascarB[i]) then
                MapaTiles[p_x,P_y]:=MapaTiles[p_x,p_y] xor ft_Nodibujar;
          end;
        end;
    end;//with
  end;
  //Presentar en pantalla
  DibujarMapa;
  DibujarMiniMapa(rect(0,0,maximo,maximo));
  PB_MMapa.repaint;
  PageControl1.ActivePage:=TS_General;
  Caption:=TITULO_APLICACION+' ['+nombre+']';
  nombre:=extractFileName(nombre);
  Val(copy(nombre,1,length(nombre)-4),id_mapa,i);
  if i<>0 then id_mapa:=255;
  cb_flagChange(nil);
end;

procedure TFCmundo.guardar(const nombre:string);
var i,j:integer;
    f:file;
    DatosMapa:TDatosMapa;
    DatosMapaExt:TDatosMapaExtendido;
begin
  CambiosRealizados:=false;
  //Preparar para guardar
  for j:=0 to maximo do
    for i:=0 to maximo do
      Mapacompreso[i,j]:=mapa[i,j] and $1F;
  //Llenar Datos generales del mapa:
  fillchar(DatosMapa,sizeOf(DatosMapa),0);
  with DatosMapa do
  begin
    BytesDatosExtendidos:=sizeOf(TDatosMapaExtendido);
    N_Graficos:=Nr_Graficos;
    N_Sensores:=Nr_Sensores;
    N_nidos:=Nr_nidos;
    N_Comerciantes:=Nr_Comerciantes;
//    N_NPC:=Nr_NPC;
    nombre:=E_nombre.text;
    //BanderasMapa: inicializado a 0 por el anterior fillchar.
    BanderasMapa:=0;
    case cbTipoMapa.itemindex of
      1:BanderasMapa:=BanderasMapa or bmEsMapaCombate;
      2:BanderasMapa:=BanderasMapa or bmEsMapaSeguro;
      3:BanderasMapa:=BanderasMapa or bmEsMapaCombate or bmEsMapaSeguro;
    end;
    case cbTipoClimaMapa.itemindex of
      0://Bosques
        BanderasMapa:=BanderasMapa or bmSonidosBosque;
      1://Desiertos
        BanderasMapa:=BanderasMapa or bmSonidosDesierto or bmEsMapaSinLluviaNiBrumaNiNieve;
      2://Glaciares
        BanderasMapa:=BanderasMapa or bmSonidosHielos;
      3://Mazmorras
        BanderasMapa:=BanderasMapa or bmSonidosMazmorras or bmEsMapaMazmorra;
      4://InteriorMapa
        BanderasMapa:=BanderasMapa or bmSonidosInterior or bmEsMapaMazmorra;
      5://MapaOscuroConLluvia
        BanderasMapa:=BanderasMapa or bmSonidosBosqueOscuro or bmMapaOscuro;
    end;
    if cb_AbismoVacio.Checked then
      BanderasMapa:=BanderasMapa or bmAbismoVacio;
    MapaNorte:=validar(E_norte,0,255,0);
    MapaSur:=validar(E_sur,0,255,0);
    MapaEste:=validar(E_este,0,255,0);
    MapaOeste:=validar(E_oeste,0,255,0);
  end;
  //Cosas de archivo
  assignFile(f,nombre);
  reWrite(f,1);
  blockwrite(f,DatosMapa,SizeOf(DatosMapa));
  blockwrite(f,MapaCompreso,SizeOf(MapaCompreso));
  //Loops de contenido
//Nr_Graficos,Nr_Sensores,Nr_nidos,Nr_NPC:byte;
  for i:=0 to nr_graficos-1 do
    blockwrite(f,Grafico[i],SizeOf(Grafico[i]));
  for i:=0 to Nr_Sensores-1 do
  begin
    blockwrite(f,Sensor[i],SizeOf(Sensor[i]));
    blockwrite(f,TextoSensor[i],SizeOf(TextoSensor[i]));
  end;
  for i:=0 to Nr_nidos-1 do
    blockwrite(f,Nido[i],SizeOf(Nido[i]));
  for i:=0 to Nr_Comerciantes-1 do
  begin
    blockwrite(f,Comerciante[i],SizeOf(comerciante[i]));
    blockwrite(f,TextoComerciante[i],SizeOf(TextoComerciante[i]));
  end;
{  for i:=0 to Nr_npc-1 do
    blockwrite(f,Npc[i],SizeOf(Npc[i]));}
  fillchar(DatosMapaExt,sizeOf(DatosMapaExt),0);
  with DatosMapaExt do
  begin
    posX_PalabraRetorno:=validar(E_RetornoX,0,255,0);
    posY_PalabraRetorno:=validar(E_RetornoY,0,255,0);
    mapa_PalabraRetorno:=validar(E_RetornoM,0,255,0);
    FlagsCalabozo:=LosFlagsCalabozo;
    FlagsAutolimpiables:=LosFlagsAutoLimpiables;
    ComportamientoFlag:=ElComportamientoFlag;
    Dato1Flag:=ElDato1Flag;
    Dato2Flag:=ElDato2Flag;
  end;
  blockwrite(f,DatosMapaExt,DatosMapa.BytesDatosExtendidos);
  closeFile(f);
end;

//********************************************
// Borrado y colocado de elementos.
//**********************************************

//comerciantes

function TFCmundo.ColocarComerciante(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_Comerciantes>max_comerciantes then exit;
  for i:=0 to Nr_Comerciantes-1 do
    with Comerciante[i] do
      if (posx=x) and (posy=y) then exit;
  with Comerciante[Nr_Comerciantes] do
  begin
    tipo:=CmbTipoComerciante.ItemIndex;
    MonstruoComerciante:=cmbAniComerciante.ItemIndex;
    posx:=x;
    posy:=y;
    item:=DatosInicialesComercio.Artefactos[tipo];
    for i:=0 to MAX_ARTEFACTOS do
     inflacion[i]:=128;
  end;
  TextoComerciante[Nr_Comerciantes]:=EdtTextoComerciante.text;
  inc(Nr_Comerciantes);
  result:=true;
end;

function TFCmundo.BorrarComerciante(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_comerciantes<=0 then exit;
  for i:=0 to Nr_comerciantes-1 do
  with Comerciante[i] do
    if (posx=x) and (posy=y) then
    begin
      dec(Nr_comerciantes);
      Comerciante[i]:=Comerciante[Nr_comerciantes];
      TextoComerciante[i]:=TextoComerciante[Nr_comerciantes];
      result:=true;
      exit;
    end;
end;

// npc
{
function TFCmundo.Borrarnpc(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_NPC<=0 then exit;
  for i:=0 to Nr_NPC-1 do
  with NPC[i] do
    if (posx=x) and (posy=y) then
    begin
      dec(Nr_NPC);
      NPC[i]:=NPC[Nr_NPC];
      result:=true;
      exit;
    end;
end;

function TFCmundo.ColocarNPC(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_NPC>max_npc then exit;
  for i:=0 to Nr_NPC-1 do
  with NPC[i] do
    if (posx=x) and (posy=y) then exit;
  with NPC[Nr_NPC] do
  begin
    tipo:=CB_tipo_npc.ItemIndex;
    posx:=x;
    posy:=y;
    dato1:=validar(e_dato1_npc.text,0,255,0);
    texto:=e_texto_npc.text;
    //items es llenado al momento de iniciar el servidor.
  end;
  inc(Nr_NPC);
  result:=true;
end;
}
// Sensores
function TFCmundo.BorrarSensor(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_Sensores<=0 then exit;
  for i:=0 to Nr_Sensores-1 do
  with Sensor[i] do
    if (posx=x) and (posy=y) then
    begin
      dec(Nr_Sensores);
      Sensor[i]:=Sensor[Nr_Sensores];
      TextoSensor[i]:=TextoSensor[Nr_Sensores];
      result:=true;
      exit;
    end;
end;

function TFCmundo.ColocarSensor(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_Sensores>max_Sensores then exit;
  for i:=0 to Nr_Sensores-1 do
  with Sensor[i] do
    if (posx=x) and (posy=y) then exit;
  with Sensor[Nr_Sensores] do
  begin
    tipo:=TTipoSensor(CB_tipo_Sensor.ItemIndex);
    posx:=x;
    posy:=y;
    llave1:=CmbObjetoLlave.ItemIndex;
    llave2:=validar(e_llave2_Sensor,0,255,0);
    dato1:=validar(e_dato1_Sensor,0,255,0);
    dato2:=validar(e_dato2_Sensor,0,255,0);
    dato3:=validar(e_dato3_Sensor,0,255,0);
    dato4:=validar(e_dato4_Sensor,0,255,0);
    flagsSensor:=0;
    if c_consumirLlave.Checked then flagsSensor:=flagsSensor or fs_consumirLlave;
    if c_soloClan.Checked then flagsSensor:=flagsSensor or fs_soloClan;
    if c_soloFantasma.Checked then flagsSensor:=flagsSensor or fs_soloFantasma;
    if c_soloAprendiz.Checked then flagsSensor:=flagsSensor or fs_soloAprendiz;
    if c_parteDelCastillo.Checked then flagsSensor:=flagsSensor or fs_parteDelCastillo;
    if c_repeler.Checked then flagsSensor:=flagsSensor or fs_RepelerAvatar;
    textoSensor[Nr_Sensores]:=e_texto_Sensor.text;{mismo indice que Sensor[]}
    //items es llenado al momento de iniciar el servidor.
  end;
  inc(Nr_Sensores);
  result:=true;
end;

function TFCmundo.ColocarNido(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_Nidos>max_nidos then exit;
  for i:=0 to Nr_nidos-1 do
  with Nido[i] do
    if (posx=x) and (posy=y) then exit;
  with Nido[Nr_Nidos] do
  begin
    tipo:=CB_tipo_nido.ItemIndex+Inicio_tipo_monstruos;
    posx:=x;
    posy:=y;
    cantidad:=validar(e_dato1_nido,1,60,1);
    //items es llenado al momento de iniciar el servidor.
  end;
  inc(Nr_Nidos);
  result:=true;
end;

function TFCmundo.BorrarNido(x,y:integer):boolean;
var i:integer;
begin
  result:=false;
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  if Nr_Nidos<=0 then exit;
  for i:=0 to Nr_Nidos-1 do
  with Nido[i] do
    if (posx=x) and (posy=y) then
    begin
      dec(Nr_Nidos);
      Nido[i]:=Nido[Nr_Nidos];
      result:=true;
      exit;
    end;
end;

procedure TFCmundo.LlenarDatosNido(x,y:integer);
var i:integer;
begin
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  for i:=0 to Nr_Nidos-1 do
  with Nido[i] do
    if (posx=x) and (posy=y) then
    begin
      cb_tipo_nido.ItemIndex:=tipo-Inicio_tipo_monstruos;
      e_dato1_nido.Text:=inttostr(cantidad);
      exit
    end
end;

procedure TFCmundo.LlenarDatosSensor(x,y:integer);
var i:integer;
begin
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  for i:=0 to Nr_sensores-1 do
  with sensor[i] do
    if (posx=x) and (posy=y) then
    begin
      cb_tipo_sensor.ItemIndex:=Integer(tipo);
      e_texto_sensor.text:=textoSensor[i];//mismo indice que sensor[]
      e_llave2_sensor.Text:=inttostr(llave2);
      e_dato1_sensor.Text:=inttostr(dato1);
      e_dato2_sensor.Text:=inttostr(dato2);
      e_dato3_sensor.Text:=inttostr(dato3);
      e_dato4_sensor.Text:=inttostr(dato4);
      c_consumirLlave.Checked:=(flagsSensor and fs_consumirLlave)<>0;
      c_soloClan.Checked:=(flagsSensor and fs_soloClan)<>0;
      c_soloFantasma.Checked:=(flagsSensor and fs_soloFantasma)<>0;
      c_soloAprendiz.Checked:=(flagsSensor and fs_soloAprendiz)<>0;
      c_parteDelCastillo.Checked:=(flagsSensor and fs_parteDelCastillo)<>0;
      c_repeler.Checked:=(flagsSensor and fs_repelerAvatar)<>0;
      //Avisar que cambio para interfaz:
      cmbObjetoLlave.ItemIndex:=llave1;
      cb_tipo_sensorChange(nil);
      exit
    end
end;

procedure TFCmundo.LlenarDatosComerciante(x,y:integer);
var i:integer;
begin
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  for i:=0 to Nr_comerciantes-1 do
  with Comerciante[i] do
    if (posx=x) and (posy=y) then
    begin
      cmbTipoComerciante.ItemIndex:=tipo;
      cmbAniComerciante.ItemIndex:=MonstruoComerciante;
      EdtTextoComerciante.text:=textoComerciante[i];
      exit
    end
end;
{
procedure TFCmundo.LlenarDatosNPC(x,y:integer);
var i:integer;
begin
  if (x<0) or (x>255) or (y<0) or (y>255) then exit;
  for i:=0 to Nr_NPC-1 do
  with NPC[i] do
    if (posx=x) and (posy=y) then
    begin
      cb_tipo_npc.ItemIndex:=tipo;
      e_texto_npc.text:=texto;
      e_dato1_npc.Text:=inttostr(dato1);
      exit
    end
end;
}

procedure TFCmundo.c_GTerrenoClick(Sender: TObject);
begin
  DibujarMapa;
end;

procedure TFCmundo.pageControl1Change(Sender: TObject);
begin
  if Pagecontrol1.activePage=TS_Terreno then
    activeControl:=CB_terreno
  else
    if Pagecontrol1.activePage=TS_graficos then
    begin
      if RB_codigo1_g.Checked then
        activeControl:=CB_modulos
      else
        activeControl:=CB_edificios
    end;
  PB_Mmapa.repaint;
end;

procedure TFCmundo.RB_codigo1_GClick(Sender: TObject);
begin
  ActiveControl:=cb_graficos;
end;

procedure TFCmundo.RB_codigo2_GClick(Sender: TObject);
begin
  ActiveControl:=cb_edificios;
end;

procedure TFCmundo.CB_graficosClick(Sender: TObject);
begin
  RB_codigo1_g.Checked:=true;
end;

procedure TFCmundo.Cb_edificiosClick(Sender: TObject);
begin
  RB_codigo2_g.Checked:=true;
end;

procedure TFCmundo.c_edificiosMMClick(Sender: TObject);
begin
  DibujarMiniMapa(rect(0,0,maximo,maximo));
  PB_MMapa.repaint;
end;

procedure TFCmundo.RB_riscosClick(Sender: TObject);
begin
  ActiveControl:=cb_riscos;
end;

procedure TFCmundo.CB_riscosClick(Sender: TObject);
begin
  RB_riscos.Checked:=true;
end;

procedure TFCmundo.RB_murosClick(Sender: TObject);
begin
  ActiveControl:=cb_modulos;
end;

procedure TFCmundo.cb_modulosClick(Sender: TObject);
begin
  RB_muros.Checked:=true;
end;

procedure TFCmundo.FormResize(Sender: TObject);
begin
  if (screen.Width-left)<800 then left:=screen.Width-800;
  if (screen.height-top)<600 then top:=screen.height-600;
  if width<800 then width:=800;
  if height<600 then height:=600;
end;

procedure TFCmundo.RB_spritesClick(Sender: TObject);
begin
  ActiveControl:=cb_sprites;
end;

procedure TFCmundo.cb_spritesClick(Sender: TObject);
begin
  RB_sprites.Checked:=true;
end;

procedure TFCmundo.ActualizarLabelPosicionGuardada;
begin
  Lb_PosicionGuardada.caption:='Mapa '+inttostr(NroMapa_marcado)+': '+
    inttostr(posX_marcado)+','+inttostr(posY_marcado)
end;

procedure TFCmundo.Btn_AsignarPosClick(Sender: TObject);
begin
  e_dato1_sensor.text:=IntToStr(NroMapa_marcado);
  e_dato2_sensor.text:=IntToStr(posX_marcado);
  e_dato3_sensor.text:=IntToStr(posY_marcado);
end;

procedure TFCmundo.Button1Click(Sender: TObject);
var i,n:integer;
    t:TDateTime;
    FXAmbiental:TFXAmbiental;
    FxNocturno:TFxNocturno;
begin
  FXAmbiental:=TFxAmbiental(cbFx.itemindex);
  if FXAmbiental>fxNiebla then
  begin
    FxNocturno:=TFxNocturno(Integer(FXAmbiental)-1-integer(fxniebla));
    FXAmbiental:=fxNoche;
  end
  else
    FxNocturno:=FxNHumano;
  if FXAmbiental=FxANinguno then
  begin
    DibujarMapa;
    exit;
  end;
  if cb_testE.Checked then
  begin
    DibujarMapa;
    n:=1999
  end
  else
    n:=0;
  t:=now;
  case FXAmbiental of
    fxlluvia:
      for i:=0 to n do
        AplicarLluviaAmbiental(i,255);
    fxnieve:
      for i:=0 to n do
        AplicarNieveAmbiental(i,255);
  else
    for i:=0 to n do
      AplicarFXAmbiental(255,FXAmbiental,FxNocturno);
  end;
  t:=now-t;
  flip(ClientToScreen(point(0,0)));
  if cb_testE.Checked then
    showmessage('Tiempo: '+floattostr(round(t*86400*100)/100));
end;

procedure TFCmundo.ReflejarMapa(horizontal:boolean);
var x,y:integer;
    Mapa2:TMapaCompreso;
begin
  for x:=0 to maximo do
    for y:=0 to maximo do
      Mapa2[x,y]:=Mapa[x,y];
  if horizontal then
    for x:=0 to maximo do
      for y:=0 to maximo do
        Mapa[x,y]:=(Mapa[x,y] and $E0) or (Mapa2[maximo-x,y] and $1F)
  else
    for x:=0 to maximo do
      for y:=0 to maximo do
        Mapa[x,y]:=(Mapa[x,y] and $E0) or (Mapa2[x,maximo-y] and $1F);
  Nr_graficos:=0;
  Nr_Sensores:=0;
  Nr_comerciantes:=0;
  Nr_nidos:=0;
  Nr_NPC:=0;
  FillChar(mapaTiles,sizeOf(mapaTiles),0);
  ActualizarTableroTiles(rect(0,0,maximo,maximo));
  DibujarMapa;
  DibujarMiniMapa(rect(0,0,maximo,maximo));
  CopiarSuperficieACanvas(PB_MMapa.canvas.handle,0,0,128,128,Pergamino_mapa,0,0);
  PB_MmapaPaint(nil);
end;

procedure TFCmundo.Button2Click(Sender: TObject);
begin
  ReflejarMapa(true);
end;

procedure TFCmundo.Button3Click(Sender: TObject);
begin
  ReflejarMapa(false);
end;

procedure TFCmundo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if PageControl1.ActivePage<>TS_General then
    CambiosRealizados:=true;
  case key of
    27:begin
      ColocandoGrafico:=false;
      DibujarMapa;
    end;
  end;
end;

procedure TFCmundo.LlenarDatosGrafico(x,y:integer);
var codGrafico,i,codigoDelGrafico:integer;
begin
  if (x<0) or (x>MaxMapaAreaExt) or (y<0) or (y>MaxMapaAreaExt) then exit;
  codGrafico:=-1;
  for i:=0 to Nr_graficos-1 do
  with Grafico[i] do
  begin
    if (posx<>x) or (posy<>y) then continue;
    codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
    if (codigoDelGrafico>MAX_OBJETOS_GRAFICOS) and (not c_sprites.checked) then continue;
    if (codigoDelGrafico>MAX_OBJETOS_GRAFICOS) or
       ((InfGra[codigoDelGrafico].tipo=tg_techo) and (c_techos.checked)) or
       ((InfGra[codigoDelGrafico].tipo=tg_normal) and (c_normales.checked)) or
       ((InfGra[codigoDelGrafico].tipo>=tg_piso) and (c_gterreno.checked)) then
    begin
      codGrafico:=codigoDelGrafico;
      cb_reflejo.Checked:=bytebool(flagsGrafico and fgfx_Espejo);
      cb_transparente.Checked:=bytebool(flagsGrafico and fgfx_TransparenteNatural);
      cb_sensible_flags.Checked:=bytebool(flagsGrafico and fgfx_sensibleAFlags);
      if bytebool(flagsGrafico and fgfx_sensibleAFlags) then
      begin
        cb_inverso.Checked:=(codigoFlags and MskFlagInverso)<>0;
        cb_flag_grafico.ItemIndex:=codigoFlags shr DzSensibilidadFlags;
      end;
      cb_levitacion.Checked:=bytebool(flagsGrafico and fgfx_Levitacion);
      cb_ilusion.Checked:=bytebool(flagsGrafico and fgfx_Ilusion);
      break;
    end;
  end;
  if codGrafico<0 then exit;
  case codGrafico of
    0..INICIO_RISCOS-1://Graficos
    begin
      cb_graficos.ItemIndex:=codGrafico;
      RB_codigo1_G.Checked:=true;
    end;
    INICIO_RISCOS..INICIO_EDIFICIOS-1://Riscos
    begin
      cb_riscos.ItemIndex:=codGrafico-INICIO_RISCOS;
      RB_riscos.Checked:=true;
    end;
    INICIO_EDIFICIOS..INICIO_MODULOS-1://Edificios
    begin
      cb_edificios.ItemIndex:=codGrafico-INICIO_EDIFICIOS;
      RB_codigo2_G.Checked:=true;
    end;
    INICIO_MODULOS..MAX_OBJETOS_GRAFICOS://Módulos
    begin
      cb_modulos.ItemIndex:=codGrafico-INICIO_MODULOS;
      RB_muros.Checked:=true;
    end;
    INICIO_SPRITES..INICIO_SPRITES+$FF:
    begin
      cb_sprites.ItemIndex:=TraducirAIndiceSprites(codGrafico and $FF);
      RB_sprites.Checked:=true;
    end;
  end;
end;

procedure TFCmundo.RB_borrar_GEnter(Sender: TObject);
begin
  cb_me_graficos.checked:=false;
end;

procedure TFCmundo.Btn_AsignarPosRETClick(Sender: TObject);
begin
  e_retornoX.text:=IntToStr(posX_marcado);
  e_retornoY.text:=IntToStr(posY_marcado);
  e_retornoM.text:=IntToStr(NroMapa_marcado);
end;

procedure TFCmundo.BtnObjeto2Click(Sender: TObject);
begin
  e_dato2_sensor.Text:=inttostr(CmbObjetoLlave.itemindex);
end;

procedure TFCmundo.cb_tipo_sensorChange(Sender: TObject);
begin
  case ttiposensor(cb_tipo_sensor.itemindex) of
    tsCambiarObjeto:
    begin
      Btn_AsignarPos.visible:=false;
      e_dato1_sensor.Visible:=false;
      e_dato2_sensor.Visible:=true;
      e_dato3_sensor.Visible:=true;
      e_dato4_sensor.Visible:=false;
      BtnObjeto2.Visible:=true;
      Label_ds1.Caption:='';
      Label_ds2.Caption:='Objeto Obtenido:';
      Label_ds3.Caption:='Modificador:';
      label_ds4.Caption:='';
      b_se1.visible:=false;
      b_se2.visible:=false;
      b_se3.visible:=false;
      b_se4.visible:=false;
    end;
    tsFBandera,tsLBandera,tsCBandera:
    begin
      Btn_AsignarPos.visible:=false;
      e_dato1_sensor.Visible:=true;
      e_dato2_sensor.Visible:=true;
      e_dato3_sensor.Visible:=true;
      e_dato4_sensor.Visible:=true;
      BtnObjeto2.Visible:=false;
      Label_ds1.Caption:='Band. 0 a 7:';
      Label_ds2.Caption:='Band. 8 a 15:';
      label_ds3.Caption:='Band. 16 a 23:';
      label_ds4.Caption:='Band. 24 a 31:';
      b_se1.visible:=true;
      b_se2.visible:=true;
      b_se3.visible:=true;
      b_se4.visible:=true;
    end;
    tsPortal,tsResurreccion:
    begin
      Btn_AsignarPos.visible:=true;
      e_dato1_sensor.Visible:=true;
      e_dato2_sensor.Visible:=true;
      e_dato3_sensor.Visible:=true;
      e_dato4_sensor.Visible:=false;
      BtnObjeto2.Visible:=false;
      Label_ds1.Caption:='Mapa destino:';
      Label_ds2.Caption:='Posx destino:';
      Label_ds3.Caption:='Posy destino:';
      label_ds4.Caption:='';
      b_se1.visible:=false;
      b_se2.visible:=false;
      b_se3.visible:=false;
      b_se4.visible:=false;
    end;
  else
    begin
      Btn_AsignarPos.visible:=false;
      e_dato1_sensor.Visible:=false;
      e_dato2_sensor.Visible:=false;
      e_dato3_sensor.Visible:=false;
      e_dato4_sensor.Visible:=false;
      BtnObjeto2.Visible:=false;
      Label_ds1.Caption:='';
      Label_ds2.Caption:='';
      Label_ds3.Caption:='';
      label_ds4.Caption:='';
      b_se1.visible:=false;
      b_se2.visible:=false;
      b_se3.visible:=false;
      b_se4.visible:=false;
    end;
  end;
  if ttiposensor(cb_tipo_sensor.itemindex)=tsCBandera then
  begin
    c_repeler.caption:='Aumentar área activa';
    c_repeler.hint:='Para abrir fácilmente puertas y portícullis';
    c_solofantasma.Checked:=false;
    c_solofantasma.visible:=false;
    c_soloaprendiz.Checked:=false;
    c_soloaprendiz.visible:=false;
  end
  else
  begin
    c_repeler.caption:='Repeler al avatar';
    c_repeler.hint:='Mueve al avatar fuera del sensor';
    c_solofantasma.visible:=true;
    c_soloaprendiz.visible:=true;
  end;
end;

procedure TFCmundo.cb_me_nidoClick(Sender: TObject);
begin
  RealizarSeleccionObjeto(desTemp.posX_t,desTemp.posY_t);
end;

procedure TFCmundo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if CambiosRealizados then
    if MessageDlg('¿Desea descartar los cambios y salir del editor?',mtConfirmation,mbOKCancel,0)=mrCancel then
      CanClose:=false;
end;

procedure TFCmundo.Button4Click(Sender: TObject);
var i,codigoDelGrafico:integer;
begin
  for i:=0 to Nr_graficos-1 do
  begin
    codigoDelGrafico:=grafico[i].codigoflags and MskCodigoGrafico;
    if codigoDelGrafico>MAX_OBJETOS_GRAFICOS then
      Grafico[i].sub_z:=255
    else
      Grafico[i].sub_z:=InfGra[codigoDelGrafico].sub_valorZ;
  end;
  OrdenadoRapido(grafico,Nr_graficos);
  DibujarMapa;
end;

procedure TFCmundo.Button5Click(Sender: TObject);
var i:integer;
begin
  for i:=0 to Nr_comerciantes-1 do
  with comerciante[i] do
    if tipo<=MAX_TIPOS_COMERCIO then
      item:=DatosInicialesComercio.Artefactos[tipo];
end;

procedure TFCmundo.FormDestroy(Sender: TObject);
begin
  NombresCortosSensores.free;
  MarcaActorSensor.free;
  MarcaGraficoTecho.free;
  MarcaGrafico.free;
  MarcaGraficoPiso.free;
  Pergamino_Mapa:=nil;
  grTab.free;
  FinalizarDirectDraw;
end;

procedure TFCmundo.cb_sensible_flagsClick(Sender: TObject);
begin
  cb_inverso.visible:=cb_sensible_flags.Checked;
  cb_flag_grafico.visible:=cb_sensible_flags.Checked;
end;

procedure TFCmundo.cb_flagChange(Sender: TObject);
begin
  if (cb_flag.itemindex<0) or (cb_flag.itemindex>31) then exit;
  cb_efS.ItemIndex:=elComportamientoFlag[cb_flag.itemindex] and $F;
  cb_efC.ItemIndex:=(elComportamientoFlag[cb_flag.itemindex] shr 4) and $F;
  c_flag_activo.Checked:=(LosFlagsCalabozo and (1 shl cb_flag.itemindex))<>0;
  c_limpiar_flag.Checked:=(LosFlagsAutolimpiables and (1 shl cb_flag.itemindex))<>0;
  E_flag_d1.text:=intastr(elDato1Flag[cb_flag.itemindex]);
  E_flag_d2.text:=intastr(elDato2Flag[cb_flag.itemindex]);
  PB_Mmapa.repaint;
end;

procedure TFCmundo.c_limpiar_flagClick(Sender: TObject);
begin
  LosFlagsAutoLimpiables:=LosFlagsAutoLimpiables or (1 shl cb_flag.itemindex);
  if not c_limpiar_flag.Checked then
    LosFlagsAutoLimpiables:=LosFlagsAutoLimpiables xor (1 shl cb_flag.itemindex);
end;

procedure TFCmundo.c_flag_activoClick(Sender: TObject);
begin
  LosFlagsCalabozo:=LosFlagsCalabozo or (1 shl cb_flag.itemindex);
  if not c_flag_activo.Checked then
    LosFlagsCalabozo:=LosFlagsCalabozo xor (1 shl cb_flag.itemindex);
end;

procedure TFCmundo.cb_efSChange(Sender: TObject);
begin
  if (cb_flag.itemindex<0) or (cb_flag.itemindex>31) then exit;
  elComportamientoFlag[cb_flag.itemindex]:=(elComportamientoFlag[cb_flag.itemindex] and $F0) or
    (cb_efS.ItemIndex and $F);
end;

procedure TFCmundo.cb_efCChange(Sender: TObject);
begin
  if (cb_flag.itemindex<0) or (cb_flag.itemindex>31) then exit;
  elComportamientoFlag[cb_flag.itemindex]:=(elComportamientoFlag[cb_flag.itemindex] and $0F) or
    ((cb_efC.ItemIndex and $F) shl 4);
end;

procedure TFCmundo.Button6Click(Sender: TObject);
begin
  e_flag_d1.text:=IntToStr(posX_marcado);
  e_flag_d2.text:=IntToStr(posY_marcado);
end;

procedure TFCmundo.E_flag_Change(Sender: TObject);
begin
  if (cb_flag.itemindex<0) or (cb_flag.itemindex>31) then exit;
  if sender=e_flag_d1 then
    elDato1Flag[cb_flag.itemindex]:=guardarValor(E_flag_d1,0,255,0)
  else
    if sender=e_flag_d2 then
      elDato2Flag[cb_flag.itemindex]:=guardarValor(E_flag_d2,0,255,0);
end;

procedure TFCmundo.boton_flagsClick(Sender: TObject);
begin
  if sender=b_se1 then
  begin
    f_banderas.showmodal(validar(e_dato1_sensor,0,255,0),0);
    e_dato1_sensor.text:=intastr(f_banderas.banderas);
  end
  else if sender=b_se2 then
    begin
      f_banderas.showmodal(validar(e_dato2_sensor,0,255,0),8);
      e_dato2_sensor.text:=intastr(f_banderas.banderas);
    end
    else if sender=b_se3 then
      begin
        f_banderas.showmodal(validar(e_dato3_sensor,0,255,0),16);
        e_dato3_sensor.text:=intastr(f_banderas.banderas);
      end
      else if sender=b_se4 then
        begin
          f_banderas.showmodal(validar(e_dato4_sensor,0,255,0),24);
          e_dato4_sensor.text:=intastr(f_banderas.banderas);
        end;
end;

procedure TFCmundo.cb_AbismoVacioClick(Sender: TObject);
begin
  if cb_AbismoVacio.Checked then
    cb_terreno.Items[0]:='Abismo (Vacío)'
  else
    cb_terreno.Items[0]:='Abismo (Lleno)';
  cb_terreno.ItemIndex:=0;
end;

procedure TFCmundo.BtnAyudaLlaveClick(Sender: TObject);
begin
  showmessage(
    '<SIN LLAVE>'+#13+
    'Sensor activado directamente.'+#13+
    '<BANDERA DE MAPA ACTIVA>'+#13+
    'Sensor activado si la bandera en modificador está activa.'+#13+
    '<MINIMO NIVEL DE HONOR>'+#13+
    'Sensor activado por el nivel de honor del avatar.'+#13+
    '<<ESPECIAL>>'+#13+
    '0..15: Activado si el avatar tiene nivel de agresividad en 0.'+#13+
    '16..23: Activado por la clase del avatar.'+#13+
    '32..39: Activado por la raza del avatar.'+#13+
    '48..63: Activado por el nivel (x5) del avatar.'+#13+
    '64..95: Activado por las pericias del avatar.'+#13+
    '96..111: Activado por los puntos de salud (x10) del avatar.'+#13+
    '112..127: Activado por los puntos de maná (x10) del avatar.'+#13+
    '128..159: Activado por los hechizos del avatar.'+#13+
    '160..175: Activado por la fuerza (x10%) del avatar.'+#13+
    '176..191: Activado por la constitución (x10%) del avatar.'+#13+
    '192..207: Activado por la inteligencia (x10%) del avatar.'+#13+
    '208..223: Activado por la sabiduría (x10%) del avatar.'+#13+
    '224..239: Activado por la destreza (x10%) del avatar.'
    );
end;

procedure TFCmundo.GuardarMiniMapa1Click(Sender: TObject);
var mm:TjpegImage;
    temp:Tbitmap;
begin
  mm:=TJPEGImage.create;
  temp:=TBitmap.create;
  temp.PixelFormat:=pf24bit;
  temp.Width:=128;
  temp.Height:=128;
  CopiarSuperficieACanvas(temp.canvas.handle,0,0,128,128,Pergamino_mapa,0,0);
  mm.Assign(temp);
  temp.free;
  mm.CompressionQuality:=80;
  mm.SaveToFile(ExtractFilePath(application.ExeName)+'MiniMapa_'+ExtractFileName(OpenDialog.filename)+'.jpg');
  mm.free;
end;

procedure TFCmundo.MD51Click(Sender: TObject);
begin
  with OpenDialog do
    if execute then
      with (TMD5.create) do
      begin
        filename:=OpenDialog.filename;
        InputBox('MD5:','MD5:',toString());
        free;
      end;
end;

procedure TFCmundo.Button7Click(Sender: TObject);
var indiceBandera:integer;
begin
  indiceBandera:=cb_flag.ItemIndex and $1F;
  cb_flag_grafico.ItemIndex:=indiceBandera;
  cb_inverso.Checked:=false;
  indiceBandera:=1 shl indiceBandera;
  case TTipoSensor(cb_tipo_sensor.ItemIndex) of
    tsFBandera..tsCBandera:begin
      e_dato1_sensor.text:=intastr(indiceBandera and $FF);
      e_dato2_sensor.text:=intastr((indiceBandera shr 8) and $FF);
      e_dato3_sensor.text:=intastr((indiceBandera shr 16) and $FF);
      e_dato4_sensor.text:=intastr((indiceBandera shr 24) and $FF);
    end;
  end;
end;


procedure TFCmundo.Button8Click(Sender: TObject);
var cad:string;
    idObj,modificadorObj,i:byte;
begin
  idObj:=CmbObjetoLlave.ItemIndex;
  modificadorObj:=validar(e_llave2_Sensor,0,255,0);
  if (idObj<4) then
    case idObj of
      1://banderas calabozo
        cad:='La bandera del mapa #'+intastr(modificadorObj)+' tiene que estar activa';
      2://honor
        cad:='El nivel de honor del avatar debe ser mayor o igual a '+intastr(modificadorObj);
      3://banderas jugador
      begin
        cad:='Este sensor no puede ser activado';
        i:=modificadorObj and $F;
        case (modificadorObj shr 4) of
          0:cad:='Tener el nivel de agresividad en 0.';
          1:if i<=7 then
              cad:='El avatar debe ser: '+MC_Nombre_Categoria[i];
          2:if i<=7 then
              cad:='El avatar debe ser: '+infmon[i].nombre;
          3:cad:='El nivel del avatar debe ser por lo menos '+intastr(i*5);
          4:cad:='El avatar debe tener la pericia '+MC_Pericias[i];
//          5:result:=(Pericias and (1 shl (i+16)))<>0;
          6:cad:='El avatar tiene que tener por lo menos '+intastr(i*10)+' puntos de salud';
          7:cad:='El avatar tiene que tener por lo menos '+intastr(i*10)+' puntos de maná';
          8:cad:='El avatar debe conocer el hechizo '+intastr(i);
          9:cad:='El avatar debe conocer el hechizo '+intastr(i+16);
          10:cad:='El avatar debe tener por lo menos '+intastr(i*10)+'% de Fuerza';
          11:cad:='El avatar debe tener por lo menos '+intastr(i*10)+'% de Constitución';
          12:cad:='El avatar debe tener por lo menos '+intastr(i*10)+'% de Inteligencia';
          13:cad:='El avatar debe tener por lo menos '+intastr(i*10)+'% de Sabiduría';
          14:cad:='El avatar debe tener por lo menos '+intastr(i*10)+'% de Destreza';
        end;
      end;
      else
        cad:='Este sensor no necesita otra condición para ser activado.';
    end
  else
    if (modificadorObj=0) then
      cad:='Llevar equipado el artefacto: '+nombreCortoObjeto(ObjetoArtefacto(idObj,modificadorObj))
    else
      cad:='Llevar equipado el artefacto: '+nombreObjeto(ObjetoArtefacto(idObj,modificadorObj),ciVerRealmente);

  showmessage('Condición para activar este sensor:'+#13+cad);
end;

end.
