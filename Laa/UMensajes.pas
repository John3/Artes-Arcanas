(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit UMensajes;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,StdCtrls,Gboton;

type
  TFMensaje = class(TForm)
    procedure B_AceptarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    B_Aceptar:TGboton;
    mensaje1,mensaje2:string;
    PosicionXTexto1,PosicionXTexto2:integer;
  protected
    procedure paint; override;
  public
    constructor create(AOwner:Tcomponent); override;
    procedure showmodal(const mensaje:string); reintroduce;
    { Public declarations }
  end;

  TFEntradaDatos= class(TForm)
    EdtTexto: TEdit;
    procedure B_AceptarClick(Sender: TObject);
    procedure B_CancelarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    B_Aceptar,B_Cancelar:TGboton;
    TextoEtiqueta,TextoRespuesta:string;
  protected
    procedure paint; override;
  public
    constructor create(AOwner:Tcomponent); override;
    function ObjetenerDato(const etiqueta,valorpredefinido:string):string;
    { Public declarations }
  end;

  //Funciona iguar que showmessage, sólo que mejorado estéticamente para el juego.
  procedure ShowMessageZ(const mensaje:string);
  function InputBoxZ(const etiqueta,valorpredefinido:string):string;
  procedure PintarFondoNegro(RForm:Tform);

implementation

uses juego,sonidos;

procedure PintarFondoNegro(RForm:Tform);
var bordes:TRect;
    i:integer;
begin
  with RForm,canvas do
  begin
    brush.style:=bsSolid;
    if (fondoMenu<>nil) then
      bitblt(handle,0,0,width,Height,fondomenu.canvas.handle,
        (640-width) shr 1,(480-Height),SRCCOPY)
    else
    begin
      brush.color:=clBlack;
      fillrect(Rform.ClientRect);
    end;
    brush.color:=clBronce;
    bordes:=rect(0,0,width,height);
    for i:=0 to 1 do
    begin
      FrameRect(bordes);
      inc(bordes.Left,2);
      inc(bordes.top,2);
      inc(bordes.Right,-2);
      inc(bordes.Bottom,-2);
    end;
    brush.style:=bsClear;
  end;
end;

procedure ShowMessageZ(const mensaje:string);
begin
  with TFMensaje.Create(Application) do
  begin
    showmodal(mensaje);
    free;
  end;
end;

function InputBoxZ(const etiqueta,valorpredefinido:string):string;
begin
  with TFEntradaDatos.Create(Application) do
  begin
    result:=ObjetenerDato(etiqueta,valorpredefinido);
    free;
  end;
end;

//TFMensaje ****************************************************************
procedure TFMensaje.B_AceptarClick(Sender: TObject);
begin
  SonidoIntensidad(snAceitar,-500);
  close;
end;

procedure TFMensaje.showmodal(const mensaje:string);
var ancho,posicionMarca:integer;
begin
  Position:=poScreenCenter;
  posicionMarca:=pos(#13,Mensaje);
  if posicionMarca>0 then
  begin
    Mensaje1:=copy(mensaje,1,posicionMarca-1);
    Mensaje2:=copy(mensaje,posicionMarca+1,length(mensaje));
    PosicionXTexto1:=canvas.TextWidth(Mensaje1);
    PosicionXTexto2:=canvas.TextWidth(Mensaje2);
    if PosicionXTexto2>PosicionXTexto1 then
      ancho:=PosicionXTexto2
    else
      ancho:=PosicionXTexto1
  end
  else
  begin
    Mensaje1:=Mensaje;
    Mensaje2:='';
    PosicionXTexto1:=canvas.TextWidth(Mensaje1);
    ancho:=PosicionXTexto1;
  end;
  inc(ancho,35);
  if ancho<200 then ancho:=200;
  ClientWidth:=ancho;
  B_Aceptar.Left:=(clientWidth-B_Aceptar.Width) div 2;//centrado
  with canvas do
  begin
    PosicionXTexto1:=(width-PosicionXTexto1) div 2;
    PosicionXTexto2:=(width-PosicionXTexto2) div 2;
  end;
  inherited showmodal;
end;

procedure TFMensaje.paint;
begin
  inherited paint;
  PintarFondoNegro(self);
  with canvas do
    if mensaje2='' then
      TextOut(PosicionXTexto1,18,Mensaje1)
    else
    begin
      TextOut(PosicionXTexto1,8,Mensaje1);
      TextOut(PosicionXTexto2,28,Mensaje2)
    end;
end;

procedure TFMensaje.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=27) or (key=13) or (key=32) then close;
end;

constructor TFMensaje.create(AOwner:Tcomponent);
begin
  inherited create(AOwner);
  Left:=364;
  Top:=136;
  BorderStyle:=bsNone;
  ClientHeight:=85;
  ClientWidth:=153;
  Font.Charset:=ANSI_CHARSET;
  Font.Color:=clWindowText;
  Font.Height:=-16;
  Font.Name:='Times New Roman';
  Font.Style:=[fsBold];
  FormStyle:=fsStayOnTop;
  Position:=poScreenCenter;
  OnKeyDown:=FormKeyDown;
  PixelsPerInch:=96;
  controlStyle:=controlStyle+[csOpaque];

  B_Aceptar:=TGBoton.create(self);
  with B_Aceptar do
  begin
    Top:=52;
    Width:=80;
    Height:=20;
    OnClick:=B_AceptarClick;
    parent:=self;
    Color:=clBronce;
    Caption:='Aceptar';
  end;
  self.canvas.font.PixelsPerInch:=96;
  canvas.font.color:=clBronceClaro;
end;

//TFEntradaDatos ****************************************************************

procedure TFEntradaDatos.B_AceptarClick(Sender: TObject);
begin
  SonidoIntensidad(snAceitar,-500);
  TextoRespuesta:=EdtTexto.text;
  close;
end;

procedure TFEntradaDatos.B_CancelarClick(Sender: TObject);
begin
  SonidoIntensidad(snError,-500);
  close;
end;

function TFEntradaDatos.ObjetenerDato(const etiqueta,valorpredefinido:string):string;
begin
  Position:=poScreenCenter;
  TextoEtiqueta:=etiqueta;
  TextoRespuesta:=valorpredefinido;
  EdtTexto.text:=TextoRespuesta;
  inherited showmodal;
  result:=TextoRespuesta;
end;

procedure TFEntradaDatos.paint;
begin
  PintarFondoNegro(self);
  with canvas do
    TextOut(10,8,TextoEtiqueta)
end;

procedure TFEntradaDatos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key<>27) then
    if (key=13) then TextoRespuesta:=EdtTexto.text else exit;
  close;
