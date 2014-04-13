(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit Mundo;
//Sin classes ni objetos por razones de optimizacion
//Tambien claro un solo mundo por servidor.

interface
uses gtimer,demonios, tablero,TableroControlado, objetos,globales, ScktComp, ExtCtrls,usuarios,windows;

const
  //Archivo de log.
  NOMBRE_ARCHIVO_LOG='REG.TXT';
  MAX_TAMANNO=30000;//256000;
  CACHE_MENSAJES=256;//128;
  CACHE_MENSAJES2=CACHE_MENSAJES shr 1;
  MAX_TAM_MENSAJE_SERVIDOR=255;

  //No modificar
  MAX_TIEMPO_OCIO=255;//255;//Nota, antes de autentificación en 1/8 de este valor.
  TIEMPO_ANTES_DE_DESCONECTAR=50;
  //Modificables
  MENSAJE_RIESGO='Intente nuevamente, el servidor está ocupado.';

//En todo el mundo:
  function LeerArchivoConfiguracionServidor:bytebool;
  procedure crear;
  procedure inicializarMundo;
  function activarMundo:string;
  function desactivarMundo:boolean;
  procedure tickMundo;
  procedure finalizarMundo;
  function MundoPreparado:boolean;
  function getId:word;//Para un jugador
  procedure ReleaseId(codJugador:integer);
  //Métodos del juego que envían datos al cliente:
  //--------------------------------------------------
  procedure ActivarIraTenax(Jug:TjugadorS);
  procedure ActivarZoomorfismo(Jug:TjugadorS);
  procedure FinalizarZoomorfismo(Jug:TjugadorS;posDestinoObjeto:byte);
  function JugadorConsumir(Jug:TjugadorS;IndArt:byte):byte;
  function ApuntarMonstruoPorCodigoCasilla(Jug:TjugadorS):byte;
  procedure FijarMovimiento(Jug:TjugadorS;posD:byte);
  function RealizarNotificarAgregarObjeto(jug:TjugadorS;var ArtefactoAgregado:TArtefacto):boolean;
  function RealizarNotificarAgregarObjetoAlBaul(jug:TjugadorS;var ArtefactoAgregado:TArtefacto):boolean;
  procedure NotificarModificacionExperiencia(jug:TjugadorS;cantidadExp:integer);
  procedure NotificarModificacionExperienciaRepartida(jug:TjugadorS;cantidadExp:integer);
  procedure RealizarNotificarMejoraMonstruo(monstruo:Tmonstruos;victimaEsJugador:boolean);
//  procedure RealizarResurreccionYNotificar();
  procedure ConsumirMateriales(jug:TjugadorS;idObjeto:byte);
  procedure GuardarTodosLosPersonajes;
  procedure TeletransportarJugador(jug:TjugadorS;Codigo_Mapa,x,y:byte);
  procedure CalcularModificadorFinal(Monstruo:TmonstruoS;tipoAtaque:TTipoArma;var Danno:integer;EsJugador:bytebool);
  procedure IniciarClima(tipo:TClimaAmbiental);
  procedure FinalizarClima;
  procedure CambiarHonor(Jug:TjugadorS;NuevoNivelHonor:shortint);
  procedure GuardarObjetoEnBaul(Jug:TjugadorS;indArtefacto,cantidad:byte);
  procedure SacarObjetoDeBaul(Jug:TjugadorS;indArtefacto,cantidad:byte);
  procedure RealizarMantenerArchivo(NroItems:integer);
  procedure mensaje(const cad:string);
  function ObtenerListaActivos(Jug:TjugadorS;Jugadores:boolean):string;
  //Jugadores=true => jugadores, false => Clanes
  procedure ObtenerListaMiembrosClan(Jug:TjugadorS);
  function GetMonstruoCodigoCasillaS(CodigoCasilla:word):TmonstruoS;
  procedure FijarCoordenadasDestino(Jug:Tjugadors;posd:word;destinoEsMonstruo:boolean);
  procedure ControlConsistenciaDatosGuardados(Jug:Tjugadors);
  procedure RepararAvatarYPosicion(Jug:Tjugadors);
  function FundarClanJugadores(JugLider:Tjugadors):bytebool;
  procedure GuardarInformacionMundo;
  procedure RealizarControlActivacionDeClanJugador(Jug:Tjugadors;ingresa:boolean);
  procedure EnviarDatosClanesActivos(jug:TjugadorS);
  function ExisteNombreClanSimilar(nombreNuevo:string;clanExcluido:byte):boolean;
  procedure ControlConsistenciaMapas;
  procedure EliminarRastrosDelClan(clanEliminado:byte);
  procedure RealizarPalabradelRetorno(Jug:TjugadorS);
  procedure EnviarBaulCompleto(jug:TjugadorS);
  procedure InformarNuevoEstadoDeBolsa(RJugador:TjugadorS);
  procedure EnviarBolsaCompleta(jug:TjugadorS);
  procedure LlamarALasArmas(MonstruoLider:TmonstruoS);
  procedure AtacarUnObjetivo(MonstruoLider:TmonstruoS;CodigoCasillaObjetivo:word);
  procedure DisiparMonstruosDeJugadorSinClan(CodigoDelJugadorSinClan:word);
  procedure DetenerMonstruos(MonstruoLider:TmonstruoS);
  procedure SeguirUnObjetivo(MonstruoLider:TmonstruoS);
  procedure LimpiarBolsas(precio_salvacion:integer);
  procedure EliminarCadaveres;
  procedure RealizarYNotificarResureccionAvatar(jug:TjugadorS;palabraDelRetorno:boolean);
  function FormarEnlaceDeParty(duennoParty,jug:TjugadorS;var indiceDeCamaradaParty:byte):byte;
  procedure EliminarEnlacesDePartyErroneos(jug:TjugadorS);
  procedure EliminarEnlacesDeParty(jug:TjugadorS);
  procedure DetenerAcciones(Jug:TjugadorS);
  procedure EjecutarComandoIniciarAtaque(Jug:TjugadorS;casilla:word;tipoAccion:TAccionAutomatica;continuo:boolean);
  function PuedeAtacarAOtrosAvatares(Atacante,Victima:TjugadorS; var cod_result:byte; informarInmediatamente:boolean):boolean;
  function esteMonstruoEsEnemigo(Jug:TjugadorS; monstruo:Tmonstruos):byte;
  procedure ActivarEstadoAgresivoEInformar(Jug:TjugadorS);
  procedure AturdirJugador(jug:TjugadorS);
  procedure ParalizarMonstruo(mon:TmonstruoS;tiempo:byte);
  procedure DisiparMagiaDeMonstruo(mon:TmonstruoS);
  procedure DarVisionVerdaderaAMonstruo(mon:TmonstruoS;tiempo:byte);
  procedure InformarAnimacionAtaque(monstruoAt:TmonstruoS);
  function ListoParaAtacar(monstruoAt:TMonstruoS):boolean;
  function AtaqueDeMonstruoConHechizos(monstruoAt:TmonstruoS;victima:TmonstruoS):boolean;
  procedure DesactivarInvisibilidadTemporalmente(monstruoAt:TmonstruoS);
var
//Objetos
  Timer: TGTimer;
  SSocket: TServerSocket;
  Mapa:array [0..MAX_TOTAL_MAPAS] of TTableroControlado;
  Jugador:array [0..maxJugadores] of TJugadorS;
  Monstruo:array [0..maxMonstruos] of TMonstruoS;
  ClanJugadores:array[0..maxClanesJugadores] of TClanJugadores;
//referencias
  SocketDelJugador:array [0..maxJugadores] of TCustomWinSocket;
//Variables
  DatosUsuario:array[0..maxJugadores] of TDatosUsuario;
  conta_Universal:integer;
  conta_Monstruos_Definidos:integer;
  Indice_Conjurar_Monstruo:integer;
  Indice_Maximo_Monstruos:integer;//máximo de monstruos activos
//Para estadísticas:
  FechaHoraInicio:TDateTime;
  NumeroArribosDatos:integer;
  NrBytesRecibidos:Integer;
//Clima
  IntensidadClimaGeneral:byte;
  TipoClimaGeneral:TClimaAmbiental;
  pendienteClimaGeneral:shortint;
//Maximo de mapas activos
  maxMapas:word;
//Otros
  G_PuertoComunicacion:word;
  G_IpDelServidor:string;
  //Es necesario crear un nuevo personaje en este modo.
  MantenerRegistroDelServidor,
  FechaYHoraEnRegistroDelServidor,
  ServidorEnModoMultiplesSesiones,
  ServidorEnModoDeComunicacionTotal,
  ServidorEnModoDeVerificacion:boolean;//Cheats activados.
  TurnosEntreEngendroDeMonstruos:Byte;
  MundoActivo:boolean;

  EnUso:boolean;

  G_MensajeDeBienvenidaAlServidor,G_ServidorDeAvatares:string;

  procedure SendText(codJugador:integer;const s:string);
  procedure SendTextNow(codJugador:integer;const s:string);

implementation
uses sysutils,dialogs,smain;
//Del sistema

var
  listo,f_Realizando_Turno:boolean;
  DirArchivosBinarios,DirArchivoLog:string;

//Del juego
const
  K_TurnosEntreEngendroDeMonstruos=128;

procedure SendText(codJugador:integer;const s:string);
begin
  if SocketDelJugador[codJugador]<>nil then
    SocketDelJugador[codJugador].SendText(s);
end;

procedure SendTextNow(codJugador:integer;const s:string);
begin
  if SocketDelJugador[codJugador]<>nil then
    SocketDelJugador[codJugador].SendTextNow(s);
end;

function ExtraerCaracteresRelevantes(const cad:string):string;
var i,nroValidos:integer;
begin
  result:=cad;
  nroValidos:=0;
  for i:=1 to length(result) do
  begin
    inc(nroValidos);
    result[i]:=upcase(result[i]);
    case result[i] of
      '8','ß':result[nroValidos]:='B';
      '1':result[nroValidos]:='I';
      '0':result[nroValidos]:='O';
      '5','$':result[nroValidos]:='S';
      '2':result[nroValidos]:='Z';
      '6','9':result[nroValidos]:='G';
      'Ç','ç':result[nroValidos]:='C';
      'Á','À','Ä','Â','á','à','ä','â','Å','å','Ã','ã','Æ','æ':result[nroValidos]:='A';
      'É','È','Ë','Ê','é','è','ë','ê','€':result[nroValidos]:='E';
      'Í','Ì','Ï','Î','í','ì','ï','î':result[nroValidos]:='I';
      'Ó','Ò','Ö','Ô','ó','ò','ö','ô','Õ','õ','Ø','ø':result[nroValidos]:='O';
      'Ú','Ù','Ü','Û','ú','ù','ü','û':result[nroValidos]:='U';
      'ñ','Ñ':result[nroValidos]:='N';
      'Þ','þ':result[nroValidos]:='P';
      'Ý','ý','ÿ','Ÿ':result[nroValidos]:='Y';
      'Ð','ð':result[nroValidos]:='D';
      'A'..'Z','3','4','7':result[nroValidos]:=result[i];
      else
        dec(nroValidos);
    end;
  end;
  delete(result,nroValidos+1,maxint);
end;

function ExisteNombreClanSimilar(nombreNuevo:string;clanExcluido:byte):boolean;
var i:integer;
begin
  nombreNuevo:=ExtraerCaracteresRelevantes(nombreNuevo);
  for i:=0 to maxClanesJugadores do
    if (ClanJugadores[i].Lider<>'') and (i<>clanExcluido) then
      if ExtraerCaracteresRelevantes(ClanJugadores[i].nombre)=nombreNuevo then
      begin
        result:=true;exit;
      end;
  result:=false;
end;

procedure IntrprtrLnaArchvoCnfgrcn(const cadena:string);
var id,valor,texto:string;
    PosicionChar:integer;
  procedure ObtenerPosicionBase;
  var code,nro,i,IdPosicionBase:integer;
  begin
    i:=0;
    IdPosicionBase:=-1;
    repeat
      PosicionChar:=pos(',',valor);
      if PosicionChar=0 then PosicionChar:=length(valor)+1;
      val(copy(valor,1,posicionChar-1),nro,code);
      if code<>0 then exit;
      if i=0 then
        IdPosicionBase:=nro mod 10
      else
        PosicionesInicialesDeAvatares[IdPosicionBase,i-1]:=nro;
      valor:=trimleft(copy(valor,posicionChar+1,length(valor)));
      inc(i);
    until (length(valor)=0) or (i>=4);
  end;
begin
  if copy(cadena,1,1)<'A' then exit;
  PosicionChar:=pos('=',cadena);
  id:=lowercase(trimright(copy(cadena,1,PosicionChar-1)));
  texto:=trimleft(copy(cadena,PosicionChar+1,length(cadena)));
  valor:=lowercase(texto);
  if id='posición base' then
    ObtenerPosicionBase
  else
  if id='bienvenida' then
  begin
    G_MensajeDeBienvenidaAlServidor:=texto;
  end
  else
  if id='servidor de avatares' then
  begin
    G_ServidorDeAvatares:=texto;
  end
  else
  if id='número de mapas' then
  begin
    val(valor,maxMapas,PosicionChar);
    if (PosicionChar<>0) or (maxMapas<1) or (maxMapas>MAX_TOTAL_MAPAS) then
      maxMapas:=1;
  end
  else if id='turnos de reengendro' then
  begin
    val(valor,TurnosEntreEngendroDeMonstruos,PosicionChar);
    if (PosicionChar<>0) or (TurnosEntreEngendroDeMonstruos<1) or (TurnosEntreEngendroDeMonstruos>250) then
      TurnosEntreEngendroDeMonstruos:=K_TurnosEntreEngendroDeMonstruos;
  end
  else if id='comunicación total' then
  begin
    ServidorEnModoDeComunicacionTotal:=valor='si';
  end
  else if id='múltiples sesiones' then
  begin
    ServidorEnModoMultiplesSesiones:=valor='si';
  end
  else if id='mantener registro' then
  begin
    MantenerRegistroDelServidor:=valor='si';
  end
  else if id='fecha y hora en registro' then
  begin
    FechaYHoraEnRegistroDelServidor:=valor='si';
  end
  else if id='puerto' then
  begin
    val(valor,G_PuertoComunicacion,PosicionChar);
    if (PosicionChar<>0) or (G_PuertoComunicacion<MIN_PUERTO_COMUNICACION) or (G_PuertoComunicacion>MAX_PUERTO_COMUNICACION) then
      G_PuertoComunicacion:=PUERTO_COMUNICACION;
  end
  else if id='ip' then
  begin
    G_IpDelServidor:=texto;
  end
end;

function LeerArchivoConfiguracionServidor:bytebool;
var f:text;
    s:string;
begin
  if EjecutableCorrompido(ParamStr(0)) then
  begin
    showmessage(M_EjecutableDannado);
    result:=false;exit;
  end;
  DirArchivoLog:=ExtractFilePath(ParamStr(0));
  dirArchivosBinarios:=ExtractFilePath(copy(DirArchivoLog,1,length(DirArchivoLog)-1))+'Laa\bin\';
  //Configuraciones predeterminadas
  maxMapas:=1;
  TurnosEntreEngendroDeMonstruos:=K_TurnosEntreEngendroDeMonstruos;
  G_PuertoComunicacion:=PUERTO_COMUNICACION;
  G_IpDelServidor:='';
  ServidorEnModoMultiplesSesiones:=true;
  ServidorEnModoDeComunicacionTotal:=true;
  MantenerRegistroDelServidor:=false;
  FechaYHoraEnRegistroDelServidor:=false;
  G_MensajeDeBienvenidaAlServidor:='';
  G_ServidorDeAvatares:='';
  //lectura del archivo de opciones
  {$I-}
  assignFile(f,DirArchivoLog+'opciones.txt');
  filemode:=0;
  reset(f);
  while not eof(f) do
  begin
    readln(f,s);
    IntrprtrLnaArchvoCnfgrcn(trim(s));
  end;
  closeFile(f);
  {$I+}
  result:=(IOResult=0) and
    fileExists(dirArchivosBinarios+'oc.b');//evita en buena forma ejecutar el servidor sin sus archivos primordiales
  if not result then
    showmessage(M_FaltanArchivosDelJuego);
end;

procedure crear;
var i:integer;
begin
  Listo:=false;
  MundoActivo:=false;
  f_Realizando_Turno:=false;
  conta_Universal:=0;
  TipoClimaGeneral:=CL_NORMAL;//sin efecto
  IntensidadClimaGeneral:=0;
  pendienteClimaGeneral:=0;
  //Configurables:
  Tablero.InicializarConstantesTablero(dirArchivosBinarios,nil);
  Demonios.InicializarMonstruos(dirArchivosBinarios+'std.mon');
  Objetos.InicializarColeccionObjetos(dirArchivosBinarios+'obj.b');
  Objetos.InicializarColeccionConjuros(dirArchivosBinarios+'cjr.b');
  Demonios.InicializarMapeoAnimaciones(dirArchivosBinarios+'mp_anim.b');
  Demonios.InicializarMapeoAtaques(dirArchivosBinarios+'mp_ataq.b');
  for i:=0 to maxMapas do
    Mapa[i]:=TtableroControlado.create(i);
  for i:=0 to maxJugadores do
    Jugador[i]:=TjugadorS.create(i);
  conta_Monstruos_Definidos:=0;
  for i:=0 to MaxMonstruos do
    Monstruo[i]:=TmonstruoS.create(i);
  for i:=0 to MaxClanesJugadores do
    ClanJugadores[i]:=TClanJugadores.create(i);
end;

procedure finalizarMundo;
var i:integer;
begin
  desactivarMundo;
  for i:=MaxClanesJugadores downto 0 do
    ClanJugadores[i].free;
  for i:=maxMonstruos downto 0 do
    Monstruo[i].free;
  for i:=maxJugadores downto 0 do
    Jugador[i].free;
  for i:=maxMapas downto 0 do
    Mapa[i].free;
end;

//------------------------------------------------------------------------------
//                      AQUI LO PESADO
//------------------------------------------------------------------------------
procedure inicializarMundo;
var i:integer;
//Para no crear uno para cada mapa, por que luego de creado el mapa lógico
//no se utiliza esta información en el servidor.
    graficosMapa:TGraficosMapa;
    e:boolean;
begin
//Inicialización del universo
  mensaje('Inicializando Servidor... Mapas habilitados: 0 al '+intastr(maxmapas));
  e:=false;
  for i:=0 to maxMapas do
    if not Mapa[i].RecuperarMapa(i,nil,nil,nil,@graficosMapa) then
    begin
      mensaje('>> EL MAPA #'+intastr(i)+' ESTÁ DAÑADO.');
      e:=true;
    end;
  if e then
    mensaje('LOS MAPAS DAÑADOS PUEDEN AFECTAR EL FUNCIONAMIENTO DE OTROS MAPAS');
  for i:=0 to maxJugadores do
  begin
    DatosUsuario[i].estadoUsuario:=euNoConectado;
    DatosUsuario[i].IdLogin:='';
    SocketDelJugador[i]:=nil;
    Jugador[i].hp:=0;//Necesario ??
    Jugador[i].activo:=false;//Necesario ??
  end;
  for i:=0 to maxMapas do
  with Mapa[i] do
  begin
    inicializar;
    definirCriaturas;
  end;
  Listo:=true;
  Indice_Conjurar_Monstruo:=conta_Monstruos_Definidos;//posicion libre para conjurar un monstruo
  Indice_Maximo_Monstruos:=conta_Monstruos_Definidos-1;//sin monstruos conjurados
  mensaje('Monstruos en todos los mapas: '+intastr(conta_Monstruos_Definidos));
  i:=MaxMonstruos+1-conta_Monstruos_Definidos;
  if i<0 then i:=0;
  mensaje('Monstruos conjurables: '+intastr(i));
  if random(2)=0 then conta_Universal:=32 else conta_Universal:=INICIO_NOCHE-32;
end;

procedure RealizarMantenerArchivo(NroItems:integer);
var f:textFile;
    TamArchivo:integer;
  function TamannoArchivo(const FileName: string):integer;
  var Arch:file;
  begin
    {$I-}
    AssignFile(Arch, FileName);
    FileMode:=0;  { Set file access to read only }
    Reset(Arch,1);
    result:=filesize(Arch);
    CloseFile(Arch);
    {$I+}
    if (IOResult<>0) then result:=-1;
  end;
  function CrearArchivoLog:boolean;
  var i:integer;
  begin
    {$I-}
    assignFile(f,DirArchivoLog+NOMBRE_ARCHIVO_LOG);
    rewrite(f);
    for i:=1 to NroItems do
    begin
      writeln(f,MainForm.memo.lines.Strings[0]);
      MainForm.memo.lines.Delete(0);
    end;
    closeFile(f);
    {$I+}
    result:=ioresult=0;
  end;
  function AumentarArchivoLog:boolean;
  var i:integer;
  begin
    {$I-}
    assignFile(f,DirArchivoLog+NOMBRE_ARCHIVO_LOG);
    append(f);
    for i:=1 to NroItems do
    begin
      writeln(f,MainForm.memo.lines.Strings[0]);
      MainForm.memo.lines.Delete(0);
    end;
    closeFile(f);
    {$I+}
    result:=ioresult=0;
  end;
begin
  TamArchivo:=TamannoArchivo(DirArchivoLog+NOMBRE_ARCHIVO_LOG);
  if TamArchivo<0 then//el archivo no existe
    crearArchivoLog
  else
    if TamArchivo>MAX_TAMANNO then
    begin
      {$I-}
      AssignFile(f,DirArchivoLog+NOMBRE_ARCHIVO_LOG);
      Rename(f,DirArchivoLog+'R'+IntToHex(trunc(date)-38154,4)+'.TXT');
      {$I+}
      if ioresult=0 then CrearArchivoLog
    end
    else
      AumentarArchivoLog
end;

procedure Mensaje(const cad:string);
begin
  with mainForm do
  begin
   if (memo.lines.Count>CACHE_MENSAJES) then
     if MantenerRegistroDelServidor then
       RealizarMantenerArchivo(CACHE_MENSAJES2)
     else
       memo.lines.Delete(0);
   if FechaYHoraEnRegistroDelServidor then
     memo.lines.Add(DateTimeToStr(now)+#32+cad)
   else
     memo.lines.Add(cad);
  end;
end;

//------------------------------------------------------------------------------
procedure ControlJugadores;
var i,conta_i:integer;
    JugCon:TjugadorS;
    mensajesSoloJugador:string;
//CONTROL DE CONSUMO DE COMIDA.
//REGENERACION DE HP Y MANA.
    function ControlHP:bytebool;
    var hpTempo:integer;
        UsandoAmuleto,tieneRegeneracion:boolean;
    begin
      result:=false;
      with JugCon do
      if hp<>0 then
        if (comida<=0) or longbool(banderas and BnEnvenenado) then
        begin//daño por hambre y/o veneno
          hpTempo:=hp-random(4)-1;
          if hpTempo>1 then
            hp:=hpTempo
          else
            hp:=1;
          result:=true;
        end
        else
          if (hp<maxhp) then
          begin
            UsandoAmuleto:=Usando[uAmuleto].id=ihAmuletoDeRegeneracion;
            tieneRegeneracion:=((Pericias and hbRegenerar)<>0) and ((banderas and bnEnvenenado)=0);
            if (accion=aaDescansando) or UsandoAmuleto or tieneRegeneracion then
            begin
              hpTempo:=0;
              if (accion=aaDescansando) then
                inc(hpTempo,maxhp shr 4)
              else
                inc(hpTempo,maxhp shr 6);
              //efecto de no tener vendadas las heridas
              if (banderas and BnVendado=0) then
              begin
                if (hp<=(maxhp shr 2)) then
                  hpTempo:=hpTempo shr 2
                else
                  if (hp<=(maxhp shr 1)) then
                    hpTempo:=hpTempo shr 1;
              end
              else
                inc(hpTempo);
              inc(hpTempo,hp + 1);//Regenerar por lo menos un punto de vida
              if UsandoAmuleto then inc(hpTempo,2);
              if tieneRegeneracion then inc(hpTempo,2);
              if (aurasExternas and flAuraExtFogata)<>0 then inc(hpTempo,2);//Si esta cerca de fogata
              if hpTempo>maxHp then
                hp:=maxHp//evitar pasar del máximo
              else
                hp:=hpTempo;
              result:=true;
            end;
          end
    end;
    function ControlMana:bytebool;
    //Control de mana sólo si memoriza conjuros.
    var aumentado:integer;
    begin
      result:=false;
      with JugCon do
      if maxMana>0 then
       if (accion=aaMeditando) or (Usando[uAmuleto].id=ihAmuletoDeMago) then
       if (comida>0) and (mana<maxmana) then
       begin
         case Usando[uArmaDer].id of
           116:aumentado:=2;//simbolo I
           112:aumentado:=2;//cayado I
           117:aumentado:=3;//simbolo II
           113:aumentado:=3;//cayado II
           118:aumentado:=4;//simbolo III
           114:aumentado:=4;//cayado III
           119:aumentado:=5;//libro oraciones
           115:aumentado:=5;//libro arcano
           else
             aumentado:=1;
         end;
         //Si esta cerca de fogata y meditando aumentar en 50% redondeado para arriba
         if ((aurasExternas and flAuraExtFogata)<>0) and (accion=aaMeditando) then
           inc(aumentado,(aumentado+1) shr 1);
         if codCategoria=ctMago then inc(aumentado,2);
         inc(aumentado,maxmana shr 4+Meditacion255);
         if (Usando[uAmuleto].id=ihAmuletoDeMago) then inc(aumentado,3);
         if (accion<>aaMeditando) then
           if (SAB>=18) and (INT>=18) then
             aumentado:=aumentado shr 1
           else
             aumentado:=aumentado shr 2;
         inc(aumentado,mana);
         if aumentado>=maxmana then//>= para asegurar informar cuando deja de meditar
         begin
           mana:=maxmana;
           if (accion=aaMeditando) then
             accion:=aaParado;
         end
         else
           mana:=aumentado;
         result:=true;
       end
    end;
    function consumoComida:boolean;
    var nivelConsumo:integer;
    begin
      result:=false;
      with JugCon do
      if comida>0 then
      begin
        nivelConsumo:=CON shr 2;
        if nivelConsumo<1 then nivelConsumo:=1;
        nivelConsumo:=comida-nivelConsumo;//nuevo nivel de comida
        if nivelConsumo>0 then
          comida:=nivelConsumo
        else
          comida:=0;
        result:=true;
      end;
    end;
  procedure AplicarFijadoresBorradoresDeFlags;
  var i,j,EstadoAnterior,FlagsCambiados,FlagActual:integer;
  begin
    for i:=0 to maxMapas do
      with Mapa[i] do
      begin
        EstadoAnterior:=FlagsCalabozo;
        //primero borrar los autoborrables:
        FlagsCalabozo:=(FlagsCalabozo or FlagsAutolimpiables) xor FlagsAutolimpiables;
        //cambiarles de estado:
        FlagsCalabozo:=FlagsCalabozo xor CambiarFlagsCalabozo;
        //luego fijar los flags:
        FlagsCalabozo:=FlagsCalabozo or FijarFlagsCalabozo;
        //finalmente borrar los flags
        FlagsCalabozo:=(FlagsCalabozo or BorrarFlagsCalabozo) xor BorrarFlagsCalabozo;
        //si existen diferencias:
        FlagsCambiados:=EstadoAnterior xor FlagsCalabozo;
        if FlagsCambiados<>0 then
        begin
          //aplicar efecto por flag:
          for j:=0 to 31 do
          begin
            FlagActual:=1 shl j;
            if (FlagsCambiados and FlagActual)<>0 then
              if not RealizarComportamientoFlag(j) then//restituir estado anterior
                FlagsCalabozo:=((FlagsCalabozo or FlagActual) xor FlagActual) or (EstadoAnterior and FlagActual);
          end;
          //nuevamente revisar si los flags cambiaron:
          if EstadoAnterior xor FlagsCalabozo<>0 then
            EnviarAlMapa(i,'K'+B4aStr(FlagsCalabozo));
        end;
        FijarFlagsCalabozo:=0;
        BorrarFlagsCalabozo:=0;
        CambiarFlagsCalabozo:=0;
      end;
  end;
begin
  //control de jugadores, y flags de los mapas
  for i:=0 to maxJugadores do
    with Jugador[i] do
      if activo then
      begin
        JugCon:=Jugador[i];//Para los subprocedimientos
        conta_i:=Conta_Universal+i;
        //********************************
        with Mapa[codMapa] do
        begin
          if longbool(banderas and bnApresurar) or ((banderas and bnAturdir)=0) or ((conta_i and $1)=0) then
          begin
            MoverAutomaticamente(JugCon);
            RealizarControlSensores(JugCon);
          end;
          if ((coordX<>fdestinoX) or (coordY<>fdestinoY)) and longbool(banderas and bnApresurar) and ((banderas and bnAturdir) = 0) then
          begin
            MoverAutomaticamente(JugCon);
            RealizarControlSensores(JugCon);
          end;
        end;
        if conta_i and $F=0 then
        begin
          if (conta_i and $1F=0) or (usando[uAmuleto].id<>ihAmuletoDePersistencia) then
          begin
            mensajesSoloJugador:='';
            //flags de conjuros
            //-----------------
            if longbool(banderas) then //optimizador
            begin
              if longbool(banderas and BnProteccion) then
                if TickTimer(tdProteccion) then
                begin
                  banderas:=banderas xor BnProteccion;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'sp';
                end;
              if longbool(banderas and BnFuerzaGigante) then
                if TickTimer(tdFuerzaGigante) then
                begin
                  banderas:=banderas xor BnFuerzaGigante;
                  CalcularDannoBase;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'sf';
                end;
              if longbool(banderas and BnAturdir) then
                if TickTimer(tdAturdir) then
                begin
                  banderas:=banderas xor BnAturdir;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'st';
                end;
              if longbool(banderas and BnApresurar) then
                if TickTimer(tdApresurar) then
                begin
                  banderas:=banderas xor BnApresurar;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'sa';
                end;
              if longbool(banderas and BnArmadura) then
                if TickTimer(tdArmadura) then
                begin
                  banderas:=banderas xor BnArmadura;
                  CalcularDefensa;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'sd';
                end;
              if longbool(banderas and BnInvisible) then
                if TickTimer(tdInvisible) then
                begin
                  banderas:=banderas xor BnInvisible;
                  if longbool(banderas and bnOcultarse) then
                    banderas:=banderas xor bnOcultarse;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'si';
                end;
              //restaurar invisibilidad
              if TimerActivo(tdInvisible) then
                if (banderas and BnInvisible)=0 then
                begin
                  banderas:=banderas or BnInvisible;
                  EnviarAlMapa(codMapa,'A'+b2aStr(codigo)+char(banderas));
                end;
              if longbool(banderas and BnParalisis) then
                if TickTimer(tdParalisis) then
                begin
                  banderas:=banderas xor BnParalisis;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'s)';
                end;
              if longbool(banderas and BnVisionVerdadera) then
                if TickTimer(tdVisionVerdadera) then
                begin
                  banderas:=banderas xor BnVisionVerdadera;
                  DefinirCapacidadIdentificacion;
                  EnviarAlMapa_J(JugCon,'B'+b2aStr(codigo)+char(banderas shr 8));
                  mensajesSoloJugador:=mensajesSoloJugador+'sw';
                end;
              if longbool(banderas and BnIraTenax) then
                if TickTimer(tdIraTenax) then
                begin
                  banderas:=banderas xor BnIraTenax;
                  CalcularDefensa;
                  EnviarAlMapa_J(JugCon,'A'+b2aStr(codigo)+char(banderas));
                  mensajesSoloJugador:=mensajesSoloJugador+'sx';
                end;
              if longbool(banderas and BnCongelado) then
                if TickTimer(tdCongelado) then
                begin
                  banderas:=banderas xor BnCongelado;
                  EnviarAlMapa_J(JugCon,'B'+b2aStr(codigo)+char(banderas shr 8));
                  mensajesSoloJugador:=mensajesSoloJugador+'sc';
                end;
              if longbool(banderas and BnVendado) and (hp>=maxhp) then
              begin
                banderas:=banderas xor BnVendado;//borrar flag vendas
                mensajesSoloJugador:=mensajesSoloJugador+'sv';
              end;
            end;
            if ControlMana then
              mensajesSoloJugador:=mensajesSoloJugador+#254+char(mana);
            if ControlHP then
              mensajesSoloJugador:=mensajesSoloJugador+#255+B2aStr(hp);
            if conta_i and $FF=0 then
              if ConsumoComida then
                mensajesSoloJugador:=mensajesSoloJugador+#253+char(comida);
            if mensajesSoloJugador<>'' then
              sendText(i,mensajesSoloJugador);
          end;
          MensajesEnviadosEn16Turnos:=0;
          if TickTimerAgresividad then
            if comportamiento>=comNormal then
              sendText(i,'I'+#12);
        end;
        //Control de defensa activa.
        if TickTimer(tdCombate) then
        begin
          if LongBool(Banderas and bnModoDefensivo) then
            Banderas:=Banderas xor bnModoDefensivo;
          if LongBool(Banderas and bnEfectoBardo) then
          begin
            Banderas:=Banderas xor bnEfectoBardo;
            EnviarAlMapa(codMapa,'B'+b2aStr(codigo)+char(banderas shr 8));
          end;
        end;
        TickTiempoDeComandos;//Disminuye el nro de turnos gastados por el jugador.
        if DatosUsuario[i].ProcesarBufferRecepcion then
        begin
  //        mensaje('Procesado en tick: '+nombre);
          mainform.InterpretarComandos(SocketDelJugador[i]);
        end;
      end;
  //aplicar fijadores y borradores de flags de los mapas.
  AplicarFijadoresBorradoresDeFlags;
end;

//------------------------------------------------------------------------------
procedure iniciarClima(Tipo:TClimaAmbiental);
var i:integer;
begin
  IntensidadClimaGeneral:=0;
  TipoClimaGeneral:=Tipo;
  pendienteClimaGeneral:=PendienteDeClima(ord(Tipo));
  for i:=0 to maxMapas do
    with Mapa[i] do
    begin
      if not (longbool(banderasMapa and bmMapaDeInterior) or
        (((TipoClimaGeneral=CL_LLUVIOSO) or (TipoClimaGeneral=CL_LLUVIA_NOCHE)) and longbool(banderasMapa and bmSinLluvia)) or
        ((TipoClimaGeneral=CL_BRUMA) and longbool(banderasMapa and bmSinBruma))) then
          EnviarAlMapa(i,'X'+char(TipoClimaGeneral));
      if ((TipoClimaGeneral=CL_LLUVIOSO) or (TipoClimaGeneral=CL_LLUVIA_NOCHE)) and not longbool(banderasMapa and bmSinLluvia) then
        controlParaApagarFogatas:=MaxBolsas;
    end;
end;

procedure FinalizarClima;
begin
  if TipoClimaGeneral=CL_NORMAL then exit;
  pendienteClimaGeneral:=-PendienteDeClima(ord(TipoClimaGeneral));
  EnviarATodos('XT');//finalizar
end;

procedure ControlClima;
var tempo:integer;
begin//iniciador de eventos del clima
  if conta_Universal<INICIO_NOCHE then
  begin
    if conta_Universal=0 then
      FinalizarClima
    else
      if (conta_Universal>512) and (conta_Universal<INICIO_NOCHE-512) then
      begin//Efectos varios
        if not longbool(conta_Universal and $7f) then
        begin
          if TipoClimaGeneral=CL_NORMAL then
          begin
            tempo:=random(20);
            if tempo=0 then
              iniciarClima(CL_LLUVIOSO)
            else
              if tempo=3 then
                iniciarClima(CL_BRUMA);//bruma
          end
          else
            if random(9)=0 then
              finalizarClima
            else
              if (TipoClimaGeneral=CL_LLUVIOSO) and (random(4)=0) then
                EnviarATodos('XR');
        end;
      end
      else
        if conta_Universal=INICIO_NOCHE-512 then
          finalizarClima;
  end
  else
  begin
    if conta_Universal=INICIO_NOCHE then
      iniciarClima(CL_NOCHE)
    else
      if (conta_Universal>INICIO_NOCHE+512) and (conta_Universal<TICKS_POR_DIA-512) then
      begin//Efectos varios
        if not longbool(conta_Universal and $7f) then
        begin
          if TipoClimaGeneral=CL_NOCHE then
          begin
            if random(20)=0 then
              iniciarClima(CL_LLUVIA_NOCHE)
          end
          else
            if random(9)=0 then
              finalizarClima
            else
              if (TipoClimaGeneral=CL_LLUVIA_NOCHE) and (random(2)=0) then
                EnviarATodos('XR');
        end;
      end
      else
        if conta_Universal=TICKS_POR_DIA-512 then
          finalizarClima;
  end;
  //control de estado de clima
  if pendienteClimaGeneral<>0 then
  begin
    tempo{NuevaIntensidadClima}:=IntensidadClimaGeneral+pendienteClimaGeneral;
    if tempo{NuevaIntensidadClima}<=0 then
    begin
      pendienteClimaGeneral:=0;
      if (TipoClimaGeneral=CL_LLUVIA_NOCHE) then
      begin
        IntensidadClimaGeneral:=255;
        TipoClimaGeneral:=CL_NOCHE;
      end
      else
      begin
        IntensidadClimaGeneral:=0;
        TipoClimaGeneral:=CL_NORMAL;
      end;
    end
    else
      if tempo{NuevaIntensidadClima}>=255 then
      begin
        IntensidadClimaGeneral:=255;
        pendienteClimaGeneral:=0;
      end
      else
        IntensidadClimaGeneral:=tempo{NuevaIntensidadClima};
  end;
  //Control de timer
  if conta_Universal<TICKS_POR_DIA then
    inc(conta_Universal)
  else
    conta_Universal:=0
end;

procedure controlMonstruos;
var i,NivelTemporal:integer;
begin
  //Timers:
  if Conta_Universal and $F=0 then
  for i:=0 to Indice_Maximo_Monstruos do
    with Monstruo[i] do
      if activo and (hp<>0) then
        if banderas<>0 then
        begin
          if longbool(banderas and BnParalisis) then
            if TickTimer(tdParalisis) then
            begin
              banderas:=banderas xor BnParalisis;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          if longbool(banderas and BnCongelado) then
            if TickTimer(tdCongelado) then
            begin
              banderas:=banderas xor BnCongelado;
              EnviarAlMapa(codMapa,'B'+b2aStr(codigo or ccmon)+char(banderas shr 8));//BnCongelado está en el byte superior
            end;
          if longbool(banderas and BnEnvenenado) then
          begin//daño por hambre y/o veneno para monstruos
            NivelTemporal:=hp-random(4)-1;//efecto del veneno 1d4
            if NivelTemporal>1 then hp:=NivelTemporal else hp:=1;
          end;
          if longbool(banderas and BnProteccion) then
            if TickTimer(tdProteccion) then
            begin
              banderas:=banderas xor BnProteccion;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          if longbool(banderas and BnFuerzaGigante) then
            if TickTimer(tdFuerzaGigante) then
            begin
              banderas:=banderas xor BnFuerzaGigante;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          if longbool(banderas and BnApresurar) then
            if TickTimer(tdApresurar) then
            begin
              banderas:=banderas xor BnApresurar;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          if longbool(banderas and BnAturdir) then
            if TickTimer(tdAturdir) then
            begin
              banderas:=banderas xor BnAturdir;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          if longbool(banderas and BnArmadura) then
            if TickTimer(tdArmadura) then
            begin
              banderas:=banderas xor BnArmadura;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          if longbool(banderas and BnInvisible) then
            if TickTimer(tdInvisible) then
            begin
              banderas:=banderas xor BnInvisible;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          //restaurar invisibilidad
          if TimerActivo(tdInvisible) then
            if (banderas and BnInvisible)=0 then
            begin
              banderas:=banderas or BnInvisible;
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
            end;
          if longbool(banderas and BnVisionVerdadera) then
            if TickTimer(tdVisionVerdadera) then
            begin
              banderas:=banderas xor BnVisionVerdadera;
              EnviarAlMapa(codMapa,'B'+b2aStr(codigo or ccmon)+char(banderas shr 8));//BnVisionVerdadera está en el byte superior
            end;
        end;
  //Vida de todos los monstruos
  for i:=0 to Indice_Maximo_Monstruos do
    with monstruo[i] do
      if activo then
        if (banderas and BnParalisis)=0 then
          Mapa[codMapa].vidaCriatura(Monstruo[i]);
  case Conta_Universal and $3 of
    0,2:begin//Monstruos definidos en el mapa en nidos.
      for i:=0 to conta_Monstruos_Definidos-1 do
        with monstruo[i] do
          if not activo then
            Mapa[codMapa].EngendrarMonstruo(monstruo[i])//Intentar crear un nuevo monstruo.
    end;
    1:begin//Monstruos conjurados por magos/clérigos
      for i:=conta_Monstruos_Definidos to Indice_Maximo_Monstruos do
      with monstruo[i] do
        if activo then
          if ritmoDeVida=0 then
            Mapa[codMapa].DisolverMonstruo(Monstruo[i])
          else
            if ritmoDeVida<255 then dec(ritmoDeVida);
    end;
    3:begin//regeneración y maná
      for i:=0 to Indice_Maximo_Monstruos do
      with monstruo[i] do
        if activo then
          if (hp<>0) then
            with InfMon[TipoMonstruo] do
            begin//regeneracion:
              if (hp<HPPromedio) and ((banderas and bnEnvenenado)=0) then
              begin
                NivelTemporal:=hp;
                inc(NivelTemporal,regeneracion);
                if NivelTemporal>HPPromedio then hp:=HPPromedio else hp:=NivelTemporal;
              end;
              if ((banderas and bnEnvenenado)<>0) and (Regeneracion>random(30)) then
              begin
                banderas:=banderas xor bnEnvenenado;
                EnviarAlMapa(codmapa,'B'+b2aStr(codigo or ccmon)+char(banderas shr 8));
              end;
              //mana para monstruos:
              if mana<(nivelMonstruo shl 1) then inc(mana,1+nivelMonstruo shr 4);
            end;
    end;
  end;//case
end;

procedure tickMundo;
var i:integer;
begin
  if not mundoActivo then exit;
  f_Realizando_Turno:=true;
  //CONTROL DE JUGADORES Y SENSORES PARA LOS JUGADORES.
  ControlJugadores;
  //CONTROL DE MONSTRUOS Y FIN DE TURNO DE MONSTRUOS Y LUEGO DE JUGADORES
  ControlMonstruos;
  //CONTROL DE TIEMPO Y SINCRONIZACION.
  ControlClima;
  //Control de bolsas y fogatas por mapa:
  for i:=0 to maxMapas do
    Mapa[i].ControlBolsasMapa((conta_Universal+i)and $3=0);
  //ENVIAR DATOS DEL BUFFER
  for i:=0 to maxJugadores do
    if SocketDelJugador[i]<>nil then
      if Jugador[i].activo then
        with SocketDelJugador[i] do
        begin
          if DatosUsuario[i].TimerDesconeccionPorOcio=TIEMPO_ANTES_DE_DESCONECTAR then
            SendText('I'+#0);
          SendBufferedTextNow;
        end;
  //Control de conexiones ociosas
  for i:=0 to maxJugadores do
    if Jugador[i].activo then
    begin
      if DatosUsuario[i].TimerDesconeccionPorOcio>0 then
        dec(DatosUsuario[i].TimerDesconeccionPorOcio)
      else
        if (SocketDelJugador[i]<>nil) and (SocketDelJugador[i].Connected) then
        begin
          mensaje('Desconexión por ocio #'+intastr(i));
          SocketDelJugador[i].close
        end
        else
          ReleaseId(i);
    end
    else
      if SocketDelJugador[i]<>nil then
        if DatosUsuario[i].TimerDesconeccionPorOcio>0 then
          dec(DatosUsuario[i].TimerDesconeccionPorOcio)
        else
          if (SocketDelJugador[i].Connected) then
            SocketDelJugador[i].close
          else
            ReleaseId(i);

  f_Realizando_Turno:=false;
  if ((conta_Universal and $3FFF)=0) and MainForm.AutoGuardarInformacin1.checked and
    (not ServidorEnModoDeVerificacion) then
  begin
    Mensaje('GUARDADO automático de información...');
    GuardarTodosLosPersonajes;
    GuardarInformacionMundo;
    EnviarATodos('I'+#3);
  end;
  //Limpieza de madrugada
  if (conta_Universal=55200) and MainForm.LimpiarPeriodicamente1.checked then
  begin
    Mensaje('Limpieza automática de cadáveres y bolsas del piso...');
    EliminarCadaveres;
  end;
end;

function getId:word;
var i:integer;
begin
  result:=ID_NULO;
  for i:=0 to maxJugadores do
    if DatosUsuario[i].estadoUsuario=euNoConectado then
    begin
      result:=i;
      exit;
    end;
end;

procedure ReleaseId(codJugador:integer);
//OJO NO DEBE ENVIAR NINGUNA INF. A Jugador[ind], ni al Socket
begin
  if codJugador>MaxJugadores then exit;//indice inválido
  SocketDelJugador[codJugador]:=nil;//Debe asegurarse esto.
  if DatosUsuario[codJugador].estadoUsuario>euAutentificado then //sesion iniciada
  begin
    //Desactiva a Jugador[ind]
    Mapa[Jugador[codJugador].codMapa].sacarJugador(Jugador[codJugador]);
    //Ojo, Jugador[ind] NO DEBE ESTAR ACTIVO AL LLEGAR A ESTE PASO:
    RealizarControlActivacionDeClanJugador(Jugador[codJugador],false);
    GuardarUsuario(codJugador);
    Jugador[codJugador].hp:=0;
    mensaje('Fin de sesión para "'+Jugador[codJugador].nombreAvatar+'" #'+intastr(codJugador));
  end
  else
    if (MainForm.Mostrarconexionesydesconexiones.Checked) then
      mensaje('Sale del servidor <Invitado> #'+intastr(codJugador));
  DatosUsuario[codJugador].estadoUsuario:=euNoConectado;//liberar posicion
  DatosUsuario[codJugador].IdLogin:='';
end;

function Mundopreparado:boolean;
begin result:=listo end;

function activarMundo:string;
var i:integer;
begin
  if not Mundoactivo then
  begin
    //Antes reinicializar, leer mapas y clanes:
    for i:=0 to maxMapas do
      mapa[i].inicializarParaReactivar;
    LeerInfPrecios;
    LeerInfCastillos;
    LeerArchivoClanes;
    ControlConsistenciaMapas;
    //Continuar
    FechaHoraInicio:=now;
    NrBytesRecibidos:=0;
    NumeroArribosDatos:=0;
    SSocket.open;

    if SSocket.Active then
      result:='Servidor activado '+SSocket.Socket.LocalHost+'('+SSocket.Address+'):'+intastr(SSocket.port);
    if ServidorEnModoDeVerificacion then
      result:=result+' (Modo de Pruebas)';
    Mensaje(result);
    MundoActivo:=true;
    Timer.enabled:=true;
  end;
end;

function desactivarMundo:boolean;
var i:integer;
begin
  if Mundoactivo then
  begin
    Timer.enabled:=false;
    //Cerrar conexiones con todos los jugadores:
    for i:=0 to maxJugadores do
      if Jugador[i].activo then
        ReleaseId(i)
      else
        SocketDelJugador[i]:=nil;
    SSocket.close;
    MundoActivo:=false;
    //Ojo, teniendo el timer desactivado:
    if not ServidorEnModoDeVerificacion then
    begin
      GuardarClanesJugadores;
      GuardarInfCastillos;
      GuardarInfPrecios;
    end
    else
      //limpiar las bolsas!!
      for i:=0 to maxmapas do
        mapa[i].InicializarBolsas(0{inicializar todas});
  end;
  result:=not SSocket.Active;
end;

procedure GuardarInformacionMundo;
var estadoTimer:boolean;
begin
  estadoTimer:=Timer.enabled;
  Timer.enabled:=false;
  if not f_Realizando_Turno then
  begin//Es seguro realizar el almacenamiento
    EnviarATodosAhora('I'+#2);
    GuardarClanesJugadores;
    GuardarInfCastillos;
    GuardarInfPrecios;
  end
  else
    mensaje(MENSAJE_RIESGO);
  Timer.enabled:=estadoTimer;
end;

procedure GuardarTodosLosPersonajes;
var i:integer;
    estadoTimer:boolean;
begin
  estadoTimer:=Timer.enabled;
  Timer.enabled:=false;
  if not f_Realizando_Turno then
  begin//Es seguro realizar el almacenamiento
    EnviarATodosAhora('I'+#1);
    for i:=0 to maxJugadores do
      GuardarUsuario(i);
  end
  else
    mensaje(MENSAJE_RIESGO);
  Timer.enabled:=estadoTimer;
end;

procedure LimpiarBolsas(precio_salvacion:integer);
var i:integer;
    estadoTimer:boolean;
begin
  estadoTimer:=Timer.enabled;
  Timer.enabled:=false;
  if not f_Realizando_Turno then
  begin
    for i:=0 to maxMapas do
      mapa[i].InicializarBolsas(precio_salvacion);
  end
  else
    mensaje(MENSAJE_RIESGO);
  Timer.enabled:=estadoTimer;
end;

//Métodos del juego que envían datos al cliente:
//--------------------------------------------------
function JugadorConsumir(Jug:TjugadorS;IndArt:byte):byte;
var cantidadDisponible:integer;
    idObj:byte;
    incrementaComida:bytebool;
    fueConsumido:bytebool;
  procedure CalcularConsumirHp(var consumido:byte;var consumidor:word;
    maximoConsumidor:word);
  var NuevoNivel:integer;
  begin
    if consumidor<maximoConsumidor then
      if consumido>0 then
      begin
        dec(consumido);
        NuevoNivel:=consumidor+PUNTOS_HP_MANA_POCION;
        if NuevoNivel>maximoConsumidor then
          NuevoNivel:=maximoConsumidor;
        consumidor:=NuevoNivel;
        result:=i_OK;
      end;
  end;
  procedure CalcularConsumirMana(var consumido,consumidor:byte;
    maximoConsumidor,bonoConsumo:byte);
  var NuevoNivel:integer;
  begin
    if consumidor<maximoConsumidor then
      if consumido>0 then
      begin
        dec(consumido);
        NuevoNivel:=consumidor+PUNTOS_HP_MANA_POCION+bonoConsumo;
        if NuevoNivel>maximoConsumidor then
          NuevoNivel:=maximoConsumidor;
        consumidor:=NuevoNivel;
        result:=i_OK;
      end;
  end;
  procedure IncrementarConLimite(var consumidor:byte;maximoConsumidor,Consumo:byte);
  var NuevoNivel:integer;
  begin
    if consumidor<maximoConsumidor then
      begin
        NuevoNivel:=consumidor+Consumo;
        if NuevoNivel>maximoConsumidor then
          NuevoNivel:=maximoConsumidor;
        consumidor:=NuevoNivel;
      end;
  end;
  procedure IncrementarWordConLimite(var consumidor:word;maximoConsumidor,Consumo:word);
  var NuevoNivel:integer;
  begin
    if consumidor<maximoConsumidor then
      begin
        NuevoNivel:=consumidor+Consumo;
        if NuevoNivel>maximoConsumidor then
          NuevoNivel:=maximoConsumidor;
        consumidor:=NuevoNivel;
      end;
  end;
  procedure consumirSolo1;
  begin
    with Jug.Artefacto[IndArt] do
    if modificador>0 then
    begin
      dec(modificador);
      result:=i_Ok;
    end
  end;
begin
  result:=i_Ok;
  with Jug do
  begin
    AccionAutomatica:=aaNinguna;
    idObj:=Artefacto[IndArt].id;
    Case idObj of//clase de objeto
      144..159://Bebidas y Comidas
      begin
        cantidadDisponible:=InfObj[idObj].modificadorADC;
        incrementaComida:=cantidadDisponible>0;
        if (incrementaComida) then
        begin
          inc(cantidadDisponible,comida);
          if cantidadDisponible>maxcomida then cantidadDisponible:=maxcomida;
          comida:=cantidadDisponible;
        end;
        case idObj of
          orBebidaAntiVeneno:
          if longbool(banderas and bnEnvenenado) and (random(3)=0) then
          begin
            Banderas:=Banderas xor BnEnvenenado;
            SendText(codigo,'ss');//No envenenado!!
            EnviarAlMapa_J(Jug,'B'+b2aStr(codigo)+char(banderas shr 8));
          end;
          orBebidaMasMANA:
          begin
            IncrementarConLimite(mana,maxMana,3);
            SendText(codigo,#254+char(mana));
            if (mana>=maxMana) and (accion=aaMeditando) then
              accion:=aaParado;
          end;
          orBebidaMasHP:
          begin
            IncrementarWordConLimite(hp,maxHp,3);
            SendText(codigo,#255+B2aStr(hp));
          end;
        end;
        //Luego disminuir cantidad, una porción fue consumida.
        if (Artefacto[IndArt].modificador>1) then
          dec(Artefacto[IndArt].modificador)
        else
          Artefacto[IndArt]:=ObNuloMDV;
        SendText(codigo,#253+char(comida));
        if idObj shr 3=18 then
        begin
          if (incrementaComida) then SendText(codigo,'i'+char(i_CalmasHambre));
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+'c')//comer
        end
        else
        begin
          if (incrementaComida) then SendText(codigo,'i'+char(i_CalmasSed));
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+'b');//beber
        end
      end;
      160..167,224://Pociones
      begin
        fueConsumido:=false;
        case idObj of
          160:begin//vida
            if (hp<maxhp) then
            begin
              CalcularConsumirHp(Artefacto[IndArt].modificador,hp,maxhp);
              SendText(codigo,#255+B2aStr(hp));
              fueConsumido:=true;
            end;
          end;
          161:begin//fuerza
            if (0 = (banderas and BnFuerzaGigante)) then
            begin
              consumirSolo1;
              banderas:=banderas or BnFuerzaGigante;
              CalcularDannoBase;
              SendText(codigo,'sF');
              inicializarTimer(tdFuerzaGigante,TIEMPO_MINIMO_CONJURO_POCIMA+nivel shr 1);
              //Sonido
              EnviarAlAreaMonstruo(jug,'S'+char(jug.coordx)+char(jug.coordy)+char(200+12{Fuerza Gigante}));
              fueConsumido:=true;
            end;
          end;
          162:begin//mana
            if (mana<maxmana) then
            begin
              CalcularConsumirMana(Artefacto[IndArt].modificador,mana,maxmana,Meditacion255);
              SendText(codigo,#254+char(mana));
              if (mana>=maxMana) and (accion=aaMeditando) then
                accion:=aaParado;
              fueConsumido:=true;
            end;
          end;
          163:begin//restituir
            if (esNecesarioDisiparMagia()) then
            begin
              consumirSolo1;
              if (codAnime>=Inicio_tipo_monstruos) then
              //Un jugador no puede tener animacion de monstruo
              //Y no estar bajo el efecto de un hechizo.
              begin
                determinarAnimacion;
                EnviarAlMapa(codMapa,'F'+B2aStr(codigo)+char(codAnime));
              end;
              restitucionAtributos;
              EnviarAlMapa_J(Jug,'a'{16 banderas}+b2aStr(codigo)+b2aStr(banderas));
              SendText(codigo,'s+');
              fueConsumido:=true;
            end;
          end;
          164:begin//Apresurar
            if (0 = (banderas and BnApresurar)) then
            begin
              consumirSolo1;
              banderas:=banderas or BnApresurar;
              inicializarTimer(tdApresurar,TIEMPO_MINIMO_CONJURO_POCIMA+nivel shr 1);
              EnviarAlMapa_J(Jug,'A'+b2aStr(codigo)+char(banderas));
              SendText(codigo,'sA');
              //Sonido
              EnviarAlAreaMonstruo(jug,'S'+char(jug.coordx)+char(jug.coordy)+char(200+14{Apresurar}));
              fueConsumido:=true;
            end;
          end;
          165:begin//sanacion
            if (esNecesarioSanar()) then
            begin
              consumirSolo1;
              sanacionCuracion;
              SendText(codigo,'sS');
              EnviarAlMapa_J(Jug,'B'+b2aStr(codigo)+char(banderas shr 8));
              //Sonido
              EnviarAlAreaMonstruo(jug,'S'+char(jug.coordx)+char(jug.coordy)+char(200+10{Sanacion}));
              fueConsumido:=true;
            end;
          end;
          166:begin//armadura
            if (0 = (banderas and BnArmadura)) then
            begin
              consumirSolo1;
              banderas:=banderas or BnArmadura;
              CalcularDefensa;
              inicializarTimer(tdArmadura,TIEMPO_MINIMO_CONJURO_POCIMA+nivel shr 1);
              EnviarAlMapa_J(Jug,'A'+b2aStr(codigo)+char(banderas));
              SendText(codigo,'sD');
              //Sonido
              EnviarAlAreaMonstruo(jug,'S'+char(jug.coordx)+char(jug.coordy)+char(200+13{Armadura}));
              fueConsumido:=true;
            end;
          end;
          167:begin//invisibilidad
            if (0 = (banderas and bnInvisible)) then
            begin
              consumirSolo1;
              banderas:=banderas or bnInvisible;
              inicializarTimer(tdInvisible,TIEMPO_MINIMO_CONJURO_POCIMA+nivel shr 2);
              EnviarAlMapa_J(Jug,'A'+b2aStr(codigo)+char(banderas));
              SendText(codigo,'sI');
              //Sonido
              EnviarAlAreaMonstruo(jug,'S'+char(jug.coordx)+char(jug.coordy)+char(200+22{Invisibilidad}));
              fueConsumido:=true;
            end;
          end;
          224:begin//proteccion divina
            if (0 = (banderas and BnProteccion)) then
            begin
              consumirSolo1;
              banderas:=banderas or BnProteccion;
              inicializarTimer(tdProteccion,TIEMPO_MINIMO_CONJURO_POCIMA+nivel shr 1);
              EnviarAlMapa_J(Jug,'A'+b2aStr(codigo)+char(banderas));
              SendText(codigo,'sP');
              //Sonido
              EnviarAlAreaMonstruo(jug,'S'+char(jug.coordx)+char(jug.coordy)+char(200+29{Proteccion}));
              fueConsumido:=true;
            end;
          end;
        end;

        if (fueConsumido) then
        begin
          //Enviar sonido de "beber".
          SendText(codigo,'i'+char(i_BebesPocima));
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+'b');//beber
        end;

        if Artefacto[IndArt].modificador=0 then
          Artefacto[IndArt].id:=0;
      end;
      else
        result:=i_error;
    end;//case
  end;
end;

function ApuntarMonstruoPorCodigoCasilla(Jug:TjugadorS):byte;
var apuntadoTemporal:TmonstruoS;
begin
  apuntadoTemporal:=GetMonstruoCodigoCasillaS(Jug.ObjetivoDeAtaqueAutomatico);
  if apuntadoTemporal=jug then apuntadoTemporal:=nil;
  with Jug do
  begin
    apuntado:=apuntadoTemporal;
    result:=byte(MonstruoApuntadoIncorrecto);
  end;
end;

function RealizarNotificarAgregarObjetoAlBaul(jug:TjugadorS;var ArtefactoAgregado:TArtefacto):boolean;
//true si mueve TODO al Baul
var i:integer;
    resultado:byte;
  procedure NotificarCambioObjeto;
  begin
    with Jug.Baul[i] do//Notificar al cliente del objeto del baul de castillo
      SendText(Jug.codigo,'I'+char(i+216{Refrescar Obj. Invent.})+char(id)+char(modificador));
  end;
begin
  result:=true;
  for i:=0 to MAX_ARTEFACTOS do
  begin
    resultado:=AgregarObjetoAObjeto(ArtefactoAgregado,jug.Baul[i]);
    if byteBool(resultado) then//si agrego todo o parte
    begin
      NotificarCambioObjeto;
      if resultado=MOVIO_TODO_A_DESTINO then exit;
    end;
  end;
  for i:=0 to MAX_ARTEFACTOS do
    if jug.Baul[i].id<4 then
    begin
      jug.Baul[i]:=ArtefactoAgregado;
      ArtefactoAgregado:=ObNuloMDV;
      NotificarCambioObjeto;
      exit;
    end;
  result:=false;
end;

function RealizarNotificarAgregarObjeto(jug:TjugadorS;var ArtefactoAgregado:TArtefacto):boolean;
var i:integer;
    resultado:byte;
  procedure NotificarCambioObjeto;
  begin
    with Jug.Artefacto[i] do//Notificar al cliente del objeto de su bolsa
      SendText(Jug.codigo,char(i+216{Refrescar Obj. Invent.})+char(id)+char(modificador));
  end;
begin
  result:=true;
  for i:=0 to MAX_ARTEFACTOS do
  begin
    resultado:=AgregarObjetoAObjeto(ArtefactoAgregado,jug.Artefacto[i]);
    if byteBool(resultado) then//si agrego todo o parte
    begin
      NotificarCambioObjeto;
      if resultado=MOVIO_TODO_A_DESTINO then exit;
    end;
  end;
  for i:=0 to MAX_ARTEFACTOS do
    if jug.Artefacto[i].id<4 then
    begin
      jug.Artefacto[i]:=ArtefactoAgregado;
      ArtefactoAgregado:=ObNuloMDV;
      NotificarCambioObjeto;
      exit;
    end;
  result:=false;
end;

procedure RealizarNotificarMejoraMonstruo(monstruo:Tmonstruos;victimaEsJugador:boolean);
var banderasAntiguas:integer;
begin
  with monstruo do
  begin
    banderasAntiguas:=banderas;
    if mejorar(victimaEsJugador) then
      if banderas<>banderasAntiguas then
        EnviarAlMapa(codMapa,'a'+b2aStr(codigo or ccmon)+b2aStr(banderas));
  end;
end;

procedure ConsumirMateriales(jug:TjugadorS;idObjeto:byte);
//Trata de crear el objeto con id=idObjeto.
//Informa al cliente de los materiales usados.
//Resta los materiales usados y si son suficientes agrega el nuevo material.
var
  i,j,ComidaTemp,CantidadAConstruir:integer;
  contadores:array[0..2] of integer;
  artefactoTemp,artefactoOrigenTemp,destinoTemp:TArtefacto;
  ID_Sonido:char;
  ModArtefacto:byte;
  cadena:string;
begin
  cadena:='';
  ModArtefacto:=1;
  with jug do
  begin
    with InfObj[idObjeto] do
    begin
      //Crear el nuevo artefacto
      artefactoTemp.id:=idObjeto;
      CantidadAConstruir:=infObj[idObjeto].CantidadConstruida;
      case CantidadAConstruir of
        0:artefactoTemp.modificador:=ModArtefacto;
        1:begin
          artefactoTemp.modificador:=MskEstadoObjetoNormal;
          //Asegurar que solo es 1 objeto.
          if (NumeroElementos(artefactoTemp)>1) then
            artefactoTemp.modificador:=1;
        end;
        else
          artefactoTemp.modificador:=CantidadAConstruir;
      end;
      //Verificar que existe espacio en la mano derecha.
      if Usando[uArmaDer].id>=4 then//no vacia
      begin
        destinoTemp:=Usando[uArmaDer];
        artefactoOrigenTemp:=artefactoTemp;
        if AgregarObjetoAObjeto(artefactoOrigenTemp,destinoTemp)<>MOVIO_TODO_A_DESTINO then
        begin
          SendText(jug.codigo,cadena+'i'+char(i_NecesitasManoDerechaLibre));
          exit;
        end;
      end;
      //Sonido:
      case HerramientaRequerida of
        ihMartillo:ID_Sonido:=#0;
        ihSerrucho:ID_Sonido:=#1;
        ihTijeras:ID_Sonido:=#2;
        ihLibroAlquimia:ID_Sonido:=#3;
        ihCalderoMagico:ID_Sonido:=#127;
        else ID_Sonido:=#255;
      end;
      if ID_sonido<>#255 then
        EnviarAlMapa(codMapa,'S'+char(coordx)+char(coordy)+ID_sonido);
      //Verificar materiales suficientes y consumirlos.
      for j:=0 to 2 do
        contadores[j]:=CantidadX[j];
      for i:=0 to MAX_ARTEFACTOS do//Revisar toda la bolsa de objetos
        for j:=0 to 2 do//Verificar con cada recurso necesario
          if Contadores[j]>0 then
            if artefacto[i].id=RecursoX[j] then
            begin
              if j=2 then ModArtefacto:=artefacto[i].modificador;
              if RestarCantidadDeMaterialConst(artefacto[i],contadores[j],cantidadConstruida<>0,true) then
              begin
                cadena:=cadena+char(i+8{Es del baul}+208{Refrescar Objetos})+
                  char(artefacto[i].id)+char(artefacto[i].modificador);
                break;
              end;
            end;
    end;
    //Si no había material suficiente salir
    for j:=0 to 2 do
      if contadores[j]>0 then
      begin
        //Informar al cliente de los materiales modificados
        SendText(jug.codigo,cadena+'i'+char(i_NoTienesTodosLosMateriales));
        exit;
      end;
    //Asignar calidad de la gema encontrada
    if CantidadAConstruir=0 then
      artefactoTemp.modificador:=ModArtefacto;//calidad de gema
    //Asignar nuevo objeto construido
    if Usando[uArmaDer].id<4 then
      Usando[uArmaDer]:=artefactoTemp//mano vacia, asignar directamente
    else
      AgregarObjetoAObjeto(artefactoTemp,Usando[uArmaDer]);//mano no vacia, intentar colocar el objeto.
    //Consumir comida
    ComidaTemp:=comida;
    dec(comidaTemp,InfObj[idObjeto].NivelConstructor shr 1);
    //Informar al cliente de los materiales modificados
    if ComidaTemp<>comida then
    begin
      if ComidaTemp<1 then comida:=1 else comida:=ComidaTemp;
      cadena:=cadena+#253+char(comida);
    end;
    cadena:=cadena+#208+char(Usando[uArmaDer].id)+char(Usando[uArmaDer].modificador);//+nuevo artefacto
    SendText(jug.codigo,cadena);
    //experiencia por construir objeto=4+nivelObjeto
    NotificarModificacionExperiencia(jug,4+InfObj[idObjeto].NivelConstructor);
  end;
end;

procedure ActivarZoomorfismo(Jug:TjugadorS);
begin
  with jug do
  if PuedeActivarZoomorfismo=i_ok then
  begin
    dec(mana,MANA_ZOOMORFISMO);//Ojo que "PuedeActivarZoomorfismo" controla que tenga esto de mana
    banderas:=banderas or bnZoomorfismo;
    CalcularDefensa;
    CalcularNivelAtaque;
    codAnime:=moOso;
    EnviarAlMapa_J(Jug,'F'+B2aStr(codigo)+char(codAnime));
    EnviarAlMapa(codMapa,'S'+char(coordx)+char(coordy)+#221);
    SendText(codigo,#254+char(mana)+'sZ');
  end;
end;

procedure FinalizarZoomorfismo(Jug:TjugadorS;posDestinoObjeto:byte);
begin
  with jug do
    if (posDestinoObjeto<=MAX_CASILLA_NEGADA_ZOOMORFISMO) then
      if (Usando[posDestinoObjeto].id>=56) and (Usando[posDestinoObjeto].id<=95) then
      begin
        banderas:=banderas xor bnZoomorfismo;
        CalcularDefensa;
        CalcularNivelAtaque;
        determinarAnimacion;
        EnviarAlMapa(codMapa,'S'+char(coordx)+char(coordy)+#219);
        SendText(codigo,'sz');
      end;
end;

procedure ActivarIraTenax(Jug:TjugadorS);
var tiempo:integer;
begin
  with Jug do
  if longbool(pericias and hbIraTenax) and (hp>PENA_HP_IRA_TENAX) then
  begin
    dec(hp,PENA_HP_IRA_TENAX);
    banderas:=banderas or bnIraTenax;
    CalcularDefensa;
    CalcularDannoBase;
    if nivel>MAX_NIVEL_NEWBIE then
      if nivel>=MIN_NIVEL_CATEGORIA then
        tiempo:=4
      else
        tiempo:=3
    else
      tiempo:=2;
    inicializarTimer(tdIraTenax,tiempo);
    EnviarAlMapa_J(Jug,'A'+b2aStr(codigo)+char(banderas));
    SendText(codigo,#255+B2aStr(hp)+'sX');
  end;
end;

procedure CambiarHonor(Jug:TjugadorS;NuevoNivelHonor:shortint);
var AnteriorComportamiento:shortint;
begin
  with Jug do
  begin
    AnteriorComportamiento:=comportamiento;
    comportamiento:=NuevoNivelHonor;
    {Pala recupero su honor, o lo perdio}
    if (CodCategoria=ctPaladin) and ((comportamiento xor AnteriorComportamiento) and $80<>0) then
    begin
      CalcularNivelAtaque;
      CalcularDefensa;
    end;
    EnviarAlMapa(CodMapa,'IR'+b2aStr(codigo)+char(comportamiento));
  end;
end;

procedure TeletransportarJugador(jug:TjugadorS;Codigo_Mapa,x,y:byte);
var exito:boolean;
begin
  //Mover a destino
  if (Codigo_Mapa=Jug.codMapa) then
    exito:=Mapa[Jug.codMapa].colocarJugador(Jug,x,y,true)
  else
    if Codigo_Mapa<=maxMapas then
      if Mapa[Codigo_Mapa].PuedeMoverseAEsteLugar(Jug,x,y) then
        with Jug do
        begin
          Mapa[codMapa].sacarJugador(Jug);
          codMapa:=codigo_mapa;
          Mapa[codMapa].colocarJugador(Jug,x,y,false);
          SendTextNow(codigo,'!');
          exito:=true;
        end
      else
        exito:=false
    else
      exito:=false;
  //quitar bandera controlado, de avatares en la carcel
  with jug do
    banderas:=(banderas or BnControlado) xor BnControlado;
  if not exito then
    SendText(jug.codigo,'i'+char(i_NoPuedesTeletransportarte));
end;

function GetMonstruoCodigoCasillaS(CodigoCasilla:word):TmonstruoS;
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

procedure FijarMovimiento(Jug:TjugadorS;posD:byte);
var dirDestino:TdireccionMonstruo;
    x,y:integer;
begin
  with Jug do
  begin
    if longbool(banderas and BnParalisis) or (not activo) then exit;
    banderas:=(banderas or bnSiguiendo) xor bnSiguiendo;
    AccionAutomatica:=aaCaminar;
    Control_Movimiento:=0;//Anular movimiento automatico actual
    dirDestino:=posd and mskDirecciones;
    if dir=dirDestino then
    begin
      x:=coordx+MC_avanceX[dirDestino];
      y:=coordy+MC_avanceY[dirDestino];
      //control de rango
      if x<0 then x:=0
      else
        if x>255 then x:=255;
      if y<0 then y:=0
      else
        if y>255 then y:=255;
      FdestinoX:=x;
      FdestinoY:=y;
    end
    else
    begin
      FDestinoX:=coordx;
      FDestinoY:=coordy;
      dir:=dirDestino;
      //Comando de dirección exclusivo jugador 144(cmdDireccion)+direccion sprite
      SendText(codigo,char((Dir and mskDirecciones)+144));
      //Comando de dirección 128(cmdDireccion)+direccion sprite
      EnviarAlMapa_J(Jug,char((Dir and mskDirecciones)+128)+b2aStr(codigo));
    end;
  end;
end;

procedure FijarCoordenadasDestino(Jug:Tjugadors;posd:word;destinoEsMonstruo:boolean);
begin
  if jug=nil then exit;
  with jug do
  begin
    if longbool(banderas and BnParalisis) or (not activo) then exit;
    if destinoEsMonstruo then
    begin
      //Apuntar a la casilla destino para seguir a monstruos
      apuntado:=GetMonstruoCodigoCasillaS(posd);
      if apuntado=Jug then apuntado:=nil;
      if apuntado=nil then exit;
      FDestinoX:=apuntado.coordx;
      FDestinoY:=apuntado.coordy;
      //verificar que el apuntado este "cerca"
      if (abs(FdestinoX-coordX)<=MaxRefrescamientoX) and (abs(FdestinoY-coordY)<=MaxRefrescamientoY) then
        Banderas:=Banderas or BnSiguiendo;
    end
    else
    begin
      FDestinoX:=posd and $FF;
      FDestinoY:=posd shr 8;
      Banderas:=(Banderas or BnSiguiendo) xor BnSiguiendo;
    end;
    AccionAutomatica:=aaCaminar;
    Control_Movimiento:=0;//Anular movimiento automatico actual
  end;
end;

procedure CalcularModificadorFinal(Monstruo:TmonstruoS;tipoAtaque:TTipoArma;var Danno:integer;EsJugador:bytebool);
var armaduraMagica:integer;
  procedure CalcularDannosEquipo(jug:TjugadorS);
  var  DannoArmadura:integer;
       elementoDannado:byte;
  begin
    DannoArmadura:=(danno shr 2);
    if DannoArmadura>0 then
    begin
      elementoDannado:=random(5);
      if DannarObjetoArmadura(jug.Usando[elementoDannado],DannoArmadura) then
      begin
        danno:=danno shr 1;
        with jug do
          if Usando[elementoDannado].id=0 then
          begin
            CalcularModDefensa;
            determinarAnimacion;
            EnviarAlMapa(codMapa,'F'+B2aStr(codigo)+char(codAnime));
          end;
        SendText(jug.codigo,char(234+elementoDannado)+char(jug.Usando[elementoDannado].modificador));
      end
    end;
  end;
  procedure calcularReduccion(armadura:integer;var danno:integer);
  begin
    if (danno<=1) then
      danno:=1
    else
    begin
      if armadura>0 then
        danno:=(danno shl 2) div (armadura+4)
      else
        if armadura<0 then
          danno:=(danno*(4-armadura)) shr 2;
      if (danno<1) then danno:=1;
    end;
  end;
begin
  if esJugador then
  with TjugadorS(Monstruo) do
  begin//Sólo jugadores
    if ((banderas and bnArmadura)<>0) and (tipoAtaque>taContundente) then
      armaduraMagica:=1
    else
      armaduraMagica:=0;
    if tipoAtaque<=taMagia then
      calcularReduccion(armadura[integer(tipoAtaque)]+armaduraMagica,danno);
    CalcularDannosEquipo(TJugadorS(Monstruo));
  end
  else
  begin//Sólo para monstruos:
    if ((Monstruo.banderas and bnArmadura)<>0) and (tipoAtaque>taContundente) then
      danno:=(danno shl 2) div 5;//20% de reducción.
    if danno>=1 then
    begin
      armaduraMagica:=(InfMon[Monstruo.TipoMonstruo].resistencias shr (byte(tipoAtaque) shl 2)) and $0F;
      if armaduraMagica<15 then
        danno:=(danno*(15-armaduraMagica)) shr 3
      else
        danno:=1;//invulnerable
    end
    else
      danno:=1//daño siempre positivo
{
    case (InfMon[Monstruo.TipoMonstruo].resistencias shr (byte(tipoAtaque) shl 2)) and $0F of//(resistencias%(tipoAtaque*4))mod 16
      0:if danno<1 then danno:=1 else inc(danno,(danno*3) shr 2);//175%
      1:if danno<1 then danno:=1 else inc(danno,danno shr 1);//150%
      2:if danno<1 then danno:=1 else inc(danno,danno shr 2);//125%
      3:if danno<1 then danno:=1;//100%
      4:if danno<3 then danno:=1 else danno:=(danno*3) shr 2;//75%
      5:if danno<4 then danno:=1 else danno:=danno shr 1;//50%
      6:if danno<8 then danno:=1 else danno:=danno shr 2;//25%
      7:danno:=1;
    end;
}
  end;
  //daños especiales:
  case tipoAtaque of
    taFuego:
      with monstruo do
      begin
        if longbool(banderas and BnCongelado) then
          ReducirTiempoDeTimer(tdCongelado,danno shr 1);
      end;
    taHielo:
      if (danno>=MINIMO_DANNO_PARA_CONGELACION) then
      with monstruo do
      begin
        banderas:=banderas or BnCongelado;
        inicializarTimer(tdCongelado,danno shr 1+2);
        if esJugador then
        begin
          EnviarAlMapa_J(TjugadorS(monstruo),'B'+b2aStr(codigo)+char(banderas shr 8));
          SendText(codigo,'sC');
        end
        else
          EnviarAlMapa(codmapa,'B'+b2aStr(codigo or ccmon)+char(banderas shr 8));
      end;
    taVeneno:
    begin
      if (danno>=MINIMO_DANNO_PARA_ENVENENAMIENTO) then
      with monstruo do
        if not longbool(banderas and bnEnvenenado) then
        begin
          banderas:=banderas or bnEnvenenado;
          if esJugador then
          begin
            EnviarAlMapa_J(TjugadorS(monstruo),'B'+b2aStr(codigo)+char(banderas shr 8));
            sendText(codigo,'s@');
          end
          else
            EnviarAlMapa(codmapa,'B'+b2aStr(codigo or ccmon)+char(banderas shr 8));
        end;
    end;
    taRayo:
      if (danno>=MINIMO_DANNO_PARA_REDUCCION_MANA) then
      with monstruo do
      begin
        Mana:=Mana shr 1;
        if esJugador then
          sendText(codigo,#254+char(mana));
      end;
  end;
  if danno>MAX_DEMONIO_HP then danno:=MAX_DEMONIO_HP;
end;

function ObtenerListaActivos(Jug:TjugadorS;Jugadores:boolean):string;
//Si Jug es nil devuelve lista completa
//Sino devuelve lista hasta 87 caracteres
var i,nro:integer;
begin
  nro:=0;
  result:='';
  if Jugadores then
  begin
    for i:=0 to maxjugadores do
      if Jugador[i].activo then
      begin
        inc(nro);
        if (Jug=nil) or (length(result)<MAX_TAM_MENSAJE_SERVIDOR) then
          result:=result+Jugador[i].nombreAvatar+','
      end
  end
  else
  begin
    for i:=0 to maxClanesjugadores do
      if ClanJugadores[i].miembrosActivos>0 then
      begin
        inc(nro);
        if (Jug=nil) or (length(result)<MAX_TAM_MENSAJE_SERVIDOR) then
          result:=result+ClanJugadores[i].nombre+' ('+inttostr(ClanJugadores[i].miembrosActivos)+'),'
      end
  end;
//  result:=result+'Hugo1,Paco1,Luis1,Hugo2,Paco2,Luis2,Hugo3,Paco3,Luis3,Hugo4,Paco4,Luis4,Hugo5,Paco5,Luis5,Hugo6,Paco6,Luis6,Hugo7,Paco7,Luis7,Hugo8,Paco8,Luis8,Hugo9,Paco9,Luis9,Hugo0,Paco0,Luis0,Hugo1,Paco1,Luis1,Hugo2,Paco2,Luis2,Hugo3,Paco3,Luis3,Hugo4,Paco4,Luis4,XXX';
  if Jug=nil then
    if result<>'' then
    begin
      result:=intastr(nro)+' ('+result;
      result[length(result)]:=')';
    end
    else
      result:=intastr(nro)
  else
  begin
    if (length(result)>MAX_TAM_MENSAJE_SERVIDOR+1) and (Jug<>nil) then
    begin
      result[MAX_TAM_MENSAJE_SERVIDOR]:=#160;
      delete(result,MAX_TAM_MENSAJE_SERVIDOR+1,maxint);
    end
    else
      delete(result,length(result),1);
    sendText(Jug.codigo,'IL'+b2aStr(nro)+chr(length(result))+result);
  end;
end;

procedure ObtenerListaMiembrosClan(Jug:TjugadorS);
var cadenaM,nombreDelLider:string;
    i,nroMiembrosClan:integer;
    ClanDelJugadorActual:byte;
begin//muestra los miembros del clan
  ClanDelJugadorActual:=Jug.clan;
  if ClanDelJugadorActual<=maxClanesJugadores then//el jugador tiene clan
  begin
    nombreDelLider:=ClanJugadores[ClanDelJugadorActual].lider;
    nroMiembrosClan:=0;
    cadenaM:='';
    for i:=0 to maxJugadores do
      if (Jugador[i].activo) then
        if (Jugador[i].clan=ClanDelJugadorActual) then
          begin
            if Jugador[i].nombreAvatar=nombreDelLider then
              cadenaM:=cadenaM+'*';
            cadenaM:=cadenaM+Jugador[i].nombreAvatar+',';
            inc(nroMiembrosClan);
            if length(cadenaM)>MAX_TAM_MENSAJE_SERVIDOR then break;
          end;
//  cadenaM:=cadenaM+'Hugo1,Paco1,Luis1,Hugo2,Paco2,Luis2,Hugo3,Paco3,Luis3,Hugo4,Paco4,Luis4,Hugo5,Paco5,Luis5,Hugo6,Paco6,Luis6,Hugo7,Paco7,Luis7,Hugo8,Paco8,Luis8,Hugo9,Paco9,Luis9,Hugo0,Paco0,Luis0,Hugo1,Paco1,Luis1,Hugo2,Paco2,Luis2,Hugo3,Paco3,Luis3,Hugo4,Paco4,Luis4,XXX';
    //cortando la cadena si es demasiado larga
    if length(cadenaM)>MAX_TAM_MENSAJE_SERVIDOR+1 then
    begin
      cadenaM[MAX_TAM_MENSAJE_SERVIDOR]:=#160;
      delete(cadenaM,MAX_TAM_MENSAJE_SERVIDOR+1,maxint);
    end
    else
      if nroMiembrosClan>0 then
        delete(cadenaM,length(cadenaM),1)//quitar ultima coma
      else
        cadenaM:='';
    SendText(Jug.codigo,'I*'+char(length(cadenaM))+cadenaM);
  end;
end;

procedure RepararAvatarYPosicion(Jug:Tjugadors);
var n_codMapa,n_coordx,n_coordy:byte;
begin
  with jug do
  begin
    repararAvatar;
    if not Mapa[codMapa].PosicionMonstruoValidaXY(Jug,coordx,coordy) then
    begin
      ObtenerPosicionInicial(n_codMapa,n_coordx,n_coordy);
      TeletransportarJugador(jug,n_codMapa,n_coordx,n_coordy);
    end;
  end;
end;

procedure ControlConsistenciaDatosGuardados(Jug:Tjugadors);
var CambioDeServidor:boolean;
//Necesario que el campo código de TjugadorS sea válido.
begin
  with Jug do
  begin
    //control de cambio de servidor:
    CambioDeServidor:=DatosUsuario[codigo].IdentificadorDeServidor<>ArchAdministradores.IdentificadorDeServidor;
    if CambioDeServidor then
    begin
      //Nueva posición:
      ObtenerPosicionInicial(codMapa,coordx,coordy);
      dineroBanco:=0;
      DatosUsuario[codigo].IdentificadorDeServidor:=ArchAdministradores.IdentificadorDeServidor;
      //Clanes
      Clan:=ninguno;
      //Magia
      TruncarArmasMagicasPoderosas;
    end
    else
      //Control de mapas:
      if (codMapa>maxMapas) or (not Mapa[codMapa].PosicionMonstruoValidaXY(Jug,coordx,coordy)) then
        ObtenerPosicionInicial(codMapa,coordx,coordy);
    if (codMapa>maxMapas) then
    begin//Al infierno si no existe el mapa
      codMapa:=0;
      coordx:=127;
      coordy:=127;
    end;
    if Clan<=MaxClanesJugadores then
      with ClanJugadores[Clan] do
      begin
        //Control de lider de clan, si no existe no tiene clan.
        if Lider='' then
          Clan:=ninguno;
        //Control de identificador de clan
        if DatosUsuario[codigo].IdentificadorDeClan<>IdentificadorDeClan then
          Clan:=ninguno;
        //Ajustar variable de actividad de clan
        if clan<>ninguno then
        begin
          UltimoLogIn:=ObtenerTiempoActualCodWord;
        end;
      end;
    //Calculos de gacos, etc.
    prepararParaIngresarJuego;
  end;
end;

procedure RealizarControlActivacionDeClanJugador(Jug:Tjugadors;ingresa:boolean);
begin
  if Jug.clan<=maxClanesJugadores then
    with ClanJugadores[Jug.clan] do
      if ingresa then
        if MiembrosActivos<=0 then
        begin
          EnviarATodos('Ik'+#1{1 clan}+char(Jug.clan)+b4aStr(PendonClan.color0)+b4aStr(PendonClan.color1)+
            char(colorClan)+char(length(nombre))+nombre);
          MiembrosActivos:=1;
        end
        else
          inc(MiembrosActivos)
      else
        if MiembrosActivos>0 then
          dec(MiembrosActivos);
end;

function FundarClanJugadores(JugLider:Tjugadors):bytebool;
var i:integer;
    t:single;
begin
  for i:=0 to maxClanesJugadores do
    if ClanJugadores[i].Lider='' then
      with ClanJugadores[i] do
      begin
        MiembrosActivos:=1;
        Lider:=JugLider.nombreAvatar;

        nombre:='Clan de '+Lider;
        JugLider.clan:=i;
        result:=true;
        UltimoLogIn:=ObtenerTiempoActualCodWord;
        colorClan:=0;
        Nousado1:=0;
        t:=frac(now/1000);//ciclo cada mil dias
        IdentificadorDeClan:=
          ((ord(Lider[0]) xor ord(Lider[1]) xor ord(Lider[2]) xor ord(Lider[3])) shl 24)
          xor integer((@t)^);
        DatosUsuario[JugLider.codigo].IdentificadorDeClan:=IdentificadorDeClan;
        PendonClan.color0:=$80000000;
        PendonClan.color1:=PendonClan.color0;
        EnviarATodos('IK'+char(i)+char(length(JugLider.nombreAvatar))+JugLider.nombreAvatar);
        EnviarAlMapa(JugLider.codMapa,'I'+#200+char(i)+b2aStr(JugLider.codigo));
        exit;
      end;
  result:=false;
end;

procedure EliminarRastrosDelClan(clanEliminado:byte);
var i:integer;
begin
  if clanEliminado>maxclanesJugadores then exit;
  for i:=0 to maxJugadores do
    with Jugador[i] do
      if activo then
      if clan=clanEliminado then
      begin
        dec(ClanJugadores[clan].MiembrosActivos);
        clan:=Ninguno;
        EnviarAlMapa(codMapa,'I'+#200+char(clan)+b2aStr(codigo));
      end;
  for i:=0 to maxMapas do
    with Mapa[i].castillo do
      if clan=clanEliminado then
      begin
        clan:=Ninguno;
        EnviarAlMapa(i,'IQ'+char(clan));
      end;
end;

procedure EnviarDatosClanesActivos(jug:TjugadorS);
var i,nroActivos:integer;
    mensaje:string;
begin
  mensaje:='Ik'+#0;
  nroActivos:=0;
  for i:=0 to maxClanesJugadores do
    with ClanJugadores[i] do
      if MiembrosActivos>0 then
      begin
        mensaje:=mensaje+char(i)+b4astr(pendonclan.color0)+b4astr(pendonclan.color1)+char(colorClan)+
          char(length(nombre))+nombre;
        inc(nroActivos);
      end;
  if nroActivos>0 then
    mensaje[3]:=char(nroActivos);
  SendText(jug.codigo,mensaje);
end;

procedure GuardarObjetoEnBaul(Jug:TjugadorS;indArtefacto,cantidad:byte);
var ObjetoTemporal,EstdAntrr:TArtefacto;
begin
  with Jug do
  if (hp<>0) and ((banderas and bnParalisis)=0) and (indArtefacto<=MAX_ARTEFACTOS) then
    with Mapa[codmapa] do
    if ((clan<=maxClanesJugadores) and (Castillo.clan=clan) and
        (ObtenerRecursoAlFrente(Jug)=irCastillo))
     or TieneElobjeto(orBaulMagico) then
    begin
      if Artefacto[IndArtefacto].id=orBaulMagico then exit;//No puedes guardar un baul mágico dentro de otro. :P
      EstdAntrr:=Artefacto[IndArtefacto];
      //Sacar la cantidad requerida
      ExtraerCantidadObjeto(Artefacto[IndArtefacto],ObjetoTemporal,cantidad);
      //Si no se guardo TODO en el baul, advertir que está lleno
      if not RealizarNotificarAgregarObjetoAlBaul(jug,ObjetoTemporal) then
        SendText(codigo,'i'+char(i_TuBaulEstaLleno));
      //Si sobro algo que no se pudo colocar en el baul, agregar denuevo al bolso:
      if ObjetoTemporal.id>=4 then
        if Artefacto[indArtefacto].id>=4 then//si quedo algo en el inventario agregar
          AgregarObjetoAObjeto(ObjetoTemporal,Artefacto[indArtefacto])
        else//Si no quedo nada directamente copiar el objeto temporal
          Artefacto[indArtefacto]:=ObjetoTemporal;
      //Actualizar objeto del bolso si es necesario
      with Artefacto[indArtefacto] do
        if (id<>EstdAntrr.id) or (modificador<>EstdAntrr.modificador) then
          SendText(codigo,char(216+indArtefacto)+char(id)+char(modificador));
    end;
end;

procedure SacarObjetoDeBaul(Jug:TjugadorS;indArtefacto,cantidad:byte);
var ObjetoTemporal,EstdAntrr:TArtefacto;
begin
  with Jug do
  if (hp<>0) and ((banderas and bnParalisis)=0) and (indArtefacto<=MAX_ARTEFACTOS) then
    with Mapa[codmapa] do
    if ((clan<=maxClanesJugadores) and (Castillo.clan=clan) and
        (ObtenerRecursoAlFrente(Jug)=irCastillo))
     or TieneElobjeto(orBaulMagico) then
    begin
      EstdAntrr:=Baul[IndArtefacto];
      //Sacar la cantidad requerida
      ExtraerCantidadObjeto(Baul[IndArtefacto],ObjetoTemporal,cantidad);
      //Si no se guardo TODO en el bolso, advertir que está lleno
      if not RealizarNotificarAgregarObjeto(jug,ObjetoTemporal) then
        SendText(codigo,'i'+char(i_TuInventarioEstaLleno));
      //Si sobro algo que no se pudo colocar en el bolso, agregar denuevo al baul:
      if ObjetoTemporal.id>=4 then
        if Baul[indArtefacto].id>=4 then//si quedo algo en el baul agregar
          AgregarObjetoAObjeto(ObjetoTemporal,Baul[indArtefacto])
        else//Si no quedo nada directamente copiar el objeto temporal
          Baul[indArtefacto]:=ObjetoTemporal;
      //Actualizar objeto del baul si es necesario
      with Baul[indArtefacto] do
        if (id<>EstdAntrr.id) or (modificador<>EstdAntrr.modificador) then
          sendText(codigo,'I'+char(216+indArtefacto)+char(id)+char(modificador));
    end;
end;

procedure ControlConsistenciaMapas;
var i:integer;
begin
  //control de lider del clan para castillos:
  for i:=0 to maxMapas do
    with mapa[i].castillo do
      if Clan<=MaxClanesJugadores then
        if ClanJugadores[clan].Lider='' then
        begin
          clan:=ninguno;
          banderasGuardian:=0;
        end;
end;

function AsegurarCamaradaPartyValido(duennoParty:TjugadorS; var codCasilla:word):boolean;
//verifica que CodCasilla contenga un camarada valido o lo coloca en CCVac.
var i:integer;
begin
  if codCasilla<=maxJugadores then
    with Jugador[codCasilla] do
      if activo and (hp<>0) then//activo y vivo
        for i:=0 to MAX_INDICE_PARTY do
          if CamaradasParty[i]=duennoParty.codigo then//enlace reciproco
          begin
            result:=true;
            exit;
          end;
  codCasilla:=ccVac;
  result:=false;
end;

procedure NotificarModificacionExperiencia(jug:TjugadorS;cantidadExp:integer);
begin
  if cantidadExp<1 then exit;
  with jug do
    if ModificarExperiencia(cantidadExp) then//unica llamada externa a esta funcion
    begin//Informar cambio de nivel
      SendText(codigo,'I^'+char(nivel)+b4aStr(getHabilidades));
      EnviarAlMapa_J(jug,'In'+char(nivel)+B2aStr(codigo));
    end
    else
      SendText(codigo,'e'+B2aStr(experiencia));
end;

procedure NotificarModificacionExperienciaRepartida(jug:TjugadorS;cantidadExp:integer);
var controlParty:word;
  procedure DistribuirExperiencia;
  var i:integer;
      cuota:array[0..MAX_INDICE_PARTY] of integer;
      total,total_1:integer;
  begin
    total:=jug.nivel;
    if total<=0 then exit;
    for i:=0 to MAX_INDICE_PARTY do
    begin
      cuota[i]:=0;
      if AsegurarCamaradaPartyValido(jug,jug.CamaradasParty[i]) then
        if (Jugador[jug.CamaradasParty[i]].codMapa=jug.codMapa) then
        begin
          cuota[i]:=Jugador[jug.CamaradasParty[i]].nivel;
          inc(total,cuota[i]);
        end;
    end;
    if total<=0 then exit;
    total_1:=total-1;
    for i:=0 to MAX_INDICE_PARTY do
      if cuota[i]>0 then
        NotificarModificacionExperiencia(Jugador[jug.CamaradasParty[i]],(cantidadExp*cuota[i]+total_1) div total);
    NotificarModificacionExperiencia(Jug,(cantidadExp*jug.nivel+total_1) div total);
  end;
begin
  with jug do
  begin
    controlParty:=CamaradasParty[0] and CamaradasParty[1] and CamaradasParty[2] and CamaradasParty[3];
    if controlParty=ccVac then
      NotificarModificacionExperiencia(jug,cantidadExp)
    else
      DistribuirExperiencia;
  end;
end;

procedure LlamarALasArmas(MonstruoLider:TmonstruoS);
var i:integer;
    AlineacionDelLider:word;
    codigoMapaDelLider:byte;
    coordxLider,coordyLider:byte;
//Necesario duenno y objetivo atacado.
begin
  with MonstruoLider do
  begin
    AlineacionDelLider:=duenno;
    codigoMapaDelLider:=codMapa;
    coordxLider:=coordx;
    coordyLider:=coordy;
  end;
  for i:=conta_Monstruos_Definidos to Indice_Maximo_Monstruos do
    with Monstruo[i] do
      if duenno=AlineacionDelLider then
        if codMapa=codigoMapaDelLider then
          if activo then
            if objetivoAtacado=ccvac then
              if (abs(coordx-coordxLider)<=MaxRangoArqueroEnNormaCuadrado) and
                (abs(coordy-coordyLider)<=MaxRangoArqueroEnNormaCuadrado) then
                  objetivoAtacado:=MonstruoLider.objetivoAtacado;
end;

procedure DisiparMonstruosDeJugadorSinClan(CodigoDelJugadorSinClan:word);
var i:integer;
begin
  for i:=conta_Monstruos_Definidos to Indice_Maximo_Monstruos do
    with Monstruo[i] do
      if duenno=CodigoDelJugadorSinClan then
        if activo then
          RitmoDeVida:=1;
end;

procedure atacarUnObjetivo(MonstruoLider:TmonstruoS;CodigoCasillaObjetivo:word);
var i:integer;
    AlineacionDelLider:word;
    codigoMapaDelLider:byte;
    coordxLider,coordyLider:byte;
//Necesario duenno y objetivo atacado.
begin
  with MonstruoLider do
  begin
    AlineacionDelLider:=duenno;
    codigoMapaDelLider:=codMapa;
    coordxLider:=coordx;
    coordyLider:=coordy;
  end;
  for i:=conta_Monstruos_Definidos to Indice_Maximo_Monstruos do
    with Monstruo[i] do
      if duenno=AlineacionDelLider then
        if codMapa=codigoMapaDelLider then
          if activo then
            if (abs(coordx-coordxLider)<=MaxVisionX) and (abs(coordy-coordyLider)<=MaxVisionY) then
              objetivoAtacado:=CodigoCasillaObjetivo;
end;

procedure seguirUnObjetivo(MonstruoLider:TmonstruoS);
var i:integer;
    AlineacionDelLider:word;
    codigoMapaDelLider:byte;
    coordxLider,coordyLider:byte;
//Necesario duenno y objetivo A Seguir.
begin
  with MonstruoLider do
  begin
    AlineacionDelLider:=duenno;
    codigoMapaDelLider:=codMapa;
    coordxLider:=coordx;
    coordyLider:=coordy;
  end;
  for i:=conta_Monstruos_Definidos to Indice_Maximo_Monstruos do
    with Monstruo[i] do
      if duenno=AlineacionDelLider then
        if codMapa=codigoMapaDelLider then
          if activo then
            if (abs(coordx-coordxLider)<=MaxVisionX) and (abs(coordy-coordyLider)<=MaxVisionY) then
            begin
              objetivoAtacado:=ccVac;
              objetivoASeguir:=MonstruoLider.objetivoASeguir;
            end;
end;

procedure DetenerMonstruos(MonstruoLider:TmonstruoS);
var i:integer;
    AlineacionDelLider:word;
    codigoMapaDelLider:byte;
    coordxLider,coordyLider:byte;
//Necesario duenno
begin
  with MonstruoLider do
  begin
    AlineacionDelLider:=duenno;
    codigoMapaDelLider:=codMapa;
    coordxLider:=coordx;
    coordyLider:=coordy;
  end;
  for i:=conta_Monstruos_Definidos to Indice_Maximo_Monstruos do
    with Monstruo[i] do
      if duenno=AlineacionDelLider then
        if codMapa=codigoMapaDelLider then
          if activo then
            if (abs(coordx-coordxLider)<=MaxVisionX) and (abs(coordy-coordyLider)<=MaxVisionY) then
            begin
              objetivoAtacado:=ccVac;
              objetivoASeguir:=ccVac;
            end;
end;

procedure InformarNuevoEstadoDeBolsa(RJugador:TjugadorS);
begin
  with RJugador do
    if (FlagsComunicacion and flRevisandoBolsa)<>0 then
    begin
      FlagsComunicacion:=FlagsComunicacion xor flRevisandoBolsa;//para que envie
      EnviarBolsaCompleta(RJugador);
    end;
end;

procedure EnviarBolsaCompleta(jug:TjugadorS);
{TODO: Optimizar envio de la bolsa}
var s:String;
begin
  with Jug do
    if ((hp<>0) or (comportamiento>comHeroe)) and (not longbool(banderas and BnParalisis))
      and ((FlagsComunicacion and flRevisandoBolsa)=0) then
    begin
      FlagsComunicacion:=FlagsComunicacion or flRevisandoBolsa;
      s:=Mapa[codMapa].BolsaACadena(coordx,coordy);
      if length(s)>1 then
        SendText(codigo,'IO'+s)
      else
      begin
        FlagsComunicacion:=FlagsComunicacion xor flRevisandoBolsa;
        EnviarAlMapa_J(jug,#192{Eliminar bolso}+char(coordx)+char(coordy));
        SendText(codigo,#193{Eliminar bolso vacio}+char(coordx)+char(coordy));
      end;
    end;
end;

procedure EnviarBaulCompleto(jug:TjugadorS);
begin
  with Jug do
    if (hp<>0) and (not longbool(banderas and BnParalisis)) then
      if Bytebool(FlagsComunicacion and flYaConoceSuBaul) then
        SendText(codigo,'Ib')
      else
      begin
        SendText(codigo,'IB'+BaulACadena);
        FlagsComunicacion:=FlagsComunicacion or flYaConoceSuBaul;
      end;
end;

procedure DetenerAcciones(Jug:TjugadorS);
begin
  with jug do
  begin
    accion:=aaParado;
    FDestinoX:=coordx;
    FDestinoY:=coordy;
    AccionAutomatica:=aaNinguna;
    Control_Movimiento:=0;
  end;
end;

procedure RealizarPalabradelRetorno(Jug:TjugadorS);
begin
  if jug=nil then exit;
  with Jug do
    if (hp=0) then
    begin
      with Mapa[codMapa] do
        if comportamiento<comNormal then
        begin
          CambiarHonor(Jug,0);
          SendText(codigo,'I'+#21);
          TeletransPortarJugador(Jug,0,127,127);//Al infierno por malo ;)
        end
        else
          if ((Posx_PalabraRetorno<>0) or (Posy_PalabraRetorno<>0)) then
            if (banderas and bnControlado)=0 then
              TeletransPortarJugador(Jug,Mapa_PalabraRetorno,Posx_PalabraRetorno,Posy_PalabraRetorno)
            else
            begin
              SendText(codigo,'I'+#14+char(NivelAgresividad));
              exit;
            end
          else
          begin
            SendText(codigo,'i'+char(i_NoEstasCercaDeCatedral));
            exit;
          end;
      RealizarYNotificarResureccionAvatar(jug,true);
    end;
end;

procedure EliminarCadaveres;
var i:integer;
begin
  for i:=0 to maxMapas do
    if Mapa[i].controlParaEliminarCadaveres<0 then
      Mapa[i].controlParaEliminarCadaveres:=MaxBolsas;
end;

procedure EjecutarComandoIniciarAtaque(Jug:TjugadorS;casilla:word;tipoAccion:TAccionAutomatica;continuo:boolean);
begin
  if continuo then
    jug.AccionAutomatica:=tipoAccion
  else
    jug.AccionAutomatica:=aaNinguna;
  jug.ObjetivoDeAtaqueAutomatico:=casilla;//utilizado siempre para definir el objetivo para ataque de rango y magico
  if tipoAccion=aaAtaqueOfensivo then
    Mapa[jug.codMapa].atacar(Jug,false)
  else if tipoAccion=aaAtaqueDefensivo then
    Mapa[jug.codMapa].atacar(Jug,true)
  else if tipoAccion=aaAtaqueMagia then
    Mapa[Jug.codMapa].LanzarConjuro(jug,0);
end;

procedure RealizarYNotificarResureccionAvatar(jug:TjugadorS;palabraDelRetorno:boolean);
var s:string;
begin
  with jug do
  begin
    if (comportamiento>comHeroe) then exit;
    resucitar;
    determinarAnimacion;
    if palabraDelRetorno then
      s:='i'+char(i_UsasPalabraRetornoFantasma)+'sr'
    else
      s:='sr';
    s:=s+'F'+B2aStr(codigo)+char(codAnime);
    sendText(codigo,s);
    EnviarAlMapa_J(jug,'='+B2aStr(codigo)+'r'+'F'+B2aStr(codigo)+char(codAnime));
  end;
end;

procedure EliminarEnlacesDePartyErroneos(jug:TjugadorS);
var i:integer;
begin
  for i:=0 to MAX_INDICE_PARTY do
    AsegurarCamaradaPartyValido(jug,jug.CamaradasParty[i]);
end;

procedure EliminarEnlacesDeParty(jug:TjugadorS);
var i:integer;
    jugador:TmonstruoS;
begin
  for i:=0 to MAX_INDICE_PARTY do
  begin
    jugador:=GetMonstruoCodigoCasillaS(jug.CamaradasParty[i]);
    jug.CamaradasParty[i]:=ccVac;
    if jugador<>nil then
      if jugador is TjugadorS then
        EliminarEnlacesDePartyErroneos(TjugadorS(jugador));
  end;
end;

function FormarEnlaceDeParty(duennoParty,jug:TjugadorS;var indiceDeCamaradaParty:byte):byte;
var i,j:integer;
begin
  with duennoParty do
    //buscar posicion libre
    for i:=0 to MAX_INDICE_PARTY do
    begin
      indiceDeCamaradaParty:=i;
      if CamaradasParty[i]=jug.codigo then//Ya esta en su party.
      begin
{        //eliminar tag
        CamaradasParty[i]:=ccVac;
        //y del otro jugador
        for j:=0 to MAX_INDICE_PARTY do
          if Jug.CamaradasParty[j]=codigo then
          begin
            Jug.CamaradasParty[j]:=ccVac;
            break;
          end;
        //informar de esto en result
        result:=i_Error;}
        result:=i_YaEstaEnTuParty;
        exit;
      end;
      //Asegurarse de eliminar las posiciones no validas
      if AsegurarCamaradaPartyValido(duennoParty,CamaradasParty[i]) then
        continue;//siguiente, este esta ocupado
      //buscar posicion libre en la lista de miembros del otro avatar
      for j:=0 to MAX_INDICE_PARTY do
      begin
        if AsegurarCamaradaPartyValido(jug,jug.CamaradasParty[j]) then
          continue;//siguiente, este esta ocupado
        //Verificar que estamos seleccionados en el compañero
        if (jug.TipoTransaccion=ttHacerParty) and (jug.CodigoMonstruoOferta=codigo) then
        begin
          jug.TipoTransaccion:=ttNinguna;
          CamaradasParty[i]:=jug.Codigo;
          jug.CamaradasParty[j]:=Codigo;
          result:=i_ok;
        end
        else
        begin
          TipoTransaccion:=ttHacerParty;
          CodigoMonstruoOferta:=jug.codigo;
          result:=i_TieneQueAgregarteASuParty;
        end;
        exit;
      end;
      result:=i_NoHayEspacioEnSuParty;
      exit;
    end;
  result:=i_NoHayEspacioEnTuParty;
end;

function PuedeAtacarAOtrosAvatares(Atacante,Victima:TjugadorS; var cod_result:byte; informarInmediatamente:boolean):boolean;
begin
  result:=false;
  if (Victima.clan=Atacante.clan) and (Atacante.clan<=maxClanesJugadores) then
  begin
    if informarInmediatamente then
      SendText(Atacante.codigo,'i'+char(i_NoPuedesAtacarMiembrosDeTuClan));
    cod_result:=i_NoPuedesAtacarMiembrosDeTuClan;exit;
  end;
  if (Atacante.FlagsComunicacion and flModoPKiller)=0 then
  begin
    if informarInmediatamente then
      SendText(Atacante.codigo,'i'+char(i_NoEstasEnModoPKiller));
    cod_result:=i_NoEstasEnModoPKiller;exit;
  end;
  //Si la victima no es agresiva
  if (victima.NivelAgresividad=0) and (victima.Comportamiento>=comNormal) then
    if (atacante.clan>maxClanesJugadores) then//atacante sin clan
    begin
      if (victima.nivelTruncado+2)<atacante.nivelTruncado then
      begin
        if informarInmediatamente then
          SendText(Atacante.codigo,'i'+char(i_NoPuedesAtacarAvataresPacifistas));
        cod_result:=i_NoPuedesAtacarAvataresPacifistas;exit;
      end
    end
    else
      if (victima.nivel<=MAX_NIVEL_NEWBIE) then
      begin
        if informarInmediatamente then
          SendText(Atacante.codigo,'i'+char(i_NoPuedesAtacarAvataresPacifistas));
        cod_result:=i_NoPuedesAtacarAvataresPacifistas;exit;
      end;
  result:=true;
end;

function EsteMonstruoEsEnemigo(Jug:TjugadorS; monstruo:Tmonstruos):byte;
begin
  result:=i_error;
  if monstruo=nil then exit;
  if monstruo is TjugadorS then
    with Jug do
    begin
      result:=i_ok;
      if not PuedeAtacarAOtrosAvatares(Jug,TjugadorS(monstruo),result,false) then exit;
      ActivarEstadoAgresivoEInformar(Jug);
    end
  else
    if monstruo.duenno<>Jug.duenno then
      result:=i_ok
    else
      result:=i_EsTuMonstruo;
end;

procedure ActivarEstadoAgresivoEInformar(Jug:TjugadorS);
begin
  with Jug do
    if ActivarEstadoAgresivo then
      if comportamiento>=comNormal then
        sendText(codigo,'I'+#13);
end;

procedure AturdirJugador(jug:TjugadorS);
begin
  with jug do
  if ((banderas and BnProteccion)=0) and ((banderas and BnAturdir)=0) then
  begin
    Banderas:=Banderas or BnAturdir;
    inicializarTimer(tdAturdir,6);
    CalcularNivelAtaque;
    EnviarAlMapa_J(jug,'A'+b2aStr(codigo)+char(banderas));
    SendText(codigo,'sT');
  end;
end;

procedure ParalizarMonstruo(mon:TmonstruoS;tiempo:byte);
begin
  with mon do
  begin
    banderas:=banderas or BnParalisis;
    if mon is TjugadorS then
    begin
      EnviarAlMapa_J(TJugadorS(mon),'A'+b2aStr(codigo)+char(banderas));
      SendText(codigo,'s(');
    end
    else
      EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
    inicializarTimer(tdParalisis,tiempo);
  end;
end;

procedure DisiparMagiaDeMonstruo(mon:TmonstruoS);
begin
  if mon is TjugadorS then
    with TJugadorS(mon) do
    begin
      if (codAnime>=Inicio_tipo_monstruos) then
      begin
        determinarAnimacion;
        EnviarAlMapa(codMapa,'F'+B2aStr(codigo)+char(codAnime));
      end;
      restitucionAtributos;
      EnviarAlMapa_J(TJugadorS(mon),'a'{16 banderas}+b2aStr(codigo)+b2aStr(banderas));
      SendText(codigo,'s+');
    end
  else
    with mon do
    begin
      if (codAnime<>TipoMonstruo) then
      begin
        codAnime:=TipoMonstruo;
        EnviarAlMapa(codMapa,'f'+B2aStr(codigo)+char(codAnime));
      end;
      if (Comportamiento=comMonstruoConjurado) and (ritmoDeVida<=250) then//reducir tiempo de vida
        ritmoDeVida:=ritmoDeVida shr 3;
      disiparMagia();
      EnviarAlMapa(codMapa,'a'{16 banderas}+b2aStr(codigo or ccmon)+b2aStr(banderas));
    end;
end;

procedure DarVisionVerdaderaAMonstruo(mon:TmonstruoS;tiempo:byte);
begin
  with mon do
  begin
    banderas:=banderas or BnVisionVerdadera;
    inicializarTimer(tdVisionVerdadera,tiempo);
    if mon is TjugadorS then
      with TJugadorS(mon) do
      begin
        DefinirCapacidadIdentificacion;
        EnviarAlMapa_J(TJugadorS(mon),'B'+b2aStr(codigo)+char(banderas shr 8));
        SendText(codigo,'sW');
      end
    else
      EnviarAlMapa(codMapa,'B'+b2aStr(codigo or ccMon)+char(banderas shr 8));
  end;
end;

function ListoParaAtacar(monstruoAt:TMonstruoS):boolean;
var TiempoDeAtacar:integer;
begin
  //NOTA IMPORTANTE: si TiempoEntreAtaques=0 => el monstruo nunca atacará!!
  with monstruoAt do
  begin
    TiempoDeAtacar:=InfMon[TipoMonstruo].TiempoEntreAtaques;
    if LongBool(banderas and BnCongelado) then
      TiempoDeAtacar:=TiempoDeAtacar shl 1;
    if LongBool(banderas and BnApresurar) then
      TiempoDeAtacar:=TiempoDeAtacar shr 1;
    result:=((Conta_Universal + codigo) mod TiempoDeAtacar)=0;
  end;
end;


procedure InformarAnimacionAtaque(monstruoAt:TmonstruoS);
begin
  with monstruoAt do//Comando de animacion de accion 160(cmdAccion)+accion monstruo
  begin
    AnimarAtaque;//Elegir animación adecuada para informar a jugadores.
    EnviarAlAreaMonstruo(monstruoAt,char((Accion and mskAcciones)+160)+B2aStr(codigo or ccMon));
    accion:=aaParado;//Fin de animación;
  end;
end;

procedure DesactivarInvisibilidadTemporalmente(monstruoAt:TmonstruoS);
var CodigoCasilla:word;
begin
  with monstruoAt do
    if longbool(banderas and BnInvisible) and TimerActivo(tdInvisible) then
    begin
      banderas:=banderas xor BnInvisible;
      CodigoCasilla:=monstruoAt.codigo;
      if not(monstruoAt is TjugadorS) then inc(CodigoCasilla,ccMon);
      EnviarAlMapa(codMapa,'A'+b2aStr(CodigoCasilla)+char(banderas));
    end;
end;

function AtaqueDeMonstruoConHechizos(monstruoAt:TmonstruoS;victima:TmonstruoS):boolean;
begin
  result:=true;
  with monstruoAt do
  begin
    //Definir si atacara o paralizara a su victima:
    if (mana>=18) then
      if Victima.RealizarResistenciaMagica=i_ok then
      begin
        //Hechizos
        if (Victima.banderas and bnParalisis)=0 then
        begin
          if (monstruoAt.PericiasDinamicas and perMon__DisiparMagia)<>0 then
            if (Victima.banderas and MskBanderasPositivas)<>0 then
            begin
              dec(mana,18);
              DisiparMagiaDeMonstruo(Victima);
              exit;
            end;
          if (monstruoAt.PericiasDinamicas and permon__Paralizar)<>0 then
          begin
            dec(mana,18);
            ParalizarMonstruo(Victima,8);
            exit;
          end;
          if victima is TJugadorS then
            if (monstruoAt.PericiasDinamicas and permon__aturdir)<>0 then
            begin
              dec(mana,18);
              AturdirJugador(TJugadorS(victima));
              exit;
            end;
        end;
      end;
  end;
  result:=false;
end;

end.

