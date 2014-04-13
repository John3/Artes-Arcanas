(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit MundoEspejo;
//Del cliente, usa a Tablero y Graficos

interface
uses Windows,Graphics,DirectDraw,Objetos,Demonios,Tablero,Graficos,graficador,umensajes,Sprites;
const
  ft_Nodibujar=$20;
  ft_PisoPuente=$40;
  msk_Terreno_tiles=$1F;
  Rectangulo16:Trect=(left:0;top:0;right:16;bottom:16);
type
  TTipoMovimiento=(tmInterpolado,tmDirecto,tmDirectoConEfecto);
  TMapaEspejo=Class(TTablero)
  private
    { Private declarations }
    Grafico:TGraficosMapa;
    FMapaTiles:PMapaTiles;
    procedure RealizarEfectosAmbientales(EstaBajoTecho:boolean);
    function GetMonstruoCasilla(x,y:byte):TmonstruoS;
  public
    { Public declarations }
    intensidadFxAmbiental:integer;
    pendienteEfectoAmbiental:shortint;
    tipoFxAmbiental:TFxAmbiental;
    SubTipoEfecto:TFxNocturno;
    Lanzar_Rayo:byte;//0=sin rayo
    PuedeEnviarComando:boolean;//para evitar enviar demasiados comandos
    BolsoDelMapa:TInventarioArtefactos;
    destructor Destroy; override;
    procedure TimerAmbiental;
    constructor create;
    function getTerrenoXY(x,y:integer):integer;
    function getTerrenoXYParaSonido(x,y:integer):integer;
    function getTerrenoYFlagsXY(x,y:integer):integer;
    function EsFronteraCamino(x,y:integer):boolean;
    function GetMonstruoXY(x,y:byte):TmonstruoS;
    procedure iniciarFxAmbiental(EventoAmbiental:TFxAmbiental;intensidad:byte;pendiente:shortint);
    procedure terminarEfectoAmbiental;
    procedure inicializar;
    procedure DibujarPergamino(SuperficieDD:IDirectDrawSurface7;x,y:byte);
    procedure draw;
    procedure ControlSensoresJugador;
    procedure SincronizarYfinTurno;
    procedure IngresarMapa(codigoMapa,x,y:byte);
    function NombreMonstruo(RMonstruo:TmonstruoS;MostrarDialogo:boolean):string;
//Comandos del jugador:
    procedure JSoltarObjetoElegido(cantidad:byte);
    procedure JRecogerObjetoElegido(IndArtefacto,cantidad:byte);
    procedure JMover(direccion:TdireccionMonstruo);
    procedure JMoverXY(x,y:integer);//coordenadas de pixeles de pantalla
    procedure JMoverXY_Minimapa(x,y:byte);//coordenadas de pixeles de minimapa
    procedure JMoverXY_Mapa(x,y:byte);//coordenadas de mapa    
    function JugadorPuedeMoverse():boolean;
    procedure JDetenerAcciones;
    procedure JAtacar(ModoDefensivo:boolean);
    procedure JLanzarConjuro(SinObjetivo,AtaqueContinuo:bytebool);
    procedure JAlzarObjeto;
    procedure JRevisarObjetos;
    procedure JGuardarEnBaul(IndArtefacto,cantidad:byte);
    procedure JSacarDeBaul(IndArtefacto,cantidad:byte);
    procedure JDescansar;
    procedure JMeditar;
    procedure JVender(IndArtefacto,cantidad:byte;Comprador:TmonstruoS);
    procedure JMostrarMenuComercio(Vendedor:TmonstruoS);
    procedure JMostrarJugadoresMapa;
    procedure JMostrarClanesMapa;
    procedure JMostrarEstadoDelCastillo;
    procedure JMostrarPosicionActual;
//Comandos del servidor:
    procedure SMover(codigoCasilla:word;X,Y,Ndir:Byte;Movimiento:TTipoMovimiento);
    procedure SMuerteJugador(codigoAsesino:word);
    procedure SMatarSprite(codigo:word);
    procedure SDisolverSprite(codigoCasilla:word);
    procedure SColocarBolsa(posx,posy:byte;tipo:TtipoBolsa);
    procedure SApagarFogata(posx,posy:byte);
    procedure SColocarCadaver(posx,posy:byte;TipoCadaver:TtipoBolsa);
    function SEliminarBolsa(posx,posy:byte):TTipoBolsa;
    procedure SEfectosConjuro(Conjuro,posx,posy:byte);
    procedure SActualizarBanderasMapa(banderas:integer;todas,sonido:boolean);
    function DescribirPosicion(posx,posy:integer):string;//coordenadas de pixeles de minimapa
    procedure DescribirClanDuenno(banderasCastillo:integer);
    function DeterminarPrefijoDeMusicaAdecuada:char;
    function getCodigoSensorXY(var pos_x,pos_y:integer):byte;
    function DescribirSensor(codigo:byte):string;
  end;
var
   ControlMensajes:TControlMensajes;
   ControlChat:TControlChat;
   controlFX:TControlfx;
   JugadorCl:Tjugador;//Referencia.
   MapaEspejo:TMapaEspejo;
   Monstruo:array[0..MaxMonstruos] of TmonstruoS;
   Jugador:array[0..maxJugadores] of Tjugador;
   ClanJugadores:array[0..maxClanesJugadores] of TClanJugadores;
   conta_Universal:integer;
   sincro_conta_Universal:integer;
   fast_sincro_conta_Universal:integer;
   Ritmo_Juego_Maestro,
   Interpolador_MaestroX,Interpolador_MaestroY,Paso_InterpoladoX,Paso_InterpoladoY:integer;
   //Configuraciones:
   Graficos_Transparentes,
   Mostrar_Nombres_Sprites,
   Mostrar_rostros,
   Texto_Modalidad_Chat,
   Visores_Vida_Mana,
   Zoom_Pantalla:bytebool;
   procedure CrearElMundoEspejo;
   procedure DestruirElMundoEspejo;
//Utilitarios
   function GetMonstruoCodigoCasilla(CodigoCasilla:word):TmonstruoS;
//------------------------------------------------------------------------------
//Comandos del Jugador independientes de datos del tablero espejo:
   procedure JIraTenax;
   procedure JZoomorfismo;
   procedure JOcultarse;
   procedure JPalabraDelRetorno;
   procedure JIntercambiarObjetos(anterior,actual:byte);
   procedure JSacarDinero(cantidad:integer);
   procedure JRetirarDineroCastillo(cantidad:integer);
   procedure JDepositarDineroCastillo(cantidad:integer);
   procedure JEnviarOrden(tipoOrden:char);
//Comandos del Servidor independientes de datos del tablero espejo:
   procedure SCambiarDireccion(codigoCasilla:word;Ndir:byte);
   procedure SCambiarAccion(codigoCasilla:word;NAccion:byte);
   procedure SResucitarJugador;
   procedure SFuerzagigante;
   procedure SFuerzaNormal;
   procedure SRestitucion;
   procedure SSanacion;
   procedure SQuitarVeneno;
   procedure SAcelerar;
   procedure SQuitarAcelerar;
   procedure SArmadura;
   procedure SQuitarArmadura;
   procedure SProteccion;
   procedure SQuitarProteccion;
   procedure SInvisibilidad;
   procedure SInvisibilidadOcultarse;
   procedure SQuitarInvisibilidad;
   procedure SVisionVerdadera;
   procedure SQuitarVisionVerdadera;
   procedure SActivarIraTenax;
   procedure SQuitarIraTenax;
   procedure SParalisis;
   procedure SQuitarParalisis;
   procedure SEnvenenar;
   procedure SQuitarVendas;
   procedure SRealizarVendaje;
   procedure SCongelar;
   procedure SQuitarCongelar;
   procedure SActivarZoomorfismo;
   procedure SQuitarZoomorfismo;
   procedure SActualizarBanderas(codigoCasilla:word;banderasAuras,BanderasNoActualizadas:longWord);
   procedure SMostrarMensajeMuerte(codigoCasilla:word);
   procedure SAturdir;
   procedure SQuitarAturdir;
   procedure SCambiarRitmoJuego(ritmoJuego:byte);
   procedure SActualizarNroInterpolados;
//De Interface
   procedure IControlMenusPorMovimiento(CerrarTodosLosMenus:boolean);

implementation
uses juego,sonidos,globales,Ucliente;

const
  ME_NO_TIENES_ESA_CANTIDAD='No tienes esa cantidad';//cantidad de dinero u objetos
  ME_NO_PUEDES_GUARDAR_BAUL_DENTRO_OTRO_BAUL='No puedes guardar el baúl mágico en otro baúl mágico';
var
  Paleta_Pergamino_Mapa:array[0..191] of word;
  Nro_Frames_Interpolados,Frame_Actualizacion_Posicion:integer;
  //Texto de Sensores
  TextoSensor:TListaTextoSensor;
  TextoComerciante:TListaTextoComerciante;

function getPedazoCadenaBarra(const cadenaBarra:String;pedazo:byte):string;
var i,nroBarras:integer;
begin
  nroBarras:=0;
  result:='';
  for i:=1 to length(cadenaBarra) do
    if cadenaBarra[i]='\' then
    begin
      inc(nroBarras);
      if nroBarras>pedazo then exit;
    end
    else
      if nroBarras=pedazo then result:=result+cadenaBarra[i];
end;

function LeerPaletaPergaminoMapa:boolean;
var f:file;
begin
  {$I-}
  assignFile(f,Ruta_Aplicacion+CrptGDD+'Mapa.pal');
  reset(f,1);
  blockread(f,Paleta_Pergamino_Mapa,sizeOf(Paleta_Pergamino_Mapa));
  closefile(f);
  {$I+}
  result:=IOresult=0;
end;

//****************************************************************************************
//  MundoEspejo
//****************************************************************************************
procedure CrearElMundoEspejo;
var i:integer;
begin
  for i:=0 to MaxMonstruos do
    Monstruo[i]:=TmonstruoS.create(i);
  for i:=0 to MaxJugadores do
    Jugador[i]:=Tjugador.create(i);
  for i:=0 to MaxClanesJugadores do
    ClanJugadores[i]:=TClanJugadores.create(i);
  controlChat:=TcontrolChat.create;
  controlMensajes:=TcontrolMensajes.create;
  controlFX:=TcontrolFx.create;
  MapaEspejo:=TmapaEspejo.create;
  LeerPaletaPergaminoMapa;
end;

procedure DestruirElMundoEspejo;
var i:integer;
begin
  MapaEspejo.free;
  controlFX.free;
  controlMensajes.free;
  controlChat.free;
  for i:=MaxClanesJugadores downto 0 do
    ClanJugadores[i].free;
  for i:=MaxJugadores downto 0 do
    Jugador[i].free;
  for i:=MaxMonstruos downto 0 do
    Monstruo[i].free;
end;

//****************************************************************************************
//  TMapaEspejo
//****************************************************************************************

destructor TMapaEspejo.Destroy;
var i:integer;
begin
  //Destruir Mapa de tiles:
  for i:=MaxMapaAreaExt downto 0 do
    freeMem(FmapaTiles[i]);
  freeMem(FmapaTiles);
  inherited destroy;
end;

constructor TMapaEspejo.create;
var i:integer;
begin
  inherited create(0);
  //Crear Mapa de tiles:
  getmem(FMapaTiles,sizeof(TMapaTiles));
  for i:=0 to MaxMapaAreaExt do
    getmem(FMapaTiles[i],sizeof(TLineaMapaTiles));
end;

procedure TMapaEspejo.inicializar;
var i,j,codigoDelGrafico:integer;
    k,x,y,p_x,p_y:integer;
    reflejado,OcultaAlgunasCasillas:bytebool;
begin
  //Agregar informacion adicional a estas casillas como visibilidad.
  for k:=0 to n_graficos-1 do
  begin
    codigoDelGrafico:=grafico[k].codigoFlags and MskCodigoGrafico;
    if codigoDelGrafico<=MAX_OBJETOS_GRAFICOS then
    with InfGra[codigoDelGrafico] do
    begin
      x:=grafico[k].posx-4;
      y:=grafico[k].posy-aliny;
      reflejado:=bytebool(grafico[k].flagsGrafico and fgfx_Espejo);
      OcultaAlgunasCasillas:=(grafico[k].flagsGrafico and (fgfx_Levitacion or fgfx_TransparenteNatural))=0;
      if tipo>=tg_Piso then
        for i:=0 to 7 do
        begin
          //  Las casillas ocultas están desplazadas para coincidir mejor
          //con las áreas cubiertas por elementos del tipo "Piso" los que
          //son dibujados primero.
          if reflejado then
            p_x:=x+8-i//no es +7 por el tipo de alineacion desplazada
          else
            p_x:=x+i;
          for j:=0 to 7 do
          begin
            p_y:=y+j;
            if enlimites(p_x,p_y) then
              if bytebool(casillaOcupada[j] and mascarB[i]) then
                FMapaTiles[p_x,P_y]:=FMapaTiles[p_x,p_y] or ft_PisoPuente;
          end;
          if OcultaAlgunasCasillas then
            for j:=0 to 7 do
            begin
              p_y:=y+j;
              if enlimites_MenosFronteras(p_x,p_y) then
                if bytebool(casillaOculta[j] and mascarB[i]) then
                  FMapaTiles[p_x,P_y]:=FMapaTiles[p_x,p_y] or ft_Nodibujar;
            end
        end
    end;//with
  end;
  //Otros.
  intensidadFxAmbiental:=0;
  tipoFxAmbiental:=FxANinguno;
  pendienteEfectoAmbiental:=0;
end;

procedure TMapaEspejo.SincronizarYfinTurno;
var n:integer;
  procedure EnviarMensajeEnBuffer;
  var colorMensaje:Tcolor;
  begin
   with Jform do
    if TextoDelJugadorAlServidor<>'' then
    begin
      TimerTextoDelJugador:=TIMER_TEXTO_JUGADOR;
      Cliente.SendTextNow(TipoTextoDelJugadorAlServidor+char(length(TextoDelJugadorAlServidor))+TextoDelJugadorAlServidor);
      if TipoTextoDelJugadorAlServidor='H' then
        ControlMensajes.setMensaje(jugadorCl,TextoDelJugadorAlServidor);
      case TipoTextoDelJugadorAlServidor of
        'T':colorMensaje:=ClPlata;
        'G':colorMensaje:=ClBronceClaro;
        else colorMensaje:=clblanco;
      end;
      ControlChat.setMensaje(JugadorCl,TextoDelJugadorAlServidor,colorMensaje);
      TextoDelJugadorAlServidor:='';
    end;
  end;
  procedure ProcesarFinTurno(Monstruo:Tmonstruos);
  begin
    with monstruo do
    begin
      if (accion>=aaAtacando1) and ((ritmoDeVida and Msk_AniSincro)=0) or
        ((accion=aaCaminando) and (control_movimiento=0))then
          accion:=aaParado;
      if control_movimiento>0 then
      begin
        dec(control_movimiento{Interpolador_movimiento})
      end
      else
      begin
        coordx_ant:=coordx;
        coordy_ant:=coordy;
      end;
      if (abs(JugadorCl.coordx-coordx)>MAXVISIONX)
        or (abs(JugadorCl.coordy-coordy)>MAXVISIONY) then
        begin
          if monstruo=JugadorCL.apuntado then JugadorCL.apuntado:=nil;
          if mapapos[coordx,coordy].monRec and fl_cod=codigo then
            mapapos[coordx,coordy].monRec:=ccVac;
          activo:=false;
        end;
    end;
  end;
begin
  if Conta_Universal and Nro_Frames_Interpolados=0 then TimerAmbiental;
  for n:=0 to MaxMonstruos do
    if monstruo[n].activo then
      ProcesarFinTurno(monstruo[n]);
  for n:=0 to MaxJugadores do
    if jugador[n].activo then
      ProcesarFinTurno(jugador[n]);
  if (conta_Universal and Nro_Frames_Interpolados)=0 then
  begin
  //Dependiente del servidor:
    JugadorCl.TickTiempoDeComandos;
    PuedeEnviarComando:=true;
  end;
  if (conta_Universal and Desplazador_AniSincro)=0 then
  //Independiente del # de FPS:
  begin
    //Control de mensajes en buffer
    with Jform do
      if TimerTextoDelJugador<=0 then
        EnviarMensajeEnBuffer
      else
        dec(TimerTextoDelJugador);
    //Control del area de mensajes.
    with Jform.LbMensaje do
      if Tag>0 then
      begin
        Tag:=Tag-1;
        if Tag=0 then
          caption:='';
      end;
    //Control de chat
    ControlMensajes.tick;
    //Control de aviso en mini mapa
    if Jform.MiniMapa_DibujarSennal>0 then
    begin
      dec(Jform.MiniMapa_DibujarSennal);
      if Jform.MiniMapa_DibujarSennal=0 then
        JForm.actualizarMiniMapa(true);
    end
  end;
  Controlfx.tick;//Efectos
  if conta_Universal>=TICKS_POR_DIA then
    conta_Universal:=0
  else
    inc(conta_Universal);
  sincro_conta_Universal:=conta_Universal shr Desplazador_AniSincro;
  fast_sincro_conta_Universal:=conta_Universal shr (Desplazador_AniSincro-1);
end;

procedure TMapaEspejo.IngresarMapa(codigoMapa,x,y:byte);
//Control de sincronización de interfaz.
var i:integer;
begin
  DetenerSonidos;//Detener sonido de lluvia
  //recuperar mapa inicializa todo el mapa, incluyendo bolsas
  if not RecuperarMapa(codigoMapa,@TextoSensor,@TextoComerciante,FMapaTiles,@grafico) then
    showmessagez('No fue posible abrir el mapa #'+intastr(codigoMapa)+'. El mapa está dañado o es obsoleto.');
  fCodMapa:=codigoMapa;//Solo para el cliente
  Inicializar;
  controlFx.Inicializar;
  ControlMensajes.InicializarMensajesMonstruos;
  DibujarPergamino(Jform.Pergamino_mapa,x,y);
  //Desactivar a todos los jugadores y monstruos
  for i:=0 to MaxMonstruos do
    with Monstruo[i] do
    begin
      activo:=false;
      comportamiento:=0;//inicial, puede cambiar a comerciante.
      duenno:=ccVac;//Si es comerciante indicara el comercio relacionado.
    end;
  for i:=0 to MaxJugadores do
    with Jugador[i] do
      if codigo<>JugadorCl.codigo then
      begin
        activo:=false;
        //nombreAvatar:='';
        banderas:=0;
      end;
  //Cambiar musica de fondo si es conveniente.
  if JForm.MusicaActivada then
    JForm.RequerimientoDeCambiarMusicaPendiente:=true;
  //Colocar el jugador
  with JugadorCl do
  begin
    codMapa:=codigoMapa;
    SMover(codigo,x,y,dir,tmDirecto);
  end;
  PuedeEnviarComando:=true;//del jugador
  //Definir tipo de efecto nocturno:
  if JugadorCl.TieneInfravision then
    if JugadorCl.TipoMonstruo=rzDrow then
      SubTipoEfecto:=FxNColores
    else
      SubTipoEfecto:=FxNElfo
  else
    if JugadorCl.TipoMonstruo=rzOrco then
      SubTipoEfecto:=FxNColores
    else
      SubTipoEfecto:=FxNHumano;
end;


{JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
                              COMANDOS DEL JUGADOR
JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ}
procedure TMapaEspejo.JDetenerAcciones;
begin
  if JForm.VentanaActivada<>vaNinguna then exit;
  if not PuedeEnviarComando then exit else PuedeEnviarComando:=false;
  Cliente.SendTextNow('XX');
end;

function TMapaEspejo.JugadorPuedeMoverse():boolean;
begin
  result:=false;
  if not PuedeEnviarComando then exit;
  if longbool(JugadorCl.Banderas and bnparalisis) then
  begin
    Jform.agregarMensaje(cmEstasParalizado);
  end
  else
  begin
    PuedeEnviarComando:=false;
    result:=true;
  end;
end;

procedure TMapaEspejo.JMover(direccion:TdireccionMonstruo);
begin
  if not JugadorPuedeMoverse() then exit;
  if bytebool(direccion and mskMovimientoContinuo) then
    Cliente.SendTextNow('M'+B2aStr(JugadorCl.ObtenerPosicionTopeWordParaCorrer(direccion and mskDirecciones)))
  else
  begin
    Cliente.SendTextNow('m'+char(direccion and mskDirecciones));
  end;
end;

procedure TMapaEspejo.JMoverXY(x,y:integer);
const NivelDeAlcance=4;
var deltax,deltay:integer;
begin
  if not JugadorPuedeMoverse() then exit;
  x:=(X div ancho_tile)-13+JugadorCl.coordx;
  y:=(Y div alto_tile)-11+JugadorCl.coordy;
  deltax:=abs(x-jugadorCl.coordx);
  deltay:=abs(y-jugadorCl.coordy);
  if (jugadorCl.coordx=0) and (x<0) and (deltay<NivelDeAlcance) then
    Cliente.SendTextNow('m'+char(dsOeste))
  else
    if (jugadorCl.coordx=MaxMapaAreaExt) and (x>MaxMapaAreaExt) and (deltay<NivelDeAlcance) then
      Cliente.SendTextNow('m'+char(dsEste))
    else
      if (jugadorCl.coordy=0) and (y<0) and (deltax<NivelDeAlcance) then
        Cliente.SendTextNow('m'+char(dsNorte))
      else
        if (jugadorCl.coordy=MaxMapaAreaExt) and (y>MaxMapaAreaExt) and (deltax<NivelDeAlcance) then
          Cliente.SendTextNow('m'+char(dsSud))
        else
        begin
          if x<0 then x:=0
          else
            if x>255 then x:=255;
          if y<0 then y:=0
          else
            if y>255 then y:=255;
          if (jugadorCl.apuntado<>nil) then
            if (abs(JugadorCl.apuntado.coordx-x)+abs(JugadorCl.apuntado.coordy-y)<=1) then
            begin
              //Seguir al apuntado
              Cliente.SendTextNow('W'+B2aStr(jugadorCl.apuntadoEnFormatoCasilla));
              exit;
            end;
          Cliente.SendTextNow('M'+char(x)+char(y))
        end;
end;

procedure TMapaEspejo.JMoverXY_Mapa(x,y:byte);
begin
  if not JugadorPuedeMoverse() then exit;
  Cliente.SendTextNow('M'+char(x)+char(y));
end;

procedure TMapaEspejo.JMoverXY_Minimapa(x,y:byte);
begin
  if not JugadorPuedeMoverse() then exit;
  if (banderasMapa and mskSonidosMapas)<>bmSonidosInterior then
  begin
    x:=x shl 1;
    y:=y shl 1;
  end
  else
  begin
    x:=(x and $7F)+(JugadorCl.coordx and $80);
    y:=(y and $7F)+(JugadorCl.coordy and $80);
  end;
  Cliente.SendTextNow('M'+char(x)+char(y));
end;

procedure JEnviarOrden(tipoOrden:char);
var CodigoMon:word;
begin
  if JugadorCl.usando[uAnillo].id=orAnilloDelControl then
    case tipoOrden of
      'a':begin
        if JugadorCl.apuntado<>nil then
        begin
          Cliente.SendTextNow('Oa'+B2aStr(JugadorCl.apuntadoEnFormatoCasilla));
          Jform.MensajeAyuda:='·Das la orden para atacar';
        end
        else
          Jform.MensajeAyuda:=JugadorCL.MensajeResultado(i_ApuntaPrimero,0,0);
      end;
      's':begin
        if JugadorCl.apuntado=nil then
          CodigoMon:=JugadorCl.codigo
        else
          CodigoMon:=JugadorCl.apuntadoEnFormatoCasilla;
        Cliente.SendTextNow('Os'+B2aStr(CodigoMon));
        Jform.MensajeAyuda:='·Das la orden para seguir';
      end;
      'd':begin
        Cliente.SendTextNow('Od');
        Jform.MensajeAyuda:='·Das la orden para detenerse';
      end;
    end
  else
    Jform.MensajeAyuda:=JugadorCL.MensajeResultado(i_NecesitasELAnilloDelConjurador,0,0)
end;

procedure TMapaEspejo.JAtacar(ModoDefensivo:boolean);
var id_mensaje:byte;
begin
  if not JugadorCl.PuedeRecibirComando(2) then exit;
  id_mensaje:=JugadorCl.puedeAtacar;
  if id_mensaje=i_OK then
  begin
    if ModoDefensivo then
      Cliente.SendTextNow('B'+B2aStr(JugadorCl.apuntadoEnFormatoCasilla))
    else
      Cliente.SendTextNow('A'+B2aStr(JugadorCl.apuntadoEnFormatoCasilla));
    if JugadorCl.accion<aaAtacando1 then JugadorCl.ritmoDeVida:=0;
  end
  else
    Jform.MensajeAyuda:=JugadorCl.MensajeResultado(Id_mensaje,0,0);
end;

procedure TMapaEspejo.JLanzarConjuro(SinObjetivo,AtaqueContinuo:bytebool);
var AnteriorApuntado:TmonstruoS;
    Id_mensaje:byte;
begin
  if not JugadorCl.PuedeRecibirComando(2) then exit;
  AnteriorApuntado:=JugadorCl.apuntado;
  if SinObjetivo then JugadorCl.apuntado:=nil;
  Id_mensaje:=jugadorCl.puedeLanzarConjuro;
  if Id_mensaje=i_OK then
  begin
    if (JugadorCl.ConjuroElegido<>Jform.IDConjuroElegidoEnElServidor) then//Cambiar el conjuro elegido
    begin
      Cliente.SendTextNow('j'+char(JugadorCl.ConjuroElegido));
      Jform.IDConjuroElegidoEnElServidor:=JugadorCl.ConjuroElegido;
    end;
    if InfConjuro[JugadorCl.ConjuroElegido].TipoCnjr=tcNecesitaArtefactoInventario then
      Cliente.SendTextNow('J'+char(Jform.DGObjetos.indice))
    else
      if AtaqueContinuo then
        Cliente.SendTextNow('Y'+B2aStr(JugadorCl.apuntadoEnFormatoCasilla))
      else
        Cliente.SendTextNow('y'+B2aStr(JugadorCl.apuntadoEnFormatoCasilla))
    //Jform.MensajeAyuda:=JugadorCl.MensajeResultado(200+JugadorCl.ConjuroElegido,0,0);
  end
  else
  begin
    if (Id_mensaje=i_ApuntaPrimero) and SinObjetivo then
      Jform.MensajeAyuda:='No puedes lanzar este hechizo a ti mismo'
    else
      Jform.MensajeAyuda:=JugadorCl.MensajeResultado(Id_mensaje,0,0);
  end;
  if SinObjetivo then JugadorCl.apuntado:=AnteriorApuntado;
end;

procedure TMapaEspejo.JGuardarEnBaul(IndArtefacto,cantidad:byte);
var nroElementos:integer;
begin
  with JugadorCl do
  if hp<=0 then
    Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
  else
  if longbool(Banderas and bnparalisis) then
    Jform.agregarMensaje(cmEstasParalizado)
  else
    if ((JugadorCl.clan<=maxClanesJugadores) and (castillo.clan=JugadorCl.clan) and (ObtenerRecursoAlFrente(JugadorCl)=irCastillo))
     or JugadorCl.TieneElObjeto(orBaulMagico) then
    begin
      if IndArtefacto<=MAX_ARTEFACTOS then
        if Artefacto[IndArtefacto].id>=4 then
        begin
          if Artefacto[IndArtefacto].id<>orBaulMagico then
          begin
            nroElementos:=NumeroElementos(Artefacto[IndArtefacto]);
            if (cantidad=0) then cantidad:=nroElementos;
            if (nroElementos>=cantidad) then
              Cliente.SendTextNow('KG'+char(cantidad)+char(IndArtefacto))
            else
              Jform.MensajeAyuda:=ME_NO_TIENES_ESA_CANTIDAD;
          end
          else
            Jform.MensajeAyuda:=ME_NO_PUEDES_GUARDAR_BAUL_DENTRO_OTRO_BAUL;
        end
        else
          Jform.MensajeAyuda:=MensajeResultado(i_SeleccionaObjetoInventario,0,0)
    end
    else
      JForm.VentanaActivada:=vaNinguna;
end;

procedure TMapaEspejo.JSacarDeBaul(IndArtefacto,cantidad:byte);
var nroElementos:integer;
begin
  with JugadorCl do
  if hp<=0 then
    Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
  else
  if longbool(Banderas and bnparalisis) then
    Jform.agregarMensaje(cmEstasParalizado)
  else
    if ((JugadorCl.clan<=maxClanesJugadores) and (castillo.clan=JugadorCl.clan) and (ObtenerRecursoAlFrente(JugadorCl)=irCastillo))
     or JugadorCl.TieneElObjeto(orBaulMagico) then
    begin
      if IndArtefacto<=MAX_ARTEFACTOS then
        if Baul[IndArtefacto].id>=4 then
        begin
          nroElementos:=NumeroElementos(Baul[IndArtefacto]);
          if (cantidad=0) then cantidad:=nroElementos;
          if (nroElementos>=cantidad) then
            Cliente.SendTextNow('KS'+char(cantidad)+char(IndArtefacto))
          else
            Jform.MensajeAyuda:=ME_NO_TIENES_ESA_CANTIDAD;
        end
        else
          Jform.MensajeAyuda:=MensajeResultado(i_SeleccionaObjetoBaul,0,0)
    end
    else
      JForm.VentanaActivada:=vaNinguna;
end;

procedure JIntercambiarObjetos(anterior,actual:byte);
begin
  //Ojo que van intercambiados siempre (actual por anterior en este caso)!!!
  Cliente.SendTextNow('I'+char(actual)+char(anterior));
  Jform.PintarObjetoPosicion(anterior,false);
  Jform.PintarObjetoPosicion(actual,true);
  if (actual=uAmuleto) and ((JugadorCl.Usando[uAmuleto].id=ihAmuletoVisionVerdadera) or
   ((anterior>=8) and (JugadorCl.Artefacto[anterior-8].id=ihAmuletoVisionVerdadera))) then
    JForm.MostrarDatosFrecuentesJugadorYObjetos;
end;

procedure JIraTenax;
var Id_mensaje:byte;
begin
  Id_mensaje:=JugadorCl.PuedeActivarIraTenax;
  if Id_mensaje=i_OK then
    Cliente.SendTextNow('i')
  else
    Jform.MensajeAyuda:=JugadorCl.MensajeResultado(Id_mensaje,0,0);
end;

procedure JZoomorfismo;
var Id_mensaje:byte;
begin
  Id_mensaje:=JugadorCl.PuedeActivarZoomorfismo;
  if Id_mensaje=i_OK then
    Cliente.SendTextNow('z')
  else
    Jform.MensajeAyuda:=JugadorCl.MensajeResultado(Id_mensaje,0,0);
end;

procedure JOcultarse;
var Id_mensaje:byte;
begin
  Id_mensaje:=JugadorCl.PuedeOcultarse;
  if Id_mensaje=i_OK then
  begin
    if JugadorCl.PuedeRecibirComando(8) then
      Cliente.SendTextNow('o')
  end
  else
    Jform.MensajeAyuda:=JugadorCl.MensajeResultado(Id_Mensaje,0,0);
end;

procedure JPalabraDelRetorno;
begin
  if JugadorCl.hp=0 then
    Cliente.SendTextNow('XR')
  else
    Jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_SoloParaFantasmas,0,0)
