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
  ExtCtrls, StdCtrls, Menus,objetos;

const
  Nombre_Iconos='..\laa\grf\cjr.jpg';
  Nombre_Archivo='..\laa\bin\cjr.b';

type
  TForm1 = class(TForm)
    CmbConjuros: TComboBox;
    Label1: TLabel;
    Bevel1: TBevel;
    PaintBox: TPaintBox;
    Label6: TLabel;
    EdtSAB: TEdit;
    Label7: TLabel;
    EdtINT: TEdit;
    Label8: TLabel;
    EdtMana: TEdit;
    Label9: TLabel;
    EdtCosto: TEdit;
    chkInicial: TCheckBox;
    Label5: TLabel;
    cmbTipo: TComboBox;
    ChkSoloJugadores: TCheckBox;
    ChkObjetivo: TCheckBox;
    ChkAsimismo: TCheckBox;
    Label10: TLabel;
    EdtAnimacion: TEdit;
    grpDanno: TGroupBox;
    Label2: TLabel;
    CmbTipoDanno: TComboBox;
    Label3: TLabel;
    EdtDBase: TEdit;
    Label4: TLabel;
    EdtDBono: TEdit;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    Abrir1: TMenuItem;
    Guardar1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Salir1: TMenuItem;
    Herramientas1: TMenuItem;
    Limpiarcadenas1: TMenuItem;
    Label11: TLabel;
    EdtNombre: TEdit;
    Label12: TLabel;
    EdtNivel: TEdit;
    Label13: TLabel;
    cmbEscuela: TComboBox;
    GuardarTextoHtml1: TMenuItem;
    GuardartextoHtmlconjurosdecombate1: TMenuItem;
    ChkConjuroAgresivo: TCheckBox;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure CmbConjurosChange(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure Limpiarcadenas1Click(Sender: TObject);
    procedure MostrarInfo;
    procedure GuardarInfo;
    procedure Abrir1Click(Sender: TObject);
    procedure Guardar1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure cmbTipoChange(Sender: TObject);
    procedure GuardarTextoHtml1Click(Sender: TObject);
    procedure GuardartextoHtmlconjurosdecombate1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    Iconos:Tbitmap;
    Info:TArchivoconjuros;
    CodigoAnterior:integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses JPEG;

{$R *.DFM}

function valor(const cdn:string;const inf,sup:integer):integer;
var code:integer;
begin
  val(cdn,result,code);
  if code<>0 then
    result:=inf
  else
    if result<inf then
      result:=inf
    else
      if result>sup then result:=sup;
end;

procedure controlar(const Edit:TEdit;const inf,sup:integer);
begin
  Edit.text:=inttostr(valor(Edit.text,inf,sup));
end;

procedure TForm1.FormCreate(Sender: TObject);
var jpg:TJpegImage;

  i:integer;
begin
  ControlStyle:=ControlStyle+[csOpaque];
  with PaintBox do
    ControlStyle:=ControlStyle+[csOpaque];
  jpg:=TjpegImage.Create;
  jpg.LoadFromFile(Nombre_Iconos);
  Iconos:=Tbitmap.Create;
  Iconos.Assign(jpg);
  jpg.free;
  for i:=0 to 31 do
    CmbConjuros.Items.Add('Hechizo #'+intastr(i));
  Caption:=caption+' '+GetVersion;  
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Iconos.free;
end;

procedure TForm1.PaintBoxPaint(Sender: TObject);
var indice:integer;
begin
  indice:=CmbConjuros.ItemIndex;
  bitBlt(PaintBox.Canvas.handle,0,0,40,40,Iconos.canvas.handle,
    (indice and $7)*40,(indice shr 3)*40,SRCCOPY);
end;

procedure TForm1.CmbConjurosChange(Sender: TObject);
begin
  MostrarInfo;
  PaintBox.repaint;
end;

procedure TForm1.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.Limpiarcadenas1Click(Sender: TObject);
var i:integer;
    s:string;
begin
  with info do
  for i:=0 to 31 do
  begin
    s:=nombre[i];
    fillchar(nombre[i],sizeof(nombre[i]),#0);
    nombre[i]:=s;
  end;
  MostrarInfo;
end;

procedure TForm1.GuardarInfo;
begin
  if CodigoAnterior>=0 then
  begin
    info.Nombre[CodigoAnterior]:=trim(EdtNombre.text);
    with info.Datos[CodigoAnterior] do
    begin
      BanderasCnjr:=0;
      if chkInicial.checked then BanderasCnjr:=BanderasCnjr or cjConjuroInicial;
      if ChkSoloJugadores.checked then BanderasCnjr:=BanderasCnjr or cjSoloJugadores;
      if ChkConjuroAgresivo.checked then BanderasCnjr:=BanderasCnjr or cjconjuroAgresivo;
      if ChkObjetivo.checked then BanderasCnjr:=BanderasCnjr or cjPuedeLanzarObjetivo;
      if ChkAsimismo.checked then BanderasCnjr:=BanderasCnjr or cjPuedeLanzarAsimismo;
      CostoCnjr:=valor(EdtCosto.text,1,650)*100;
      TipoCnjr:=TTipoConjuro(cmbTipo.itemindex);
      EscuelaConjuro:=cmbEscuela.itemindex;
      nivelINT:=valor(EdtINT.text,1,20);
      nivelSAB:=valor(EdtSAB.text,1,20);
      nivelMANA:=valor(EdtMANA.text,1,200);
      nivelJugador:=valor(EdtNivel.text,1,100);
      AnimacionCnjr:=valor(EdtAnimacion.text,0,255);
      if nivelSAB>nivelINT then
        IconoPergamino:=ihPergaminoS
      else
        IconoPergamino:=ihPergaminoA;
      DannoBaseCnjr:=valor(EdtDBase.text,1,255);
      DannoBonoCnjr:=valor(EdtDBono.text,DannoBaseCnjr,255);
      dec(DannoBonoCnjr,(DannoBaseCnjr-1));
      TipoDannoCnjr:=CmbTipoDanno.itemIndex;
    end;
  end;
end;

procedure TForm1.MostrarInfo;
begin
  GuardarInfo;
  CodigoAnterior:=CmbConjuros.itemIndex;
  with info.datos[CodigoAnterior] do
  begin
    chkInicial.checked:=byteBool(BanderasCnjr and cjConjuroInicial);
    ChkSoloJugadores.checked:=byteBool(BanderasCnjr and cjSoloJugadores);
    ChkConjuroAgresivo.checked:=byteBool(BanderasCnjr and cjConjuroAgresivo);
    ChkObjetivo.checked:=byteBool(BanderasCnjr and cjPuedeLanzarObjetivo);
    ChkAsimismo.checked:=byteBool(BanderasCnjr and cjPuedeLanzarAsimismo);
    cmbTipo.itemindex:=ord(TipoCnjr);
    cmbEscuela.itemindex:=ord(EscuelaConjuro);
    EdtINT.text:=intastr(nivelINT);
    EdtSAB.text:=intastr(nivelSAB);
    EdtMANA.text:=intastr(nivelMANA);
    EdtNivel.text:=intastr(nivelJugador);
    EdtAnimacion.text:=intastr(Animacioncnjr);
    EdtDBase.text:=intastr(DannoBasecnjr);
    EdtDBono.text:=intastr(DannoBasecnjr-1+DannoBonocnjr);
    CmbTipoDanno.itemIndex:=TipoDannoCnjr;
    grpDanno.visible:=cmbTipo.ItemIndex=0;
    EdtCosto.text:=inttostr(CostoCnjr div 100);
  end;
  EdtNombre.text:=info.Nombre[CodigoAnterior];
end;

procedure TForm1.Abrir1Click(Sender: TObject);
var f:file of TArchivoConjuros;
begin
  CmbConjuros.ItemIndex:=0;
  CmbEscuela.ItemIndex:=0;
  cmbTipo.ItemIndex:=0;
  CmbTipoDanno.ItemIndex:=0;
  assignFile(f,Nombre_Archivo);
  fileMode:=0;
  reset(f);
  read(f,Info);
  closeFile(f);
//  DeCriptico(Info.Datos,sizeof(Info.Datos));
  CodigoAnterior:=-1;
  MostrarInfo;
end;

procedure TForm1.Guardar1Click(Sender: TObject);
var f:file of TArchivoConjuros;
begin
  GuardarInfo;
//   Info.CheckSum:=Criptico(Info.Datos,sizeof(Info.Datos));
   assignFile(f,Nombre_Archivo);
   reWrite(f);
   write(f,Info);
   closeFile(f);
//   DeCriptico(Info.Datos,sizeof(Info.Datos));
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Abrir1Click(nil);
end;

procedure TForm1.cmbTipoChange(Sender: TObject);
begin
  grpDanno.visible:=cmbTipo.ItemIndex=0;
end;

procedure TForm1.GuardarTextoHtml1Click(Sender: TObject);
var f:textFile;
    i,j:integer;
    cadAux:string;
    listaCad:array[0..29] of string;
   function IntToStr2(n:integer):string;
   begin
     result:=inttostr(n);
     if n<10 then result:=' '+result;
   end;
begin
  for i:=0 to 29 do
    with info.Datos[i] do
      listaCad[i]:='<tr><td>'+inttostr2(nivelJugador)+'</td><td>'+info.Nombre[i]+'</td><td>'+cmbEscuela.Items[EscuelaConjuro]+
      '</td><td>'+inttostr(nivelINT*5)+'%</td><td>'+inttostr(nivelSAB*5)+'%</td><td>'+inttostr(nivelMana)+'</td></tr>';
  for i:=0 to 29 do
    for j:=i+1 to 29 do
    begin
      if listaCad[j]<listaCad[i] then
      begin
        cadAux:=listaCad[i];
        listaCad[i]:=listaCad[j];
        listaCad[j]:=cadAux;
      end;
    end;
  assignFile(f,'Hechizos.html');
  rewrite(f);
  writeln(f,'<table>');
  writeln(f,'<tr><th>Nivel</th><th>Nombre</th><th>Escuela</th><th>INT</th><th>SAB</th><th>Maná</th></tr>');
  for i:=0 to 29 do writeln(f,listaCad[i]);
  writeln(f,'</table>');
  closefile(f);
end;

procedure TForm1.GuardartextoHtmlconjurosdecombate1Click(Sender: TObject);
const maxHCombate=8;
var f:textFile;
    i,j:integer;
    cadAux:string;
    listaCad:array[0..maxHCombate] of string;
   function IntToStr2(n:integer):string;
   begin
     result:=inttostr(n);
     if n<10 then result:=' '+result;
   end;
   function DefinirAlcance(Banderas:byte):string;
   begin
     if bytebool(Banderas and cjPuedeLanzarObjetivo) then result:='Preciso'
     else
       if bytebool(Banderas and cjPuedeLanzarAsimismo) then result:='Circundante'
       else
         result:='Lineal';
   end;
begin
  for i:=0 to maxHCombate do
    with info.Datos[i] do
      listaCad[i]:='<tr><td>'+inttostr2(nivelJugador)+'</td><td>'+info.Nombre[i]+'</td>'+
      '</td><td>'+inttostr(nivelMana)+'</td><td>'+inttostr(dannoBaseCnjr)+' a '+inttostr(dannoBaseCnjr+dannobonoCnjr-1)+'</td><td>'+CmbTipoDanno.Items[TipoDannoCnjr]+
      '</td><td>'+DefinirAlcance(BanderasCnjr)+'</td><td>'+cmbEscuela.Items[EscuelaConjuro]+'</td></tr>';
  for i:=0 to maxHCombate do
    for j:=i+1 to maxHCombate do
    begin
      if listaCad[j]<listaCad[i] then
      begin
        cadAux:=listaCad[i];
        listaCad[i]:=listaCad[j];
        listaCad[j]:=cadAux;
      end;
    end;
  assignFile(f,'HechizosCombate.html');
  rewrite(f);
  writeln(f,'<table>');
  writeln(f,'<tr><th>Nivel</th><th>Nombre</th><th>Maná</th><th>Daño</th><th>Tipo</th><th>Efecto</th><th>Escuela</th></tr>');
  for i:=0 to maxHCombate do writeln(f,listaCad[i]);
  writeln(f,'</table>');
  closefile(f);
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  EdtCosto.text:=inttostr(valor(EdtNivel.text,1,25)*5);
end;

end.

