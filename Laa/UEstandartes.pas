(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit UEstandartes;

interface

uses
  Windows, SysUtils, Graphics, Classes, Forms,Controls, StdCtrls, ExtCtrls,
  GTimer, Gboton;

const
  LimitesFormulario:Trect=(left:0;top:0;right:52;bottom:125);

type
  TRGB=record
    r,g,b:byte;
  end;
  TFEstandartes = class(TForm)
    cb_disenno: TComboBox;
    sb_color: TScrollBar;
    sb_rojo: TScrollBar;
    sb_verde: TScrollBar;
    sb_azul: TScrollBar;
    EditCodigo: TEdit;
    lbColor: TLabel;
    cb_Predef: TComboBox;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cb_disennoChange(Sender: TObject);
    procedure sb_rojoChange(Sender: TObject);
    procedure sb_verdeChange(Sender: TObject);
    procedure sb_azulChange(Sender: TObject);
    procedure sb_colorChange(Sender: TObject);
    procedure cb_PredefChange(Sender: TObject);
    procedure GTimer1Timer(Sender: TObject);
    procedure GbotonAceptarClick(Sender: TObject);
    procedure paint; override;
    procedure GbotonCancelarClick(Sender: TObject);
    function execute:boolean;
    procedure EditCodigoChange(Sender: TObject);
  private
    { Private declarations }
    Pantalla:Tbitmap;
    ritmo,fColorActual:integer;
    NivelColorRGB:array[0..9] of TRGB;
    ColorElegido,DisennoElegido:byte;
    CambioDeEstandarteAceptado:boolean;
    ActualizarEdit:boolean;
    GbotonAceptar,GbotonCancelar:TGboton;
    procedure ActualizarColor;
    procedure ActualizarEstandarte;
    procedure DibujarEstandarte;
    procedure DibujarColorActual;
  public
    { Public declarations }
    Quinteto0,Quinteto1:integer;
  end;

var
  FEstandartes: TFEstandartes;

implementation
{$R *.DFM}
uses UMensajes,Graficador,graficos,objetos,juego;

procedure TFEstandartes.FormCreate(Sender: TObject);
var ft:textfile;
    cad:string;
begin
  GbotonAceptar:=TGboton.create(self);
  with GBotonAceptar do
  begin
    parent:=self;
    Left:=68;
    Top:=238;
    Width:=96;
    Height:=22;
    OnClick:=GbotonAceptarClick;
    Color:=clBronce;
    Caption:='Aceptar';
  end;
  GbotonCancelar:=TGboton.create(self);
  with GBotonCancelar do
  begin
    parent:=self;
    Left:=200;
    Top:=238;
    Width:=96;
    Height:=22;
    OnClick:=GbotonCancelarClick;
    Color:=clBronce;
    Caption:='Cancelar';
  end;
  cb_disenno.ItemIndex:=0;
  ControlStyle:=ControlStyle+[csOpaque];
  Pantalla:=Tbitmap.create;
  with pantalla do
  begin
    handleType:=bmdib;
    PixelFormat:=pf16bit;
    Width:=LimitesFormulario.right;
    height:=LimitesFormulario.bottom;
    BitBlt(canvas.handle,0,0,Width,Height,0,0,0,BLACKNESS);
  end;
  //Para preparar las tablas de colores indexados:
  ritmo:=0;
  ColorElegido:=0;
  {$I-}
  assignFile(ft,'estandartes.txt');
  reset(ft);
  while not eof(ft) do
  begin
    readln(ft,cad);
    if (cad<>'') and (pos(':',cad)>0) then
      cb_Predef.Items.Add(cad);
  end;
  closefile(ft);
  {$I+}
  //solo para leer IOresult
  if IOresult<>0 then ritmo:=0;
  Quinteto0:=0;
  Quinteto1:=0;
  canvas.brush.style:=bsSolid;
  ActualizarEdit:=true;
end;

procedure TFEstandartes.paint;
begin
  PintarFondoNegro(self);
  with canvas do
  begin
    TextOut(16,12,'DISEÑOS PREDEFINIDOS:');
    TextOut(16,76,'Diseño:');
    TextOut(16,104,'Color:');
    TextOut(16,128,'Rojo:');
    TextOut(16,152,'Verde:');
    TextOut(16,176,'Azul:');
    TextOut(16,204,'Código:');
  end;
  DibujarEstandarte;
  DibujarColorActual;
end;

procedure TFEstandartes.DibujarColorActual;
begin
  with canvas do
  begin
    brush.Style:=bsSolid;
    brush.color:=fColorActual;
    FrameRect(rect(204,128,340,194));
    FillRect(rect(207,131,337,191));
  end;
end;

procedure TFEstandartes.FormDestroy(Sender: TObject);
begin
  timer1.free;
  Pantalla.free;
end;

procedure TFEstandartes.cb_disennoChange(Sender: TObject);
begin
  disennoElegido:=cb_disenno.ItemIndex and $3;
  ActualizarColor;
end;

procedure TFEstandartes.sb_rojoChange(Sender: TObject);
begin
  NivelColorRGB[ColorElegido].r:=TScrollBar(sender).position;
  ActualizarColor;
end;

procedure TFEstandartes.sb_verdeChange(Sender: TObject);
begin
  NivelColorRGB[ColorElegido].g:=TScrollBar(sender).position;
  ActualizarColor;
end;

procedure TFEstandartes.sb_azulChange(Sender: TObject);
begin
  NivelColorRGB[ColorElegido].b:=TScrollBar(sender).position;
  ActualizarColor;
end;

procedure TFEstandartes.ActualizarColor;
    procedure PrepararQuintuple(var Quintuple:integer;base:integer);
    var i:integer;
    begin
      Quintuple:=0;
      for i:=base to base+4 do
      begin
        Quintuple:=Quintuple shl 6;
        Quintuple:=Quintuple or
          ((NivelColorRGB[i].r) shl 4) or
          ((NivelColorRGB[i].g) shl 2) or
          (NivelColorRGB[i].b);
      end;
    end;
  procedure PrepararQuintuples;
  begin
    PrepararQuintuple(Quinteto0,0);
    Quinteto0:=Quinteto0 or $40000000;
    PrepararQuintuple(Quinteto1,5);
    Quinteto1:=Quinteto1 or (DisennoElegido shl 30);
  end;
begin
  PrepararQuintuples;
  PrepararTablaColores(Quinteto0,Quinteto1);
  fColorActual:=ColorDeLaTabla((4-(ColorElegido mod 5))+((ColorElegido div 5)*5));
  if ActualizarEdit then
    EditCodigo.text:=IntToHex(Quinteto0,8)+' '+IntToHex(Quinteto1,8);

  DibujarColorActual;
end;

procedure TFEstandartes.sb_colorChange(Sender: TObject);
begin
  ColorElegido:=sb_color.position;
  sb_rojo.Position:=NivelColorRGB[ColorElegido].r;
  sb_verde.Position:=NivelColorRGB[ColorElegido].g;
  sb_azul.Position:=NivelColorRGB[ColorElegido].b;
  ActualizarColor;
  LbColor.Caption:=inttostr(ColorElegido);
end;

procedure TFEstandartes.ActualizarEstandarte;
var cad0,cad1:string;
  procedure ExtraerQuinteto(quinteto,Base:integer);
  var i:integer;
  begin
    for i:=Base+4 downto Base do
    begin
      NivelColorRGB[i].r:=(quinteto and $30) shr 4;
      NivelColorRGB[i].g:=(quinteto and $0C) shr 2;
      NivelColorRGB[i].b:=(quinteto and $03);
      quinteto:=quinteto shr 6;//recorrer lo extraido
    end;
  end;
begin
  cad0:=trim(EditCodigo.text);
  cad1:=trim(copy(cad0,pos(' ',cad0)+1,length(cad0)));
  cad0:=trim(copy(cad0,1,pos(' ',cad0)-1));
  Quinteto0:=HexToInt(cad0);
  Quinteto1:=HexToInt(cad1);
//  showmessage(inttohex(HexToInt(inttohex(quintuple0,8)),8));
  ExtraerQuinteto(Quinteto0,0);
  ExtraerQuinteto(Quinteto1,5);
  disennoElegido:=Quinteto1 shr 30;
  cb_disenno.itemIndex:=disennoElegido;
  ActualizarColor;
  sb_rojo.Position:=NivelColorRGB[ColorElegido].r;
  sb_verde.Position:=NivelColorRGB[ColorElegido].g;
  sb_azul.Position:=NivelColorRGB[ColorElegido].b;
end;

procedure TFEstandartes.cb_PredefChange(Sender: TObject);
begin
  if ActualizarEdit then
    EditCodigo.text:=copy(cb_predef.Text,pos(':',cb_predef.Text)+1,length(cb_predef.Text));
  ActualizarEstandarte;
end;

procedure TFEstandartes.GTimer1Timer(Sender: TObject);
var ancho,alto,frame,posY:integer;
    ElEstandarte:TAnimacionEfecto;
begin
  inc(ritmo);
  frame:=ritmo and $7;
  with pantalla do
    BitBlt(canvas.handle,0,0,Width,Height,0,0,0,BLACKNESS);
  ElEstandarte:=TAnimacionEfecto(animas.animacion[192{AnEstandarte en Demonios.pas}+disennoElegido]);
  if not (ElEstandarte is TAnimacionEfecto) then exit;
  ancho:=ElEstandarte.miSuperficie.width;
  if frame=0 then
  begin
    posy:=0;
    alto:=ElEstandarte.miPosicionA.acumy[frame];
  end
  else
  begin
    posY:=ElEstandarte.miPosicionA.acumy[frame-1];
    alto:=ElEstandarte.miPosicionA.acumy[frame]-posY;
  end;
  PrepararTablaColores(quinteto0,quinteto1);
  blt0TransTablaColores(pantalla,ElEstandarte.miPosicionA.cenx[frame],ElEstandarte.miPosicionA.ceny[frame],ancho,alto,ElEstandarte.miSuperficie,0,posy);
  DibujarEstandarte;
end;

procedure TFEstandartes.DibujarEstandarte;
begin
  Canvas.StretchDraw(rect(360,12,LimitesFormulario.right*2+360,LimitesFormulario.bottom*2+12),pantalla);
end;

procedure TFEstandartes.GbotonAceptarClick(Sender: TObject);
begin
  CambioDeEstandarteAceptado:=True;
  close;
end;

function TFEstandartes.execute:boolean;
begin
  if ActualizarEdit then
    EditCodigo.text:=inttohex(Quinteto0,6)+' '+inttohex(Quinteto1,6);
  ActualizarEstandarte;
  CambioDeEstandarteAceptado:=false;
  timer1.enabled:=true;
  showmodal;
  timer1.enabled:=false;
  result:=CambioDeEstandarteAceptado;
end;

procedure TFEstandartes.GbotonCancelarClick(Sender: TObject);
begin
  close;
end;

procedure TFEstandartes.EditCodigoChange(Sender: TObject);
begin
  ActualizarEdit:=false;
  ActualizarEstandarte;
  ActualizarEdit:=true;
end;

end.