end;

procedure JRetirarDineroCastillo(cantidad:integer);
begin
  if cantidad<1 then exit;
  with JugadorCl do
  if hp<=0 then
    Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
  else
    if longbool(Banderas and bnparalisis) then
      Jform.agregarMensaje(cmEstasParalizado)
    else
      Cliente.SendTextNow('KE'+b3aStr(cantidad))
end;

procedure JDepositarDineroCastillo(cantidad:integer);
begin
  if cantidad<1 then exit;
  with JugadorCl do
  if hp<=0 then
    Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
  else
    if longbool(Banderas and bnparalisis) then
      Jform.agregarMensaje(cmEstasParalizado)
    else
      if cantidad<=dinero then
        Cliente.SendTextNow('Kg'+b3aStr(cantidad))
      else
        Jform.MensajeAyuda:=ME_NO_TIENES_ESA_CANTIDAD;
end;

procedure JSacarDinero(cantidad:integer);
begin
  if cantidad<1 then exit;
  with JugadorCl do
  if hp<=0 then
    Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
  else
    if longbool(Banderas and bnparalisis) then
      Jform.agregarMensaje(cmEstasParalizado)
    else
      if cantidad<=dinero then
        Cliente.SendTextNow('$'+b3aStr(cantidad))
      else
        Jform.MensajeAyuda:=ME_NO_TIENES_ESA_CANTIDAD;
end;

