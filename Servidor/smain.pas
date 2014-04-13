{Configuración para el compilador (cliente y servidor):
-------------------------------------------------------
ACTIVADOS:
Optimización
Alineación
Stric Var-Strings
Extended Sintax
Open Parameters
Huge Strings

NO ACTIVADOS:
Stack Frames
Complete Boolean Eval
Typed @ Operator
Assignable Typed Constants
}
unit smain;
interface
//Para evitar caracteres extraños en los mensajes.
//Para mostrar estadísticas
{$DEFINE CONTROL_ESTADISTICAS}
uses
  Forms,Sysutils,Graphics,Windows,TrayIcon,ScktComp,Menus,StdCtrls,Classes,Controls,
  globales,ComCtrls,demonios,tablero, ExtCtrls,gtimer;
const
  FRECUENCIA_ALTA=134;//160
  FRECUENCIA_BASE=FRECUENCIA_ALTA shr 1;// /2
  FRECUENCIA_MEDIA=FRECUENCIA_ALTA shl 1;//*2

type
  TMainForm = class(TForm)
    PanelBajo: TPanel;
    MainMenu1: TMainMenu;
    Servidor1: TMenuItem;
    FindelMundo1: TMenuItem;
    Universo1: TMenuItem;
    Desactivar1: TMenuItem;
    TestVarios1: TMenuItem;
    tamaos1: TMenuItem;
    Label2: TLabel;
    Edit2: TEdit;
    Activar1: TMenuItem;
    Edit1: TEdit;
    Label1: TLabel;
    Acercade1: TMenuItem;
    Estadsticas1: TMenuItem;
    Bytesrecibidos1: TMenuItem;
    Resertearestadsticas1: TMenuItem;
    FrecuenciaAlta: TMenuItem;
    FrecuenciaBaja: TMenuItem;
    Utilitarios1: TMenuItem;
    GuardarPersonajes1: TMenuItem;
    IniciarNoche1: TMenuItem;
    IniciarNiebla1: TMenuItem;
    IniciarLluvia1: TMenuItem;
    Terminarefectoambiental1: TMenuItem;
    TestAmb: TMenuItem;
    LbMensaje: TLabel;
    AdministracindePersonajes1: TMenuItem;
    Test1: TMenuItem;
    N2: TMenuItem;
    ServidorModoVerificacion1: TMenuItem;
    Opcionesdelservidor1: TMenuItem;
    Ocultar1: TMenuItem;
    TestNocheLluviosa1: TMenuItem;
    Enviarmensajeatodoslosjugadores1: TMenuItem;
    Enviarmensajeatodoslosjugadores2: TMenuItem;
    Parmetrosdelservidor1: TMenuItem;
    Tiempoentreengendrodemonstruos1: TMenuItem;
    Cambiarpuerto1: TMenuItem;
    N6: TMenuItem;
    Comunicacintotalcon1: TMenuItem;
    N7: TMenuItem;
    N1: TMenuItem;
    AgregarAdminA1: TMenuItem;
    Desactivarcomandosdea1: TMenuItem;
    N8: TMenuItem;
    VerConexionesImprocedentes1: TMenuItem;
    AgregarGameMaster1: TMenuItem;
    ExpulsarJugador1: TMenuItem;
    MantenerRegistro1: TMenuItem;
    FechayHoraenRegistro1: TMenuItem;
    Jugadoresactivos1: TMenuItem;
    Memo: TMemo;
    Archivos1: TMenuItem;
    Guardarclanes1: TMenuItem;
    Clanesactivos1: TMenuItem;
    N3: TMenuItem;
    AdministrarClanes1: TMenuItem;
    EliminarClanesinactivos1: TMenuItem;
    AutoGuardarInformacin1: TMenuItem;
    AgregarAdminB1: TMenuItem;
    Limpiarelsuelo1: TMenuItem;
    AdministrarMapas1: TMenuItem;
    Limpiarcadveres1: TMenuItem;
    N4: TMenuItem;
    Permitirmultiplessesiones1: TMenuItem;
    Eliminarbolsasycadveres1: TMenuItem;
    Mostrarconexionesydesconexiones: TMenuItem;
    N5: TMenuItem;
    LimpiarPeriodicamente1: TMenuItem;
    ConvertirenSuperAmodelCalabozo1: TMenuItem;
    procedure FindelMundo1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Desactivar1Click(Sender: TObject);
    procedure SSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure SSocketClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure tamaos1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Activar1Click(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TimerTimer(Sender: TObject);
    procedure Acercade1Click(Sender: TObject);
    procedure Bytesrecibidos1Click(Sender: TObject);
    procedure Resertearestadsticas1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FrecuenciaClick(Sender: TObject);
    procedure GuardarPersonajes1Click(Sender: TObject);
    procedure IniciarNoche1Click(Sender: TObject);
    procedure IniciarNiebla1Click(Sender: TObject);
    procedure IniciarLluvia1Click(Sender: TObject);
    procedure Terminarefectoambiental1Click(Sender: TObject);
    procedure OpcionMenuClick(Sender: TObject);
    procedure Ocultar1Click(Sender: TObject);
    procedure TestNocheLluviosa1Click(Sender: TObject);
    procedure Enviarmensajeatodoslosjugadores2Click(Sender: TObject);
    procedure Tiempoentreengendrodemonstruos1Click(Sender: TObject);
    procedure Cambiarpuerto1Click(Sender: TObject);
    procedure Desactivarcomandosdea1Click(Sender: TObject);
    procedure AgregarAdministradorClick(Sender: TObject);
    procedure ExpulsarJugador1Click(Sender: TObject);
    procedure Jugadoresactivos1Click(Sender: TObject);
    procedure Guardarclanes1Click(Sender: TObject);
    procedure Clanesactivos1Click(Sender: TObject);
    procedure EliminarClanesinactivos1Click(Sender: TObject);
    procedure Limpiarelsuelo1Click(Sender: TObject);
    procedure Limpiarcadveres1Click(Sender: TObject);
    procedure RestaurarAplicacion(Sender: TObject);
    procedure MinimizarAplicacionEnBanjeja(Sender: TObject);

  private
    { Private declarations }
      ServerTrayIcon:TTrayIcon;
      IconoEstadoInactivo,IconoEstadoActivo:TIcon;
  public
    { Public declarations }
    procedure InterpretarComandos(Socket: TCustomWinSocket);
  end;
var
  MainForm: TMainForm;
  procedure EnviarATodosAhora(const s:string);
  procedure EnviarATodos(const s:string);
  procedure EnviarATodos_J(codJugador:word;const s:string);
  procedure EnviarAlMapa(codigoMapa:byte;const s:string);
  procedure EnviarAlMapa_J(ElJugador:TjugadorS;const s:string);
  procedure EnviarAlAreaJugador_J(codJugador:word;const s:string);
  procedure EnviarAlAreaMonstruo(Monstr:TmonstruoS;const s:string);
  procedure EnviarAlClan_J(codJugador:word;const s:string);

implementation
{$R *.DFM}

uses usuarios,mundo,dialogs,objetos;

const
  M_ElUsuarioDebeIniciarSesion='El usuario tiene que iniciar una sesión en el servidor';
  M_NoEsIdentificadorValido='No es un identificador válido';
  M_ElServidorNoGuardaEnModoDePruebas='El servidor no guarda información en modo de pruebas';

function NombreCodJugador(codJugador:word):string;
begin
  if (codJugador>MaxJugadores) then
    result:='¡ERROR!'
  else
    if DatosUsuario[codJugador].EstadoUsuario>euAutentificado then
      result:='"'+Jugador[codJugador].nombreAvatar+'"'
    else
      result:='<Invitado>';
  result:=result+' #'+inttostr(codJugador);
end;

function LimpiarCadena(const cad:string):string;
var i:integer;
begin
  result:='';
  for i:=1 to length(cad) do
    if (ord(cad[i])>=32) and (ord(cad[i])<>127) and (ord(cad[i])<>36) then
      result:=result+cad[i]
    else
      result:=result+'$'+IntToHex(ord(cad[i]),2);
end;

procedure TMainForm.FindelMundo1Click(Sender: TObject);
begin
  close;
end;

procedure InterpretarErrorEnSocket(Error:integer;elSocket:pointer;const origen:string);
var s:string;
begin
  case Error of
    10048:s:='* El puerto de comunicación no está disponible';
    10054:s:='* Conexión cerrada por la máquina cliente';
    10053:s:='* Conexion cerrada por la aplicación cliente';
    else
      if origen='' then
        s:='* Error '+inttostr(Error)
      else
        s:='* Error '+inttostr(Error)+' '+origen;
  end;
  if elSocket<>nil then
    s:=s+' Socket:'+intastr(integer(elSocket));
  mensaje(s);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Randomize;
  //Ajustar menus a configuración guardada en archivo:
  Comunicacintotalcon1.Checked:=ServidorEnModoDeComunicacionTotal;
  MantenerRegistro1.Checked:=MantenerRegistroDelServidor;
  FechayHoraenRegistro1.Checked:=FechaYHoraEnRegistroDelServidor;
  //Inicialización de Timer
  Timer:=TGTimer.create();
  with Timer do
  begin
    Enabled:= False;
    Interval:= FRECUENCIA_ALTA;
    OnTimer:= TimerTimer;
  end;
  //Inicialización de Puerto
  SSocket:=TServerSocket.create(self);
  with SSocket do
  begin
    Active:= False;
    Port:=G_PuertoComunicacion;
    Address:=G_IpDelServidor;
    OnClientConnect:= SSocketClientConnect;
    OnClientDisconnect:= SSocketClientDisconnect;
    OnClientRead:= SSocketClientRead;
    OnClientError:= SSocketClientError;
  end;
  //Inicializacion de Tray icon
  ServerTrayIcon:=TTrayIcon.create(self);
  with ServerTrayIcon do
  begin
    OnClick:=RestaurarAplicacion;
    ToolTip:='Servidor LAA';
  end;
  Application.OnMinimize:=MinimizarAplicacionEnBanjeja;
  IconoEstadoInactivo:=TIcon.Create;
  IconoEstadoInactivo.Handle:=loadIcon(HInstance,'MAINICON');
  IconoEstadoActivo:=TIcon.Create;
  IconoEstadoActivo.Handle:=loadIcon(HInstance,'DARKICON');
{$IFNDEF CONTROL_ESTADISTICAS}
  Estadsticas1.visible:=false;
{$ENDIF}
  SocketErrorProc:=InterpretarErrorEnSocket;
  caption:='Legado de las artes arcanas ('+getVersion+')';
  //Formatos de fecha y otros
  ShortDateFormat:='yy"."mm"."dd';
  LongTimeFormat:='hh:mm:ss';
  //Creación e inicialización
  Mundo.crear;//Ambiente del juego
  InicializarRegistro(ExtractFilePath(ParamStr(0))+CARPETA_AVATARES);
  if not Mundo.Mundopreparado then
  begin
    Mundo.inicializarMundo;
    Mensaje('Servidor inicializado');
    if paramCount>=1 then
      if paramstr(1)='ACTIVAR' then
      begin
        Activar1Click(nil);
        WindowState:=wsMinimized;
      end;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  IconoEstadoActivo.free;
  IconoEstadoInactivo.free;
  SSocket.free;
  Timer.free;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Mundo.finalizarMundo;
  if MantenerRegistroDelServidor then
    RealizarMantenerArchivo(Memo.lines.Count);
end;

procedure TMainForm.RestaurarAplicacion(Sender: TObject);
begin
  ServerTrayIcon.Active:=false;
  show;
  Application.BringToFront;
  Application.Restore;  
end;

procedure TMainForm.MinimizarAplicacionEnBanjeja(Sender: TObject);
begin
  hide;
  if MundoActivo then
    ServerTrayIcon.Icon:=IconoEstadoActivo
  else
    ServerTrayIcon.Icon:=IconoEstadoInactivo;
  ServerTrayIcon.Active:=true;
end;

procedure TMainForm.Activar1Click(Sender: TObject);
begin
if MundoPreparado then
  if not MundoActivo then
  begin
    ServidorEnModoDeVerificacion:=ServidorModoVerificacion1.Checked;
    LbMensaje.caption:=activarMundo();
    if ServidorEnModoDeVerificacion then
    begin
      Memo.color:=$00004070;
      PanelBajo.color:=$004080F0;
    end
    else
    begin
      Memo.color:=$00704018;
      PanelBajo.color:=$00FFD8A0;
    end;
    Desactivar1.Enabled:=true;
    Opcionesdelservidor1.Enabled:=false;
    activar1.Enabled:=false;
    Utilitarios1.Enabled:=true;
    Test1.Enabled:=true;
  end;
end;

procedure TMainForm.Desactivar1Click(Sender: TObject);
begin
if MundoPreparado then
  if MundoActivo then
    if desactivarMundo then
    begin
      Memo.color:=0;
      PanelBajo.color:=clBtnFace;
      LbMensaje.caption:='';
      Mensaje('El servidor está desactivado.');
      Activar1.enabled:=true;
      Opcionesdelservidor1.Enabled:=true;
      Test1.Enabled:=false;
      Utilitarios1.Enabled:=false;
      Desactivar1.enabled:=false;
    end;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  try
    if (EnUso) then mensaje('(i) Entrada concurrente a Mundo.tickMundo()');
    EnUso:=true;
    Mundo.tickMundo;
//    sleep(320);
    EnUso:=false;
  except
    on E: Exception do Mensaje('Excepción de tipo "Exception" en Mundo.tickMundo() :' + #13 + E.Message);
    else Mensaje('Excepcion desconocida en Mundo.tickMundo');
  end;
end;

procedure TMainForm.Acercade1Click(Sender: TObject);
begin
  showmessage(CREADO_POR);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if height<300 then height:=300;
  if width<480 then width:=480;
end;

//*****************************************************************************
//                    ADMINISTRADOR DE COMANDOS DE LOS JUGADORES
//*****************************************************************************
procedure EnviarATodos(const s:string);
var i:integer;
begin
  for i:=0 to maxjugadores do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].activo then
        SocketDelJugador[i].sendText(s);
end;

procedure EnviarATodosAhora(const s:string);
var i:integer;
begin
  for i:=0 to maxjugadores do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].activo then
        SocketDelJugador[i].sendTextNow(s);