end;

constructor TFEntradaDatos.create(AOwner:Tcomponent);
begin
  inherited create(AOwner);
  Scaled := False;
  Left := 0;
  Top := 0;
  BorderStyle := bsNone;
  ClientHeight := 92;
  ClientWidth := 320;
  Font.Charset := ANSI_CHARSET;
  Font.Color := clWhite;
  Font.Height := -16;
  Font.Name := 'Times New Roman';
  Font.Style := [fsBold];
  FormStyle := fsStayOnTop;
  OnKeyDown := FormKeyDown;
  PixelsPerInch := 96;
  KeyPreview := True;
  controlStyle:=controlStyle+[csOpaque];

  EdtTexto:=TEdit.create(self);
  with EdtTexto do
  begin
    Left := 10;
    Top := 30;
    Width := 300;
    Height := 20;
    TabStop := True;
    AutoSelect := True;
    AutoSize := False;
    Color := clBlack;
    BorderStyle := bsNone;
    ParentFont := True;
    MaxLength := 79;
    TabOrder := 0;
    Parent := self;
  end;

  B_Aceptar:=TGBoton.create(self);
  with B_Aceptar do
  begin
    Left:=50;
    Top:=60;
    Width:=80;
    Height:=20;
    OnClick:=B_AceptarClick;
    parent:=self;
    Color:=clBronce;
    Caption:='Aceptar';
  end;
  B_Cancelar:=TGBoton.create(self);
  with B_Cancelar do
  begin
    Left:=190;
    Top:=60;
    Width:=80;
    Height:=20;
    OnClick:=B_CancelarClick;
    parent:=self;
    Color:=clBronce;
    Caption:='Cancelar';
  end;
  self.canvas.font.PixelsPerInch:=96;
  canvas.font.color:=clBronceClaro;
end;

end.