procedure TMapaEspejo.JMostrarMenuComercio(Vendedor:TmonstruoS);
begin//Mostrar menú de comercio.
  with JugadorCl do
  if hp<=0 then
    Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
  else
  if longbool(Banderas and bnparalisis) then
    Jform.agregarMensaje(cmEstasParalizado)
  else
  if (Vendedor is TjugadorS) then
    Jform.MensajeAyuda:=MensajeResultado(i_ApuntaParaComerciar,0,0)
  else
    if Vendedor.comportamiento=comComerciante then
      if abs(Vendedor.coordx-coordx)+abs(Vendedor.coordy-coordy)<=MAXIMA_DISTANCIA_COMERCIO then
        if PrepararMenuComercio(vendedor) then
        begin
          if Jform.IdGridActivado=IdGrConjuros then
            Jform.PresionarBotonGrid(IdGrInventario);
          //Enviar un mensaje al servidor para que el comerciante no se mueva.
          Cliente.SendTextNow('|'+b2aStr(Vendedor.codigo));
          jform.VentanaActivada:=vaMenuComercio//Mostrar menú de comercio
        end
        else
          Jform.MensajeAyuda:=MensajeResultado(i_NoEsUnComerciante,0,0)
      else
      begin
        //Ejecutar comando para acercarse al vendedor
        JMoverXY_Mapa(Vendedor.coordx, Vendedor.coordy);
      end
    else
      Jform.MensajeAyuda:=MensajeResultado(i_NoEsUnComerciante,0,0);
end;

procedure TMapaEspejo.JVender(IndArtefacto,cantidad:byte;Comprador:TmonstruoS);
var nroElementos:byte;
begin //Vender
  with JugadorCl do
  if hp<=0 then
    Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
  else
  if longbool(Banderas and bnparalisis) then
    Jform.agregarMensaje(cmEstasParalizado)
  else
  if Comprador=nil then
    Jform.MensajeAyuda:=MensajeResultado(i_ApuntaParaComerciar,0,0)
  else
  if abs(comprador.coordx-coordx)+abs(comprador.coordy-coordy)>MAXIMA_DISTANCIA_COMERCIO then
    ControlMensajes.setMensaje(Comprador,MensajeResultado(i_EstasMuyLejos,0,0))
  else
    if IndArtefacto<=MAX_ARTEFACTOS then
      if Artefacto[IndArtefacto].id>=8 then//no vender monedas!!
        if PrecioArtefacto(Artefacto[IndArtefacto])>0 then
          if not (Comprador is TjugadorS) then
            if Comprador.comportamiento=comComerciante then
            begin
              nroElementos:=NumeroElementos(Artefacto[IndArtefacto]);
              if (cantidad=0) then cantidad:=nroElementos;
              if (nroElementos>=cantidad) then
                Cliente.SendTextNow('V'+b2aStr(Comprador.Codigo)+char(cantidad)+char(IndArtefacto))
              else
                Jform.MensajeAyuda:=ME_NO_TIENES_ESA_CANTIDAD;
            end
            else
              Jform.MensajeAyuda:=MensajeResultado(i_NoEsUnComerciante,0,0)
          else
            Jform.MensajeAyuda:=MensajeResultado(i_ApuntaParaComerciar,0,0)
        else
          Jform.MensajeAyuda:=MensajeResultado(i_NoPuedesVenderEso,0,0)
      else
        Jform.MensajeAyuda:=MensajeResultado(i_SeleccionaObjetoInventario,0,0)
end;

procedure TMapaEspejo.JRecogerObjetoElegido(IndArtefacto,cantidad:byte);
var
    nroElementos:byte;
begin
  if Jform.IdGridActivado<>IdGrInventario then
  begin
    Jform.MensajeAyuda:=Men_Abre_El_Inventario;
    exit;
  end;
  with JugadorCl do
    if ((hp<>0) or (comportamiento>comHeroe)) then
      if longbool(Banderas and bnparalisis) then
        Jform.agregarMensaje(cmEstasParalizado)
      else
      begin
        if IndArtefacto<=MAX_ARTEFACTOS then
          if BolsoDelMapa[IndArtefacto].id>=4 then
          begin
            nroElementos:=NumeroElementos(BolsoDelMapa[IndArtefacto]);
            if (cantidad=0)or(cantidad>nroElementos) then cantidad:=nroElementos;
            Cliente.SendTextNow('r'+char(cantidad)+char(IndArtefacto))
          end
          else
            Jform.MensajeAyuda:=MensajeResultado(i_SeleccionaObjetoInventario,0,0)
      end
    else
      Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
end;

procedure TMapaEspejo.JSoltarObjetoElegido(cantidad:byte);
var codigo_Bolsa:word;
    nroElementos,IndArtefacto:byte;
begin
  if Jform.IdGridActivado<>IdGrInventario then
  begin
    Jform.MensajeAyuda:=Men_Sennala_En_Inventario;
    exit;
  end;
  with JugadorCl do
    if ((hp<>0) or (comportamiento>comHeroe)) then
      if longbool(Banderas and bnparalisis) then
        Jform.agregarMensaje(cmEstasParalizado)
      else
      begin
        codigo_Bolsa:=mapaPos[coordx,coordy].terBol and mskBolsa;
        if ttipoBolsa(codigo_Bolsa)=tbtrampaMagica then
          Jform.agregarMensaje(cmActivasTrampaMagica)
        else
        begin
          IndArtefacto:=JForm.DGObjetos.indice;
          if IndArtefacto<=MAX_ARTEFACTOS then
            if Artefacto[IndArtefacto].id>=4 then
            begin
              nroElementos:=NumeroElementos(Artefacto[IndArtefacto]);
              if (cantidad=0) then cantidad:=nroElementos;
              if (nroElementos>=cantidad) then
                Cliente.SendTextNow('S'+char(cantidad)+char(IndArtefacto))
              else
                Jform.MensajeAyuda:=ME_NO_TIENES_ESA_CANTIDAD;
            end
            else
              Jform.MensajeAyuda:=MensajeResultado(i_SeleccionaObjetoInventario,0,0)
        end;
      end
    else
      Jform.MensajeAyuda:=MensajeResultado(i_EstasMuerto,0,0)
end;

procedure TMapaEspejo.JMeditar;
begin
  with jugadorCl do
  if maxmana>0 then
    if hp<>0 then
      if (JugadorCl.banderas and bnParalisis)=0 then
        if comida>0 then
          if (mana<maxMana) then
          begin
            Cliente.SendTextNow('e');
            JForm.AgregarMensaje('Tu nivel de maná está subiendo');
          end
          else
            JForm.AgregarMensaje('Tu maná ya está al máximo')
        else
          JForm.AgregarMensaje('No puedes meditar, te mueres de hambre')
      else
        Jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasParalizado,0,0)
    else
      Jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0)
  else
    JForm.AgregarMensaje('No puedes acumular maná')
end;

procedure TMapaEspejo.JDescansar;
begin
  if JugadorCl.hp<>0 then
    if (JugadorCl.banderas and bnEnvenenado)=0 then
      if JugadorCl.comida>0 then
      begin
        Cliente.SendTextNow('d');
        if (JugadorCl.hp<=(JugadorCl.maxhp shr 1)) and ((JugadorCl.banderas and bnvendado)=0) then
          JForm.AgregarMensaje('Necesitas vendar tus heridas para que sanen más rápido')
        else
          JForm.AgregarMensaje('Te detienes a descansar para recuperar puntos de salud');
      end
      else
        JForm.AgregarMensaje('No puedes descansar, estás muriendo de hambre')
    else
      JForm.AgregarMensaje('No puedes descansar, estás envenenado')
  else
    Jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0);
end;

procedure TMapaEspejo.JRevisarObjetos;
begin
  if Jform.VentanaActivada=vaMenuObjetos then exit;
  if longbool(JugadorCl.Banderas and bnparalisis) then
    Jform.agregarMensaje(cmEstasParalizado)
  else
    with JugadorCL do
      if ((hp<>0) or (comportamiento>comHeroe)) then
        if (MapaPos[coordx,coordy].terBol and mskBolsa)<>NoExisteBolsa then
          Cliente.SendTextNow('R')
        else
          Jform.MensajeAyuda:='No encuentras nada para revisar'
      else
        Jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0);
end;

procedure TMapaEspejo.JAlzarObjeto;
begin
  if longbool(JugadorCl.Banderas and bnparalisis) then
    Jform.agregarMensaje(cmEstasParalizado)
  else
    with JugadorCL do
      if ((hp<>0) or (comportamiento>comHeroe)) then
        if (MapaPos[coordx,coordy].terBol and mskBolsa)<>NoExisteBolsa then
          Cliente.SendTextNow('a')//alzar
        else
          Jform.MensajeAyuda:='No ves nada interesante para alzar'
      else
        Jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuerto,0,0);
end;

{SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
                           COMANDOS DEL SERVIDOR
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS}

procedure TMapaEspejo.SMatarSprite(codigo:word);
var contenido:word;
    Temp:integer;
begin
  contenido:=codigo and fl_con;
  codigo:=codigo and fl_cod;
  if contenido=ccMon then
    with Monstruo[codigo] do
    begin
      if activo then//implica coordx y coordy válidos
      begin
        controlFX.SetEfecto(0,0,fxSangre,0,0,Monstruo[codigo]);
        if mapapos[coordx,coordy].monRec=(codigo or ccMon) then
          mapapos[coordx,coordy].monRec:=ccVac;
        activo:=false;
      end;
      if JugadorCl.apuntado=Monstruo[codigo] then JugadorCl.apuntado:=nil;
      SonidoXY(snMuerteMonstruo,coordX-JugadorCl.coordX,coordY-JugadorCl.coordY);
    end
  else if contenido=ccJgdr then
    with Jugador[codigo] do
    begin
      if activo then//implica coordx y coordy válidos
      begin
        controlFX.SetEfecto(0,0,fxSangre,0,0,Jugador[codigo]);
        if esVaron then temp:=snMuerteH else temp:=snMuerteM;
        SonidoXY(temp,coordX-JugadorCl.coordX,coordY-JugadorCl.coordY);
      end;
      hp:=0;
      accion:=aaParado;
      ritmoDeVida:=0;
      banderas:=0;
      determinarAnimacion;
      CambiarAnimacionJugador(codAnime);
    end;
end;

procedure SCambiarAccion(codigoCasilla:word;NAccion:byte);
var RefMonstruo:TMonstruoS;
begin
  RefMonstruo:=GetMonstruoCodigoCasilla(codigoCasilla);
  if RefMonstruo=nil then exit;
  with refMonstruo do
  begin
    activo:=true;
    Banderas:=Banderas or BnMana or BnDescansar;
    if Naccion<>aaMeditando then Banderas:=Banderas xor BnMana;
    if Naccion<>aaDescansando then Banderas:=Banderas xor BnDescansar;
    if Naccion<=aaDescansando then Naccion:=aaParado;
    if (NAccion>=aaAtacando1) and (Accion<aaAtacando1) then ritmoDeVida:=0;
    Accion:=NAccion;
    if (refMonstruo=JugadorCl) and (Accion>=aaPrimerAtaque) and (Accion<=aaUltimoAtaque) then
      IControlMenusPorMovimiento(true);
  end
end;

procedure SCambiarDireccion(codigoCasilla:word;Ndir:byte);
var RefMonstruo:TMonstruoS;
begin
  RefMonstruo:=GetMonstruoCodigoCasilla(codigoCasilla);
  if RefMonstruo=nil then exit;
  with refMonstruo do
  begin
    activo:=true;
    if accion<aaAtacando1 then accion:=aaParado;
    dir:=Ndir;
    if refMonstruo=JugadorCl then
      IControlMenusPorMovimiento(false);
  end
end;

procedure TMapaEspejo.SMover(codigoCasilla:word;X,Y,Ndir:byte;Movimiento:TTipoMovimiento);
var RefMonstruo:TMonstruoS;
begin
  RefMonstruo:=GetMonstruoCodigoCasilla(codigoCasilla);
  if RefMonstruo<>nil then
    with refMonstruo do
    begin
      if activo then
      begin//borrar marca en el mapa, fijar la interpolación del movimiento, fijar coordenadas anteriores
        if mapapos[coordx,coordy].monRec and fl_cod=codigo then
          mapaPos[coordx,coordy].monRec:=ccVac;
        if (movimiento=tmInterpolado) and (maximo2(abs(coordx-x),abs(coordy-y))<=3) then
        begin
          if (control_movimiento=0) then
          begin
            control_movimiento:=Nro_Frames_Interpolados;
            coordx_ant:=coordx;
            coordy_ant:=coordy;
          end;
        end
        else
        begin
          control_movimiento:=0;
          coordx_ant:=x;
          coordy_ant:=y;
        end;
      end
      else//activar, fijar interpolador en 0, fijar coordenadas anteriores en las actuales
      begin
        activo:=true;
        control_movimiento:=0;
        coordx_ant:=x;
        coordy_ant:=y;
      end;
      //Efecto de salida
      if movimiento=tmDirectoConEfecto then
        controlFX.SetEfecto(coordx,coordy,anIngresando,0,0,nil);
      //Actualizar posicion
      coordx:=x;
      coordy:=y;
      //Efecto de entrada
      if movimiento=tmDirectoConEfecto then
        controlFX.SetEfecto(coordx,coordy,anDisolviendo,0,0,nil);
      //Actualizar posicion en el mapa
      mapaPos[coordx,coordy].monRec:=codigoCasilla;
      dir:=Ndir and $F;
      accion:=Ndir shr 4;
      //Control de banderas
      Banderas:=Banderas or BnMana or BnDescansar;//banderas
      if accion<>aaMeditando then Banderas:=Banderas xor BnMana;
      if accion<>aaDescansando then Banderas:=Banderas xor BnDescansar;
      if accion<=aaDescansando then accion:=aaParado;//continua caminando o atacando
      //sonido de pasos
      inc(codNido);//sincronizador de sonido de pasos
      if ((banderas and bnFantasma)=0) and ((codNido and $1) =0) then
        sonidoPasosXY(MC_SndPasosEnTerreno[getTerrenoXYParaSonido(coordx,coordy)] or
        (((codNido xor codigo) and $6) shl 15),
        coordX-JugadorCl.coordX,coordY-JugadorCl.coordY);
      if refMonstruo=JugadorCl then
      begin
        //Control de sensores
        ControlSensoresJugador;
        if Jform.RequerimientoDeCambiarMusicaPendiente then
          if copy(jform.MusicaTocada,1,1)<>DeterminarPrefijoDeMusicaAdecuada then //si es distinto
            if (copy(jform.MusicaTocada,1,1)='c') or (DeterminarPrefijoDeMusicaAdecuada='c') then //si alguno es del tipo tetrica
            begin
              Jform.RequerimientoDeCambiarMusicaPendiente:=false;
              jform.DesactivarMusica;
              jform.ActivarMusica;
            end;
        IcontrolMenusPorMovimiento(true);
      end;
    end;
end;

procedure TMapaEspejo.SMuerteJugador(codigoAsesino:word);
var monstruoAsesino:Tmonstruos;
  cadena:string;
begin
  with jugadorCL do
  begin
    controlFX.SetEfecto(0,0,fxSangre,0,0,Jugador[codigo]);
    //Nota: Igual q' en soltarObjetosMuerto(jugadorCL);
    if ((BanderasMapa and bmEsMapaSeguro)=0) and (comportamiento<=comHeroe) then
      if (usando[uAmuleto].id=ihAmuletoDeConservacion) then
      begin
        sonido(snMagiaCorto);
        Jform.AgregarMensaje('·El amuleto de conservación hace efecto');
        usando[uAmuleto]:=obNuloMDV;
      end;
    if esVaron then sonido(snMuerteH) else sonido(snMuerteM);
    morir;
    ritmoDeVida:=0;
    CalcularModDefensa;
    CambiarAnimacionJugador(codAnime);
  end;
  monstruoAsesino:=GetMonstruoCodigoCasilla(codigoAsesino);
  cadena:='';
  if monstruoAsesino=nil then
    case random(4) of
      0:cadena:='Tu cuerpo sin vida yace en el suelo';
      1:cadena:='Entraste al mundo de los muertos';
      2:cadena:='La muerte ha llegado para ti';
      else cadena:='Atravesaste el umbral de la muerte';
    end
  else
    if monstruoAsesino is TjugadorS then
    begin
      cadena:=TjugadorS(monstruoAsesino).nombreAvatar;
      case random(5) of
        0:cadena:=cadena+' te ha matado';
        1:cadena:='Fuiste derrotado por '+cadena;
        2:cadena:='Caes vencido por '+cadena;
        3:cadena:=cadena+' te ha ejecutado';
        else cadena:=cadena+' te mandó al otro mundo';
      end
    end
    else
      if monstruoAsesino is Tmonstruos then
      begin
        cadena:=AgregarSufijoSexuadoA(InfMon[monstruoAsesino.TipoMonstruo].nombre);
        case random(5) of
          0:cadena:='Te ha matado un'+cadena;
          1:cadena:='Un'+cadena+' acabó contigo';
          2:cadena:='Un'+cadena+' te ha ejecutado';
          3:cadena:='Caes derrotado por un'+cadena;
          else cadena:='Fuiste derrotado por un'+cadena;
        end;
      end;
  Jform.AgregarMensaje('+'+cadena);
  case random(3) of
    0:cadena:='Busca una catedral para resucitar o escribe "/ret"';
    1:cadena:='Puedes resucitar con la palabra del retorno "/ret"';
    else
      cadena:='Usa la palabra del retorno "/ret" para resucitar';
  end;
  Jform.AgregarMensaje('·'+cadena);
  Jform.MostrarDatosFrecuentesJugadorYObjetos;
  Jform.PintarRostroJugador;
