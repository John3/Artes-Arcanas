(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit Gboton;
interface

uses
  Windows, Messages, Classes, Graphics, Controls;

const
  CM_BASE                   = $B000;
  CM_MOUSELEAVE             = CM_BASE + 20;

type
  TCMExit = TWMNoParams;
  TCaption19 = string[19];
type
  TEstadoGboton=(ebPresionado,ebIluminado,ebLibre);
  TEventoDibujarBoton = procedure (Sender: TObject) of object;
  TGboton = class(TGraphicControl)
  private
    { Private declarations }
    FAlDibujarBoton: TEventoDibujarBoton;
    CanvasGrafico:TCanvas;
    Inicio,Delta:Tpoint;
    nombre:TCaption19;
    festado:TEstadoGboton;
    procedure CMExit(var Message: TCMExit); message CM_MOUSELEAVE;
    procedure Cambiarnombre(const cadena:TCaption19);
    procedure setVisibilidad(value:Boolean);
  protected
    { Protected declarations }
    procedure paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
              X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
              X: Integer; Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure click; override;
  public
    { Public declarations }
    property canvas;
    property estado:TEstadoGboton read festado;
    procedure DefinirGraficos(CanvasGrafico:Tcanvas;const Inicio,Delta:Tpoint);
    constructor create(AOwner: TComponent); override;
  published
    { Published declarations }
    //Solo lectura
    property AlDibujarboton:TEventoDibujarBoton read FAlDibujarBoton write FAlDibujarBoton;
    property Caption: TCaption19 read nombre write Cambiarnombre;
    property Color;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible write setVisibilidad;
    property OnClick;
  end;

implementation

constructor TGboton.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  CanvasGrafico:=nil;
  nombre:='';
  controlStyle:=controlStyle-[csAcceptsControls,csFramed,csDoubleClicks];
  color:=clSilver;
  festado:=ebLibre;
  width:=48;
  height:=20;
end;

procedure TGboton.setVisibilidad(value:Boolean);
begin
  festado:=ebLibre;
  inherited visible:=value;
end;

procedure TGboton.Cambiarnombre(const cadena:TCaption19);
begin
  nombre:=cadena;
  paint;
end;

procedure TGboton.DefinirGraficos(CanvasGrafico:Tcanvas;const Inicio,Delta:Tpoint);
begin
  if (CanvasGrafico<>nil) then
  begin
    self.CanvasGrafico:=CanvasGrafico;
    self.Inicio:=Inicio;
    self.Delta:=Delta;
  end;
end;

procedure TGboton.MouseDown(Button: TMouseButton; Shift: TShiftState;
              X: Integer; Y: Integer);
begin
  fEstado:=ebPresionado;
  paint;
end;

procedure TGboton.MouseUp(Button: TMouseButton; Shift: TShiftState;
              X: Integer; Y: Integer);
begin
  fEstado:=ebLibre;
  paint;
end;

procedure TGboton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if estado=ebLibre then
  begin
    fEstado:=ebIluminado;
    paint;
  end;
end;

procedure TGboton.click;
begin
  fEstado:=ebPresionado;
  inherited click;
end;

procedure TGboton.CMExit(var Message: TCMExit);
begin
  if estado=ebIluminado then
  begin
    festado:=ebLibre;
    paint;
  end;
end;

procedure TGboton.Paint;
var colorBoton:array[0..4] of Tcolor;
    i,borde:integer;
   function promedia(color1,color2:Tcolor):Tcolor;
   begin
     result:=(color1 and $00FEFEFE+color2 and $00FEFEFE) shr 1;
   end;
begin
if visible then
if Assigned(FAlDibujarBoton) then
  FAlDibujarBoton(Self)
else
with canvas do
begin
  colorBoton[4]:=color;
  if CanvasGrafico<>nil then
  begin
    if (festado>=ebPresionado) and (festado<=ebLibre) then
      bitblt(handle,0,0,width,height,CanvasGrafico.handle,Inicio.x+Delta.x*byte(festado),Inicio.y+Delta.y*byte(festado),SRCCOPY);
  end
  else
  begin
    borde:=17;
    if enabled then
    begin
      case Estado of
        ebPresionado:
        begin
          colorBoton[0]:=Promedia(Color,clBlack);
          colorBoton[4]:=Promedia(Color,colorBoton[0]);
          colorBoton[2]:=Promedia(colorBoton[4],colorBoton[0]);
        end;
        ebIluminado:
        begin
          colorBoton[0]:=Color;
          colorBoton[2]:=Promedia(colorBoton[0],clWhite);
          colorBoton[4]:=clWhite;
        end;
        else
        begin
          colorBoton[2]:=Promedia(Color,clBlack);
          colorBoton[0]:=Promedia(Color,colorBoton[2]);
          colorBoton[2]:=Promedia(Color,colorBoton[0]);
        end;
      end;
      colorBoton[1]:=Promedia(colorBoton[0],colorBoton[2]);
      colorBoton[3]:=Promedia(colorBoton[2],colorBoton[4]);
      for i:=0 to 4 do
      begin
        if i>0 then
          pen.color:=colorBoton[i]
        else
          pen.color:=Promedia(ColorBoton[0],Promedia(ColorBoton[0],clBlack));
        brush.color:=colorBoton[i];
        RoundRect(i shl 1,i,width-(i shl 1),height-i,borde,borde);
      end;
    end
    else
    begin
      pen.color:=Promedia(Color,clBlack);
      Brush.color:=colorBoton[4];
      RoundRect(0,0,width,height,borde,borde);
    end;
  end;
  if length(nombre)>0 then
  begin
    if nombre='_v_' then
      with canvas do
      begin
        Brush.style:=bsSolid;
        Pen.color:=ColorBoton[0];
        if estado=ebPresionado then
          Brush.color:=clWhite
        else
          Brush.color:=clBlack;
        FillRect(rect(5,10,width-5,12));
        FillRect(rect(7,12,width-7,14));
        moveTo(3,9);
        LineTo(width-4,9);
        LineTo(width div 2,height-9);
        LineTo(3,9);
        exit;
      end;
    Brush.style:=bsClear;
    canvas.Font:=self.Font;
    //Color de fondo para el texto:
    if((colorBoton[4] and $000000FF)+
      ((colorBoton[4] and $0000FF00)*5) shr 9+
      (colorBoton[4] and $00FF0000) shr 17)>500 then
      Font.Color:=clBlack
    else
      Font.Color:=clWhite;
    TextOut((width-canvas.TextWidth(nombre))div 2,
      (height-canvas.TextHeight(nombre))div 2,nombre);
  end;
end;
end;

end.

