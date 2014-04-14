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
  StdCtrls, Menus;

type
  TFormMain = class(TForm)
    GroupBox1: TGroupBox;
    cbAnimacionAtaque: TComboBox;
    cbMapeoArmas: TComboBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Salir1: TMenuItem;
    Mapeodeanimaciones1: TMenuItem;
    Mapeodeataques1: TMenuItem;
    Recuperar1: TMenuItem;
    Guardar1: TMenuItem;
    Button1: TButton;
    lbxObjetos: TListBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbxRaza: TListBox;
    lbxClase: TListBox;
    Label5: TLabel;
    cbAnimacion: TComboBox;
    Label6: TLabel;
    lbxGenero: TListBox;
    Button2: TButton;
    Button3: TButton;
    Abrir1: TMenuItem;
    Guardar2: TMenuItem;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    procedure Salir1Click(Sender: TObject);
    procedure Recuperar1Click(Sender: TObject);
    procedure Guardar1Click(Sender: TObject);
    procedure cbAnimacionAtaqueChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbMapeoArmasChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CambiarSeleccion(Sender: TObject);
    procedure Guardar2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure ActualizarMapeoDeAtaque;
    procedure RecuperarMapeoDeAtaque;
    procedure RecuperarMapeoDeAnimaciones;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation
{$R *.DFM}
uses objetos,demonios, visorAnimacion, Reportes;

const
   Nombre_Archivo_Mapeo_Ataques='..\laa\bin\mp_ataq.b';
   Nombre_Archivo_Mapeo_Animaciones='..\laa\bin\mp_anim.b';
   Nombre_Archivo_Monstruos='..\laa\bin\std.mon';
   Nombre_Archivo_Artefactos='..\laa\bin\obj.b';

var
   BackupInformacionDeMapeoDeAtaques:TInformacionDeMapeoDeAtaques;
   BackupInformacionDeMapeoDeAnimaciones:TInformacionDeMapeoDeAnimaciones;

function SonIgualesByteAByte(var A; var B; longitud:integer):boolean;
type
  TArrayDeBytes=array [0..0] of byte;
  pArrayDeBytes=^TArrayDeBytes;
var i:integer;
    pa,pb:pArrayDeBytes;
begin
  result:=false;
  pa:=pArrayDeBytes(addr(A));
  pb:=pArrayDeBytes(addr(B));
  for i:=0 to longitud-1 do
    if pa[i]<>pb[i] then exit;
  result:=true;
end;

procedure TFormMain.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TFormMain.RecuperarMapeoDeAtaque;
begin
  InicializarMapeoAtaques(Nombre_Archivo_Mapeo_Ataques);
  cbAnimacionAtaque.ItemIndex:=0;
  ActualizarMapeoDeAtaque;
  BackupInformacionDeMapeoDeAtaques:=InfMapeoAtaques;
end;

procedure TFormMain.RecuperarMapeoDeAnimaciones;
begin
  InicializarMapeoAnimaciones(Nombre_Archivo_Mapeo_Animaciones);
  cbAnimacion.ItemIndex:=0;
//  ActualizarMapeoDeAtaque;
  BackupInformacionDeMapeoDeAnimaciones:=InfMapeoAnimaciones;
end;

procedure TFormMain.Recuperar1Click(Sender: TObject);
begin
  RecuperarMapeoDeAtaque;
end;

procedure GuardarMapeoDeAtaques;
var f:file of TInformacionDeMapeoDeAtaques;
begin
  assignfile(f,Nombre_Archivo_Mapeo_Ataques);
  rewrite(f);
  write(f,InfMapeoAtaques);
  closefile(f);
  BackupInformacionDeMapeoDeAtaques:=InfMapeoAtaques;
end;

procedure GuardarMapeoDeAnimaciones;
var f:file of TInformacionDeMapeoDeAnimaciones;
begin
  assignfile(f,Nombre_Archivo_Mapeo_Animaciones);
  rewrite(f);
  write(f,InfMapeoAnimaciones);
  closefile(f);
  BackupInformacionDeMapeoDeAnimaciones:=InfMapeoAnimaciones;
end;

procedure TFormMain.Guardar1Click(Sender: TObject);
begin
  GuardarMapeoDeAtaques;
end;

procedure TFormMain.ActualizarMapeoDeAtaque;
var indice:integer;
begin
  indice:=cbAnimacionAtaque.ItemIndex;
  if (indice<0) or (indice>Fin_animaciones_avatares) then exit;
  try
    cbMapeoArmas.ItemIndex:=InfMapeoAtaques[indice].ConArmas;
  except
    cbMapeoArmas.ItemIndex:=0;
  end;
end;

procedure TFormMain.cbAnimacionAtaqueChange(Sender: TObject);
begin
  ActualizarMapeoDeAtaque;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var i:integer;