end;

procedure SResucitarJugador;
begin
  sonido(snCampana);
  jugadorCL.resucitar;
  with Jform do
  begin
    MostrarHP(jugadorCl.hp,false,'');
    MostrarMana;
    MostrarComida;
    MostrarExperiencia;
    AgregarMensaje('+Te han resucitado');
    PintarRostroJugador;
  end;
end;

procedure SFuerzagigante;
begin
//  sonido(snCuracion);
  JugadorCl.Banderas:=JugadorCl.Banderas or BnFuerzaGigante;
  JugadorCl.CalcularDannoBase;
  Jform.AgregarMensaje('*Tienes la fuerza de los gigantes');
  Jform.MostrarDanno;
  Jform.PintarRostroJugador;
end;

procedure SFuerzaNormal;
begin
  if longbool(JugadorCl.Banderas and bnFuerzaGigante) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnFuerzaGigante;//Limpiar bandera
    JugadorCl.CalcularDannoBase;
    Jform.AgregarMensaje('·Perdiste la fuerza de los gigantes');
    Jform.MostrarDanno;
    Jform.PintarRostroJugador;
  end;
end;

procedure SRestitucion;
begin
  sonido(snTermina);
  JugadorCl.restitucionAtributos;
  Jform.MostrarDatosFrecuentesJugador;
  Jform.AgregarMensaje('*Los hechizos que te afectaban fueron disipados');
  Jform.PintarRostroJugador;
end;

procedure SSanacion;
begin
//  sonido(snCuracion);
  JugadorCl.SanacionCuracion;
  with Jform do
  begin
    AgregarMensaje('+¡Te sientes mucho más saludable!');
    MostrarHp(JugadorCl.hp,false,'');
    PintarRostroJugador;
  end;
end;

procedure SQuitarVeneno;
begin
  if longbool(JugadorCl.Banderas and BnEnvenenado) then
  begin
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnEnvenenado;//Limpiar bandera
    sonido(snCuracion);
    with Jform do
    begin
      AgregarMensaje('+¡Ya no estás envenenado!');
      PintarRostroJugador;
    end;
  end;
end;

procedure SAcelerar;
begin
//  sonido(snCuracion);
  JugadorCl.Banderas:=JugadorCl.Banderas or BnApresurar;
  Jform.AgregarMensaje('*Tu velocidad de ataque se ha duplicado');
  Jform.PintarRostroJugador;
end;

procedure SQuitarAcelerar;
begin
  if longbool(JugadorCl.Banderas and BnApresurar) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnApresurar;//Limpiar bandera
    Jform.AgregarMensaje('·Tu velocidad de ataque se normalizó');
    Jform.PintarRostroJugador;
  end;
end;

procedure SArmadura;
begin
//  sonido(snCuracion);
  JugadorCl.Banderas:=JugadorCl.Banderas or BnArmadura;
  JugadorCl.CalcularDefensa;
  Jform.MostrarDatosFrecuentesJugador;
  Jform.AgregarMensaje('*Te rodea una armadura mágica');
  Jform.PintarRostroJugador;
end;

procedure SQuitarArmadura;
begin
  if longbool(JugadorCl.Banderas and BnArmadura) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnArmadura;
    JugadorCl.CalcularDefensa;
    Jform.MostrarDatosFrecuentesJugador;
    Jform.AgregarMensaje('·La armadura mágica se desvaneció');
    Jform.PintarRostroJugador;
  end;
end;

procedure SProteccion;
begin
  JugadorCl.Banderas:=JugadorCl.Banderas or BnProteccion;
  Jform.AgregarMensaje('*Te rodea una aura de protección divina');
  Jform.PintarRostroJugador;
end;

procedure SQuitarProteccion;
begin
  if longbool(JugadorCl.Banderas and BnProteccion) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnProteccion;
    Jform.AgregarMensaje('·El aura de protección divina se desvaneció');
    Jform.PintarRostroJugador;
  end;
end;

procedure SAturdir;
begin
  sonido(snMaldicion);
  JugadorCl.Banderas:=JugadorCl.Banderas or BnAturdir;
  JugadorCl.CalcularNivelAtaque;
  Jform.AgregarMensaje('-¡Te han aturdido!');
  Jform.MostrarGAC0;
  Jform.PintarRostroJugador;
end;

procedure SQuitarAturdir;
begin
  if longbool(JugadorCl.Banderas and BnAturdir) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnAturdir;
    JugadorCl.CalcularNivelAtaque;
    Jform.AgregarMensaje('!¡Ya no estás aturdido!');
    Jform.MostrarGAC0;
    Jform.PintarRostroJugador;
  end;
end;

procedure SCongelar;
begin
  sonido(snMagiaCorto);//mejor enviar a todos los jugadores??
  JugadorCl.Banderas:=JugadorCl.Banderas or BnCongelado;
  Jform.AgregarMensaje('-¡Te han congelado, el frio hace lentos tus movimientos!');
  Jform.PintarRostroJugador;
end;

procedure SQuitarCongelar;
begin
  if longbool(JugadorCl.Banderas and BnCongelado) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnCongelado;
    Jform.AgregarMensaje('·Ya no estás congelado');
    Jform.PintarRostroJugador;
  end;
end;

procedure SActivarZoomorfismo;
begin
  sonido(snCuracion);
  JugadorCl.Banderas:=JugadorCl.Banderas or BnZoomorfismo;
  Jform.AgregarMensaje('*Cambias de forma');
  JugadorCl.CalcularDefensa;
  JugadorCl.CalcularNivelAtaque;
  JugadorCl.CambiarAnimacionJugador(moOso);
  Jform.MostrarDatosFrecuentesJugador;
  Jform.PintarRostroJugador;
end;

procedure SQuitarZoomorfismo;
begin
  if longbool(JugadorCl.Banderas and BnZoomorfismo) then
  begin
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnZoomorfismo;
    Jform.AgregarMensaje('·Recuperaste tu forma normal');
    JugadorCl.CalcularDefensa;
    JugadorCl.CalcularNivelAtaque;
    Jform.MostrarDatosFrecuentesJugador;
    Jform.PintarRostroJugador;
  end;
end;

procedure SParalisis;
begin
  sonido(snMaldicion);
  JugadorCl.Banderas:=JugadorCl.Banderas or BnParalisis;
  Jform.AgregarMensaje('-'+cmEstasParalizado);
  Jform.PintarRostroJugador;
end;

procedure SQuitarParalisis;
begin
  if longbool(JugadorCl.Banderas and BnParalisis) then
  begin
    sonido(snCuracion);//enviado a todos los jugadores??
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnParalisis;
    Jform.AgregarMensaje('·Ya no estás paralizado');
    Jform.PintarRostroJugador;
  end;
end;

procedure SRealizarVendaje;
begin
  JugadorCl.Banderas:=JugadorCl.Banderas or BnVendado;
  Jform.AgregarMensaje('·Tus heridas están vendadas');
end;

procedure SQuitarVendas;
begin
  if longbool(JugadorCl.Banderas and BnVendado) then
  begin
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnVendado;
    Jform.AgregarMensaje('·Te quitas los vendajes');
  end;
end;

procedure SActivarIraTenax;
begin
  with JugadorCl do
  begin
    banderas:=banderas or bnIraTenax;
    CalcularDefensa;
    CalcularDannoBase;
    sonido(snCuracion);
    Jform.MostrarDatosFrecuentesJugador;
    Jform.AgregarMensaje('*Ira Tenax, ahora puedes hacer el doble de daño');
    Jform.PintarRostroJugador;
  end;
end;

procedure SQuitarIraTenax;
begin
  with JugadorCl do
  if longbool(Banderas and BnIraTenax) then
  begin
    banderas:=banderas xor bnIraTenax;
    CalcularDefensa;
    CalcularDannoBase;    
    sonido(snTermina);
    Jform.MostrarDatosFrecuentesJugador;
    Jform.AgregarMensaje('·Ira Tenax ha terminado');
    Jform.PintarRostroJugador;
  end;
end;

procedure SInvisibilidad;
begin
  JugadorCl.Banderas:=JugadorCl.Banderas or BnInvisible;
  Jform.AgregarMensaje('*Te has vuelto invisible');
  Jform.PintarRostroJugador;
end;

procedure SInvisibilidadOcultarse;
begin
  sonido(snOcultarse);
  JugadorCl.Banderas:=JugadorCl.Banderas or BnInvisible;
  Jform.AgregarMensaje('*Te has ocultado');
  Jform.PintarRostroJugador;
end;

procedure SQuitarInvisibilidad;
begin
  if longbool(JugadorCl.Banderas and BnInvisible) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnInvisible;
    JugadorCl.Banderas:=(JugadorCl.Banderas or BnOcultarse) xor BnOcultarse;
    Jform.AgregarMensaje('·Vuelves a ser visible');
  end;
  Jform.PintarRostroJugador;
end;

procedure SVisionVerdadera;
begin
  JugadorCl.Banderas:=JugadorCl.Banderas or BnVisionVerdadera;
  JugadorCl.DefinirCapacidadIdentificacion;
  Jform.AgregarMensaje('*Estas bajo el efecto de la visión verdadera');
  Jform.PintarRostroJugador;
  Jform.MostrarDatosFrecuentesJugadorYObjetos
end;

procedure SQuitarVisionVerdadera;
begin
  if longbool(JugadorCl.Banderas and BnVisionVerdadera) then
  begin
    sonido(snTermina);
    JugadorCl.Banderas:=JugadorCl.Banderas xor BnVisionVerdadera;
    JugadorCl.DefinirCapacidadIdentificacion;
    Jform.AgregarMensaje('·El hechizo visión verdadera ha terminado');
    Jform.PintarRostroJugador;
    Jform.MostrarDatosFrecuentesJugadorYObjetos    
  end;
end;

procedure SEnvenenar;
begin
  sonido(snMagiaCorto);//Sonido de envenenar
  JugadorCl.Banderas:=JugadorCl.Banderas or BnEnvenenado;
  Jform.AgregarMensaje('-¡Estás envenenado!');
  Jform.PintarRostroJugador;
end;

procedure SActualizarBanderas(codigoCasilla:word;banderasAuras,BanderasNoActualizadas:longWord);
var RefMonstruo:TmonstruoS;
    banderasAnteriores:longWord;
begin
  RefMonstruo:=GetMonstruoCodigoCasilla(codigoCasilla);
  if RefMonstruo=nil then exit;
  banderasAnteriores:=RefMonstruo.banderas;
  with refMonstruo do
  begin
    banderas:=(banderas and BanderasNoActualizadas) or banderasAuras;
    //Emitir sonidos de hechizos, según estaban o no activadas las banderas
    if (((banderasAnteriores and bnParalisis)=0) and ((banderas and bnParalisis)<>0)) or
       (((banderasAnteriores and bnAturdir)=0)   and ((banderas and bnAturdir)<>0)) then
      sonidoXY(snMaldicion,coordx-JugadorCl.coordX,coordy-JugadorCl.coordY);
  end;
  if RefMonstruo=JugadorCl then Jform.PintarRostroJugador;
end;

procedure SCambiarRitmoJuego(ritmoJuego:byte);
begin
  if ritmoJuego<1 then ritmoJuego:=1;
  if ritmoJuego>16 then ritmoJuego:=16;
  Ritmo_Juego_Maestro:=ritmoJuego;
  SActualizarNroInterpolados;
end;

procedure SActualizarNroInterpolados;
begin
  if (Jform.Timer.Interval=BAJA_FRECUENCIA) then
  begin
    Frame_Actualizacion_Posicion:=Ritmo_Juego_Maestro shr 1;
    Nro_Frames_Interpolados:=Ritmo_Juego_Maestro-1;
    Desplazador_AniSincro:=1;
    Msk_AniSincro:=$3
  end
  else
  begin
    Frame_Actualizacion_Posicion:=Ritmo_Juego_Maestro;
    Nro_Frames_Interpolados:=(Ritmo_Juego_Maestro shl 1)-1;
    Desplazador_AniSincro:=2;
    Msk_AniSincro:=$7;
  end;
  Paso_InterpoladoX:=ancho_tile div (Nro_Frames_Interpolados+1);
  Paso_InterpoladoY:=alto_tile div (Nro_Frames_Interpolados+1);
end;

procedure SMostrarMensajeMuerte(codigoCasilla:word);
var cadena:string;
    ElMonstruo:Tmonstruos;
begin
  case codigoCasilla and $3 of
    0:cadena:='Ejecut';
    1:cadena:='Elimin';
    else cadena:='Mat';
  end;
  ElMonstruo:=GetMonstruoCodigoCasilla(codigoCasilla);
  if ElMonstruo=nil then exit;
  cadena:=cadena+'aste a un'+AgregarSufijoSexuadoA(InfMon[ElMonstruo.TipoMonstruo].nombre);
  if ElMonstruo is TjugadorS then
    cadena:=cadena+' llamado '+TjugadorS(ElMonstruo).nombreAvatar;
  Jform.AgregarMensaje('+'+cadena);
end;

procedure TMapaEspejo.SDisolverSprite(codigoCasilla:word);
var RefMonstruo:TmonstruoS;
begin
  RefMonstruo:=GetMonstruoCodigoCasilla(codigoCasilla);
  if RefMonstruo=nil then exit;
  if JugadorCl.apuntado=RefMonstruo then jugadorCl.apuntado:=nil;
  with RefMonstruo do
  begin
    if activo then
    begin
      controlFX.SetEfecto(coordx,coordy,anDisolviendo,0,0,nil);
      if mapapos[coordx,coordy].monRec and fl_cod=codigo then
        mapaPos[coordx,coordy].monRec:=ccVac;
      activo:=false;
    end;
    banderas:=0;
  end;
  if RefMonstruo is TjugadorS then TjugadorS(RefMonstruo).nombreAvatar:='';
end;

procedure TMapaEspejo.SColocarCadaver(posx,posy:byte;TipoCadaver:TtipoBolsa);
var TipoT:TtipoBolsa;
begin
  //bolsa anterior
  TipoT:=TtipoBolsa(mapaPos[posx,posy].terBol and mskBolsa);
  //hacer arder el cadaver si es el caso
  if (TipoT>=tbFogata) and (TipoT<=tbCadaverArdiente)  then
    if TipoCadaver<>tbCadaverEnergia then
      TipoT:=tbCadaverArdiente
    else
      TipoT:=tbFogata
  else
    TipoT:=TipoCadaver;
  SColocarBolsa(posx,posy,TipoT);
end;

procedure TMapaEspejo.SApagarFogata(posx,posy:byte);
var TipoDeBolsa:TtipoBolsa;
begin
  //bolsa anterior
  TipoDeBolsa:=TtipoBolsa(mapaPos[posx,posy].terBol and mskBolsa);
  //hacer arder el cadaver si es el caso
  if (TipoDeBolsa=tbCadaverArdiente)  then
    TipoDeBolsa:=tbCadaverQuemado
  else
    TipoDeBolsa:=tbCenizas;
  SColocarBolsa(posx,posy,TipoDeBolsa);
end;

procedure TMapaEspejo.SColocarBolsa(posx,posy:byte;tipo:TtipoBolsa);
begin
  mapaPos[posx,posy].terBol:=(mapaPos[posx,posy].terBol and mskTerreno) or byte(tipo);
end;

function TMapaEspejo.SEliminarBolsa(posx,posy:byte):TTipoBolsa;
begin//devuelve el tipo de bolsa anterior
  result:=TTipoBolsa(mapaPos[posx,posy].terBol and $FF);
  mapaPos[posx,posy].terBol:=mapaPos[posx,posy].terBol or NoExisteBolsa;
end;

procedure TMapaEspejo.SActualizarBanderasMapa(banderas:integer;todas,sonido:boolean);
const
  MC0_dX:array[0..4] of smallint=(0,0,0,-1,1);
  MC0_dY:array[0..4] of smallint=(0,-1,1,0,0);
var UnaBandera,EstadoAnterior,flagActual,i,j,k,inicio,fin:integer;
    distanciaXN,distanciaXP:array[0..3] of smallint;
    distanciaY:array[0..3] of smallint;
    sonidoActivado:array[0..3] of boolean;
  //Reducir todos los sonidos a solo uno por tipo, reproduciendo el sonido
  //más cercano al jugador.
  procedure ActivarSonido(indice:integer);
  var x,y:integer;
  begin
    sonidoActivado[indice]:=true;
    x:=dato1Flag[i]-JugadorCl.coordx;
    y:=abs(dato2Flag[i]-JugadorCl.coordy);
    if x<0 then
    begin
      if x>distanciaXN[indice] then
        distanciaXN[indice]:=x;
    end
    else
      if x<distanciaXP[indice] then
        distanciaXP[indice]:=x;
    if y<distanciaY[indice] then
      distanciaY[indice]:=y;
  end;
