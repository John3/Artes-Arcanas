(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit UColor8;

interface

uses
  Windows, Classes, Graphics, Controls, Forms, Gboton, StdCtrls;

type
  TFColor8 = class(TForm)
    sb_rojo: TScrollBar;
    sb_verde: TScrollBar;
    sb_azul: TScrollBar;
    procedure GbotonCancelarClick(Sender: TObject);
    procedure GbotonAceptarClick(Sender: TObject);
    procedure paint; override;
    procedure sb_colorChange(Sender: TObject);
  private
    { Private declarations }
    GbotonAceptar,GbotonCancelar:TGboton;
    fEscogioUnColor,fActualizarColores:boolean;
    fcolor8:byte;
    procedure setColor8(NuevoColor:byte);
    procedure PintarAreaColorida;
  public
    { Public declarations }
    titulo:string;
    constructor create(AOwner:Tcomponent); override;
    property color8:byte read fcolor8 write setColor8;
    function execute:boolean;
  end;

implementation
uses UMensajes,graficador,juego;

constructor TFColor8.create(AOwner:Tcomponent);
begin
  inherited create(AOwner);
  Left := 480;
  Top := 139;
  BorderStyle := bsNone;
  ClientHeight := 161;
  ClientWidth := 312;
  Color := clBlack;
  Ctl3D := False;
  Font.Charset := ANSI_CHARSET;
  Font.Color := 12644596;
  Font.Height := -15;
  Font.Name := 'Times New Roman';
  Font.Style := [fsBold];
  OldCreateOrder := True;
  Position := poScreenCenter;
  Scaled := False;
  PixelsPerInch := 96;
  sb_rojo:=TScrollBar.create(self);
  with sb_rojo do
  begin
    Left := 64;
    Top := 42;
    Width := 126;
    Height := 18;
    Max := 5;
    PageSize := 0;
    TabOrder := 0;
    OnChange := sb_colorChange;
    Parent := self;
  end;
  sb_verde:=TScrollBar.create(self);
  with sb_verde do
  begin
    Left := 64;
    Top := 66;
    Width := 126;
    Height := 18;
    Max := 6;
    PageSize := 0;
    TabOrder := 1;
    OnChange := sb_colorChange;
    Parent := self;
  end;
  sb_azul:=TScrollBar.create(self);
  with sb_azul do
  begin
    Left := 64;
    Top := 90;
    Width := 126;
    Height := 18;
    Max := 5;
    PageSize := 0;
    TabOrder := 2;
    OnChange := sb_colorChange;
    Parent := self;
  end;

  ControlStyle:=ControlStyle+[csOpaque];
  GbotonAceptar:=TGBoton.create(self);
  with GbotonAceptar do
  begin
    Left:=36;
    Top:=124;
    Width:=96;
    Height:=22;
    OnClick:=GbotonAceptarClick;
    parent:=self;
    Color:=clBronce;
    Caption:='Aceptar';
  end;
  GbotonCancelar:=TGBoton.create(self);
  with GbotonCancelar do
  begin
    Left:=178;
    Top:=124;
    Width:=96;
    Height:=22;
    OnClick:=GbotonCancelarClick;
    parent:=self;
    Color:=clBronce;
    Caption:='Cancelar';
  end;
  canvas.brush.style:=bsSolid;
  self.canvas.font.PixelsPerInch:=96;
  fActualizarColores:=true;
end;

procedure TFColor8.setColor8(NuevoColor:byte);
begin
  fActualizarColores:=False;
  sb_rojo.Position:=NuevoColor mod 6;
  sb_verde.Position:=(NuevoColor div 6) mod 7;
  sb_azul.Position:=NuevoColor div 42;
  fcolor8:=NuevoColor;
  fActualizarColores:=true;
end;

procedure TFColor8.paint;
begin
  PintarFondoNegro(self);
  with canvas do
  begin
    font.Size:=14;
    TextOut((width-textwidth(titulo))div 2,12,titulo);
    font.Size:=11;
    TextOut(16,42,'Rojo:');
    TextOut(16,66,'Verde:');
    TextOut(16,90,'Azul:');
  end;
  PintarAreaColorida;
end;

procedure TFColor8.PintarAreaColorida;
begin
  with canvas do
  begin
    brush.style:=bsSolid;
    Brush.color:=TablaDeColorIndexado676[fcolor8];
    FillRect(rect(209,45,269,105));
    FrameRect(rect(206,42,272,108));
  end;
end;

function TFColor8.execute:boolean;
begin
  fEscogioUnColor:=false;
  titulo:='Elige el color de tu clan';
  showmodal;
  result:=fEscogioUnColor;
end;

procedure TFColor8.GbotonCancelarClick(Sender: TObject);
begin
  close;
end;

procedure TFColor8.GbotonAceptarClick(Sender: TObject);
begin
  fEscogioUnColor:=true;
  close;
end;

procedure TFColor8.sb_colorChange(Sender: TObject);
begin
  if not fActualizarColores then exit;
  fcolor8:=sb_rojo.Position+sb_verde.Position*6+sb_azul.Position*42;
  canvas.Brush.color:=TablaDeColorIndexado676[fcolor8];
  PintarAreaColorida;
end;

end.

