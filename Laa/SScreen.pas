unit SScreen;

interface

uses
  Windows,  Graphics,  Forms,
  Ucliente, Classes, Controls, StdCtrls;

type
  TFEsperar = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    Logo:Tbitmap;
  public
    PBar:TbarraProgreso;
  end;

implementation
{$R *.DFM}
uses Graficador;

procedure TFEsperar.FormCreate(Sender: TObject);
begin
  PBar:=TBarraProgreso.create(self.canvas,0,350,640,30);
  Logo:=CrearDeGdd(CrptGDD+'logo'+ExtArc);
  controlStyle:=controlStyle+[csOpaque];
  brush.Style:=bsClear;
end;

procedure TFEsperar.FormDestroy(Sender: TObject);
begin
  hide;
  Logo.free;
  Pbar.free;
end;

procedure TFEsperar.FormPaint(Sender: TObject);
begin
  self.canvas.FillRect(rect(0,0,width,100));
  self.Canvas.draw(0,100,Logo);
  self.canvas.FillRect(rect(0,380,width,480));  
  PBar.paint;
end;

end.

(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)