begin
  EstadoAnterior:=FlagsCalabozo;
  if todas then
  begin
    FlagsCalabozo:=banderas;
    inicio:=0;
    fin:=31;
  end
  else
  begin
    inicio:=banderas and $1F;
    fin:=inicio;
    UnaBandera:=1 shl inicio;
    FlagsCalabozo:=FlagsCalabozo or UnaBandera;
    if (banderas and $20)=0 then//limpiar flag
      FlagsCalabozo:=FlagsCalabozo xor UnaBandera;
  end;
  //Actualizar mapa
  for k:=inicio to fin do
  begin
    flagActual:=FlagsCalabozo and (1 shl k);
    //Dato1Flag[k] : Posición X
    //Dato2Flag[k] : Posición Y
    case TTipoEfectoFlagS(ComportamientoFlag[k] and $F) of
      efsDesactiva2x2:
      begin
        if flagActual=0 then
        begin
          for i:=0 to 1 do
            for j:=0 to 1 do
              if (mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec=ccVac) then
                mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec:=ccRecMov
        end
        else
          for i:=0 to 1 do
            for j:=0 to 1 do
              if (mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec=ccRecMov) then
                mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec:=ccVac;
      end;
      efsDesactivaReja2x2:
      begin
        if flagActual=0 then
        begin
          for i:=0 to 1 do
            for j:=0 to 1 do
              if (mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec=ccVac) then
                mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec:=ccVacRangoMov
        end
        else
          for i:=0 to 1 do
            for j:=0 to 1 do
              if (mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec=ccVacRangoMov) then
                mapaPos[(i+Dato1Flag[k])and $FF,(j+Dato2Flag[k]) and $FF].monRec:=ccVac;
      end;
      efsDesactiva3x3:
      begin
        if flagActual=0 then
        begin
          for i:=0 to 4 do
            if (mapaPos[(MC0_dX[i]+Dato1Flag[k])and $FF,(MC0_dY[i]+Dato2Flag[k]) and $FF].monRec=ccVac) then
              mapaPos[(MC0_dX[i]+Dato1Flag[k])and $FF,(MC0_dY[i]+Dato2Flag[k]) and $FF].monRec:=ccRecMov
        end
        else
          for i:=0 to 4 do
            if (mapaPos[(MC0_dX[i]+Dato1Flag[k])and $FF,(MC0_dY[i]+Dato2Flag[k]) and $FF].monRec=ccRecMov) then
              mapaPos[(MC0_dX[i]+Dato1Flag[k])and $FF,(MC0_dY[i]+Dato2Flag[k]) and $FF].monRec:=ccVac;
      end;
    end;
  end;
  //Sonidos
  if not sonido then exit;
  for i:=0 to 3 do
  begin
    sonidoActivado[i]:=false;
    distanciaXN[i]:=-1024;
    distanciaXP[i]:=1024;
    distanciaY[i]:=1024;
  end;
  for i:=inicio to fin do
  begin
    flagActual:=FlagsCalabozo and (1 shl i);
    if ((EstadoAnterior xor FlagsCalabozo) and (1 shl i))<>0 then
      case TTipoEfectoFlagC(ComportamientoFlag[i] shr 4) of
        efcPuerta:
          if (flagActual=0) then
            ActivarSonido(0)
          else
            ActivarSonido(1);
        efcPorticullis:ActivarSonido(2);
        efcPalanca:ActivarSonido(3);
      end;
  end;
  //Reproducir los sonidos más cercanos al jugador
  for i:=0 to 3 do
    if sonidoActivado[i] then
    begin
      if distanciaXN[i]<=-1024 then distanciaXN[i]:=0;
      if distanciaXP[i]>=1024 then distanciaXP[i]:=0;
      SonidoXY(46+i,distanciaXN[i]+distanciaXP[i],distanciaY[i]);
    end;
end;

procedure TMapaEspejo.SEfectosConjuro(Conjuro,posx,posy:byte);
var i,x,y,nx,ny:integer;
    MonstruoOrigen:TmonstruoS;
    direccionConjuro:TdireccionMonstruo;
    ContenidoCasilla:word;
    Nro_Frame:byte;
  function FijarEfecto(EfectoCompleto:boolean):boolean;
  //false si se debe detener el efecto
  begin
    result:=false;
    if (x<0)or(y<0)or(x>MaxMapaAreaExt)or(y>MaxMapaAreaExt) then exit;
    contenidoCasilla:=mapaPos[x,y].monRec;
    if (contenidoCasilla<ccVacRango) and (contenidoCasilla>=ccRec) then exit;
    result:=true;
    if (contenidoCasilla<=ccLimiteMonstruos) then
      controlFX.SetEfecto(x,y,fxArdienteR+(conjuro div 3),0,0,GetMonstruoXY(x,y))
    else
      if EfectoCompleto then
        if conjuro=7 then
          controlFX.SetEfecto(x,y,fxRayo,2,MonstruoOrigen.dir,nil)
        else
        begin
          Nro_Frame:=MAX_NRO_EXPLOSIONES-i;
          if Nro_Frame>7 then Nro_frame:=7;
          controlFX.SetEfecto(x,y,fxBolaR+(conjuro div 3),Nro_Frame,0,nil);
        end;
  end;
begin
  if Conjuro<=8 then // Conjuros de combate
  begin
    if byteBool(InfConjuro[conjuro].BanderasCnjr and cjPuedeLanzarObjetivo) then
    begin
      controlFX.SetEfecto(posx,posy,fxArdienteR+(conjuro div 3),0,0,GetMonstruoXY(posx,posy));
    end
    else
      if byteBool(InfConjuro[conjuro].BanderasCnjr and cjPuedeLanzarAsimismo) then
      begin
        MonstruoOrigen:=GetMonstruoCasilla(posx,posy);
        if MonstruoOrigen=nil then exit;
        direccionConjuro:=MonstruoOrigen.dir;
        nx:=posx+MC_avanceX[direccionConjuro]+MC_avanceX[direccionConjuro];
        ny:=posy+MC_avanceY[direccionConjuro]+MC_avanceY[direccionConjuro];
        for i:=0 to MAX_INTENTOS_POSICIONAMIENTO do//Tormentas
          begin
            x:=nx+MC_POSICIONAMIENTO_X[i];
            y:=ny+MC_POSICIONAMIENTO_Y[i];
            if (x>=0) and (y>=0) and (x<=MaxMapaAreaExt) and (y<=MaxMapaAreaExt) then
            begin
              contenidoCasilla:=mapaPos[x,y].monRec;
              if (contenidoCasilla<ccRec) or (contenidoCasilla>=ccVacRango) then
                controlFX.SetEfecto(x,y,fxArdienteR+(conjuro div 3),-(i shr 2),0,GetMonstruoXY(x,y))
            end
          end;
      end
      else
      begin// conjuros que lanzan una fila de efectos
        MonstruoOrigen:=GetMonstruoCasilla(posx,posy);
        if MonstruoOrigen=nil then exit;
        direccionConjuro:=MonstruoOrigen.dir;
        nx:=posx+MC_avanceX[direccionConjuro];
        ny:=posy+MC_avanceY[direccionConjuro];
        x:=nx;
        y:=ny;
        for i:=0 to MAX_NRO_EXPLOSIONES do
        begin
          inc(x,MC_avanceX[direccionConjuro]);
          inc(y,MC_avanceY[direccionConjuro]);
          if not FijarEfecto(true) then break;
        end;
        if Conjuro<>7{Rayo psítico} then
        begin
          x:=nx+MC_avanceX[MC_anteriorDireccion[direccionConjuro]];
          y:=ny+MC_avanceY[MC_anteriorDireccion[direccionConjuro]];
          for i:=0 to MAX_NRO_EXPLOSIONES-1 do
          begin
            inc(x,MC_avanceX[direccionConjuro]);
            inc(y,MC_avanceY[direccionConjuro]);
            if not FijarEfecto(true) then break;
          end;
          x:=nx+MC_avanceX[MC_siguienteDireccion[direccionConjuro]];
          y:=ny+MC_avanceY[MC_siguienteDireccion[direccionConjuro]];
          for i:=0 to MAX_NRO_EXPLOSIONES-1 do
          begin
            inc(x,MC_avanceX[direccionConjuro]);
            inc(y,MC_avanceY[direccionConjuro]);
            if not FijarEfecto(true) then break;
          end;
        end;
      end
  end
  else//Otros conjuros
  case Conjuro of
    12..14,25,28:controlFX.SetEfecto(posx,posy,fxBolaB,0,0,GetMonstruoXY(posx,posy));
    16,26:controlFX.SetEfecto(posx,posy,fxArdienteR,0,0,GetMonstruoXY(posx,posy));
    15,17:controlFX.SetEfecto(posx,posy,fxChispasRojas,0,0,GetMonstruoXY(posx,posy));
    18,20..22,24,27:controlFX.SetEfecto(posx,posy,fxChispasAzules,0,0,GetMonstruoXY(posx,posy));
    else controlFX.SetEfecto(posx,posy,fxChispasDoradas,0,0,GetMonstruoXY(posx,posy));
  end;
end;

procedure TMapaEspejo.JMostrarJugadoresMapa;
var cad:string;
    i:integer;
begin
  cad:='';
  for i:=0 to maxJugadores do
    with Jugador[i] do
      if (NombreAvatar<>'') and ({jugador[i]}codMapa={mapa}fcodMapa) then
        cad:=cad+NombreAvatar+',';
  if cad='' then begin
    ControlChat.setMensaje(nil,'No existen otros avatares en esta zona.',clEsmeralda)
  end
  else
  begin
    delete(cad,length(cad),1);
    ControlChat.setMensaje(nil,'Avatares en esta zona: '+cad,clEsmeralda);
  end;
  //Pedir más info al servidor:
  Cliente.SendTextNow('&J')
end;

procedure TMapaEspejo.JMostrarClanesMapa;
var cad:string;
    i:integer;
begin
  cad:='';
  for i:=0 to maxClanesJugadores do
    with ClanJugadores[i] do
      if (Nombre<>'') then
        cad:=cad+Nombre+',';
  if cad='' then begin
    ControlChat.setMensaje(nil,'No existen clanes activos.',clEsmeralda)
  end
  else
  begin
    delete(cad,length(cad),1);
    ControlChat.setMensaje(nil,'Clanes conocidos: '+cad,clEsmeralda);
  end;
  //Pedir más info al servidor:
  Cliente.SendTextNow('&K')
end;

procedure TMapaEspejo.JMostrarEstadoDelCastillo;
begin
  if castillo.clan<=maxClanesJugadores then
    Cliente.SendTextNow('KM?')
  else
    Jform.MensajeAyuda:='!Esta zona no está dominada por un clan.';
end;

procedure TMapaEspejo.JMostrarPosicionActual;
begin
  Jform.MensajeAyuda:=nombreMapa+' · mapa:'+intastr(JugadorCl.codmapa)+' x:'+intastr(jugadorCl.coordx)+
      ' y:'+intastr(jugadorCl.coordy);
  Jform.MiniMapa_DibujarSennal:=255;
  Jform.MiniMapa_X:=JugadorCL.coordx;
  Jform.MiniMapa_Y:=JugadorCL.coordy;
  Jform.ActualizarMiniMapa(true);
end;
{-------------------------------------------------------------------------------
                                 INTERFAZ
-------------------------------------------------------------------------------}
procedure IControlMenusPorMovimiento(CerrarTodosLosMenus:boolean);
begin
  case Jform.VentanaActivada of
    vaMenuComercio,vaMenuConfirmacion:if not CerrarTodosLosMenus then exit;
    vaInformacion,vaMenuOpciones:exit;
  end;
  Jform.VentanaActivada:=vaNinguna;
end;

procedure TMapaEspejo.IniciarFxAmbiental(EventoAmbiental:TFxAmbiental;intensidad:byte;pendiente:shortint);
var cad1,cad2:string;
begin
  //Sonidos ambientales
  if (tipoFxAmbiental<>EventoAmbiental) then
    case tipoFxAmbiental of//Detener sonido
      fxLluvia,fxNocheLluvia:SonidoAmbiental(snLluvia,0);
    end
  else
    if IntensidadFxAmbiental<>intensidad then
      case tipoFxAmbiental of//Cambiar intensidad de sonido
        fxLluvia,fxNocheLluvia:SonidoAmbiental(snLluvia,intensidad);
      end;
  IntensidadFxAmbiental:=intensidad;
  tipoFxAmbiental:=EventoAmbiental;
  pendienteEfectoAmbiental:=pendiente;
  if intensidad<>0 then exit;//sólo cuando inicia
  case tipoFxAmbiental of
    fxLluvia,FxNocheLluvia:begin
      cad1:='Está comenzando a ';
      cad2:='!Las armas de rango se deterioran más rápido ';
      if ((BanderasMapa and mskSonidosMapas)=bmSonidosHielos) then
      begin
        cad1:=cad1+'nevar.';
        cad2:=cad2+'con la nieve';
      end
      else
      begin
        cad1:=cad1+'llover.';
        cad2:=cad2+'en la lluvia';
      end;
    end;
    fxNiebla:begin
      cad1:='Comienza a caer la niebla.';
      cad2:='!La niebla dificulta el ataque con armas de rango (-15%)';
    end;
    FxNoche:begin
      cad1:='Comienza a anochecer.';
      cad2:='!La noche dificulta el ataque con armas de rango';
      if JugadorCl.tieneInfravision then
        cad2:=cad2+' (-10%)'
      else
        cad2:=cad2+' (-20%)'
    end;
    else cad1:='';
  end;
  if cad1<>'' then
  begin
    ControlChat.setMensaje(nil,cad1,clBronceClaro);
    JForm.AgregarMensaje(cad2);
  end;
end;

procedure TMapaEspejo.terminarEfectoAmbiental;
var cad1:string;
begin
  case tipoFxAmbiental of
    fxLluvia,FxNocheLluvia:begin
      cad1:='Está terminando de ';
      if ((BanderasMapa and mskSonidosMapas)=bmSonidosHielos) then
        cad1:=cad1+'nevar.'
      else
        cad1:=cad1+'llover.';
    end;
    fxNiebla:
      cad1:='Comienza a disiparse la niebla.';
    FxNoche:
      cad1:='Comienza a amanecer.';
  end;
  if cad1<>'' then
    ControlChat.setMensaje(nil,cad1,clBronceClaro);
  pendienteEfectoAmbiental:=-PendienteDeClima(ord(tipoFxAmbiental));
end;

procedure TMapaEspejo.TimerAmbiental;
var NuevaIntensidadClima:integer;
begin
  if Lanzar_Rayo>0 then dec(Lanzar_Rayo);
  if pendienteEfectoAmbiental<>0 then
  begin
    NuevaIntensidadClima:=IntensidadFxAmbiental+pendienteEfectoAmbiental;
    if NuevaIntensidadClima<=0 then
    begin
      pendienteEfectoAmbiental:=0;
      //Detener sonidos ambientales
      case tipoFxAmbiental of
        fxLluvia,fxNocheLluvia:SonidoAmbiental(snLluvia,0);
      end;
      case tipoFxAmbiental of
        fxNocheLluvia:begin
          tipoFxAmbiental:=FxNoche;
          IntensidadFxAmbiental:=255;
        end;
        else
        begin
          tipoFxAmbiental:=FxANinguno;
          IntensidadFxAmbiental:=0;
        end;
      end;
    end
    else
      if NuevaIntensidadClima>=255 then
      begin
        IntensidadFxAmbiental:=255;
        pendienteEfectoAmbiental:=0;
      end
      else
        IntensidadFxAmbiental:=NuevaIntensidadClima;
  end;
end;

procedure TMapaEspejo.RealizarEfectosAmbientales(EstaBajoTecho:boolean);
var AplicarOtrosEfectos:boolean;
    NivelDeOscuridad:byte;//255=maximo
