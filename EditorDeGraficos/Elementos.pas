(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit Elementos;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, Menus,Tablero;
type
  TPixelito=packed record
    r,g,b:byte
  end;
  TLinea=array[0..1] of Tpixelito;
  PLinea=^TLinea;
const
  alto_tile=16;
  ExtArc='.bmp';
  marca='X';
  Mascar:array[0..7] of byte=($01,$02,$04,$08,$10,$20,$40,$80);
  iniX=96;
  iniy=368;
  prefix:array[0..1] of char=('g','c');
  ruta='..\Laa\bin\';
  rutag='..\Laa\grf\';
  nombreConstantes='dg';
  pxNegro:TPixelito=(r:0;g:0;b:0);
  pxBlanco:TPixelito=(r:255;g:255;b:255);
  espacios23:Tcadena23='                       ';
type
  TForm1 = class(TForm)
    CBlista: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Labelx: TLabel;
    Labely: TLabel;
    Label5: TLabel;
    Casillas: TStringGrid;
    CB_guardar: TCheckBox;
    Label6: TLabel;
    ENombre: TEdit;
    Label3: TLabel;
    LabelCodigo: TLabel;
    Label4: TLabel;
    LabelNoma: TLabel;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Pantalla: TImage;
    cb_borrar: TCheckBox;
    Panel1: TPanel;
    CasOcultas: TStringGrid;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Label8: TLabel;
    Timer1: TTimer;
    Button12: TButton;
    Bevel2: TBevel;
    Bevel3: TBevel;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    RecuperarInformaciondegrficos1: TMenuItem;
    Guardarregistrodegrficos1: TMenuItem;
    N1: TMenuItem;
    Salir1: TMenuItem;
    SB_alinY: TScrollBar;
    CB_tipo: TComboBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    LB_SUBZ: TLabel;
    Bevel4: TBevel;
    BtnSZ0: TButton;
    BtnSZ1: TButton;
    BtnSubZ: TButton;
    Bevel1: TBevel;
    Bevel5: TBevel;
    rb_a11: TRadioButton;
    rb_a88: TRadioButton;
    rb_a2416: TRadioButton;
    cb_RecursoEfecto: TComboBox;
    Label7: TLabel;
    cb_DejarPasarMisiles: TCheckBox;
    Label12: TLabel;
    BtnActualizar: TButton;
    cb_PermiteAutoTransparencia: TCheckBox;
    cb_EvitarAntialisado: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure PantallaPaint;
    procedure PantallaFlicker;
    procedure CasillasKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CBlistaChange(Sender: TObject);
    procedure ENombreChange(Sender: TObject);
    procedure CBlistaEnter(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GuardarArchivoClick(Sender: TObject);
    procedure RecuperarArchivoClick(Sender: TObject);
    procedure PantallaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PantallaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PantallaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CasOcultasKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button12MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button12MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Salir1Click(Sender: TObject);
    procedure SB_alinXChange(Sender: TObject);
    procedure SB_alinYChange(Sender: TObject);
    procedure CBlistaExit(Sender: TObject);
    procedure c_MoverSombraClick(Sender: TObject);
    procedure CB_SombraChange(Sender: TObject);
    procedure BtnSZ0Click(Sender: TObject);
    procedure BtnSZ1Click(Sender: TObject);
    procedure BtnSubZClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnActualizarClick(Sender: TObject);
  private
    { Private declarations }
    Archivo_Guardado,MoverGrafica,Recuperado,DoFlick:boolean;
    posmx,posmy,posicionx,posiciony,codigo:integer;
    Imagen:TBitmap;
    Imasc:TBitmap;
    DatoGrafico:TDescriptoresGraficos;
    Nombres:TNombresGraficos;
    procedure ActualizarRegistro;
    procedure RecuperarRegistro;
    procedure CrearMascara;
    procedure ModificarSubZ(cantidad:integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
{$R *.DFM}
uses Objetos;

  function inttostrconceros(i:integer):string;
  begin
    result:=inttostr(i);
    while length(result)<3 do result:='0'+result;
  end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  MoverGrafica:=false;
  ControlStyle:=ControlStyle+[csOpaque];
  Pantalla.ControlStyle:=Pantalla.ControlStyle+[csOpaque];
  Imagen:=Tbitmap.create;
  Imasc:=Tbitmap.create;
  //Limpiar
  fillchar(DatoGrafico,sizeof(DatoGrafico),#0);
  for i:=0 to 255 do
    CBLista.Items.Add('g');
  for i:=0 to 254 do//511=255+256 está reservado
    CBLista.Items.Add('c');
  CBLista.ItemIndex:=0;
  DoFlick:=false;
  Recuperado:=false;
  Caption:=caption+' '+getVersion;
end;

procedure TForm1.CrearMascara;
var i,j:integer;
    origen,destino:Plinea;
begin
  Imasc.PixelFormat:=pf24bit;
  Imagen.PixelFormat:=pf24bit;
  IMasc.width:=Imagen.Width;
  IMasc.height:=Imagen.height;
  for j:=0 to Imagen.height-1 do
  begin
    origen:=IMagen.ScanLine[j];
    destino:=IMasc.ScanLine[j];
    for i:=0 to Imagen.Width-1 do
      if (origen[i].r+origen[i].g+origen[i].b=0) then
        destino[i]:=pxBlanco
      else
        destino[i]:=pxNegro;
  end;
end;

procedure TForm1.PantallaFlicker;
var i,j:integer;
begin
with Pantalla,canvas do
  begin
    Brush.Color:=clSilver;
    FillRect(Pantalla.clientrect);
    if DoFlick then
      brush.color:=clLime
    else
      brush.color:=clBlack;
    for j:=0 to 7 do
      for i:=0 to 7 do
      if CasOcultas.Cells[i,j]<>'' then
        fillrect(rect(iniX+i*24-12,iniY+j*16-8,iniX+i*24+12,iniY+j*16+8));
    if recuperado then
    begin
      CopyMode:=cmSrcAnd;
      draw(posicionx+iniX,posiciony+iniY,Imasc);
      CopyMode:=cmSrcPaint;
      draw(posicionx+iniX,posiciony+iniY,imagen);
    end;
    update;
  end;
end;

procedure TForm1.PantallaPaint;
var i,j:integer;
begin
with Pantalla,canvas do
  begin
    Brush.Color:=clSilver;
    FillRect(Pantalla.clientrect);

    brush.color:=clLime;
    for j:=0 to 7 do
      for i:=0 to 7 do
      if CasOcultas.Cells[i,j]<>'' then
        fillrect(rect(iniX+i*24-12,iniY+j*16-8,iniX+i*24+12,iniY+j*16+8));
    if recuperado then
    begin
      CopyMode:=cmSrcAnd;
      draw(posicionx+iniX,posiciony+iniY,Imasc);
      CopyMode:=cmSrcPaint;
      draw(posicionx+iniX,posiciony+iniY,imagen);
    end;
    copymode:=cmSrcCopy;
    for j:=0 to 7 do
      for i:=0 to 7 do
      begin
        if (i+j) mod 2=0 then
          Brush.Color:=clBlack
        else
          Brush.Color:=clwhite;
        FrameRect(rect(iniX+i*24,iniY+j*16,iniX+i*24+24,iniY+j*16+16));
      end;

    for j:=0 to 7 do
      for i:=0 to 7 do
      if Casillas.Cells[i,j]<>'' then
      begin
        Pen.Color:=clYellow;
        Moveto(iniX+i*24,iniY+j*16);
        Lineto(iniX+i*24+24,iniY+j*16+15);
        Moveto(iniX+i*24,iniY+j*16+14);
        Lineto(iniX+i*24+24,iniY+j*16-1);
        Pen.Color:=clOlive;
        Moveto(iniX+i*24,iniY+j*16+1);
        Lineto(iniX+i*24+24,iniY+j*16+16);
        Moveto(iniX+i*24,iniY+j*16+15);
        Lineto(iniX+i*24+24,iniY+j*16);
      end;
    Pen.Color:=clWhite;
    Moveto(0,iniY+SB_AlinY.position*16);
    Lineto(Pantalla.Width,iniY+SB_AlinY.position*16);
    update;
  end;
end;

procedure TForm1.CasillasKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var c:string;
begin
if (ssShift in Shift) or (key=32) then
with casillas do
begin
     c:=Cells[col,row];
     if c<>'' then Cells[col,row]:=''
     else Cells[col,row]:=marca;
     PantallaPaint;
end;
end;

function ConvValZ(cad:string):integer;
var code:integer;
begin
  val(cad,result,code);
  if code<>0 then result:=0;
  if result>8 then if result<>15 then result:=8;
  if result<0 then result:=0;
end;

procedure TForm1.ActualizarRegistro;
var i,j:integer;
begin
if CB_borrar.Checked then
begin
  CBLista.Items[codigo]:=prefix[codigo div 256]+inttostrconceros(codigo mod 256)+' '+Nombres[codigo];
  CBLista.ItemIndex:=codigo;
  Nombres[codigo]:=espacios23;
  Nombres[codigo]:='';
  DatoGrafico[codigo].posx:=0;
  DatoGrafico[codigo].posy:=0;
  DatoGrafico[codigo].posx_r:=0;
  DatoGrafico[codigo].Nousado1:=0;
  DatoGrafico[codigo].RecursoEfecto:=0;
  DatoGrafico[codigo].FlagsDesGrafico:=0;
  DatoGrafico[codigo].alinY:=4;
  DatoGrafico[codigo].tipo:=0;
  for j:=0 to 7 do
  begin
    DatoGrafico[codigo].casillaOcupada[j]:=0;
    DatoGrafico[codigo].casillaOculta[j]:=0;
  end;
end
else
begin
  Nombres[codigo]:=ENombre.text;
  CBLista.Items[codigo]:=prefix[codigo div 256]+inttostrconceros(codigo mod 256)+' '+Nombres[codigo];
  CBLista.ItemIndex:=codigo;
  DatoGrafico[codigo].posx:=posicionX;
  DatoGrafico[codigo].posx_r:=192-posicionX-imagen.width;
  DatoGrafico[codigo].posy:=posicionY;
{  DatoGrafico[codigo].SombraX:=PosicionX_sombra;
  DatoGrafico[codigo].SombraY:=PosicionY_sombra;}
  DatoGrafico[codigo].alinY:=SB_aliny.position;
  DatoGrafico[codigo].tipo:=CB_tipo.itemindex;
  DatoGrafico[codigo].recursoEfecto:=cb_RecursoEfecto.itemindex;
  with DatoGrafico[codigo] do
  begin
    FlagsDesGrafico:=0;
    if cb_DejarPasarMisiles.Checked then
      FlagsDesGrafico:=FlagsDesGrafico or dg_DejarPasarMisiles;
    if recuperado then
      FlagsDesGrafico:=FlagsDesGrafico or dg_RecuperarArchivo;
    if cb_PermiteAutoTransparencia.Checked then
      FlagsDesGrafico:=FlagsDesGrafico or dg_PermiteAutoTransparencia;
    if cb_EvitarAntialisado.Checked then
      FlagsDesGrafico:=FlagsDesGrafico or dg_EvitarAntialisado;
  end;
  for j:=0 to 7 do
  begin
    DatoGrafico[codigo].casillaOcupada[j]:=0;
    for i:=0 to 7 do
      if casillas.Cells[i,j]=marca then
       DatoGrafico[codigo].casillaOcupada[j]:=
         DatoGrafico[codigo].casillaOcupada[j] or mascar[i];
    DatoGrafico[codigo].casillaOculta[j]:=0;
    for i:=0 to 7 do
      if casOcultas.Cells[i,j]=marca then
       DatoGrafico[codigo].casillaOculta[j]:=
         DatoGrafico[codigo].casillaOculta[j] or mascar[i]
  end;
end;
end;

procedure TForm1.RecuperarRegistro;
var i,j:integer;
begin
  codigo:=CBLista.itemindex;
  LabelCodigo.caption:=inttostr(codigo);
  LabelNoma.caption:=inttostr(codigo mod 256)+extArc;
  if codigo>=256 then
    LabelNoma.caption:='C'+LabelNoma.caption;
  try
    Imagen.loadFromFile(rutag+LabelNoma.caption);
    CrearMascara;
    recuperado:=true;
  except
    recuperado:=false;
  end;
  if codigo>=256 then
    LabelCodigo.caption:=LabelCodigo.caption+' (Construcción)'
  else
    LabelCodigo.caption:=LabelCodigo.caption+' (Objeto)';
  for j:=0 to 7 do
    for i:=0 to 7 do
    begin
      if byteBool(DatoGrafico[codigo].casillaOcupada[j] and mascar[i]) then
        casillas.Cells[i,j]:=marca
      else
        casillas.Cells[i,j]:='';
      if byteBool(DatoGrafico[codigo].casillaOculta[j] and mascar[i]) then
        casOcultas.Cells[i,j]:=marca
      else
        casOcultas.Cells[i,j]:='';
    end;
  with DatoGrafico[codigo] do
  begin
    ENombre.text:=Nombres[codigo];
    posicionx:=posx;
    LabelX.Caption:=inttostr(posicionx);
    posiciony:=posy;
    LabelY.Caption:=inttostr(posiciony);
    sb_aliny.position:=alinY;
    CB_tipo.itemindex:=tipo;
    if (recursoEfecto>=cb_RecursoEfecto.Items.count) then
      recursoEfecto:=0;
    cb_RecursoEfecto.itemindex:=recursoEfecto;
    if sub_Valorz=0 then BtnSubZClick(nil);
    LB_SUBZ.caption:=inttostr(sub_Valorz);
    cb_DejarPasarMisiles.Checked:=(FlagsDesGrafico and dg_DejarPasarMisiles)<>0;
    cb_PermiteAutoTransparencia.Checked:=(FlagsDesGrafico and dg_PermiteAutoTransparencia)<>0;
    cb_EvitarAntialisado.Checked:=(FlagsDesGrafico and dg_EvitarAntialisado)<>0;
  end;
  PantallaPaint;
end;

procedure TForm1.CBlistaChange(Sender: TObject);
begin
   cb_borrar.Checked:=False;
   RecuperarRegistro;
end;

procedure TForm1.ENombreChange(Sender: TObject);
var estado:boolean;
begin
     estado:=CB_guardar.Checked;
     if estado<>(length(ENombre.text)>1) then
       CB_guardar.Checked:=not estado;
end;

procedure TForm1.CBlistaEnter(Sender: TObject);
begin
  if CB_guardar.Checked then ActualizarRegistro;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     Imasc.free;
     Imagen.free
end;

procedure TForm1.GuardarArchivoClick(Sender: TObject);
var f:file of TArchivoGraficos;
    todo:TArchivoGraficos;
begin
  if CB_guardar.Checked then ActualizarRegistro;
//  todo.checksum:=Criptico(DatoGrafico,sizeOf(DatoGrafico));
  todo.datos:=DatoGrafico;
  todo.nombres:=Nombres;
  assignfile(f,ruta+'oc.b');
  rewrite(f);
  write(f,todo);
  closefile(f);
//  DeCriptico(DatoGrafico,sizeOf(DatoGrafico));
  Archivo_Guardado:=true;
end;

procedure TForm1.RecuperarArchivoClick(Sender: TObject);
var i:integer;
    f:file of TArchivoGraficos;
    todo:TArchivoGraficos;
begin
  try
    Recuperado:=false;
    assignfile(f,ruta+'oc.b');
    filemode:=0;
    reset(f);
    read(f,todo);
    closefile(f);
    nombres:=todo.nombres;
    DatoGrafico:=todo.datos;
  {  if todo.checksum<>DeCriptico(DatoGrafico,sizeOf(DatoGrafico)) then
      showmessage('Archivo inconsistente.');}
    for i:=0 to 510 do//511 está reservado
       CBLista.Items[i]:=prefix[i div 256]+inttostrconceros(i mod 256)+' '+Nombres[i];
    CBLista.itemindex:=0;
    RecuperarRegistro;
  except
    Archivo_Guardado:=true;
    showmessage('Este programa debe estar ubicado en la carpeta "Editores"');
    close;
  end;
end;

procedure TForm1.PantallaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl:=Casillas;
  if recuperado then
  begin
    MoverGrafica:=true;
    posmx:=x;
    posmy:=y;
  end;
end;

procedure TForm1.PantallaMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if MoverGrafica then
  begin
    PosicionX:=PosicionX+(x-posmx);
    PosicionY:=PosicionY+(y-posmy);
    Labelx.caption:=inttostr(PosicionX);
    Labely.caption:=inttostr(Posiciony);
    posmx:=x;
    posmy:=y;
    PantallaPaint;
  end;
end;

procedure TForm1.PantallaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MoverGrafica:=false;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  PosicionX:=0;
  PosicionY:=0;
  Labelx.caption:=inttostr(PosicionX);
  Labely.caption:=inttostr(Posiciony);
  PantallaPaint;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if posicionX>0 then posicionx:=posicionx+4
   else
     if posicionx<0 then posicionx:=posicionx-4;
  PosicionX:=PosicionX div 8*8;
  if posiciony>0 then posiciony:=posiciony+4
   else
     if posiciony<0 then posiciony:=posiciony-4;
  PosicionY:=PosicionY div 8*8;
  Labelx.caption:=inttostr(PosicionX);
  Labely.caption:=inttostr(Posiciony);
  PantallaPaint;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if posicionX>0 then posicionx:=posicionx+12
   else
     if posicionx<0 then posicionx:=posicionx-12;
  PosicionX:=PosicionX div 24*24;
  if posiciony>0 then posiciony:=posiciony+8
   else
     if posiciony<0 then posiciony:=posiciony-8;
  PosicionY:=PosicionY div 16*16;
  Labelx.caption:=inttostr(PosicionX);
  Labely.caption:=inttostr(Posiciony);
  PantallaPaint;
end;

procedure TForm1.Button6Click(Sender: TObject);
var i,j:integer;
begin
  for j:=0 to 7 do
    for i:=0 to 7 do
    begin
      if casillas.Cells[i,j]='' then
        casillas.Cells[i,j]:=marca
      else
        casillas.Cells[i,j]:='';
    end;
  PantallaPaint;
end;

procedure TForm1.Button7Click(Sender: TObject);
var i,j:integer;
begin
  for j:=0 to 7 do
    for i:=0 to 7 do
      casillas.Cells[i,j]:='';
  PantallaPaint;
end;

procedure TForm1.Button8Click(Sender: TObject);
var i,j:integer;
begin
  for j:=0 to 7 do
    for i:=0 to 7 do
      casillas.Cells[i,j]:=marca;
  PantallaPaint;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  PantallaPaint;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  RecuperarArchivoClick(nil);
  Archivo_Guardado:=true;
end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ActiveControl=cblista then
    activeControl:=Enombre;
  case x of
    0..19:x:=-1;
    20..39:x:=0;
    40..59:x:=1;
  end;
  case y of
    0..19:y:=-1;
    20..39:y:=0;
    40..59:y:=1;
  end;
  if rb_a88.Checked then
  begin
    x:=x*8;
    y:=y*8;
  end
  else
    if rb_a2416.Checked then
    begin
      x:=x*24;
      y:=y*16;
    end;
  inc(PosicionX,x);
  inc(PosicionY,y);
  Labelx.caption:=inttostr(PosicionX);
  Labely.caption:=inttostr(Posiciony);
  PantallaPaint;
end;

procedure TForm1.CasOcultasKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var c:string;
begin
  if (ssShift in Shift) or (key=32) then
  with casOcultas do
  begin
    c:=Cells[col,row];
    if c<>'' then Cells[col,row]:='' else Cells[col,row]:=marca;
    PantallaPaint;
  end;
end;

procedure TForm1.Button9Click(Sender: TObject);
var i,j:integer;
begin
  with casOcultas do
  for j:=0 to 7 do
    for i:=0 to 7 do
    begin
      if Cells[i,j]='' then
        Cells[i,j]:=marca
      else
        Cells[i,j]:='';
    end;
    PantallaPaint;
end;

procedure TForm1.Button10Click(Sender: TObject);
var i,j:integer;
begin
  for j:=0 to 7 do
    for i:=0 to 7 do
      casOcultas.Cells[i,j]:='';
  PantallaPaint;
end;

procedure TForm1.Button11Click(Sender: TObject);
var i,j:integer;
begin
  for j:=0 to 7 do
    for i:=0 to 7 do
      casOcultas.Cells[i,j]:=marca;
  PantallaPaint;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  doFlick:=not doFlick;
  PantallaFlicker;
end;

procedure TForm1.Button12MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer1.enabled:=true;
end;

procedure TForm1.Button12MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer1.enabled:=false;
  PantallaPaint;
end;

procedure TForm1.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.SB_alinXChange(Sender: TObject);
begin
  PantallaPaint;
end;

procedure TForm1.SB_alinYChange(Sender: TObject);
begin
  PantallaPaint;
end;

procedure TForm1.CBlistaExit(Sender: TObject);
begin
  Archivo_Guardado:=false;
end;

procedure TForm1.c_MoverSombraClick(Sender: TObject);
begin
  PantallaPaint;
end;

procedure TForm1.CB_SombraChange(Sender: TObject);
begin
  PantallaPaint;
end;

procedure TForm1.BtnSZ0Click(Sender: TObject);
begin
  ModificarSubZ(-1);
end;

procedure TForm1.BtnSZ1Click(Sender: TObject);
begin
  ModificarSubZ(1);
end;

procedure TForm1.ModificarSubZ(cantidad:integer);
var valor:integer;
begin
  valor:=DatoGrafico[codigo].sub_valorZ+cantidad;
  if valor<1 then valor:=1 else if valor>255 then valor:=255;
  DatoGrafico[codigo].sub_valorZ:=valor;
  LB_SUBZ.caption:=inttostr(valor);
end;

procedure TForm1.BtnSubZClick(Sender: TObject);
var valor:integer;
begin
  valor:=(-PosicionY div alto_tile)+DatoGrafico[codigo].alinY;
  if valor<1 then valor:=1 else if valor>255 then valor:=255;
  DatoGrafico[codigo].sub_valorZ:=valor;
  LB_SUBZ.caption:=inttostr(valor);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not Archivo_Guardado then
    CanClose:=MessageDlg('¿Descartar los cambios y Salir?',
      mtConfirmation, mbOKCancel, 0) = mrOK;
end;

procedure TForm1.BtnActualizarClick(Sender: TObject);
begin
  ActualizarRegistro;
end;

end.