begin
  if not FileExists(Nombre_Archivo_Artefactos) then
  begin
    showmessage('Este programa debe estar ubicado en la carpeta "Editores"');
    Halt;
    exit;
  end;
  InicializarColeccionObjetos(Nombre_Archivo_Artefactos);
  InicializarMonstruos(Nombre_Archivo_Monstruos);
  for i:=0 to Fin_animaciones_avatares do
  begin
    cbAnimacionAtaque.Items.Add(InfMon[i].nombre);
    cbAnimacion.Items.Add(InfMon[i].nombre);
  end;
  for i:=0 to 7 do
    lbxRaza.Items.Add(InfMon[i].nombre);
  lbxRaza.Items[7]:='??';
  for i:=0 to 7 do
    lbxClase.Items.Add(MC_Nombre_Categoria[i]);
  for i:=56 to 79 do
    lbxObjetos.Items.Add(NomObj[i]);
  for i:=248 to 253 do
    lbxObjetos.Items.Add(NomObj[i]);
  lbxObjetos.Items.Add('<Sin armadura>');
  lbxObjetos.Items.Add('<Para fantasma>');

  for i:=0 to 1 do
    lbxGenero.Items.Add(MC_Genero[i]);

  RecuperarMapeoDeAtaque;
  RecuperarMapeoDeAnimaciones;
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  if FormVisor.setBitmap('..\laa\grf\m'+intastr(cbAnimacionAtaque.ItemIndex)+'.bmp') then
    FormVisor.show
  else
    showmessage('El bitmap no existe.');
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not SonIgualesByteAByte(BackupInformacionDeMapeoDeAnimaciones,InfMapeoAnimaciones,SizeOf(InfMapeoAnimaciones)) then
    canClose:=MessageDlg('¿Salir sin guardar los cambios en el mapeo de animaciones?',mtConfirmation,mbOKCancel,0)=mrOk;
  if canClose then
    if not SonIgualesByteAByte(BackupInformacionDeMapeoDeAtaques,InfMapeoAtaques,SizeOf(InfMapeoAtaques)) then
      canClose:=MessageDlg('¿Salir sin guardar los cambios en el mapeo de ataques por animación?',mtConfirmation,mbOKCancel,0)=mrOk;
end;

procedure TFormMain.cbMapeoArmasChange(Sender: TObject);
var indice:integer;
begin
  indice:=cbAnimacionAtaque.ItemIndex;
  if (indice<0) or (indice>Fin_animaciones_avatares) then exit;
  InfMapeoAtaques[indice].ConArmas:=cbMapeoArmas.ItemIndex;
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
  if FormVisor.setBitmap('..\laa\grf\m'+intastr(cbAnimacion.ItemIndex)+'.bmp') then
    FormVisor.show
  else
    showmessage('El bitmap no existe.');
end;


procedure TFormMain.CambiarSeleccion(Sender: TObject);
var i,item,tipo:integer;
    listaActual:TlistBox;
begin
  if not (sender is Tcomponent) then exit;
  tipo:=Tcomponent(sender).tag and $1;
  item:=Tcomponent(sender).tag shr 1;
  case item of
    0:listaActual:=lbxObjetos;
    1:listaActual:=lbxRaza;
    2:listaActual:=lbxClase;
    else
      listaActual:=lbxGenero;
  end;
  if (tipo=0) then
  begin
    for i:=0 to listaActual.items.Count-1 do
      listaActual.Selected[i]:=false;
  end
  else
    for i:=0 to listaActual.items.Count-1 do
      listaActual.Selected[i]:=not listaActual.Selected[i];
end;


procedure TFormMain.Guardar2Click(Sender: TObject);
begin
  GuardarMapeoDeAnimaciones;
end;

procedure TFormMain.Button2Click(Sender: TObject);
var iClase,iRaza,iObjeto,iGenero:integer;
begin
  if (lbxObjetos.SelCount=0) then
  begin
    showmessage('Selecciona por lo menos un elemento de "Objetos".');
    exit;
  end;
  if (lbxClase.SelCount=0) then
  begin
    showmessage('Selecciona por lo menos un elemento de "Clases".');
    exit;
  end;
  if (lbxRaza.SelCount=0) then
  begin
    showmessage('Selecciona por lo menos un elemento de "Razas".');
    exit;
  end;
  if (lbxGenero.SelCount=0) then
  begin
    showmessage('Selecciona por lo menos un elemento de "Géneros".');
    exit;
  end;
  if not FileExists('..\laa\grf\m'+intastr(cbAnimacion.ItemIndex)+'.bmp') then
  begin
    showmessage('No existe el bitmap de animacion para:"'+cbAnimacion.Text+'"');
    exit;
  end;
  for iClase:=0 to lbxClase.Items.Count-1 do
    if lbxClase.Selected[iClase] then
      for iObjeto:=0 to lbxObjetos.Items.Count-1 do
        if lbxObjetos.Selected[iObjeto] then
          for iRaza:=0 to lbxRaza.Items.Count-1 do
            if lbxRaza.Selected[iRaza] then
              for iGenero:=0 to lbXGenero.Items.Count-1 do
                if lbxGenero.Selected[iGenero] then
                begin
                  //[32 objetos][8 clases][8 razas][2 generos]
                  InfMapeoAnimaciones[iObjeto+(iClase shl 5)+(iRaza shl 8)+(iGenero shl 11)]:=cbAnimacion.ItemIndex;
                end;
end;

procedure TFormMain.Button3Click(Sender: TObject);
var iClase,iRaza,iObjeto,iGenero,w:integer;
    s:string;
begin
  for iClase:=0 to lbxClase.Items.Count-1 do
    for iObjeto:=0 to lbxObjetos.Items.Count-1 do
      for iRaza:=0 to lbxRaza.Items.Count-1 do
        for iGenero:=0 to lbXGenero.Items.Count-1 do
        begin
          //[32 objetos][8 clases][8 razas][2 generos]
          s:=cbAnimacion.Items[InfMapeoAnimaciones[iObjeto+(iClase shl 5)+(iRaza shl 8)+(iGenero shl 11)]];
          with FormReporte.StringGrid do
          begin
            Cells[iObjeto+1,1+iClase+(iRaza shl 3)+(iGenero shl 6)]:=s;
            w:=Canvas.TextWidth(s)+6;
            if ColWidths[iObjeto+1]<w then
              ColWidths[iObjeto+1]:=w;
          end;
        end;
  FormReporte.showModal;
end;

end.