end;

procedure EnviarATodos_J(codJugador:word;const s:string);
var i:integer;
begin
  if codJugador>maxjugadores then exit;
  for i:=0 to codJugador-1 do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].activo then
        SocketDelJugador[i].sendText(s);
  for i:=codJugador+1 to maxjugadores do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].activo then
        SocketDelJugador[i].sendText(s);
end;

procedure EnviarAlMapa_J(ElJugador:TjugadorS;const s:string);
var i,limite:integer;
    codigoDelMapa:byte;
begin
  if ElJugador=nil then exit;
  codigoDelMapa:=ElJugador.codMapa;
  limite:=ElJugador.codigo-1;
  for i:=0 to limite do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].codMapa=codigoDelMapa then
        if Jugador[i].activo then
          SocketDelJugador[i].sendText(s);
  limite:=ElJugador.codigo+1;
  for i:=limite to maxjugadores do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].codMapa=codigoDelMapa then
        if Jugador[i].activo then
          SocketDelJugador[i].sendText(s);
end;

procedure EnviarAlClan_J(codJugador:word;const s:string);
var i:integer;
    codigoDelClan:byte;
begin
  if codJugador>maxjugadores then exit;
  codigoDelClan:=Jugador[codJugador].clan;
  for i:=0 to codJugador-1 do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].clan=codigoDelClan then
        if Jugador[i].activo then
          SocketDelJugador[i].sendText(s);
  for i:=codJugador+1 to maxjugadores do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].clan=codigoDelClan then
        if Jugador[i].activo then
          SocketDelJugador[i].sendText(s);
end;

procedure EnviarAlMapa(codigoMapa:byte;const s:string);
var i:integer;
begin
  for i:=0 to maxjugadores do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].codMapa=codigoMapa then
        if Jugador[i].activo then
          SocketDelJugador[i].sendText(s);
end;

procedure EnviarAlAreaMonstruo(Monstr:TmonstruoS;const s:string);
var i:integer;
    coordx_R,coordy_R:integer;
    codigoMapaJ:byte;
begin
  if Monstr=nil then exit;
  with Monstr do
  begin
    codigoMapaJ:=codMapa;
    coordX_R:=coordx;
    coordY_R:=coordy;
  end;
  for i:=0 to maxjugadores do
    if SocketDelJugador[i]<>nil then
      with Jugador[i] do
        if codMapa=codigoMapaJ then
          if activo then
            if (abs(coordx-Coordx_R)<=MaxRefrescamientoX) and (abs(coordy-Coordy_R)<=MaxRefrescamientoY) then
              SocketDelJugador[i].sendText(s);
end;

procedure EnviarAlAreaJugador_J(codJugador:word;const s:string);
var i:integer;
    coordx_R,coordy_R:integer;
    codigoMapaJ:byte;
begin
  if codJugador>maxjugadores then exit;
  with Jugador[codJugador] do
  begin
    codigoMapaJ:=codMapa;
    coordX_R:=coordx;
    coordY_R:=coordy;
  end;
  for i:=0 to codJugador-1 do
    if SocketDelJugador[i]<>nil then
      with Jugador[i] do
        if codMapa=codigoMapaJ then
          if activo then
            if (abs(coordx-Coordx_R)<=MaxRefrescamientoX) and (abs(coordy-Coordy_R)<=MaxRefrescamientoY) then
              SocketDelJugador[i].sendText(s);
  for i:=codJugador+1 to maxjugadores do
    if SocketDelJugador[i]<>nil then
      with Jugador[i] do
        if codMapa=codigoMapaJ then
          if activo then
            if (abs(coordx-Coordx_R)<=MaxRefrescamientoX) and (abs(coordy-Coordy_R)<=MaxRefrescamientoY) then
              SocketDelJugador[i].sendText(s);
end;

procedure TMainForm.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=123 then
  begin
    Memo.lines.add(CREADO_POR);
    TestVarios1.visible:=true;
    label1.visible:=true;
    label2.visible:=true;
    Edit1.visible:=true;
    Edit2.visible:=true;
  end;
end;

procedure TMainForm.FrecuenciaClick(Sender: TObject);
var Nuevo_Intervalo:integer;
begin
  with TMenuItem(Sender) do
  if not Checked then
  begin
    FrecuenciaAlta.Checked:=false;
    FrecuenciaBaja.Checked:=false;
    Checked:=true;
    Nuevo_Intervalo:=Frecuencia_ALTA;
    if FrecuenciaBaja.Checked then
      Nuevo_Intervalo:=Frecuencia_MEDIA;
    if Nuevo_Intervalo<>Timer.Interval then
    begin
      Timer.Interval:=Nuevo_Intervalo;
      if MundoActivo then
        EnviarATodos('IV'+char(Nuevo_Intervalo div FRECUENCIA_BASE));
    end;
  end;
end;

procedure TMainForm.GuardarPersonajes1Click(Sender: TObject);
begin
  if ServidorEnModoDeVerificacion then
    Mensaje(M_ElServidorNoGuardaEnModoDePruebas)
  else
  begin
    Mensaje('GUARDANDO información de los avatares activos...');
    GuardarTodosLosPersonajes;
  end;
end;

procedure TMainForm.IniciarNoche1Click(Sender: TObject);
begin
  IniciarClima(CL_NOCHE);
end;

procedure TMainForm.IniciarNiebla1Click(Sender: TObject);
begin
  IniciarClima(CL_BRUMA);
end;

procedure TMainForm.IniciarLluvia1Click(Sender: TObject);
begin
  IniciarClima(CL_LLUVIOSO);
end;

procedure TMainForm.TestNocheLluviosa1Click(Sender: TObject);
begin
  IniciarClima(CL_LLUVIA_NOCHE);
end;

procedure TMainForm.Terminarefectoambiental1Click(Sender: TObject);
begin
  FinalizarClima;
end;

procedure TMainForm.Ocultar1Click(Sender: TObject);
begin
  hide;
end;

procedure TMainForm.Enviarmensajeatodoslosjugadores2Click(Sender: TObject);
var CadenaMensaje:TCadena127;
begin
  CadenaMensaje:=copy(trim(InputBox('Mensaje a todos los jugadores', 'Mensaje:', '')),1,79);
  if CadenaMensaje<>'' then
    EnviarATodos('I!'+CadenaMensaje[0]+CadenaMensaje);
end;

procedure TMainForm.OpcionMenuClick(Sender: TObject);
var nuevoEstado:bytebool;
begin
  if sender is TMenuItem then
  begin
    TMenuItem(sender).Checked:=not TMenuItem(sender).Checked;
    nuevoEstado:=TMenuItem(sender).Checked;
    if sender=Comunicacintotalcon1 then
      ServidorEnModoDeComunicacionTotal:=nuevoEstado
    else if sender=Permitirmultiplessesiones1 then
      ServidorEnModoMultiplesSesiones:=nuevoEstado
    else if sender=MantenerRegistro1 then
      MantenerRegistroDelServidor:=nuevoEstado
    else if sender=FechayHoraenRegistro1 then
      FechaYHoraEnRegistroDelServidor:=nuevoEstado
    else if sender=ServidorModoVerificacion1 then
      if TMenuItem(sender).Checked then
        ShowMessage('ADVERTENCIA: En modo de Pruebas el servidor NO guardará los cambios realizados en objetos, dinero, experiencia, niveles, castillos, clanes, etc.'+
        ' Tampoco se pueden crear nuevos avatares en esta modalidad del servidor.');
  end;
end;

procedure TMainForm.Tiempoentreengendrodemonstruos1Click(Sender: TObject);
var temp:integer;
begin
  temp:=TurnosEntreEngendroDeMonstruos;
  while not controlParametroEntero(InputBox('Tiempo de reengendro de criaturas', 'Turnos: [1..250]',
    inttostr(TurnosEntreEngendroDeMonstruos)),1,250,temp) do;
  TurnosEntreEngendroDeMonstruos:=temp;
end;

procedure TMainForm.Cambiarpuerto1Click(Sender: TObject);
var cad:string;
    nro,code:integer;
begin
  cad:=InputBox('Cambiando Puerto de Comunicación', 'Nuevo Puerto (Un número de '+
    inttostr(MIN_PUERTO_COMUNICACION)+' a '+inttostr(MAX_PUERTO_COMUNICACION)+'):'
    , inttostr(SSocket.Port));
  val(cad,nro,code);
  if code<>0 then exit;
  if (nro<MIN_PUERTO_COMUNICACION) or (nro>MAX_PUERTO_COMUNICACION) then exit;
  SSocket.Port:=nro;
end;

//******************************************************************************
// ESTADISTICAS
//******************************************************************************
procedure TMainForm.Bytesrecibidos1Click(Sender: TObject);
var segundos:double;
    cad,temp:string;
