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

type
  T3RGB=packed record
    b,g,r:byte;
  end;
  Tlinea=array[0..16000] of T3rgb;
  Plinea=^Tlinea;
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    SaveDialog: TSaveDialog;
    Procesarimgenes1: TMenuItem;
    N1: TMenuItem;
    Salir1: TMenuItem;
    ColorDialog: TColorDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Button2: TButton;
    ColorTrans: TLabel;
    CB_autoColor: TCheckBox;
    Pantalla: TPaintBox;
    Guardarimagenoptimizada1: TMenuItem;
    OpenDialog: TOpenDialog;
    Label1: TLabel;
    E_Umbral: TEdit;
    Herramientas1: TMenuItem;
    Pintardemagenta1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    ObtenermscaraAND1: TMenuItem;
    ObtenermscaraOR1: TMenuItem;
    N4: TMenuItem;
    Enfondonegro1: TMenuItem;
    CB_escala: TCheckBox;
    procedure AbrirArchivo(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure up1dClick(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure ColorTransClick(Sender: TObject);
    procedure Guardarimagenoptimizada1Click(Sender: TObject);
    procedure PantallaPaint(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EvaluarUmbral;
    procedure Button1Click(Sender: TObject);
    procedure Pintardemagenta1Click(Sender: TObject);
    procedure Enfondonegro1Click(Sender: TObject);
    procedure AplicarFondoNegro(Imagenm:Tbitmap);
  private
    { Private declarations }
    escalar:array[0..255] of byte;
    Imagen,IOptima:Tbitmap;
    ColTrans:T3RGB;
    optimo:Trect;
    umbral:integer;
    Optimizado:boolean;
    function ObtenerRectangulo(const ImagenSimple:Tbitmap):Trect;
    procedure Magentatronizar(Imagenm:Tbitmap);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
const
     magentor:T3RGB=(b:$FF;g:00;r:$FF);
     cFondo:T3RGB=(b:$00;g:00;r:$00);
     cFigura:T3RGB=(b:$FF;g:$FF;r:$FF);
     magentorP=$00FF00FF;
     c_tran:T3RGB=(b:$28;g:00;r:$00);


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
          if (linea[i].r=magentor.r) and (linea[i].g=magentor.g) and (linea[i].b=magentor.b) then
            linea[i]:=cFondo;
      end;
end;


procedure TForm1.Magentatronizar(Imagenm:Tbitmap);
var  i,j:integer;
     linea:Plinea;
  function diferentorN(var color1:T3RGB):boolean;
  begin
    result:=(abs(color1.r-ColTrans.r)+abs(color1.g-ColTrans.g)+abs(color1.b-ColTrans.b))<umbral;
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
      if CB_escala.Checked then
        for j:=0 to ImagenM.Height-1 do
        begin
          linea:=ImagenM.ScanLine[j];
          for i:=0 to ImagenM.Width-1 do
            if diferentorN(linea[i]) then
              linea[i]:=magentor
            else
              nuevaEscala(linea[i]);
        end
      else
        for j:=0 to ImagenM.Height-1 do
        begin
          linea:=ImagenM.ScanLine[j];
          for i:=0 to ImagenM.Width-1 do
            if diferentorN(linea[i]) then
              linea[i]:=magentor;
        end;

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
       if ((linea[i].b shl 16) or linea[i].r or (linea[i].g shl 8))<>MagentorP then exit;
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
       if ((linea[x].b shl 16) or linea[x].r or (linea[x].g shl 8))<>MagentorP then exit;
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

procedure TForm1.EvaluarUmbral;
var code:integer;
begin
  val(E_Umbral.Text,umbral,code);
  if code<>0 then umbral:=12;
end;

procedure TForm1.AbrirArchivo(Sender: TObject);
var NombreArchivo:string;
begin
  if OpenDialog.execute then
  begin
    cursor:=crHourGlass;
    NombreArchivo:=ExtractFileName(OpenDialog.filename);
    SaveDialog.filename:=OpenDialog.filename;
    Imagen.loadFromFile(OpenDialog.filename);
    Optimizado:=false;
     cursor:=crDefault;
    pantalla.repaint;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  //Definir escala: 8..255
  for i:=0 to 4 do
    escalar[i]:=8;
  for i:=5 to 250 do
    escalar[i]:=i+4;
  for i:=251 to 255 do
    escalar[i]:=255;
  //Sig.
  umbral:=16;
  Pantalla.ControlStyle:=Pantalla.ControlStyle+[csOpaque];
  Pantalla.Canvas.Brush.Color:=clBlue;
  Imagen:=Tbitmap.create;
  IOptima:=Tbitmap.create;
  ColTrans:=C_tran;
  Optimizado:=false;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  IOptima.free;
  Imagen.free;
end;

procedure TForm1.up1dClick(Sender: TObject);
var i,j:integer;
    lin:Plinea;
{  function up1df(z:byte):byte;
  var t,zf:double;
  begin
    zf:=z-127.5;
    t:=z*z*z+constante;
    t:=(t+127.5);
    if t<0 then t:=0;
    if t>255 then t:=255;
    result:=round(t);
  end;}
begin
  //Tratar IOptima
  if not optimizado then
  begin
    showmessage('Primero tienes que optimizar la imagen');
    exit;
  end;
  with Ioptima do
  begin
    for j:=0 to height-1 do
    begin
      lin:=scanline[j];
      for i:=0 to width-1 do
        if (lin[i].r=magentor.r)
          and
           (lin[i].g=magentor.g)
          and
           (lin[i].b=magentor.b)
         then
          lin[i]:=cFondo
        else
          lin[i]:=cFigura;
    end;
  end;
  Pantalla.repaint;
end;

procedure TForm1.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.ColorTransClick(Sender: TObject);
var colt:T3RGB;
begin
  colt.r:=ColorTrans.color and $FF;
  colt.g:=(ColorTrans.color shr 8)and $FF;
  colt.b:=(ColorTrans.color shr 16)and $FF;
{  LabelMensaje.caption:='Color: (R '+inttostr(colt.r)+
    ', G '+inttostr(colt.g)+', B '+inttostr(colt.b)+')'+
    '  web(Hex): #'+inttohex(colt.r,2)+inttohex(colt.g,2)+inttohex(colt.b,2);}
end;

procedure TForm1.Guardarimagenoptimizada1Click(Sender: TObject);
begin
  if SaveDialog.execute then
    IOptima.SaveToFile(SaveDialog.filename);
end;

procedure TForm1.PantallaPaint(Sender: TObject);
var imagenTemp:Tgraphic;
begin
  with pantalla do
  begin
    if Optimizado then imagenTemp:=IOptima else imagenTemp:=imagen;
    Canvas.Fillrect(rect(0,imagenTemp.height,imagenTemp.width,height));
    Canvas.Fillrect(rect(imagenTemp.width,0,Width,height));
    Canvas.Draw(0,0,imagenTemp);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
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
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var i,j:integer;
    lin:Plinea;
{  function up1df(z:byte):byte;
  var t,zf:double;
  begin
    zf:=z-127.5;
    t:=z*z*z+constante;
    t:=(t+127.5);
    if t<0 then t:=0;
    if t>255 then t:=255;
    result:=round(t);
  end;}
begin
  //Tratar IOptima
  if not optimizado then
  begin
    showmessage('Primero tienes que optimizar la imagen');
    exit;
  end;
  with Ioptima do
  begin
    for j:=0 to height-1 do
    begin
      lin:=scanline[j];
      for i:=0 to width-1 do
        if (lin[i].r=magentor.r)
        and
         (lin[i].g=magentor.g)
        and
          (lin[i].b=magentor.b)
        then
          lin[i]:=cFigura
        else
          lin[i]:=cFondo
    end;
  end;
  Pantalla.repaint;
end;

procedure TForm1.Pintardemagenta1Click(Sender: TObject);
var i:integer;
begin
  cursor:=crHourGlass;
  if CB_autoColor.Checked then
  begin
    i:=Imagen.canvas.pixels[0,0];
    ColTrans.r:=i and $FF;
    ColTrans.g:=(i shr 8) and $FF;
    ColTrans.b:=(i shr 16) and $FF;
  end;
  EvaluarUmbral;
  //Procesar
  Magentatronizar(Imagen);
  optimo:=ObtenerRectangulo(Imagen);
  if Enfondonegro1.Checked then
    AplicarFondoNegro(Imagen);
  IOptima.Width:=optimo.Right-optimo.Left;
  IOptima.Height:=optimo.bottom-optimo.top;
  IOptima.PixelFormat:=pf24bit;
  IOptima.Canvas.Draw(-optimo.left,-optimo.top,Imagen);
  Optimizado:=true;
  Pantalla.repaint;
  cursor:=crDefault;
end;

procedure TForm1.Enfondonegro1Click(Sender: TObject);
begin
  Enfondonegro1.Checked:=not Enfondonegro1.Checked;

end;

end.

