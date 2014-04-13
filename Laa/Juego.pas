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

unit Juego;
//Para estadísticas
{$DEFINE CONTROL_ESTADISTICAS}
//Para test
{$DEFINE FPS}
{$DEFINE ESPERA_PARA_CREAR_AVATAR}
interface
uses
  windows, Classes, Controls, Graphics,Forms,StdCtrls,
  GTimer,Gboton,UCliente,MPlayerLite,UMensajes,Demonios,Graficador,Graficos,objetos,
  DirectDraw,MundoEspejo,Sprites, ScktComp, MidiOut,MidiFile,
  messages,buscar_ip,sysutils, ExtCtrls;

const
     ext_Midi='.mid';
     ext_MP3='.mp3';
     crCursorPersonalizado=1;
     ATOM_CREACION_AVATAR:Pchar='bß˜{þª+“¨‘';
     Men_Sennala_En_Inventario='Señala el objeto en el inventario';
     Men_Abre_El_Inventario='Selecciona la pestaña del inventario';
     CrdndBtn:array[0..4] of smallint=(0,58,110,157,190);
     Ancho_Panel_Info=168;
     Alto_Panel_Info=144;
     IdPnPuntajes=0;
     IdPnPericias=1;
     IdPnEquipo=2;
     IdPnMapa=3;
     IdPnPrincipal=4;
     IdGrInventario=0;
     IdGrConjuros=1;
     BAJA_FRECUENCIA=67;//67
     ALTA_FRECUENCIA=BAJA_FRECUENCIA shr 1;
     TIMER_TEXTO_JUGADOR=20;//1 seg.
     NRO_MAX_DE_MENSAJES_EN_COLA=$3F;//SIEMPRE potencia de 2 -1.

     //Interfaz
     clEsmeralda=$00A0FF60;
     clFondo=$00A0DFDA;
     clOro=$0058F2FF;
     clPlata=$00FFE8CA;
     clCelesteClaro=$00FFF0E0;
     clRubi=$0068B0FF;
     clBronce=$0074C8D6;
     clBronceClaro=$00C0F0F4;
     clBronceOscuro=$00385860;
     clAmarilloPalido=$00D8F8FF;
     clBlanco=clWhite;
     //Coordenadas destino para objetos:
     CrdndDstnObjts:array[0..8] of Trect=(
       (left:410;top:104;Right:450;Bottom:144),//Arma D.
       (left:370;top:104;Right:410;Bottom:144),//Arma I.
       (left:112;top:60;Right:152;Bottom:100),//Armadura
       (left:112;top:18;Right:152;Bottom:58),//Casco
       (left:0;top:102;Right:40;Bottom:142),//Obj D.
       (left:112;top:102;Right:152;Bottom:142),//Obj I.
       (left:0;top:60;Right:40;Bottom:100),//Amuleto
       (left:0;top:18;Right:40;Bottom:58),//Municion
       (left:458;top:104;Right:498;Bottom:144));//Magia
     //Nombres de posiciones de los objetos:
     NmbrsHabilidades:array[0..4] of string[$D]=(//14
       'Fuerza:',
       'Constitución:',
       'Inteligencia:',
       'Sabiduría:',
       'Destreza:');
     NmbrsPscnsObjts:array[0..7] of string[34]=(//20
       'Mano derecha',
       'Mano izquierda',
       'Casilla para Armaduras/Vestimentas',
       'Casilla para Cascos/Gorros',
       'Casilla para Brazaletes/Anillos',
       'Casilla para Anillos',
       'Casilla para Amuletos',
       'Casilla para Municiones');
type
  TModoVentana=(mvNormal,mvMaximizada,mvAutomatica);
  TEstadoJuego=(ejNoPreparado,ejMenu,ejLogin,ejCrear,ejBorrar,ejConectando,ejProgreso);
//----------------------------------------------------------------------------
  TJForm = class(TForm)
    EditMensaje: TEdit;
    PBInterfaz: TPaintBox;
    E_Identificador: TEdit;
    E_contrasenna: TEdit;
    E_nombre: TEdit;
    E_confirmar: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure B_OpcionesClick(Sender: TObject);
    procedure EditMensajeKeyPress(Sender: TObject; var Key: Char);
    procedure PantallaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Salir1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure PBInterfazMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MP_musicaNotify(Sender: TObject);
    procedure DGObjetosAlDibujarCelda(Col,Fil: Integer; ARect: TRect;Seleccionado:bytebool);
    procedure DGConjurosAlDibujarCelda(Col,Fil: Integer; ARect: TRect;Seleccionado:bytebool);
    procedure DGObjetosMouseDown(Button: TMouseButton;Acol,Afil:shortint);
    procedure DGConjurosMouseDown(Button: TMouseButton;Acol,Afil:shortint);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PBInterfazPaint(Sender: TObject);
    procedure BMenu_SalirClick(Sender: TObject);
    procedure BMenu_IngresarClick(Sender: TObject);
    procedure B_AceptarClick(Sender: TObject);
    procedure B_CancelarClick(Sender: TObject);
    procedure BMenu_CrearClick(Sender: TObject);
    procedure B_DadosClick(Sender: TObject);
    procedure LB_perMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBInterfazMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure b_ArribaClick(Sender: TObject);
    procedure B_AbajoClick(Sender: TObject);
    procedure btnClaseClick(Sender: TObject);
    procedure BtnRazaClick(Sender: TObject);
    procedure BtnGeneroClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure BtnServidorClick(Sender: TObject);
    procedure BtnPuertoClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MidiFileUpdateEvent(Sender: TObject);
    procedure BtnRapidasClick(Sender: TObject);
    procedure B_TxAbajoClick(Sender: TObject);
    procedure B_txArribaClick(Sender: TObject);
    procedure BtnBuscarClick(Sender: TObject);
  private
    { Private declarations }
    fVentanaActivada:TVentanaActivada;
    FEsperar:TFEsperar;
    MP_Musica:TMediaPlayer;
    LbTexto:array[0..4] of TLabel;
    LbPericia:array[0..15] of Tlabel;
    //Labels de habilidades:
    Lb_FRZ,Lb_INT,Lb_SAB,Lb_DES,Lb_CON,
    Lb_Genero,Lb_Clase,Lb_Raza:TLabel;
    //Imagenes para interfaz
    Fondo, //barra de mensajes/interfaz/botones
    Objjug, //barra para objetos
    FondoTexto:Tbitmap; //area de texto descriptor
    //Interfaz del juego
    miramapa,puntoResalte:Tbitmap;
    PnInfo,PnGrids:IDirectDrawSurface7;
    MarcaMapaAnterior:Tposicion;
    //Cadenas de pericias:
    NombrePericiaJugador:array[0..2] of string[17];
    //Botones
    B_Abajo,B_Arriba,B_Aceptar,B_Cancelar,B_Dados,
    B_Opciones,B_TxAbajo,B_txArriba,
    BMenu_crear,BMenu_Ingresar,BMenu_Salir:TGBoton;
    BtnBuscar,BtnClase,BtnGenero,BtnRaza,
    BtnServidor,BtnPuerto,BtnRapidas:TGBoton;
    //LabelLogicos panel izquierdo
    LbCat,LbFrz,LbDes,LbCon,LbSab,LbInt,LbExp,
    LbDan,LbAta,LbDef,lbArm,lbAMg,LbRep,LbMo,LbMp,LbTitulo:TLabelLogico;
    //El elemento que dibuja los labels
    LbPanelInfo:TDibujadorLabel;
    //Para evitar abuso en creacion de avatares:
    IdDeAtomDeCreacion:word;
    NroAvataresCreados:byte;
    //Midi
    midioutput:TMidiOutput;
    midiFile:TMidiFile;
    procedure HablarAhora(CaracterInicial:char);
    procedure MarcarAutor;
    procedure PintarConjuro(NroConjuro:integer;destx,desty:integer;Handle:integer;conCuadro:boolean);
    procedure PresionarBotonInfo(id:integer);
    procedure PintarBotonInfo(Brillando:bytebool);
    procedure PintarBotonGrid(Brillando:bytebool);
    procedure PintarMarcasDeHabilidades(borrar:bytebool);
    procedure SetVentanaActivada(valor:TVentanaActivada);
    procedure MaximizarMinimizarPantalla(solorestaurar:boolean);
//  RED y CONEXIÓN
//----------------------------------------------------
    procedure TratarIniciarSesion(NroAleatorioServidor:integer);
//  REFRESCADORES
//********************************************************
    procedure SRefrescarObjeto(Posicion,id,modificador:byte;Seleccionar:boolean);//id:0..7:usado, 8..MAX_POSICIONES:artefacto del bolso
    procedure SetMensaje(const mensaje:Tcaption);
    procedure SetMensajeTip(const mensaje:Tcaption);
    procedure SetMensajeTipTimer(const mensaje:Tcaption);
//Sockets
//***************************
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure AlLeerIP(Sender: TObject; Socket: TCustomWinSocket);
    procedure IPClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  protected
    procedure paint; override;
  public
    { Public declarations }
    LabelComida,LabelVida,LabelMana,LbMensaje:TLabel;
    VolverAMostrarVentanaComercio:boolean;
    Timer:TGTimer;
    //Del juego
    ContrasennaUU:Tcadena15;
    NombreLoginUU,IdentificadorUU:TCadenaLogin;
    TimerTextoDelJugador:integer;
    TextoDelJugadorAlServidor:Tcadena127;
    SpriteAnteriorApuntado:TmonstruoS;
    TipoTextoDelJugadorAlServidor:char;
    //Señal en el minimapa
    MiniMapa_DibujarSennal,//si es >0 se dibuja una señal en la posición.
    MiniMapa_X,MiniMapa_Y:byte;
    //Globales
    EstadoGeneralDelJuego:TEstadoJuego;
    IDConjuroElegidoEnElServidor:byte;
    //Interfaz de paneles
    RepintarPanelGrids,RepintarPanelInfo:bytebool;
    IdPanelActivado:integer;
    IdGridActivado:integer;
    //UltimoMensageAgregado:string;
    NumeroDeMensajesAgregados,IndiceDelUltimoMensaje,IndiceDePosicionLibreParaMensaje:integer;
    ListaDeMensajesAgregados:array[0..NRO_MAX_DE_MENSAJES_EN_COLA] of string;
    //Para los iconos.
    Imagen40:TImagen40;
    TablaCC_Botones,TablaCC_Arca,BarraVidaMana:IDirectDrawSurface7;
    botonesMenu,Rostros,Iconos_Objetos,cuadroResalte,CuadroNoPuedesUsar,IconosCjr:Tbitmap;
    Pergamino_Mapa:IDirectDrawSurface7;
    CanvasInterfaz:Tcanvas;//Referencia al canvas donde debe dibujarse la interfaz
    //Grids
    DGObjetos,DGConjuros:TGridLogico;
    //Creacion del personaje
    DatosPersonajeCl:TDatosNuevoPersonaje;
    NroPericiasResaltadas:integer;
    //Para el interpretador de comandos
    CodigoCNXJugador:integer;//De conexión en el servidor.
    //Musica de fondo
    MusicaTocada:string[2];
    RequerimientoDeCambiarMusicaPendiente:bytebool;
    MusicaActivada:bytebool;
    MusicaTipoMP3:bytebool;
{$IFDEF CONTROL_ESTADISTICAS}
    //Estadisticas:
    FechaHoraInicio:TDateTime;
    NrBytesRecibidos:integer;
    NumeroArribosDatos:integer;
    procedure Mostrar_Estadisticas;
{$ENDIF}
    property VentanaActivada:TVentanaActivada read fVentanaActivada write SetVentanaActivada;
    property MensajeAyuda:Tcaption write SetMensaje;//Va con agregar mensaje, si está repetido parpadea y sonido.
    property MensajeTip:Tcaption write SetMensajeTip;//Un texto informativo al mover el ratón a una zona especial.
    property MensajeTipTimer:Tcaption write SetMensajeTipTimer;//Alternativa a MensajeTip, pero con un timer
//  MUSICA
    procedure desactivarMusica;
    procedure activarMusica;
    function ElegirArchivoDeMusica:string;
    procedure TocarMusicaDeFondo(ArchivoMusica:string);
//----------------------------------------------------
//  INTERFAZ DE OBJETOS
    procedure Accion_Usar;
//-----------------------------------------------
//  Para mostrar los botones, edits, labels de acuerdo al estado del juego:
    procedure ActualizarElementosDePantalla;
    procedure ActualizarMiniMapa(ForzarActualizacionYDibujarTodoElMapa:boolean);
//-------------------------
    procedure PintarObjeto(const artefacto:Tartefacto;NoManos:bytebool;destx,desty:integer;Handle:integer;conCuadro,conBrillo:bytebool);
    procedure RealizarAccion(Button:TMouseButton;icono:TIconoSeleccionado;NroObjetoBaul:byte);
    procedure PresionarBotonGrid(id:integer);
    procedure MostrarAyuda;
    procedure IniciarJuego;
    procedure FinalizarJuego;
    procedure AgregarMensaje(const mensaje:string);
    procedure DibujarMensajes;
    procedure LimpiarMensajes;
    procedure PintarObjetoPosicion(Posicion:byte;PintarYSeleccionar:boolean);
    procedure MostrarExperiencia;
    procedure MostrarComida;
    procedure MostrarMana;
    procedure MostrarHP(nuevoHp:word;ActualizacionPorDanno:boolean;const TextoAdicional:string);
    procedure MostrarGAC0;
    procedure MostrarDanno;
    procedure MostrarReputacionJugador;
    procedure MostrarDineroJugador;
    procedure MostrarDatosJugador;
    procedure MostrarDatosFrecuentesJugador;
    procedure MostrarDatosFrecuentesJugadorYObjetos;
    procedure MostrarDatosCompletosJugador;
    procedure ActualizacionCompletaPanelInformacion;
    procedure PintarRostroJugador;
    procedure ActualizarIconoMagiaEspecialidad;
    procedure PrepararPanelGrids;
    procedure PrepararPanelInfo;
    procedure AsegurarCategoriaValidaPorRaza;
    procedure ProcesarRuedaDelRaton(delta,x,y:smallint);
    procedure ProcesarMensajesAplicacion(var Msg: TMsg; var Handled: Boolean);
  end;
var
  JForm:TJForm;
  ClientSocket:TClientSocket;
  Cliente:TClientWinSocket;
  GetIPClientSocket:TGetIPClientSocket;
  fondoMenu:TBitmap;
  G_ServidorWEB,G_NombreDelServidor,G_GameHosting:string;
  Ruta_Aplicacion:string;
  G_PuertoComunicacion,G_PixelesPorPulgada:integer;
  G_Aplicar_Desfase,G_MostrarFPS,G_IniciarConMusica,G_MoverConClickIzquierdo,G_ServidorEnModoDePruebas,G_StereoInverso,G_ModoVentana:bytebool;
  SeRealizoPeticionParaFinalizarSesion:boolean;
  G_ExtensionMusica1,G_ExtensionMusica2:TCadena4;
implementation
{$R *.DFM}
uses Tablero,sonidos,globales,midiType,Urapidas,Uestandartes,UColor8;

procedure TJForm.ProcesarRuedaDelRaton(delta,x,y:smallint);
const AREA_BOTONES_TEXTO:Trect=(left:158;top:368;right:168;bottom:418);
begin
  delta:=delta div 120;
  dec(x,ClientOrigin.x);
  dec(y,ClientOrigin.y);
//  mensajeAyuda:='x:'+intastr(x)+ 'y:'+intastr(y);
  if delta=0 then exit;
  //revisar que elemento cambiar:
  if PuntoDentroRect(x,y,AREA_BOTONES_TEXTO) then
  begin
    if (delta>0) then
      B_txArribaClick(nil)
    else
      B_txAbajoClick(nil);
  end
  else
    if (delta>0) then
      b_ArribaClick(nil)
    else
      b_AbajoClick(nil);
end;

procedure TJForm.ProcesarMensajesAplicacion(var Msg: TMsg; var Handled: Boolean);
begin
  if Active then
    if msg.message=WM_MOUSEWHEEL then
      with msg do
      begin
        ProcesarRuedaDelRaton(smallint(HIWORD(wParam)),smallint(LOWORD(lParam)),smallint(HIWORD(lParam)));
        handled:=true;
      end;
end;