begin
  NivelDeOscuridad:=0;
  if tipoFxAmbiental<>fxANinguno then
  begin
    AplicarOtrosEfectos:=true;
    if ((tipoFxAmbiental=fxLluvia)or(tipoFxAmbiental=FxNocheLluvia)) and not longBool(BanderasMapa and bmSinLluvia) then
      if ((BanderasMapa and mskSonidosMapas)=bmSonidosHielos) then//si es nieve
      begin
        if not EstaBajoTecho then
          AplicarNieveAmbiental(conta_Universal,intensidadFXAmbiental);
      end
      else
        if EstaBajoTecho then
          SonidoAmbiental(snLluvia,intensidadFXAmbiental shr 1)
        else
        begin
          SonidoAmbiental(snLluvia,intensidadFXAmbiental);
          AplicarLluviaAmbiental(conta_Universal,intensidadFXAmbiental);
          if Lanzar_Rayo>0 then
          begin
            AplicarOtrosEfectos:=false;
            if tipoFxAmbiental<FxNocheLluvia then AplicarFXAmbientalRayo;
            if Lanzar_Rayo=1 then sonido(snTrueno);
          end;
        end;
    if AplicarOtrosEfectos then
      if (tipoFxAmbiental=FxNocheLluvia) or (tipoFxAmbiental=FxNoche) then
        if (tipoFxAmbiental=FxNocheLluvia) then
          NivelDeOscuridad:=255
        else
          NivelDeOscuridad:=intensidadFXAmbiental
      else
        if (tipoFxAmbiental<>FxLluvia) then
          AplicarFXAmbiental(intensidadFXAmbiental,tipoFxAmbiental,SubTipoEfecto)
  end;
  if longBool(banderasMapa and bmMapaOscuro) then
    if longBool(banderasMapa and bmMapaDeInterior) then
      NivelDeOscuridad:=255
    else
      if NivelDeOscuridad<180 then
        NivelDeOscuridad:=180;
  if (JugadorCl.Usando[1].id=ihVaritaLlena) then dec(NivelDeOscuridad, 40);
  if NivelDeOscuridad>0 then
    AplicarFXAmbiental(NivelDeOscuridad,fxNoche,SubTipoEfecto);
  //sonidos Ambientales
  if sincro_conta_Universal and $3F=0 then
    if random(2)=0 then
      case (BanderasMapa and mskSonidosMapas) of
        bmSonidosMazmorras:Sonido(snAmbienteMazmorra);
        bmSonidosBosqueOscuro:Sonido(snAmbienteNocturno);
        bmSonidosBosque:
          if tipoFxAmbiental>=fxNoche then
          begin
            if tipoFxAmbiental<FxNocheLluvia then
              Sonido(snAmbienteNocturno)
          end
          else
            if tipoFxAmbiental<>fxLluvia then
              Sonido(snAmbienteDiurno);
        bmSonidosDesierto:
          if tipoFxAmbiental>=fxNoche then
            Sonido(snAmbienteDesiertoNocturno)
          else
            Sonido(snAmbienteDesiertoDiurno);
        bmSonidosHielos:Sonido(snAmbienteHielos);
        bmSonidosInterior:Sonido(snAmbienteInterior);
      end;
end;

function TMapaEspejo.EsFronteraCamino(x,y:integer):boolean;
begin
  result:=(x=0) or (x=256) or (y=0) or (y=256);
  if result then
  begin
    limitarExt(x,y);
    x:=FmapaTiles[x,y] and msk_Terreno_tiles;
    result:=(x>0) and (x<28);
  end;
end;

function TMapaEspejo.getTerrenoXY(x,y:integer):integer;
begin
  limitarExt(x,y);
  result:=FmapaTiles[x,y] and msk_Terreno_tiles
end;

function TMapaEspejo.getTerrenoXYParaSonido(x,y:integer):integer;
begin
  limitarExt(x,y);
  result:=FmapaTiles[x,y];
  if (result and ft_PisoPuente)=0 then
    result:=result and msk_Terreno_tiles
  else
    result:=27;//piso
end;

function TMapaEspejo.getTerrenoYFlagsXY(x,y:integer):integer;
begin
  limitarExt(x,y);
  result:=FmapaTiles[x,y];
end;

procedure TMapaEspejo.draw;
var
  J_coordx,J_coordy:smallint;
  posCentralx,posCentraly,codigoDelGrafico:integer;
  EstaBajoTecho,PuedeVerInvisibles:boolean;
