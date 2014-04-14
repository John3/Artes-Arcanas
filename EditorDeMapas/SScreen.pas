(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit SScreen;

interface

uses
  Windows, Messages,Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls;
const
    rutaGraficosTablero='..\Laa\';
type
  TFEsperar = class(TForm)
    PBar: TProgressBar;
    LB_progreso: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    Logo:Tbitmap;
  public
    procedure Mensaje(avance:integer;const mensaje:string);
  end;

var
  FEsperar:TFEsperar;
  Ruta_Aplicacion:string;

implementation
{$R *.DFM}
uses Graficador,SysUtils;

procedure TFEsperar.FormCreate(Sender: TObject);
begin
  Ruta_Aplicacion:=ExtractFilePath(Application.ExeName);
  Logo:=CrearDeGdd(rutaGraficosTablero+'grf\logo'+ExtArc);
  controlStyle:=controlStyle+[csOpaque];
  brush.Style:=bsClear;
end;

procedure TFEsperar.FormDestroy(Sender: TObject);
begin
  hide;
  Logo.free;
end;

procedure TFEsperar.Mensaje(avance:integer;const mensaje:string);
begin
  PBar.StepBy(avance);
  LB_progreso.caption:=mensaje;
  LB_progreso.repaint;
end;

procedure TFEsperar.FormPaint(Sender: TObject);
begin
  self.Canvas.draw(0,0,Logo);
end;

end.