begin
  segundos:=(Now-FechaHoraInicio)*86400;
  if int(segundos)<1 then segundos:=0.05;
  str(segundos:0:2,temp);
  cad:='Segundos: '+temp+#13;
  cad:=cad+'Bytes Netos: '+inttostr(NrBytesrecibidos)+#13;
  str((NrBytesrecibidos/segundos):0:2,temp);
  cad:=cad+'Promedio B/s Netos: '+temp+#13;
  cad:=cad+'Paquetes: '+inttostr(NumeroArribosDatos)+#13;
  str((NumeroArribosDatos/segundos):0:2,temp);
  cad:=cad+'Promedio paq./s: '+temp+#13;
  if NumeroArribosDatos<1 then
  begin
    showmessage('Sin flujo de datos');
    exit;
  end;
  str((NrBytesrecibidos/NumeroArribosDatos):0:2,temp);
  cad:=cad+'Promedio B/paq.: '+temp+#13;
  str(((NrBytesrecibidos+NumeroArribosDatos*48)/segundos):0:2,temp);
  cad:=cad+'Promedio real estimado (+48) B/s: '+temp;
  showmessage(cad);
end;

procedure TMainForm.Resertearestadsticas1Click(Sender: TObject);
begin
  NrBytesrecibidos:=0;
  NumeroArribosDatos:=0;
  FechaHoraInicio:=now;
end;

//******************************************************************************
//Auxiliares de testeo de funciones
//******************************************************************************

procedure TMainForm.tamaos1Click(Sender: TObject);
begin
  mensaje('TMonstruoS: '+inttostr(TMonstruoS.InstanceSize));
  mensaje('TJugadorS: '+inttostr(TJugadorS.InstanceSize));
  mensaje('TPersonaje: '+inttostr(Sizeof(TPersonaje)));
  mensaje('TDatosUsuario: '+inttostr(sizeOf(TDatosUsuario)));
  mensaje('TUsuario: '+inttostr(sizeOf(TUsuario))+' ('+inttostr(4+Sizeof(TPersonaje)+sizeOf(TDatosUsuario))+')');
  mensaje('TClanJugadores: '+inttostr(TClanJugadores.InstanceSize));
end;

procedure TMainForm.AgregarAdministradorClick(Sender: TObject);
var ID_Conexion:integer;
    nomCategoria,cad:string;
    EstadoNuevo:TEstadoUsuario;
