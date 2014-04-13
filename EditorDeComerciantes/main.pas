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
  StdCtrls, ExtCtrls,Tablero,Objetos, Menus;

const
//!! COORDINAR CON EDITOR DE MAPAS
  MC_DescripcionComercio:array[0..MAX_TIPOS_COMERCIO] of string[6]=(
    '','Simple','Enanos','Elfos','Orcos','Enanos',
    'Elfos','','','','','',
    '','','','','','','','Drow','','','','','','','','','','','','');

  NR_ARTEFACTOS_DEFINIDOS=247;
type
  TFMain = class(TForm)
    Panel1: TPanel;
    PaintBox: TPaintBox;
    CmbComercio: TComboBox;
    Label2: TLabel;
    CmbArtefacto: TComboBox;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    Arcivo1: TMenuItem;
    Recuperar1: TMenuItem;
    Guardar1: TMenuItem;
    N2: TMenuItem;
    Salir1: TMenuItem;
    IconoArma: TPaintBox;
    Bevel1: TBevel;
    Lb_descripcion: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure CmbArtefactoChange(Sender: TObject);
    procedure CmbComercioChange(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Recuperar1Click(Sender: TObject);
    procedure Guardar1Click(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure IconoArmaPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    Graficos:Tbitmap;
    Posicion:integer;
    Archivo:TArchivoComercios;
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation
uses JPEG;
{$R *.DFM}
function DefinirModificador(id,posicion:byte):byte;
var ArtefactoTemp:Tartefacto;
    clase:byte;
begin
  if id<4 then
  begin
    result:=0;
    exit;
  end;
  ArtefactoTemp.id:=id;
  ArtefactoTemp.modificador:=5;
  clase:=id shr 3;
  if NumeroElementos(ArtefactoTemp)>1 then
  begin
    if (clase=18) or (clase=19) then
      result:=5
    else
      case PrecioArtefacto(ArtefactoTemp) of
        0..45:result:=25;
        46..100:result:=10;
        101..250:result:=5;
        else result:=1;
      end;
  end
  else
    case clase of
        17:result:=25;
        23:result:=100;
        22:result:=0;
        29:if (id=232) then
             case posicion of
               0..5:result:=posicion+3;//ataque hielo,rayo
               6..8:result:=posicion+6;//hech.+
               9:result:=17;//aturdir
               10:result:=18;//ident.
               11..13:result:=posicion+9;
               14..16:result:=posicion+10;
               else result:=18;
             end
           else
             if (id=233) then
               case posicion of
                 0..2:result:=posicion;//Ataque de fuego
                 3..5:result:=posicion+6;//curaciones
                 6:result:=15;//Maldecir
                 7:result:=16;//Paralizar
                 8:result:=19;//disiparmagia
                 9:result:=23;//VisionVerdadera
                 10..12:result:=posicion+17;
                 else result:=9;
               end
             else
               result:=50;
      else
        result:=50
    end;
end;

procedure TFMain.FormCreate(Sender: TObject);
var jpg:TjpegImage;
    i:integer;
begin
  ControlStyle:=ControlStyle+[csOpaque];
  with PaintBox do
    ControlStyle:=ControlStyle+[csOpaque];
  jpg:=TjpegImage.Create;
  jpg.LoadFromFile('..\laa\grf\obj.jpg');
  Graficos:=Tbitmap.Create;
  Graficos.Assign(jpg);
  jpg.free;
  InicializarColeccionObjetos('..\laa\bin\obj.b');
  InicializarColeccionConjuros('..\laa\bin\cjr.b');
  for i:=0 to MAX_TIPOS_COMERCIO do
    fillchar(Archivo.Artefactos[i],sizeOf(Archivo.Artefactos[i]),0);
  for i:=0 to NR_ARTEFACTOS_DEFINIDOS do
    CmbArtefacto.Items.Add(NomObj[i]);
  for i:=0 to MAX_TIPOS_COMERCIO do
    CmbComercio.Items.Add(MC_NombresComerciantes[i]+' '+MC_DescripcionComercio[i]);
  CmbArtefacto.ItemIndex:=0;
  CmbComercio.ItemIndex:=0;
  posicion:=0;
  caption:=caption+' '+getVersion;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  Graficos.free;
end;

procedure TFMain.IconoArmaPaint(Sender: TObject);
var id:integer;
begin
  id:=CmbArtefacto.ItemIndex;
  if id=0 then
    IconoArma.Canvas.FillRect(clientrect)
  else
  BitBlt(IconoArma.Canvas.handle,0,0,40,40,Graficos.canvas.handle,
    (id mod 8)*40,(id div 8)*40,SRCCOPY);
end;

procedure TFMain.PaintBoxPaint(Sender: TObject);
var i,j:integer;
    id,modificador:byte;
    artefacto:Tartefacto;
    s:string;
begin
  for j:=0 to 1 do
    for i:=0 to 8 do
    begin
      artefacto:=Archivo.Artefactos[CmbComercio.itemindex][i+j*9];
      id:=artefacto.id;
      if artefacto.id<4 then
        BitBlt(PaintBox.Canvas.handle,i*40,j*40,40,40,Graficos.canvas.handle,
          0,0,BLACKNESS)
      else
        BitBlt(PaintBox.Canvas.handle,i*40,j*40,40,40,Graficos.canvas.handle,
          (id mod 8)*40,(id div 8)*40,SRCCOPY);
      if id>=4 then
      with paintBox.canvas do
      begin
        Font.Size:=10;
        Font.Style:=Font.Style+[fsBold];
        Brush.Style:=bsClear;
        modificador:=artefacto.modificador;
        artefacto.modificador:=3;
        Font.Color:=clBlack;
        if (NumeroElementos(Artefacto)=1) then
        begin
          s:='1 ('+inttostr(modificador)+')';
          TextOut(i*40+1,j*40+26,s);
          TextOut(i*40+3,j*40+26,s);
          TextOut(i*40+2,j*40+27,s);
          TextOut(i*40+2,j*40+25,s);
          Font.Color:=$C0FFA0;
          TextOut(i*40+2,j*40+26,s)
        end
        else
        begin
          TextOut(i*40+1,j*40+26,inttostr(modificador));
          TextOut(i*40+3,j*40+26,inttostr(modificador));
          TextOut(i*40+2,j*40+27,inttostr(modificador));
          TextOut(i*40+2,j*40+25,inttostr(modificador));          
          Font.Color:=clWhite;
          TextOut(i*40+2,j*40+26,inttostr(modificador))
        end;
      end;
    end;
  i:=Posicion;
  j:=i div 9;
  i:=i mod 9;
  PaintBox.Canvas.Brush.Color:=clWhite;
  PaintBox.Canvas.FrameRect(rect(i*40,j*40,i*40+40,j*40+40));
end;

procedure TFMain.CmbArtefactoChange(Sender: TObject);
var id_nuevo:byte;
begin
  id_nuevo:=CmbArtefacto.ItemIndex;
  if id_nuevo<4 then id_nuevo:=0;
  with Archivo.Artefactos[CmbComercio.itemindex][posicion] do
  begin
    id:=id_nuevo;
    modificador:=DefinirModificador(id_nuevo,posicion);
  end;
  IconoArma.repaint;
  PaintBox.repaint;
end;

procedure TFMain.CmbComercioChange(Sender: TObject);
begin
  PaintBox.repaint;
  CmbArtefacto.ItemIndex:=Archivo.Artefactos[CmbComercio.itemindex][posicion].id;
  IconoArma.repaint;
end;

procedure TFMain.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  posicion:=x div 40+(y div 40)*9;
  CmbArtefacto.ItemIndex:=Archivo.Artefactos[CmbComercio.itemindex][posicion].id;
  PaintBox.repaint;  
  IconoArma.repaint;
end;

procedure TFMain.Recuperar1Click(Sender: TObject);
{type
  TOldArchivoComercios=record
    Artefactos:array[0..15] of TInventarioArtefactos;
    CheckSum:integer;
  end;
var f:file of TOldArchivoComercios;
  ArchivoOld:TOldArchivoComercios;
  i:integer;
}
var f:file of TArchivoComercios;
    result:boolean;
begin
  assignFile(f,'..\laa\bin\comercio.b');
  reset(f);
    {$I-}
  read(f,Archivo);
    {$I+}
  result:=IOResult=0;
  if not result then showmessage('Actualizando Archivo...');
  closeFile(f);
  PaintBox.repaint;
end;

procedure TFMain.Guardar1Click(Sender: TObject);
var f:file of TArchivoComercios;
begin
  assignFile(f,'..\laa\bin\comercio.b');
  rewrite(f);
  write(f,Archivo);
  closeFile(f);
end;

procedure TFMain.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  Recuperar1Click(nil);
end;

procedure TFMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  with Archivo.Artefactos[CmbComercio.itemindex][posicion] do
{  if (NumeroElementos(ObjetoArtefacto(id,3))>1) or
  ((id>=orGemaInicial)and(id<=orGemaFinal)) or
  ((id>=136)and(id<=143))
   then}
  begin
    case key of
      109://'-'
        if modificador>1 then dec(modificador);
      107://'+'
        if modificador<255 then inc(modificador);
      else
        exit;
    end;
    IconoArma.repaint;
    PaintBox.repaint;
  end;
end;

procedure TFMain.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var posicionTempo:integer;
begin
  posicionTempo:=x div 40+(y div 40)*9;
  Lb_descripcion.caption:=nombreObjeto(Archivo.Artefactos[CmbComercio.itemindex][posicionTempo],ciVerRealmente);
end;

end.
