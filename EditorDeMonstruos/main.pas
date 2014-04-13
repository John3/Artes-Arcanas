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
  ExtCtrls, StdCtrls, Menus, Buttons, Mask,Demonios;

const
  Ruta_Aplicacion='..\laa\';

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Cerrar1: TMenuItem;
    AbrirManual1: TMenuItem;
    GuardaresteManual1: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditNombre: TEdit;
    C_ZonaCivilizada: TCheckBox;
    C_ZonaSalvaje: TCheckBox;
    Label7: TLabel;
    E_Defensa: TEdit;
    Label8: TLabel;
    E_HPB: TEdit;
    Label10: TLabel;
    E_PA1: TEdit;
    Label12: TLabel;
    E_BA1: TEdit;
    Label26: TLabel;
    CB_Cortantes: TComboBox;
    Label27: TLabel;
    CB_Contundentes: TComboBox;
    Label28: TLabel;
    CB_Punzantes: TComboBox;
    Label30: TLabel;
    Label31: TLabel;
    CB_Veneno: TComboBox;
    Label32: TLabel;
    Label33: TLabel;
    C_TerrenoSolido: TCheckBox;
    CB_codigo: TComboBox;
    CB_guardar: TCheckBox;
    E_ModTesoro: TEdit;
    Label11: TLabel;
    CB_tamanno: TComboBox;
    Label13: TLabel;
    EditCodigo: TEdit;
    Label19: TLabel;
    CB_alineacion: TComboBox;
    CB_sociedad: TComboBox;
    CB_combate: TComboBox;
    Label22: TLabel;
    CB_tesoro: TComboBox;
    Label5: TLabel;
    Label29: TLabel;
    Label34: TLabel;
    Label37: TLabel;
    CB_Fuego: TComboBox;
    CB_Rayo: TComboBox;
    CB_Hielo: TComboBox;
    CB_Magia: TComboBox;
    Label38: TLabel;
    C_agua: TCheckBox;
    C_fuego: TCheckBox;
    CB_TA1: TComboBox;
    Label23: TLabel;
    Label39: TLabel;
    E_exp: TEdit;
    Label40: TLabel;
    CB_NA1: TComboBox;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    E_ataque: TEdit;
    E_PA2: TEdit;
    E_BA2: TEdit;
    CB_TA2: TComboBox;
    CB_NA2: TComboBox;
    Label20: TLabel;
    Label21: TLabel;
    Label24: TLabel;
    E_PA3: TEdit;
    E_BA3: TEdit;
    CB_TA3: TComboBox;
    CB_NA3: TComboBox;
    Label6: TLabel;
    E_regeneracion: TEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label14: TLabel;
    Label18: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    E_nivel: TEdit;
    Herramientas1: TMenuItem;
    Llenarconvaloresusuales1: TMenuItem;
    CB_indice: TComboBox;
    CB_TesoroAzar: TComboBox;
    Label41: TLabel;
    Cerrar2: TMenuItem;
    N1: TMenuItem;
    Guardar1: TMenuItem;
    Label4: TLabel;
    CB_EstiloAnimacion: TComboBox;
    Label9: TLabel;
    cb_consecuenciaMuerte: TComboBox;
    Label25: TLabel;
    cb_estiloMuerte: TComboBox;
    cb_Paralizar: TCheckBox;
    cb_VisionVerdadera: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    cb_Aturdir: TCheckBox;
    cb_Disipar: TCheckBox;
    CheckBox9: TCheckBox;
    Label42: TLabel;
    CB_TiempoEntreAtaques: TComboBox;
    cb_Liderazgo: TCheckBox;
    cb_encantar: TCheckBox;
    procedure AbrirManual1Click(Sender: TObject);
    procedure GuardaresteManual1Click(Sender: TObject);
    procedure EditNombreChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CB_codigoEnter(Sender: TObject);
    procedure CB_codigoChange(Sender: TObject);
    procedure EditCodigoChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CB_guardarClick(Sender: TObject);
    procedure Llenarconvaloresusuales1Click(Sender: TObject);
    procedure Cerrar2Click(Sender: TObject);
    procedure Guardar1Click(Sender: TObject);

  private
    { Private declarations }
    Guardado:boolean;
    ListaActivos:array[0..Fin_tipo_monstruos] of boolean;
    Lista:array[0..Fin_tipo_monstruos] of TDescripcionMonstruo;
    procedure LimpiarListas;
    procedure InicializarFormulario(n:byte);
    procedure ActualizarLista;
    procedure InicializarListaValoresUsuales(n:integer);
    procedure AbrirMan(const nombre:string);
    procedure GuardarMan(const nombre:string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
uses Globales,Objetos;

function valor(const numero:string;const minimo,maximo:integer):integer;
var code:integer;
begin
   val(numero,result,code);
   if code<>0 then result:=0;
   if result<minimo then result:=minimo;
   if result>maximo then result:=maximo;
end;

procedure TForm1.LimpiarListas;
var i:integer;
begin
  Fillchar(ListaActivos,sizeof(ListaActivos),#0);
  for i:=0 to Fin_tipo_monstruos do
    InicializarListaValoresUsuales(i);
end;

procedure TForm1.AbrirMan(const nombre:string);
var f:file of TDescripcionMonstruoYTipo;
    des:TDescripcionMonstruoYTipo;
    i:integer;

 //   t,j:integer;
begin
  //relacionar archivo con variable
  assignfile(f,nombre);
  LimpiarListas;
  //Modo solo lectura
  filemode:=0;
  //abrir archivo
  reset(f);
  for i:=0 to filesize(f)-1 do
  begin
    //leer en la variable des
    read(f,des);
    listaactivos[des.tipoMonstruo]:=true;

{//Actualización de resistencias
    t:=0;
    for j:=0 to 6 do
      t:=t or (((((des.descripcion.resistencias shr (j*3)) and $7) shl 1)+1) shl (j shl 2));
    t:=t or (((des.descripcion.resistencias shr 21) and $7) shl 28);
    des.descripcion.resistencias:=t;
}
    //Actualizar los flags de pericias de monstruos
    //agregar actuales
    //des.descripcion.PericiasMonstruo:=des.descripcion.PericiasMonstruo or ((des.descripcion.PericiasMonstruo and $3) shl 8);
    //remover antiguas
    //des.descripcion.PericiasMonstruo:=(des.descripcion.PericiasMonstruo or $3) xor $3;

    lista[des.tipoMonstruo]:=des.descripcion;
    CB_codigo.Items[des.tipoMonstruo]:=inttostr(des.tipoMonstruo)+'.'+des.descripcion.nombre;
  end;
  //cerrar archivo
  closefile(f);
  CB_codigo.ItemIndex:=0;
  InicializarFormulario(0);
end;

procedure TForm1.AbrirManual1Click(Sender: TObject);
begin
  with OpenDialog do
    if execute then AbrirMan(filename);
end;

procedure TForm1.GuardarMan(const nombre:string);
var
   f:file of TDescripcionMonstruoYTipo;
   des:TDescripcionMonstruoYTipo;
   i:integer;
begin
  ActualizarLista;
  //relacionar archivo con variable
  assignfile(f,nombre);
  //abrir para sobreescribir
  rewrite(f);
  for i:=0 to Fin_tipo_monstruos do
  if listaactivos[i] then
  begin
    des.tipoMonstruo:=i;
    des.descripcion:=lista[i];
    //escribir la variable des
    write(f,des);
  end;
  //cerrar archivo
  closefile(f);
  guardado:=true;
end;

procedure TForm1.GuardaresteManual1Click(Sender: TObject);
begin
  with SaveDialog do
  begin
    FileName:=OpenDialog.FileName;
    if execute then GuardarMan(filename);
  end;
end;

procedure TForm1.EditNombreChange(Sender: TObject);
var estado:boolean;
begin
     estado:=CB_guardar.Checked;
     if estado<>(length(EditNombre.text)>1) then
       CB_guardar.Checked:=not estado;
end;

procedure TForm1.InicializarFormulario(n:byte);
begin
  CB_guardar.Checked:=listaActivos[n];
  EditCodigo.text:=inttostr(n);
  with lista[n] do
  begin
    EditNombre.text:=nombre;

    C_ZonaCivilizada.checked:=(terreno and ft_ZonaCivilizada)<>0;
    C_ZonaSalvaje.checked:=(terreno and ft_TierraSalvaje)<>0;
    C_TerrenoSolido.checked:=(terreno and ft_TerrenoSolido)<>0;
    C_Agua.checked:=(terreno and ft_Agua)<>0;
    C_fuego.checked:=(terreno and ft_Fuego)<>0;

    CB_Cortantes.ItemIndex:=resistencias and $F;
    CB_Punzantes.ItemIndex:=(resistencias shr 4) and $F;
    CB_contundentes.ItemIndex:=(resistencias shr 8) and $F;
    CB_Veneno.ItemIndex:=(resistencias shr 12) and $F;
    CB_Fuego.ItemIndex:=(resistencias shr 16) and $F;
    CB_Hielo.ItemIndex:=(resistencias shr 20) and $F;
    CB_Rayo.ItemIndex:=(resistencias shr 24) and $F;
    CB_Magia.ItemIndex:=(resistencias shr 28) and $7;
    //De los monstruos
    E_ataque.text:=inttostr(Nivelataque);
    E_Defensa.text:=inttostr(Defensa);
    E_HPB.text:=inttostr(HPPromedio);
    E_Exp.text:=inttostr(PExperiencia);
    CB_tamanno.ItemIndex:=tamanno mod 5;
    E_nivel.text:=inttostr(NivelMonstruo);
    CB_Tesoro.ItemIndex:=tesoro;
    CB_TesoroAzar.ItemIndex:=TesoroAzar;
    CB_sociedad.ItemIndex:=visibilidad;
    CB_alineacion.ItemIndex:=alineacion;
    CB_combate.ItemIndex:=Comportamiento;
    CB_consecuenciaMuerte.ItemIndex:=ord(ConsecuenciaMuerte);
    CB_EstiloAnimacion.ItemIndex:=ord(EstiloAnimacion);
    E_ModTesoro.text:=inttostr(ModificadorTesoro);
    E_Regeneracion.text:=inttostr(Regeneracion);
    CB_indice.ItemIndex:=movimiento;
    CB_estiloMuerte.ItemIndex:=ord(EstiloMuerte);
    case TiempoEntreAtaques of
      2:CB_TiempoEntreAtaques.ItemIndex:=0;
      4:CB_TiempoEntreAtaques.ItemIndex:=1;
      16:CB_TiempoEntreAtaques.ItemIndex:=3;
      else
        CB_TiempoEntreAtaques.ItemIndex:=2;
    end;
    //Ataques:
    with Ataque[0] do
    begin
      E_BA1.Text:=inttostr(base);
      E_PA1.Text:=inttostr(plus+base-1);
      CB_NA1.itemindex:=cdNombre;
      CB_TA1.itemindex:=tipoDanno;
    end;
    with Ataque[1] do
    begin
      E_BA2.Text:=inttostr(base);
      E_PA2.Text:=inttostr(plus+base-1);
      CB_NA2.itemindex:=cdNombre;
      CB_TA2.itemindex:=tipoDanno;
    end;
    with Ataque[2] do
    begin
      E_BA3.Text:=inttostr(base);
      E_PA3.Text:=inttostr(plus+base-1);
      CB_NA3.itemindex:=cdNombre;
      CB_TA3.itemindex:=tipoDanno;
    end;
    cb_Liderazgo.checked:=(PericiasMonstruo and perMon_Liderazgo)<>0;
    cb_encantar.checked:=(PericiasMonstruo and perMon_Encantamiento)<>0;
    cb_Paralizar.checked:=(PericiasMonstruo and perMon__Paralizar)<>0;
    cb_VisionVerdadera.checked:=(PericiasMonstruo and perMon__VisionVerdadera)<>0;
    cb_Aturdir.Checked:=(PericiasMonstruo and perMon__Aturdir)<>0;
    cb_Disipar.Checked:=(PericiasMonstruo and perMon__DisiparMagia)<>0;
  end;
end;

procedure TForm1.ActualizarLista;
var n:byte;
begin
n:=valor(EditCodigo.text,0,255);
listaActivos[n]:=cb_guardar.checked and (length(EditNombre.text)>0);
InicializarListaValoresUsuales(n);
if listaActivos[n] then
with lista[n] do
begin
  //Todos
  guardado:=false;
  nombre:=EditNombre.text;
  CB_codigo.Items[n]:=inttostr(n)+'.'+nombre;
  CB_codigo.ItemIndex:=n;
  terreno:=0;
  if C_ZonaCivilizada.Checked then
    terreno:=terreno or ft_ZonaCivilizada;
  if C_ZonaSalvaje.Checked then
    terreno:=terreno or ft_TierraSalvaje;
  if C_TerrenoSolido.Checked then
    terreno:=terreno or ft_TerrenoSolido;
  if C_fuego.Checked then
    terreno:=terreno or ft_Fuego;
  if C_agua.Checked then
    terreno:=terreno or ft_Agua;
  tamanno:=CB_tamanno.ItemIndex mod 5;
  NivelMonstruo:=valor(E_nivel.text,1,100);
  resistencias:=(CB_Cortantes.ItemIndex and $F);
  resistencias:=resistencias or ((CB_Punzantes.ItemIndex and $F)shl 4);
  resistencias:=resistencias or ((CB_contundentes.ItemIndex and $F)shl 8);
  resistencias:=resistencias or ((CB_Veneno.ItemIndex and $F)shl 12);
  resistencias:=resistencias or ((CB_Fuego.ItemIndex and $F)shl 16);
  resistencias:=resistencias or ((CB_Hielo.ItemIndex and $F)shl 20);
  resistencias:=resistencias or ((CB_Rayo.ItemIndex and $F)shl 24);
  resistencias:=resistencias or ((CB_Magia.ItemIndex and $7)shl 28);
  estiloMuerte:=TEstiloMuerte(CB_EstiloMuerte.itemindex);
  TiempoEntreAtaques:=1 shl (CB_TiempoEntreAtaques.ItemIndex+1);
  //Sólo monstruos
  if n>=Inicio_tipo_monstruos then
  begin
    //De los monstruos
    NivelAtaque:=valor(E_ataque.text,0,200);
    Defensa:=valor(E_defensa.text,0,200);
    Regeneracion:=valor(E_regeneracion.text,0,15);
    ModificadorTesoro:=valor(E_ModTesoro.text,0,255);
    HPPromedio:=valor(E_HPB.text,0,MAX_DEMONIO_HP);
    tesoro:=CB_tesoro.ItemIndex;
    tesoroAzar:=CB_tesoroAzar.ItemIndex;
    visibilidad:=CB_sociedad.ItemIndex;
    alineacion:=CB_alineacion.ItemIndex;
    comportamiento:=CB_combate.ItemIndex;
    ConsecuenciaMuerte:=TConsecuenciaMuerteMonstruo(cb_consecuenciaMuerte.itemindex);
    EstiloAnimacion:=TestiloAnimacion(CB_estiloAnimacion.itemindex);
    PExperiencia:=valor(E_Exp.text,NivelMonstruo*25,NivelMonstruo*100);
    movimiento:=CB_indice.itemIndex;
    with Ataque[0] do
    begin
      base:=valor(E_BA1.Text,1,250);
      plus:=valor(E_PA1.Text,base,250)+1-base;
      cdNombre:=CB_NA1.itemindex;
      tipoDanno:=CB_TA1.itemindex;
    end;
    with Ataque[1] do
    begin
      base:=valor(E_BA2.Text,1,250);
      plus:=valor(E_PA2.Text,base,250)+1-base;
      cdNombre:=CB_NA2.itemindex;
      tipoDanno:=CB_TA2.itemindex;
    end;
    with Ataque[2] do
    begin
      base:=valor(E_BA3.Text,1,250);
      plus:=valor(E_PA3.Text,base,250)+1-base;
      cdNombre:=CB_NA3.itemindex;
      tipoDanno:=CB_TA3.itemindex;
    end;
    PericiasMonstruo:=0;
    if cb_Liderazgo.checked then PericiasMonstruo:=PericiasMonstruo or perMon_Liderazgo;
    if cb_encantar.checked then PericiasMonstruo:=PericiasMonstruo or perMon_Encantamiento;
    if cb_Paralizar.checked then PericiasMonstruo:=PericiasMonstruo or perMon__Paralizar;
    if cb_VisionVerdadera.checked then PericiasMonstruo:=PericiasMonstruo or perMon__VisionVerdadera;
    if cb_Aturdir.Checked then PericiasMonstruo:=PericiasMonstruo or perMon__Aturdir;
    if cb_Disipar.Checked then PericiasMonstruo:=PericiasMonstruo or perMon__DisiparMagia;
  end;//if
end//with
else
begin
  CB_codigo.Items[n]:=inttostr(n);
  CB_codigo.ItemIndex:=n;
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  InicializarColeccionObjetos(Ruta_Aplicacion+'bin\obj.b');
  for i:=0 to 255 do
    CB_tesoro.items.add(NomObj[i]);
  for i:=0 to MaxNombresAtaques do
  begin
    CB_NA1.Items.Add(Nombre_Ataque[i]);
    CB_NA2.Items.Add(Nombre_Ataque[i]);
    CB_NA3.Items.Add(Nombre_Ataque[i]);
  end;
  LimpiarListas;
  for i:=0 to Fin_tipo_monstruos do
    CB_codigo.Items.Add(inttostr(i));
  CB_codigo.ItemIndex:=0;
  InicializarFormulario(0);
  if FileExists('..\laa\bin\std.mon') then
  begin
    OpenDialog.filename:='..\laa\bin\std.mon';
    AbrirMan(OpenDialog.filename);
  end;
  guardado:=true;
  Caption:=caption+getVersion;
end;

procedure TForm1.CB_codigoEnter(Sender: TObject);
begin
  ActualizarLista;
  InicializarFormulario(CB_codigo.ItemIndex);
end;

procedure TForm1.CB_codigoChange(Sender: TObject);
begin
    InicializarFormulario(CB_codigo.ItemIndex);
end;

procedure TForm1.EditCodigoChange(Sender: TObject);
var c,v:integer;
begin
     val(EditCodigo.text,v,c);
     if (c<>0) or (v<0) or (v>Fin_tipo_monstruos) then
     begin
      CB_Guardar.Checked:=false;
      EditCodigo.text:='';
     end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not guardado then
  begin
    canclose:=true;
    case MessageDlg('¿Guardar los cambios?',mtConfirmation,mbYesNoCancel,0) of
       mrYes:Guardar1Click(nil);
       mrNo:;
       else canclose:=false;
    end;
  end
end;

procedure TForm1.CB_guardarClick(Sender: TObject);
begin
  guardado:=false;
end;

procedure TForm1.InicializarListaValoresUsuales(n:integer);
var i:integer;
begin
  //Modificar valores:
  //Todos
  FillChar(Lista[n],sizeof(Lista[n]),0);
  with lista[n] do
  begin
    terreno:=ft_TierraSalvaje or ft_TerrenoSolido;
    tamanno:=2; //Mediano
    NivelMonstruo:=1; //Basico
    resistencias:=$7 or ($7shl 4) or ($7shl 8) or ($7shl 12) or
      ($7shl 16) or ($7shl 20) or ($7shl 24) or ($0 shl 28);
    //De los monstruos
    NivelAtaque:=0;
    Defensa:=50;
    Regeneracion:=0;
    ModificadorTesoro:=0;
    HPPromedio:=10;
    tesoro:=0;
    visibilidad:=1;
    alineacion:=0;
    comportamiento:=0;
    ConsecuenciaMuerte:=cmNinguno;
    EstiloAnimacion:=eaNormal;
    PExperiencia:=100;
    movimiento:=3;
    estiloMuerte:=emSangreRoja;
    for i:=0 to 2 do
      with Ataque[i] do
      begin
        base:=1;
        plus:=4;
        cdNombre:=0;
        tipoDanno:=0;
      end;
    TiempoEntreAtaques:=4;
  end;
end;

procedure TForm1.Llenarconvaloresusuales1Click(Sender: TObject);
var n:integer;
begin
  n:=valor(EditCodigo.text,0,255);
  InicializarListaValoresUsuales(n);
  InicializarFormulario(n);
end;

procedure TForm1.Cerrar2Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.Guardar1Click(Sender: TObject);
begin
  GuardarMan(OpenDialog.FileName);
end;



end.