//********* INICIO DE DIBUJAR MOSAICOS
  procedure DibujarMosaicos;
  var
    ter_i:integer;
    px,py:integer;
    nro_mez:integer;//para pseudo tiles entre terrenos:-1=sin transparencia
    mos_i,mos_j:integer;
    ter,ter_Base:integer;//Terreno de esquinas
    rOrigen,rDestino:Trect;
    i,j,x,y,pi,pj:integer;
    dibujarPuntosFrontera:bytebool;
      procedure DeterminarMosaico;
      //necesita ter,x,y,sincro_conta_Universal,px,py
      //modifica mos_1,mos_j,rdestino,rorigen
      begin
        //movimiento de líquidos
        case ter of
          30,28:
          begin
            mos_j:=(fast_sincro_conta_Universal+y+33101) mod 9;
            mos_i:=(x+32101+round(cos((y mod 6))*2)) mod 6;
          end;
          29,31:
          begin
            mos_j:=(fast_sincro_conta_Universal+y+33109) mod 9;
            mos_i:=(x+31017+(y+31021)*4)mod 6;
          end
          else
          begin
            case (px+py) mod 3 of
              0:mos_i:=1+random(4);
              1:mos_i:=random(6);
              else mos_i:=random(3)+random(4);
            end;
            if LongBool((x xor y)and $1) xor (mos_i<=2) then //Tablero ajedrezado
              mos_i:=5-mos_i;
            mos_j:=random(3);
          end;
        end;
        //Direct Draw://144,24
        with rOrigen do
        begin
          Left:=(ter and $3)*144+mos_i*ancho_tile;
          top:=(ter shr 2)*48+mos_j*alto_tile;
          Right:=left+ancho_tile;
          bottom:=top+alto_tile;
        end;
        with rDestino do
        begin
          Right:=i*ancho_tile-60{:( -24-24-12}-Interpolador_MaestroX;
          bottom:=j*alto_tile-40{:( -16-16-8}-Interpolador_MaestroY;
          Left:=Right-ancho_tile;
          top:=Bottom-alto_tile;
        end;
      end;
      procedure DibujarPseudoMosaico;
      begin
       if (ter<>ter_Base) then
     //   if (ter<20) or (ter>26) then
       begin
        DeterminarMosaico;
        if EstaEnPantalla(rDestino,rOrigen,false) then
          BltAlphaTile(rDestino,grafTablero.SuperficieTerreno,ROrigen,nro_mez);
       end;
      end;
      procedure DibujarMosaicosAlpha;
      begin
     // PSEUDO MOSAICOS //
     //*******************
        ter_Base:=ter;
     //  if (ter_Base<20) or (ter_Base>26) then
        begin
          ter_i:=getTerrenoXY(px+2,py+2);
          //conector
          if (pj=0) and (pi=0) then
          begin
            if getTerrenoXY(px-1,py-1)=getTerrenoXY(px,py-1) then
            begin
              if getTerrenoXY(px-1,py)<>getTerrenoXY(px,py) then
              begin
                ter:=getTerrenoXY(px-1,py);
                nro_mez:=MZ_v;
                DibujarPseudoMosaico;
              end;
              ter:=getTerrenoXY(px,py-1);
              nro_mez:=MZ_h;
              DibujarPseudoMosaico;
            end
            else
            begin
              if getTerrenoXY(px-1,py-1)=getTerrenoXY(px-1,py) then
              begin
                if getTerrenoXY(px,py-1)<>getTerrenoXY(px,py) then
                begin
                  ter:=getTerrenoXY(px,py-1);
                  nro_mez:=MZ_h;
                  DibujarPseudoMosaico;
                end;
                ter:=getTerrenoXY(px-1,py);
                nro_mez:=MZ_v;
                DibujarPseudoMosaico;
              end
              else
                if getTerrenoXY(px-1,py)=getTerrenoXY(px,py) then
                begin
                  if getTerrenoXY(px-1,py)<>getTerrenoXY(px,py-1) then
                  begin
                    ter:=getTerrenoXY(px-1,py-1);
                    nro_mez:=MZ_h;
                    DibujarPseudoMosaico;
                  end;
                  if getTerrenoXY(px,py)<>getTerrenoXY(px-1,py) then
                  begin
                    ter:=getTerrenoXY(px-1,py-1);
                    nro_mez:=MZ_id;
                    DibujarPseudoMosaico;
                  end;
                end
                else
                begin
                  ter:=getTerrenoXY(px-1,py);
                  nro_mez:=MZ_v;
                  DibujarPseudoMosaico;
                  if getTerrenoXY(px,py)<>getTerrenoXY(px-1,py) then
                  begin
                    ter:=getTerrenoXY(px-1,py-1);
                    nro_mez:=MZ_id;
                    DibujarPseudoMosaico;
                  end;
                end;
                if getTerrenoXY(px,py-1)<>getTerrenoXY(px,py) then
                begin
                  ter:=getTerrenoXY(px,py-1);
                  nro_mez:=MZ_ii;
                  DibujarPseudoMosaico;
                end;
            end;
          end// fin de conector (0,0)
          else
          if (pj=0) and (pi=2) then
          begin
            ter:=getTerrenoXY(px+2,py-1);
            nro_mez:=MZ_h;
            DibujarPseudoMosaico;
          end
          else
          if (pi=0) and (pj=2) then
          begin
            ter:=getTerrenoXY(px-1,py+2);
            nro_mez:=MZ_v;
            DibujarPseudoMosaico;
          end
          else
          begin
            // esquina superior izquierda
            nro_mez:=MZ_nulo;
            if (pi<=1) and (pj<=1) then
            begin
              if getTerrenoXY(px,py)<>ter_i then
              // diagonal
              begin
                if (pj+pi=1) then
                begin
                  ter:=ter_i;
                  nro_mez:=MZ_si;
                end
                else if (pj+pi=2) then
                begin
                  ter:=getTerrenoXY(px,py);
                  nro_mez:=MZ_id;
                end;
              end;
            end
            else
            // esquina superior derecha
            if (pi>=3) and (pj<=1) then
            begin
              if getTerrenoXY(px+3,py)<>ter_i then
              // diagonal
              begin
                if (pi-pj=3) then
                begin
                  ter:=ter_i;
                  nro_mez:=MZ_sd;
                end
                else if (pi-pj=2) then
                begin
                  ter:=getTerrenoXY(px+3,py);
                  nro_mez:=MZ_ii;
                end;
              end;
            end
            else
            // esquina inferior izquierda
            if (pi<=1) and (pj>=3) then
            begin
              if getTerrenoXY(px,py+3)<>ter_i then
              // diagonal
              begin
                if (pj-pi=3) then
                begin
                  ter:=ter_i;
                  nro_mez:=MZ_ii;
                end
                else if (pj-pi=2) then
                begin
                  ter:=getTerrenoXY(px,py+3);
                  nro_mez:=MZ_sd;
                end;
              end;
            end
            else
            // esquina inferior derecha
            if (pi=3) and (pj=3) then
            begin
              if {(getTerrenoXY(px+3,py+4)<>ter_i) and (getTerrenoXY(px+4,py+3)<>ter_i)}
                (getTerrenoXY(px+3,py+4)=getTerrenoXY(px+4,py+3)) then
              // diagonal
              begin
                ter:=getTerrenoXY(px+3,py+4);
                nro_mez:=MZ_si;
              end;
            end;
            if (nro_mez<>MZ_nulo) then
              DibujarPseudoMosaico;
          end;
          //mosaicos alternantes:
          nro_mez:=MZ_nulo;
          if (pj=0) then
          begin
            if (pi=1) then
              if getTerrenoXY(px,py-1)<>getTerrenoXY(px+2,py-2) then
              begin
                ter:=getTerrenoXY(px+2,py-2);
                nro_mez:=MZ_ii;
              end
              else
              begin
                ter:=getTerrenoXY(px+1,py-1);
                nro_mez:=MZ_h2;
              end;
            if (pi=3) then
              if (getTerrenoXY(px+4,py-1)<>getTerrenoXY(px+2,py-2)) and
                (getTerrenoXY(px+4,py-1)=getTerrenoXY(px+3,py)) then
              begin
                ter:=getTerrenoXY(px+2,py-2);
                nro_mez:=MZ_id;
              end
              else
              begin
                ter:=getTerrenoXY(px+3,py-1);
                nro_mez:=MZ_h2;
              end;
          end;
          if (pi=0) then
          begin
            if (pj=1) then
              if getTerrenoXY(px-1,py)<>getTerrenoXY(px-2,py+2) then
              begin
                ter:=getTerrenoXY(px-2,py+2);
                nro_mez:=MZ_sd;
              end
              else
              begin
                ter:=getTerrenoXY(px-1,py+1);
                nro_mez:=MZ_v2;
              end;
            if (pj=3) then
              if (getTerrenoXY(px-1,py+4)<>getTerrenoXY(px-2,py+2)) and
                (getTerrenoXY(px-1,py+4)=getTerrenoXY(px,py+3)) then
              begin
                ter:=getTerrenoXY(px-2,py+2);
                nro_mez:=MZ_id;
              end
              else
              begin
                ter:=getTerrenoXY(px-1,py+3);
                nro_mez:=MZ_v2;
              end;
          end;
          if (nro_mez<>MZ_nulo) then
            DibujarPseudoMosaico;
        end;
      end;
  begin
    dibujarPuntosFrontera:=bytebool(fast_sincro_conta_Universal and $6);
    for j:=0 to 29 do//límites minimos comprobados
    begin
      y:=j+J_coordy-14;
      py:=y and $FFFFFFFC;
      pj:=y and $3;
      for i:=0 to 33 do//límites minimos comprobados
      begin
        x:=i+J_coordx-16;
        px:=x and $FFFFFFFC;
        pi:=x and $3;
        RandSeed:=((x+31)*(y+17)*197+(x+19)*21+y*23)*91;
        ter:=getTerrenoYFlagsXY(x,y);
        if not bytebool(ter and ft_Nodibujar) then
        begin
          ter:=ter and msk_Terreno_tiles;
          DeterminarMosaico;
          if EstaEnPantalla(rDestino,rOrigen,false) then
          begin
            SuperficieRender.BltFast(rDestino.left,rDestino.top,grafTablero.SuperficieTerreno,@rOrigen,DDBLTFAST_NOCOLORKEY);
            DibujarMosaicosAlpha;
            if dibujarPuntosFrontera and EsFronteraCamino(x,y) then
            begin
              with rOrigen do
              begin
                Left:=0;
                top:=0;
                Right:=3;
                bottom:=2;
              end;
              with rDestino do
              begin
                Right:=i*ancho_tile-69{ -21-24-24:(}-Interpolador_MaestroX;
                bottom:=j*alto_tile-46{ -6-32-8:(}-Interpolador_MaestroY;
                Left:=Right-3;
                top:=Bottom-2;
              end;
              if EstaEnPantalla(rDestino,rOrigen,false) then
                BltZonaFrontera(rDestino);
            end;
          end;
        end;
      end;
    end;
  end;
//********* FIN DE DIBUJAR MOSAICOS
  procedure DibujarGraficosYSprites;
  var posyact,posyant,i,j,x,y:integer;
      limitey:integer;
      primero,ultimo:integer;
      RefMonstruo:TmonstruoS;
      Ritmo_sprite:smallint;
      CodAnimeSpriteMapa,efectosGlobales,efectosPorGrafico:byte;
      SpriteVisible:boolean;
      function BuscarIndice(clave:integer):integer;
      var central,bajo,alto:integer;
      begin
        result:=0;
        bajo:=0;
        alto:=N_Graficos-1;
        repeat
          central:=(bajo+alto) div 2;
          if clave<grafico[central].posy then
          begin
            //verifica limites de lista con central<=bajo
            if (central<=bajo) or (clave>=grafico[central-1].posy) then
            begin
              result:=central;
              break;
            end
            else
              alto:=central-1
          end
          else
          begin
            //verifica limites de lista con central>=alto
            if (central>=alto) or (clave<grafico[central+1].posy) then
            begin
              result:=central;
              break;
            end
            else
              bajo:=central+1;
          end;
        until (Bajo>Alto);
      end;

      procedure DibujarSpritesPiso(SubCoordBase:integer);
      var i:integer;
          iniciox,finx,posx,posy,posyBase:integer;
          info:word;
        procedure CalculosGraficacion;
        begin
          posx:=posCentralx+i*ancho_tile;
          if (mapaPos[i,SubCoordBase].terBol and ft_Agua)<>0 then
            posy:=posyBase+3
          else
            posy:=posyBase;
          if (i+SubCoordBase) and $1=0 then
            info:=fgfx_Espejo
          else
            info:=0;
          randSeed:=i*7+SubCoordBase*13;
        end;
      begin
        if abs(SubCoordBase-J_coordy)>=MaxRefrescamientoY then exit;
        if SubCoordBase<0 then exit;
        if SubCoordBase>MaxMapaAreaExt then exit;
        posyBase:=posCentraly+SubCoordBase*alto_tile;
        //Bolsas, fogatas, cadaveres
        iniciox:=J_coordx-15;
        if iniciox<0 then iniciox:=0;
        finx:=J_coordx+15;
        if finx>MaxMapaAreaExt then finx:=MaxMapaAreaExt;
        for i:=iniciox to finx do
          case TTipoBolsa(mapaPos[i,SubCoordBase].terbol and mskBolsa) of
            tbCadaver:
              if animas.animacion[anCadaver]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnCadaver]).drawEspecial(
                  posx,posy,random(4),info);
              end;
            tbCadaverVerde:
              if animas.animacion[anCadaver]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnCadaver]).drawEspecial(
                  posx,posy,6+random(2),info);
              end;
            tbCadaverQuemado:
              if animas.animacion[anCadaver]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnCadaver]).drawEspecial(
                  posx,posy,4+random(2),info);
              end;
            tbCadaverEnergia:
              if animas.animacion[fxAura3]<>nil then
              begin
                CalculosGraficacion;
                info:=(sincro_conta_Universal and $1F);
                if info>16 then info:=32-info;
                info:=$0040A0+(info shl 10);
                TAnimacionEfecto(animas.animacion[fxAura3]).drawXYEfecto(
                  posx,posy,0,info,fxSumaSaturada);
              end;
            tbCadaverArdiente:
              if animas.animacion[anCadaver]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnCadaver]).drawEspecial(
                  posx,posy,4+random(2),info);
              end;
            tbCenizas:
              if animas.animacion[anBolsa]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnBolsa]).drawEspecial(
                  posx,posy,7,info);
              end;
            tbTrampaMagica:
              if animas.animacion[anBolsa]<>nil then
              begin
                CalculosGraficacion;
                if JugadorCl.CapacidadId<>ciVerRealmente then
                  info:=info or fgfx_TransparenteNatural;
                TAnimacionObjeto(animas.animacion[AnBolsa]).drawEspecial(
                  posx,posy,4,info);
              end;
            tbLenna,tbFogata:
              if animas.animacion[anBolsa]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnBolsa]).drawEspecial(
                  posx,posy,6,info);
              end;
          end;
        //Auras de fondo de monstruos y jugadores
        for i:=iniciox to finx do
        begin
          RefMonstruo:=GetMonstruoCasilla(i,SubCoordBase);
          if RefMonstruo<>nil then
            with RefMonstruo do
            if puedeVerInvisibles or ((banderas and bnInvisible)=0) or (RefMonstruo=JugadorCl) then
              DrawAurasPiso(refMonstruo,
                posCentralX+coordX*ancho_tile+
                (coordx_ant-coordx)*Paso_InterpoladoX*control_movimiento,
                posCentralY+coordY*alto_tile+
                (coordy_ant-coordy)*Paso_InterpoladoY*control_movimiento);
        end;
      end;

      procedure DibujarSprites(SubCoordBase:integer);
      var i,iniciox,finx,posx,posy,posyBase:integer;
          RefMonstruo:TmonstruoS;
          efectosAdicionales:byte;
        procedure CalculosGraficacion;
        begin
          posx:=posCentralx+i*ancho_tile;
          if (mapaPos[i,SubCoordBase].terBol and ft_Agua)<>0 then
            posy:=posyBase+3
          else
            posy:=posyBase;
          if (i+(SubCoordBase shl 1)) and $1=0 then
            efectosAdicionales:=fgfx_Espejo
          else
            efectosAdicionales:=0;
          randSeed:=i+SubCoordBase*3;
        end;
      begin
        if abs(SubCoordBase-J_coordy)>=MaxRefrescamientoY then exit;
        if SubCoordBase<0 then exit;
        if SubCoordBase>MaxMapaAreaExt then exit;
        posyBase:=posCentraly+SubCoordBase*alto_tile;
        //Bolsas, fogatas, cadaveres
        iniciox:=J_coordx-15;
        if iniciox<0 then iniciox:=0;
        finx:=J_coordx+15;
        if finx>MaxMapaAreaExt then finx:=MaxMapaAreaExt;
        for i:=iniciox to finx do
          case TTipoBolsa(mapaPos[i,SubCoordBase].terbol and mskBolsa) of
            tbComun:
              if animas.animacion[anBolsa]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnBolsa]).drawEspecial(
                  posx+random(7)-3,posy+random(5)-2,randSeed and $3,efectosAdicionales);
              end;
            tbCadaver,tbCadaverVerde:
              if animas.animacion[anMoscas]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnMoscas]).drawEspecial(
                  posx,posy,(fast_sincro_conta_Universal+randSeed) and $7,efectosAdicionales);
              end;
            tbCadaverAvatar:
              if animas.animacion[anBolsa]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionObjeto(animas.animacion[AnBolsa]).drawEspecial(
                  posx,posy,5,efectosAdicionales);
              end;
            tbCadaverArdiente,tbFogata:
              if animas.animacion[fxfogata]<>nil then
              begin
                CalculosGraficacion;
                TAnimacionEfecto(animas.animacion[fxFogata]).drawXY(
                  posx,posy,(fast_sincro_conta_Universal+randSeed) and $7);
              end;
          end;
      //Monstruos y Jugadores
        for i:=iniciox to finx do
        begin
          RefMonstruo:=GetMonstruoCodigoCasilla(getMonRecXY(i,SubCoordBase));
          if RefMonstruo<>nil then
          with RefMonstruo do
            if activo then
            begin
              posy:=posCentralY;
              if (mapaPos[i,SubCoordBase].terBol and ft_Agua)<>0 then inc(posy,6);//!!!
              SpriteVisible:=puedeVerInvisibles or ((banderas and bnInvisible)=0) or (RefMonstruo=JugadorCl);
              if SpriteVisible or (accion<>aaParado) then
                DrawSprite(RefMonstruo,posCentralx,{posCentralY}posY,not SpriteVisible);
            end;
        end;//for
        //Efectos magicos
        controlFX.draw(posCentralx,posCentralY,J_coordx,SubCoordBase);
      end;
  begin
    //Determinar si esta bajo techo.
    EstaBajoTecho:=(MapaPos[J_coordx,J_coordy].terbol and ft_Cubierto)<>0;
    PuedeVerInvisibles:=((JugadorCl.CapacidadId and ciInvisibles)<>0) or (JugadorCl.hp=0);
    //Referencia al mapa global
    if Graficos_Transparentes then
      efectosGlobales:=fgfx_TransparenteForzado
    else
      efectosGlobales:=0;
    limitey:=40;
    //Dibujar Graficos y Sprites en orden.
    //------------------------------------
    //Determinar primero y ultimo;
    //busqueda lineal de posy-15, a posy+40
    primero:=BuscarIndice(J_coordy-15);
    ultimo:=BuscarIndice(J_coordy+limitey);
    for i:=primero to ultimo do
    with grafico[i] do
    begin
      codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
      if codigoDelGrafico<=MAX_OBJETOS_GRAFICOS then
      if InfGra[codigoDelGrafico].tipo>=tg_Piso then
      begin//pisos y objetos del terreno
        if (posx+20>J_coordx) and (posx-21<J_coordx) then
          if grafTablero.Grafico[codigoDelGrafico]<>nil then //Seguridad necesaria
          begin
            x:=(posx+9-J_coordx)*ancho_tile-Interpolador_MaestroX;
            y:=(posy-InfGra[codigoDelGrafico].aliny+11-J_coordy)*alto_tile-Interpolador_MaestroY;
            if bytebool(flagsGrafico and fgfx_levitacion) then
              dec(y,MA_Levitacion8[(conta_Universal+posx+posy) shr Desplazador_AniSincro and $7]-2);
            grafTablero.Grafico[codigoDelGrafico].draw(x,y,flagsGrafico);
          end;
      end;
    end;
    //Entre los pisos y los sprites.
    for j:=J_coordy-15 to J_coordy+15 do
      dibujarSpritesPiso(j);
    //Mira para apuntar
    jugadorCL.DrawMira(conta_Universal and $7);
    //Lista de objetos gráficos
    posyact:=J_coordy-15;//Comenzar desde este nivel
    for i:=primero to ultimo do
    with grafico[i] do
     if (posx+19>J_coordx) and (posx-20<J_coordx) then
      if((flagsGrafico and fgfx_SensibleAFlags)=0)or
      (((FlagsCalabozo and (1 shl (codigoFlags shr DzSensibilidadFlags)))<>0) xor ((codigoFlags and MskFlagInverso)<>0))then
      begin
        codigoDelGrafico:=codigoFlags and MskCodigoGrafico;
        if codigoDelGrafico>MAX_OBJETOS_GRAFICOS then//SPRITES
        begin
          posyant:=posyact;
          posyact:=posy;
          for j:=posyant to posyact-1 do
            dibujarSprites(j);
          CodAnimeSpriteMapa:=codigoDelGrafico and $FF;
          Ritmo_sprite:=(fast_sincro_conta_Universal+i) and $7;
          x:=(posx+13-J_coordx)*ancho_tile-Interpolador_MaestroX;
          y:=(posy+11-J_coordy)*alto_tile-Interpolador_MaestroY;
          if bytebool(flagsGrafico and fgfx_levitacion) then
            dec(y,MA_Levitacion8[(conta_Universal+posx+posy) shr Desplazador_AniSincro and $7]);
          case CodAnimeSpriteMapa of
            fxFlamaBlanca,fxFogata,fxFlamaAzul,fxHumo,fxExplosion1,fxExplosion2,fxExplosion3:
              if animas.animacion[CodAnimeSpriteMapa]<>nil then
                TAnimacionEfecto(animas.animacion[CodAnimeSpriteMapa]).drawXY(x,y,Ritmo_sprite);
            fxAntorcha1..fxAltarB:
              if animas.animacion[fxFogata]<>nil then
                with TAnimacionEfecto(animas.animacion[fxFogata]) do
                begin
                  if CodAnimeSpriteMapa>=fxAltar1 then
                    dec(y,28)
                  else
                  begin
                    if bytebool(flagsGrafico and fgfx_espejo) then dec(x,3) else inc(x,3);
                    dec(y,30);
                  end;
                  case CodAnimeSpriteMapa of
                    fxAntorcha2,fxAltar2:drawXYEfecto(x,y,Ritmo_sprite,$60C000,fxSumaSaturada);
                    fxAntorcha3,fxAltar3:drawXYEfecto(x,y,Ritmo_sprite,$E80078,fxSumaSaturada);
                    fxAntorchaR,fxAltarR:drawXYEfecto(x,y,Ritmo_sprite,$0000E0,fxSumaSaturada);
                    fxAntorchaG,fxAltarG:drawXYEfecto(x,y,Ritmo_sprite,$00E000,fxSumaSaturada);
                    fxAntorchaB,fxAltarB:drawXYEfecto(x,y,Ritmo_sprite,$E00000,fxSumaSaturada);
                    else drawXY(x,y,Ritmo_sprite);
                  end;
                end;
            fxPortal,fxPortal1,fxPortal2,fxPortal3:
              if animas.animacion[fxPortal]<>nil then
                with TAnimacionEfecto(animas.animacion[fxPortal]) do
                begin
                  case CodAnimeSpriteMapa of
                    fxPortal1:drawFX(x,y,Ritmo_sprite,$70C8FF,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                    fxPortal2:drawFX(x,y,Ritmo_sprite,$80A000,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                    fxPortal3:drawFX(x,y,Ritmo_sprite,$E80040,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                    else drawFX(x,y,Ritmo_sprite,$808080,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                  end;
                end;
            fxPersonalizado0,fx0R,fx0G,fx0B:
              if animas.animacion[fxPersonalizado0]<>nil then
                with TAnimacionEfecto(animas.animacion[fxPersonalizado0]) do
                begin
                  case CodAnimeSpriteMapa of
                    fx0R:drawFX(x,y,Ritmo_sprite,$2040FF,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                    fx0G:drawFX(x,y,Ritmo_sprite,$00A880,fxSumaSaturadaColor,bytebool(flagsGrafico and fgfx_espejo));
                    fx0B:drawFX(x,y,Ritmo_sprite,$E80080,fxSumaSaturadaColor,bytebool(flagsGrafico and fgfx_espejo));
                    else drawFX(x,y,Ritmo_sprite,$808088,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                  end;
                end;
            fxPersonalizado1,fx1R,fx1G,fx1B:
              if animas.animacion[fxPersonalizado1]<>nil then
                with TAnimacionEfecto(animas.animacion[fxPersonalizado1]) do
                begin
                  case CodAnimeSpriteMapa of
                    fx1R:drawFX(x,y,Ritmo_sprite,$20D8FF,fxSumaSaturadaColor,bytebool(flagsGrafico and fgfx_espejo));
                    fx1G:drawFX(x,y,Ritmo_sprite,$20C020,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                    fx1B:drawFX(x,y,Ritmo_sprite,$E86000,fxSumaSaturadaColor,bytebool(flagsGrafico and fgfx_espejo));
                    else drawFX(x,y,Ritmo_sprite,$808880,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                  end;
                end;
            fxPersonalizado2,fx2R,fx2G,fx2B:
              if animas.animacion[fxPersonalizado2]<>nil then
                with TAnimacionEfecto(animas.animacion[fxPersonalizado2]) do
                begin
                  case CodAnimeSpriteMapa of
                    fx2R:drawFX(x,y,Ritmo_sprite,$9040FF,fxSumaSaturadaColor,bytebool(flagsGrafico and fgfx_espejo));
                    fx2G:drawFX(x,y,Ritmo_sprite,$90A000,fxSumaSaturadaColor,bytebool(flagsGrafico and fgfx_espejo));
                    fx2B:drawFX(x,y,Ritmo_sprite,$E81818,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                    else drawFX(x,y,Ritmo_sprite,$888080,fxSumaSaturada,bytebool(flagsGrafico and fgfx_espejo));
                  end;
                end;
            fxFlamaAltar1:
              if animas.animacion[fxFlamaBlanca]<>nil then
                with TAnimacionEfecto(animas.animacion[fxFlamaBlanca]) do
                begin
                  if bytebool(flagsGrafico and fgfx_espejo) then inc(x,4) else dec(x,4);
                  drawXY(x,y-66,Ritmo_sprite);
                end;
            fxFlamaAltar2:
              if animas.animacion[fxFlamaBlanca]<>nil then
                TAnimacionEfecto(animas.animacion[fxFlamaBlanca]).drawXY(x,y-65,Ritmo_sprite);
            fxFundicion:
              if animas.animacion[fxFogata]<>nil then
                with TAnimacionEfecto(animas.animacion[fxFogata]) do
                begin
                  drawXY(x-12,y-11,(fast_sincro_conta_Universal+3) and $7);
                  drawXY(x,y-9,Ritmo_sprite);
                  drawXY(x+12,y-11,(fast_sincro_conta_Universal+6) and $7);
                end;
            fxHumoChimenea:
              if not EstaBajoTecho then
                if animas.animacion[fxHumo]<>nil then
                  with TAnimacionEfecto(animas.animacion[fxHumo]) do
                  begin
                    if bytebool(flagsGrafico and fgfx_espejo) then dec(x,29) else inc(x,29);
                    drawXY(x,y-166,Ritmo_sprite);
                  end;
            anEstandarte:
              with castillo do
                if clan<=maxClanesJugadores then
                  with ClanJugadores[clan].PendonClan do
                    if color0<>0 then
                      if animas.animacion[AnEstandarte+(color1 shr 30)]<>nil then
                      begin
                        if bytebool(flagsGrafico and fgfx_espejo) then inc(x,12) else dec(x,12);
                        TAnimacionEfecto(animas.animacion[AnEstandarte+(color1 shr 30)]).drawXYTablaColor(x,y-4,fast_sincro_conta_Universal and $7,color0,color1,efectosGlobales or flagsGrafico);
                      end;
          end;
        end
        else
          //dibujar si es un gráfico normal
          if (InfGra[codigoDelGrafico].tipo=tg_Normal)
           //o si es un techo y no está bajo techo.
           or ((InfGra[codigoDelGrafico].tipo=tg_Techo) and not EstaBajoTecho) then
            if grafTablero.Grafico[codigoDelGrafico]<>nil then //necesario
            begin
              posyant:=posyact;
              posyact:=posy;
              for j:=posyant to posyact-1 do
                dibujarSprites(j);
              x:=(posx+9-J_coordx)*ancho_tile-Interpolador_MaestroX;
              y:=(posy-InfGra[codigoDelGrafico].aliny+11-J_coordy)*alto_tile-Interpolador_MaestroY;
              if bytebool(flagsGrafico and fgfx_levitacion) then
                dec(y,MA_Levitacion8[(conta_Universal+posx+posy) shr Desplazador_AniSincro and $7]);
              if bytebool(flagsGrafico and fgfx_Ilusion) and PuedeVerInvisibles then
                efectosPorGrafico:=efectosGlobales or fgfx_TransparenteNatural
              else
                efectosPorGrafico:=efectosGlobales;
              grafTablero.Grafico[codigoDelGrafico].draw(x,y,efectosPorGrafico or flagsGrafico);
            end;
      end;
    for i:=posyact to (J_coordy+15) do
      dibujarSprites(i);

    //Dibujar Nombres encima de todo:
    if Graficos_Transparentes then
    begin
      if J_coordY<=11 then posyant:=0 else posyant:=J_coordY-11;//limitar
      if J_coordY>=MaxMapaAreaExt-10 then posyact:=MaxMapaAreaExt else posyact:=J_coordY+10;//limitar
      if J_coordX<=13 then primero:=0 else primero:=J_coordX-13;//limitar
      if J_coordX>=MaxMapaAreaExt-13 then ultimo:=MaxMapaAreaExt else ultimo:=J_coordX+13;//limitar
      for y:=posyant to posyact do
        for x:=primero to ultimo do
        begin
          RefMonstruo:=GetMonstruoCasilla(x,y);
          if RefMonstruo=nil then continue;//este no va, siguiente
          with RefMonstruo do
            if puedeVerInvisibles or (((banderas and bnInvisible)=0) and (codAnime<Inicio_tipo_monstruos)) then
                DrawNombreSprite(refMonstruo,
                posCentralX+coordX*ancho_tile+
                (coordx_ant-coordx)*Paso_InterpoladoX*control_movimiento,
                posCentralY+coordY*alto_tile+
                (coordy_ant-coordy)*Paso_InterpoladoY*control_movimiento
              );
        end;
    end;
  end;
begin
//coordenadas para dibujar
  with JugadorCl do
  begin
    J_coordx:=coordx;
    J_coordy:=coordy;
    Interpolador_MaestroX:=(coordx_ant-coordx)*Paso_InterpoladoX*control_movimiento;
    Interpolador_MaestroY:=(coordy_ant-coordy)*Paso_InterpoladoY*control_movimiento;
  end;
  posCentralx:=DDraw_mitad_sprite_X-J_coordx*ancho_tile-Interpolador_MaestroX;
  posCentraly:=DDraw_mitad_sprite_Y-J_coordy*alto_tile-Interpolador_MaestroY;
//Dibujar mosaicos:
  DibujarMosaicos;
//DIBUJAR OBJETOS.
  DibujarGraficosySprites;
//Solo para el cliente!!
  randomize;
//Efectos
  RealizarEfectosAmbientales(EstaBajoTecho);
//Mensajes:
  controlMensajes.draw(posCentralX,posCentralY);
end;

function TMapaEspejo.GetMonstruoXY(x,y:byte):TmonstruoS;
var casilla:word;
begin
  casilla:=mapaPos[x,y].monRec;
  case casilla and fl_con of
    ccJgdr:result:=Jugador[casilla and fl_cod];
    ccMon:result:=Monstruo[casilla and fl_cod];
    else result:=nil;
  end;
end;

procedure TMapaEspejo.DibujarPergamino(SuperficieDD:IDirectDrawSurface7;x,y:byte);
const Zona_Origen:Trect=(left:0;top:0;right:128;bottom:128);
var
    contaO:pointer;
    TotalPixeles:integer;
    cambio:boolean;
    indice,base,tipoTerreno,i2,j2:integer;
    iniciox,inicioy:byte;
begin
  if SuperficieDD.lock(@Zona_Origen,DescSuperficieLockUnlock,DDLOCK_WAIT,0)=DD_OK then
  begin
    ContaO:=DescSuperficieLockUnlock.lpSurface;
    with Zona_Origen do
      TotalPixeles:=integer(ContaO)+((bottom-top)*DescSuperficieLockUnlock.lPitch)-2;
    cambio:=false;//control de textura
    indice:=0;
    if (BanderasMapa and MskSonidosMapas)<>bmSonidosInterior then
      while integer(contaO)<=TotalPixeles do
      begin
        i2:=(indice and $7F) shl 1;
        j2:=(indice shr 6) and $FE;
        base:=0;
        if (MapaPos[i2,j2].monRec<>ccVac) then inc(base,32);
        if (MapaPos[i2+1,j2].monRec<>ccVac) or bytebool(fMapaTiles[i2+1,j2] and ft_PisoPuente) then inc(base,32);
        if (MapaPos[i2,j2+1].monRec<>ccVac) or bytebool(fMapaTiles[i2,j2+1] and ft_PisoPuente) then inc(base,32);
        if (MapaPos[i2+1,j2+1].monRec<>ccVac) then inc(base,32);
        if random(3)=0 then cambio:=not cambio;
        if (base=0) and cambio then base:=160;
        word(contaO^):=Paleta_pergamino_mapa[fMapaTiles[i2,j2] and msk_Terreno_tiles+base];
        word(contaO^):=((word(contaO^) and mskTrans) + Paleta_pergamino_mapa[fMapaTiles[i2+1,j2+1] and msk_Terreno_tiles+base]) shr 1;
        word(contaO^):=((word(contaO^) and mskTrans) + Paleta_pergamino_mapa[fMapaTiles[i2+1,j2] and msk_Terreno_tiles+base]) shr 1;
        word(contaO^):=((word(contaO^) and mskTrans) + Paleta_pergamino_mapa[fMapaTiles[i2,j2+1] and msk_Terreno_tiles+base]) shr 1;
        inc(indice);
        inc(integer(ContaO),2);
      end
    else
    begin
      //obtener cuadrante valido
      iniciox:=x and $80;
      inicioy:=y and $80;
      while integer(contaO)<=TotalPixeles do
      begin
        i2:=(indice and $7F)+iniciox;
        j2:=(indice shr 7)+inicioy;
        base:=0;
        if (MapaPos[i2,j2].monRec<>ccVac) {or bytebool(fMapaTiles[i2,j2] and ft_PisoPuente)} then inc(base,32);
        if random(3)=0 then cambio:=not cambio;
        tipoTerreno:=fMapaTiles[i2,j2] and msk_Terreno_tiles;
        if (base=0) and (tipoTerreno=0) then
        begin//sin edificios y tipo de terreno abismo
          if cambio then base:=$39E7 else base:=$3186;
          word(contaO^):=base;
        end
        else
        begin
          if (base=0) and cambio then base:=160;
          word(contaO^):=Paleta_pergamino_mapa[base+tipoTerreno];
        end;
        inc(indice);
        inc(integer(ContaO),2);
      end
    end;
    SuperficieDD.unlock(@Zona_Origen);
  end;
end;

function GetMonstruoCodigoCasilla(CodigoCasilla:word):TmonstruoS;
begin
  if CodigoCasilla<=maxJugadores then
    result:=Jugador[CodigoCasilla]//Ok, funciona
  else
  begin
    dec(CodigoCasilla,ccMon);
    if CodigoCasilla<=MaxMonstruos then
      result:=Monstruo[CodigoCasilla]
    else
      result:=nil;
  end;
end;

function TMapaEspejo.GetMonstruoCasilla(x,y:byte):TmonstruoS;
var casilla:word;
begin
  casilla:=mapaPos[x,y].monRec;
  if casilla<=maxJugadores then
    result:=Jugador[casilla]//Ok, funciona
  else
  begin
    dec(casilla,ccMon);
    if casilla<=MaxMonstruos then
      result:=Monstruo[casilla]
    else
      result:=nil;
  end;
end;

function TMapaEspejo.NombreMonstruo(RMonstruo:TmonstruoS;MostrarDialogo:boolean):string;
var s:string;
  function NombreComportamiento(comportamiento:byte):string;
  begin
    case comportamiento of
      comPacifico,comHerbivoro:result:=', Pacífico';
      comTerritorial:result:=', Territorial';
      comGuerreroMago,comAgresivo,comAtaqueRango,comAtaqueHechizos:result:=', Agresivo';
      comDefensaEstatica,comGuardia:result:=', Guardián';
      comObjetoDummy:result:='';
      else result:='';
    end;
  end;
begin
  with RMonstruo do
    if comportamiento=comComerciante then
      if duenno<N_Comerciantes then
      begin
        s:=getPedazoCadenaBarra(TextoComerciante[duenno],1);
        if s='' then
        begin
          result:=MC_NombresComerciantes[Comerciante[duenno].tipo];
          if MostrarDialogo then
            result:=result+' (Comerciante)';
        end
        else
          result:=s;
        if MostrarDialogo then
          ControlMensajes.setMensaje(RMonstruo,getPedazoCadenaBarra(TextoComerciante[duenno],0));
      end
      else
        result:='?'//no definido
    else
      with InfMon[TipoMonstruo] do
      begin
        result:=nombre;
        if MostrarDialogo then
          result:=result+', nivel '+intastr(nivelMonstruo+
            ((rMonstruo.banderas and MskPoderMonstruo) shr DsPoderMonstruo)*(nivelMonstruo shr 2+1))+
            NombreComportamiento(comportamiento);
      end;
end;

procedure TMapaEspejo.ControlSensoresJugador;
var i:integer;
    posicion:byte;
begin
  i:=MapaSensor[JugadorCl.coordx,JugadorCl.coordy];
  if i<N_Sensores then
    with sensor[i] do
    begin
      if tipo=tsCBandera then exit;
      if (flagsSensor and fs_solofantasma)<>0 then
        if JugadorCl.hp<>0 then
        begin
          JForm.AgregarMensaje(getPedazoCadenaBarra(textoSensor[i],3));
          exit;
        end;
      if (flagsSensor and fs_soloaprendiz)<>0 then
        if JugadorCl.nivel>MAX_NIVEL_NEWBIE then
        begin
          JForm.AgregarMensaje(getPedazoCadenaBarra(textoSensor[i],3));
          exit;
        end;
      if (flagsSensor and fs_soloClan)<>0 then
        if (JugadorCl.clan>MaxClanesJugadores) or (JugadorCl.clan<>Castillo.clan) then
        begin
          JForm.AgregarMensaje(getPedazoCadenaBarra(textoSensor[i],3));
          exit;
        end;
      //Condiciones que deben cumplirse antes de usar un sensor:
      //- Si no cumplen las condiciones, salir de este procedimiento
      case Tipo of
        tsFundarClan:
          if (JugadorCl.pericias and hbLiderazgo)=0 then
          begin
            JForm.AgregarMensaje('No tienes la pericia de liderazgo para fundar un clan');
            exit;
          end
          else
            if (JugadorCl.nivel<=MAX_NIVEL_CON_BONO) then
            begin
              JForm.AgregarMensaje('Necesitas tener nivel '+intastr(MAX_NIVEL_CON_BONO+1)+' para fundar un clan');
              exit;
            end
            else
              if JugadorCl.clan<=maxClanesJugadores then//ya tiene un clan
              begin
                JForm.AgregarMensaje('Primero abandona tu clan para fundar uno nuevo.');
                exit;
              end;
      end;
      //Mensajes al usar un sensor:
      if (Tipo=tsFBandera) or (Tipo=tsLBandera) then
        if ((FlagsCalabozo and (dato1 or (dato2 shl 8) or (dato3 shl 16) or (dato4 shl 24)))<>0) xor (Tipo=tsLBandera) then
          exit;
      posicion:=(flagsSensor and fs_consumirLlave);
      if JugadorCl.TieneLaLlave(llave1,llave2,flagsCalabozo,posicion) then
        JForm.AgregarMensaje(getPedazoCadenaBarra(textoSensor[i],1))
      else
        JForm.AgregarMensaje(getPedazoCadenaBarra(textoSensor[i],0));
    end;
end;

function TMapaEspejo.DescribirPosicion(posx,posy:integer):string;
begin
  if (banderasMapa and mskSonidosMapas)<>bmSonidosInterior then
  begin
    posx:=posx shl 1;
    posy:=posy shl 1;
  end
  else
  begin
    posx:=(posx and $7F)+(JugadorCl.coordx and $80);
    posy:=(posy and $7F)+(JugadorCl.coordy and $80);
  end;
  result:=result+'Mapa:'+intastr(fcodmapa)+' x:'+intastr(posx)+' y:'+intastr(posy)+' · ';
  if castillo.clan<=maxClanesJugadores then
    result:=result+'Territorio de: "'+clanJugadores[castillo.clan].nombre+'"'
  else
    result:=result+nombreMapa;
end;

procedure TMapaEspejo.DescribirClanDuenno(banderasCastillo:integer);
var cadena:string;
begin
  if castillo.clan<=maxClanesJugadores then
  begin
    cadena:='Castillo del clan: "'+clanJugadores[castillo.clan].nombre+'"';
    if BanderasCastillo<>0 then
      cadena:=cadena+', mejoras:';
    jform.agregarMensaje(cadena);
    if BanderasCastillo=0 then exit;
    cadena:='';
    if (banderasCastillo and bnArmadura)<>0 then cadena:=cadena+'Armadura,';
    if (banderasCastillo and bnVisionVerdadera)<>0 then cadena:=cadena+'Visión,';
    if (banderasCastillo and BnModoDefensivo)<>0 then cadena:=cadena+'Guardia,';
    if (banderasCastillo and bnFuerzaGigante)<>0 then cadena:=cadena+'Fuerza,';
    if (banderasCastillo and BnDuracion)<>0 then cadena:=cadena+'Tiempo,';
    if (banderasCastillo and bnApresurar)<>0 then cadena:=cadena+'Ataque,';
    if (banderasCastillo and bnMana)<>0 then cadena:=cadena+'Maná,';
    if (banderasCastillo and bnVendado)<>0 then cadena:=cadena+'Resistencia,';
    if length(cadena)>0 then
    begin
      delete(cadena,length(cadena),1);
      cadena:='['+cadena+']';
      jform.agregarMensaje(cadena);
    end;
  end;
end;

function TMapaEspejo.getCodigoSensorXY(var pos_x,pos_y:integer):byte;
  function revisar:byte;
  var flagsAfectados,distancia:integer;
      elCodigoDelSensor,indiceU:byte;
  begin
    result:=Ninguno;
    elCodigoDelSensor:=mapaSensor[pos_x,pos_y];
    if elCodigoDelSensor<N_Sensores then
      with Sensor[elCodigoDelSensor] do
        if (Tipo=tsCBandera) then
        begin
          if ((flagsSensor and fs_soloclan)<>0) and ((JugadorCl.clan>MaxClanesJugadores) or (JugadorCl.clan<>Castillo.clan)) then
          begin
            jform.MensajeAyuda:=getPedazoCadenaBarra(textoSensor[elCodigoDelSensor],3);
            exit;
          end;
          distancia:=round(sqr(JugadorCl.coordx-pos_x)+sqr(JugadorCl.coordy-pos_y));
          if (distancia<=5) and (
            ((flagsSensor and fs_repelerAvatar)<>0) or //Si "mayor zona de efecto" o
            ((distancia<=4) and (JugadorCl.coordy>=(pos_y-1)))//"dentro de menor zona"
            ) then
          begin
            flagsAfectados:=dato1 or(dato2 shl 8)or(dato3 shl 16)or(dato4 shl 24);
            if ((flagsSensor and fs_consumirLlave)<>0) and ((flagsAfectados and FlagsCalabozo)=flagsAfectados) then exit;
            indiceU:=(flagsSensor and fs_consumirLlave);
            if JugadorCl.TieneLaLlave(llave1,llave2,flagsCalabozo,indiceU) then
            begin
              jform.MensajeAyuda:=getPedazoCadenaBarra(textoSensor[elCodigoDelSensor],1);
              result:=elCodigoDelSensor;
            end
            else
              jform.MensajeAyuda:=getPedazoCadenaBarra(textoSensor[elCodigoDelSensor],0)
          end
          else
            jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_EstasMuyLejos,0,0);
          jform.MensajeTipTimer:=DescribirSensor(elCodigoDelSensor);
        end;
  end;
begin
  pos_x:=pos_x and $FF;
  pos_y:=(pos_y+1) and $FF;
  result:=revisar;
  if result<>Ninguno then exit;
  pos_y:=(pos_y+1) and $FF;
  result:=revisar;
  if result<>Ninguno then exit;
  pos_y:=(pos_y-2) and $FF;
  result:=revisar;
  if result<>Ninguno then exit;
  pos_y:=(pos_y+3) and $FF;
  result:=revisar;
end;

function TMapaEspejo.DeterminarPrefijoDeMusicaAdecuada:char;
var TipoDeSonidos:word;
    TipoTerreno:byte;
begin
  result:='c';//tetrica
  TipoTerreno:=getTerrenoXY(jugadorCl.coordx,jugadorCl.coordy);
  TipoDeSonidos:=banderasMapa and mskSonidosMapas;
  case TipoDeSonidos of
    bmSonidosBosque:
      case TipoTerreno of
        1..12:result:='b';
        16..31:result:='v';
      end;
    bmSonidosDesierto:
      case TipoTerreno of
        4,7,8:result:='b';
        17..27,31:result:='v';
      end;
    bmSonidosHielos:
      case TipoTerreno of
        1,3..9:result:='b';
        17..27,31:result:='v';
      end;
  end;
end;

function TMapaEspejo.DescribirSensor(codigo:byte):string;
begin
  result:=getPedazoCadenaBarra(textoSensor[codigo],2);
end;

end.

