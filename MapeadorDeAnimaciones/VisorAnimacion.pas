(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit VisorAnimacion;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TFormVisor = class(TForm)
    ScrollBarY: TScrollBar;
    PaintBox: TPaintBox;
    ScrollBarX: TScrollBar;
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure ScrollBarYChange(Sender: TObject);
    procedure ScrollBarXChange(Sender: TObject);
  private
    { Private declarations }
    fBitmap:Tbitmap;
    fNombre:string;
  public
    { Public declarations }
    function setBitmap(nombre:string):boolean;
  end;

var
  FormVisor: TFormVisor;

implementation

{$R *.DFM}

procedure TFormVisor.FormCreate(Sender: TObject);
begin
  ControlStyle:=ControlStyle+[csOpaque];
  with PaintBox do
    ControlStyle:=ControlStyle+[csOpaque];
  fBitmap:=Tbitmap.create();
  fNombre:='';
end;

function TFormVisor.setBitmap(nombre:string):boolean;
begin
  result:=true;
  ScrollBarX.Position:=0;
  ScrollBarY.Position:=0;
  if fNombre<>nombre then
    try
      Caption:='Gráfico '+ExtractFileName(nombre);
      fBitmap.LoadFromFile(nombre);
    except
      result:=false;
    end;
end;

procedure TFormVisor.PaintBoxPaint(Sender: TObject);
var x,y:integer;
begin
  with PaintBox do
  begin
    if Width<fBitmap.Width then
      x:=(ScrollBarX.Position*(Width-fBitmap.Width)) div 100
    else
      x:=(Width-fBitmap.Width) shr 1;
    if height<fBitmap.height then
      y:=(ScrollBarY.position*(height-fBitmap.Height)) div 100
    else
      y:=(height-fBitmap.height) shr 1;
    BitBlt(Canvas.handle,x,y,fBitmap.width,fBitmap.height,fBitmap.canvas.handle,0,0,SRCCOPY);
  end;
end;

procedure TFormVisor.ScrollBarYChange(Sender: TObject);
begin
  PaintBox.repaint;
end;

procedure TFormVisor.ScrollBarXChange(Sender: TObject);
begin
  PaintBox.repaint;
end;

end.