begin
  if sender=ConvertirenSuperAmodelCalabozo1 then
  begin
    EstadoNuevo:=euSuperGameMaster;
    nomCategoria:='Super Amo del Calabozo';
  end
  else
  if sender=AgregarGameMaster1 then
  begin
    EstadoNuevo:=euGameMaster;
    nomCategoria:='Amo del Calabozo';
  end
  else
  if sender=AgregarAdminA1 then
  begin
    EstadoNuevo:=euAdminA;
    nomCategoria:='Admin. clase A';
  end
  else
  begin
    EstadoNuevo:=euAdminB;
    nomCategoria:='Admin. clase B';
  end;
  cad:=trim(InputBox('Convertir en '+nomCategoria,'Identificador del Avatar:',''));
  if cad='' then exit;
  cad:=ObtenerLoginDeCadena(cad);
  if MessageDlg('¿Está seguro de convertir en '+nomCategoria+' a "'+cad+'"?',mtConfirmation,mbOKCancel,0)=mrOk then
  begin
    ID_Conexion:=ObtenerIdConexion(cad);
    if ID_Conexion<=MaxJugadores then//logueado
    begin
      case AgregarAdministrador(ID_Conexion,EstadoNuevo) of
        elNecesitasAvatarNivel1:showmessage('Necesitas un avatar de nivel 1');
        elLimiteExedido:showmessage('No es posible crear otro '+nomCategoria);
        elNoSePudoGuardar:showmessage('No se pudo guardar los cambios en disco');
        else
        begin
          mensaje(cad+' ahora es '+nomCategoria);
          Sendtext(id_conexion,'I'+#19+char(estadoNuevo));
        end;
      end;
    end
    else
      showmessage(M_ElUsuarioDebeIniciarSesion)
  end;
end;

procedure TMainForm.Desactivarcomandosdea1Click(Sender: TObject);
var cad:string;
begin
  cad:=trim(InputBox('Quitar privilegios de Administrador','Identificador del Avatar:',''));
  if cad='' then exit;
  cad:=ObtenerLoginDeCadena(cad);
  if MessageDlg('¿Está seguro de quitar privilegios de Administrador a "'+cad+'"?',mtConfirmation,mbOKCancel,0)=mrOk then
    case EliminarAdministrador(cad) of
      elNoSePudoGuardar:showmessage('No se pudo guardar los cambios en disco');
      elNoExiste:showmessage('El usuario no esta registrado como Administrador');
      else
        mensaje(cad+' ahora es Jugador Normal');
    end;
end;

procedure TMainForm.ExpulsarJugador1Click(Sender: TObject);
var ID_Conexion:integer;
    cad:string;
begin
  cad:=trim(InputBox('Expulsar Jugadores','Identificador del Avatar:',''));
  if cad='' then exit;
  cad:=ObtenerLoginDeCadena(cad);
  if MessageDlg('¿Está seguro de Expulsar a "'+cad+'"?',mtConfirmation,mbOKCancel,0)=mrOk then
  begin
    ID_Conexion:=ObtenerIdConexion(cad);
    if ID_Conexion<=MaxJugadores then//logueado
    begin
      if DatosUsuario[ID_Conexion].EstadoUsuario<euAdminB then
      begin
        DatosUsuario[ID_Conexion].EstadoUsuario:=euBaneado;
        mensaje('EXPULSADO del servidor: '+NombreCodJugador(ID_Conexion));
        SocketDelJugador[ID_Conexion].Close;
      end
      else
        showmessage('No aplicable a los Administradores');
    end
    else
      showmessage(M_ElUsuarioDebeIniciarSesion)
  end
end;

procedure TMainForm.Jugadoresactivos1Click(Sender: TObject);
begin
  mensaje('Nro. Jugadores: '+ObtenerListaActivos(nil,true{Listar Jugadores}));
end;

procedure TMainForm.Guardarclanes1Click(Sender: TObject);
begin
  if ServidorEnModoDeVerificacion then
    Mensaje(M_ElServidorNoGuardaEnModoDePruebas)
  else
  begin
    Mensaje('GUARDANDO información del juego');
    GuardarInformacionMundo;
  end;
end;

procedure TMainForm.Clanesactivos1Click(Sender: TObject);
begin
  mensaje('Nro. Clanes: '+ObtenerListaActivos(nil,false{Listar Clanes}));
end;

procedure TMainForm.EliminarClanesinactivos1Click(Sender: TObject);
var i:integer;
begin
  for i:=0 to maxClanesJugadores do
  with ClanJugadores[i] do
  begin
    //TODO: Clanes inactivos
  end;
end;

procedure TMainForm.Limpiarcadveres1Click(Sender: TObject);
begin
  EliminarCadaveres;
end;

procedure TMainForm.Limpiarelsuelo1Click(Sender: TObject);
var cad:string;
    nro,code:integer;
begin
  cad:=trim(InputBox('Eliminar objetos del piso','Mínimo costo de salvación en monedas de oro:','5'));
  val(cad,nro,code);
  if (code<>0) then nro:=0;
  if (nro<1) or (nro>21000000) then
    showmessage('Tiene que ingresar una cantidad entre 1 y 21000000.')
  else
    if MessageDlg('¿Está seguro de eliminar los cadáveres,bolsas,trampas,fogatas,etc. cuyo COSTO total sea MENOR a '+inttostr(nro)+' en monedas de oro'+'?',mtConfirmation,mbOKCancel,0)=mrOk then
      LimpiarBolsas(nro*100);

end;

////////////////////////////////////////////////////////////////////////////////
//                               S O C K E T S                                //
////////////////////////////////////////////////////////////////////////////////
procedure TMainForm.SSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var codJugador:word;
    ErrorLogin:bytebool;
begin
  ErrorLogin:=true;
  codJugador:=Mundo.GetId;
  if codJugador<=MaxJugadores then
    if IPAutorizado(Socket.RemoteAddr.sin_addr.S_addr) then
    begin
      if (Mostrarconexionesydesconexiones.Checked) then
        mensaje('CONECTADO: '+NombreCodJugador(codJugador)+' IP:'+Socket.RemoteAddress+' Socket:'+intastr(integer(socket)));
      socket.Identificador:=codJugador;
      DatosUsuario[codJugador].EstadoUsuario:=euNoAutentificado;
      SocketDelJugador[codJugador]:=Socket;
      //Tiempo para autentificarse
      DatosUsuario[codJugador].TimerDesconeccionPorOcio:=MAX_TIEMPO_OCIO shr 3;
      DatosUsuario[codJugador].ProcesarBufferRecepcion:=false;
      //Nota: como ultimoIP no se usará hasta autenticar al usuario con ident. y contraseña,
      //almacena un número aleatorio que se usará para comprobar que la conexión
      //está siendo iniciada por el juego-cliente.
      DatosUsuario[codJugador].UltimoIP:=random($FFFFFFFF);
      //Enviamos un identificador único si la conexión tiene éxito.
      Socket.sendTextNow('|'+B2aStr(codJugador)+B4aStr(DatosUsuario[codJugador].UltimoIP));
      ErrorLogin:=false;
    end
    else
    begin
    //Enviar Error: IP Denegado
      Socket.sendTextNow('EI');
//      Mensaje('Acceso denegado al IP: '+Socket.RemoteAddress)
    end
  else
  begin
  //Enviar Error: Servidor Saturado
    Socket.sendTextNow('ES');
//    Mensaje('¡El servidor está lleno!')
  end;
  if ErrorLogin then
    socket.close;
end;

procedure TMainForm.SSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
//Nunca llamar a .close del socket aqui.
//Tampoco enviar nada, ¡Ya está cerrado en el cliente!.
var codJugador:word;
begin
  codJugador:=Socket.Identificador;
  Socket.Identificador:=ID_NULO;
  if codJugador<=MaxJugadores then
  begin
    SocketDelJugador[codJugador]:=nil;
    if (Mostrarconexionesydesconexiones.Checked) then
      mensaje('Desconectado: '+NombreCodJugador(codJugador)+' IP:'+Socket.RemoteAddress+' Socket:'+intastr(integer(socket)));
    if (Jugador[codJugador].NivelAgresividad>0) and (DatosUsuario[codJugador].TimerDesconeccionPorOcio>0) and (DatosUsuario[codJugador].estadoUsuario>euAutentificado) then
    begin
      //Tiempo de demora antes de finalizar sesion
      DatosUsuario[codJugador].TimerDesconeccionPorOcio:=TIEMPO_ANTES_DE_DESCONECTAR-1;
      Mensaje('Fin de sesión demorado para: '+NombreCodJugador(codJugador));
    end
    else
      ReleaseId(codJugador);
  end;
end;

procedure TMainForm.SSocketClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
//Ya esta cerrado??
begin
  Mensaje('Error de conexión: '+NombreCodJugador(Socket.identificador)+' IP:'+Socket.RemoteAddress+' Socket:'+intastr(integer(Socket)));
  Socket.Identificador:=ID_NULO;
  ErrorCode:=0;
  Socket.close;
end;

procedure TMainForm.SSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   longitudAnteriorBufferRecepcion:integer;
begin
{$IFDEF CONTROL_ESTADISTICAS}
  longitudAnteriorBufferRecepcion:=length(socket.BufferRecepcion);//Lo que no fue procesado del anterior paquete
{  if longitudAnteriorBufferRecepcion>0 then
    Mensaje('Fragmentos de mensaje unidos: '+NombreCodJugador(codJugador));}
{$ENDIF}
  //aumentar al buffer lo que ha sido recibido
  socket.BufferRecepcion:=socket.BufferRecepcion+Socket.receiveText;
{$IFDEF CONTROL_ESTADISTICAS}
  inc(NrBytesRecibidos,length(socket.BufferRecepcion)-longitudAnteriorBufferRecepcion);//Sólo contar lo que recien llegó.
  inc(NumeroArribosDatos);
{$ENDIF}

  try
    if (EnUso) then mensaje('(i) Entrada concurrente a TMainForm.interpretarComandos()');
    EnUso:=true;
    InterpretarComandos(socket);
//    sleep(320);
    EnUso:=false;
  except
    on E: Exception do Mensaje('Excepción de tipo "Exception" en TMainForm.interpretarComandos() :' + #13 + E.Message);
    else Mensaje('Excepcion desconocida en TMainForm.interpretarComandos()');
  end;

end;

//******************************************************************************
//*********************** INICIO DEL INTERPRETADOR DE COMANDOS *****************
//******************************************************************************
procedure TMainForm.InterpretarComandos(Socket: TCustomWinSocket);
var
    longitudBufferProcesado,posicionBufferRecepcion,longitudBufferRecepcion:integer;
    codJugador:word;
    SalirDelInterpretador:bytebool;
  procedure MostrarMensajeID(const Cadena:string);
  begin
    Mensaje('*** '+cadena+' #'+inttostr(codJugador));
  end;
  procedure MostrarMensajeErrorSesion;
  begin
    Mensaje('(!)Error, l:'+inttostr(longitudBufferRecepcion)+' p:'+inttostr(posicionBufferRecepcion));
    Mensaje('Detalle: '+LimpiarCadena(Copy(Socket.BufferRecepcion,posicionBufferRecepcion,length(Socket.BufferRecepcion)-posicionBufferRecepcion+1)));
    posicionBufferRecepcion:=longitudBufferRecepcion;//Eliminar de cache el resto de ordenes.
    socket.BufferRecepcion:='';
    SalirDelInterpretador:=true;
    socket.close;
  end;
  function Get1B:byte;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(Socket.BufferRecepcion[posicionBufferRecepcion]);
  end;
  function Get2B:word;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(Socket.BufferRecepcion[posicionBufferRecepcion]);
    inc(posicionBufferRecepcion);
    result:=result or (ord(Socket.BufferRecepcion[posicionBufferRecepcion]) shl 8);
  end;
  function Get3B:longint;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(Socket.BufferRecepcion[posicionBufferRecepcion]);
    inc(posicionBufferRecepcion);
    result:=result or (ord(Socket.BufferRecepcion[posicionBufferRecepcion]) shl 8);
    inc(posicionBufferRecepcion);
    result:=result or (ord(Socket.BufferRecepcion[posicionBufferRecepcion]) shl 16);
  end;
  function Get4B:longint;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(Socket.BufferRecepcion[posicionBufferRecepcion]);
    inc(posicionBufferRecepcion);
    result:=result or (ord(Socket.BufferRecepcion[posicionBufferRecepcion]) shl 8);
    inc(posicionBufferRecepcion);
    result:=result or (ord(Socket.BufferRecepcion[posicionBufferRecepcion]) shl 16);
    inc(posicionBufferRecepcion);
    result:=result or (ord(Socket.BufferRecepcion[posicionBufferRecepcion]) shl 24);
  end;
//Para cadenas largas con longitud variable:
  function GET_Cadena127(caracteres:byte):TCadena127;
  //buffer nunca=''.
  //Hasta 127 chars.
  begin
    if caracteres>127 then caracteres:=127;
    result[0]:=chr(caracteres);
    move(pointer(integer(socket.BufferRecepcion)+posicionBufferRecepcion)^,
      result[1],caracteres);
    inc(posicionBufferRecepcion,caracteres);
  end;
  procedure DesecharBytesDelBuffer(caracteres:byte);
  begin
    inc(posicionBufferRecepcion,caracteres);
  end;
//Para cadenas cortas:
  function GET_Cadena16(caracteres:byte):TCadenaLogin;
  begin//Hasta 16 chars.
    if caracteres<=16 then
    begin
      result[0]:=chr(caracteres);
      move(pointer(integer(socket.BufferRecepcion)+posicionBufferRecepcion)^,
         result[1],caracteres);
    end
    else
      result:='';
    inc(posicionBufferRecepcion,caracteres);
  end;
//Para login y Password:
  function GetTPassword:TPassword;
  var i:integer;
  begin
    inc(posicionBufferRecepcion);
    for i:=0 to 7 do
      result[i]:=ord(Socket.BufferRecepcion[posicionBufferRecepcion+i]);
    inc(posicionBufferRecepcion,7);
  end;
  function FaltaInformacion(nroBytes:integer):boolean;
  begin
    result:=longitudBufferRecepcion<posicionBufferRecepcion+nroBytes;
    if result then
      delete(socket.BufferRecepcion,1,longitudBufferProcesado);
  end;
  //Permite a un cliente executar varios comandos repetidos en su debido turno
  //para atenuar efectos de lag.
  procedure PrepararParaPostponerProcesoDeComandos;
  begin
    delete(socket.BufferRecepcion,1,longitudBufferProcesado);
    DatosUsuario[codJugador].ProcesarBufferRecepcion:=true;
  end;
//Intercambio de objetos:
  procedure IntercambiarObjetosEInformar(PosO,PosD:byte);
  var CodAnimeAnterior,Resultado:byte;
  begin
    with Jugador[codJugador] do
    if (hp<>0) or (comportamiento>comHeroe){Game master} then
    begin
      CodAnimeAnterior:=codAnime;
      Resultado:=IntercambiarObjetos(PosO,PosD);
      if Resultado=i_Ok then
      begin
        if posD>=8 then
          SendText(codigo,char(208+PosD)+char(Artefacto[PosD-8].id)+char(Artefacto[PosD-8].modificador))
        else
        begin
          SendText(codigo,char(208+PosD)+char(Usando[PosD].id)+char(Usando[PosD].modificador));
          if posD<=1 then// si destino es icono de mano:
            if (InfObj[Usando[PosD].id].pesoArma=paPesada) or (InfObj[Artefacto[PosO-8].id].pesoArma=paPesada) then
            begin//si alguno de los objetos es arma pesada
              posD:=posD xor $1;//elegir el otro icono de mano
              //enviar información de la otra mano
              SendText(codigo,char(208+PosD)+char(Usando[PosD].id)+char(Usando[PosD].modificador));
            end;
          //Actualizar animacion
          if PosD=uArmadura then//Verificar si cambio de vestimenta:
            if (Usando[PosD].id{Nueva Vestimenta}<>Artefacto[PosO-8].id{Anterior Vestimenta})
              and (codanime<Inicio_tipo_monstruos){No esta bajo efecto de conjuro}
              then
                determinarAnimacion;
        end;
        SendText(codigo,char(208+PosO)+char(Artefacto[PosO-8].id)+char(Artefacto[PosO-8].modificador));
        //Finaliza zoo si equipa arma, armadura, casco o escudo:
        if longbool(banderas and bnZoomorfismo) then
          FinalizarZoomorfismo(Jugador[codJugador],posD);
        if codAnimeAnterior<>codAnime then//Actualizar animacion
          EnviarAlMapa(codMapa,'F'+b2aStr(codigo)+char(codAnime));//A todos para evitar pérdida de sincronización
      end
      else
        SendText(codigo,'II'+InventarioACadena)
    end
  end;
//Consumiendo Objetos:
  function ConsumirObjeto(IndArt:byte):boolean;
  begin
    with Jugador[codJugador] do
    begin
      result:=PuedeRecibirComando(8);
      if result then
      begin
        if PuedeConsumir(IndArt)=i_OK then
          if JugadorConsumir(Jugador[codJugador],IndArt)<>i_error then
          begin
            SendText(codigo,char(IndArt+216{Refrescar Objeto})+char(Artefacto[IndArt].id)+char(Artefacto[IndArt].modificador));
            exit;
          end;
        //Error => Enviar todo el inventario para sincronizar
        SendText(codigo,'II'+InventarioACadena);
      end;
    end;
  end;
//Usando Objetos:
  function UsarObjeto(IndArt:byte):boolean;
  begin
    with Jugador[codJugador] do
    begin
      result:=PuedeRecibirComando(8);
      if result and (codMapa<=maxMapas) then
        Mapa[codMapa].UtilizarHerramienta(Jugador[codJugador],IndArt)
    end;
  end;
  function FabricarObjeto(IdObjeto,IndArt:byte):boolean;
  begin
    with Jugador[codJugador] do
    begin
      result:=PuedeRecibirComando(16);
      if result and (codMapa<=maxMapas) then
        Mapa[codMapa].FabricarArtefacto(Jugador[codJugador],IndArt,idObjeto);
    end;
  end;
  function PersonajeHablarAlrededor:boolean;
  var CadenaMensaje:Tcadena127;
      nroBytes:byte;
  begin
    result:=false;
    if FaltaInformacion(1) then exit;
    nroBytes:=get1b;
    if FaltaInformacion(nroBytes) then exit;
    CadenaMensaje:=Get_Cadena127(nroBytes);
    result:=true;//todos los datos fueron recibidos
    if (DatosUsuario[codJugador].AgresividadVerbal>=100) then
      if CadenaMensaje[0]>#2 then
      begin
        CadenaMensaje[0]:=#4;
        CadenaMensaje[3]:=#160;
        CadenaMensaje[4]:=#169;
        SendText(codJugador,'I'+#17);
      end;
    EnviarAlAreaJugador_J(codJugador,'h'+B2aStr(codJugador)+CadenaMensaje[0]+CadenaMensaje);
  end;
  function ConjuroMasterHablarAlMundo(importante:boolean):boolean;
  var CadenaMensaje:Tcadena127;
      nroBytes:byte;
      puedeHablar:boolean;
  begin
    result:=false;
    if FaltaInformacion(1) then exit;
    nroBytes:=get1b;
    if FaltaInformacion(nroBytes) then exit;
    CadenaMensaje:=Get_Cadena127(nroBytes);
    result:=true;//todos los datos fueron recibidos
    if (DatosUsuario[codJugador].EstadoUsuario>=euAdminB) then
      puedeHablar:=true
    else
      if (DatosUsuario[codJugador].AgresividadVerbal>=100) then
      begin
        SendText(codJugador,'I'+#17);
        exit;
      end
      else
        puedeHablar:=ServidorEnModoDeComunicacionTotal;
    if puedeHablar then
    begin
      CadenaMensaje:=Jugador[codJugador].nombreAvatar+': '+CadenaMensaje;
      if importante and (Jugador[codJugador].comportamiento>comHeroe) then
        EnviarATodos('I!'+char(length(CadenaMensaje))+CadenaMensaje)
      else
        EnviarATodos_J(codJugador,'IH'+char(length(CadenaMensaje))+CadenaMensaje);
    end
    else
      SendText(codJugador,'I'+#16);
  end;
  function PersonajeHablarAlClan:boolean;
  var CadenaMensaje:Tcadena127;
      nroBytes:byte;
  begin
    result:=false;
    if FaltaInformacion(1) then exit;
    nroBytes:=get1b;
    if FaltaInformacion(nroBytes) then exit;
    CadenaMensaje:=Get_Cadena127(nroBytes);
    if Jugador[codJugador].clan<=maxClanesJugadores then
    begin
      CadenaMensaje:=Jugador[codJugador].nombreAvatar+': '+CadenaMensaje;
      EnviarAlClan_J(codJugador,'IG'+char(length(CadenaMensaje))+CadenaMensaje);
    end;
    result:=true;
  end;
  function ProcesarMensajeIniciarSesion:boolean;//false si el mensaje NO está completo
  var Login:TcadenaLogin;
      Password:Tpassword;
      nroBytes:byte;
  begin
    result:=false;
    if FaltaInformacion(9) then exit;
    Password:=getTPassword;//8bytes
    nroBytes:=get1b;//1byte
    if FaltaInformacion(nroBytes) then exit;
    result:=true;//no faltan más datos
    Login:=GET_Cadena16(nroBytes);
    SalirDelInterpretador:=true;
    case iniciarSesion(Login,Password,codJugador) of
      elOk://Login con éxito
      begin
        //Inicio de sesion
        DatosUsuario[codJugador].TimerDesconeccionPorOcio:=MAX_TIEMPO_OCIO;
        //Enviar información al usuario:
        if ServidorEnModoDeVerificacion then
          byte(ServidorEnModoDeVerificacion):=FS_ModoDePruebas;
        with Jugador[codJugador] do
        begin
          activo:=false;
          codigo:=codJugador;//Necesario!!
          ControlConsistenciaDatosGuardados(Jugador[codJugador]);//tambien llama a PrepararParaIngresarJuego
          socket.SendTextNow('@'+
            //Información de sincronizacion de frames por segundo:
            char((Timer.interval div FRECUENCIA_BASE) or byte(ServidorEnModoDeVerificacion))+
            ExtraerDatosEnCadena());
          //Enviar Clanes Activos
          EnviarDatosClanesActivos(Jugador[codJugador]);
          //Activar el jugador en el mapa y enviar datos del mapa
          //OJO que aqui se llama a colocarJugador y no Teletransportar jugador
          //por que está comenzando el juego.
          Mapa[codMapa].colocarJugador(Jugador[codJugador],coordx,coordy,false);
          //Enviar Nuevo clan activo:
          RealizarControlActivacionDeClanJugador(Jugador[codJugador],true);
          //Enviar caracter de inicio del juego
          SendTextNow(codJugador,'!');
          if G_MensajeDeBienvenidaAlServidor<>'' then
            SendText(codJugador,'IG'+char(length(G_MensajeDeBienvenidaAlServidor))+G_MensajeDeBienvenidaAlServidor);
          if ServidorEnModoMultiplesSesiones then
            socket.SendText('I'+#24)
        end;
        mensaje('Inicio de sesión para: '+NombreCodJugador(codJugador));
        SalirDelInterpretador:=false;
      end;
      elPassword://Error: Contraseña Incorrecta
        socket.SendTextNow('EC');
      elYALogueado://Error: Un usuario se logueo con el mismo login
        socket.SendTextNow('EY');
      elBaneado://Error: Usuario baneado.
        socket.SendTextNow('EB');
      elDestruido://Archivo de avatar dañado
        socket.SendTextNow('E0');
      else//Error: No existe el avatar
        socket.SendTextNow('EN');
    end
  end;
  procedure OrdenarAtacar(ElObjetivoAtacado:word);
  var mensajeResultado:byte;
  begin
    with Jugador[codJugador] do
      if usando[uAnillo].id=orAnilloDelControl then
      begin
        mensajeResultado:=esteMonstruoEsEnemigo(Jugador[codJugador],GetMonstruoCodigoCasillaS(ElObjetivoAtacado));
        if mensajeResultado=i_ok then
          AtacarUnObjetivo(Jugador[codJugador],ElObjetivoAtacado)
        else
          socket.sendText('i'+char(mensajeResultado));
      end;
  end;
  //COMANDOS PARA ADMINISTRADORES **************************
  procedure ConjuroMasterCrearArtefacto(idObj,modObj:byte);
  begin
    if (DatosUsuario[codJugador].EstadoUsuario>euGameMaster)
       or
       (
         (ServidorEnModoDeVerificacion and (DatosUsuario[codJugador].EstadoUsuario>=euAdminB))
         or
         (
           (DatosUsuario[codJugador].EstadoUsuario>=euGameMaster)
           and
           ((PosicionesInicialesDeAvatares[9,0]=Jugador[codJugador].codmapa) and (PosicionesInicialesDeAvatares[9,1]=Jugador[codJugador].coordx) and (PosicionesInicialesDeAvatares[9,2]=Jugador[codJugador].coordy))
         )
       ) then
      with Jugador[codJugador] do
      begin
        if (not ServidorEnModoDeVerificacion) then
          mensaje('Objeto creado ('+inttostr(idObj)+','+inttostr(modObj)+') por '+nombreAvatar);
        if (DatosUsuario[codJugador].EstadoUsuario>euGameMaster) then
          case idObj of
            //Incrementa el nivel en 1.
            0:NotificarModificacionExperiencia(Jugador[codJugador],MAXIMA_EXPERIENCIA_FALTANTE);
            //Cambia el estado de la bandera de calabozo
            1:mapa[codMapa].CambiarFlagsCalabozo:=mapa[codMapa].CambiarFlagsCalabozo xor (1 shl modObj);
            //cambia el nivel de honor
            2:cambiarHonor(Jugador[codJugador],shortint(modObj));
            //0..7: cambia de raza, 100..107: cambia de clase
            3:if (modObj<=6) then
              begin
                Jugador[codJugador].TipoMonstruo:=modObj;
                Jugador[codJugador].CodCategoria:=0;//guerrero (todas las razas)
              end
              else if (modObj>=100) and (modObj<=107) then
                if (categoriasDenegadas[Jugador[codJugador].TipoMonstruo] and (1 shl (modObj-100)))=0 then
                  Jugador[codJugador].CodCategoria:=modObj-100;
          end;
        if (Artefacto[0].id<4) or (idObj<4) then
        begin//si la casilla esta libre o se quiere destruir el objeto:
          Artefacto[0].id:=idObj;
          Artefacto[0].modificador:=modObj;
          SendText(codJugador,#216+char(idObj)+char(modObj));
        end
        else
          SendText(codJugador,'i'+char(i_NecesitasTenerLibreLaPrimeraCasilla));
      end
    else//No es admin
      SendText(codJugador,'I'+#18);
  end;
  procedure ConjuroMasterTeletransportarse;
  var x,y,z,fallos:byte;
      i:integer;
  begin
    y:=get1b;
    x:=get1b;
    z:=get1b;
    fallos:=0;
    if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puTeletransportar) then
    begin
      for i:=0 to MAX_INTENTOS_POSICIONAMIENTO do
      begin
        if Mapa[z].PuedeMoverseAEsteLugar(Jugador[codJugador],x,y) then
          break;
        x:=byte(x+MC_POSICIONAMIENTO_X[i]*5);
        y:=byte(y+MC_POSICIONAMIENTO_Y[i]*5);
        inc(fallos);
      end;
      if (fallos>0) and (fallos<=MAX_INTENTOS_POSICIONAMIENTO){evitar enviar 2 veces el mensaje} then
        SendText(codJugador,'i'+char(i_NoPuedesTeletransportarte));
      TeletransPortarJugador(Jugador[codJugador],z,x,y);//Moverse a otro mapa.
    end;
  end;
  type TTipoMensajeBusqueda=(tmbNinguno,tmbBuscar,tmbRestaurar,tmbPrision,tmbExpulsar,tmbVisitar,tmbConvocar,tmbAnularClan,tmbPermitirChat,tmbNegarChat,tmbHeroeLegendario);
  function ProcesarMensajeDeBusqueda(tipo:TTipoMensajeBusqueda):boolean;
  var
      ID_Conexion:integer;
      nroBytes:byte;
      cad:string;
  begin
    result:=false;
    if faltaInformacion(1) then exit;
    nroBytes:=get1b;
    if faltaInformacion(nroBytes) then exit;
    result:=true;
    if (DatosUsuario[codJugador].PermisosDelUsuario = 0) then
    begin
      DesecharBytesDelBuffer(nroBytes);
      exit;
    end;
    ID_Conexion:=ObtenerIdConexion(GET_Cadena127(nroBytes));
    if ID_Conexion<=MaxJugadores then//logueado
      case tipo of
        tmbAnularClan:
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puAnularClan) then
          begin
            if Jugador[ID_Conexion].clan<=MaxClanesJugadores then
              with ClanJugadores[Jugador[ID_Conexion].clan] do
              begin//Debe ser igual al codigo en dejar clan para el lider=anular clan
                lider:='';//clan sin lider=extinto
                PendonClan.color0:=0;
                PendonClan.color1:=0;
                ColorClan:=255;//anularclan
                with Jugador[ID_Conexion] do
                begin
                  EnviarATodos('IP'+char(clan)+b4astr(PendonClan.color0)+b4astr(PendonClan.color1));
                  EnviarATodos('I('+char(clan)+char(colorClan));
                  EliminarRastrosDelClan(clan);//castillos, jugadores activos y otros bonos
                end;
              end;
          end
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbExpulsar:
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puExpulsarAvatar) then
          begin
            if DatosUsuario[codJugador].EstadoUsuario>DatosUsuario[ID_Conexion].EstadoUsuario then
            begin
              cad:=Jugador[codJugador].nombreAvatar+' expulsó a '+Jugador[ID_Conexion].nombreAvatar;
              SendTextNow(ID_Conexion,'IX');
              DatosUsuario[ID_Conexion].EstadoUsuario:=euBaneado;
              mensaje('EXPULSADO del servidor: '+NombreCodJugador(ID_Conexion));
              SocketDelJugador[ID_Conexion].close;
              EnviarATodos('IG'+char(length(cad))+cad);
            end
            else
              SendText(codJugador,'i'+char(i_NecesitasMayorNivelAdministrativo));
          end
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbBuscar:with Jugador[ID_Conexion] do
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puBuscarAvatar) then
            SendText(codJugador,'I'+#23+char(codmapa)+char(coordx)+char(coordy))
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbConvocar:with Jugador[codJugador] do
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puConvocarAvatar) then
            TeletransportarJugador(Jugador[ID_Conexion],codmapa,coordx,coordy)
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbPrision:with Jugador[ID_Conexion] do
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puEncarcelarAvatar) then
          begin
            cad:='Encarcelaste a '+Jugador[ID_Conexion].nombreAvatar;
            TeletransportarJugador(Jugador[ID_Conexion],
              PosicionesInicialesDeAvatares[8,0],
              PosicionesInicialesDeAvatares[8,1],
              PosicionesInicialesDeAvatares[8,2]);
            IncrementarTiempoDeCarcel;
            SendText(ID_Conexion,'I'+#14+char(NivelAgresividad));
            SendText(codJugador,'IG'+char(length(cad))+cad);
          end
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbVisitar:with Jugador[ID_Conexion] do
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puVisitarAvatar) then
            TeletransportarJugador(Jugador[codJugador],codmapa,coordx,coordy)
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbRestaurar:
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puRestaurarAvatar) then
          begin
            RepararAvatarYPosicion(Jugador[ID_Conexion]);
            SendText(ID_Conexion,'I'+#20);
          end
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbPermitirChat:
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puModerarChat) then
          begin
            DatosUsuario[ID_Conexion].AgresividadVerbal:=0;
            SendText(ID_Conexion,'I'+#15);
          end
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbNegarChat:
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puModerarChat) then
            if DatosUsuario[codJugador].EstadoUsuario>DatosUsuario[ID_Conexion].EstadoUsuario then
            begin
              DatosUsuario[ID_Conexion].AgresividadVerbal:=255;
              SendText(ID_Conexion,'I'+#17);
            end
            else
             SendText(codJugador,'i'+char(i_NecesitasMayorNivelAdministrativo))
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
        tmbHeroeLegendario:
          if longbool(DatosUsuario[codJugador].PermisosDelUsuario and puHeroeLegendario) then
          begin
            Jugador[ID_Conexion].CrearHeroeLegendario();
            cad:='Héroe Legendario';
            SendText(ID_Conexion,'IG'+char(length(cad))+cad);
          end
          else
            SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
      end
    else
      SendText(codJugador,'I'+#22);
  end;
  procedure ConjuroMasterDisolverMonstruo(IdMonstruo:word);
  begin
    if (DatosUsuario[codJugador].PermisosDelUsuario and puDisolverMonstruo)=0 then
    begin
      SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
      exit;
    end;
    if IdMonstruo<=maxMonstruos then
      with monstruo[idMonstruo] do
        if (hp<>0) then
          Mapa[codMapa].DisolverMonstruo(monstruo[idMonstruo]);
  end;
  procedure ConjuroMasterConjurarMonstruo(ElTipoDeMonstruo:byte);
  var ElMonstruoConjurado:TmonstruoS;
  begin
    if (DatosUsuario[codJugador].PermisosDelUsuario and puConjurarMonstruo)=0 then
    begin
      SendText(codJugador,'i'+char(i_NoTienesPrivilegioParaUsarEseComando));
      exit;
    end;
    with Jugador[codJugador] do
    begin
      ElMonstruoConjurado:=mapa[codMapa].ConjurarMonstruo(ElTipoDeMonstruo,uNoDefinido,coordx,coordy+1,ccvac,nil);
      if ElMonstruoConjurado<>nil then
        with ElMonstruoConjurado do
        begin
          banderas:=banderas or BnParalisis;
          inicializarTimer(tdParalisis,2);
          EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
        end
      else
        SendText(codJugador,'i'+char(i_NoPudisteConjurarMonstruo));
    end
  end;
  procedure ControlMasterDeMonstruo(IdMonstruo:word);
  begin
    if DatosUsuario[codJugador].EstadoUsuario<euAdminB then exit;
    if IdMonstruo<=maxMonstruos then
      with monstruo[idMonstruo] do
        if (hp<>0) then
          if (banderas and BnControlado)<>0 then
          begin
            banderas:=banderas xor BnControlado;
            if (codigo<conta_Monstruos_Definidos) or (ritmoDeVida=uNoDefinido) then
              comportamiento:=InfMon[monstruo[idMonstruo].tipoMonstruo].comportamiento;
            banderas:=banderas or BnParalisis;
            inicializarTimer(tdParalisis,2);
            EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
          end
          else
          begin
            banderas:=banderas or BnControlado;
            comportamiento:=comMonstruoConjurado;
            objetivoASeguir:=codJugador;
            objetivoAtacado:=ccvac;
          end;
  end;
//Especial de jugadores
  procedure RealizarSeppuku;
  begin
    with Jugador[codJugador] do
      if hp<>0 then
        Mapa[codMapa].MuerteJugador(Jugador[codJugador],nil);
  end;
//Clanes
  procedure ClanVerTesoroCastillo;
  begin
    if Jugador[codJugador].clan<=maxClanesJugadores then
      with Mapa[Jugador[codJugador].codMapa] do
        if (Castillo.clan=Jugador[codJugador].clan) and (ObtenerRecursoAlFrente(Jugador[codJugador])=irCastillo) then
          if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
            SendText(codJugador,'I'+#202+b4aStr(castillo.dinero));
  end;
  procedure RetirarDineroCastillo(dinero:integer);
  var mensaje:string;
  begin
    if Jugador[codJugador].clan<=maxClanesJugadores then
      with ClanJugadores[Jugador[codJugador].clan] do
        if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
          with Mapa[Jugador[codJugador].codmapa] do
          begin
            if (Castillo.clan=Jugador[codJugador].clan) and (ObtenerRecursoAlFrente(Jugador[codJugador])=irCastillo) then
              if castillo.Dinero>=dinero then
              begin
                dec(castillo.Dinero,dinero);
                inc(Jugador[codJugador].dinero,dinero);
                SendText(codJugador,#250{Dinero}+b4aStr(Jugador[codJugador].dinero)+
                  'I'+#202+b4aStr(castillo.dinero));
                mensaje:=Jugador[codJugador].nombreAvatar+' retiró del castillo "'+nombreMapa+'" '+DineroAStr(dinero);
                EnviarAlClan_J(codJugador,'IG'+char(length(mensaje))+mensaje);
              end
              else
                SendText(codJugador,'i'+char(i_ElCastilloNoTieneTantoDinero));
          end
  end;
  procedure DepositarDineroCastillo(dinero:integer);
  begin
    if Jugador[codJugador].clan<=maxClanesJugadores then
      with Mapa[Jugador[codJugador].codmapa] do
        if (Castillo.clan=Jugador[codJugador].clan) and (ObtenerRecursoAlFrente(Jugador[codJugador])=irCastillo) then
          if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
            if Jugador[codJugador].dinero>=dinero then
            begin
              dec(Jugador[codJugador].dinero,dinero);
              inc(castillo.Dinero,dinero);
              SendText(codJugador,#250{Dinero}+b4aStr(Jugador[codJugador].dinero)+
                'I'+#202+b4aStr(castillo.dinero));
            end
  end;
  procedure MejorarGuardianCastillo(monedasPlata,Bandera:integer);
  var i:integer;
  begin
    if Jugador[codJugador].clan<=maxClanesJugadores then
      with Mapa[Jugador[codJugador].codmapa] do
        if (Castillo.clan=Jugador[codJugador].clan) and (ObtenerRecursoAlFrente(Jugador[codJugador])=irCastillo) then
          if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
            if Jugador[codJugador].dinero>=monedasPlata then
              if (Castillo.banderasGuardian and Bandera)=0 then
              begin
                dec(Jugador[codJugador].dinero,monedasPlata);
                Castillo.banderasGuardian:=Castillo.banderasGuardian or Bandera;
                for i:=0 to max_guardianes do
                  if CodigoMonstruoGuardian[i]<=MaxMonstruos then
                  begin//si tiene monstruo guardian
                    Monstruo[CodigoMonstruoGuardian[i]].banderas:=Castillo.banderasGuardian;
                    if (Bandera and $FFFF)<>0 then
                      EnviarAlMapa(Jugador[codJugador].codmapa,'a'+b2aStr(CodigoMonstruoGuardian[i] or ccmon)+b2aStr(Monstruo[CodigoMonstruoGuardian[i]].banderas));
                    SendText(codJugador,'i'+char(i_HasMejoradoLaDefensaDelCastillo));
                  end;
                SendText(codJugador,#250{Dinero}+b4aStr(Jugador[codJugador].dinero));
              end
              else
                SendText(codJugador,'i'+char(i_YaSeRealizoEsaMejoraEnElGuardian));
  end;

  procedure ClanCambiarColor(NuevoColorClan:byte);
  begin
    if Jugador[codJugador].clan<=maxClanesJugadores then
      if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
        with ClanJugadores[Jugador[codJugador].clan],Mapa[Jugador[codJugador].codMapa] do
          if lider=Jugador[codJugador].nombreAvatar then
          begin
            if (NuevoColorClan<>colorClan) and
              (Castillo.clan=Jugador[codJugador].clan) and (ObtenerRecursoAlFrente(Jugador[codJugador])=irCastillo) then
            begin
              colorClan:=NuevoColorClan;
              EnviarATodos('I('+char(Jugador[codJugador].clan)+char(colorClan));
            end;
          end
          else
            SendText(codJugador,'i'+char(i_NoEresElLiderDelClan));
  end;
  procedure ClanCambiarPendon(color0,color1:longword);
  begin
    if Jugador[codJugador].clan<=maxClanesJugadores then
      if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
        with ClanJugadores[Jugador[codJugador].clan],Mapa[Jugador[codJugador].codMapa] do
          if lider=Jugador[codJugador].nombreAvatar then
          begin
            if ((PendonClan.color0<>color0) or (PendonClan.color1<>color1)) and
              (Castillo.clan=Jugador[codJugador].clan) and (ObtenerRecursoAlFrente(Jugador[codJugador])=irCastillo) then
            begin
              PendonClan.color0:=color0;
              PendonClan.color1:=color1;
              EnviarATodos('IP'+char(Jugador[codJugador].clan)+b4astr(color0)+b4astr(color1));
            end;
          end
          else
            SendText(codJugador,'i'+char(i_NoEresElLiderDelClan));
  end;
  function ProcesarMensajeClanCambiarNombre:boolean;
  var CadenaMensaje:Tcadena127;
      nroBytes:byte;
  begin
    result:=false;
    if faltaInformacion(1) then exit;
    nroBytes:=get1b;
    if faltaInformacion(nroBytes) then exit;
    result:=true;
    if Jugador[codJugador].clan<=maxClanesJugadores then
      if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
        with ClanJugadores[Jugador[codJugador].clan] do
          if lider=Jugador[codJugador].nombreAvatar then
          begin
            CadenaMensaje:=GET_Cadena127(nroBytes);
            if Nombre<>CadenaMensaje then
              if not ExisteNombreClanSimilar(cadenaMensaje,Jugador[codJugador].clan) then
              begin
                Nombre:=CadenaMensaje;
                EnviarATodos('IN'+char(Jugador[codJugador].clan)+char(length(nombre))+nombre);
              end
              else
                SendText(codJugador,'i'+char(i_YaExisteUnNombreMuyParecido));
            exit;//para no desechar los bytes leidos en la cadena
          end
          else
            SendText(codJugador,'i'+char(i_NoEresElLiderDelClan));
    DesecharBytesDelBuffer(nroBytes);
  end;
  procedure ClanReclutarJugador(IdJugador:word);
  begin
    if Jugador[codJugador].clan<=maxClanesJugadores then//el jugador reclutador tiene clan
      if (Jugador[codJugador].hp<>0) and (not longbool(Jugador[codJugador].banderas and BnParalisis)) then
        if ClanJugadores[Jugador[codJugador].clan].lider=Jugador[codJugador].nombreAvatar then//si el reclutador es el lider
        begin
          if IdJugador<=maxJugadores then//seguridad
            with Jugador[IdJugador] do
              if clan>maxClanesJugadores then//si el reclutado no tiene clan
              begin
                clan:=Jugador[codJugador].clan;
                DatosUsuario[idJugador].IdentificadorDeClan:=ClanJugadores[clan].IdentificadorDeClan;
                inc(ClanJugadores[clan].MiembrosActivos);
                EnviarAlMapa(codMapa,'I'+#200+char(clan)+b2aStr(IdJugador));
              end
              else
                SendText(codJugador,'i'+char(i_YaTieneClan));
        end
        else
          SendText(codJugador,'i'+char(i_NoEresElLiderDelClan));
  end;
  procedure ClanDespedirJugador(IdJugador:word);
  begin
    if idJugador=codJugador then//Abandonar un clan.
    begin
      with Jugador[codJugador] do
        if clan<=maxClanesJugadores then//tiene clan
          if nombreAvatar<>ClanJugadores[clan].lider then
          begin//no es el lider
            dec(ClanJugadores[clan].MiembrosActivos);
            clan:=ninguno;
            EnviarAlMapa(codMapa,'I'+#200+char(clan)+b2aStr(IdJugador));
          end
          else//es el lider, anula su clan
            with ClanJugadores[Jugador[codJugador].clan] do
            begin//Debe ser igual al código en anular clan
              lider:='';//clan sin lider=extinto
              PendonClan.color0:=0;
              PendonClan.color1:=0;
              ColorClan:=255;//anularclan
              with Jugador[codJugador] do
              begin
                EnviarATodos('IP'+char(clan)+b4astr(PendonClan.color0)+b4astr(PendonClan.color1));
                EnviarATodos('I('+char(clan)+char(colorClan));
                EliminarRastrosDelClan(clan);//castillos, jugadores activos y otros bonos
              end;
            end;
    end
    else
      if Jugador[codJugador].clan<=maxClanesJugadores then
        if ClanJugadores[Jugador[codJugador].clan].lider=Jugador[codJugador].nombreAvatar then
        begin
          if IdJugador<=maxJugadores then//seguridad
            with Jugador[IdJugador] do
              if clan=Jugador[codJugador].clan then//si esta en el clan
              begin
                dec(ClanJugadores[clan].MiembrosActivos);
                clan:=ninguno;
                EnviarAlMapa(codMapa,'I'+#200+char(clan)+b2aStr(IdJugador));
              end
              else
                SendText(codJugador,'i'+char(i_NoEstaEnTuClan));
        end
        else
          SendText(codJugador,'i'+char(i_NoEresElLiderDelClan));
  end;
//Otros
  procedure ProcesarComandoDeGrupo(codCasilla:word);
  var codigoResultado,indiceDeCamaradaParty:byte;
  begin
    if codCasilla<=maxJugadores then
    begin
      //No hacer nada si quiere agregarse a si mismo.
      if codCasilla=codJugador then exit;
      if Jugador[codJugador].hp=0 then exit;//si esta muerto salir
      codigoResultado:=
        FormarEnlaceDeParty(Jugador[codJugador],Jugador[codCasilla],indiceDeCamaradaParty);
      if codigoResultado=i_ok then
      begin
        with Jugador[codJugador] do
          SendText(codJugador,'Iga'+camaradasPartyACadena);
        with Jugador[codCasilla] do
          SendText(codCasilla,'Igi'+camaradasPartyACadena);
      end
      else//Informar Eliminar de la lista si ya fue agregado:
        if codigoResultado=i_error then
        begin
          with Jugador[codJugador] do
            SendText(codJugador,'Igq'+camaradasPartyACadena);
          with Jugador[codCasilla] do
            SendText(codCasilla,'Igs'+camaradasPartyACadena);
        end
        else//Informar de otros errores
        begin
          SendText(codJugador,'i'+char(codigoResultado));
          SendText(codCasilla,'Ii'+b2aStr(codJugador));
        end;
    end
    else//Informar de los miembros del grupo
    begin
      EliminarEnlacesDePartyErroneos(Jugador[codJugador]);
      with Jugador[codJugador] do
        SendText(codJugador,'Igl'+camaradasPartyACadena);
    end;
  end;
  procedure OfrecerVenderObjetoANPC;
  var CodigoMonstruocomerciante:word;
      cantidad,IndiceArtefacto:byte;
  begin
    CodigoMonstruocomerciante:=get2b;
    cantidad:=get1b;
    IndiceArtefacto:=get1b;
    Mapa[Jugador[codJugador].codMapa].VenderObjeto(Jugador[codJugador],indiceArtefacto,cantidad,CodigoMonstruocomerciante);
  end;
  procedure ComprarObjetoANPC;
  var CodigoMonstruocomerciante:word;
      cantidad,IndiceArtefacto:byte;
  begin
    CodigoMonstruocomerciante:=get2b;
    cantidad:=get1b;
    IndiceArtefacto:=get1b;
    Mapa[Jugador[codJugador].codMapa].ComprarObjeto(Jugador[codJugador],indiceArtefacto,cantidad,CodigoMonstruocomerciante);
  end;
  function CrearNuevoPersonaje:boolean;
  var DatosNuevoPersonaje:TDatosNuevoPersonaje;
      Password:TPassword;
      NroDesHabilidades:integer;
      codResultado:TErrorAdmUsuarios;
      IdentificadorUU:TCadenaLogin;
      NroBytes:byte;
  begin
    if ServidorEnModoDeVerificacion then
    begin
      result:=true;
      socket.SendTextNow('EM')//error modo de pruebas
    end
    else
    begin
      result:=false;
      with DatosNuevoPersonaje do
      begin
        if faltaInformacion(8) then exit;
        pericias:=GET2B;
        cod_raza:=GET1B;//cod_raza=nible_inferior, cod_categotia=nible_superior.
        cod_categoria:=cod_raza shr 4;//4 bits
        cod_raza:=cod_raza and $F;//4 bits.
        NroDesHabilidades:=get4b;//Puntajes de habilidades y otros 7 bits.
        cod_genero:=NroDesHabilidades shr 31; //bit 32.
        INT:=NroDesHabilidades and $1F;//5 bits
        FRZ:=(NroDesHabilidades shr 5) and $1F;//5 bits
        CON:=(NroDesHabilidades shr 10) and $1F;//5 bits
        DES:=(NroDesHabilidades shr 15) and $1F;//5 bits
        SAB:=(NroDesHabilidades shr 20) and $1F;//5 bits
        nroBytes:=get1b;
        if faltaInformacion(nroBytes) then exit;
        nombre:=Get_Cadena127(nroBytes);
        if faltaInformacion(8) then exit;
        Password:=getTPassword;//8bytes
      end;
      result:=true;
      codResultado:=crearCuenta(Password,DatosNuevoPersonaje,IdentificadorUU,Socket.RemoteAddr.sin_addr.S_addr);
      if codResultado=elOK then
      begin
        //Informar al cliente de cuenta creada
        socket.SendTextNow('IC'+char(length(IdentificadorUU))+IdentificadorUU);
        mensaje('CUENTA creada: '+IdentificadorUU+' #'+inttostr(codJugador));
      end
      else
        if codResultado=elDenegado then
          socket.SendTextNow('ED')//error al crear la cuenta.
        else
          socket.SendTextNow('EO');//error al crear la cuenta.
    end;
  end;
  procedure HacerClickEnSensor(y,x:byte);
  begin
    Mapa[Jugador[codJugador].codMapa].SensorClick(Jugador[codJugador],x,y);
  end;
begin
  codJugador:=socket.identificador;
  if codJugador>MaxJugadores then exit;//sin id, no se puede interpretar nada

  //Por enviar un comando
  DatosUsuario[codJugador].TimerDesconeccionPorOcio:=MAX_TIEMPO_OCIO;
  if (Jugador[codJugador].FlagsComunicacion and flSaliendoDelServidor)<>0 then
  begin
    Jugador[codJugador].FlagsComunicacion:=Jugador[codJugador].FlagsComunicacion xor
      flSaliendoDelServidor;
    SendText(codJugador,'I'+#9);
  end;

  DatosUsuario[codJugador].ProcesarBufferRecepcion:=false;
  longitudBufferRecepcion:=length(socket.BufferRecepcion);
  if longitudBufferRecepcion<=0 then exit;//sin nada que interpretar
  posicionBufferRecepcion:=0;
  if DatosUsuario[codJugador].EstadoUsuario=euNoAutentificado then
    //Nota: Ultimo IP tiene el número aleatorio de autenticación.
    if AutentificacionCorrecta(get4b,DatosUsuario[codJugador].UltimoIP) then
    begin
      if versionLA=GET1B then
      begin
        DatosUsuario[codJugador].EstadoUsuario:=euAutentificado
      end
      else//Error de versiones
      begin
        socket.SendTextNow('EV'+chr(versionLA));
        socket.BufferRecepcion:='';
        socket.close;
        exit;
      end;
    end
    else
    begin
      if VerConexionesImprocedentes1.Checked then
      begin
        Mensaje('Conexión rechazada. IP:'+Socket.RemoteAddress+' Socket:'+intastr(integer(socket))+' ('+inttostr(longitudBufferRecepcion)+'B) Datos:');
        Mensaje(LimpiarCadena(Socket.BufferRecepcion));
      end;
      socket.BufferRecepcion:='';
      socket.close;
      exit;
    end;
  SalirDelInterpretador:=false;
  //Mientras existan caracteres no decodificados
  while longitudBufferRecepcion>posicionBufferRecepcion do
  begin
    longitudBufferProcesado:=posicionBufferRecepcion;
    case chr(GET1B) of
      'm':begin//Moverse direccion
        if FaltaInformacion(1) then exit;
        FijarMovimiento(Jugador[codJugador],get1B);
      end;
      'M':begin//Moverse Coordenada
        if FaltaInformacion(2) then exit;
        fijarCoordenadasDestino(Jugador[codJugador],get2b,false);
      end;
      'W':begin//Moverse a un monstruo
        if FaltaInformacion(2) then exit;
        fijarCoordenadasDestino(Jugador[codJugador],get2b,true);
      end;
      'A':begin//Ataque ofensivo
        if FaltaInformacion(2) then exit;
        EjecutarComandoIniciarAtaque(Jugador[codJugador],get2b,aaAtaqueOfensivo,true);
      end;
      'B':begin//Ataque defensivo
        if FaltaInformacion(2) then exit;
        EjecutarComandoIniciarAtaque(Jugador[codJugador],get2b,aaAtaqueDefensivo,true);
      end;
      'y':begin//Lanzar Hechizo
        if FaltaInformacion(2) then exit;
        EjecutarComandoIniciarAtaque(Jugador[codJugador],get2b,aaAtaqueMagia,false);
      end;
      'Y':begin//Lanzar Hechizo, ataque continuo
        if FaltaInformacion(2) then exit;
        EjecutarComandoIniciarAtaque(Jugador[codJugador],get2b,aaAtaqueMagia,true);
      end;
      'J':begin//Lanzar Hechizo sobre objeto del inventario
        if FaltaInformacion(1) then exit;
        Jugador[codJugador].ObjetivoDeAtaqueAutomatico:=ccVac;//Asegura que el hechizo no intente ser lanzado a otro.
        Mapa[Jugador[codJugador].codMapa].LanzarConjuro(Jugador[codJugador],get1b);
      end;
      'O':begin
        if FaltaInformacion(1) then exit;
        //Con el atributo "duenno" del jugador definimos cuales son sus monstruos
        with Jugador[codJugador] do
        begin
          if clan<=maxClanesJugadores then
            duenno:=ccClan or clan
          else//si NO tiene clan
            duenno:=codigo;
          case char(get1b) of//Comandar monstruos
          'a':begin//orden de atacar
            if FaltaInformacion(2) then exit;
            OrdenarAtacar(get2b);
          end;
          's':begin//orden de seguir
            if FaltaInformacion(2) then exit;
            Jugador[codJugador].objetivoASeguir:=get2b;
            if usando[uAnillo].id=orAnilloDelControl then
              SeguirUnObjetivo(Jugador[codJugador]);
          end;
          'd':if usando[uAnillo].id=orAnilloDelControl then
            DetenerMonstruos(Jugador[codJugador]);
          else
            MostrarMensajeErrorSesion;
          end
        end;
      end;
      'K':begin
        if FaltaInformacion(1) then exit;
        case char(get1b) of//Administrar Clan y Castillo
          'P':begin
            if FaltaInformacion(8) then exit;
            ClanCambiarPendon(get4b,get4b);
          end;
          '(':begin
            if FaltaInformacion(1) then exit;
            ClanCambiarColor(get1b);
          end;
          'M':begin//mejoras
            if FaltaInformacion(1) then exit;
            case char(get1b) of
              'A':MejorarGuardianCastillo(COSTO_MEJORAR_ATAQUE,bnApresurar);
              'D':MejorarGuardianCastillo(COSTO_MEJORAR_ARMADURA,bnArmadura);
              'M':MejorarGuardianCastillo(COSTO_MEJORAR_MANA,bnMana);
              'V':MejorarGuardianCastillo(COSTO_MEJORAR_VISION,bnVisionVerdadera);
              'R':MejorarGuardianCastillo(COSTO_MEJORAR_RESISTENCIA,bnVendado);
              'F':MejorarGuardianCastillo(COSTO_MEJORAR_FUERZA,bnFuerzaGigante);
              'G':MejorarGuardianCastillo(COSTO_MEJORAR_GUARDIA,BnModoDefensivo);
              'T':MejorarGuardianCastillo(COSTO_MEJORAR_TIEMPO,BnDuracion);
              '?':socket.sendText('I'+#203+b4aStr(Mapa[Jugador[codJugador].codmapa].castillo.banderasGuardian));
            else
              MostrarMensajeErrorSesion;
            end
          end;
          'N':if not ProcesarMensajeClanCambiarNombre then exit;
          'T':ClanVerTesoroCastillo;
          'B':EnviarBaulCompleto(Jugador[codJugador]);
          'E':begin
            if FaltaInformacion(3) then exit;
            RetirarDineroCastillo(get3b);
          end;
          'g':begin
            if FaltaInformacion(3) then exit;
            DepositarDineroCastillo(get3b);
          end;
          'R':begin
            if FaltaInformacion(2) then exit;
            ClanReclutarJugador(get2b);
          end;
          'D':begin
            if FaltaInformacion(2) then exit;
            ClanDespedirJugador(get2b);
          end;
          'G':begin
            if FaltaInformacion(2) then exit;
            GuardarObjetoEnBaul(Jugador[codJugador],get1b{ind},get1b{cantidad});
          end;
          'S':begin
            if FaltaInformacion(2) then exit;
            SacarObjetoDeBaul(Jugador[codJugador],get1b{ind},get1b{cantidad});
          end;
          'L':ObtenerListaMiembrosClan(Jugador[codJugador]);
        else
          MostrarMensajeErrorSesion;
        end;
      end;
      's':begin//click en sensor
        if FaltaInformacion(2) then exit;
        HacerClickEnSensor(get1b,get1b);
      end;
      'c':begin//Consumir objeto: Siempre envia al cliente inf. adicional.
        if FaltaInformacion(1) then exit;
        //Si no se realizó el comando por la pausa entre comandos, evitar que el comando llegue al estatus de "procesado"
        if not ConsumirObjeto(get1b) then
        begin
          PrepararParaPostponerProcesoDeComandos;
          exit;
        end;
      end;
      'u':begin//Usar un objeto: Puede que envie al cliente inf. adicional.
        if FaltaInformacion(1) then exit;
        if not UsarObjeto(get1b) then
        begin
          PrepararParaPostponerProcesoDeComandos;
          exit;
        end;
      end;
      'F':begin//Fabricar objeto
        if FaltaInformacion(2) then exit;
        FabricarObjeto(get1b,get1b);
      end;
      'H':if not PersonajeHablarAlrededor then exit;
      'T':if not ConjuroMasterHablarAlMundo(false) then exit;
      'G':if not PersonajeHablarAlClan then exit;
      'I':begin//Intercambiar dos objetos, el intercambio se hace antes en el cliente
        if FaltaInformacion(2) then exit;
        IntercambiarObjetosEInformar(get1b,get1b);
      end;
      'S':begin//soltar objetos
        if FaltaInformacion(2) then exit;
        with Jugador[codJugador] do
          Mapa[codMapa].SoltarObjeto(Jugador[codJugador],get1b{ind},get1b{cantidad});//Va invertido en los parámetros:
      end;
      'R':EnviarBolsaCompleta(Jugador[codJugador]);//activar revisar bolsas, cadáveres.
      'r':begin//recoger un objeto específico
        if FaltaInformacion(2) then exit;
        with Jugador[codJugador] do
          Mapa[codMapa].RecogerObjeto(Jugador[codJugador],GET1B{ind},GET1B{cantidad});//Va invertido en los parámetros:
      end;
      'a'://alzar objetos
        with Jugador[codJugador] do
          Mapa[codMapa].AlzarObjetos(Jugador[codJugador]);
      '$':begin//Sacar dinero
        if FaltaInformacion(3) then exit;
        with Jugador[codJugador] do
          Mapa[codMapa].SacarDinero(Jugador[codJugador],Jugador[codJugador],get3b);
      end;
      'V':begin//vender objetos (Ojo tiene 3 parámetros, total 4 bytes)
        if FaltaInformacion(4) then exit;
        OfrecerVenderObjetoANPC;
      end;
      'C':begin//comprar objetos (Ojo tiene 3 parámetros, total 4 bytes)
        if FaltaInformacion(4) then exit;
        ComprarObjetoANPC;
      end;
      '#':;//Ofrecer objetos
      ')'://Aceptar oferta
        Mapa[Jugador[codJugador].codMapa].AceptarOferta(Jugador[codJugador]);
      '|'://Llamar la atencion de NPC, si es comerciante se para y te mira.
        Mapa[Jugador[codJugador].codMapa].LlamarAtencionNPC(Jugador[codJugador],get2b);
      'i':ActivarIraTenax(Jugador[codJugador]);//Activar Ira Tenax
      'z':ActivarZoomorfismo(Jugador[codJugador]);//Activar Zoomorfismo
      'e'://Meditar
        with Jugador[codJugador] do
          Mapa[codMapa].MeditarJugador(Jugador[codJugador]);
      'd'://Descansar
        with Jugador[codJugador] do
          Mapa[codMapa].DescansarJugador(Jugador[codJugador]);
      'o'://Ocultarse
        with Jugador[codJugador] do
          Mapa[codMapa].OcultarJugador(Jugador[codJugador]);
      'j':begin//seleccionar con(j)uro
        if FaltaInformacion(1) then exit;
        with Jugador[codJugador] do
        begin
          conjuroElegido:=get1b;
          if not longbool(Conjuros and (1 shl conjuroElegido)) then
          begin
            conjuroElegido:=ninguno;//Si no conoce el conjuro.
            MostrarMensajeID('Selección erronea de hechizo');
          end
        end;
      end;
      '&':begin//comando de GM
        if FaltaInformacion(1) then exit;
        case char(get1b) of
          'J':if (DatosUsuario[codJugador].EstadoUsuario>=euAdminB)
                or ServidorEnModoDeComunicacionTotal then
                  ObtenerListaActivos(Jugador[codJugador],true{Listar jugadores});
          'K':if (DatosUsuario[codJugador].EstadoUsuario>=euAdminB)
                or ServidorEnModoDeComunicacionTotal then
                  ObtenerListaActivos(Jugador[codJugador],false{Listar clanes});
          'O':begin//Creacion de objeto
            if FaltaInformacion(2) then exit;
            ConjuroMasterCrearArtefacto(get1b,get1b);
          end;
          'T':begin
            if FaltaInformacion(3) then exit;
            ConjuroMasterTeletransportarse;
          end;
          'L':if DatosUsuario[codJugador].EstadoUsuario>=euAdminB then EliminarCadaveres;
          'R':if not ProcesarMensajeDeBusqueda(tmbRestaurar) then exit;
          'A':if not ProcesarMensajeDeBusqueda(tmbAnularClan) then exit;
          'B':if not ProcesarMensajeDeBusqueda(tmbBuscar) then exit;
          'C':if not ProcesarMensajeDeBusqueda(tmbConvocar) then exit;
          'V':if not ProcesarMensajeDeBusqueda(tmbVisitar) then exit;
          'P':if not ProcesarMensajeDeBusqueda(tmbPrision) then exit;
          'E':if not ProcesarMensajeDeBusqueda(tmbExpulsar) then exit;
          'H':if not ProcesarMensajeDeBusqueda(tmbPermitirChat) then exit;
          'h':if not ProcesarMensajeDeBusqueda(tmbNegarChat) then exit;
          'X':if not ProcesarMensajeDeBusqueda(tmbHeroeLegendario) then exit;
          'D':begin
            if FaltaInformacion(2) then exit;
            ConjuroMasterDisolverMonstruo(get2b);
          end;
          'M':begin
            if FaltaInformacion(2) then exit;
            ControlMasterDeMonstruo(get2b);
          end;
          '(':begin
            if FaltaInformacion(1) then exit;
            ConjuroMasterConjurarMonstruo(get1b);
          end;
          '"':if not ConjuroMasterHablarAlMundo(true) then exit;
          else realizarSeppuku;//'?'
        end;
      end;
      'X':begin//comandos eXtendidos
        if FaltaInformacion(1) then exit;
        case char(get1b) of
          '.':begin//Ya no está viendo el bolso de objetos
            with Jugador[codJugador] do
              FlagsComunicacion:=(FlagsComunicacion or flRevisandoBolsa) xor flRevisandoBolsa;
          end;
          's':begin//seleccionar habilidad
            if FaltaInformacion(1) then exit;
            Jugador[codJugador].HabilidadResaltada:=get1b;
          end;
          'C'://Cambiar contraseña
          begin
            if FaltaInformacion(8) then exit;//getTpassword
            datosUsuario[codJugador].Password:=GetTPassword;
            socket.SendText('Ix');
          end;
          'R'://Ir a resucitar, teletransporta cerca de catedral
            RealizarPalabradelRetorno(Jugador[codJugador]);
          'S'://activa y desactiva el seguro
            with Jugador[codJugador] do
            begin
              FlagsComunicacion:=FlagsComunicacion xor flModoPKiller;
              if (FlagsComunicacion and flModoPKiller)=0 then
                socket.SendText('I'+#10)//modo seguro
              else
                socket.SendText('I'+#11);
            end;
          'T'://peticion de hora del mundo del servidor
            socket.SendText('IT'+b2astr(Conta_Universal));
          'G'://grupo
          begin
            if FaltaInformacion(2) then exit;//
            ProcesarComandoDeGrupo(get2b);
          end;
          'g'://cancelar grupo
          begin
            EliminarEnlacesDeParty(Jugador[codJugador]);
            with Jugador[codJugador] do
              SendText(codJugador,'Igc'+camaradasPartyACadena);
          end;
          'X'://Detener todo
          begin
            DetenerAcciones(Jugador[codJugador]);
          end;
          '!'://Salir
          begin
            if Jugador[codJugador].NivelAgresividad>0 then
            begin
              //Demora de fin de sesion
              Jugador[codJugador].FlagsComunicacion:=Jugador[codJugador].FlagsComunicacion or flSaliendoDelServidor;
              DatosUsuario[codJugador].TimerDesconeccionPorOcio:=TIEMPO_ANTES_DE_DESCONECTAR-1;
            end
            else
              DatosUsuario[codJugador].TimerDesconeccionPorOcio:=0;
          end;
          else MostrarMensajeErrorSesion;
        end;
      end;
      '!':if not ProcesarMensajeIniciarSesion then exit;
      '*'://Crear un nuevo personaje
      begin
        if not CrearNuevoPersonaje then exit;
        break;
      end
      else //case
        MostrarMensajeErrorSesion;
    end;//case
    //Para no revisar el siguiente comando
    if SalirDelInterpretador then break;
    with Jugador[codJugador] do
    begin
      inc(MensajesEnviadosEn16Turnos);
      if MensajesEnviadosEn16Turnos>64 then
      begin
        Mensaje('Desconectado por "flood": '+nombreAvatar);
        SocketDelJugador[codJugador].close
      end
    end;
  end;//while
  socket.BufferRecepcion:='';
end;

end.
