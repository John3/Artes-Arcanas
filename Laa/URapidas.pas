(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit URapidas;

interface

uses
  Windows, Forms, Gboton, StdCtrls, Classes, Controls;

type
  TAccionRapida=byte;
  TFRapidas = class(TForm)
    cb_tecla: TComboBox;
    cb_Accion: TComboBox;
    procedure BtnCancelarClick(Sender: TObject);
    procedure paint; override;
    procedure BtnGuardarClick(Sender: TObject);
    procedure Initialize();
    procedure cb_teclaChange(Sender: TObject);
    procedure cb_AccionChange(Sender: TObject);
  private
    { Private declarations }
    BtnCancelar,BtnGuardar:TGboton;
  public
    constructor create(AOwner:Tcomponent); override;
    { Public declarations }
  end;

  function RecuperarConfiguracionTeclasRapidas:boolean;
  function CodigoAccionACadena(Nro_accion:byte):string;
  procedure RealizarAccionRapida(tecla:word);

var
  ListaAccionRapida,ListaOriginalAccionRapida:array[0..35] of TAccionRapida;
  AccionAPosicion,PosicionAAccion:array[0..127] of byte;

implementation
uses Graphics,UMensajes,Globales,Objetos,Juego,MundoEspejo;

function RecuperarConfiguracionTeclasRapidas:boolean;
var f:file;
begin
  {$I-}
  assignFile(f,Ruta_Aplicacion+CARPETA_AVATARES+'teclasRapidas.cfg');
  reset(f,1);
  blockread(f,ListaAccionRapida,sizeOf(ListaAccionRapida));
  closefile(f);
  {$I+}
  result:=ioresult=0;
end;

function GuardarConfiguracionTeclasRapidas:boolean;
var f:file;
begin
  {$I-}
  assignFile(f,Ruta_Aplicacion+CARPETA_AVATARES+'teclasRapidas.cfg');
  rewrite(f,1);
  blockwrite(f,ListaAccionRapida,sizeOf(ListaAccionRapida));
  closefile(f);
  {$I+}
  result:=ioresult=0;
end;

procedure TFRapidas.paint;
const MSG_Configuracion_de_acciones_rapidas='CONFIGURACIÓN DE TECLAS RÁPIDAS';
begin
  PintarFondoNegro(self);
  with canvas do
  begin
    TextOut((width-textwidth(MSG_Configuracion_de_acciones_rapidas))div 2,8,MSG_Configuracion_de_acciones_rapidas);
    TextOut(16,40,'Tecla:');
    TextOut(16,72,'Acción:');
  end;
end;

procedure TFRapidas.BtnCancelarClick(Sender: TObject);
begin
  ListaAccionRapida:=ListaOriginalAccionRapida;//Restaurar valores originales
  close;
end;

procedure TFRapidas.BtnGuardarClick(Sender: TObject);
begin
  if GuardarConfiguracionTeclasRapidas then
    showmessagez('Configuración guardada...')
  else
    showmessagez('No fue posible guardar la configuración de teclas');
  close;
end;

constructor TFRapidas.create(AOwner:Tcomponent);
begin
  inherited create(AOwner);
  Left := 357;
  Top := 191;
  BorderStyle := bsNone;
  ClientHeight := 144;
  ClientWidth := 396;
  Color := clBlack;
  Font.Charset := DEFAULT_CHARSET;
  Font.Color := 12644596;
  Font.Height := -15;
  Font.Name := 'Times New Roman';
  Font.Style := [fsBold];
  OldCreateOrder := True;
  Position := poScreenCenter;
  Scaled := False;
  PixelsPerInch := 96;
  cb_Tecla:=TComboBox.create(self);
  with cb_tecla do
  begin
    Left := 72;
    Top := 36;
    Width := 69;
    Height := 25;
    Style := csDropDownList;
    Color := clBlack;
    Ctl3D := False;
    ItemHeight := 17;
    ParentCtl3D := False;
    TabOrder := 0;
    OnChange := cb_teclaChange;
    Parent := self;
  end;
  cb_Accion:=TComboBox.Create(self);
  with cb_Accion do
  begin
    Left := 72;
    Top := 68;
    Width := 309;
    Height := 25;
    Style := csDropDownList;
    Color := clBlack;
    Ctl3D := False;
    ItemHeight := 17;
    ParentCtl3D := False;
    TabOrder := 1;
    OnChange := cb_AccionChange;
    Parent := self;
  end;
  BtnCancelar:=TGBoton.create(self);
  with BtnCancelar do
  begin
    parent:=self;
    caption:='Cancelar';
    color:=clBronce;
    left:=252;
    top:=106;
    width:=96;
    height:=22;
    OnClick:=BtnCancelarClick;
  end;
  BtnGuardar:=TGBoton.create(self);
  with BtnGuardar do
  begin
    parent:=self;
    caption:='Guardar';
    color:=clBronce;
    left:=44;
    top:=106;
    width:=96;
    height:=22;
    OnClick:=BtnGuardarClick;
  end;
  Initialize();
end;

procedure TFRapidas.Initialize();
var i,posicion:integer;
  procedure AgregarItem;
  begin
    cb_Accion.Items.Add(CodigoAccionACadena(i));
    AccionAPosicion[i]:=posicion;
    PosicionAAccion[posicion]:=i;
    inc(posicion);
  end;
begin
  //teclas
  with cb_tecla do
  begin
    for i:=0 to 9 do
      Items.Add(char(i+48));
    for i:=0 to 25 do
      Items.Add(char(i+65));
  end;
  cb_tecla.ItemIndex:=0;
  posicion:=0;
  //acciones
  fillchar(PosicionAAccion,sizeOf(PosicionAAccion),0);
  i:=0;
  AgregarItem;
  i:=3;
  AgregarItem;//proteccion divina
  i:=4;
  AgregarItem;
  for i:=6 to 45 do
    AgregarItem;
  for i:=52 to 81 do
    if ((InfConjuro[i-52].BanderasCnjr and cjPuedeLanzarAsimismo)<>0) and
       ((InfConjuro[i-52].BanderasCnjr and cjPuedeLanzarObjetivo)<>0) then
      AgregarItem;
  for i:=88 to 96 do
    AgregarItem;
  for i:=109 to 112 do
    AgregarItem;
  for i:=121 to 126 do
    AgregarItem;
  cb_accion.ItemIndex:=AccionAPosicion[ListaAccionRapida[0]];
  ListaOriginalAccionRapida:=ListaAccionRapida;//copia el contenido
end;

function CodigoAccionACadena(Nro_accion:byte):string;
begin
  case Nro_accion of
    0:result:='<No asignado>';
    3:result:='Tomar '+NomObj[224];
    4..15:result:='Tomar '+NomObj[152+Nro_accion];
    16..45:begin
      result:='Hechizo: '+NomConjuro[Nro_accion-16];
      if ((InfConjuro[Nro_accion-16].BanderasCnjr and cjPuedeLanzarObjetivo)<>0) and
        ((InfConjuro[Nro_accion-16].BanderasCnjr and cjPuedeLanzarAsimismo)<>0) then
        result:=result+' (al objetivo)';
    end;
    //46..53=extensión futura.
    52..81:result:='Hechizo: '+NomConjuro[Nro_accion-52]+' (a uno mismo)';
    //72..80=extensión futura.
    //81..adelante, ordenes especiales:
    88:result:='Lanzar hechizo elegido (al objetivo)';
    89:result:='Lanzar hechizo elegido (a uno mismo)';
    90:result:='Usar objeto';
    91:result:='Alzar objeto';
    92:result:='Soltar objeto';
    93:result:='Revisar cadaver, bolsas, etc';
    94:result:='Activar ira tenax';
    95:result:='Activar zoomorfismo';
    96:result:='Ocultarse';

    109:result:='Ver mejoras del Castillo';
    110:result:='Ordenar Atacar';
    111:result:='Ordenar Seguir';
    112:result:='Ordenar Detenerse';

    121:result:='Ver mi posición actual';
    122:result:='Usar Palabra del Retorno';
    123:result:='Descansar';
    124:result:='Meditar';
    125:result:='Comer/Beber';
    126:result:='Equipar munición';
    else result:='';
  end;
end;

procedure TFRapidas.cb_teclaChange(Sender: TObject);
begin
  cb_accion.ItemIndex:=AccionAPosicion[ListaAccionRapida[cb_tecla.itemindex]];
end;

procedure TFRapidas.cb_AccionChange(Sender: TObject);
begin
  ListaAccionRapida[cb_tecla.itemindex]:=PosicionAAccion[cb_accion.ItemIndex];
end;

procedure RealizarAccionRapida(tecla:word);
var i:integer;
    ElArmaDeRango:Tartefacto;
    AnteriorSeleccionado,CodAccion:byte;
begin
  if tecla>=65 then
    dec(tecla,55)
  else
    dec(tecla,48);
  if (tecla>35) then exit;//seguridad
  CodAccion:=ListaAccionRapida[tecla];
  case CodAccion of
    3:begin//protección divina
      for i:=0 to MAX_ARTEFACTOS do
        if (JugadorCl.artefacto[i].id=224) then
        begin
          Jform.RealizarAccion(mbRight,uConsumible,i);
          exit;
        end;
      Jform.MensajeAyuda:='No te queda ni una "'+NomObj[224]+'"';
    end;
    4..7:begin
      for i:=0 to MAX_ARTEFACTOS do
        if (JugadorCl.artefacto[i].id=(CodAccion+152)) then
        begin
          Jform.RealizarAccion(mbRight,uConsumible,i);
          exit;
        end;
      Jform.MensajeAyuda:='No tienes "'+NomObj[152+codAccion]+'"';
    end;
    8..15:begin
      for i:=0 to MAX_ARTEFACTOS do
        if (JugadorCl.artefacto[i].id=(CodAccion+152)) then
        begin
          Jform.RealizarAccion(mbRight,uConsumible,i);
          exit;
        end;
      Jform.MensajeAyuda:='No te queda ni una "'+NomObj[152+codAccion]+'"';
    end;
    16..45:begin
      AnteriorSeleccionado:=JugadorCl.ConjuroElegido;
      JugadorCl.ConjuroElegido:=(CodAccion-16);
      MapaEspejo.JLanzarConjuro(false,false);
      JugadorCl.ConjuroElegido:=AnteriorSeleccionado;
    end;
    52..81:begin
      AnteriorSeleccionado:=JugadorCl.ConjuroElegido;
      JugadorCl.ConjuroElegido:=(CodAccion-52);
      MapaEspejo.JLanzarConjuro(true,false);
      JugadorCl.ConjuroElegido:=AnteriorSeleccionado;
    end;

    88:MapaEspejo.JLanzarConjuro(false,false);
    89:MapaEspejo.JLanzarConjuro(true,false);
    90:Jform.Accion_Usar;
    91:MapaEspejo.JAlzarObjeto;
    92:MapaEspejo.JSoltarObjetoElegido(0);
    93:MapaEspejo.JRevisarObjetos;
    94:JIraTenax;
    95:JZoomorfismo;
    96:JOcultarse;

    109:MapaEspejo.JMostrarEstadoDelCastillo;
    110:JenviarOrden('a');
    111:JenviarOrden('s');
    112:JenviarOrden('d');

    121:MapaEspejo.JMostrarPosicionActual;
    122:JPalabraDelRetorno;
    123:MapaEspejo.JDescansar;
    124:MapaEspejo.JMeditar;
    125:begin
      for i:=0 to MAX_ARTEFACTOS do
        if ((JugadorCl.artefacto[i].id>=144) and (JugadorCl.artefacto[i].id<=159)) then
        begin
          Jform.RealizarAccion(mbRight,uConsumible,i);
          exit;
        end;
      Jform.MensajeAyuda:='No tienes nada que se pueda comer o beber';
    end;
    126:begin
      ElArmaDeRango:=JugadorCl.Usando[uArmaDer];
      if InfObj[ElArmaDeRango.id].TipoArma<>taMunicion then
      begin
        ElArmaDeRango:=JugadorCl.Usando[uArmaIzq];
        if InfObj[ElArmaDeRango.id].TipoArma<>taMunicion then
        begin
          Jform.MensajeAyuda:='No tienes un arma de rango en tus manos';
          exit;
        end;
      end;
      for i:=0 to MAX_ARTEFACTOS do
        if MunicionCorrecta(ElArmaDeRango,JugadorCl.artefacto[i]) then
        begin
          Jform.RealizarAccion(mbRight,uMunicion,i);
          exit;
        end;
      Jform.MensajeAyuda:='No te queda munición en tu bolso';
    end;
  end;
end;

end.