procedure TJForm.FormCreate(Sender: TObject);
  function CrearGraficos:boolean;
  var re:Hresult;
  begin
    Graficador.conta_universal:=@Conta_universal;
    re:=InicializarDirectDraw(self.Handle,G_ModoVentana,screen.width,screen.height);
    result:=re=DD_OK;
    if result then
    begin
      fesperar:=TFEsperar.create(nil);
      with fesperar do
      begin
        show;
        update;
        //antes de crear con objetos de la unidad Graficos
        Graficos.FijarRutaRecuperacionArchivos(Ruta_Aplicacion);
        LB_progreso.caption:='Recuperando gráficos de monstruos';
        LB_progreso.repaint;
        InicializarEfectos(Ruta_Aplicacion+CrptGDD);
        PBar.StepBy(10);
        Tablero.InicializarConstantesTablero(Ruta_Aplicacion+'bin\',nil);
        PBar.StepBy(10);
        Demonios.InicializarMonstruos(Ruta_Aplicacion+'bin\std.mon');
        PBar.StepBy(4);
        Animas:=TColeccionAnimaciones.create;
        PBar.StepBy(20);
        LB_progreso.caption:='Recuperando gráficos del terreno';
        LB_progreso.repaint;
        GrafTablero:=TcoleccionGraficosTablero.create;
        PBar.StepBy(15);
        LB_progreso.caption:='Inicializando mapas';
        Objetos.InicializarColeccionObjetos(Ruta_Aplicacion+'bin\obj.b');
        PBar.StepBy(3);
        Objetos.InicializarColeccionConjuros(Ruta_Aplicacion+'bin\cjr.b');
        PBar.StepBy(3);
        //-------
        Demonios.InicializarMapeoAnimaciones(Ruta_Aplicacion+'bin\mp_anim.b');
        LB_progreso.repaint;
        CrearElMundoEspejo;
        PBar.StepBy(5);
      end
    end
    else
    begin
      showmessageZ(DDErrorString(re));
      application.Terminate;
    end;
  end;
  procedure PrepararInterfaz;
  var i:integer;
  //DESPUES de CREAR GRAFICOS
    procedure CrearEtiquetaH(var etiqueta:Tlabel;x,y:integer;ColorEt:TColor;Tamanno:byte);
    begin
      etiqueta:=Tlabel.Create(self);
      etiqueta.canvas.font.PixelsPerInch:=96;// :(
      with etiqueta do
      begin
        if tamanno>=11 then
          font.Name:=NOMBRE_FONT
        else
        begin
          font.Name:='Tahoma';
          dec(tamanno);
        end;
        font.Size:=Tamanno;
        left:=x;
        top:=y;
        transparent:=true;
        visible:=false;
        if (Tamanno>=11) and (Tamanno<14) then
          font.Style:=[fsBold];
        font.color:=ColorEt;
        ControlStyle:=ControlStyle-[csCaptureMouse]+[csNoStdEvents];
        caption:='';
        parent:=self;
      end;
    end;
    procedure CrearTGBoton(var boton:TGBoton;x,y,ancho,alto:integer;eventoOnClick:TNotifyEvent);
    begin
      boton:=TGBoton.create(self);
      with boton do
      begin
        left:=x;
        top:=y;
        Width:=ancho;
        Height:=alto;
        OnClick:=eventoOnClick;
        parent:=self;
      end;
    end;
  begin
    ClientHeight:=478;
    ClientWidth:=646;
    G_PixelesPorPulgada:=self.PixelsPerInch; // :(
    self.canvas.font.PixelsPerInch:=96; // :(
    PosicionRaton_X:=mitad_ancho_dd;
    PosicionRaton_Y:=mitad_alto_dd;
    GetIPClientSocket:=TGetIPClientSocket.create(self);
    GetIPClientSocket.OnRead:=AlLeerIP;
    GetIPClientSocket.OnError:=IPClientSocketError;
    ClientSocket:=TClientSocket.create(self);
    with ClientSocket do
    begin
      Active := False;
      ClientType := ctNonBlocking;
      OnRead := ClientSocketRead;
      OnError := ClientSocketError;
      OnDisconnect := ClientSocketDisconnect;
      Cliente:=socket;
      SocketErrorProc:=MostrarMensajeErrorEnSocket;
      Port:=G_PuertoComunicacion;
      if PareceIP(G_NombreDelServidor) then
      begin
        host:='';//siempre para que Address tenga prioridad
        Address:=G_NombreDelServidor
      end
      else
        host:=G_NombreDelServidor;
    end;
    conta_Universal:=0;
    sincro_conta_Universal:=0;
    fast_sincro_conta_Universal:=0;
    Timer:=TGTimer.create;
    with Timer do
    begin
      Enabled := False;
      Interval := ALTA_FRECUENCIA;
      OnTimer := TimerTimer;
    end;
    //Para música Midi
    try
      midioutput:=TMidiOutput.Create(self);
      midioutput.DeviceID:=0;//Define default deviceId
    except
      midioutput:=nil;
    end;
    if midioutput<>nil then
      try
        midiFile:=TMidiFile.Create(self);
        midiFile.DefaultMidiOutput:=midioutput;
        midiFile.OnUpdateEvent:=MidiFileUpdateEvent;
      except
        midiFile:=nil;
      end;
    //Para la música MP3
    try
      MP_Musica:=TMediaPlayer.create(Self);
      MP_Musica.OnNotify:=MP_musicaNotify;
      MP_Musica.parent:=self;
    except
      MP_Musica:=nil;
    end;
    //Recuperar Cursor
    Screen.Cursors[crCursorPersonalizado]:=LoadCursorFromFile('laa.cur');
    if Screen.Cursors[crCursorPersonalizado]=0 then
      Screen.Cursors[crCursorPersonalizado]:=LoadCursor(HInstance,'KHER');
    //Menus y paneles
    canvas.brush.style:=bsClear;
    //Acelerar Aplicación quitando propiedades no usadas a los controles
    ControlStyle:=ControlStyle+[csOpaque];
    EditMensaje.ControlStyle:=EditMensaje.ControlStyle-[csDoubleClicks]+[csOpaque]-[csCaptureMouse	];
    PBInterfaz.ControlStyle:=ControlStyle;
    if G_PixelesPorPulgada>96 then //:(
      EditMensaje.Font.Name:='Arial';
//------------------------------------------------------------------------------
// Labels con fondo grafico
    CrearEtiquetaH(LbMensaje,215,422,clBlanco,9);
    CrearEtiquetaH(LabelVida,300,439,clFondo,9);
    CrearEtiquetaH(LabelMana,300,453,clFondo,9);
    CrearEtiquetaH(LabelComida,300,467,clFondo,9);
    for i:=0 to 4 do
      CrearEtiquetaH(LbTexto[i],170,406-13*i,clFondo,9);
    CrearEtiquetaH(Lb_Frz,590,182,clBronceClaro,12);
    CrearEtiquetaH(Lb_Con,590,206,clBronceClaro,12);
    CrearEtiquetaH(Lb_Int,590,230,clBronceClaro,12);
    CrearEtiquetaH(Lb_Sab,590,254,clBronceClaro,12);
    CrearEtiquetaH(Lb_Des,590,276,clBronceClaro,12);
    CrearEtiquetaH(Lb_Clase,88,182,clBronce,14);
    CrearEtiquetaH(Lb_Raza,88,214,clBronce,14);
    CrearEtiquetaH(Lb_Genero,88,246,clBronce,14);
    for i:=0 to 15 do
    begin
      // 8 filas, 2 columnas (shr 3, and $7)
      CrearEtiquetaH(LbPericia[i],258+120*(i shr 3),178+20*(i and $7),clBronce,12);
      with LbPericia[i] do
      begin
        caption:=MC_pericias[i];
        ControlStyle:=LbMensaje.ControlStyle-[csNoStdEvents];
        onMouseDown:=LB_perMouseDown;
      end;
    end;
//Grids:
    DGObjetos:=TGridLogico.create;
    DGObjetos.setPosicion(12,16);//en el panel de grids
    DGObjetos.FuncionDibujarCelda:=DGObjetosAlDibujarCelda;
    DGObjetos.FuncionClikearCelda:=DGObjetosMouseDown;
    DGconjuros:=TGridLogico.create;
    DGconjuros.personalizar(3,10,3,3);
    DGconjuros.setPosicion(12,16);//en el panel de grids
    DGconjuros.FuncionDibujarCelda:=DGConjurosAlDibujarCelda;
    DGconjuros.FuncionClikearCelda:=DGConjurosMouseDown;
//Menus:
    fondoMenu:=CrearDeJDD(Ruta_Aplicacion+CrptGDD+'menu'+ExtArc2);
    botonesMenu:=CrearDeJDD(Ruta_Aplicacion+CrptGDD+'bmenu'+ExtArc2);
//GUI, elementos gráficos de la interfaz de la ventana
    CanvasInterfaz:=PBInterfaz.canvas;
    Fondo:=CrearDeGDD(Ruta_Aplicacion+CrptGDD+'fondo'+ExtArc);
    Objjug:=CrearDeGDD(Ruta_Aplicacion+CrptGDD+'obj-m'+ExtArc);
    FondoTexto:=CrearDeGDD(Ruta_Aplicacion+CrptGDD+'tx'+ExtArc);
    CrearSuperficieDeJDD(TablaCC_Botones,Ruta_Aplicacion+CrptGDD+'tccb'+ExtArc2);
    CrearSuperficieDeJDD(TablaCC_Arca,Ruta_Aplicacion+CrptGDD+'tcca'+ExtArc2);
    CrearSuperficieDeBMP(BarraVidaMana,Ruta_Aplicacion+CrptGDD+'barra'+ExtArc);
//Botones con graficos:
    CrearTGBoton(B_Abajo,502,454,12,24,B_AbajoClick);
    B_Abajo.DefinirGraficos(fondo.canvas,Point(0,108),Point(12,0));
    CrearTGBoton(B_Arriba,502,428,12,24,b_ArribaClick);
    B_Arriba.DefinirGraficos(fondo.canvas,Point(0,84),Point(12,0));
    CrearTGBoton(B_Aceptar,200,356,104,42,B_AceptarClick);
    B_Aceptar.DefinirGraficos(botonesMenu.canvas,Point(0,300),Point(0,42));
    CrearTGBoton(B_Cancelar,330,356,108,42,B_CancelarClick);
    B_Cancelar.DefinirGraficos(botonesMenu.canvas,Point(104,300),Point(0,42));
    CrearTGBoton(B_Dados,532,312,58,62,B_DadosClick);
    B_Dados.DefinirGraficos(botonesMenu.canvas,Point(0,426),Point(58,0));
    CrearTGBoton(B_Opciones,464,422,34,17,B_OpcionesClick);
    B_Opciones.DefinirGraficos(fondo.canvas,Point(48,28),Point(0,17));
    CrearTGBoton(B_txAbajo,158,394,10,24,B_TxAbajoClick);
    B_txAbajo.DefinirGraficos(fondo.canvas,Point(36,108),Point(10,0));
    CrearTGBoton(B_txArriba,158,368,10,24,B_txArribaClick);
    B_txArriba.DefinirGraficos(fondo.canvas,Point(36,84),Point(10,0));
    CrearTGBoton(BMenu_crear,214,230,210,50,BMenu_CrearClick);
    BMenu_crear.DefinirGraficos(botonesMenu.canvas,Point(0,0),Point(0,50));
    CrearTGBoton(BMenu_ingresar,252,150,134,50,BMenu_IngresarClick);
    BMenu_ingresar.DefinirGraficos(botonesMenu.canvas,Point(0,150),Point(0,50));
    CrearTGBoton(BMenu_salir,278,310,82,50,BMenu_SalirClick);
    BMenu_salir.DefinirGraficos(botonesMenu.canvas,Point(134,150),Point(0,50));
//Botones sin graficos
    CrearTGBoton(BtnBuscar,2,414,107,19,BtnBuscarClick);
    BtnBuscar.Color:=clBronce;
    BtnBuscar.Caption:='Buscar Servidor';
    CrearTGBoton(BtnClase,212,182,17,23,btnClaseClick);
    BtnClase.Color:=clBronce;
    BtnClase.Caption:='_v_';
    CrearTGBoton(BtnRaza,212,214,17,23,btnRazaClick);
    BtnRaza.Color:=clBronce;
    BtnRaza.Caption:='_v_';
    CrearTGBoton(BtnGenero,212,246,17,23,btnGeneroClick);
    BtnGenero.Color:=clBronce;
    BtnGenero.Caption:='_v_';
    CrearTGBoton(BtnServidor,2,436,66,19,BtnServidorClick);
    BtnServidor.Color:=clBronce;
    BtnServidor.Caption:='Servidor:';
    CrearTGBoton(BtnPuerto,2,458,66,19,BtnPuertoClick);
    BtnPuerto.Color:=clBronce;
    BtnPuerto.Caption:='Puerto:';
    CrearTGBoton(BtnRapidas,524,414,112,19,BtnRapidasClick);
    BtnRapidas.Color:=clBronce;
    BtnRapidas.Caption:='Teclas rápidas';
//Mini mapa
    CrearSuperficieDeBMP(Pergamino_Mapa,Ruta_Aplicacion+CrptGDD+'mapa'+ExtArc);
    Miramapa:=CrearBackBufferDD(22,11);
      CopiarSuperficieACanvas(Miramapa.canvas.handle,0,0,22,11,Pergamino_Mapa,0,0);
    PuntoResalte:=CrearBackBufferDD(32,16);
      CopiarSuperficieACanvas(PuntoResalte.canvas.handle,0,0,32,16,Pergamino_Mapa,0,11);
    cuadroResalte:=CrearBackBuffer16Bits(40,40);
      CopiarSuperficieACanvas(cuadroResalte.canvas.handle,0,0,40,40,Pergamino_Mapa,0,27);
    CuadroNoPuedesUsar:=CrearBackBuffer16Bits(12,12);
      CopiarSuperficieACanvas(CuadroNoPuedesUsar.canvas.handle,0,0,12,12,Pergamino_Mapa,26,69);
//Iconos varios
    Iconos_Objetos:=CrearDeJDD(Ruta_Aplicacion+CrptGDD+'obj'+ExtArc2);
    Rostros:=CrearDeJDD(Ruta_Aplicacion+CrptGDD+'ros'+ExtArc2);
    IconosCjr:=CrearDeJDD(Ruta_Aplicacion+CrptGDD+'cjr'+ExtArc2);
    Imagen40:=TImagen40.create;
//-----------------------------------------------------------------------------------------
// Paneles de informacion y grids de objetos/conjuros
    //Botones de paneles:
    IdPanelActivado:=IdPnMapa;
    //Botones de Grids
    IdGridActivado:=IdGrInventario;
    CrearSuperficieOculta(PnGrids,136,140,etMagenta);
    CopiarCanvasASuperficie(PnGrids,0,0,136,140,Fondo.canvas.handle,504,4);
    PintarBotonGrid(true);
    CrearSuperficieOculta(PnInfo,Ancho_Panel_Info,Alto_Panel_Info,etMagenta);
    CopiarCanvasASuperficie(PnInfo,0,0,168,32,Fondo.canvas.handle,0,0);
    //Dibujador Labeles
    LbPanelInfo:=TDibujadorLabel.create(PnInfo,Ancho_Panel_Info,Alto_Panel_Info);
    With LbPanelInfo do
    begin
      Registrar(IdPnPuntajes,0,-14,FondoTexto.canvas);
      Registrar(IdPnPericias,0,-14,FondoTexto.canvas);
      Registrar(IdPnEquipo,0,-14,ObjJug.canvas);
      Registrar(IdPnMapa,0,0,Fondo.canvas);
      Registrar(IdPnPrincipal,0,0,Fondo.canvas);
      //Panel puntajes:
      CrearLabel(LbCat,4,16,IdPnPuntajes,clblanco);
      CrearLabel(LbFrz,86,33,IdPnPuntajes,clblanco);
      CrearLabel(LbCon,86,48,IdPnPuntajes,clblanco);
      CrearLabel(LbInt,86,63,IdPnPuntajes,clblanco);
      CrearLabel(LbSab,86,78,IdPnPuntajes,clblanco);
      CrearLabel(LbDes,86,93,IdPnPuntajes,clblanco);
      CrearLabel(LbExp,96,111,IdPnPuntajes,clblanco);
      CrearLabel(LbRep,48,126,IdPnPuntajes,clblanco);
      //Panel Pericias:
      CrearLabel(LbDan,68,66,IdPnPericias,clblanco);
      CrearLabel(LbAta,68,81,IdPnPericias,clblanco);
      CrearLabel(LbDef,68,96,IdPnPericias,clblanco);
      CrearLabel(LbArm,68,111,IdPnPericias,clblanco);
      CrearLabel(LbAMg,4,126,IdPnPericias,clblanco);
      //Panel Objetos
      CrearLabel(LbMp,60,117,IdPnEquipo,clblanco);
      CrearLabel(LbMo,60,130,IdPnEquipo,clblanco);
      //Principal
      CrearLabel(LbTitulo,76,0,IdPnPrincipal,clblanco);
      LbTitulo.alineacion:=axCentro;
    end;
    MusicaTocada:='';
//------------------------------------------------------------------------------
// Configuraciones
    IdDeAtomDeCreacion:=0;
    NroAvataresCreados:=0;
    CodigoCNXJugador:=0;
    NombreLoginUU:='';
    IdentificadorUU:='';//Id del usuario.
    MusicaActivada:=false;
    RequerimientoDeCambiarMusicaPendiente:=false;
    sonidos.Emitir_Sonidos:=DirectSound_Funcionando;
    Zoom_Pantalla:=false;
    Graficos_Transparentes:=false;
    Mostrar_Nombres_Sprites:=false;
    Mostrar_rostros:=false;
    Aplicar_Antialisado:=true;
    Texto_Modalidad_Chat:=false;
    Visores_Vida_Mana:=true;
    G_ServidorEnModoDePruebas:=false;
    RecuperarConfiguracionTeclasRapidas;
  end;
begin
  EstadoGeneralDelJuego:=ejNoPreparado;
//Antes de crear cualquier otro grafico, inicializa la pantalla!!
  if not (CrearGraficos and EJECUTABLE_INTEGRO) then exit;
//Antes de emitir sonidos o musica:
  if not CrearSonidos(self.Handle,Ruta_Aplicacion+'snd\',G_StereoInverso) then
    showmessageZ('No fue posible inicializar Directsound.');
  Application.OnMessage:=ProcesarMensajesAplicacion;
  FEsperar.PBar.StepBy(10);
//Parámetros de configuración y creación de objetos gráficos para interfaz.
  PrepararInterfaz;
  FEsperar.PBar.StepBy(10);
//Aplicacion lista para menu:
  EstadoGeneralDelJuego:=ejMenu;
//Preparar la pantala en el nuevo estado del juego
  ActualizarElementosDePantalla;
//Musica de introduccion
  InicializarMenuOpciones;
  FijarVolumenMidi(25);
  if (screen.width>640) then
    BorderStyle:=BsSingle;
  ClientWidth:=640;
  ClientHeight:=480;
  left:=(Screen.Width-ClientWidth) shr 1;
  top:=(Screen.Height-ClientHeight) shr 1;
  fesperar.free;
end;

procedure TJForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if EstadoGeneralDelJuego>=EjProgreso then
  begin
    Timer.enabled:=false;
    DetenerSonidos;
    EstadoGeneralDelJuego:=ejMenu;
    if ClientSocket.Active then
      ClientSocket.Close;
  end;
  if GetIPClientSocket.Active then GetIPClientSocket.Close;
  hide;
  DesactivarMusica;
end;

procedure TJForm.FormDestroy(Sender: TObject);
begin
  if EstadoGeneralDelJuego>ejNoPreparado then
  begin
    EstadoGeneralDelJuego:=ejNoPreparado;
    LbPanelInfo.free;
    PnInfo:=nil;
    PnGrids:=nil;
    Imagen40.free;
    IconosCjr.free;
    Rostros.free;
    Iconos_Objetos.free;
  //Creados en
    CuadroNoPuedesUsar.free;
    cuadroResalte.free;
    PuntoResalte.free;
    miraMapa.free;
    Pergamino_Mapa:=nil;
  //Creados en "Preparar Interfaz"
    BarraVidaMana:=nil;
    TablaCC_Arca:=nil;
    TablaCC_Botones:=nil;
    FondoTexto.free;
    Objjug.free;
    Fondo.free;
    //Interfaz
    DGConjuros.free;
    DGObjetos.free;
  //al ULTIMO ************************************************
    LiberarSonidos;
    DestruirElMundoEspejo;
    GrafTablero.free;
    Animas.free;
    FinalizarDirectDraw;//Lo último.
  end;
  //Menus
  botonesMenu.free;
  fondoMenu.free;
  Timer.free;
  ClientSocket.free;
  GetIPClientSocket.free;
end;

//*********** Inicializacion y finalizacion del juego

procedure TJForm.IniciarJuego;
var i:integer;
begin
  jugadorCl.prepararParaIngresarJuego;
  IDConjuroElegidoEnElServidor:=ninguno;
  jugadorCl.ElegirElPrimerConjuroDisponible;
  JugadorCL.CambiarAnimacionJugador(JugadorCl.codAnime);
  SpriteAnteriorApuntado:=nil;
  ActualizacionCompletaPanelInformacion;
  EstadoGeneralDelJuego:=ejProgreso;
  ActualizarElementosDePantalla;
  VentanaActivada:=vaNinguna;
  IndiceDeArtefactoSeleccionadoEnElBaul:=0;
  IndiceDeArtefactoSeleccionadoEnElBolso:=0;
  TextoDelJugadorAlServidor:='';
  TimerTextoDelJugador:=0;
  ControlChat.Inicializar;
  ControlMensajes.Inicializar;
  //Inicializar clanes.
  for i:=0 to maxClanesJugadores do ClanJugadores[i].Nombre:='';
end;

procedure TJForm.FinalizarJuego;
begin
  Timer.enabled:=false;
  DetenerSonidos;
  EstadoGeneralDelJuego:=ejMenu;
  ActualizarElementosDePantalla;
  //  Es vital que esta sea la última línea ya que antes de cerrar se llamará a este
  //procedure si EstadoGeneralDelJuego>=EjProgreso
  if ClientSocket.Active then ClientSocket.Close;
end;

//******************* Procedimientos para mostrar estado del avatar

procedure TJForm.MostrarExperiencia;
begin
  lbexp.Caption:=intastr(jugadorCl.experiencia);
end;

procedure TJForm.MostrarGAC0;
begin
  LbAta.caption:=intastr(JugadorCl.nivelAtaque)+'%';
end;

procedure TJForm.MostrarDanno;
begin
  LbDan.caption:=Dannoporcentual_125(JugadorCl.dannoBase shr 2,true);
end;

procedure TJForm.MostrarComida;
begin
  with JugadorCl,LabelComida do
  begin
    Font.color:=ColorParaLabel(comida,MaxComida);
    caption:=intastr(comida)+'%';
  end;
end;

procedure TJForm.MostrarMana;
begin
  with JugadorCl,LabelMana do
  If maxMana>0 then
  begin
    font.color:=ColorParaLabel(mana,Maxmana);
    caption:=intastr(mana)+' de '+intastr(MaxMana);
    ActualizarIconoMagiaEspecialidad;
    if IdGridActivado=IdGrConjuros then
      PrepararPanelGrids;
  end;
end;
procedure TJForm.MostrarHP(nuevoHp:word;ActualizacionPorDanno:boolean;const TextoAdicional:string);
var cad:string;
  function NroPuntos(puntos:integer):string;
  begin
    if puntos=1 then result:='un punto' else result:=intastr(puntos)+' puntos';
    result:=result+' de salud';
  end;
begin
  with jugadorCl,LabelVida do
  begin
    if (nuevoHp>hp) and (not B_txAbajo.Visible) then
      AgregarMensaje('+Recuperaste '+NroPuntos(nuevoHp-hp))
    else if hp>nuevoHp then
    begin
      if ActualizacionPorDanno then
        cad:='-'+TextoAdicional+' por '+intastr(hp-nuevoHp)+' de salud'
      else
      begin
        cad:='-Pierdes '+NroPuntos(hp-nuevoHp);
        if jugadorCl.comida=0 then cad:=cad+', te mueres de hambre';
        if Longbool(jugadorCl.banderas and bnEnvenenado) then cad:=cad+', estás envenenado';
        cad:=cad+TextoAdicional;
      end;
      AgregarMensaje(cad);
    end;
    hp:=nuevoHp;
    Font.color:=ColorParaLabel(Hp,maxhp);
    caption:=intastr(Hp)+' de '+intastr(maxhp);
  end;
end;

procedure TJForm.MostrarDineroJugador;
begin
  with jugadorCl do
  begin
     LbMo.caption:=intastr(dinero div 100);
     LbMp.caption:=intastr(dinero mod 100);
  end;
end;

procedure TJForm.MostrarReputacionJugador;
begin
  with jugadorCl do
  begin
    if (comportamiento<0) then
      LbRep.Color:=clRubi
    else
      LbRep.Color:=clblanco;
    LbRep.caption:=reputacion;
  end;
end;

procedure TJForm.MostrarDatosFrecuentesJugador;
begin
  with jugadorCl do
  begin
    MostrarHp(JugadorCl.hp,false,'');
    MostrarMana;
    MostrarComida;
    MostrarDineroJugador;
    LbExp.Caption:=intastr(experiencia);
    LbCat.Caption:=nombreCategoriaEstandar+', nivel '+intastr(nivel);
    LbAta.caption:=intastr(nivelAtaque)+'%';
    LbDan.caption:=Dannoporcentual_125(dannoBase shr 2,true);
    if (defensa+modDefensa<=50) then
      LbDef.Color:=clRubi
    else
      LbDef.Color:=clblanco;
    LbDef.caption:=intastr(defensa-50)+'%'+intastrBonoPorcentual(modDefensa);
    LbArm.caption:=ArmaduraPorcentual(armadura[integer(taPunzante)])+' '+ArmaduraPorcentual(armadura[integer(taCortante)])+' '+ArmaduraPorcentual(armadura[integer(taContundente)]);
    LbAMg.caption:='H.'+ArmaduraPorcentual(armadura[integer(taHielo)])+
      ' F.'+ArmaduraPorcentual(armadura[integer(taFuego)])+
      ' R.'+ArmaduraPorcentual(armadura[integer(taRayo)])+
      ' V.'+ArmaduraPorcentual(armadura[integer(taVeneno)]);
    MostrarReputacionJugador;
  end;
end;

procedure TJForm.MostrarDatosFrecuentesJugadorYObjetos;
begin
  if EditMensaje.visible then
  begin
    EditMensaje.text:='';
    EditMensaje.visible:=false;
  end;
  MostrarDatosFrecuentesJugador;
  //Objetos de las manos
  PintarObjetoPosicion(uArmaIzq,false);
  PintarObjetoPosicion(uArmaDer,false);
  if IdGridActivado=IdGrInventario then
    PrepararPanelGrids;
  if IdPanelActivado=IdPnEquipo then
    PrepararPanelInfo;
end;

procedure TJForm.MostrarDatosJugador;
begin
  with jugadorCl do
  begin
    If maxMana<=0 then
    begin
      //No usa magia
      LabelMana.font.color:=clFondo;
      LabelMana.caption:='-/-'
    end;
    LbFrz.caption:=intastr(FRZ*5)+'%';
    LbCon.caption:=intastr(CON*5)+'%';
    LbInt.caption:=intastr(INT*5)+'%';
    LbSab.caption:=intastr(SAB*5)+'%';
    LbDes.caption:=intastr(DES*5)+'%';
    PintarMarcasDeHabilidades(true);
    MostrarDatosFrecuentesJugador;
  end;
end;

procedure TJForm.MostrarDatosCompletosJugador;
var i,c:integer;
begin
  with jugadorCl do
  begin
    if esVaron then NombrePericiaJugador[0]:=MC_Genero[0] else NombrePericiaJugador[0]:=MC_Genero[1];
//    LbNom.Caption:=infMon[TipoMonstruo].nombre+' '+NombrePericiaJugador[0];
    MostrarDatosJugador;
    c:=0;
    for i:=0 to 15 do
      if LongBool(Pericias and (1 shl i)) then
      begin
        NombrePericiaJugador[c]:=MC_Pericias[i];
        inc(c);
        if (c=3) then break;
      end;
  end;
end;

procedure TJForm.ActualizacionCompletaPanelInformacion;
begin
  if EditMensaje.visible then
  begin
    EditMensaje.text:='';
    EditMensaje.visible:=false;
  end;
  IdPanelActivado:=IdPnEquipo;
  LbPanelInfo.InvalidarPanel(IdPanelActivado);
  if IdGridActivado<>IdGrInventario then
    PresionarBotonGrid(IdGrInventario);
  DGObjetos.col:=0;
  DGObjetos.fil:=0;
  DGConjuros.col:=JugadorCl.ConjuroElegido mod 3;
  DGConjuros.fil:=JugadorCl.ConjuroElegido div 3;
  B_Arriba.Visible:=false;
  B_Abajo.Visible:=true;
  LimpiarMensajes;
  MostrarDatosCompletosJugador;
  PBInterfaz.repaint;
  //Paneles de datos:
  PrepararPanelGrids;
  PrepararPanelInfo;
  //Datos del jugadorCl:
end;

procedure TJForm.DibujarMensajes;
var nColor:Tcolor;
    informacion:string;
    i:integer;
begin
  for i:=0 to 4 do
  begin
    informacion:=ListaDeMensajesAgregados[(IndiceDelUltimoMensaje-i) and NRO_MAX_DE_MENSAJES_EN_COLA];
    nColor:=clFondo;
    if length(informacion)>0 then
    begin
      case informacion[1] of
        '+':nColor:=clOro;
        '-':nColor:=clRubi;
        '!':nColor:=clblanco;
        '*':nColor:=clCelesteClaro;
        '·':nColor:=clAmarilloPalido;
      end;
      if (nColor<>clFondo) then
        delete(informacion,1,1);
    end;
    LbTexto[i].Caption:=informacion;
    LbTexto[i].Font.Color:=nColor;
  end;
  B_txArriba.Visible:=(IndiceDelUltimoMensaje>IndiceDePosicionLibreParaMensaje+4-NumeroDeMensajesAgregados);
  B_txAbajo.Visible:=IndiceDelUltimoMensaje<IndiceDePosicionLibreParaMensaje-1;
end;

procedure TJForm.AgregarMensaje(const mensaje:string);
begin
  if length(mensaje)>1 then
  begin
    ListaDeMensajesAgregados[IndiceDePosicionLibreParaMensaje and NRO_MAX_DE_MENSAJES_EN_COLA]:=mensaje;
    IndiceDelUltimoMensaje:=IndiceDePosicionLibreParaMensaje;
    if NumeroDeMensajesAgregados<=NRO_MAX_DE_MENSAJES_EN_COLA then
      inc(NumeroDeMensajesAgregados);
    inc(IndiceDePosicionLibreParaMensaje);
    DibujarMensajes;
  end;
end;

procedure TJForm.LimpiarMensajes;
var i:integer;
begin
  for i:=0 to 4 do
  begin
    LbTexto[i].Caption:='';
    ListaDeMensajesAgregados[NRO_MAX_DE_MENSAJES_EN_COLA-i]:='';
  end;
  lbMensaje.caption:='';
  LbMensaje.tag:=0;
  IndiceDePosicionLibreParaMensaje:=0;
  NumeroDeMensajesAgregados:=0;
  IndiceDelUltimoMensaje:=0;
end;

{$IFDEF CONTROL_ESTADISTICAS}
procedure TJForm.Mostrar_Estadisticas;
var segundos:double;
    cad,temp:string;
begin
  if NrBytesrecibidos>0 then
  begin
    segundos:=(Now-FechaHoraInicio)*86400;
    str(segundos:0:2,temp);
    cad:='Segundos:'+temp+'  Bytes:'+intastr(NrBytesrecibidos);
    str((NrBytesrecibidos/segundos):0:2,temp);
    cad:=cad+'  B/s:'+temp+#13;
    cad:=cad+'Paq:'+intastr(NumeroArribosDatos);
    str((NumeroArribosDatos/segundos):0:2,temp);
    cad:=cad+'  Paq/s:'+temp;
    str((NrBytesrecibidos/NumeroArribosDatos):0:2,temp);
    cad:=cad+'  B/Paq:'+temp;
    str(((NrBytesrecibidos+NumeroArribosDatos*48)/segundos):0:2,temp);
    cad:=cad+'  ((B+48)*Paq)/s:'+temp;
  end
  else cad:='B/s:0';
  ShowmessageZ(cad);
  NrBytesrecibidos:=0;
  NumeroArribosDatos:=0;
  FechaHoraInicio:=now;
end;
{$ENDIF}

procedure TJForm.SetVentanaActivada(valor:TVentanaActivada);
begin
  VolverAMostrarVentanaComercio:=(fVentanaActivada=vaMenuComercio) and (valor=vaMenuConfirmacion);
  if (fVentanaActivada=vaMenuObjetos) and (valor<>vaMenuObjetos) then
    Cliente.SendTextNow('X.');
  fVentanaActivada:=valor;
  if fVentanaActivada=vaInformacion then TimerMenuInformacion:=(length(MensajeVentanaInformacion) shl 2+32) shl Desplazador_AniSincro;
  CambiarAreaDibujable(Zoom_Pantalla,(valor=vaMenuComercio) or (valor=vaMenuConstruccion) or (valor=vaMenuBaul) or (valor=vaMenuObjetos));
end;

procedure TJForm.MaximizarMinimizarPantalla(solorestaurar:boolean);
var EstadoDelTimer:boolean;
begin
  EstadoDelTimer:=Timer.enabled;
  if (screen.width>640) xor solorestaurar then
  begin
    CambiarAModoPantallaCompleta(false,screen.width,screen.height);
    BorderStyle:=bsNone;
  end
  else
  begin
    CambiarAModoVentana;
    BorderStyle:=bsSingle;
  end;
  ClientWidth:=640;
  ClientHeight:=480;
  left:=(Screen.Width-width) shr 1;
  top:=(Screen.height-height) shr 1;
  Timer.enabled:=EstadoDelTimer;
end;

procedure TJForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
// MensajeAyuda:=intastr(key);
 if (key=13) and (ssAlt in Shift) then
 begin
   MaximizarMinimizarPantalla(false);
   key:=0;
   exit;
 end;
 if EstadoGeneralDelJuego>=ejProgreso then
 if not EditMensaje.visible then
 begin
    with MapaEspejo do
    case key of
      //moverse
      38:JMover(dsNorte);
      40:JMover(dsSud);
      37:JMover(dsOeste);
      39:JMover(dsEste);
      36:JMover(dsNorOeste);
      35:JMover(dsSudOeste);
      33:JMover(dsNorEste);
      34:JMover(dsSudEste);
      //correr
      104:JMover(dsNorte or mskMovimientoContinuo);
      98:JMover(dsSud or mskMovimientoContinuo);
      100:JMover(dsOeste or mskMovimientoContinuo);
      102:JMover(dsEste or mskMovimientoContinuo);
      103:JMover(dsNorOeste or mskMovimientoContinuo);
      97:JMover(dsSudOeste or mskMovimientoContinuo);
      105:JMover(dsNorEste or mskMovimientoContinuo);
      99:JMover(dsSudEste or mskMovimientoContinuo);
      12,27,101:JDetenerAcciones;
      //Atacar
      17:JAtacar(false);
      32:JAtacar(true);
      16:JLanzarConjuro(false,true);
      //Hablar
      13:HablarAhora(#0);
      111:HablarAhora('/');
      106:HablarAhora('*');
      107:HablarAhora('&');
      109:HablarAhora('%');
      //Acciones de tecla rápida
//      73:JIraTenax;
//      79:JOcultarse;
//      82://RecogerObjetos
//        JRecogerObjetos;
//      83://SoltarObjetos 'S'
//        JSoltarObjetoElegido(0);
//      85://Usar Objetos
//        Accion_Usar;
//      90:JZoomorfismo;//Zoomorfismo, ojo sin armas.
      48..57,ord('A')..ord('Z'):begin//Teclas rápidas
        RealizarAccionRapida(key);
      end;
    end;
  case key of //Sólo interfaz
    //ayuda F1.
    112:MostrarAyuda;
    113:begin//F2
         if (Timer.Interval=BAJA_FRECUENCIA) then
           Timer.Interval:=ALTA_FRECUENCIA
         else
           Timer.Interval:=BAJA_FRECUENCIA;
         SActualizarNroInterpolados;
       end;
    114:begin//F3
//      Mostrar_Nombres_Jugadores:=bytebool((byte(Mostrar_Nombres_Jugadores)+1) and $3);
      Mostrar_Nombres_Sprites:=not Mostrar_Nombres_Sprites;
      DatosMenuOpciones.elemento[0].marcado:=Mostrar_Nombres_Sprites;
    end;
    115:begin//F4
      Mostrar_rostros:=not Mostrar_rostros;
      DatosMenuOpciones.elemento[1].marcado:=Mostrar_rostros;
    end;
    116:begin//F5
      Graficos_Transparentes:=not Graficos_Transparentes;
      DatosMenuOpciones.elemento[2].marcado:=Graficos_Transparentes;
    end;
    117:begin//F6
      Zoom_Pantalla:=not Zoom_Pantalla;
      DatosMenuOpciones.elemento[3].marcado:=Zoom_Pantalla;
      VentanaActivada:=VentanaActivada;//Actualiza el area dibujable.
    end;
    118:begin//F7
      Aplicar_Antialisado:=not Aplicar_Antialisado;
      DatosMenuOpciones.elemento[4].marcado:=Aplicar_Antialisado;
    end;
    119:begin//F8
      G_Aplicar_Desfase:=not G_Aplicar_Desfase;
      DatosMenuOpciones.elemento[5].marcado:=G_Aplicar_Desfase;
    end;
    120:begin//F9
      if DirectSound_Funcionando then
        sonidos.Emitir_Sonidos:=not sonidos.Emitir_Sonidos
      else
        sonidos.Emitir_Sonidos:=FALSE;
      DatosMenuOpciones.elemento[6].marcado:=sonidos.Emitir_Sonidos;
    end;
    121:begin//F10
      if MusicaActivada then DesactivarMusica else ActivarMusica;
      DatosMenuOpciones.elemento[7].marcado:=MusicaActivada;
    end;
    122:begin//F11
      Texto_Modalidad_Chat:= not Texto_Modalidad_Chat;
      DatosMenuOpciones.elemento[8].marcado:=Texto_Modalidad_Chat;
    end;
    123:with TFRapidas.create(Application) do
    begin
      showmodal;
      free;
    end;
    45:if not G_IniciarConMusica then//insert.
      begin
        case (sincro_conta_Universal shr 4) and $1F of
          0:jugadorCl.codAnime:=moAriete;
          1:jugadorCl.codAnime:=fxSangre;
          2:jugadorCl.codAnime:=2;
          3:jugadorCl.codAnime:=5;
          4:jugadorCl.codAnime:=20;
          5:jugadorCl.codAnime:=21;
          6:jugadorCl.codAnime:=22;
          7:jugadorCl.codAnime:=23;
          8:jugadorCl.codAnime:=30;
          9:jugadorCl.codAnime:=31;
          10:jugadorCl.codAnime:=32;
          11:jugadorCl.codAnime:=33;
          12:jugadorCl.codAnime:=49;
          13:jugadorCl.codAnime:=112;
          14:jugadorCl.codAnime:=142;
          15:jugadorCl.codAnime:=101;
          16:jugadorCl.codAnime:=102;
          17:jugadorCl.codAnime:=103;
          18:jugadorCl.codAnime:=104;
          19:jugadorCl.codAnime:=110;
          20:jugadorCl.codAnime:=120;
          21:jugadorCl.codAnime:=128;
          22:jugadorCl.codAnime:=129;
          23:jugadorCl.codAnime:=140;
          24:jugadorCl.codAnime:=150;
          25:jugadorCl.codAnime:=151;
          26:jugadorCl.codAnime:=160;
          27:jugadorCl.codAnime:=161;
          28:jugadorCl.codAnime:=170;
          29:jugadorCl.codAnime:=180;
          30:jugadorCl.codAnime:=181;
          else jugadorCl.codAnime:=182;
        end;
        MapaEspejo.Lanzar_Rayo:=2;
     end;
{    begin
      JugadorCl.NivelEspecializacion:=sincro_conta_Universal shr 2;
      JugadorCl.EspecialidadArma:=45;
      MensajeAyuda:=JugadorCl.DescribirEspecialidad;
    end;}
{    begin
      JugadorCl.comportamiento:=-100;
      ActualizacionCompletaPanelInformacion;
    end;}
{    begin
      agregarMensaje('Terbol:'+inttohex(MapaEspejo.getterbolXY(jugadorcl.coordx,jugadorcl.coordy),4)+
        'Recurso:'+inttostr(MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)));
    end;}
    27:VentanaActivada:=vaNinguna;//Esc
{$IFDEF CONTROL_ESTADISTICAS}
    69:if (ssAlt in Shift) then Mostrar_Estadisticas;//E
{$ENDIF}
  end;
  if (key=115) and (ssAlt in Shift) then close;
  key:=0;
 end
 else//comerse las F1 a F12
   if (key>=112) and (key<=122) then key:=0;
end;

procedure TJForm.PintarObjeto(const artefacto:Tartefacto;NoManos:bytebool;destx,desty:integer;Handle:integer;conCuadro,conBrillo:bytebool);
var
  nro_objetos:integer;
  cadena:string[5];
  brillo:TbrilloObjeto;
  objeto:byte;
begin
  objeto:=artefacto.id;
  if (objeto<4) then //dibujar manos
    if noManos then
      bitblt(Imagen40.canvas.handle,0,0,40,40,0,0,0,CMBLACKNESS)
    else
    begin
      if (jugadorCl.TipoMonstruo=rzOrco) then
        brillo:=boVenenoso
      else
        if (jugadorCl.TipoMonstruo=rzDrow) then
          brillo:=boMagico
        else
          brillo:=boNinguno;
      Imagen40.copiarImagen(objeto*40,0,Iconos_Objetos,TBrilloFxObjeto(brillo));
    end
  else
  begin
    if conBrillo or conCuadro then
      brillo:=BrilloObjeto(artefacto,jugadorCl.CapacidadId)
    else
      brillo:=boNinguno;
    Imagen40.copiarImagen((objeto and $7)*40,(objeto shr 3)*40,Iconos_Objetos,TBrilloFxObjeto(brillo));
  end;
  //Nro de elementos
  nro_objetos:=NumeroElementos(artefacto);
  if (objeto=6) then//dinero, mo x 10
    nro_objetos:=nro_objetos*10;
  if (objeto=7) then//dinero mo x 100
    nro_objetos:=nro_objetos*100;
  if (nro_objetos=1) then
    if (objeto>=orGemaInicial) and (objeto<=orGemaFinal) and (artefacto.modificador<=100) then
      cadena:=intastr(artefacto.modificador)+'%'
    else
      cadena:=''
  else
    cadena:=intastr(nro_Objetos);
  if cadena<>'' then//Simple, escribir cadena.
  with Imagen40.canvas do
  begin
    Font.Color:=clBlack;
    textout(2,27,cadena);
    Font.Color:=clblanco;
    textout(1,26,cadena);
  end;
  if conCuadro then
    Imagen40.copiarTransMagenta(CuadroResalte);
  bitblt(Handle,destx,desty,40,40,Imagen40.canvas.handle,0,0,SRCCOPY);
end;

procedure TJForm.PintarConjuro(NroConjuro:integer;destx,desty:integer;Handle:integer;conCuadro:boolean);
var
  brillo:TBrilloFxObjeto;
  TotalMana:integer;
begin
  if longBool(jugadorCl.Conjuros and (1 shl NroConjuro)) then
  begin
    with JugadorCl do
    begin
      TotalMana:=mana;
      if Usando[uArmaIzq].id=ihVaritaLlena then inc(TotalMana,Usando[uArmaIzq].modificador);
    end;
    if TotalMana>=InfConjuro[NroConjuro].nivelMana then
      brillo:=bfxNinguno
    else
      brillo:=bfxMedioBrillo
  end
  else
    brillo:=bfxOscuro;
  Imagen40.copiarImagen((NroConjuro and $7)*40,(NroConjuro shr 3)*40,IconosCjr,TBrilloFxObjeto(brillo));
  if conCuadro then
    Imagen40.copiarTransMagenta(CuadroResalte);
  bitblt(Handle,destx,desty,40,40,Imagen40.canvas.handle,0,0,SRCCOPY);
end;

procedure TJForm.PintarObjetoPosicion(Posicion:byte;PintarYSeleccionar:boolean);
var HDCSuperficie:HDC;
    c,f:byte;
    ObjetoPintar:Tartefacto;
begin
  if Posicion<=7 then
  begin
    if (IdPanelActivado=IdPnEquipo) or (Posicion=uArmaDer) or (Posicion=uArmaIzq) then
      with CrdndDstnObjts[Posicion] do
        if Posicion<=1 then
        begin
          ObjetoPintar:=jugadorCl.usando[Posicion];
          if ObjetoPintar.id<4 then
            if (posicion=1) and (InfObj[JugadorCl.Usando[uArmaDer].id].PesoArma=paPesada) then
              ObjetoPintar.id:=3
            else
              ObjetoPintar.id:=posicion;
          PintarObjeto(ObjetoPintar,false,left,top-16,CanvasInterfaz.handle,false,true)
        end
        else
          if pnInfo.GetDC(HDCSuperficie)=DD_OK then
          begin
            PintarObjeto(jugadorCl.usando[Posicion],true,left,top,HDCSuperficie,false,true);
            pnInfo.ReleaseDC(HDCSuperficie);
          end;
    repintarPanelInfo:=repintarPanelInfo or (IdPanelActivado=IdPnEquipo);
  end
  else
    if IdGridActivado=IdGrInventario then
      //Seleccionar el último agregado:
      with DgObjetos do
      begin
        dec(Posicion,8);
        c:=Posicion mod 3;
        f:=Posicion div 3;
        if PintarYSeleccionar and ((c<>byte(col)) or (f<>byte(fil))) then
        begin
          DGObjetosAlDibujarCelda(col,fil,LimitesCelda(col,fil),false);
          col:=c;
          fil:=f;
          B_Abajo.visible:=PrimeraFil<3;
          b_Arriba.visible:=PrimeraFil>0;
        end;
        DGObjetosAlDibujarCelda(c,f,LimitesCelda(c,f),seleccionado(c,f));
        RepintarPanelGrids:=true;
      end;
end;

procedure TJForm.MostrarAyuda;
begin
  AgregarMensaje('Ataque ofensivo: Ctrl · Defensivo: Espacio · Hechizos: Shift');
  AgregarMensaje('Chat: Enter · Prefijos: "%"=A todos, "*"=Al clan, "&&"=Runas');
  AgregarMensaje('/SOLtar /RECoger /VENder /COMprar /DEScansar /MEDitar');
  AgregarMensaje('/DINero /JUGadores /CLAnes /CAStillo /CONtraseña');
  AgregarMensaje('El uso de las teclas está listado en "Menú,Teclas rápidas"');
end;

procedure TJForm.B_OpcionesClick(Sender: TObject);
begin
  if VentanaActivada=vaMenuOpciones then
    VentanaActivada:=vaNinguna
  else
    VentanaActivada:=vaMenuOpciones;
end;

procedure TJForm.HablarAhora;
const
  INDICA_UNA_CANTIDAD_250='Escribe una cantidad de 1 a 250';
  INDICA_UN_PORCENTAJE='Indica el volumen de 0 a 100';
  INDICA_CANTIDAD_MP_VALIDA='Escribe una cantidad de 1 a 99mp';//mp junto al número!
  MAX_MONEDAS_MO=500;
  INDICA_CANTIDAD_MO_VALIDA='Escribe una cantidad de 1 a 500mo';//mo junto al número!
  COMANDO_DESCONOCIDO='Comando desconocido';
  TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO='Tienes que estar frente a tu castillo';
  NO_TIENES_SUFICIENTE_NECESITAS='No te alcanza, necesitas: ';
  INDICA_NOMBRE_ARCHIVO_MUSICA='Escribe el nombre del archivo de música';
  INDICA_NOMBRE_CLAN='Escribe el nuevo nombre para el clan';
  INDICA_NOMBRE_AVATAR='Escribe el nombre de un avatar';
  INDICA_QUE_MEJORARAS_DEL_CASTILLO='Escribe la mejora que deseas realizar:';
  MEJORA_DE_CASTILLO_DESCONOCIDA='Mejoras disponibles para el castillo:';
  MEJORAS_DE_CASTILLO_DISPONIBLES='Armadura,Visión,Guardia,Fuerza,Tiempo,Ataque,Maná,Resistencia';
  INDICA_ID_Y_MODIFICADOR_DE_OBJETO='Indica el id. y modificador de objeto, ej: /objeto 220 1';
  INDICA_COORDENADAS_MAPA_X_Y='Indica el mapa y posición, ej: /mover 0 120 120';
  ERROR_NO_NECESITA_PARAMETROS='No necesitas parámetros para este comando';
  TODOS_LOS_PARAMETROS_ENTRE_0_Y_255='El comando sólo admite números (0..255)';
  ESCRIBE_CODIGO_MONSTRUO='Escribe el código del monstruo (';
type
  TestadoComando=(ecOk,ecError,ecFaltaParametros);
  TParametros=record
    cadena:array[0..3] of string[31];
    Nro:byte;
  end;
var
    CadParametros:string;
    CadMensaje:Tcadena127;
    numero:array[0..3]of integer;
    ListaParametros:TParametros;
  function NoEsAdministrador:boolean;
  begin
    result:=(JugadorCl.comportamiento<=comHeroe) and (G_ServidorEnModoDePruebas=false);
    if result then
      MensajeAyuda:='Comando reservado para administración.'
  end;
  procedure ExtraerComando(var cadena:Tcadena127;var Parametro:TParametros);
  var i,j:integer;
  begin
    cadena:=trimleft(copy(cadena,2,length(cadena)));
    i:=pos(' ',cadena);
    if i>0 then
      CadParametros:=trimleft(copy(cadena,i,length(cadena)))
    else
      CadParametros:='';
    Parametro.Nro:=0;
    for i:=3 downto 0 do
    begin
      j:=length(cadena);
      while j>0 do
      begin
        if cadena[j]=' ' then //buscando espacio desde la derecha.
        begin
          Parametro.cadena[Parametro.Nro]:=copy(cadena,j+1,15);//copiar 3 caracteres desde el espacio
          inc(Parametro.Nro);
          //Eliminar espacios duplicados
          while (j>0) and (cadena[j]=' ') do dec(j);
          cadena[0]:=char(j);
          break;
        end;
        dec(j);
      end;
      if j=0 then exit;
    end;
  end;
  function ControlParametroDinero(const cadena:string;var cantidad:integer;MoPredefinido:boolean):boolean;
  //Reconoce si son mp o mo.
  //En numero coloca la cantidad en mp.
  var code:integer;
      sufijo:string[3];
  begin
    cantidad:=0;
    result:=false;
    if length(cadena)<=0 then exit;
    sufijo:=Uppercase(copy(cadena,length(cadena)-1,2));
    if sufijo='MO' then
    begin
      val(copy(cadena,1,length(cadena)-2),cantidad,code);
      if code<>0 then
      begin
        MensajeAyuda:=INDICA_CANTIDAD_MO_VALIDA;
        exit;
      end;
      MoPredefinido:=true;
    end
    else
      if sufijo='MP' then
      begin
        val(copy(cadena,1,length(cadena)-2),cantidad,code);
        if code<>0 then
        begin
          MensajeAyuda:=INDICA_CANTIDAD_MP_VALIDA;
          exit;
        end;
        MoPredefinido:=false;
      end
      else//Cantidad simple
      begin
        val(cadena,cantidad,code);
        if code<>0 then
        begin
          if MoPredefinido then
            MensajeAyuda:=INDICA_CANTIDAD_MO_VALIDA
          else
            MensajeAyuda:=INDICA_CANTIDAD_MP_VALIDA;
          exit;
        end;
      end;
    if MoPredefinido then
    begin
      if (cantidad>MAX_MONEDAS_MO) then
      begin
        cantidad:=0;
        MensajeAyuda:=INDICA_CANTIDAD_MO_VALIDA
      end;
      cantidad:=cantidad*100;
    end
    else
      if (cantidad>99) then
      begin
        cantidad:=0;
        MensajeAyuda:=INDICA_CANTIDAD_MP_VALIDA
      end;
    result:=(cantidad>0);
  end;
  function StrToRunas(const cadena:string):string;
  //Elimina espacios al inicio y el caracter inicial
  var i,inicio:integer;
  begin
    inicio:=2;
    i:=length(cadena);
    result:='';
    while (cadena[inicio]=' ') and (inicio<i) do inc(inicio);
    for i:=inicio to length(cadena) do
      if upcase(cadena[i]) in ['A'..'Z'] then
        result:=result+chr(ord(upcase(cadena[i]))+64)
      else
        if (cadena[i]='ñ') or (cadena[i]='Ñ') then
          result:=result+#175
        else
          if cadena[i] in [#32..#64,'['..#126] then
            result:=result+cadena[i];
  end;
  procedure HablarAlServidor(const mensaje:string;TipoComando:char);
  var colorMensaje:Tcolor;
  begin
    if (length(mensaje)>79) or (length(mensaje)<1) then exit;
    if TimerTextoDelJugador<=0 then
    begin
      TimerTextoDelJugador:=TIMER_TEXTO_JUGADOR;
      Cliente.sendTextNow(TipoComando+char(length(mensaje))+mensaje);
      if TipoComando='H' then
        ControlMensajes.setMensaje(jugadorCl,mensaje);
      case TipoComando of
        'T':colorMensaje:=ClPlata;
        'G':colorMensaje:=ClOro;
        else colorMensaje:=clblanco;
      end;
      ControlChat.setMensaje(jugadorCl,mensaje,colorMensaje)
    end
    else
    begin
      if TextoDelJugadorAlServidor<>'' then
        MensajeAyuda:='Descartado: '+copy(TextoDelJugadorAlServidor,1,32)+'...'
      else
        MensajeAyuda:='La pausa entre mensajes es de 1 segundo...';
      TextoDelJugadorAlServidor:=mensaje;
      TipoTextoDelJugadorAlServidor:=TipoComando;
    end;
  end;
  function ComparaCadenas(const cad:string; comando:string):boolean;
  //Compara dos cadenas, cad debe tener por lo menos 3, compara tantos
  //caracteres como tenga cad.
  var i:integer;
  begin
    result:=false;
    if length(cad)<3 then exit;
    if length(cad)>length(comando) then exit;
    for i:=1 to length(cad) do
      if cad[i]<>comando[i] then exit;
    result:=true;
  end;

begin
  if not EditMensaje.visible then
  begin
    if CaracterInicial=#0 then
      EditMensaje.text:=''
    else
      EditMensaje.text:=CaracterInicial;
    EditMensaje.visible:=true;
    activeControl:=EditMensaje;
//    EditMensaje.Perform(WM_KEYDOWN,102,0);
    EditMensaje.Perform(WM_KEYDOWN,39,24);
  end
  else
    begin
      EditMensaje.visible:=false;
      CadMensaje:=trim(EditMensaje.text);
      EditMensaje.text:='';
      if CadMensaje<>'' then //Nada de cadenas vacias
        case CadMensaje[1] of
          '/'://Cadenas de comandos
          begin//primero cadenas cortas, luego largas
            ExtraerComando(CadMensaje,ListaParametros);
            CadMensaje:=uppercase(CadMensaje);
            // Comandos con prioridad en abreviacion
            //**************************************
            if ComparaCadenas(CadMensaje,'SOLTAR') then
            begin
              if IdGridActivado=IdGrInventario then
                if (ListaParametros.Nro=0) then
                  MapaEspejo.JSoltarObjetoElegido(0)
                else
                  if (ListaParametros.Nro=1) and ControlParametroEntero(ListaParametros.cadena[0],1,MAX_NRO_OBJETOSxCASILLA,Numero[0]) then
                    MapaEspejo.JSoltarObjetoElegido(Numero[0])
                  else
                    MensajeAyuda:=INDICA_UNA_CANTIDAD_250
              else
                MensajeAyuda:=Men_Sennala_En_Inventario;
            end
            else if ComparaCadenas(CadMensaje,'RECOGER') then
            begin
              if VentanaActivada=VaMenuObjetos then
                if IdGridActivado=IdGrInventario then
                  if (ListaParametros.Nro=0) then
                    MapaEspejo.JRecogerObjetoElegido(IndiceDeArtefactoSeleccionadoEnElBolso,0)
                  else
                    if (ListaParametros.Nro=1) and ControlParametroEntero(ListaParametros.cadena[0],1,MAX_NRO_OBJETOSxCASILLA,Numero[0]) then
                      MapaEspejo.JRecogerObjetoElegido(IndiceDeArtefactoSeleccionadoEnElBolso,Numero[0])
                    else
                      MensajeAyuda:=INDICA_UNA_CANTIDAD_250
                else
                  MensajeAyuda:=Men_Abre_El_Inventario
              else
                MapaEspejo.JRevisarObjetos;
            end
            else if ComparaCadenas(CadMensaje,'DESCANSAR') then
            begin
              MapaEspejo.JDescansar;
            end
            else if ComparaCadenas(CadMensaje,'MEDITAR') then
            begin
              MapaEspejo.JMeditar;
            end
            else if ComparaCadenas(CadMensaje,'VENDER') then
            begin
              if (ListaParametros.Nro=0) then
                MapaEspejo.JVender(DGObjetos.indice,0,JugadorCl.apuntado)
              else
              if (ListaParametros.Nro=1) and
               ControlParametroEntero(ListaParametros.cadena[0],1,MAX_NRO_OBJETOSxCASILLA,Numero[0]) then
                MapaEspejo.JVender(DGObjetos.indice,Numero[0],JugadorCl.apuntado)
              else
                MensajeAyuda:=INDICA_UNA_CANTIDAD_250;
            end
            else if ComparaCadenas(CadMensaje,'DINERO') then
            begin
              if (ListaParametros.Nro>=1) then
              begin
                if ControlParametroDinero(ListaParametros.cadena[0],Numero[0],ListaParametros.Nro=1) then
                  if (ListaParametros.Nro=2) then
                    if ControlParametroDinero(ListaParametros.cadena[1],Numero[1],true) then
                      inc(Numero[0],Numero[1]);
                MundoEspejo.JSacarDinero(Numero[0]);
              end
              else
                MensajeAyuda:=INDICA_CANTIDAD_MO_VALIDA;
            end
            else if ComparaCadenas(CadMensaje,'COMPRAR') then
            begin
              //verificar que esté activo el menu de comercio:
              if VentanaActivada=vaMenuComercio then
                if (ListaParametros.Nro=1) and
                  ControlParametroEntero(ListaParametros.cadena[0],1,MAX_NRO_OBJETOSxCASILLA,Numero[0]) then
                    RealizarPeticionParaComprar(Numero[0])
                else
                  MensajeAyuda:=INDICA_UNA_CANTIDAD_250
              else
                MensajeAyuda:='Señala a un comerciante para abrir la ventana de comercio';
            end
            else if ComparaCadenas(CadMensaje,'CONTRASEÑA') then
            begin
              if (ListaParametros.Nro=2) then
                if length(ListaParametros.cadena[0])<14 then
                  if length(ListaParametros.cadena[0])>=4 then
                    if not repeticionEnContrasenna(ListaParametros.cadena[0]) then
                      if not loguinParecidoAContrasenna(NombreLoginUU,e_contrasenna.text) then
                        if ListaParametros.cadena[1]=ContrasennaUU then
                          Cliente.SendTextNow('XC'+PasswordAStr(EmpaquetarPassword(QuitarCaracteresNoPermitidos(ListaParametros.cadena[0]),IdentificadorUU)))
                        else
                          MensajeAyuda:='Primero escribe tu contraseña actual'
                      else
                        MensajeAyuda:=MC_CONTRASENNA_CON_LOGIN
                    else
                      MensajeAyuda:=MC_CONTRASENNA_CON_REPETICIONES
                  else
                    MensajeAyuda:=MC_CONTRASENNA_CORTA
                else
                  MensajeAyuda:='La contraseña no debe exeder 13 caracteres'
              else
                MensajeAyuda:=MC_INDICA_IDENTIFICADOR
            end
            else if ComparaCadenas(CadMensaje,'RETORNO') then
            begin
              JPalabraDelRetorno;
            end
            else if ComparaCadenas(CadMensaje,'AVATAR') then
            begin//Crea un personaje en disco
              if G_ServidorEnModoDePruebas then
                MensajeAyuda:='No puedes guardar tu avatar en modo de Pruebas'
              else
                if GuardarAvatarActual then
                  MensajeAyuda:='Tu avatar fue guardado en tu disco, carpeta "laa\avatares\"'
                else
                  MensajeAyuda:='No se pudo guardar tu avatar';
            end
            else if ComparaCadenas(CadMensaje,'JUGADORES') then
            begin
              MapaEspejo.JmostrarJugadoresMapa;
            end
            else if ComparaCadenas(CadMensaje,'CLANES') then
            begin
              MapaEspejo.JmostrarClanesMapa;
            end
            else if ComparaCadenas(CadMensaje,'CASTILLO') then
            begin
              MapaEspejo.JMostrarEstadoDelCastillo;
            end
            else if ComparaCadenas(CadMensaje,'GUARDAR') then
            begin
              if VentanaActivada=VaMenuBaul then
                if IdGridActivado=IdGrInventario then
                  if (ListaParametros.Nro=0) then
                    MapaEspejo.JGuardarEnBaul(DGObjetos.indice,0{Todo})
                  else
                    if (ListaParametros.Nro=1) and ControlParametroEntero(ListaParametros.cadena[0],1,MAX_NRO_OBJETOSxCASILLA,Numero[0]) then
                      MapaEspejo.JGuardarEnBaul(DGObjetos.indice,Numero[0])
                    else
                      MensajeAyuda:=INDICA_UNA_CANTIDAD_250
                else
                  MensajeAyuda:=Men_Sennala_En_Inventario
              else
                MensajeAyuda:=MEN_ABRE_EL_BAUL
            end
            else if ComparaCadenas(CadMensaje,'SACAR') then
            begin
              if VentanaActivada=VaMenuBaul then
                if IdGridActivado=IdGrInventario then
                  if (ListaParametros.Nro=0) then
                    MapaEspejo.JSacarDeBaul(IndiceDeArtefactoSeleccionadoEnElBaul,0{Todo})
                  else
                    if (ListaParametros.Nro=1) and ControlParametroEntero(ListaParametros.cadena[0],1,MAX_NRO_OBJETOSxCASILLA,Numero[0]) then
                      MapaEspejo.JSacarDeBaul(IndiceDeArtefactoSeleccionadoEnElBaul,Numero[0])
                    else
                      MensajeAyuda:=INDICA_UNA_CANTIDAD_250
                else
                  MensajeAyuda:=Men_Abre_El_Inventario
              else
                MensajeAyuda:=MEN_ABRE_EL_BAUL
            end
            else if ComparaCadenas(CadMensaje,'TOCAR') then
            begin
              if (ListaParametros.Nro=1) then
                TocarMusicaDeFondo(ListaParametros.cadena[0])
              else
                MensajeAyuda:=INDICA_NOMBRE_ARCHIVO_MUSICA
            end
            else if ComparaCadenas(CadMensaje,'VMIDI') then
            begin
              if (ListaParametros.Nro=1) and ControlParametroEntero(ListaParametros.cadena[0],0,100,Numero[0]) then
                FijarVolumenMidi(Numero[0])
              else
                MensajeAyuda:=INDICA_UN_PORCENTAJE
            end
            else if ComparaCadenas(CadMensaje,'AGRESIVIDAD') then
            begin
              Cliente.SendTextNow('XS')
            end
            else if ComparaCadenas(CadMensaje,'HORA') then
            begin
              Cliente.SendTextNow('XT')
            end
            else if ComparaCadenas(CadMensaje,'ATACAR') then
            begin
              JEnviarOrden('a');
            end
            else if ComparaCadenas(CadMensaje,'DETENER') then
            begin
              JEnviarOrden('d');
            end
            else if ComparaCadenas(CadMensaje,'SEGUIR') then
            begin
              JEnviarOrden('s');
            end
            else
            // Comandos no prioritarios en abreviacion
            //****************************************
            if ComparaCadenas(CadMensaje,'ESTANDARTE') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if (JugadorCl.clan<=maxClanesJugadores) and //tiene clan
                   (MapaEspejo.castillo.clan=JugadorCl.clan) and
                   (MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)=irCastillo) then
                    with FEstandartes do
                    begin
                      if (Quinteto0 or quinteto1)=0 then
                        with ClanJugadores[MapaEspejo.castillo.Clan].PendonClan do
                        begin
                          quinteto0:=color0;
                          quinteto1:=color1;
                        end;
                      if execute then
                        Cliente.SendTextNow('KP'+b4aStr(Quinteto1)+b4aStr(Quinteto0))
                    end
                  else
                    MensajeAyuda:=TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if ComparaCadenas(CadMensaje,'COLORCLAN') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if (JugadorCl.clan<=maxClanesJugadores) and //tiene clan
                   (MapaEspejo.castillo.clan=JugadorCl.clan) and
                   (MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)=irCastillo) then
                    with TFColor8.create(Application) do
                    begin
                      color8:=ClanJugadores[JugadorCl.clan].colorClan;
                      if execute then
                        Cliente.SendTextNow('K('+char(color8));
                      free;
                    end
                  else
                    MensajeAyuda:=TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if ComparaCadenas(CadMensaje,'TESORO') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if (JugadorCl.clan<=maxClanesJugadores) and
                   (MapaEspejo.castillo.clan=JugadorCl.clan) and
                   (MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)=irCastillo) then
                    Cliente.SendTextNow('KT')
                  else
                    MensajeAyuda:=TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if ComparaCadenas(CadMensaje,'RETIRAR') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if (JugadorCl.clan<=maxClanesJugadores) and
                   (MapaEspejo.castillo.clan=JugadorCl.clan) and
                   (MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)=irCastillo) then
                    if (ListaParametros.Nro>=1) then
                    begin
                      if ControlParametroDinero(ListaParametros.cadena[0],Numero[0],ListaParametros.Nro=1) then
                        if (ListaParametros.Nro=2) then
                          if ControlParametroDinero(ListaParametros.cadena[1],Numero[1],true) then
                            inc(Numero[0],Numero[1]);
                      MundoEspejo.JRetirarDineroCastillo(Numero[0]);
                    end
                    else
                      MensajeAyuda:=INDICA_CANTIDAD_MO_VALIDA
                  else
                    MensajeAyuda:=TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if ComparaCadenas(CadMensaje,'DEPOSITAR') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if (JugadorCl.clan<=maxClanesJugadores) and
                   (MapaEspejo.castillo.clan=JugadorCl.clan) and
                   (MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)=irCastillo) then
                    if (ListaParametros.Nro>=1) then
                    begin
                      if ControlParametroDinero(ListaParametros.cadena[0],Numero[0],ListaParametros.Nro=1) then
                        if (ListaParametros.Nro=2) then
                          if ControlParametroDinero(ListaParametros.cadena[1],Numero[1],true) then
                            inc(Numero[0],Numero[1]);
                      MundoEspejo.JDepositarDineroCastillo(Numero[0]);
                    end
                    else
                      MensajeAyuda:=INDICA_CANTIDAD_MO_VALIDA
                  else
                    MensajeAyuda:=TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if ComparaCadenas(CadMensaje,'NOMBRECLAN') then
            begin
              if CadParametros<>'' then
                if JugadorCl.hp<>0 then
                  if (JugadorCl.banderas and BnParalisis)=0 then
                    if JugadorCl.clan<=maxClanesJugadores then
                    begin
                      delete(CadParametros,24,maxint);
                      Cliente.SendTextNow('KN'+char(length(CadParametros))+CadParametros)
                    end
                    else
                      MensajeAyuda:=JugadorCl.MensajeResultado(i_NoPertenecesAUnClan,0,0)
                  else
                    MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
              else
                MensajeAyuda:=INDICA_NOMBRE_CLAN
            end
            else if ComparaCadenas(CadMensaje,'RECLUTAR') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if JugadorCl.clan<=maxClanesJugadores then
                    if JugadorCl.apuntado is TjugadorS then
                      Cliente.SendTextNow('KR'+b2astr(JugadorCl.apuntado.codigo))
                    else
                      MensajeAyuda:=JugadorCL.MensajeResultado(i_PrimeroApuntaAUnJugador,0,0)
                  else
                    MensajeAyuda:=JugadorCl.MensajeResultado(i_NoPertenecesAUnClan,0,0)
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if CadMensaje='DEJARCLAN' then//dejar clan
            begin
              if JugadorCl.clan<=maxClanesJugadores then
                Cliente.SendTextNow('KD'+b2astr(JugadorCl.codigo))
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_NoPertenecesAUnClan,0,0);
            end
            else if ComparaCadenas(CadMensaje,'MIEMBROS') then
            begin
              if JugadorCl.clan<=maxClanesJugadores then
                Cliente.SendTextNow('KL')
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_NoPertenecesAUnClan,0,0);
            end
            else if ComparaCadenas(CadMensaje,'DESPEDIR') then//despedir del clan
            begin
              if JugadorCl.clan<=maxClanesJugadores then
                if JugadorCl.apuntado is TjugadorS then
                  Cliente.SendTextNow('KD'+b2astr(JugadorCl.apuntado.codigo))
                else
                  MensajeAyuda:=JugadorCL.MensajeResultado(i_PrimeroApuntaAUnJugador,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_NoPertenecesAUnClan,0,0);
            end
            else if ComparaCadenas(CadMensaje,'MEJORAR') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if (JugadorCl.clan<=maxClanesJugadores) and
                    ((MapaEspejo.castillo.clan=JugadorCl.clan)) and
                    (MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)=irCastillo) then
                  begin
                    CadParametros:=uppercase(CadParametros);
                    if ComparaCadenas(CadParametros,'ATAQUE') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_ATAQUE then
                        Cliente.SendTextNow('KMA')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_ATAQUE)
                    end
                    else
                    if ComparaCadenas(CadParametros,'ARMADURA') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_ARMADURA then
                        Cliente.SendTextNow('KMD')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_ARMADURA)
                    end
                    else
                    if ComparaCadenas(CadParametros,'VISIóN') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_VISION then
                        Cliente.SendTextNow('KMV')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_VISION)
                    end
                    else
                    if ComparaCadenas(CadParametros,'MANá') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_MANA then
                        Cliente.SendTextNow('KMM')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_MANA)
                    end
                    else
                    if ComparaCadenas(CadParametros,'RESISTENCIA') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_MANA then
                        Cliente.SendTextNow('KMR')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_MANA)
                    end
                    else
                    if ComparaCadenas(CadParametros,'FUERZA') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_FUERZA then
                        Cliente.SendTextNow('KMF')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_FUERZA)
                    end
                    else
                    if ComparaCadenas(CadParametros,'GUARDIA') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_GUARDIA then
                        Cliente.SendTextNow('KMG')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_GUARDIA)
                    end
                    else
                    if ComparaCadenas(CadParametros,'TIEMPO') then
                    begin
                      if JugadorCl.dinero>=COSTO_MEJORAR_TIEMPO then
                        Cliente.SendTextNow('KMT')
                      else
                        MensajeAyuda:=NO_TIENES_SUFICIENTE_NECESITAS+DineroAStr(COSTO_MEJORAR_TIEMPO)
                    end
                    else
                    begin
                      if CadParametros='' then
                        MensajeAyuda:=INDICA_QUE_MEJORARAS_DEL_CASTILLO
                      else
                        MensajeAyuda:=MEJORA_DE_CASTILLO_DESCONOCIDA;
                      MensajeAyuda:=MEJORAS_DE_CASTILLO_DISPONIBLES
                    end;
                  end
                  else
                    MensajeAyuda:=TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if ComparaCadenas(CadMensaje,'BAUL') then
            begin
              if JugadorCl.hp<>0 then
                if (JugadorCl.banderas and BnParalisis)=0 then
                  if ((JugadorCl.clan<=maxClanesJugadores) and (MapaEspejo.castillo.clan=JugadorCl.clan) and (MapaEspejo.ObtenerRecursoAlFrente(JugadorCl)=irCastillo))
                   or (JugadorCl.Usando[uArmaDer].id=orBaulMagico) then
                  begin
                    if IdGridActivado=IdGrConjuros then
                      PresionarBotonGrid(IdGrInventario);
                    Cliente.SendTextNow('KB')
                  end
                  else
                    MensajeAyuda:=TIENES_QUE_ESTAR_FRENTE_A_TU_CASTILLO
                else
                  MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
            end
            else if ComparaCadenas(CadMensaje,'GRUPO') then
            begin
              if JugadorCl.hp<>0 then
                Cliente.SendTextNow('XG'+b2astr(JugadorCl.apuntadoEnFormatoCasilla))
              else
                MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0);
            end
            else if ComparaCadenas(CadMensaje,'CANCELARGRUPO') then
            begin
              Cliente.SendTextNow('Xg')
            end
            else if ComparaCadenas(CadMensaje,'SALIR') then
            begin
              ControlChat.setMensaje(nil,'Saliendo del servidor, espera unos segundos...',clOro);
              SeRealizoPeticionParaFinalizarSesion:=true;
              Cliente.SendTextNow('X!');
            end
            //COMANDOS DE ADMINISTRADOR *********************************************
            else if ComparaCadenas(CadMensaje,'OBJETO') then
            begin
              if NoEsAdministrador and
                ((ListaParametros.Nro<>2) or (ListaParametros.cadena[0]<>'127') or (ListaParametros.cadena[1]<>'2')) then exit;
              if ListaParametros.Nro=2 then
                if ControlParametroEntero(ListaParametros.cadena[0],0,255,Numero[0]) and
                   ControlParametroEntero(ListaParametros.cadena[1],0,255,Numero[1]) then
                  Cliente.SendTextNow('&O'+char(Numero[0])+char(Numero[1]))
                else
                  MensajeAyuda:=TODOS_LOS_PARAMETROS_ENTRE_0_Y_255
              else
                MensajeAyuda:=INDICA_ID_Y_MODIFICADOR_DE_OBJETO
            end
            else if ComparaCadenas(CadMensaje,'CONJURAR') then
            begin
              if NoEsAdministrador then exit;
              if (ListaParametros.Nro=1) and ControlParametroEntero(ListaParametros.cadena[0],0,255,Numero[0]) then
                Cliente.SendTextNow('&('+char(Numero[0]))
              else
                MensajeAyuda:=ESCRIBE_CODIGO_MONSTRUO+intastr(Inicio_tipo_monstruos)+'..'+intastr(Fin_tipo_monstruos)+')';
            end
            else if ComparaCadenas(CadMensaje,'MOVER') then
            begin
              if NoEsAdministrador then exit;
              if ListaParametros.Nro=2 then
                if ControlParametroEntero(ListaParametros.cadena[0],0,255,Numero[0]) and
                   ControlParametroEntero(ListaParametros.cadena[1],0,255,Numero[1]) then
                    Cliente.SendTextNow('&T'+char(Numero[0])+char(Numero[1])+char(JugadorCl.codMapa))
                else
                  MensajeAyuda:=TODOS_LOS_PARAMETROS_ENTRE_0_Y_255
              else
              if ListaParametros.Nro=3 then
                if ControlParametroEntero(ListaParametros.cadena[0],0,255,Numero[0]) and
                   ControlParametroEntero(ListaParametros.cadena[1],0,255,Numero[1]) and
                   ControlParametroEntero(ListaParametros.cadena[2],0,255,Numero[2]) then
                    Cliente.SendTextNow('&T'+char(Numero[0])+char(Numero[1])+char(Numero[2]))
                else
                  MensajeAyuda:=TODOS_LOS_PARAMETROS_ENTRE_0_Y_255
              else
                MensajeAyuda:=INDICA_COORDENADAS_MAPA_X_Y
            end
            else if ComparaCadenas(CadMensaje,'DISOLVER') then
            begin
              if NoEsAdministrador then exit;
              if ListaParametros.Nro=0 then
                if (JugadorCl.apuntado<>nil) and not (JugadorCl.apuntado is TjugadorS)  then
                  Cliente.SendTextNow('&D'+b2astr(JugadorCl.apuntado.codigo))
                else
                  MensajeAyuda:=JugadorCL.MensajeResultado(i_ApuntaAUnMonstruo,0,0)
              else
                MensajeAyuda:=ERROR_NO_NECESITA_PARAMETROS
            end
            else if ComparaCadenas(CadMensaje,'CONTROLAR') then
            begin
              if NoEsAdministrador then exit;
              if ListaParametros.Nro=0 then
                if (JugadorCl.apuntado<>nil) and not (JugadorCl.apuntado is TjugadorS)  then
                  Cliente.SendTextNow('&M'+b2astr(JugadorCl.apuntado.codigo))
                else
                  MensajeAyuda:=JugadorCL.MensajeResultado(i_ApuntaAUnMonstruo,0,0)
              else
                MensajeAyuda:=ERROR_NO_NECESITA_PARAMETROS
            end
            else if ComparaCadenas(CadMensaje,'RESTAURAR') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&R'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Restaurando al avatar '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'ANULARCLAN') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&A'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Anulando el clan del avatar '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'EXPULSAR') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&E'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Expulsando al avatar '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'CARCEL') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&P'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Encarcelando al avatar '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'CONVOCAR') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&C'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Convocando al avatar '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'VISITAR') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&V'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Visitando al avatar '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'HEROE') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&X'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Héroe legendario: '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'BUSCAR') then
            begin
              if NoEsAdministrador then exit;
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&B'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Buscando al avatar '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'ELIMINAR_CADAVERES') then
            begin
              if NoEsAdministrador then exit;
              Cliente.SendTextNow('&L')
            end
            else if ComparaCadenas(CadMensaje,'REMOVER_SILENCIAR') then
            begin
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&H'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Aplicas "Remover silenciar" en: '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            else if ComparaCadenas(CadMensaje,'SILENCIAR') then
            begin
              CadParametros:=ObtenerLoginDeCadena(CadParametros);
              if CadParametros<>'' then
              begin
                Cliente.SendTextNow('&h'+char(length(cadParametros))+cadParametros);
                AgregarMensaje('Aplicas "Silenciar" en: '+cadParametros);
              end
              else
                MensajeAyuda:=INDICA_NOMBRE_AVATAR
            end
            //Fin de comandos administrativos
            //**********************************************************
            else if CadMensaje='SEPPUKU' then
            begin
              if (jugadorCl.hp<>0) then
                Cliente.SendTextNow('&?')
              else
                MensajeAyuda:=JugadorCL.MensajeResultado(i_EstasMuerto,0,0)
            end
            else
              MensajeAyuda:=COMANDO_DESCONOCIDO;
          end;
          '*':
          begin
            if JugadorCl.clan<=maxClanesJugadores then
            begin
              CadMensaje:=TrimLeft(copy(CadMensaje,2,79));
              if length(CadMensaje)<=0 then exit;
              if CadMensaje[1]='&' then
              begin
                CadMensaje:=StrToRunas(CadMensaje);
                if length(CadMensaje)<=0 then exit;
              end;
              HablarAlServidor(CadMensaje,'G')//Al clan (grupo)
            end
            else
              MensajeAyuda:=JugadorCl.MensajeResultado(i_NoPertenecesAUnClan,0,0);
          end;
          '&'://Caracteres élficos
          begin
            CadMensaje:=uppercase(CadMensaje);
            HablarAlServidor(StrToRunas(CadMensaje),'H');
          end;
          '%':
          begin
            CadMensaje:=TrimLeft(copy(CadMensaje,2,79));
            if length(CadMensaje)<=0 then exit;
            if CadMensaje[1]='&' then
            begin
              CadMensaje:=StrToRunas(CadMensaje);
              if length(CadMensaje)<=0 then exit;
            end
            else
              if (CadMensaje[1]='%') and (JugadorCl.comportamiento>comHeroe) then
              begin
                CadMensaje:=TrimLeft(copy(CadMensaje,2,79));
                if length(CadMensaje)<=0 then exit;
                Cliente.SendTextNow('&"'+char(length(CadMensaje))+CadMensaje);
                exit;
              end;
            HablarAlServidor(CadMensaje,'T');
          end
          else // Mensajes de los jugadores
            HablarAlServidor(CadMensaje,'H');
        end;
    end;
