(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit Reportes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TFormReporte = class(TForm)
    StringGrid: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormReporte: TFormReporte;

implementation

uses main;

{$R *.DFM}


procedure TFormReporte.FormCreate(Sender: TObject);
var i,j,k,w:integer;
    s:string;
begin
  with StringGrid do
  begin
    ColCount:=33;
    RowCount:=129;
    for i:=0 to 31 do
    begin
      Cols[i+1].Text:=FormMain.lbxObjetos.Items[i];
      w:=StringGrid.Canvas.TextWidth(FormMain.lbxObjetos.Items[i])+6;
      if ColWidths[i+1]<w then
        ColWidths[i+1]:=w;
    end;
    for i:=0 to 7 do
      for j:=0 to 7 do
        for k:=0 to 1 do
        begin
          s:=FormMain.lbxGenero.Items[k]+'.'+FormMain.lbxRaza.Items[j]+'.'+FormMain.lbxClase.Items[i];
          Rows[1+i+(j shl 3)+(k shl 6)].Strings[0]:=s;
          w:=StringGrid.Canvas.TextWidth(s)+6;
          if ColWidths[0]<w then
            ColWidths[0]:=w;
        end;
  end;
end;

end.

