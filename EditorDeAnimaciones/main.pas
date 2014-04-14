(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls;

const MaxCuadros=19;
      MaxCuadros2=7;
      MaxDirecciones=4;//0..4=5
      MaxTamannoSimple=104;//Archivo de animación simple 20 frames
      MinTamannoSimple=44;//Archivo de animación simple 8 frames
      MaxCuadros1a=MaxCuadros2+1;
      UmbralStd=16;
      EXT_CRG='cr9';

type
  TAlinLin=record//Datos de animacion en una dirección de un monstruo con 5 ataques
      anchoMax:smallint;
      modix,modiy:byte;
      acumy:array[0..MaxCuadros] of smallint;
      ancho:array[0..MaxCuadros] of byte;
      cenx,ceny:array[0..MaxCuadros] of byte
    end;
  TAlinLin2=record//Datos de animacion en una dirección de un monstruo o personaje con 1 ataque
      anchoMax:smallint;
      modix,modiy:byte;
      acumy:array[0..MaxCuadros2] of smallint;
      ancho:array[0..MaxCuadros2] of byte;
      cenx,ceny:array[0..MaxCuadros2] of byte
    end;
  T3RGB=packed record
    b,g,r:byte;
  end;
  TLineaLin=record//Datos de animacion de una sola dirección
    AlinLin:TAlinLin;
    Resultado:Tbitmap;
    ImagenesListas:boolean;
    NroImagen,MaxImagenesListas:byte;
  end;
  Tlinea=array[0..16000] of T3rgb;
  Plinea=^Tlinea;
  TForm1 = class(TForm)
    OpenDialog: TOpenDialog;
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    LabelMensaje: TLabel;
    EditInc: TEdit;
    Label2: TLabel;
    EditBase: TEdit;
    Label3: TLabel;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    OpenDialogL: TOpenDialog;
    SaveDialogL: TSaveDialog;
    Button5: TButton;
    Label4: TLabel;
    EditNro: TEdit;
    Procesarimgenes1: TMenuItem;
    N1: TMenuItem;
    Salir1: TMenuItem;
    Bevel1: TBevel;
    ScrollBar: TScrollBar;
    Timer: TTimer;
    Button6: TButton;
    ColorDialog: TColorDialog;
    ColorTrans: TLabel;
    Pantalla: TImage;
    CB_dir: TComboBox;
    Modificaranimacin1: TMenuItem;
    Resultados1: TMenuItem;
    Crearanimacincondirecciones1: TMenuItem;
    Crearanimacinsimple1: TMenuItem;
    CB_autoColor: TCheckBox;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label1: TLabel;
    Bevel4: TBevel;
    OpenDialogA: TOpenDialog;
    Edit1: TEdit;
    Label5: TLabel;
    Button7: TButton;
    Button10: TButton;
    N2: TMenuItem;
    FondoMagenta1: TMenuItem;
    FondoNegro1: TMenuItem;
    N3: TMenuItem;
    GuardararchivoBMP1: TMenuItem;
    Button11: TButton;
    Pistas1: TMenuItem;
    Alineaciondemonstruos1: TMenuItem;
    NroFrameParado1: TMenuItem;
    cb_animacion: TComboBox;
    cb_estiloAtaque: TComboBox;
    CB_NroAtaque: TComboBox;
    Alinearparagrficoesttico1: TMenuItem;
    procedure Procesar1click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure DibujarPantalla;
    procedure ScrollBarChange(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure PantallaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Memo1Change(Sender: TObject);
    procedure ButtonActClick(Sender: TObject);
    procedure CB_dirChange(Sender: TObject);
    procedure ColorTransClick(Sender: TObject);
    procedure Crearanimacincondirecciones1Click(Sender: TObject);
    procedure Crearanimacinsimple1Click(Sender: TObject);
    procedure Modificaranimacin1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Fondo1Click(Sender: TObject);
    procedure GuardararchivoBMP1Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Alineaciondemonstruos1Click(Sender: TObject);
    procedure NroFrameParado1Click(Sender: TObject);
    procedure cb_animacionChange(Sender: TObject);
    procedure Alinearparagrficoesttico1Click(Sender: TObject);
  private
    { Private declarations }
    escalar:array[0..255] of byte;
    d:array[0..MaxDirecciones] of TLineaLin;
    Imagen:array[0..MaxCuadros] of Tbitmap;
    DirAlin:byte;//Indice de dirección de la animacion (Norte, Sur, etc.)
    ZZUmbral:integer;
    ResultadoFinal:Tbitmap;
    cuaClaves:array[0..MaxCuadros] of string[16];
    NroCuaClaves,inicioAnima,finAnima:integer;
    actualizado:boolean;
    ColTrans:T3RGB;
    nombreAR:string;
    function CargarArchivos(const filename:string):integer;
    procedure ProcesarImagenes(const nro_animaciones:integer;const filename:string);
    function ObtenerRectangulo(const ImagenSimple:Tbitmap):Trect;
    procedure CambiarAFondoMagenta(Imagenm:Tbitmap;Reescalar:boolean);
    procedure AplicarFondoNegro(Imagenm:Tbitmap);
    procedure ColocarImagen(nro:byte);
    procedure LlenarLista;
    procedure ModificarAnimaciones(nombre:string;NroDirecciones:byte;NroFramesIncluidos:byte);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses objetos;

{$R *.DFM}
const
     NegroTotal:T3RGB=(b:0;g:0;r:0);
     ColorMagenta:T3RGB=(b:$FF;g:00;r:$FF);
     ColorMagentaP=$00FF00FF;
     c_tran:T3RGB=(b:$28;g:00;r:$00);

function TForm1.CargarArchivos(const filename:string):integer;
var cntAr:integer;
    fallo:boolean;
    s:string;
    prefijo:string[255];
    NroCifras:integer;
  procedure AgregarCeros(var cadenaNumero:string;nroCifras:integer);
  begin
    while length(cadenaNumero)<nroCifras do
      cadenaNumero:='0'+cadenaNumero;
  end;
begin
  //Calcular el prefijo
  prefijo:=ExtractFileName(filename);
  prefijo:=copy(prefijo,1,length(prefijo)-5);
  //quitar todos los ceros
  NroCifras:=1;
  while (ord(prefijo[0])>0) and (prefijo[ord(prefijo[0])]='0') do
  begin
    dec(prefijo[0]);
    inc(NroCifras);
  end;

  if (length(cuaClaves[0])>1) and (NroCifras=1) then
    if (ord(prefijo[0])>0) then
    begin
      dec(prefijo[0]);
      inc(NroCifras);
    end;

  prefijo:=ExtractFilePath(filename)+prefijo;
  showmessage(prefijo);
  cntAr:=0;
  repeat
    fallo:=false;
    try
      s:=cuaClaves[cntAr];
      AgregarCeros(s,nroCifras);
      s:=s+'.bmp';
//      showmessage(prefijo+s);
      Imagen[cntAr].loadFromFile(prefijo+s);
      if Imagen[cntAr].height>254 then Imagen[cntAr].height:=254;
      if Imagen[cntAr].width>254 then Imagen[cntAr].width:=254;
      inc(cntAr);
    except
      fallo:=true;
    end;
  until (cntAr>=NroCuaClaves) or fallo;
  result:=cntAr;
  nombreAR:=prefijo+'-Resultado.';
end;

procedure AgregarArea(var Destino:Trect;const Agregado:Trect);
begin
  if Agregado.Top<Destino.Top then
    Destino.top:=Agregado.Top;
  if Agregado.Bottom>Destino.Bottom then
    Destino.Bottom:=Agregado.Bottom;
  if Agregado.Left<Destino.Left then
    Destino.Left:=Agregado.Left;
  if Agregado.Right>Destino.Right then
    Destino.Right:=Agregado.Right;
end;

procedure TForm1.AplicarFondoNegro(Imagenm:Tbitmap);
var  i,j:integer;
     linea:Plinea;
begin
  ImagenM.PixelFormat:=pf24bit;
  if not ImagenM.Empty then
    if (ImagenM.Width>0) and (ImagenM.Height>0) then
      for j:=0 to ImagenM.Height-1 do
      begin
        linea:=ImagenM.ScanLine[j];
        for i:=0 to ImagenM.Width-1 do
          if (linea[i].r=ColorMagenta.r) and (linea[i].g=ColorMagenta.g) and(linea[i].b=ColorMagenta.b) then
            linea[i]:=NegroTotal;
      end;
end;

procedure TForm1.CambiarAFondoMagenta(Imagenm:Tbitmap;Reescalar:boolean);
var  i,j:integer;
     linea:Plinea;
  function diferentorN(const color1:T3RGB):boolean;
  begin
    result:=(abs(color1.r-ColTrans.r)+abs(color1.g-ColTrans.g)+abs(color1.b-ColTrans.b))<ZZUmbral;
  end;
  procedure nuevaEscala(var color1:T3RGB);
  begin
    color1.r:=Escalar[color1.r];
    color1.g:=Escalar[color1.g];
    color1.b:=Escalar[color1.b];
  end;
begin
  ImagenM.PixelFormat:=pf24bit;
  if not ImagenM.Empty then
    if (ImagenM.Width>0) and (ImagenM.Height>0) then
      if Reescalar then
        for j:=0 to ImagenM.Height-1 do
        begin
          linea:=ImagenM.ScanLine[j];
          for i:=0 to ImagenM.Width-1 do
            if diferentorN(linea[i]) then
              linea[i]:=ColorMagenta
            else
              nuevaEscala(linea[i]);
        end
      else
        for j:=0 to ImagenM.Height-1 do
        begin
          linea:=ImagenM.ScanLine[j];
          for i:=0 to ImagenM.Width-1 do
            if diferentorN(linea[i]) then
              linea[i]:=ColorMagenta;
        end
end;

function Tform1.ObtenerRectangulo(const ImagenSimple:Tbitmap):Trect;
var ancho,alto:integer;
   function FilaTransparente(y:integer):boolean;
   var i:integer;
       linea:Plinea;
   begin
     result:=false;
     linea:=ImagenSimple.ScanLine[y];
     for i:=0 to ImagenSimple.Width-1 do
       if ((linea[i].b shl 16) or linea[i].r or (linea[i].g shl 8))<>ColorMagentaP then exit;
     result:=true;
   end;
   function ColumnaTransparente(x,margens,margeni:integer):boolean;
   var i:integer;
       linea:Plinea;
   begin
     result:=false;
     for i:=margens to margeni-1 do
     begin
       linea:=ImagenSimple.ScanLine[i];
       if ((linea[x].b shl 16) or linea[x].r or (linea[x].g shl 8))<>ColorMagentaP then exit;
     end;
     result:=true;
   end;
begin
  ancho:=ImagenSimple.Width;
  alto:=ImagenSimple.Height;
  result.top:=0;
  while FilaTransparente(result.top) and (result.top<alto) do
    inc(result.top);
  result.Bottom:=alto;
  while FilaTransparente(result.Bottom-1) and (result.Bottom>result.top) do
    dec(result.Bottom);
  result.left:=0;
  while ColumnaTransparente(result.left,result.Top,result.bottom) and (result.left<ancho) do
    inc(result.left);
  result.right:=ancho;
  while ColumnaTransparente(result.right-1,result.Top,result.bottom) and (result.right>result.left) do
    dec(result.right);
end;

procedure TForm1.ProcesarImagenes(const nro_animaciones:integer;const filename:string);
var i,altoTotal,mincx,mincy,posicionY:integer;
    Rectangulo:Trect;
    cex,cey,alto:array[0..MaxCuadros] of integer;
begin
 with d[DirAlin].AlinLin do
 begin
  if CB_AutoColor.Checked then
  begin
    i:=Imagen[0].canvas.pixels[0,0];
    ColTrans.r:=i and $FF;
    ColTrans.g:=(i shr 8) and $FF;
    ColTrans.b:=(i shr 16) and $FF;
  end;
  //Definir áreas transparentes
  for i:=0 to Nro_Animaciones-1 do
  begin
    LabelMensaje.caption:='Procesando Imagen #'+inttostr(i+1);
    LabelMensaje.update;
    CambiarAFondoMagenta(Imagen[i],not FondoNegro1.Checked);
  end;
  //Obtener coordenadas de cortado
  LabelMensaje.caption:='Determinando tamaño mínimo';
  LabelMensaje.update;
  anchomax:=0;
  mincx:=32000;
  mincy:=32000;
  for i:=0 to Nro_Animaciones-1 do
  begin
    Rectangulo:=ObtenerRectangulo(Imagen[i]);
    ancho[i]:=Rectangulo.Right-Rectangulo.left;
    if ancho[i]>anchomax then anchomax:=ancho[i];
    alto[i]:=Rectangulo.bottom-Rectangulo.top;
    cex[i]:=Rectangulo.left;
    cey[i]:=Rectangulo.top;
    if cex[i]<mincx then mincx:=cex[i];
    if cey[i]<mincy then mincy:=cey[i];
  end;
  //Sumar dimen 'y'
  altoTotal:=0;
  for i:=0 to Nro_Animaciones-1 do
  begin
    inc(altoTotal,alto[i]);
    acumy[i]:=altoTotal;
  end;
  LabelMensaje.caption:='Creando Bitmap Resultado';
  LabelMensaje.update;
  //Crear un rectángulo con los tamaños:
  with d[DirAlin] do
  begin
    Resultado.PixelFormat:=pf24bit;//24 bits de color!!
    Resultado.Height:=altoTotal;
    Resultado.Width:=anchomax;
  end;
  //Limpiar imagen para Componer resultado
  with d[DirAlin].Resultado do
  begin
    canvas.Brush.color:=ColorMagentaP;
    canvas.FillRect(rect(0,0,width,height));
  end;
  //Componer resultado
  for i:=0 to Nro_Animaciones-1 do
  begin
    if i=0 then posicionY:=0 else posicionY:=acumy[i-1];
    BitBlt(d[DirAlin].Resultado.canvas.handle,0,posicionY,anchomax,alto[i],imagen[i].canvas.handle,cex[i],cey[i],SRCCOPY);
  end;
  //Ajuste Centrados:
  for i:=0 to Nro_Animaciones-1 do
  begin
    cenx[i]:=cex[i]-mincx;
    ceny[i]:=cey[i]-mincy;
  end;
  d[DirAlin].MaxImagenesListas:=Nro_Animaciones;
  ScrollBar.max:=d[DirAlin].MaxImagenesListas-1;
  d[DirAlin].NroImagen:=0;
  d[DirAlin].ImagenesListas:=true;
  ColocarImagen(d[DirAlin].NroImagen);
 end;
end;

procedure TForm1.Procesar1click(Sender: TObject);
var NroAnimaciones:integer;
begin
  if OpenDialog.execute then
  begin
    if not actualizado then LlenarLista;
    ScrollBar.max:=0;
    d[DirAlin].ImagenesListas:=false;
    cursor:=crHourGlass;
    NroAnimaciones:=CargarArchivos(OpenDialog.filename);
    if NroAnimaciones>0 then
      ProcesarImagenes(NroAnimaciones,OpenDialog.filename);
    cursor:=crDefault;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i,j:integer;
begin
  ZZUmbral:=UmbralStd;
  //Definir escala: 8..255
  for i:=0 to 1 do
    escalar[i]:=4;
  for i:=2 to 253 do
    escalar[i]:=i+2;
  for i:=254 to 255 do
    escalar[i]:=255;
  //Sig.
  DirAlin:=0;
  ControlStyle:=ControlStyle+[csOpaque];
  Pantalla.ControlStyle:=Pantalla.ControlStyle+[csOpaque];
  Pantalla.canvas.pen.Style:=psDot;
  DibujarPantalla;
  for i:=0 to MaxCuadros do
    Imagen[i]:=Tbitmap.create;
  for j:=0 to MaxDirecciones do
    with D[j] do
    begin
      Resultado:=Tbitmap.create;
      ImagenesListas:=false;
      AlinLin.modix:=127;
      alinlin.modiy:=127;
    end;
  ResultadoFinal:=Tbitmap.create;
  ColTrans:=C_tran;
  CB_dir.ItemIndex:=0;
  CB_NroAtaque.ItemIndex:=0;
  cb_estiloAtaque.ItemIndex:=0;
  cb_animacion.ItemIndex:=0;
  caption:=caption+' '+getVersion;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var i,j:integer;
begin
  ResultadoFinal.free;
  for j:=0 to MaxDirecciones do
    with D[j] do
      Resultado.free;
  for i:=MaxCuadros downto 0 do
    Imagen[i].free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var ColTransP:integer;
begin
  if colorDialog.execute then
  begin
    ColTransP:=colorDialog.color;
    ColTrans.b:=ColTransP shr 16 and $FF;
    ColTrans.g:=ColTransP shr 8 and $FF;
    ColTrans.r:=ColTransP and $FF;
    ColorTrans.Color:=ColTransP;
    ColorTransClick(nil);
    CB_autoColor.Checked:=false;    
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if OpenDialogL.execute then
  begin
    Memo1.lines.LoadFromFile(OpenDialogL.filename);
    LlenarLista;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if SaveDialogL.execute then
    Memo1.lines.SaveToFile(SaveDialogL.filename);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Memo1.clear;
end;

procedure TForm1.Button3Click(Sender: TObject);
var i,base,incremento,maxi:integer;
begin
  base:=strtoint(Editbase.text);
  incremento:=strtoint(Editinc.text);
  Memo1.clear;
  maxi:=strtoint(EditNro.text)-1;
  if maxi>MaxCuadros then maxi:=MaxCuadros;
  for i:=0 to maxi do
    Memo1.Lines.Add(inttostr(base+incremento*i));
  LlenarLista;
end;

procedure TForm1.LlenarLista;
var i:integer;
begin
  NroCuaClaves:=memo1.lines.Count;
  for i:=0 to NroCuaClaves-1 do
  begin
    cuaClaves[i]:=Trim(memo1.lines.Strings[i]);
    if cuaClaves[i]='' then
    begin
      NroCuaClaves:=i;
      break;
    end;
  end;
  Actualizado:=true;
end;

procedure TForm1.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.DibujarPantalla;
var Origen,Destino:Trect;
begin
  if D[DirAlin].ImagenesListas then
    Pantalla.canvas.brush.color:=$00FF00FF
  else
    Pantalla.canvas.brush.color:=color;
  Pantalla.canvas.fillrect(pantalla.ClientRect);
  if D[DirAlin].ImagenesListas then
  with D[DirAlin],D[DirAlin].AlinLin do
  begin
    if NroImagen=0 then
      origen.top:=0
    else
      origen.top:=acumy[NroImagen-1];
    origen.bottom:=acumy[NroImagen];
    origen.Left:=0;
    origen.Right:=ancho[NroImagen];
    Destino:=Origen;
    Destino.top:=0;
    Destino.bottom:=origen.Bottom-origen.Top;
    Offsetrect(destino,cenx[NroImagen],ceny[NroImagen]);
    Pantalla.canvas.CopyRect(Destino,Resultado.canvas,origen);
    Pantalla.canvas.brush.color:=clWhite;
    Pantalla.canvas.moveTo(modix,0);
    Pantalla.canvas.lineTo(modix,Pantalla.Height);
    Pantalla.canvas.moveTo(0,modiy);
    Pantalla.canvas.lineTo(Pantalla.Width,modiy);
  end;
end;

procedure TForm1.ColocarImagen(nro:byte);
var tempo:byte;
begin
  tempo:=D[DirAlin].NroImagen;
  D[DirAlin].NroImagen:=nro;
  DibujarPantalla;
  Pantalla.update;
  LabelMensaje.caption:='Cuadro '+inttostr(nro);
  if ScrollBar.Position<>nro then
    ScrollBar.Position:=nro;
  D[DirAlin].NroImagen:=tempo;
end;

procedure TForm1.ScrollBarChange(Sender: TObject);
begin
  D[DirAlin].NroImagen:=ScrollBar.Position;
  ColocarImagen(D[DirAlin].NroImagen);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if Timer.Enabled then
    Button6.caption:='Animar'
  else
  begin
    Button6.caption:='Detener';
    case cb_animacion.itemindex of
      0:begin
        inicioAnima:=0;
        finAnima:=D[DirAlin].MaxImagenesListas-1;
      end;
      1,2:begin
        inicioAnima:=0;
        finAnima:=D[DirAlin].MaxImagenesListas-1;
        if finAnima>3 then finAnima:=3;
      end;
    end;
  end;
  Timer.Enabled:=not Timer.Enabled;
end;

procedure TForm1.TimerTimer(Sender: TObject);
var FrameAColocar:integer;
begin
  FrameAColocar:=D[DirAlin].NroImagen;
  if cb_animacion.itemindex=2 then
    case cb_estiloAtaque.itemindex of
      1:case FrameAColocar of
       0:FrameAColocar:=5;
       2:FrameAColocar:=7;
       else FrameAColocar:=6;
      end;
      2:case FrameAColocar of
       0:FrameAColocar:=7;
       1:FrameAColocar:=5;
       else FrameAColocar:=6;
      end;
      3:case FrameAColocar of
       0:FrameAColocar:=6;
       1:FrameAColocar:=5;
       else FrameAColocar:=7;
      end;
      else case FrameAColocar of
       0:FrameAColocar:=5;
       1:FrameAColocar:=6;
       else FrameAColocar:=7;
      end;
    end;
  if (D[DirAlin].MaxImagenesListas)>=MaxCuadros then
    FrameAColocar:=FrameAColocar+(CB_NroAtaque.ItemIndex*3);
  ColocarImagen(FrameAColocar);
  if D[DirAlin].NroImagen<finAnima then
    inc(D[DirAlin].NroImagen)
  else
    D[DirAlin].NroImagen:=inicioAnima;
end;

procedure TForm1.PantallaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  procedure IncrementarByte(var valor:byte;incremento:integer);
  var temp:integer;
  begin
    temp:=valor;
    inc(temp,incremento);
    if temp<0 then temp:=0;
    if temp>255 then temp:=255;
    valor:=temp;
  end;
begin
  if D[DirAlin].imagenesListas then
  with D[DirAlin].alinlin do
  begin
    if Button=mbLeft then
    begin
      modix:=x;
      modiy:=y;
    end
    else
    begin
      case x of
        0..85:x:=-1;
        86..171:x:=0;
        172..255:x:=1;
      end;
      case y of
        0..85:y:=-1;
        86..171:y:=0;
        172..255:y:=1;
      end;
      IncrementarByte(modix,x);
      IncrementarByte(modiy,y);
    end;
    DibujarPantalla;
    Pantalla.update;
  end;
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin
  actualizado:=false;
end;

procedure TForm1.ButtonActClick(Sender: TObject);
begin
  LlenarLista;
end;

procedure TForm1.CB_dirChange(Sender: TObject);
begin
  if timer.Enabled then Button6Click(nil);
  DirAlin:=cb_dir.ItemIndex;
  D[DirAlin].NroImagen:=4;//posparado
  ColocarImagen(D[DirAlin].NroImagen);
  DibujarPantalla;
end;

procedure TForm1.ColorTransClick(Sender: TObject);
var colt:T3RGB;
begin
  colt.r:=ColorTrans.color and $FF;
  colt.g:=(ColorTrans.color shr 8)and $FF;
  colt.b:=(ColorTrans.color shr 16)and $FF;
  LabelMensaje.caption:='Color: (R '+inttostr(colt.r)+
    ', G '+inttostr(colt.g)+', B '+inttostr(colt.b)+')'+
    '  web(Hex): #'+inttohex(colt.r,2)+inttohex(colt.g,2)+inttohex(colt.b,2);
end;

procedure TForm1.Crearanimacincondirecciones1Click(Sender: TObject);
var TodoListo:boolean;
    i,j,M_ancho,M_alto,M_posx,M_frames:integer;
    origen,destino:Trect;
    alin2:TAlinLin2;
    f1:file;
begin
  TodoListo:=true;
  for i:=0 to MaxDirecciones do
    if d[i].ImagenesListas=false then TodoListo:=false;
  if TodoListo then
  begin
  // Componer el resultado final.
  //*************************************************
    M_ancho:=0;
    M_alto:=0;
    for i:=0 to MaxDirecciones do
    begin
      inc(M_ancho,d[i].resultado.Width);
      if d[i].resultado.Height>M_alto then M_alto:=d[i].resultado.Height;
    end;

    if GuardararchivoBMP1.checked then
    begin
      //Limpiar destino:
      with ResultadoFinal do
      begin
        PixelFormat:=pf24bit;//24 bits de color!!
        Height:=1;//Limpiar!!
        Width:=M_ancho;
        Height:=M_alto;
        canvas.brush.color:=ColorMagentaP;
        canvas.fillrect(rect(0,0,width,height));
      end;
      //Copiar bitmaps:
      M_posx:=0;
      for i:=0 to MaxDirecciones do
      begin
        origen.top:=0;
        origen.Left:=0;
        origen.Right:=d[i].resultado.Width;
        origen.Bottom:=d[i].resultado.Height;
        destino:=origen;
        offsetrect(destino,M_posx,0);
        ResultadoFinal.Canvas.CopyRect(Destino,d[i].resultado.canvas,origen);
        inc(M_posx,origen.Right);
      end;
      if FondoNegro1.Checked then
        AplicarFondoNegro(ResultadoFinal);
      ResultadoFinal.SaveToFile(nombreAR+'bmp');
    end;
    M_frames:=0;
    for i:=0 to MaxDirecciones do
      if d[i].MaxImagenesListas>M_frames then M_frames:=d[i].MaxImagenesListas;
    if M_frames<=MaxCuadros1a then
    begin//Monstruos
      //Guardar a disco:
      assignFile(f1,nombreAR+EXT_CRG);
      rewrite(f1,1);
      for j:=0 to MaxDirecciones do
      begin
      //Adaptar de Alinlin a alinlin2
        with d[j],alin2 do
        begin
          anchoMax:=alinlin.anchoMax;
          modix:=alinlin.modix;
          modiy:=alinlin.modiy;
          for i:=0 to MaxCuadros2 do
          begin
            acumy[i]:=alinlin.acumy[i];
            ancho[i]:=alinlin.ancho[i];
            cenx[i]:=alinlin.cenx[i];
            ceny[i]:=alinlin.ceny[i];
          end;
        end;
        BlockWrite(f1,alin2,sizeof(alin2));
      end;
      i:=cb_estiloAtaque.itemindex;
      BlockWrite(f1,i,4);
      closefile(f1);
    end
    else
    begin//Personajes con 5 ataques
      assignFile(f1,nombreAR+EXT_CRG);
      rewrite(f1,1);
      for j:=0 to MaxDirecciones do
        Blockwrite(f1,d[j].alinlin,sizeOf(d[j].alinlin));
      i:=cb_estiloAtaque.itemindex;
      BlockWrite(f1,i,4);
      closefile(f1);
    end;
    showmessage('Animación Direccionada Completa!! ('+nombreAR+'bmp)');
  end
  else
    showmessage('No están listos todos los cuadros.');
end;

procedure TForm1.Crearanimacinsimple1Click(Sender: TObject);
var j,M_frames:integer;
    alin2:TAlinLin2;
    alinlintemp:TAlinLin;
    f1:file;
begin
  if d[DirAlin].ImagenesListas then
  begin
  // Componer el resultado final.
  //*************************************************
    if GuardararchivoBMP1.checked then
    begin
      with ResultadoFinal do
      begin
        Height:=D[DirAlin].resultado.Height;
        Width:=D[DirAlin].resultado.Width;
        PixelFormat:=pf24bit;//24 bits de color!!
        with canvas do
        begin
          brush.color:=ColorMagentaP;
          fillrect(rect(0,0,width,height));
        end;
      end;
      with D[DirAlin].resultado do
        bitblt(ResultadoFinal.canvas.handle,0,0,width,height,canvas.handle,0,0,SRCCOPY);
      if FondoNegro1.Checked then
        AplicarFondoNegro(ResultadoFinal);
      ResultadoFinal.SaveToFile(nombreAR+'bmp');
    end;
    M_frames:=d[DirAlin].MaxImagenesListas;
    if M_frames<=MaxCuadros1a then
    begin//Monstruos
      //Guardar a disco:
      assignFile(f1,nombreAR+EXT_CRG);
      rewrite(f1,1);
      //Adaptar de Alinlin a alinlin2
      with d[DirAlin],alin2 do
      begin
        anchoMax:=alinlin.anchoMax;
        modix:=alinlin.modix;
        modiy:=alinlin.modiy;
        for j:=0 to MaxCuadros2 do
        begin
          acumy[j]:=alinlin.acumy[j];
          ancho[j]:=alinlin.ancho[j];
          cenx[j]:=alinlin.cenx[j];
          ceny[j]:=alinlin.ceny[j];
        end;
      end;
      Blockwrite(f1,alin2,sizeOf(alin2));
      closefile(f1);
    end
    else
    begin//Personajes con 5 ataques
      assignFile(f1,nombreAR+EXT_CRG);
      rewrite(f1,1);
      Blockwrite(f1,alinlintemp,sizeof(alinlintemp));
      closefile(f1);
    end;
    showmessage('Animación Completa!! ('+nombreAR+'bmp)');
  end
  else
    showmessage('No están listos los cuadros.');
end;

procedure TForm1.ModificarAnimaciones(nombre:string;NroDirecciones:byte;NroFramesIncluidos:byte);
var i,j,pos_x:integer;
    alin2:TAlinLin2;
    f1:file;
    Destino,Origen:Trect;
begin
  for i:=0 to maxDirecciones do
    D[i].ImagenesListas:=false;
  try
  //Archivo Binario
    if NroFramesIncluidos<=MaxCuadros2 then
    begin//TAlinLin2, usar alin2, f2
      assignFile(f1,nombre);
      reset(f1,1);
      for i:=0 to NroDirecciones do
      begin
        Blockread(f1,alin2,sizeof(alin2));
        with D[i].alinlin do
        begin
          anchoMax:=alin2.anchoMax;
          modiy:=alin2.modiy;
          modix:=alin2.modix;
          for j:=0 to MaxCuadros2 do
          begin
            acumy[j]:=alin2.acumy[j];
            ancho[j]:=alin2.ancho[j];
            cenx[j]:=alin2.cenx[j];
            ceny[j]:=alin2.ceny[j];
          end;
        end;
      end;
      closeFile(f1);
    end
    else
    begin//TAlinLin
      assignFile(f1,nombre);
      reset(f1,1);
      for i:=0 to NroDirecciones do
        Blockread(f1,D[i].alinlin,sizeOf(D[i].alinlin));
      closeFile(f1);
    end;
  //Archivo de imágenes
  nombreAR:=copy(nombre,1,length(nombre)-3);
  nombre:=nombreAR+'bmp';
  ResultadoFinal.LoadFromFile(nombre);
  pos_x:=0;
  for i:=0 to NroDirecciones do
  with D[i] do
  begin
    with alinlin do
    begin
      resultado.pixelFormat:=pf24bit;
      resultado.width:=anchoMax;
      resultado.height:=acumy[NroFramesIncluidos];
      //Copiar Bitmap
      destino.Top:=0;
      destino.left:=0;
      destino.Right:=resultado.width;
      destino.Bottom:=resultado.height;
      origen:=destino;
      offsetRect(origen,pos_x,0);
      resultado.Canvas.CopyRect(Destino,ResultadoFinal.canvas,origen);
      inc(pos_x,anchoMax);
    end;
    NroImagen:=0;
    ScrollBar.max:=NroFramesIncluidos;
    MaxImagenesListas:=NroFramesIncluidos+1;
    ImagenesListas:=true;
  end;
  DirAlin:=0;
  cb_dir.ItemIndex:=0;
  DibujarPantalla;
  except
    showmessage('El archivo es erróneo');
  end;
end;

procedure TForm1.Modificaranimacin1Click(Sender: TObject);
var f:file;
    tamannoArchivo:integer;
    NroFramesIncluidos:byte;
    Nrodirecciones:byte;
    i:integer;
begin
  GuardararchivoBMP1.Checked:=false;
  for i:=0 to MaxDirecciones do
    d[i].ImagenesListas:=false;

  if OpenDialogA.Execute then
  begin
    assignFile(f,OpenDialogA.Filename);
    filemode:=0;
    reset(f,1);//para saber el tamaño del archivo
    tamannoArchivo:=filesize(f)-4;
    closeFile(f);

    if tamannoArchivo<=MaxTamannoSimple then
      Nrodirecciones:=0
    else
      Nrodirecciones:=MaxDirecciones;

    if Nrodirecciones=0 then
      if tamannoArchivo<=MinTamannoSimple then
        NroFramesIncluidos:=MaxCuadros2
      else
        NroFramesIncluidos:=MaxCuadros
    else
      if tamannoArchivo<=MinTamannoSimple*(MaxDirecciones+1) then
        NroFramesIncluidos:=MaxCuadros2
      else
        NroFramesIncluidos:=MaxCuadros;
    ModificarAnimaciones(OpenDialogA.Filename,nroDirecciones,NroFramesIncluidos);
  end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
var code:integer;
begin
  val(Edit1.text,ZZUmbral,code);
  if (code<>0) or (ZZUmbral<0) or (ZZUmbral>190) then
  begin
     ZZUmbral:=UmbralStd;
     Edit1.text:=inttostr(ZZUmbral);
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var i:integer;
    mostrarMensaje:boolean;
begin
  mostrarmensaje:=false;
  for i:=0 to 4 do
    if d[i].ImagenesListas then mostrarmensaje:=true;
  if mostrarmensaje then
    CanClose:=MessageDlg('¿Salir?',
       mtConfirmation, mbOKCancel, 0)=mrOK;
end;

procedure TForm1.Fondo1Click(Sender: TObject);
begin
  TmenuItem(sender).Checked:=not TmenuItem(sender).Checked;
end;

procedure TForm1.GuardararchivoBMP1Click(Sender: TObject);
begin
  Tmenuitem(Sender).checked:=not Tmenuitem(Sender).checked;
end;

procedure TForm1.Button11Click(Sender: TObject);
var s:string;
    posicion,posinicio:integer;
begin
  s:=memo1.Lines.GetText;
  memo1.clear;
  posicion:=1;
  posinicio:=1;
  while posicion<=length(s) do
  begin
    if s[posicion]=',' then
    begin
      if posicion-posinicio>0 then
        memo1.lines.add(copy(s,posinicio,posicion-posinicio));
      posinicio:=posicion+1;
    end;
    inc(posicion);
  end;
  if posicion-posinicio>0 then
    memo1.lines.add(copy(s,posinicio,posicion-posinicio));
  LlenarLista;    
end;

procedure TForm1.Alineaciondemonstruos1Click(Sender: TObject);
begin
  showmessage('Si no es posible fijar las líneas en el centro (dir. N y S), el lado izquierdo <<| deberá ser un poco más extenso');
end;

procedure TForm1.NroFrameParado1Click(Sender: TObject);
begin
  showmessage('En animaciones con dirección: El cuadro 4 siempre será el correspondiente a "parado"');
end;

procedure TForm1.cb_animacionChange(Sender: TObject);
begin
  if timer.Enabled then Button6Click(nil);
end;

procedure TForm1.Alinearparagrficoesttico1Click(Sender: TObject);
var j,M_frames:integer;
    alin2:TAlinLin2;
    f1:file;
begin
  if d[DirAlin].ImagenesListas then
  begin
  // Componer el resultado final.
  //*************************************************
    if GuardararchivoBMP1.checked then
    begin
      with ResultadoFinal do
      begin
        Height:=D[DirAlin].alinlin.acumy[0];
        Width:=D[DirAlin].resultado.Width;
        PixelFormat:=pf24bit;//24 bits de color!!
        with canvas do
        begin
          brush.color:=ColorMagentaP;
          fillrect(rect(0,0,width,height));
        end;
      end;
      with D[DirAlin].resultado do
        bitblt(ResultadoFinal.canvas.handle,0,0,width,D[DirAlin].alinlin.acumy[0],canvas.handle,0,0,SRCCOPY);
      if FondoNegro1.Checked then
        AplicarFondoNegro(ResultadoFinal);
      ResultadoFinal.SaveToFile(nombreAR+'bmp');
    end;
    M_frames:=d[DirAlin].MaxImagenesListas;
    if M_frames>=1 then
    begin//Monstruos
      //Guardar a disco:
      assignFile(f1,nombreAR+EXT_CRG);
      rewrite(f1,1);
      //Adaptar de Alinlin a alinlin2
      with d[DirAlin],alin2 do
      begin
        anchoMax:=alinlin.anchoMax;
        modix:=alinlin.modix;
        modiy:=alinlin.modiy;
        for j:=0 to MaxCuadros2 do
        begin
          if j<4 then
            acumy[j]:=0
          else
            acumy[j]:=alinlin.acumy[0];
          ancho[j]:=alinlin.ancho[0];
          cenx[j]:=alinlin.cenx[0];
          ceny[j]:=alinlin.ceny[0];
        end;

      end;
      Blockwrite(f1,alin2,sizeOf(alin2));
      closefile(f1);
    end;
    showmessage('Gráfico estático completo!! ('+nombreAR+'bmp)');
  end
  else
    showmessage('No está listo el cuadro.');
end;

end.