end;

procedure TJForm.EditMensajeKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
  begin
    key:=#0;
    HablarAhora(#0);
  end;
end;

procedure TJForm.Accion_Usar;
begin
  if IdGridActivado=idGrInventario then
    if jugadorCl.Artefacto[DGObjetos.indice].id>=4 then
      RealizarAccion(mbRight,DeterminarIconoApropiado(jugadorCl.Artefacto[DGObjetos.indice]),DGObjetos.indice)
end;

procedure TJForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if EstadoGeneralDelJuego>=EjProgreso then
  begin
    PosicionRaton_X:=X;
    PosicionRaton_Y:=Y;
    case VentanaActivada of
      vaMenuConstruccion:MovimientoSobreMenuConstruccion(x,y);
      vaMenuComercio,vaMenuBaul,vaMenuObjetos:MovimientoSobreMenuObjetos(x,y,VentanaActivada);
      else MensajeTip:='';
    end;
  end
end;

procedure TJForm.PantallaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var TipoErrorAlApuntar:byte;
  procedure Apuntar(pos_a_x,pos_a_y:integer);
  var codigoCasilla:word;
      codSensor:byte;
  begin
    codigoCasilla:=MapaEspejo.ApuntarCasilla(pos_a_x,pos_a_y,false);
    if (Button<>mbMiddle) then
    begin
      JugadorCl.apuntado:=GetMonstruoCodigoCasilla(codigoCasilla);
      if JugadorCl.apuntado<>nil then
      begin
        if not JugadorCl.apuntado.activo then JugadorCl.apuntado:=nil;//antes que la siguiente linea
        if JugadorCl.apuntado=JugadorCl then JugadorCl.apuntado:=nil;
      end;
    end
    else
      JugadorCl.apuntado:=nil;
    if JugadorCl.apuntado=nil then
    begin
      case TtipoBolsa(MapaEspejo.getCodBolsaVerificarFronterasXY(pos_a_x,pos_a_y)) of
        tbComun:MensajeTipTimer:='Bolsa';
        tbTrampaMagica:MensajeTipTimer:='Trampa mágica';
        tbCadaver..tbCadaverQuemado:MensajeTipTimer:='Cadaver';
        tbcenizas:MensajeTipTimer:='Cenizas';
        tblenna,tbFogata:MensajeTipTimer:='Fogata';
        tbCadaverArdiente:MensajeTipTimer:='Cadaver ardiendo';
      end;
      if ((Button=mbright) xor G_MoverConClickIzquierdo) then exit;
      codSensor:=MapaEspejo.getCodigoSensorXY(pos_a_x,pos_a_y);
      if codSensor<>Ninguno then
        if (JugadorCl.hp<>0) or (JugadorCl.comportamiento>comHeroe) then
          if (JugadorCl.banderas and bnParalisis=0) then
          begin
            if JugadorCl.PuedeRecibirComando(4) then
            begin
              MensajeTipTimer:=MapaEspejo.DescribirSensor(codSensor);
              Cliente.SendTextNow('s'+char(pos_a_x)+char(pos_a_y));
            end;
          end
          else
            MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
        else
          MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
    end;
  end;
begin
  if EstadoGeneralDelJuego<ejProgreso then exit;
  if (Y>=336) and ((x<=156) or (x>=514)) then
    PBInterfazMouseDown(Sender,Button,Shift,X,Y-Alto_dd)//Panel de control
  else
    case VentanaActivada of
      vaMenuOpciones:EjecutarComandosMenuOpciones(x,y);
      vaMenuConstruccion:EjecutarComandosMenuConstruccion(x,y);
      vaMenuConfirmacion:EjecutarComandosMenuConfirmacion(x,y);
      vaMenuComercio,vaMenuBaul,vaMenuObjetos:EjecutarComandosMenuObjetos(x,y,VentanaActivada);
    else
      with jugadorCl do
      begin
        if (Button=mbright) xor G_MoverConClickIzquierdo then
        begin
          if Zoom_Pantalla then
            MapaEspejo.JMoverXY((x-2+DDraw_mitad_Sprite_X) div 2,(y-4+DDraw_mitad_Sprite_Y) div 2)
          else
            MapaEspejo.JMoverXY(x,y+1);
          if Apuntado<>nil then exit;//no apuntar si existe algo apuntado.
        end;
        //modificando Y:
        if Zoom_Pantalla then
          apuntar(((X-12) div (ancho_tile*2))-6+coordx,((Y-8) div (alto_tile*2))-5+coordy)
        else
          apuntar((X div ancho_tile)-13+coordx,(Y div alto_tile)-11+coordy);
        TipoErrorAlApuntar:=byte(MonstruoApuntadoIncorrecto);
        if TipoErrorAlApuntar<>i_Ok then
        begin
          if TipoErrorAlApuntar=i_EstasMuyLejos then
            MensajeAyuda:=MensajeResultado(i_EstasMuyLejos,0,0)
        end
        else
          if apuntado is Tjugador then
          begin
            MensajeAyuda:=Tjugador(apuntado).describir;
            MensajeAyuda:=Tjugador(apuntado).ListarEstadoYBanderas;
          end
          else
            MensajeTipTimer:=MapaEspejo.NombreMonstruo(apuntado,true);
        if SpriteAnteriorApuntado<>apuntado then
          SpriteAnteriorApuntado:=apuntado
        else
          if apuntado<>nil then
          begin//Acción de acuerdo al contexto
            if not (apuntado is TjugadorS) then
              if apuntado.comportamiento=comComerciante then
                MapaEspejo.JMostrarMenuComercio(apuntado);
          end;
      end//with
    end//case
end;

function CalcularCoordXMinimapa(x:integer):integer;
begin
  if (MapaEspejo.BanderasMapa and mskSonidosMapas)<>bmSonidosInterior then
    result:=x shr 1-5
  else
    result:=(x and $7F)-5;
end;

function CalcularCoordYMinimapa(y:integer):integer;
begin
  if (MapaEspejo.BanderasMapa and mskSonidosMapas)<>bmSonidosInterior then
    result:=y shr 1+11//-5+16
  else
    result:=(y and $7F)+11;//-5+16
end;

procedure TJForm.ActualizarMiniMapa(ForzarActualizacionYDibujarTodoElMapa:boolean);
const LimitesMiniMapa:Trect=(left:0;top:16;right:128;bottom:144);
var org,dst:Trect;
begin
  if (IdPanelActivado<>idPnMapa) then exit;
  if ForzarActualizacionYDibujarTodoElMapa then
  begin
    org.Left:=0;
    org.top:=0;
    org.right:=128;
    org.bottom:=128;
    pnInfo.BltFast(0,16,Pergamino_Mapa,@org,DDBLTFAST_NOCOLORKEY);
  end;
  with MarcaMapaAnterior do
  if ForzarActualizacionYDibujarTodoElMapa or (dst.left<>x) or (dst.top<>y) then
  begin
    //borrar la marca anterior
    dst.left:=x;
    dst.top:=y;
    dst.right:=dst.Left+11;
    dst.bottom:=dst.top+11;
    org.Left:=x;
    org.top:=y-16;
    org.right:=org.Left+11;
    org.bottom:=org.top+11;
    if EstaEnInterior(dst,org,LimitesMiniMapa) then
      pnInfo.BltFast(dst.left,dst.top,Pergamino_Mapa,@org,DDBLTFAST_NOCOLORKEY);
    //pintar la nueva marca
    dst.left:=CalcularCoordXMinimapa(jugadorCl.coordx);
    dst.top:=CalcularCoordYMinimapa(jugadorCl.coordy);
    dst.Right:=dst.left+11;
    dst.bottom:=dst.top+11;
    org.Left:=0;
    org.top:=0;
    org.Right:=org.left+11;
    org.bottom:=org.top+11;
    if EstaEnInterior(dst,org,LimitesMiniMapa) then
      CopyTransMagenta(PnInfo,dst.left,dst.top,dst.Right-dst.left,dst.bottom-dst.top,MiraMapa,org.left,org.top);
    x:=dst.left;
    y:=dst.top;
    if MiniMapa_DibujarSennal>0 then
    begin
      dst.left:=CalcularCoordXMinimapa(MiniMapa_X);
      dst.top:=CalcularCoordYMinimapa(MiniMapa_Y);
      dst.Right:=dst.left+11;
      dst.bottom:=dst.top+11;
      org.Left:=11;
      org.top:=0;
      if EstaEnInterior(dst,org,LimitesMiniMapa) then
        CopyTransMagenta(PnInfo,dst.left,dst.top,dst.Right-dst.left,dst.bottom-dst.top,MiraMapa,org.left,org.top);
    end;
    RepintarPanelInfo:=true;
  end;
end;

procedure TJForm.Salir1Click(Sender: TObject);
begin
  close;
end;

procedure TJForm.SetMensaje(const mensaje:TCaption);
begin
  if mensaje<>'' then
    if LbTexto[0].Caption<>mensaje then
      AgregarMensaje(mensaje)
    else
    begin
      if LbTexto[0].Font.Color=clWhite then
        LbTexto[0].Font.Color:=clFondo
      else
        LbTexto[0].Font.Color:=clWhite;
      SonidoIntensidad(snError,-800);
    end;
end;

procedure TJForm.SetMensajeTip(const mensaje:TCaption);
begin
  if (LbMensaje.caption<>mensaje) and ((mensaje<>'') or (LbMensaje.tag=0)) then
  begin
    LbMensaje.tag:=0;
    LbMensaje.font.Color:=clAmarilloPalido;
    LbMensaje.caption:=mensaje;
  end;
end;

procedure TJForm.SetMensajeTipTimer(const mensaje:TCaption);
begin
  if (LbMensaje.caption<>mensaje) then
  begin
    if length(mensaje)>0 then
    begin
      LbMensaje.font.Color:=clWhite;
      LbMensaje.tag:=length(mensaje)+15;
    end
    else
      LbMensaje.tag:=0;
    LbMensaje.caption:=mensaje;
  end
  else//si son iguales, prolongar el tiempo
    LbMensaje.tag:=length(mensaje)+15;
end;

procedure TJForm.TimerTimer(Sender: TObject);
  procedure DibujarBarrasVidaMana;
  var pos_barra:integer;
  begin
    with JugadorCl do pos_barra:=96-(96*hp div maxhp);
    if (JugadorCl.hp=0) then
      BltTrans(rect(0,0,116,32),BarraVidaMana,rect(0,0,116,32),false)
    else
      if (JugadorCl.FlagsComunicacion and flmodoPKiller)=0 then
        BltMejorado(rect(0,0,116,32),BarraVidaMana,rect(0,0,116,32),false)
      else
        BltFxColor(rect(0,0,116,32),BarraVidaMana,rect(0,0,116,32),false,clRed);
    BltFxMascara(rect(16,0,112-pos_barra,24),BarraVidaMana,rect(20,32,116-pos_barra,56),false,$FF);
    if (JugadorCl.maxMana>0) and (VentanaActivada<>vaMenuConstruccion)
      and (VentanaActivada<>vaMenuComercio)and (VentanaActivada<>vaMenuOpciones)
      and (VentanaActivada<>vaMenuBaul) and (VentanaActivada<>vaMenuObjetos) then
    begin
      with JugadorCl do pos_barra:=96-(96*mana div maxmana);
      if (JugadorCl.hp=0) then
      begin
        BltTrans(rect(524,0,640,32),BarraVidaMana,rect(0,0,116,32),true);
      end
      else
      begin
        BltMejorado(rect(524,0,640,32),BarraVidaMana,rect(0,0,116,32),true);
      end;
      BltFxMascara(rect(528+pos_barra,0,624,24),BarraVidaMana,rect(20+pos_barra,32,116,56),false,$FF0000);
    end;
  end;
  procedure asegurarPosicion;
  begin
    if left>screen.Width-width then left:=screen.Width-width;
    if left<0 then left:=0;
    if top>screen.Height-height then top:=screen.Height-height;
    if top<0 then top:=0;
  end;
  procedure DibujarFrame;
  var origen:Trect;
    resultado:integer;
  begin
      mapaespejo.draw;
      if not active then exit;//salir si ya no esta activo
      if Zoom_Pantalla then RealizarZoom;
      if RepintarPanelGrids then
      begin
        CopiarSuperficieACanvas(CanvasInterfaz.handle,516,0,124,128,PnGrids,12,12);
        RepintarPanelGrids:=false;
      end;
      ActualizarMiniMapa(false);
      if LbPanelInfo.NecesitaDibujarse then
        RepintarPanelInfo:=RepintarPanelInfo or
          LbPanelInfo.actualizarLabeles(IdPanelActivado);
      if RepintarPanelInfo then
      begin
        CopiarSuperficieACanvas(CanvasInterfaz.handle,0,0,156,128,PnInfo,0,16);
        RepintarPanelInfo:=false;
      end;
      if Visores_Vida_Mana then
        DibujarBarrasVidaMana;
      ControlChat.draw;
      case VentanaActivada of
        vaMenuOpciones:PintarMenuOpciones;
        vaMenuConstruccion:PintarMenuConstruccion;
        vaMenuConfirmacion:PintarMenuConfirmacion;
        vaMenuComercio:PintarMenuComercio;
        vaMenuBaul,vaMenuObjetos:PintarMenuObjetos(VentanaActivada);
        vaInformacion:PintarMenuInformacion;
      end;
      origen:=rect(4,0,136,12);
      SuperficieRender.BltFast(508,340,PnGrids,@origen,DDBLTFAST_SRCCOLORKEY);
      origen:=rect(0,0,161,16);
      SuperficieRender.BltFast(0,336,PnInfo,@origen,DDBLTFAST_SRCCOLORKEY);
    {$IFDEF FPS}
      if G_MostrarFPS then
        if not MusicaActivada then
        with TextoDDraw do
        begin
          resultado:=abs(Timer.LastIntervalMs-Timer.Interval);
          if resultado>0 then
            if resultado>5 then
              color:=clRed
            else
              color:=clYellow
          else
            color:=clEsmeralda;
          alineacionX:=axIzquierda;
          TextOut(160,338,'FPS:'+floatToStrF(1000/Timer.LastIntervalMs, ffFixed	, 7, 2)+' · '+intastr(Timer.Lagcount));
        end;
    {$ENDIF}
      if G_PantallaEn15Bits then
        CambiarSuperficieRenderA15Bits;
      if not active then exit;

      if screen.width<=640 then
        resultado:=flip(PuntoOrigen)
      else
      begin
        asegurarPosicion;
        resultado:=flip(getClientOrigin);
      end;

      if resultado<>dd_ok then
        if resultado=DDERR_UNSUPPORTED then
          MaximizarMinimizarPantalla(true);
  end;
begin
  if EstadoGeneralDelJuego>=ejProgreso then
  begin
    if active then
      DibujarFrame;
    MapaEspejo.SincronizarYfinTurno;
  end;
end;

procedure TJForm.PresionarBotonInfo(id:integer);
begin
  if id<>IdPanelActivado then
  begin
    PintarBotonInfo(FALSE);
    //seguridad (interfaz)
    if id<0 then id:=0;
    if id>3 then id:=3;
    IdPanelActivado:=id;
    PintarBotonInfo(TRUE);
    PrepararPanelInfo;
  end;
end;

procedure TJForm.PresionarBotonGrid(id:integer);
begin
  if id<>IdGridActivado then
  begin
    PintarBotonGrid(FALSE);
    //seguridad (interfaz)
    if id<0 then id:=0;
    if id>1 then id:=1;
    IdGridActivado:=id;
    PintarBotonGrid(TRUE);
    case id of
      idGrInventario: with DGObjetos do begin
        B_Abajo.visible:=PrimeraFil<3;
        b_Arriba.visible:=PrimeraFil>0;
      end;
      else with DGCOnjuros do begin
        B_Abajo.visible:=PrimeraFil<7;
        b_Arriba.visible:=PrimeraFil>0;
      end;
    end;
    PrepararPanelGrids;
  end;
end;

procedure TJForm.PintarBotonInfo(Brillando:bytebool);
var origen:Tpoint;
begin
  if Brillando then
    origen:=Point(0,28)
  else
    origen:=Point(159,88);
  BitBlt(CanvasInterfaz.handle,159,72+14*IdPanelActivado,48,14,Fondo.canvas.handle,ORIGEN.X,ORIGEN.Y+14*IdPanelActivado,SRCCOPY)
end;

procedure TJForm.PintarBotonGrid(Brillando:bytebool);
var origen:Tpoint;
begin
  if Brillando then
    origen:=Point(0,16)
  else
    origen:=Point(520,7);
  CopiarCanvasASuperficie(PnGrids,16+59*IdGridActivado,3,59,12,Fondo.canvas.handle,ORIGEN.X+59*IdGridActivado,ORIGEN.Y);
end;

procedure TJForm.PBInterfazMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var i,IdLimiteARevisar,Id_Icono_mostrado:byte;
    cadena:string;
begin
 if EstadoGeneralDelJuego>=ejProgreso then
 begin
  PosicionRaton_X:=X;
  PosicionRaton_Y:=Y+alto_dd;
  if (x>=516) and (y>=4) then
  begin// Panel derecho
    x:=(x-516) div 42;
    y:=(y-4) div 42;
    if y>2 then exit;
    if x>2 then exit;
    case IdGridActivado of
      idGrInventario:
      with DGObjetos do
      begin
        inc(y,PrimeraFil);
        Id_Icono_mostrado:=y*3+x;
        MensajeTip:=nombreObjeto(
          jugadorCl.artefacto[Id_Icono_mostrado],jugadorCl.CapacidadId);
      end;
      IdGrConjuros:
      with DGConjuros do
      begin
        inc(y,PrimeraFil);
        Id_Icono_mostrado:=y*3+x;
        MensajeTip:=JugadorCl.DescribirConjuro(Id_Icono_mostrado);
      end;
    end;
    exit;
  end
  else
  begin
    inc(y,16);
    if IdPanelActivado=idPnEquipo then IdLimiteARevisar:=7 else IdLimiteARevisar:=1;
    for i:=0 to IdLimiteARevisar do
      if PuntoDentroRect(x,y,CrdndDstnObjts[i]) then
      begin
        cadena:=nombreObjeto(jugadorCl.usando[i],jugadorCl.CapacidadId);
        if cadena='' then cadena:=NmbrsPscnsObjts[i];
        MensajeTip:=cadena;
        exit;
      end;
    if PuntoDentroRect(x,y,CrdndDstnObjts[uConjuro]) then
    begin
      MensajeTip:=JugadorCl.DescribirConjuro(JugadorCl.ConjuroElegido);
      exit;
    end;
    if (IdPanelActivado=IdPnEquipo) and PuntoDentroRect(x,y,rect(42,118,94,143)) then
    begin
      MensajeTip:=JugadorCl.DineroACadena;
      exit;
    end;
    if (IdPanelActivado=IdPnPericias) then
      with JugadorCl do
      begin
        if PuntoDentroRect(x,y,rect(0,110,150,124)) then
        begin
          MensajeTip:='Punzante:'+ArmaduraPorcentual(armadura[integer(taPunzante)])+
            ' Cortante:'+ArmaduraPorcentual(armadura[integer(taCortante)])+
            ' Contundente:'+ArmaduraPorcentual(armadura[integer(taContundente)]);
          exit;
        end;
        if PuntoDentroRect(x,y,rect(0,125,150,139)) then
        begin
          MensajeTip:='Hielo:'+ArmaduraPorcentual(armadura[integer(taHielo)])+
            ' Fuego:'+ArmaduraPorcentual(armadura[integer(taFuego)])+
            ' Rayo:'+ArmaduraPorcentual(armadura[integer(taRayo)])+
            ' Veneno:'+ArmaduraPorcentual(armadura[integer(taVeneno)]);
          exit;
        end;
      end;
    if (IdPanelActivado=IdPnPuntajes) then
    begin
      if PuntoDentroRect(x,y,rect(4,110,150,126)) then
      begin
        MensajeTip:='Experiencia necesaria para subir de nivel';
        exit;
      end;
      if (JugadorCl.nivel>MAX_NIVEL_CON_BONO) and
       PuntoDentroRect(x,y,rect(132,32,148,107)) then
      begin
        MensajeTip:='Indica la habilidad que deseas reducir';
        exit;
      end;
      if PuntoDentroRect(x,y,rect(114,32,130,107)) then
      begin
        MensajeTip:='Indica la habilidad que deseas mejorar';
        exit;
      end;
    end;
    if PuntoDentroRect(x,y,rect(258,104,302,144)) then
    begin
      if Visores_Vida_Mana then
        MensajeTip:='Ocultar barras de vida y mana'
      else
        MensajeTip:='Ver barras de vida y mana';
      exit;
    end;
  end;
  //Si no existe mensaje, colocar área de mensajes en blanco.
  mensajeTip:='';
//      mensajeTip:=intastr(x)+','+intastr(y);
 end;
end;

procedure TJForm.PBInterfazMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var icono:TIconoSeleccionado;
    Habilidad,AnteriorEstado:byte;
    MejorandoHabilidad:boolean;
  function ObtenerHabilidadPorPosicion(posicion_y:integer):byte;
  begin
    case posicion_y of
      32..46:result:=hbFuerza;
      47..61:result:=hbConstitucion;
      62..76:result:=hbInteligencia;
      77..91:result:=hbSabiduria;
      else result:=hbDestreza;
    end;
  end;
begin
  inc(y,16);
//Grids
  if (x>=516) and (y>=20) then
  begin
    dec(x,516);
    dec(y,20);
    case IdGridActivado of
      idGrConjuros:
      begin
        RepintarPanelGrids:=RepintarPanelGrids or DGConjuros.ClikearCelda(button,x,y);
        if RepintarPanelGrids then ActualizarIconoMagiaEspecialidad;
      end;
      idGrInventario:
        DGObjetos.ClikearCelda(button,x,y);
    end;
  end
  else
//Iconos de armas
  if (y>=104) and (x>=216) and (x<=497) then
  begin
    case x of
      216..255:begin
        AgregarMensaje(jugadorCl.describir);
        AgregarMensaje(jugadorCl.ListarEstadoYBanderas);
      end;
      258..302:Visores_Vida_Mana:=not Visores_Vida_Mana;
      370..409:RealizarAccion(Button,uArmaIzq,DGObjetos.indice);
      410..449:RealizarAccion(Button,uArmaDer,DGObjetos.indice);
      464..490://Por seguridad =(
        if (y>=110) then
          if JugadorCl.maxmana>0 then
            MapaEspejo.JLanzarConjuro(Button=MbLeft,false)
          else
            MensajeAyuda:=JugadorCL.DescribirEspecialidad+' ('+NomObj[JugadorCL.EspecialidadArma]+')';
    end;
  end
  else
//Paneles de info.
  if (x<152) then
    case IdPanelActivado of
      idPnEquipo:begin
        icono:=uNoDefinido;
        case x of
          0..39:
            case y of
              18..57:icono:=uMunicion;
              60..99:icono:=uAmuleto;
              102..141:icono:=uBrazaletes;
            end;
          112..151:
            case y of
              18..57:icono:=uCasco;
              60..99:icono:=uArmadura;
              102..141:icono:=uAnillo;
            end;
        end;
        if icono<>uNoDefinido then
          RealizarAccion(Button,icono,DGObjetos.indice);
      end;
      idPnPuntajes:
       if (y>=32) and (y<=106) and (x>=12) and (x<148) then
       begin
         MejorandoHabilidad:=x<128;
         if MejorandoHabilidad then
           Habilidad:=ObtenerHabilidadPorPosicion(Y)
         else
           if (jugadorCl.nivel>MAX_NIVEL_CON_BONO) then
             Habilidad:=ObtenerHabilidadPorPosicion(Y)
           else
             exit;
         AnteriorEstado:=JugadorCl.HabilidadResaltada;
         if jugadorCl.ElegirHabilidadParaCambiar(Habilidad,MejorandoHabilidad) then
         begin
           if AnteriorEstado<>JugadorCl.HabilidadResaltada then
           begin
             Cliente.SendTextNow('Xs'+char(JugadorCl.HabilidadResaltada));
             PintarMarcasDeHabilidades(true);
           end
         end
         else
           if MejorandoHabilidad then
             MensajeAyuda:='No puedes tener más de 100%, elige otra habilidad'
           else
             MensajeAyuda:='No puedes tener menos de 5%, elige otra habilidad'
       end;
      idPnMapa:
        if (x<128) and (y>=16) then
          if (Button=mbright) xor G_MoverConClickIzquierdo then
            MapaEspejo.JMoverXY_Minimapa(x,y-16)
          else
            MensajeAyuda:=MapaEspejo.DescribirPosicion(x,y-16);
    end
  else
//Etiquetas de paneles de informacion:
  if (x>=153) and (x<=212) and (y>=88) then
    PresionarBotonInfo((y-88) div 14)
  else
//Etiquetas de grids
  if (x>=520) and (x<=637) and (y>=4) and (y<=19)  then
    if x<582 then
      PresionarBotonGrid(IdGrInventario)
    else
      if JugadorCl.maxMana>0 then
        PresionarBotonGrid(IdGrConjuros)
      else
        MensajeAyuda:='Los guerreros y los bribones no lanzan conjuros';
end;

procedure TJForm.DGObjetosAlDibujarCelda(Col,Fil: Integer; ARect: TRect;Seleccionado:bytebool);
var HDCSuperficie:HDC;
begin
  if Arect.bottom<=0 then exit;//fuera de límites
  if pnGrids.GetDC(HDCSuperficie)=DD_OK then
  begin
    PintarObjeto(jugadorCl.artefacto[fil*3+col],true,Arect.left,Arect.top,HDCSuperficie,Seleccionado,false);
    pnGrids.ReleaseDC(HDCSuperficie);
  end;
end;

procedure TJForm.DGConjurosAlDibujarCelda(Col,Fil: Integer; ARect: TRect;Seleccionado:bytebool);
var HDCSuperficie:HDC;
begin
  if Arect.bottom<=0 then exit;//fuera de límites
  if PnGrids.GetDC(HDCSuperficie)=DD_OK then
  begin
    PintarConjuro(col+fil*3,Arect.left,Arect.top,HDCSuperficie,seleccionado);
    PnGrids.ReleaseDC(HDCSuperficie);
  end;
end;

procedure TJForm.DGConjurosMouseDown(Button: TMouseButton;Acol,Afil:shortint);
var actual,anterior:byte;
begin
  Afil:=Afil+DGConjuros.PrimeraFil;
  anterior:=Afil*3+Acol;
  actual:=DGConjuros.indice;
  if actual=anterior then
    MapaEspejo.JLanzarConjuro(Button=MbLeft,false);
end;

procedure TJForm.DGObjetosMouseDown(Button: TMouseButton;Acol,Afil:shortint);
var actual,anterior:byte;
begin
  Afil:=Afil+DGObjetos.PrimeraFil;
  anterior:=Afil*3+Acol;
  actual:=DGObjetos.indice;
  if Button=mbLeft then
  begin
    if anterior<>actual then
      RepintarPanelGrids:=true
    else//acción especial dependiendo del contexto
    begin
      if VentanaActivada=vamenuComercio then
      begin//vender el objeto
        MapaEspejo.JVender(DGObjetos.indice,0,JugadorCl.apuntado)
      end
      else
        with JugadorCl do
          if EsIdDeArmaOArmadura(artefacto[DGObjetos.indice].id) then
          begin
            AgregarMensaje('·Descripción de: '+nombreObjeto(artefacto[DGObjetos.indice],CapacidadId));
            AgregarMensaje('+  '+DescribirObjeto(artefacto[DGObjetos.indice],CapacidadId));
          end;
    end
  end
  else
    if anterior<>actual then
    begin
      if jugadorCl.intercambiarObjetos(anterior+8,actual+8)=i_Ok then
      begin
        JIntercambiarObjetos(anterior+8,actual+8);
//        MensajeTip:='';//???
      end
      else//Sólo refrescar borde del icono
        RepintarPanelGrids:=true;
    end
    else
      Accion_Usar;
end;

procedure TJForm.PrepararPanelGrids;
begin
//Llenar Paneles de informacion
  Case IdGridActivado of
    IdGrInventario:DGObjetos.PintarCeldas;
    IdGrConjuros:DGConjuros.PintarCeldas;
  end;
  RepintarPanelGrids:=true;
end;

procedure TJForm.PintarMarcasDeHabilidades(borrar:bytebool);
begin
  if IdPanelActivado=IdPnPuntajes then
  begin
    if borrar then
      CopiarCanvasASuperficie(PnInfo,116,32,32,75,FondoTexto.canvas.handle,116,18);
    copyTransMagenta(pnInfo,116,jugadorCl.HabilidadResaltada and $7*15+32,16,16,PuntoResalte,0,0);
    if (jugadorCl.nivel>MAX_NIVEL_CON_BONO) then
      copyTransMagenta(pnInfo,132,(jugadorCl.HabilidadResaltada shr 3)*15+32,16,16,PuntoResalte,16,0);
    RepintarPanelInfo:=true;
  end;
end;

procedure TJForm.PrepararPanelInfo;
var i:integer;
    HDCSuperficie:HDC;
    limites:Trect;
begin
//Llenar Paneles de informacion
  Case IdPanelActivado of
    IdPnPuntajes,idPnPericias:
      begin
        if pnInfo.GetDC(HDCSuperficie)=DD_OK then
        begin
          BitBlt(HDCSuperficie,0,14,156,130,FondoTexto.canvas.handle,0,0,SRCCOPY);
          pnInfo.ReleaseDC(HDCSuperficie);
        end;
        with TextoDDraw do
        begin
          SuperficieDestino:=pnInfo;
          AlineacionX:=axIzquierda;
          limites:=rect(0,0,Ancho_Panel_Info,Alto_Panel_Info);
          LimitesTexto:=@limites;
          color:=clFondo;
          //Labeles estaticos:
          if IdPanelActivado=IdPnPuntajes then
          begin
            LbTitulo.caption:='Puntajes y habilidades';
            TextOut(10,33,NmbrsHabilidades[0]);
            TextOut(10,48,NmbrsHabilidades[1]);
            TextOut(10,63,NmbrsHabilidades[2]);
            TextOut(10,78,NmbrsHabilidades[3]);
            TextOut(10,93,NmbrsHabilidades[4]);
            TextOut(4,111,'Exp. necesaria:');
            TextOut(4,126,'Honor:');
            PintarMarcasDeHabilidades(false);
          end
          else
          begin
            LbTitulo.caption:='Pericias';
            for i:=0 to 2 do
              TextOut(24,18+i*15,#156+#32+NombrePericiaJugador[i]);
            TextOut(4,66,'Daño Arma:');
            TextOut(4,81,'Ataque:');
            TextOut(4,96,'Defensa:');
            TextOut(4,111,'Armadura:');
          end;
          SuperficieDestino:=SuperficieRender;
          LimitesTexto:=@Rectangulo_Origen;
        end;
      end;
    IdPnEquipo:begin
      LbTitulo.caption:='Equipo y dinero';
      if pnInfo.GetDC(HDCSuperficie)=DD_OK then
      begin
        BitBlt(HDCSuperficie,0,14,156,130,Objjug.canvas.handle,0,0,SRCCOPY);
        for i:=2 to 7 do
          with CrdndDstnObjts[i] do
            PintarObjeto(jugadorCl.usando[i],true,left,top,HDCSuperficie,false,true);
        pnInfo.ReleaseDC(HDCSuperficie);
      end;
      LbPanelInfo.InvalidarPanel(IdPnEquipo);
    end;
    IdPnMapa:begin
      LbTitulo.caption:=MapaEspejo.nombreMapa{+'     '};
      with MarcaMapaAnterior do begin
        x:=CalcularCoordXMinimapa(jugadorCl.coordx);
        y:=CalcularCoordYMinimapa(jugadorCl.coordy);
      end;
      //borde
      CopiarCanvasASuperficie(pnInfo,0,14,156,2,Fondo.canvas.handle,0,14);
      CopiarCanvasASuperficie(pnInfo,128,14,28,130,Fondo.canvas.handle,128,14);
      //mapa
      ActualizarMiniMapa(true);
    end;
  end;
  LbPanelInfo.ActualizarLabeles(IdPanelActivado);
  LbPanelInfo.invalidar;//Para actualizar el otro label
  LbPanelInfo.ActualizarLabeles(IdPnPrincipal);
  RepintarPanelInfo:=true;
end;

procedure TJForm.RealizarAccion(Button:TMouseButton;icono:TIconoSeleccionado;NroObjetoBaul:byte);
var cadena:string;
    resultado,posicionLibre:byte;
    reparar:boolean;
begin
  if Button=mbLeft then
  begin
    if (icono<=7) then
      with JugadorCl do
        if EsIdDeArmaOArmadura(usando[icono].id) then
        begin
          AgregarMensaje('·Descripción de: '+nombreObjeto(usando[icono],CapacidadId));
          AgregarMensaje('+  '+DescribirObjeto(usando[icono],CapacidadId));
        end;
  end
  else
  begin
    if NroObjetoBaul>MAX_ARTEFACTOS then exit;
    if icono=uNoDefinido then exit;
    if icono=uConsumible then//consumir
    begin
      resultado:=JugadorCl.PuedeConsumir(NroObjetoBaul);
      if resultado=i_OK then
      begin
        if JugadorCl.PuedeRecibirComando(4) then
          Cliente.SendTextNow('c'+char(NroObjetoBaul))
      end
      else
        MensajeAyuda:=JugadorCl.MensajeResultado(resultado,NroObjetoBaul,uConsumible);
    end
    else
    if icono=uHerramienta then//Usar herramienta
    begin
      resultado:=MapaEspejo.PuedeUsarHerramienta(jugadorCl,NroObjetoBaul,reparar);
      if resultado=i_OK then
        if JugadorCl.PuedeRecibirComando(8) then
        begin
          cadena:='';
          //Caso especial: escribir magia, tiene que actualizar el conjuro elegido
          if JugadorCL.Artefacto[NroObjetoBaul].id=ihplumaMagica then
            if JugadorCl.ConjuroElegido<>IDConjuroElegidoEnElServidor then
            begin
              cadena:=cadena+'j'+char(JugadorCl.ConjuroElegido);
              IDConjuroElegidoEnElServidor:=JugadorCl.ConjuroElegido;
            end;
          cadena:=cadena+'u'+char(NroObjetoBaul);
          Cliente.SendTextNow(cadena);
          JugadorCl.SonidoArtefacto(NroObjetoBaul);
        end;
      MensajeAyuda:=JugadorCl.MensajeResultado(resultado,NroObjetoBaul,uHerramienta);
    end
    else
    if icono=uConstructor then//Usar herramienta previo menu de construccion.
    begin
      resultado:=MapaEspejo.PuedeUsarHerramienta(jugadorCl,NroObjetoBaul,reparar);
      if resultado=i_OK then
      begin
        //verificar si se tiene que reparar.
        if reparar then
        begin
          if JugadorCl.PuedeRecibirComando(8) then
          begin
            JugadorCl.SonidoArtefacto(NroObjetoBaul);
            Cliente.SendTextNow('u'+char(NroObjetoBaul));
          end;
        end
        else
          if PrepararMenuConstruccion(JugadorCl,JugadorCl.artefacto[NroObjetoBaul].id) then
            VentanaActivada:=vaMenuConstruccion
          else
            resultado:=i_AunNoPuedesConstruirNada
      end;
      MensajeAyuda:=JugadorCl.MensajeResultado(resultado,NroObjetoBaul,uHerramienta);
    end
    else
    begin
      resultado:=JugadorCl.IntercambiarObjetos(NroObjetoBaul+8,icono);
      //Permite equipar un arma de dos manos, desequipando dos armas:
      if resultado=i_NecesitasAmbasManos then//necesita ambas manos libres
        //Buscar una casilla libre:
        for posicionLibre:=0 to MAX_ARTEFACTOS do
          if JugadorCl.Artefacto[posicionLibre].id<4 then
          begin
          //desequipar la mano izq.
            if JugadorCl.IntercambiarObjetos(posicionLibre+8,uArmaIzq)=i_Ok then
            begin
              JIntercambiarObjetos(posicionLibre+8,uArmaIzq);
              resultado:=JugadorCl.IntercambiarObjetos(NroObjetoBaul+8,icono);
            end;
            break;
          end;
      if resultado=i_Ok then
      begin
        JIntercambiarObjetos(NroObjetoBaul+8,icono);
        //Pintar adecuadamente la mano izquierda:
        if (icono=uArmaDer) and (InfObj[JugadorCl.Usando[icono].id].pesoArma=paPesada)
          or (InfObj[JugadorCl.Artefacto[NroObjetoBaul].id].pesoArma=paPesada) then
          PintarObjetoPosicion(uArmaIzq,false);
        if (icono=uArmaIzq) and (InfObj[JugadorCl.Artefacto[NroObjetoBaul].id].pesoArma=paPesada) then
          PintarObjetoPosicion(uArmaDer,false);
        MostrarDatosFrecuentesJugador;
      end;
      MensajeAyuda:=JugadorCl.MensajeResultado(resultado,NroObjetoBaul,icono);
    end;
  end;
end;

procedure TJForm.ActualizarIconoMagiaEspecialidad;
begin//actualiza el ícono de magia y lo pinta, especialidad si no lanza conjuros
with CrdndDstnObjts[8] do
  if jugadorCl.maxmana>0 then
  begin//1.Actualizarlo 2.Pintarlo
    with DGConjuros do JugadorCl.ConjuroElegido:=(col+fil*3) and $1F;
    if JugadorCl.Conjuros and (1 shl JugadorCl.ConjuroElegido)=0 then JugadorCl.ConjuroElegido:=JugadorCl.ConjuroElegido;
    PintarConjuro(JugadorCl.ConjuroElegido,left,top-16,CanvasInterfaz.handle,false)
  end
  else
  begin
    with JugadorCl do
      Imagen40.copiarImagen((EspecialidadArma and $7)*40,(EspecialidadArma shr 3)*40,Iconos_Objetos,bfxBrilloGris);
    bitblt(CanvasInterfaz.handle,left,top-16,40,40,Imagen40.canvas.handle,0,0,SRCCOPY);
  end;
end;

procedure TJForm.PintarRostroJugador;
begin
  JugadorCl.PrepararImagenJugador;
  BitBlt(CanvasInterfaz.handle,216,88,40,40,Imagen40.canvas.handle,0,0,SRCCOPY);
end;

procedure TJForm.PBInterfazPaint(Sender: TObject);
begin
if EstadoGeneralDelJuego>=ejprogreso then
  with CanvasInterfaz,ClipRect do
  begin
    if (right>=155) and (left<=516) and (bottom>=70) then//Parte central
    begin
      BitBlt(handle,156,0,360,128,fondo.canvas.handle,156,16,SRCCOPY);
      PintarBotonInfo(true);//4 Botones a la derecha del rostro.
      if (right>=214) and (left<=500) then//Iconos inferiores:
      begin
        PintarRostroJugador;
        PintarObjetoPosicion(uArmaIzq,false);
        PintarObjetoPosicion(uArmaDer,false);
        ActualizarIconoMagiaEspecialidad;
      end;
    end
    else //sólo para mensajes
    begin
      if right<156 then right:=156;
      if left>516 then left:=516;
      BitBlt(handle,Left,top,right-Left,bottom-top,fondo.canvas.handle,left,top+16,SRCCOPY);
    end;
    if (right>=516) then RepintarPanelGrids:=true;//Parte derecha
    if (Left<=156) then RepintarPanelInfo:=true;//Parte izquierda
    if not Active then
    begin
//      CopiarSuperficieACanvas(handle,516,0,124,128,PnGrids,12,12);
//      CopiarSuperficieACanvas(handle,0,0,156,128,PnInfo,0,16);
    end;
  end;
end;

procedure TJForm.BtnRapidasClick(Sender: TObject);
begin
  with TFRapidas.create(Application) do
  begin
    showmodal;
    free;
  end;
end;
//-------------------- Botones Arriba Abajo --------------------
procedure TJForm.B_TxAbajoClick(Sender: TObject);
begin
//abajo
  if not B_TxAbajo.visible then exit;
  inc(IndiceDelUltimoMensaje);
  DibujarMensajes;
end;

procedure TJForm.B_txArribaClick(Sender: TObject);
begin
//arriba
  if not B_TxArriba.visible then exit;
  dec(IndiceDelUltimoMensaje);
  DibujarMensajes;
end;

procedure TJForm.b_ArribaClick(Sender: TObject);
  procedure SubirGridLogico(var GridLogico:TgridLogico;maxFilaArriba:integer);
  var i,anterior:integer;
  begin
    with GridLogico do
    begin
      i:=PrimeraFil;
      anterior:=fil;
      if i>maxFilaArriba then i:=i-3 else dec(i);
      if i<0 then i:=0;
      fil:=i;
      B_Abajo.visible:=PrimeraFil<maxFilaArriba;
      B_Arriba.visible:=PrimeraFil>0;
      repintarPanelGrids:=repintarPanelGrids or (anterior<>Fil);
    end;
  end;
begin
  if not B_Arriba.Visible then exit;
  case IdGridActivado of
    IdGrInventario:
      SubirGridLogico(DgObjetos,3);
    IdGrconjuros:begin
      SubirGridLogico(DgConjuros,7);
      if RepintarPanelGrids then ActualizarIconoMagiaEspecialidad;
    end;
  end;
end;

procedure TJForm.B_AbajoClick(Sender: TObject);
  procedure BajarGridLogico(var GridLogico:TgridLogico;maxFilaArriba:integer);
  var i,anterior:integer;
  begin
    with GridLogico do
    begin
      anterior:=fil;
      i:=PrimeraFil;
      if i<maxFilaArriba then i:=i+3 else inc(i);
      if i>(NroFil-1) then i:=NroFil-1;
      fil:=i;
      B_Abajo.visible:=PrimeraFil<maxFilaArriba;
      B_Arriba.visible:=PrimeraFil>0;
      repintarPanelGrids:=repintarPanelGrids or (anterior<>Fil);
    end;
  end;
begin
  if not B_Abajo.Visible then exit;
  case IdGridActivado of
    IdGrInventario:
      BajarGridLogico(DgObjetos,3);
    IdGrconjuros:begin
      BajarGridLogico(DgConjuros,7);
      if RepintarPanelGrids then ActualizarIconoMagiaEspecialidad;
    end;
  end;
end;

//*******************************
//                MUSICA
//*******************************

function TJForm.ElegirArchivoDeMusica:string;
var PrefijoMusica:char;
begin
  if EstadoGeneralDelJuego>=ejProgreso then
  begin
    PrefijoMusica:=MapaEspejo.DeterminarPrefijoDeMusicaAdecuada;
    repeat
      result:=PrefijoMusica+char(random(6)+48);
    until result<>MusicaTocada;
  end
  else// Pantalla principal
    if MusicaTocada='i' then result:='b3' else result:='i';
  MusicaTocada:=result;
  result:=result+'.';
  if fileexists(Ruta_Aplicacion+'snd\'+result+G_ExtensionMusica1) then
    result:=result+G_ExtensionMusica1
  else
    result:=result+G_ExtensionMusica2;
end;

procedure TJForm.MidiFileUpdateEvent(Sender: TObject);
begin
  if MidiFile.ready then TocarMusicaDeFondo('');
end;

procedure TJForm.TocarMusicaDeFondo(ArchivoMusica:string);
var errorcode:integer;
begin
  DesactivarMusica;
  MusicaActivada:=true;
  if ArchivoMusica='' then
    ArchivoMusica:=ElegirArchivoDeMusica;
  MusicaTipoMP3:=copy(uppercase(ExtractFileExt(ArchivoMusica)),2,3)<>'MID';
  if MusicaTipoMP3 then
  begin
    if MP_musica=nil then
      MusicaActivada:=false
    else
      with MP_musica do
      begin
        FileName:=Ruta_Aplicacion+'snd\'+ArchivoMusica;
        try
          Notify:=true;
          wait:=false;
          open;
        except
          ControlMensajes.setMensaje(JugadorCl,ErrorMessage);
          MusicaActivada:=false;
        end;
      end
  end
  else
  begin
    if (MidiFile=nil) or (MidiOutput=nil) then
      MusicaActivada:=false
    else
    begin
      MidiOutput.Open;
      with MidiFile do
      begin
        FileName:=Ruta_Aplicacion+'snd\'+ArchivoMusica;
        errorcode:=ReadFile();
        if errorcode=0 then
          StartPlaying()//sin error
        else
        begin
          ControlMensajes.setMensaje(JugadorCl,ErrorToStr(errorcode));
          MidiOutput.SentAllNotesOff();
          MusicaActivada:=false;
        end
      end;
    end;
  end;
  DatosMenuOpciones.elemento[7].marcado:=MusicaActivada;
end;

procedure TJForm.MP_musicaNotify(Sender: TObject);
begin
  with TmediaPlayer(Sender) do
    if NotifyValue=nvSuccessful then
      case LastAction of
        mpaPlay:TocarMusicaDeFondo('');
        mpaOpen:play;
      end;
end;

procedure TJForm.ActivarMusica;
begin
  if not MusicaActivada then
    TocarMusicaDeFondo('');
end;

procedure TJForm.DesactivarMusica;
begin
  if MusicaActivada then
  begin
    MusicaActivada:=false;
    if MusicaTipoMP3 then
    begin
      if MP_musica<>nil then
        MP_musica.close
    end
    else
      if (midifile<>nil) and (midiOutput<>nil) then
      begin
        midifile.StopPlaying;
        MidiOutput.SentAllNotesOff;
        MidiOutput.Close;
      end;
  end;
end;

//------------------------Visibilidad de ---------------------
//---------------------- Botones labels Edits ----------------
//Para mostrar los botones.
procedure TJForm.ActualizarElementosDePantalla;
var i,seleccionado:integer;
    ok:boolean;
begin
  Randomize;//.. :(  ??
// Interfaz del juego
  EditMensaje.visible:=false;//sólo activado a peticion del usuario
  ok:=EstadoGeneralDelJuego=ejProgreso;
  B_Opciones.Visible:=ok;
  PBInterfaz.Visible:=ok;
  for i:=0 to 4 do
    lbTexto[i].visible:=ok;
  lbMensaje.visible:=ok;
  LabelVida.visible:=ok;
  LabelComida.visible:=ok;
  LabelMana.visible:=ok;
  B_Arriba.Visible:=false;
  B_Abajo.Visible:=ok;
  B_txArriba.Visible:=false;
  B_txAbajo.Visible:=false;

//Botones del Menu Principal
  ok:=EstadoGeneralDelJuego=ejMenu;
  BMenu_Ingresar.visible:=ok;
  BMenu_Crear.visible:=ok;
  BMenu_Salir.visible:=ok;
  BtnServidor.visible:=ok;
  BtnBuscar.visible:=ok;
  BtnPuerto.visible:=ok;
  BtnRapidas.visible:=ok;
//Etiquetas del login
  ok:=EstadoGeneralDelJuego=ejLogin;
  E_identificador.visible:=ok;
//Botones Aceptar/Cancelar y contraseña
  ok:=(EstadoGeneralDelJuego=ejLogin) or
      (EstadoGeneralDelJuego=ejCrear);
  B_Aceptar.visible:=ok;
  B_cancelar.visible:=ok;
  E_contrasenna.visible:=ok;
//Elementos de Crear Personaje
  ok:=EstadoGeneralDelJuego=ejCrear;
  B_Dados.visible:=ok;
  Lb_clase.visible:=ok;
  Lb_raza.visible:=ok;
  Lb_genero.visible:=ok;
  Btnclase.visible:=ok;
  Btnraza.visible:=ok;
  Btngenero.visible:=ok;
  e_nombre.visible:=ok;
  E_confirmar.visible:=ok;
  for i:=0 to 15 do
    LbPericia[i].visible:=ok;
  LB_frz.visible:=ok;
  LB_con.visible:=ok;
  LB_int.visible:=ok;
  LB_sab.visible:=ok;
  LB_des.visible:=ok;
  case EstadoGeneralDelJuego of
    ejLogin:
    begin
      E_identificador.text:=NombreLoginUU;
      E_contrasenna.left:=300;
      E_contrasenna.top:=252;
      E_contrasenna.text:='';
      ActiveControl:=E_identificador;
    end;
    ejCrear:
    begin
      E_identificador.text:='';//sino no tratará de loguearse
      E_contrasenna.left:=112;
      E_contrasenna.top:=280;
      E_contrasenna.text:='';
      E_confirmar.text:='';
      with DatosPersonajeCl do
      begin
        cod_categoria:=random(8);
        cod_raza:=random(6);
//        if bytebool(categoriasDenegadas[cod_raza] and $40) then cod_genero:=0 else cod_genero:=random(2);
        cod_genero:=0;
        Lb_Genero.Caption:=MC_Genero[cod_genero];
        Lb_Clase.Caption:=MC_Nombre_Categoria[cod_Categoria];
        Lb_Raza.Caption:=InfMon[cod_raza].nombre;
      end;
      e_nombre.text:='';
      ActiveControl:=E_nombre;
      //Inicializar las etiquetas de pericias a desactivado, no elegible:
      for i:=0 to 15 do LbPericia[i].font.color:=clBronceOscuro;
      AsegurarCategoriaValidaPorRaza;
      //Seleccionar 3 pericias:
      for i:=1 to MAX_PERICIAS do
      begin
        repeat
          seleccionado:=random(16);
        until ((PericiasDenegadas[DatosPersonajeCl.cod_categoria]and(1 shl seleccionado))=0) and (LbPericia[seleccionado].font.color<>clblanco);
        with LbPericia[seleccionado] do
        begin
          font.color:=clblanco;
          repaint;
        end;
      end;
      NroPericiasResaltadas:=MAX_PERICIAS;
      B_DadosClick(nil);
    end;
  end;
  if EstadoGeneralDelJuego<ejProgreso then
    repaint;
end;

procedure TJForm.MarcarAutor;
var s:string;
    i,k,j:integer;
begin
  with canvas,font do
  begin
    size:=11;
    style:=[fsBold];
    s:=CREADO_POR;
    color:=clBlack;
    for i:=0 to 4 do
    begin
      if i=4 then
      begin
        color:=clOro;
        k:=0;
        j:=0;
      end
      else
      begin
        color:=i*$200000;
        j:=MC_avanceX[i];
        k:=MC_avanceY[i];
      end;
      textOut(72+j,436+k,G_NombreDelServidor);
      textOut(72+j,458+k,intastr(G_PuertoComunicacion));
      if (color=clOro) then color:=clAmarilloPalido;
      textOut(638+j-textWidth(G_GameHosting),440+k,G_GameHosting);
      textOut(638+j-textWidth(s),460+k,s);
    end;
  end;
end;

procedure TJForm.paint;
var s:string;
    i:integer;
begin
  if EstadoGeneralDelJuego<ejprogreso then
  begin
    if EstadoGeneralDelJuego>ejNoPreparado then
      BitBlt(canvas.handle,0,0,640,480,fondoMenu.canvas.handle,0,0,SRCCOPY);
    case EstadoGeneralDelJuego of
      ejConectando:
        with canvas do
        begin
          font.size:=18;
          font.color:=clBronce;
          font.style:=[];
          s:='Conectando con el servidor';
          textOut((640-TextWidth(s)) div 2,200,s);
          s:=G_NombreDelServidor+':'+intastr(G_PuertoComunicacion);
          textOut((640-TextWidth(s)) div 2,240,s);
        end;
      ejMenu:
          MarcarAutor;
      ejLogin:
        with canvas do
        begin
          font.size:=14;
          font.color:=clBronceClaro;
          font.style:=[];
          textOut(208,204,'Nombre:');
          textOut(208,252,'Contraseña:');
        end;
      ejCrear:
        with canvas do
        begin
          font.style:=[fsBold];
          font.size:=12;
          font.color:=clBronce;
          for i:=0 to 4 do
          begin
            textOut(500,182+i*24,NmbrsHabilidades[i]);
          end;
          font.size:=14;
          font.color:=clBronceClaro;
          font.style:=[];
          textOut(16,150,'Nombre:');
          textOut(16,182,'Clase:');
          textOut(16,214,'Raza:');
          textOut(16,280,'Contraseña:');
          textOut(16,314,'Confirmar:');
          font.style:=[fsUnderline];
          textOut(258,146,'Selecciona tres pericias:');
          textOut(500,146,'Habilidades:');
        end;
    end
  end
  else
  if not active then
  begin
    PBInterfaz.repaint;
    CopiarSuperficieACanvas(canvas.handle,0,0,ancho_DD,alto_DD,SuperficieRender,0,0);
  end;
end;

procedure TJForm.BMenu_IngresarClick(Sender: TObject);
begin
  if EstadoGeneralDelJuego=ejMenu then //Elementos creados y listos para iniciar el juego
  begin
    SonidoIntensidad(snAceitar,-500);
    EstadoGeneralDelJuego:=ejLogin;
    ActualizarElementosDePantalla;
  end
end;

procedure TJForm.BMenu_CrearClick(Sender: TObject);
begin
  if EstadoGeneralDelJuego=ejMenu then //Elementos creados y listos para iniciar el juego
  begin
    SonidoIntensidad(snAceitar,-500);
    EstadoGeneralDelJuego:=ejCrear;
    ActualizarElementosDePantalla;
  end;
end;

procedure TJForm.BMenu_SalirClick(Sender: TObject);
begin
  if EstadoGeneralDelJuego=ejMenu then Close;
end;

procedure TJForm.B_AceptarClick(Sender: TObject);
//Pequeñas funciones para evitar contraseñas con secuencias o repeticiones.
  //Funcion que introduce las pericias señaladas:
  procedure LlenarPericias;
  var i:integer;
  begin
    with DatosPersonajeCl do
    begin
      pericias:=0;
      for i:=0 to 15 do
        if LbPericia[i].font.color=clblanco then
          pericias:=pericias or ($0001 shl i);
    end;
  end;
  function NoTiene3Letras(const cad:string):boolean;
  var i,c:integer;
  begin
    c:=0;
    for i:=1 to length(cad) do
      if cad[i] in ['A'..'Z'] then inc(c);
    result:=c<3;
  end;
begin
  case EstadoGeneralDelJuego of
    ejLogin:begin
      if length(trim(E_Identificador.text))<3 then
      begin
        ShowmessageZ('Identificador incorrecto');
        exit;
      end;
      if length(E_contrasenna.text)<4 then
      begin
        ShowmessageZ('Contraseña incorrecta');
        exit;
      end;
      EstadoGeneralDelJuego:=ejConectando;
      ActualizarElementosDePantalla;
      ClientSocket.open;
    end;
    ejCrear:begin
      //Verificar datos:
      E_nombre.text:=QuitarCaracteresNoPermitidos(trim(E_nombre.text));
      NombreLoginUU:=E_nombre.text;
      if NoTiene3Letras(ObtenerLoginDeCadena(NombreLoginUU)) then
      begin
        ShowmessageZ('Tu nombre debe tener al menos tres letras');
        exit;
      end;
      if length(e_contrasenna.text)<4 then
      begin
        ShowmessageZ(MC_CONTRASENNA_CORTA);
        exit;
      end;
      if e_contrasenna.text<>e_confirmar.text then
      begin
        ShowmessageZ(MC_CONTRASENNA_CONFIRMACION);
        exit;
      end;
      if repeticionEnContrasenna(e_contrasenna.text) then
      begin
        ShowmessageZ(MC_CONTRASENNA_CON_REPETICIONES);
        exit;
      end;
      if loguinParecidoAContrasenna(NombreLoginUU,e_contrasenna.text) then
      begin
        ShowmessageZ(MC_CONTRASENNA_CON_LOGIN);
        exit;
      end;
      LlenarPericias;
      if ContarPericias(DatosPersonajeCl.pericias)<>3 then
      begin
        ShowmessageZ('Selecciona tres pericias');
        exit;
      end;
      {$IFDEF ESPERA_PARA_CREAR_AVATAR}
      if G_NombreDelServidor<>IP_SERVIDOR_LOCAL then
      begin
        if (IdDeAtomDeCreacion=0) then//Ver si se creo en otra instancia del juego
          IdDeAtomDeCreacion:=GlobalFindAtom(ATOM_CREACION_AVATAR);
        if (IdDeAtomDeCreacion<>0) then
        begin// Si encontro el ATOM, no permitir crear más personajes.
          ShowmessageZ(MEN_ANTI_ABUSO_CREACION);
          exit;
        end;
      end;
      {$ENDIF}
      with DatosPersonajeCl do
        nombre:=NombreLoginUU;
      EstadoGeneralDelJuego:=ejConectando;
      ActualizarElementosDePantalla;
      SonidoIntensidad(snCampana,-500);
      ClientSocket.open;
    end;
  end;
end;

procedure TJForm.B_CancelarClick(Sender: TObject);
begin
  SonidoIntensidad(snError,-500);
  case EstadoGeneralDelJuego of
    ejLogin,ejCrear:
    begin
      EstadoGeneralDelJuego:=ejMenu;
      ActualizarElementosDePantalla;
    end;
  end;
end;

procedure TJForm.B_DadosClick(Sender: TObject);
begin
  if sender<>nil then SonidoIntensidad(snMinar,-500);
  //Necesita saber la categoria y la raza:
  DefinirHabilidadesAlAzar(DatosPersonajeCl);
  with DatosPersonajeCl do
  begin
    LB_FRZ.Caption:=intastr(FRZ*5)+'%';
    LB_DES.Caption:=intastr(DES*5)+'%';
    LB_INT.Caption:=intastr(INT*5)+'%';
    LB_SAB.Caption:=intastr(SAB*5)+'%';
    LB_CON.Caption:=intastr(CON*5)+'%';
  end
end;

procedure TJForm.BtnRazaClick(Sender: TObject);
begin
  with DatosPersonajeCl do
  begin
    inc(cod_raza);
    cod_raza:=cod_raza mod 7;
    Lb_raza.Caption:=InfMon[cod_raza].nombre;
  end;
  AsegurarCategoriaValidaPorRaza;
  B_DadosClick(nil);
end;

procedure TJForm.AsegurarCategoriaValidaPorRaza;
var i:integer;
begin
  with DatosPersonajeCl do
  begin
    while bytebool(categoriasDenegadas[cod_raza] and (1 shl cod_categoria)) do
    begin
      inc(cod_categoria);
      cod_categoria:=cod_categoria and $7;
    end;
    Lb_Clase.Caption:=MC_Nombre_Categoria[cod_categoria];
  end;
  //Control de estado de selección de pericias.
  for i:=0 to 15 do
    with LbPericia[i] do
      if LongBool(PericiasDenegadas[DatosPersonajeCl.cod_categoria] and (1 shl i)) then
      begin
        if font.color=clblanco then dec(nroPericiasResaltadas);
        font.color:=clBronceOscuro;
      end
      else
        if font.color=clBronceOscuro then font.color:=clBronce
end;

procedure TJForm.btnClaseClick(Sender: TObject);
begin
  with DatosPersonajeCl do
  begin
    inc(cod_categoria);
    cod_categoria:=cod_categoria and $7;
  end;
  AsegurarCategoriaValidaPorRaza;
  B_DadosClick(nil);
end;

procedure TJForm.BtnGeneroClick(Sender: TObject);
begin
  with DatosPersonajeCl do
  begin
    inc(cod_genero);
    cod_genero:=cod_genero and $1;
    Lb_genero.Caption:=MC_Genero[cod_genero];
  end;
end;

procedure TJForm.LB_perMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with Tlabel(sender),font do
    if color=clBronce then
    begin
      if (nroPericiasResaltadas<MAX_PERICIAS) then
      begin
        inc(nroPericiasResaltadas);
        color:=clblanco;
        repaint;
      end
      else
        ShowMessageZ('Sólo puedes seleccionar hasta tres pericias'+#13+
          'Para elegir otra, primero apaga una de las elegidas');
    end
    else
      if color=clblanco then
      begin
        if nroPericiasResaltadas>0 then dec(nroPericiasResaltadas);
        color:=clBronce;
        repaint;
      end;
end;

procedure TJForm.EditKeyPress(Sender: TObject; var Key: Char);
begin  //Para presionar "Aceptar" con la tecla Enter
  case key of
    #13:begin
      key:=#0;
      B_Aceptar.OnClick(nil);
    end;
    #27:begin
      key:=#0;
      B_Cancelar.OnClick(nil);
    end;
  end;
  if key<>#8 then
    if not (key in CaracteresPermitidos) then key:=#0;
end;

procedure TJForm.FormActivate(Sender: TObject);
begin
  if EstadoGeneralDelJuego=ejMenu then
    if G_IniciarConMusica then ActivarMusica;
end;

//******************************************************************************
// REFRESCADORES (Comandos del servidor, que necesitan acceso a interfaz)
//******************************************************************************
procedure TJform.SRefrescarObjeto(Posicion,id,modificador:byte;Seleccionar:boolean);
begin
  if Posicion<=7 then
  begin
    jugadorCl.Usando[Posicion].id:=id;
    jugadorCl.Usando[Posicion].modificador:=modificador;
    JugadorCl.CalcularModDefensa;
    MostrarDatosFrecuentesJugador;
  end
  else
  begin
    jugadorCl.Artefacto[Posicion-8].id:=id;
    jugadorCl.Artefacto[Posicion-8].modificador:=modificador;
  end;
  PintarObjetoPosicion(Posicion,Seleccionar);
end;

procedure TJForm.BtnServidorClick(Sender: TObject);
var cad:string;
begin
  SonidoIntensidad(snAceitar,-500);
  cad:=trim(InputBoxZ('Servidor:', G_NombreDelServidor));
  if length(cad)<=0 then exit;
  G_NombreDelServidor:=cad;
  with ClientSocket do
    if PareceIP(G_NombreDelServidor) then
    begin
      host:='';//siempre para que Address tenga prioridad
      Address:=G_NombreDelServidor
    end
    else
    begin
      host:=G_NombreDelServidor;
    end;
  invalidate;
end;

procedure TJForm.BtnPuertoClick(Sender: TObject);
var cad:string;
    nro,code:integer;
begin
  SonidoIntensidad(snAceitar,-500);
  cad:=trim(InputBoxZ('Puerto:', intastr(G_PuertoComunicacion)));
  val(cad,nro,code);
  if code<>0 then exit;
  if (nro<MIN_PUERTO_COMUNICACION) or (nro>MAX_PUERTO_COMUNICACION) then exit;
  G_PuertoComunicacion:=nro;
  ClientSocket.port:=G_PuertoComunicacion;
  invalidate;
end;

procedure TJForm.AlLeerIP(Sender: TObject; Socket: TCustomWinSocket);
begin
  GetIPClientSocket.ObtenerServidorYPuerto(socket);
  socket.close;
  if GetIPClientSocket.servidor<>'' then
  begin
    G_NombreDelServidor:=GetIPClientSocket.servidor;
    with ClientSocket do
      if PareceIP(G_NombreDelServidor) then
      begin
        host:='';//siempre para que Address tenga prioridad
        Address:=G_NombreDelServidor
      end
      else
      begin
        host:=G_NombreDelServidor;
      end;
  end;
  if GetIPClientSocket.puerto<>0 then
  begin
    G_PuertoComunicacion:=GetIPClientSocket.puerto;
    ClientSocket.port:=G_PuertoComunicacion;
  end;
  BtnBuscar.Caption:='Buscar Servidor';
  invalidate;
end;

procedure TJForm.IPClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var cad:string;
begin
  BtnBuscar.Caption:='Buscar Servidor';
  cad:=G_NombreDelServidor;
  G_NombreDelServidor:=G_ServidorWEB;
  ClientSocketError(Sender,Socket,ErrorEvent,ErrorCode);
  G_NombreDelServidor:=cad;
end;

procedure TJForm.BtnBuscarClick(Sender: TObject);
begin
  sonido(snHielo);
  if GetIPClientSocket.SolicitarServidor(G_ServidorWEB) then
    BtnBuscar.Caption:='Buscando...';
end;


//******************************************************************************
//SOCKETS
//******************************************************************************
procedure TJForm.ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
//Propiedad "Active" está en falso, luego de terminado este proceso se procederá a un .close
begin
  if EstadoGeneralDelJuego>=EjProgreso then
  begin
    FinalizarJuego;
    if not SeRealizoPeticionParaFinalizarSesion then
      ShowmessageZ('Se perdió la conexión con el servidor');
    SeRealizoPeticionParaFinalizarSesion:=false;
  end
  else
    if EstadoGeneralDelJuego=ejConectando then
    begin
      EstadoGeneralDelJuego:=ejMenu;
      ActualizarElementosDePantalla;
      ShowmessageZ('Conexión cerrada por el Servidor');
    end;
  if (ID_ATOM_SOLO_UNA_INSTANCIA<>0) then
    GlobalDeleteAtom(ID_ATOM_SOLO_UNA_INSTANCIA);
end;

procedure TJForm.ClientSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  if ClientSocket.Active then
    ClientSocket.close;
  MostrarMensajeErrorEnSocket(ErrorCode,Socket,'');
  ErrorCode:=0;
end;

procedure TJForm.TratarIniciarSesion(NroAleatorioServidor:integer);
var pas:TPassword;
    cadenaDatosConexion:string;
    NroDesHabilidades:longWord;
begin
  cadenaDatosConexion:=B4aStr(ObtenerAutentificacion(NroAleatorioServidor))+chr(VersionLA);
  if length(E_identificador.text)=0 then
  begin
    //Bloqueador anti creación masiva abusiva.
    {$IFDEF ESPERA_PARA_CREAR_AVATAR}
    if G_NombreDelServidor<>IP_SERVIDOR_LOCAL then
      if NroAvataresCreados>=3 then
      begin
        if (IdDeAtomDeCreacion=0) then//Ver si fue agregado en instancia anterior
          IdDeAtomDeCreacion:=GlobalFindAtom(ATOM_CREACION_AVATAR);
        if (IdDeAtomDeCreacion=0) then//Sólo agregar si no existe!
          IdDeAtomDeCreacion:=GlobalAddAtom(ATOM_CREACION_AVATAR);
      end
      else
        inc(NroAvataresCreados);
    {$ENDIF}
    //Crear Personaje
    with DatosPersonajeCl do
    begin
      pas:=EmpaquetarPassword(E_contrasenna.text,ObtenerLoginDeCadena(nombre));
      if cod_genero<>0 then NroDesHabilidades:=$80000000 else NroDesHabilidades:=0;
      NroDesHabilidades:=NroDesHabilidades or INT;
      NroDesHabilidades:=NroDesHabilidades or (FRZ shl 5);
      NroDesHabilidades:=NroDesHabilidades or (CON shl 10);
      NroDesHabilidades:=NroDesHabilidades or (DES shl 15);
      NroDesHabilidades:=NroDesHabilidades or (SAB shl 20);
      cadenaDatosConexion:=cadenaDatosConexion+
        '*'+B2aStr(pericias)+
        //cod_raza=nible_inferior, cod_categoria=nible_superior.
        chr((cod_raza and $F)or(cod_categoria shl 4))+b4aStr(NroDesHabilidades)+chr(length(nombre))+nombre+PasswordAStr(pas);
    end;
  end
  else
  begin
  //Iniciar Sesion
{$IFDEF CONTROL_ESTADISTICAS}
    FechaHoraInicio:=now;
    NrBytesRecibidos:=0;
    NumeroArribosDatos:=0;
{$ENDIF}
    NombreLoginUU:=E_identificador.text;
    IdentificadorUU:=ObtenerLoginDeCadena(NombreLoginUU);
    ContrasennaUU:=E_contrasenna.text;
    pas:=EmpaquetarPassword(ContrasennaUU,IdentificadorUU);
    //OJO: mando primero pas y luego log, porque en el servidor los parámetros
    cadenaDatosConexion:=cadenaDatosConexion+'!'+PasswordAStr(pas)+chr(length(IdentificadorUU))+IdentificadorUU;

    if GlobalFindAtom(CREADO_POR)=0 then
      ID_ATOM_SOLO_UNA_INSTANCIA:=GlobalAddAtom(CREADO_POR)
    else
    begin
      ShowmessageZ(MEN_SIN_MULTIPLES_SESIONES);
      cadenaDatosConexion:='#255';
    end;
  end;
  Cliente.SendTextNow(cadenaDatosConexion);
end;

////////////////////////////////////////////////////////////////////////////////
//              INTERPRETADOR DE COMANDOS QUE VIENEN DEL SERVIDOR             //
////////////////////////////////////////////////////////////////////////////////
procedure TJForm.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var i:integer;
    longitudBufferRecepcion,longitudBufferProcesado,posicionBufferRecepcion:integer;
    desconectar:bytebool;//colocar Terminar:=true para salir del interpretador
    MetaComando:byte;

    //Para la conexion:
    CX_Cadena127:Tcadena127;
    CX_Cadena:string;
    CX_4B:Longint;
    RefMonstruoTemp:TmonstruoS;
    CX_A,CX_B,CX_C,CX_D:Byte;
    CX_2B:word;

  procedure MostrarMensajeError;
  const ERROR_SINCRONIZACION='Error de sincronización, desconectando...';
  begin
    socket.BufferRecepcion:='';
    MensajeAyuda:=ERROR_SINCRONIZACION;
    if EstadoGeneralDelJuego<ejProgreso then
      ShowmessageZ(ERROR_SINCRONIZACION);
    desconectar:=true;
  end;
  procedure MostrarMensajeServidor(const mensaje:string);
  begin
    MensajeAyuda:=mensaje;
  end;
//Inicio de los GET
//--------------------------------------------------------------
  function Get1B:byte;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(socket.BufferRecepcion[posicionBufferRecepcion]);
  end;
  function GET2B:word;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(socket.BufferRecepcion[posicionBufferRecepcion]);
    inc(posicionBufferRecepcion);
    result:=result or (ord(socket.BufferRecepcion[posicionBufferRecepcion]) shl 8);
  end;
  function GET3B:longint;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(socket.BufferRecepcion[posicionBufferRecepcion]);
    inc(posicionBufferRecepcion);
    result:=result or (ord(socket.BufferRecepcion[posicionBufferRecepcion]) shl 8);
    inc(posicionBufferRecepcion);
    result:=result or (ord(socket.BufferRecepcion[posicionBufferRecepcion]) shl 16);
  end;
  function GET4B:longint;
  begin
    inc(posicionBufferRecepcion);
    result:=ord(socket.BufferRecepcion[posicionBufferRecepcion]);
    inc(posicionBufferRecepcion);
    result:=result or (ord(socket.BufferRecepcion[posicionBufferRecepcion]) shl 8);
    inc(posicionBufferRecepcion);
    result:=result or (ord(socket.BufferRecepcion[posicionBufferRecepcion]) shl 16);
    inc(posicionBufferRecepcion);
    result:=result or (ord(socket.BufferRecepcion[posicionBufferRecepcion]) shl 24);
  end;
//Para cadenas largas con longitud variable:
  function GET_Cadena255(caracteres:byte):TCadena255;
  //buffer nunca=''.
  //Hasta 255 chars.
  begin
    result[0]:=chr(caracteres);
    move(pointer(integer(socket.BufferRecepcion)+posicionBufferRecepcion)^,
      result[1],caracteres);
    inc(posicionBufferRecepcion,caracteres);
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
//Fin de los GET
//--------------------------------------------------------------
  function FaltaInformacion(nroBytes:integer):boolean;
  begin
    result:=longitudBufferRecepcion<posicionBufferRecepcion+nroBytes;
    if result then
      delete(socket.BufferRecepcion,1,longitudBufferProcesado);
  end;
{TODO:
  Varias de estas funciones no tienen control de rango de los códigos de
monstruos y jugadores, por lo que en caso de error de transmisión puede
que generen una excepción de indice fuera de rango.}
begin
{$IFDEF CONTROL_ESTADISTICAS}
  i:=length(socket.BufferRecepcion);//Lo que no fue procesado del anterior paquete

  if (i>0) and (not G_IniciarConMusica) then
    agregarMensaje('Fragmentos unidos');

{$ENDIF}
  socket.BufferRecepcion:=socket.BufferRecepcion+Socket.receiveText;
  longitudBufferRecepcion:=length(socket.BufferRecepcion);
{$IFDEF CONTROL_ESTADISTICAS}
  inc(NrBytesRecibidos,longitudBufferRecepcion-i);//Sólo contar lo que recien ha llegado.
  inc(NumeroArribosDatos);
{$ENDIF}
  posicionBufferRecepcion:=0;
  desconectar:=false;
  //Mientras existan caracteres no decodificados
  while longitudBufferRecepcion>posicionBufferRecepcion do
  begin
    longitudBufferProcesado:=posicionBufferRecepcion;
    MetaComando:=GET1B;
    case chr(MetaComando) of //Primer caracter
      'p':begin//Posicion actual del jugador
        if FaltaInformacion(3) then exit;
        CX_A:=GET1B;//X
        CX_B:=GET1B;//Y
        MapaEspejo.Smover(CodigoCNXJugador,CX_A,CX_B,GET1B{dir},tmInterpolado);
      end;
      'P':begin//Posicion de un sprite.
        if FaltaInformacion(5) then exit;
        CX_2b:=GET2B;
        CX_A:=GET1B;//X
        CX_B:=GET1B;//Y
        MapaEspejo.Smover(CX_2b,CX_A,CX_B,GET1B,tmInterpolado);
      end;
      #128..#135:begin//Dirección del elemento: (8 direcciones)
        if FaltaInformacion(2) then exit;
        dec(MetaComando,128);
        SCambiarDireccion(GET2B,Metacomando);
      end;
      #144..#151:begin//Direccion del jugador
        dec(MetaComando,144);
        SCambiarDireccion(JugadorCl.codigo,Metacomando);
      end;
      #160..#175:begin//Acción del elemento: (16 acciones)
        if FaltaInformacion(2) then exit;
        dec(MetaComando,160);
        SCambiarAccion(GET2B,Metacomando);
      end;
      #176..#191:begin//Accion del jugador
        dec(MetaComando,176);
        SCambiarAccion(JugadorCl.codigo,Metacomando);
      end;
      #255://Refrescar HP
      begin
        if FaltaInformacion(2) then exit;
        MostrarHP(GET2B,false,'');
      end;
      #252:begin//hp disminuido por golpe y nombre ataque
        if FaltaInformacion(4) then exit;
        CX_2b:=GET2B;
        CX_B:=GET1B;
        CX_C:=GET1B;
        MostrarHP(CX_2b,true,'Un'+AgregarSufijoSexuadoA(infmon[CX_C].nombre)+' te ataca con '+Nombre_Ataque[CX_B mod (MaxNombresAtaques+1)]);
      end;
      #251:begin//hp disminuido por golpe e identificador de objeto
        if FaltaInformacion(5) then exit;
        CX_2b:=GET2B;
        CX_B:=GET1B;
        MostrarHP(CX_2b,true,nombreAtaquePorObjeto(CX_B,GET2B));
      end;
      #249:begin//hp disminuido por Hechizo mágico
        if FaltaInformacion(5) then exit;
        CX_2b:=GET2B;
        CX_B:=GET1B;
        MostrarHP(CX_2b,true,nombreAtaquePorHechizo(CX_B,GET2B));
      end;
      #254:begin//mana
        if FaltaInformacion(1) then exit;
        with JugadorCl do
        begin
          mana:=GET1B;
          //dejar de meditar si esta lleno de mana
          if mana>=maxMana then
          begin
            accion:=aaParado;
            Banderas:=(Banderas or BnMana) xor BnMana;
          end;
        end;
        MostrarMana;
      end;
      #253:begin//comida
        if FaltaInformacion(1) then exit;
        JugadorCl.comida:=GET1B;
        MostrarComida;
      end;
      #250:begin//dinero
        if FaltaInformacion(4) then exit;
        JugadorCl.dinero:=GET4B;
        MostrarDineroJugador;
      end;
      //#192..#207: Comandos de sincronizacion de objetos tipo bolsa
      #192:begin//Eliminar una bolsa
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SEliminarBolsa(CX_A,GET1B);
      end;
      #193:begin//Eliminar bolsa e informar que no tenia nada.
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        if MapaEspejo.SEliminarBolsa(CX_A,GET1B)=tbFogata then
          AgregarMensaje('Apagas la fogata')
        else
        //cerrar ventana de objetos
          if VentanaActivada=vaMenuObjetos then
            VentanaActivada:=vaNinguna
          else
            AgregarMensaje('No encontraste algo que sea de valor');
      end;
      #194:begin//Agregar bolsa
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarBolsa(CX_A,GET1B,tbComun);
      end;
      #195:begin//Agregar leña
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarBolsa(CX_A,GET1B,tbLenna);
      end;
      #196:begin//Agregar fogata
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarBolsa(CX_A,GET1B,tbFogata);
      end;
      #197:begin//Apagar fogata
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SApagarFogata(CX_A,GET1B);
      end;
      #198:begin//Agregar cadaver rojo
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarCadaver(CX_A,GET1B,tbCadaver);
      end;
      #199:begin//Agregar cadaver verde
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarCadaver(CX_A,GET1B,tbCadaverVerde);
      end;
      #200:begin//Agregar cadaver quemado
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarCadaver(CX_A,GET1B,tbCadaverQuemado);
      end;
      #201:begin//Agregar restos de energia disipada
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarCadaver(CX_A,GET1B,tbCadaverEnergia);
      end;
      #202:begin//Agregar restos para avatar
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        MapaEspejo.SColocarCadaver(CX_A,GET1B,tbCadaverAvatar);
      end;
      #203:begin//Agregar una trampa
        if FaltaInformacion(2) then exit;
        CX_A:=GET1B;
        CX_B:=GET1B;
        MapaEspejo.SColocarBolsa(CX_A,CX_B,tbTrampaMagica);
        SonidoXY(snPrepararTrampa,CX_A-JugadorCl.coordX,CX_B-JugadorCl.coordY);
      end;
      #208..#233:begin//Refrescar objeto, hasta MAX_Posiciones
        if FaltaInformacion(2) then exit;
        dec(MetaComando,208);
        CX_A:=GET1B;
        CX_B:=GET1B;
        SrefrescarObjeto(Metacomando,CX_A,CX_B,false{true});
        MensajeTipTimer:=nombreObjeto(ObjetoArtefacto(CX_A,CX_B),JugadorCl.CapacidadId);
      end;
      #234..#239:begin//Refrescar modificador de objeto usado, de 0 a 5.
        if FaltaInformacion(1) then exit;
        CX_B:=MetaComando-234;
        CX_A:=GET1B;
        CX_C:=JugadorCl.usando[CX_B].id;
        if CX_A>0 then
        begin
          SrefrescarObjeto(CX_B,CX_C,CX_A,false);
          if CX_A<5 then
            AgregarMensaje('-Tienes que reparar tu'+AgregarSufijoAsexuadoS(NomObj[CX_C]))
        end
        else
        begin
          if CX_C<16 then
          begin
            AgregarMensaje('-Se desvaneció el arma '+NomObj[CX_C]);
            sonido(snTermina);
          end
          else
          begin
            if BrilloObjeto(JugadorCl.usando[CX_B],ciVerRealmente)=boNinguno then
              AgregarMensaje('-Perdiste tu'+AgregarSufijoAsexuadoS(NomObj[CX_C]));
            sonido(snArmaArmaduraDestrozada);
          end;
          SrefrescarObjeto(CX_B,ObNuloMDV.id,ObNuloMDV.modificador,false);
          //Refrescar mano izquierda cuando un arma de dos manos se rompe.
          if (CX_B=uArmaDer) and (InfObj[CX_C].PesoArma=paPesada) then
            PintarObjetoPosicion(uArmaIzq,false);
        end;
      end;
      'r':begin//Refrescamiento de sprites
        //numero de sprites:
        if FaltaInformacion(1) then exit;
        CX_4b:=get1B;
        if FaltaInformacion(CX_4b*5) then exit;
        for i:=0 to CX_4b-1 do
        begin
          CX_2b:=GET2B;
          CX_A:=GET1B;//X
          CX_B:=GET1B;//Y
          MapaEspejo.Smover(CX_2b,CX_A,CX_B,GET1B,tmDirecto);
        end;
      end;
      'e'://actualizar experiencia.
      with JugadorCl do
      begin
        if FaltaInformacion(2) then exit;
        experiencia:=GET2B;
        MostrarExperiencia;
      end;
      'h':begin
        if FaltaInformacion(3) then exit;
        RefMonstruoTemp:=GetMonstruoCodigoCasilla(GET2B);
        CX_A:=get1b;
        if FaltaInformacion(CX_A) then exit;
        CX_Cadena127:=GET_Cadena127(CX_A);
        if RefMonstruoTemp<>nil then
        begin
          ControlMensajes.setMensaje(RefMonstruoTemp,CX_Cadena127);
          ControlChat.setMensaje(RefMonstruoTemp,CX_Cadena127,clblanco)
        end
        else
          MostrarMensajeError;
      end;
      'H':begin
        if FaltaInformacion(3) then exit;
        RefMonstruoTemp:=GetMonstruoCodigoCasilla(GET2B);
        CX_A:=get1b;
        if RefMonstruoTemp<>nil then
          ControlMensajes.setMensaje(RefMonstruoTemp,JugadorCl.MensajeResultado(CX_A,0,0))
        else
          MostrarMensajeError;
      end;
      '=':begin//efectos sobre un jugador o monstruo en este mapa.
        if FaltaInformacion(3) then exit;
        RefMonstruoTemp:=GetMonstruoCodigoCasilla(GET2B);
        CX_A:=get1b;
        if RefMonstruoTemp<>nil then
          case char(CX_A) of
            'r':begin//resurreccion
              RefMonstruoTemp.hp:=$80;//$80 : avatar vivo
              if (RefMonstruoTemp.activo) then
                SonidoXY(snResucitar,RefMonstruoTemp.coordX-JugadorCl.coordX,RefMonstruoTemp.coordY-JugadorCl.coordY);
            end;
          end
        else
          MostrarMensajeError;
      end;
      'S'://efectos con posicion SxyC en este mapa
      begin
        if FaltaInformacion(3) then exit;
        CX_A:=GET1B;
        CX_B:=GET1B;
        CX_C:=GET1B;
        case char(CX_C) of
          //Combate, reservados los numeros
          'A':CX_2b:=snArcabuz;//Sonido al disparar Arbabuz
          'R':CX_2b:=snArco;//Sonido de la cuerda del arco
          'G':CX_2b:=snGolpeGarraEnCarne;
          'g':CX_2b:=snGolpeGarraEnArmadura;
          'E':CX_2b:=snGolpeEspadaEnCarne;
          'e':CX_2b:=snGolpeEspadaEnArmadura;
          'F':CX_2b:=snGolpeFlechaEnCarne;
          'f':CX_2b:=snGolpeFlechaEnArmadura;
          'C':CX_2b:=snGolpeContundente;
          'm':CX_2b:=snGolpeFallado;
          //Trabajo:
          't':CX_2b:=snTalar;//Hacha cortando árboles
          'n':CX_2b:=snMinar;//Pico destrozando piedra
          'p':CX_2b:=snPescar;//Caña de pescar lanzada al agua
          'u':begin
            CX_2b:=snFundir;//Agua encima del metal ardiente
            controlFX.SetEfecto(CX_A,CX_B,fxAcido,0,0,MapaEspejo.GetMonstruoXY(CX_A,CX_B));
          end;
          'c':CX_2b:=snComer;//comer
          'b':CX_2b:=snBeber;//beber
          '*':begin//fuego artificial indicando posicion
            AgregarMensaje('*Señal en el mapa, posición: '+intastr(CX_A)+','+intastr(CX_B));
            MiniMapa_DibujarSennal:=192;//255=max
            MiniMapa_X:=CX_A;
            MiniMapa_Y:=CX_B;
            ActualizarMiniMapa(true);
            controlFX.SetEfecto(CX_A,CX_B,fxFuegoArtificial1,0,0,nil);
            CX_2b:=snMeteoro;//disparo
          end;
          #127:CX_2b:=snPrepararPocima;
          #128:CX_2b:=snFabricarTela;
          #129:CX_2b:=snTallarGemas;
          #130:CX_2b:=snAfilar;
          #131:CX_2b:=snAceitar;
          #132:CX_2b:=snMartillarReparar;
          #133:CX_2b:=snCoser;
          #134:CX_2b:=snFlauta;
          #135:CX_2b:=snLaud;
          #136:CX_2b:=snCuerno;
          #137:CX_2b:=snBuscarIngrediente;
          #138:CX_2b:=snEcharVeneno;
          #139:CX_2b:=snEnvenenarFlechas;
          #140:begin
            CX_2b:=snLeerTomoDeLaExperiencia;
            controlFX.SetEfecto(CX_A,CX_B,fxChispasAzules,0,0,nil);
          end;
          #196:begin
            CX_2b:=snMeteoro;
            MapaEspejo.SEfectosConjuro(3,CX_A,CX_B);
          end;
          #197:begin
            CX_2b:=snMeteoro;
            MapaEspejo.SEfectosConjuro(0,CX_A,CX_B);
          end;
          #198:begin
            CX_2b:=snMeteoro;
            MapaEspejo.SEfectosConjuro(6,CX_A,CX_B);
          end;
          #199:begin
            CX_2b:=snMagiaCorto;
            MapaEspejo.SEfectosConjuro(6,CX_A,CX_B);
          end;
          //Construccion:
          #0:CX_2b:=snHerrero;//Herreria
          #1:CX_2b:=snCarpintero;//Carpinteria
          #2:CX_2b:=snTijeras;//Sastreria
          #3:CX_2b:=snAlquimia;
          #4:CX_2b:=snEscribirMagia;
          #5:CX_2b:=snLeerPergamino;
          #6:CX_2b:=snCurtir;//Agua encima del metal ardiente
          #200:CX_2b:=snMagiaBoom;
          #203,#216:CX_2b:=snHielo;
          #206,#226:CX_2b:=snAtaquePsitico;
          #209,#210,#229:CX_2b:=snCuracion;
          #219:CX_2b:=snTermina;
          #217,#218,#221,#225:CX_2b:=snMagiaCorto;
          #220,#224,#227:CX_2b:=snPrepararPocima;
          #212..#214,#222,#223:CX_2b:=snMagiaHada;
          #215:CX_2b:=snMaldicion;
          #201,#204:CX_2b:=snMeteoro;
          #207:CX_2b:=snRayoPsitico;
          #202,#205,#208:CX_2b:=snTormenta;
          #211,#228:CX_2b:=snCampana;
          else
          begin
            CX_2b:=snNinguno;
            AgregarMensaje('El servidor envio código de sonido desconocido.');
          end;
        end;
        if (CX_C>=200) and (CX_C<=229) then
          MapaEspejo.SEfectosConjuro(CX_C-200,CX_A,CX_B);
        SonidoXY(CX_2b,CX_A-JugadorCl.coordX,CX_B-JugadorCl.coordY);
      end;
      '*'://Variantes de comandos comunes
      begin
        if FaltaInformacion(1) then exit;
        case chr(GET1B) of
          'P':begin//Posicion de un sprite.
            if FaltaInformacion(5) then exit;
            CX_2b:=GET2B;
            CX_A:=GET1B;//X
            CX_B:=GET1B;//Y
            MapaEspejo.Smover(CX_2b,CX_A,CX_B,GET1B,tmDirectoConEfecto);
          end;
        else
          MostrarMensajeError;
        end;
      end;
      's'://acciones que afectan sólo al jugador actual
      begin
        if FaltaInformacion(1) then exit;
        case chr(GET1B) of
          'r':SResucitarJugador;
          'F':SFuerzagigante;
          'f':SFuerzaNormal;
          '+':SRestitucion;
          'S':SSanacion;
          'A':SAcelerar;
          'a':SQuitarAcelerar;
          'D':SArmadura;
          'd':SQuitarArmadura;
          'P':SProteccion;
          'p':SQuitarProteccion;
          'I':SInvisibilidad;
          'O':SInvisibilidadOcultarse;
          'i':SQuitarInvisibilidad;
          '(':SParalisis;
          ')':SQuitarParalisis;
          '@':SEnvenenar;
          's':SQuitarVeneno;
          'W':SVisionVerdadera;
          'w':SQuitarVisionVerdadera;
          'X':SActivarIraTenax;
          'x':SQuitarIraTenax;
          'v':SQuitarVendas;
          'V':SRealizarVendaje;
          'C':SCongelar;
          'c':SQuitarCongelar;
          'Z':SActivarZoomorfismo;
          'z':SQuitarZoomorfismo;
          'T':SAturdir;
          't':SQuitarAturdir;
        else
          MostrarMensajeError;
        end;
      end;
      'd'://Informe de daño a una criatura
      begin
        if FaltaInformacion(4) then exit;
        CX_2B:=GET2B;
        CX_4B:=GET2B;
        AgregarMensaje(DescribirAtaqueRealizado(CX_2B,CX_4B,ccVac))
      end;
      'D'://Informe de daño a un avatar
      begin
        if FaltaInformacion(6) then exit;
        CX_2B:=GET2B;
        CX_4B:=GET2B;
        AgregarMensaje(DescribirAtaqueRealizado(CX_2B,CX_4B,GET2B));
      end;
      'C'://Informa de conjuro lanzado a un avatar
      begin
        if FaltaInformacion(3) then exit;
        CX_A:=GET1B;
        AgregarMensaje(DescribirHechizoQueLeLanzaron(CX_A,GET2B));
      end;
      'i'://Informacion del servidor por código
      begin
        if FaltaInformacion(1) then exit;
        CX_A:=GET1B;//codigo de mensaje
        AgregarMensaje('·'+JugadorCl.MensajeResultado(CX_A,0,0));
        //Sonidos asociados
        case CX_A of
          i_BebesPocima,i_CalmasSed:CX_2b:=snBeber;
          i_CalmasHambre:CX_2b:=snComer;
          i_EchasElVeneno:CX_2b:=snEcharVeneno;
          i_CreasteNuevoClan,i_HasMejoradoLaDefensaDelCastillo:CX_2b:=snCuerno;
          i_EsInvulnerableAConjuros,i_falloElConjuro,i_TieneGemaAntiMaldicion,
            i_NoPuedesVampirearle,i_EstaProtegidoContraHechizosMalvados:CX_2b:=snError;
          i_MaldicionSobreObjeto:begin
            CX_2b:=snNinguno;
            JugadorCl.CalcularModDefensa;//Actualizar por maldicion.
          end;
          i_EstasBajoEfectodeJuglaria,i_DialogoNPJqueCompro,i_DialogoNPJqueVendio:CX_2b:=snNinguno;
        else
          begin
            CX_2b:=snNinguno;
            if CX_A<i_InicioMensajesExitoDeConjuro then
              SonidoIntensidad(snError,-1000);
          end;
        end;
        if CX_2b<>snNinguno then//si no es frecuente que emita un sonido
          SonidoIntensidad(CX_2b,-random($FF));
      end;
      'A','B'://Actualización de banderas de Auras (8 banderas)
      begin
        if FaltaInformacion(3) then exit;
        cx_2b:=GET2B;
        if chr(MetaComando)='A' then
          SActualizarBanderas(cx_2b,GET1B,$FFFFFF00)
        else
          SActualizarBanderas(cx_2b,GET1B shl 8,$FFFF00FF)
      end;
      'a'://Actualización de banderas de Auras (16 banderas)
      begin
        if FaltaInformacion(4) then exit;
        cx_2b:=GET2B;
        SActualizarBanderas(cx_2b,GET2B,$FFFF0000);
      end;
      'k'://Actualización de TODAS las banderas del mapa
      begin
        if FaltaInformacion(4) then exit;
        MapaEspejo.SActualizarBanderasMapa(GET4B,true,false);
      end;
      'K'://Actualización de TODAS las banderas del mapa, con sonidos
      begin
        if FaltaInformacion(4) then exit;
        MapaEspejo.SActualizarBanderasMapa(GET4B,true,true);
      end;
{      ''://Actualización de UNA bandera del mapa
      begin//(and $20)=limpiar o fijar bandera # (and $1F)
        if FaltaInformacion(1) then exit;
        CX_a:=get1b;
        if CX_a<64 then
          MapaEspejo.SActualizarBanderasMapa(cx_a,false)
        else
          MostrarMensajeError;
      end;}
      'I'://Informacion del servidor
      begin
        if FaltaInformacion(1) then exit;
        metaComando:=GET1B;
        case char(metaComando) of
          'M':begin
            if FaltaInformacion(2) then exit;
            cx_2b:=get2b;
            MapaEspejo.SMuerteJugador(cx_2b{codigo casilla del asesino});
          end;
          'K':begin//creo un nuevo clan
            if FaltaInformacion(2) then exit;
            CX_A:=get1b;//codigoclan
            if CX_A<=maxClanesJugadores then
              with ClanJugadores[CX_A] do
              begin
                CX_B:=get1b;
                if FaltaInformacion(CX_B) then exit;
                Lider:=GET_Cadena16(CX_B);
                Nombre:='Clan de '+Lider;
                PendonClan.color0:=$80000000;
                PendonClan.color1:=PendonClan.color0;
                colorClan:=0;
                Sonido(snClan);
                AgregarMensaje('!¡'+Lider+' ha fundado un nuevo clan!');
              end
            else
              MostrarMensajeError;
          end;
          'Q':begin//castillo conquistado
            if FaltaInformacion(1) then exit;
            CX_A:=get1b;//codigoclan
            if CX_A<=maxClanesJugadores then
            begin
              MapaEspejo.castillo.clan:=CX_A;
              if (JugadorCl.Clan<>MapaEspejo.castillo.clan) then
                AgregarMensaje('Este territorio fue conquistado por: '+ClanJugadores[CX_A].nombre);
            end
          end;
          'N':begin//Cambio Nombre del clan
            if FaltaInformacion(2) then exit;
            CX_A:=get1b;//codigoclan
            CX_B:=get1b;//longitud del nombre
            if CX_A<=maxClanesJugadores then
            begin
              if FaltaInformacion(CX_B) then exit;
              with ClanJugadores[CX_A] do
              begin
                CX_Cadena127:=GET_Cadena127(CX_B);
                AgregarMensaje('El clan: '+nombre+' ahora se llama: '+CX_Cadena127);
                nombre:=CX_Cadena127;
              end;
            end
            else
              MostrarMensajeError;
          end;
          '(':begin//cambio el color del clan
            if FaltaInformacion(2) then exit;
            CX_A:=get1b;//codigoclan
            if CX_A<=maxClanesJugadores then
              with ClanJugadores[CX_A] do
              begin
                ColorClan:=get1b;
                if ColorClan=255 then
                  AgregarMensaje('El clan '+nombre+' está disuelto.')
                else
                  AgregarMensaje('El clan '+nombre+' cambió su color.')
              end
            else
              MostrarMensajeError;
          end;
          'P':begin//Cambio el Pendón (Estandarte) del clan
            if FaltaInformacion(9) then exit;
            CX_A:=get1b;//codigoclan
            if CX_A<=maxClanesJugadores then
              with ClanJugadores[CX_A] do
              begin
                PendonClan.color0:=get4b;
                PendonClan.color1:=get4b;
                if (PendonClan.color0 or PendonClan.color1)<>0 then
                  AgregarMensaje('El clan '+nombre+' cambió de estandarte.')
                else
                  AgregarMensaje('El clan '+nombre+' retiró su estandarte.')
              end
            else
              MostrarMensajeError;
          end;
          #200:begin//enlistarse en un clan
            if FaltaInformacion(3) then exit;
            CX_A:=GET1B;//nuevo clan
            CX_2b:=GET2B;//codigo de jugador
            if CX_2b<=MaxJugadores then
              with Jugador[CX_2b] do
              begin
                if (CX_A>MaxClanesJugadores) then
                begin
                  if (clan<=MaxClanesJugadores) then
                    if (CX_2b=jugadorCl.codigo) then
                    begin
                      agregarMensaje('!Dejaste el clan "'+ClanJugadores[clan].nombre+'"');
                      Sonido(snTermina);
                    end
                    else
                      agregarMensaje('!'+Jugador[CX_2b].nombreAvatar+' dejó el clan "'+ClanJugadores[clan].nombre+'"');
                end
                else
                begin
                  Sonido(snClan);
                  if CX_2b=jugadorCl.codigo then
                    agregarMensaje('!Ingresas al clan "'+ClanJugadores[CX_A].nombre+'"')
                  else
                    agregarMensaje('!'+Jugador[CX_2b].nombreAvatar+' ingreso al clan "'+ClanJugadores[CX_A].nombre+'"');
                end;
                clan:=CX_A;
              end;
          end;
          'k':begin//lista de clanes activos
            if FaltaInformacion(1) then exit;
            CX_4B:=GET1B;
            for i:=0 to CX_4B-1 do // extraer clanes
            begin
              if FaltaInformacion(11) then exit;
              CX_A:=GET1B;
              if CX_A<=maxClanesJugadores then
                with ClanJugadores[CX_A] do
                begin
                  pendonClan.color0:=GET4B;
                  pendonClan.color1:=GET4B;
                  colorClan:=GET1B;
                  CX_C:=GET1B;
                  if FaltaInformacion(CX_C) then exit;
                  nombre:=GET_Cadena127(CX_C);
                end
              else
                MostrarMensajeError
            end;
          end;
          #202:begin//ver arcas del castillo
            if FaltaInformacion(4) then exit;
            CX_4B:=GET4B;
            AgregarMensaje('Tesoro en arcas del castillo: '+DineroAStr(CX_4B));
          end;
          #203:begin//ver mejoras del castillo
            if FaltaInformacion(4) then exit;
            CX_4B:=GET4B;
            MapaEspejo.DescribirClanDuenno(CX_4B);
          end;
          'T':begin
            if FaltaInformacion(2) then exit;
            CX_2B:=GET2B;
            ControlChat.setMensaje(nil,'Hora: '+TicksDelServidorAHoraEnCadena(CX_2B),clEsmeralda);
          end;
          '^':with JugadorCl do//Subio de nivel
          begin
            if FaltaInformacion(5) then exit;
            nivel:=GET1B;
            SetHabilidades(GET4B);
            CalculosNuevoNivel;
            hp:=maxHp;
            if mana>maxMana then mana:=maxMana;
            sonido(snSubioNivel);
            AgregarMensaje('+¡ Subiste al nivel '+intastr(nivel)+' !');
            controlFX.SetEfecto(0,0,fxChispasDoradas,0,0,JugadorCl);
            MostrarDatosJugador;
            //Para evitar abuso de creación de personajes:
            {$IFDEF ESPERA_PARA_CREAR_AVATAR}
            if IdDeAtomDeCreacion=0 then
              IdDeAtomDeCreacion:=GlobalFindAtom(ATOM_CREACION_AVATAR);
            GlobalDeleteAtom(IdDeAtomDeCreacion);
            IdDeAtomDeCreacion:=0;
            {$ENDIF}
          end;
          'R'://reputacion del jugador
          begin
            if FaltaInformacion(3) then exit;
            CX_2b:=GET2B;//codigo de jugador.
            CX_C:=GET1B;
            if CX_2b<=MaxJugadores then
              if JugadorCl.codigo=CX_2b then
                with JugadorCl do
                begin
                  CX_A:=comportamiento;
                  comportamiento:=CX_C;//reputacion
                  if ((byte(comportamiento) xor CX_A) and $80<>0) then
                  begin
                    if comportamiento>=0 then
                      AgregarMensaje('Recuperaste tu Honor')
                    else
                      AgregarMensaje('Acabas de perder tu Honor');
                    if (CodCategoria=ctPaladin) then
                    begin
                      CalcularNivelAtaque;
                      CalcularDefensa;
                      MostrarDatosFrecuentesJugador;
                    end
                    else
                      MostrarReputacionJugador
                  end
                  else
                    MostrarReputacionJugador;
                end
              else
                Jugador[CX_2b].comportamiento:=CX_C;//reputacion
          end;
          #0://Dar signos de vida antes de ser desconectado.
          begin
            if JugadorCl.hp=0 then
              if JugadorCl.comportamiento<=comHeroe then
              begin
                AgregarMensaje('!Tu avatar se aburrió de esperar y de estar muerto.');
                Cliente.SendTextNow('XR');//Código para resucitar con palabra del retorno
              end
              else
                Cliente.SendTextNow('e')//Código para meditar
            else
              if (JugadorCl.mana<JugadorCl.maxMana) then
                Cliente.SendTextNow('e')//Código para meditar
              else
                Cliente.SendTextNow('d')//Código para descansar
          end;
          #1://Guardando jugadores.
            ControlChat.setMensaje(nil,'Guardando información de los avatares',clEsmeralda);
          #2://Guardando mundo
            ControlChat.setMensaje(nil,'Guardando información del juego',clEsmeralda);
          #3://Continua el juego
            ControlChat.setMensaje(nil,'Información guardada, continuando el juego...',clEsmeralda);
          #8:begin
            MensajeVentanaInformacion:='El servidor te ha paralizado por enviar demasiados comandos';
            VentanaActivada:=vaInformacion;
          end;
          #9:ControlChat.setMensaje(nil,'Salir cancelado, te moviste o realizaste alguna acción.',clEsmeralda);
          #10:begin
            AgregarMensaje('!'+JugadorCl.MensajeResultado(i_NoEstasEnModoPKiller,0,0));
            JugadorCl.FlagsComunicacion:=(JugadorCl.FlagsComunicacion or flModoPKiller) xor flModoPKiller;
          end;
          #11:begin
            AgregarMensaje('!En modo AGRESIVO, para modo normal escribe: /agr');
            JugadorCl.FlagsComunicacion:=JugadorCl.FlagsComunicacion or flModoPKiller;
          end;
          #12:AgregarMensaje('+Recuperas la protección anti abuso.');
          #13:AgregarMensaje('-Pierdes la protección anti abuso por atacar a un avatar.');
          #14:begin
            if FaltaInformacion(1) then exit;
            CX_4b:=(get1b*Ritmo_Juego_Maestro) shl 1;
            ControlChat.setMensaje(nil,'Te faltan '+intastr(CX_4b)+' segundos para salir de prisión.',clRubi);
          end;
          #15:AgregarMensaje('+Ya no estás marcado como agresor verbal.');
          #16:AgregarMensaje('!El servidor no está en modo de "Comunicación Total"');
          #17:AgregarMensaje('-Estas marcado como agresor verbal.');
          #18:if (JugadorCl.comportamiento>=comGameMaster) then
                AgregarMensaje('!Tienes que usar este comando en la zona de conjuración')
              else
                AgregarMensaje('!Comando disponible sólo para Amo del Calabozo');
          #19:begin
            if FaltaInformacion(1) then exit;
            CX_A:=get1b;
            case TEstadoUsuario(CX_A) of
              euSuperGameMaster:ControlChat.setMensaje(nil,'Te asignaron el estatus de Super Game Master',clEsmeralda);
              euGameMaster:ControlChat.setMensaje(nil,'Te asignaron el estatus de Game Master',clEsmeralda);
              euAdminA:ControlChat.setMensaje(nil,'Te asignaron el estatus de Admin. clase A',clEsmeralda);
              euAdminB:ControlChat.setMensaje(nil,'Te asignaron el estatus de Admin. clase B',clEsmeralda);
              else
                ControlChat.setMensaje(nil,'Te cancelaron los privilegios de administración',clEsmeralda);
            end;
          end;
          #20:begin
            ControlChat.setMensaje(nil,'TU AVATAR FUE RESTAURADO DE POSIBLES INCOHERENCIAS',clEsmeralda);
            MostrarDatosCompletosJugador;
          end;
          #21:ControlChat.setMensaje(nil,'Tu avatar ha recuperado el honor al aceptar la prueba del infierno',clEsmeralda);
          #22:AgregarMensaje('!El avatar que buscas no ha iniciado sesión en el servidor');
          #23:begin
            if FaltaInformacion(3) then exit;
            CX_A:=get1b;
            CX_B:=get1b;
            CX_C:=get1b;
            AgregarMensaje('!El avatar que buscas está en el mapa:'+intastr(CX_A)+' x:'+intastr(CX_B)+' y:'+intastr(CX_C));
          end;
          #24:begin
            ControlChat.setMensaje(nil,'El servidor permite usar varios avatares al mismo tiempo.',clRubi);
            if ID_ATOM_SOLO_UNA_INSTANCIA<>0 then
            begin
              GlobalDeleteAtom(ID_ATOM_SOLO_UNA_INSTANCIA);
              ID_ATOM_SOLO_UNA_INSTANCIA:=0;
            end;
          end;

          'o'://Oferta de un PNJ
          begin
            if FaltaInformacion(8) then exit;
            CX_2b:=GET2B;//codigo de monstruo ofertante
            CX_4b:=GET4B;//oferta
            with JugadorCl.objetoOferta do
            begin
              id:=GET1B;
              modificador:=GET1B;
            end;
            if CX_2b<=MaxMonstruos then
            begin
              MensajeVentanaInformacion:=DineroAStr(cx_4b);
              ControlMensajes.setMensaje(Monstruo[CX_2b],'Puedo pagar '+MensajeVentanaInformacion);
              MensajeVentanaInformacion:='¿Venderás tu'+AgregarSufijoAsexuadoS(nombreObjeto(JugadorCl.objetoOferta,jugadorCl.CapacidadId))+
                ' en '+MensajeVentanaInformacion+'?';
              VentanaActivada:=vaMenuConfirmacion;
            end;
          end;
          'p'://Precio de un objeto en tienda de PNJ.
          begin
            if FaltaInformacion(8) then exit;
            CX_2b:=GET2B;//codigo de monstruo ofertante
            CX_4b:=GET4B;//oferta
            with JugadorCl.objetoOferta do
            begin
              id:=GET1B;
              modificador:=GET1B;
            end;
            if CX_2b<=MaxMonstruos then
            begin
              MensajeVentanaInformacion:=DineroAStr(cx_4b);
              ControlMensajes.setMensaje(Monstruo[CX_2b],'Te costará '+MensajeVentanaInformacion);
              MensajeVentanaInformacion:='¿Comprarás su'+AgregarSufijoAsexuadoS(nombreObjeto(JugadorCl.objetoOferta,jugadorCl.CapacidadId))
                +' en '+MensajeVentanaInformacion+'?'+#13+JugadorCl.MensajeAdvertenciaObjetoOfertaNoUsado;
              VentanaActivada:=vaMenuConfirmacion;
            end;
          end;
          '-'://No tienes suficiente dinero.
          begin
            if FaltaInformacion(6) then exit;
            CX_2b:=GET2B;//codigo de monstruo ofertante
            CX_4b:=GET4B;//oferta
            with JugadorCl.objetoOferta do
            begin
              id:=GET1B;
              modificador:=GET1B;
            end;
            if CX_2b<=MaxMonstruos then
            begin
              case random(3) of
                0:CX_Cadena:='El costo es '+DineroAStr(cx_4b)+', no te alcanza el dinero.';
                1:CX_Cadena:='El precio es '+DineroAStr(cx_4b)+', necesitas más dinero.';
                else CX_Cadena:='Necesitas '+DineroAStr(cx_4b)+', no tienes lo suficiente.';
              end;
              ControlMensajes.setMensaje(Monstruo[CX_2b],CX_Cadena);
              CX_Cadena:=JugadorCl.MensajeAdvertenciaObjetoOfertaNoUsado;
              if CX_Cadena<>'' then
                MensajeAyuda:=CX_Cadena;
            end;
          end;
          'V'://El servidor cambio de velocidad
          begin
            if FaltaInformacion(1) then exit;
            SCambiarRitmoJuego(GET1B);
          end;
          'E':begin//Cambio de especialidad.
            if FaltaInformacion(1) then exit;
            with JugadorCl do
            begin
              EspecialidadArma:=GET1B;
              NivelEspecializacion:=2;
              AgregarMensaje('!'+DescribirEspecialidad);
            end;
            ActualizarIconoMagiaEspecialidad;
          end;
          'e':begin//Cambio de nivel de especialidad.
            if FaltaInformacion(1) then exit;
            with JugadorCl do
            begin
              NivelEspecializacion:=GET1B;
              AgregarMensaje('!'+DescribirEspecialidad);
            end;
            ActualizarIconoMagiaEspecialidad;
          end;
          'c'://El jugador agrego un Conjuro a su libro de magia.
          begin
            if FaltaInformacion(1) then exit;
            CX_A:=GET1B;
            if CX_A<=31 then
            begin
              JugadorCl.Conjuros:=JugadorCl.Conjuros or (1 shl CX_A);
              Sonido(snLeerPergamino);
              AgregarMensaje('*Has memorizado el hechizo "'+NomConjuro[CX_A]+'"');
            end
            else // fallo al leer el hechizo
            begin
              Sonido(snError);
              AgregarMensaje('-Fallaste al intentar memorizar el hechizo "'+NomConjuro[CX_A and $1F]+'"');
              AgregarMensaje('·'+JugadorCl.RequerimientosParaLeerPergamino(CX_A and $1F));
            end;
          end;
          'n'://Un jugador subio de nivel
          begin
            if FaltaInformacion(3) then exit;
            CX_A:=GET1B;//nuevo nivel
            CX_2b:=GET2B;//codigo de jugador
            if CX_2b<=MaxJugadores then
              with Jugador[CX_2b] do
              begin
                nivel:=CX_A;
                SonidoXY(snSubioNivel,coordx-JugadorCl.coordX,coordy-JugadorCl.coordY);
                controlFX.SetEfecto(0,0,fxChispasDoradas,0,0,Jugador[CX_2b]);
              end
            else
              MostrarMensajeError;
          end;
          //informe de que mato el avatar
          'm':begin
            if FaltaInformacion(2) then exit;
            SMostrarMensajeMuerte(GET2B);
          end;
          'C'://Información del servidor para mostrar cuenta creada.
          begin
            if FaltaInformacion(1) then exit;
            CX_A:=get1b;
            if FaltaInformacion(CX_A) then exit;
            IdentificadorUU:=GET_Cadena16(CX_A);
            if EstadoGeneralDelJuego=ejConectando then
            begin
              EstadoGeneralDelJuego:=ejMenu;
              ActualizarElementosDePantalla;
            end;
            if EscribirFichaPersonaje then
              ShowmessageZ('Avatar creado: '+NombreLoginUU)
            else
              ShowmessageZ('Avatar creado, pero no se pudo guardar la descripción'+#13+'en tu PC. Anota tu identificador: '+IdentificadorUU);
            desconectar:=true;
          end;
          'x':begin
            MensajeVentanaInformacion:='Tu contraseña está actualizada';
            VentanaActivada:=vaInformacion;
          end;
          'X':begin
            ShowmessageZ('TU AVATAR FUE EXPULSADO DEL SERVIDOR');
            desconectar:=true;
          end;
          'I':begin//Refrescar el inventario completo ((MAX_ARTEFACTOS+9)*2 bytes).
            if FaltaInformacion((MAX_ARTEFACTOS+9) shl 1) then exit;
            for i:=0 to MAX_ARTEFACTOS+8 do
            begin
              CX_A:=get1b;
              CX_B:=get1b;
              SrefrescarObjeto(i,CX_A,CX_B,false);
            end;
            JugadorCl.CalcularModDefensa;
            MostrarDatosFrecuentesJugador;
          end;
          '0':begin//Refrescar objetos que cayeron al morir.
            if FaltaInformacion(4) then exit;
            CX_4B:=get4b;
            if CX_4B<>0 then//existe algo que refrescar
            begin
              for i:=0 to MAX_ARTEFACTOS+8 do
                if (CX_4B and (1 shl i))<>0 then
                  SrefrescarObjeto(i,0,0,false);//refresca a objeto nulo por que se cayo
              JugadorCl.CalcularModDefensa;
              MostrarDatosFrecuentesJugador;
            end;
          end;
          'B':begin//Refrescar el baul completo ((MAX_ARTEFACTOS+1)*2 bytes).
            if FaltaInformacion((MAX_ARTEFACTOS+1) shl 1) then exit;
            for i:=0 to MAX_ARTEFACTOS do
            begin
              CX_A:=get1b;
              JugadorCl.Baul[i]:=ObjetoArtefacto(CX_A,get1B);
            end;
            VentanaActivada:=vaMenuBaul;
          end;
          'b':begin
            VentanaActivada:=vaMenuBaul;
          end;
          'O':begin//Refrescar objetos de una bolsa ((MAX_ARTEFACTOS+1)*2 bytes).
            {if FaltaInformacion(1) then exit;
            CX_C:=get1b;
            if FaltaInformacion((CX_C) shl 1) then exit;}
            if FaltaInformacion((MAX_ARTEFACTOS+1) shl 1) then exit;
            //for i:=0 to CX_C-1 do
            for i:=0 to MAX_ARTEFACTOS do
            begin
              CX_A:=get1b;
              MapaEspejo.BolsoDelMapa[i]:=ObjetoArtefacto(CX_A,get1B);
            end;
            {for i:=CX_C to Max_Artefactos do
              MapaEspejo.BolsoDelMapa[i]:=ObNuloMDV;}
            VentanaActivada:=vaMenuObjetos;
 {            if not G_IniciarConMusica then
            //AgregarMensaje('Llegaron '+intastr(cx_c)+' objetos');
              AgregarMensaje('Llegaron 18 objetos');}
          end;
          #216..#233:begin//Refrescar Artefacto del baul hasta MAX_ARTEFACTOS
            if FaltaInformacion(2) then exit;
            dec(MetaComando,216);
            CX_A:=get1b;
            JugadorCl.Baul[MetaComando]:=ObjetoArtefacto(CX_A,get1B);
          end;
          #234..#251:begin//Refrescar Artefacto de la bolsa del mapa hasta MAX_ARTEFACTOS
            if FaltaInformacion(2) then exit;
            dec(MetaComando,234);
            CX_A:=get1b;
            MapaEspejo.BolsoDelMapa[MetaComando]:=ObjetoArtefacto(CX_A,get1B);
            VentanaActivada:=vaMenuObjetos;
          end;
          'L':begin//lista
            if FaltaInformacion(3) then exit;
            CX_2B:=get2b;
            CX_A:=get1b;
            if FaltaInformacion(CX_A) then exit;
            CX_Cadena:=GET_Cadena255(CX_A);
            ControlChat.setMensaje(nil,'Total conectados ('+inttostr(CX_2b)+'): '+CX_Cadena,clEsmeralda);
          end;
          '*':begin//lista de miembros del clan
            if FaltaInformacion(1) then exit;
            CX_A:=get1b;
            if FaltaInformacion(CX_A) then exit;
            CX_Cadena:='Miembros del clan conectados: '+GET_Cadena255(CX_A);
            ControlChat.setMensaje(nil,CX_Cadena,clEsmeralda);
          end;
          'g':begin//lista de camaradas en el grupo (party)
            if FaltaInformacion(9) then exit;
            CX_A:=get1b;
            for i:=0 to MAX_INDICE_PARTY do//4 elementos!!
              JugadorCl.CamaradasParty[i]:=get2b;
            CX_Cadena127:=JugadorCl.DescribirParty;
            if CX_Cadena127<>'' then
            begin
              case char(CX_A) of
                'i':AgregarMensaje('·Un avatar ingresa a tu grupo de combate');
                'a':AgregarMensaje('·Agregaste un avatar a tu grupo de combate');
                'q':AgregarMensaje('·Quitaste un avatar de tu grupo de combate');
                's':AgregarMensaje('·Un avatar salió de tu grupo de combate');
              end;
              AgregarMensaje('+Grupo de combate: '+CX_Cadena127);
            end
            else
              if char(CX_A)='c' then
                AgregarMensaje('-Cancelaste tu grupo de combate')
              else
                AgregarMensaje('-No tienes un grupo de combate');
          end;
          'i':begin//te llega invitacion para formar grupo
            if FaltaInformacion(2) then exit;
            CX_2b:=get2b;
            if CX_2b<=maxJugadores then
              AgregarMensaje('+'+jugador[CX_2b].nombreAvatar+' te invita a formar parte de su grupo.');
          end;
          'G','H','"':begin//Texto
            if FaltaInformacion(1) then exit;
            CX_A:=get1b;
            if FaltaInformacion(CX_A) then exit;
            CX_Cadena127:=GET_Cadena127(CX_A);
            case char(MetaComando) of
              'H':CX_4B:=clPlata;
              '"':CX_4B:=clEsmeralda;
            else
              CX_4B:=clOro;
            end;
            ControlChat.setMensaje(nil,CX_Cadena127,CX_4B);
          end;
          '!'://Mensaje en ventana de información
          begin
            if FaltaInformacion(1) then exit;
            CX_A:=get1b;
            if FaltaInformacion(CX_A) then exit;
            CX_Cadena127:=GET_Cadena127(CX_A);
            MensajeVentanaInformacion:=CX_Cadena127;
            VentanaActivada:=vaInformacion;
            ControlChat.setMensaje(nil,CX_Cadena127,clEsmeralda);
          end;
          else
            MostrarMensajeError;
        end;
      end;
      'N'://Nuevo Jugador
      begin
        if FaltaInformacion(13) then exit;
        with Jugador[GET2B] do
        begin
          activo:=false;
          CX_A:=GET1B;//x
          CX_B:=GET1B;//y
          CX_C:=GET1B;//lowNib:dir(reccion) hiNib:acc(ion)
          codAnime:=GET1B;
          banderas:={(banderas and $FFFF0000) or }GET2B;
          nivel:=GET1B;
          codCategoria:=GET1B;
          TipoMonstruo:=(codCategoria shr 4) and $7;
          hp:=codCategoria and $80;
          codCategoria:=codCategoria and $F;
          Comportamiento:=GET1B;
          clan:=GET1B;
          fcodCara:=GET1B;
          CX_D:=get1b;
          if FaltaInformacion(CX_D) then exit;
          nombreAvatar:=GET_Cadena16(CX_D);
          CambiarAnimacionJugador(codAnime);
          codMapa:=JugadorCl.codMapa;
          MapaEspejo.SMover(codigo,CX_A,CX_B,CX_C,tmDirecto);
          controlFX.SetEfecto(CX_A,CX_B,anIngresando,0,0,nil);
        end;
      end;
      'n'://Nuevo Monstruo
      begin
        if FaltaInformacion(6) then exit;
        with Monstruo[GET2B] do
        begin
          activo:=false;
          CX_A:=GET1B;//x
          CX_B:=GET1B;//y
          CX_C:=GET1B;//ln:dir hn:acc
          codAnime:=GET1B;
          TipoMonstruo:=codAnime;
          banderas:=0;
          codMapa:=JugadorCl.codMapa;
          MapaEspejo.SMover(codigo or ccMon,CX_A,CX_B,CX_C,tmDirecto);
          controlFX.SetEfecto(CX_A,CX_B,fxExplosion2,0,0,nil);
        end;
      end;
      'F':begin
        if FaltaInformacion(3) then exit;
        with Jugador[GET2B] do//Nuevo Aspecto Jugador
          CambiarAnimacionJugador(GET1B);
      end;
      'f':begin
        if FaltaInformacion(3) then exit;
        with Monstruo[GET2B] do//Nuevo Aspecto Monstruo
        begin
          codAnime:=GET1B;
          tipoMonstruo:=codAnime;
        end;
      end;
      '_':begin//Murio un jugador / monstruo
        if FaltaInformacion(2) then exit;
        MapaEspejo.SMatarSprite(GET2B);
      end;
      '~':begin//salio un jugadorCl, salio un monstruo
        if FaltaInformacion(2) then exit;
        MapaEspejo.SDisolverSprite(GET2B);
      end;
      'X':begin//Efectos no muy frecuentes sobre el mapa
        if FaltaInformacion(1) then exit;
        CX_A:=GET1B;
        case CX_A of
          ord(fxLluvia)..ord(fxNocheLluvia):
            MapaEspejo.iniciarFxAmbiental(TFxAmbiental(CX_A),0,PendienteDeClima(CX_A));
          ord('T'):MapaEspejo.TerminarEfectoAmbiental;
          ord('R'):MapaEspejo.Lanzar_Rayo:=2;
        else
          MostrarMensajeError;
        end;
      end;
      '^'://Datos iniciales nuevo Mapa
      with MapaEspejo do
      begin
        Timer.Enabled:=false;
        if FaltaInformacion(8) then exit;
        MensajeTipTimer:='Saliendo de "'+MapaEspejo.nombreMapa+'"';
        CX_A:=GET1B;//Codigo de mapa.
        CX_B:=GET1B;//coord.x
        IngresarMapa(CX_A,CX_B,GET1B{coord.y});
        //EfectosAmbientales:
        MensajeTipTimer:='Entrando en "'+MapaEspejo.nombreMapa+'"';
        MiniMapa_DibujarSennal:=0;
        Lanzar_Rayo:=0;
        CX_A:=GET1B;//Tipo de efecto ambiental
        CX_B:=GET1B;//intensidad de efecto ambiental
        CX_C:=GET1B;//pendiente de efecto ambiental
        case TFxAmbiental(CX_A) of
          fxLluvia..fxNocheLluvia:iniciarFxAmbiental(TFxAmbiental(CX_A),CX_B,shortint(CX_C));
          else iniciarFxAmbiental(fxANinguno,CX_B,shortint(CX_C));
        end;
        if IdPanelActivado=IdPnMapa then
          PrepararPanelInfo;//Repintar el minimapa.
        //Castillo
        Castillo.clan:=get1b;
        //nombre de clan y estandarte si no está activo.
        CX_A:=get1b;//longitud del nombre, 0=está activo, no es necesario
        if (CX_A>0)and(Castillo.clan<=maxClanesJugadores) then
          with ClanJugadores[Castillo.clan] do
          begin
            if FaltaInformacion(8+CX_A) then exit;
            nombre:=GET_Cadena127(CX_A);
            pendonclan.color0:=get4b;
            pendonclan.color1:=get4b;
          end;
      end;
      'J'://Jugadores cercanos
      with MapaEspejo do
      begin
        if FaltaInformacion(1) then exit;
        CX_4B:=GET1B;
        for i:=0 to CX_4B-1 do // extraer Jugadores
        begin
          if FaltaInformacion(14) then exit;
          CX_2B:=GET2B;
          with Jugador[CX_2B] do
          begin
            activo:=false;
            CX_A:=GET1B;//x
            CX_B:=GET1B;//y
            CX_C:=GET1B;//acc/dir
            codAnime:=GET1B;
            banderas:={(banderas and $FFFF0000) or }GET2B;
            nivel:=GET1B;
            codCategoria:=GET1B;
            TipoMonstruo:=(codCategoria shr 4) and $7;
            hp:=codCategoria and $80;
            codCategoria:=codCategoria and $F;
            Comportamiento:=GET1B;
            clan:=GET1B;
            fcodCara:=GET1B;
            CX_D:=GET1B;
            if FaltaInformacion(CX_D) then exit;
            nombreAvatar:=GET_Cadena16(CX_D);
            CambiarAnimacionJugador(codAnime);
            codMapa:=JugadorCl.codMapa;
            SMover(codigo,CX_A,CX_B,CX_C,tmDirecto);
          end
        end;
      end;
      'j'://Jugadores lejanos
      with MapaEspejo do
      begin
        if FaltaInformacion(1) then exit;
        CX_4B:=GET1B;
        for i:=0 to CX_4B-1 do // extraer Jugadores
        begin
          if FaltaInformacion(11) then exit;
          CX_2B:=GET2B;
          with Jugador[CX_2B] do
          begin
            activo:=false;
            codAnime:=GET1B;
            banderas:={(banderas and $FFFF0000) or }GET2B;
            nivel:=GET1B;
            codCategoria:=GET1B;
            TipoMonstruo:=(codCategoria shr 4) and $7;
            hp:=codCategoria and $80;
            codCategoria:=codCategoria and $F;
            Comportamiento:=GET1B;
            clan:=GET1B;
            fcodCara:=GET1B;
            CX_D:=GET1B;
            if FaltaInformacion(CX_D) then exit;
            nombreAvatar:=GET_Cadena16(CX_D);
            codMapa:=JugadorCl.codMapa;
            CambiarAnimacionJugador(codAnime);
          end
        end;
      end;
      'M'://Monstruos cercanos
      with MapaEspejo do
      begin
        if FaltaInformacion(1) then exit;
        CX_4B:=GET1B;
        if FaltaInformacion(CX_4B shl 3{*8}) then exit;
        for i:=0 to CX_4B-1 do // extraer Monstruos
        begin
          CX_2B:=GET2B;
          with Monstruo[CX_2B] do
          begin
            activo:=false;
            CX_A:=GET1B;//x
            CX_B:=GET1B;//y
            CX_C:=GET1B;//acc/dir
            codAnime:=GET1B;
            banderas:=GET2B;
            tipoMonstruo:=codAnime;
            codMapa:=JugadorCl.codMapa;
            SMover(codigo or ccMon,CX_A,CX_B,CX_C,tmDirecto);
          end;
        end;
      end;
      'm'://Monstruos lejanos
      with MapaEspejo do
      begin
        if FaltaInformacion(1) then exit;
        CX_4B:=GET1B;
        if FaltaInformacion(CX_4B*5) then exit;
        for i:=0 to CX_4B-1 do // extraer Monstruos
        begin
          CX_2B:=GET2B;
          with Monstruo[CX_2B] do
          begin
            activo:=false;
            codAnime:=GET1B;
            banderas:=GET2B;
            codMapa:=JugadorCl.codMapa;
            tipoMonstruo:=codAnime;
          end;
        end;
      end;
      '#'://Datos adicionales del mapa.
      begin
        if FaltaInformacion(1) then exit;
        CX_4B:=GET1B;
        if FaltaInformacion(CX_4B shl 1 {*2}) then exit;
        for i:=0 to CX_4B-1 do//Definir Comerciantes
        begin
          CX_2b:=GET2B;
          if CX_2b<=MaxMonstruos then
          with Monstruo[CX_2b] do
          begin
            comportamiento:=comComerciante;
            Duenno:=i;
          end;
        end;
      end;
      '&'://Bolsas del mapa.
      begin
        if FaltaInformacion(1) then exit;
        CX_4B:=GET1B;
        if FaltaInformacion(CX_4B*3) then exit;
        for i:=0 to CX_4B-1 do
        begin
          CX_A:=GET1B;
          CX_B:=GET1B;
          MapaEspejo.SColocarBolsa(CX_A,CX_B,TTipoBolsa(GET1B));
        end;
      end;
      '!'://Fin de transmisión de datos del nuevo mapa
      begin
        TimerTimer(nil);//Para que muestre la pantalla inmediatamente
        Timer.Enabled:=true;
      end;
      '|'://Para inicio de conexión o creacion del personaje.
      begin
        if FaltaInformacion(6) then exit;
        CodigoCNXJugador:=GET2B;
        TratarIniciarSesion(GET4B);
        break;//Fin de lectura.
      end;
      '@'://Recibir datos iniciales del personaje.
      begin
        if FaltaInformacion(34+BYTES_INVENTARIO) then exit;
        JugadorCL:=TJugador(Jugador[CodigoCNXJugador]);
        with JugadorCl do
        begin
          CX_A:=GET1B;//Ritmo de juego y algunos flags
          SCambiarRitmoJuego(CX_A and $F);
          CX_C:=byte(CX_A and FS_ModoDePruebas);
          HP:=GET2B;
          Mana:=GET1B;
          comida:=GET1B;
          dir:=GET1B;
          codAnime:=GET1B;
          Banderas:=GET3B;
          codCategoria:=GET1B;//10B
          TipoMonstruo:=(codCategoria shr 4) and $7;
          codCategoria:=codCategoria and $F;
          Pericias:=GET2B;
          nivel:=GET1B;
          Experiencia:=GET2B;
          conjuros:=GET4B;
          EspecialidadArma:=GET1B;//20B
          NivelEspecializacion:=GET1B;
          fCodCara:=GET1B;
          comportamiento:=GET1B;
          Clan:=GET1B;
          Dinero:=GET4B;
          SetHabilidades(GET4B);//32B
          CadenaAInventario(GET_Cadena127(BYTES_INVENTARIO));
          CX_D:=GET1b;//33B
          if FaltaInformacion(CX_D) then exit;
          nombreAvatar:=GET_Cadena16(CX_D);
        end;
        IniciarJuego;
        if bytebool(CX_C)<>G_ServidorEnModoDePruebas then
        begin
          G_ServidorEnModoDePruebas:=bytebool(CX_C);
          //CambiarCanalesDeColores(GrafTablero.SuperficieTerreno);
        end;
        if G_ServidorEnModoDePruebas then
        begin
          MensajeVentanaInformacion:='Servidor en modo de Pruebas';
          VentanaActivada:=vaInformacion;
        end;
      end;
      'E'://errores, sin control de buffer desde este punto.
      begin
        if EstadoGeneralDelJuego=ejConectando then
        begin
          EstadoGeneralDelJuego:=ejMenu;
          ActualizarElementosDePantalla;
        end;
        desconectar:=true;
        case char(GET1B) of
          'S':ShowmessageZ('El servidor está lleno');
          'I':ShowmessageZ('Tu IP está bloqueado en el servidor');
          'C':ShowmessageZ('Contraseña incorrecta');
          '0':ShowmessageZ('El avatar es obsoleto o está dañado');
          'N':ShowmessageZ('El avatar no existe en el servidor');
          'Y':ShowmessageZ('Otra persona está usando el Avatar');
          'D':ShowmessageZ('Creación de Avatar denegado');
          'O':ShowmessageZ('El nombre que escogiste ya está siendo usado');
          'B':ShowmessageZ('El avatar está marcado como "EXPULSADO"');
          'M':ShowmessageZ('El servidor está en modo de Pruebas, no puedes crear un Avatar');
          'V':ShowmessageZ('Necesitas la versión: '+GetVersionCliente(get1b));
          else MostrarMensajeError;
        end;
      end;
      else
        MostrarMensajeError
    end;//while para decodificar flujo de mensajes.
    if desconectar then break;
  end;
  socket.BufferRecepcion:='';
  if desconectar then ClientSocket.close;
end;

end.

