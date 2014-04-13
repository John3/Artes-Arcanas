(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit TableroControlado;
{$C-}
interface
uses Demonios,Tablero,Objetos;
type
  TTableroControlado=Class(TTablero)
  protected
    //Para ciclos for i:=inicio to fin para controlar los monstruos de este mapa.
    IndiceInicioMonstruos,IndiceFinalMonstruos,IndiceInicioComerciantes:integer;
  public
    controlParaApagarFogatas:integer;//va de maxbolsas hasta 0, 0=desactivado.
    controlParaEliminarCadaveres:integer;
    procedure inicializar;
    function DireccionEnemigo(monstruo_mirando:TMonstruoS;rango:byte;dirst:TdireccionMonstruo):TdireccionMonstruo;
    function DireccionEnemigoClan(monstruo_mirando:TMonstruoS;rango:byte;dirst:TdireccionMonstruo):TdireccionMonstruo;
    function DireccionEnemigoJugador(jugador_mirando:TJugadorS;dirst:TdireccionMonstruo):TdireccionMonstruo;
    procedure definirCriaturas;
    procedure vidaCriatura(monstr:TmonstruoS);
    procedure ControlBolsasMapa(ControlarTodo:longbool);
    function EliminarBolsa(cdBolsaEliminada:word):boolean;
    function EliminarBolsaDelMapaYComunicarlo(x,y:byte):boolean;
    procedure LanzarConjuro(jugadorAt:TJugadorS;indArt:byte);
    procedure atacar(jugadorAt:TJugadorS;AtaqueDefensivo:boolean);
    function ataqueMonstruo(monstruoAt:TMonstruoS;Victima:TMonstruoS;TipoAlcance:TAlcanceArma;IdAtaqueElegido:byte):boolean;
    // True=> IntentoAtaque False=> NoIntentoAtaque
    function Mover(elemento:TMonstruoS;dirMov:TDireccionMonstruo;GirarYAvanzar:bytebool):bytebool;
    function colocarJugador(RJugador:TJugadorS;x,y:byte;SoloMover:bytebool):bytebool;
    procedure sacarJugador(RJugador:TJugadorS);
    procedure EliminarMarcaExistencia(Rmonstruo:TmonstruoS);
    function RealizarConjuroCombateCasilla(posConjuro_x,posConjuro_y:integer;MonstruoAt:TmonstruoS):boolean;
    procedure RealizarConjuroCombate(MonstruoVictima,MonstruoAt:TmonstruoS);
    procedure EngendrarMonstruo(Rmonstruo:TmonstruoS);
    procedure MoverAutomaticamente(Rjugador:TjugadorS);
    function ApuntarmonstruoXY(x,y:integer):TmonstruoS;
    procedure MuerteMonstruo(Rmonstruo:TmonstruoS;verdugo:TmonstruoS);
    procedure DisolverMonstruo(Rmonstruo:TmonstruoS);
    procedure MuerteJugador(RJugador:TjugadorS;verdugo:TmonstruoS);
    procedure SoltarObjetosMuerto(jug:TjugadorS);
    function SoltarObjetoXY(var Artefacto:Tartefacto;x,y:byte;tipoBolsa:TTipoBolsa;ReemplazarObjetoMenosCostoso:boolean):boolean;
    procedure RecogerObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte);
    procedure SoltarObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte);
    procedure VenderObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte;CodigoMonstruo:word);
    procedure ComprarObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte;CodigoMonstruo:word);
    procedure LlamarAtencionNPC(RJugador:TjugadorS;CodigoMonstruo:word);
    procedure SacarDinero(RjugadorOrigen,RJugadorDestino:TjugadorS;cantidad:integer);
    procedure UtilizarHerramienta(RJugador:TjugadorS;IndArt:byte);
    procedure FabricarArtefacto(RJugador:TjugadorS;IndArt,idObjeto:byte);
    procedure AlzarObjetos(RJugador:TjugadorS);
    procedure DescansarJugador(Rjugador:TjugadorS);
    procedure MeditarJugador(Rjugador:TjugadorS);
    procedure OcultarJugador(Rjugador:TjugadorS);
    procedure AceptarOferta(Rjugador:TjugadorS);
    function ConjurarMonstruo(Tipo_de_Monstruo,tiempo_vida:byte;x,y:smallint;ObjetivoParaAtacar:word;DuennoMonstruo:TmonstruoS):TmonstruoS;
    procedure JugadorMataVictima(JugadorAt:TjugadorS;Victima:TmonstruoS;VictimaEsJugador:boolean;idArma:byte);
    procedure EnviarDatosFinalesMapa(codigoJug:word);
    procedure enviarSpritesMapa(idConexion:word;x,y:byte);
    function GetRefrescamientoAreaJugador(x,y:integer):string;
    function EstaLloviendo(x,y:byte):boolean;
    function modificadorClima(infravision:boolean):integer;
    procedure EnviarDatosInicialesMapa(codigoJug:word;x,y:byte);
    procedure RealizarControlSensores(Rjugador:TjugadorS);
    procedure InicializarParaReactivar;
    procedure InicializarBolsas(precio_salvacion:integer);
    function RealizarComportamientoFlag(numero:byte):boolean;
    procedure SensorClick(RJugador:TjugadorS;x,y:byte);
    procedure ConsumirLaLlave(RJugador:TjugadorS;indiceDelSensor,indiceDeLaLlave:byte);
    function BolsaACadena(posx,posy:byte):string;
    procedure CambiarObjetivoAtaque(monstr:TmonstruoS;JugadorAtacante:TjugadorS);
  end;

implementation
uses Mundo,Smain,Globales;

const
  DURABILIDAD_ARMAS_MELEE=4;
  DURABILIDAD_ARMAS_RANGO=6;
  //Nota: los arcabuces tienen la mitad de durabilidad.
  DURABILIDAD_ARMAS_RANGO_EN_LLUVIA=2;

function minimo2(a,b:integer):integer; register;
asm
  cmp eax,edx
  jl @AEsMenor
    mov eax,edx
  @AEsMenor:
end;

//--------- TABLERO CONTROLADO ---------------------------
procedure TTableroControlado.inicializar;
var i:integer;
begin
  if bolsa=nil then
    getMem(Bolsa,sizeOf(TGrupoBolsas));
  FijarFlagsCalabozo:=0;
  BorrarFlagsCalabozo:=0;
  CambiarFlagsCalabozo:=0;
  controlParaApagarFogatas:=-1;
  controlParaEliminarCadaveres:=-1;
  InicializarBolsas(0{inicializar todas});
  InicializarParaReactivar;
  for i:=0 to 31 do
    RealizarComportamientoFlag(i);
end;

procedure TTableroControlado.InicializarBolsas(precio_salvacion:integer);
//precio_salvacion<=0 => inicializa todas. NUNCA envía informacion a los jugadores.
//precio_salvacion>0 => inicializa todas cuyo precio sea menor al de salvacion e informa de esto a los jugadores.
var i,j,precio:integer;
    cad:string;
begin
  if precio_salvacion<=0 then //quitar todas las bolsas
  begin
    BolsaLibre:=0;
    for i:=0 to MaxBolsas do
      Bolsa[i].tipo:=tbNinguna;
    //limpiar bolsas del mapa
    for i:=0 to MaxMapaAreaExt do
      for j:=0 to MaxMapaAreaExt do
        mapaPos[i,j].terBol:=mapaPos[i,j].terBol or mskBolsa;
  end
  else
  begin
    cad:='';
    for i:=0 to MaxBolsas do
      with bolsa[i] do
        if tipo<>tbNinguna then//evita anular bolsas accidentalmente con la informacion de una que no es válida.
        begin
          precio:=0;
          for j:=0 to MAX_ITEMS_BOLSA do
            if Item[j].id>=4 then
              inc(precio,PrecioArtefacto(Item[j]));
          if precio<precio_salvacion then
          begin
            tipo:=tbNinguna;
            if (mapaPos[posx,posy].terBol and mskBolsa)=i then//evita interferir con una bolsa distinta.
            begin
              mapaPos[posx,posy].terBol:=mapaPos[posx,posy].terBol or mskBolsa;
              cad:=cad+#192+char(posx)+char(posy);
            end;
          end;
        end;
    if cad<>'' then
      EnviarAlMapa(fcodMapa,cad);
  end;
end;

procedure TTableroControlado.InicializarParaReactivar;
begin
  with Castillo do
  begin
    Clan:=ninguno;//sin clan
    Dinero:=0;
    HP:=1000;
    Impuestos:=1;
    banderasGuardian:=0;
  end;
end;

procedure TTableroControlado.definirCriaturas;
//Sólo para el servidor!!!!
var i,j,conta_guardianes:integer;
begin
//Crear segun lo definido en el mapa.
  IndiceInicioMonstruos:=conta_Monstruos_Definidos;
  conta_guardianes:=0;
  for i:=0 to N_nidos-1 do
    with Nido[i] do
    begin
      if conta_Monstruos_Definidos>MaxMonstruos then break;
      for j:=0 to cantidad-1 do
      begin
        if conta_Monstruos_Definidos>MaxMonstruos then break;
        with Monstruo[conta_Monstruos_Definidos] do
        begin
          TipoMonstruo:=tipo;
          codMapa:=fcodMapa;
          codNido:=i;
          if infMon[tipoMonstruo].ConsecuenciaMuerte=cmCastilloReclamado then
            if (conta_guardianes<=max_guardianes) then
            begin
              CodigoMonstruoGuardian[conta_guardianes]:=codigo;
              inc(conta_guardianes);
            end;
          if LugarVacioXY(Monstruo[conta_Monstruos_Definidos],posx,posy) then
            ritmoDeVida:=0//intentar engendrar en el primer instante.
          else
            ritmoDeVida:=TurnosEntreEngendroDeMonstruos;
        end;
        inc(conta_Monstruos_Definidos);
      end;
    end;
  //NPJs. Definir Comerciantes.
  IndiceInicioComerciantes:=conta_Monstruos_Definidos;
  for i:=0 to N_Comerciantes-1 do
    with Comerciante[i] do
    begin
      if conta_Monstruos_Definidos>MaxMonstruos then break;
      with Monstruo[conta_Monstruos_Definidos] do
      begin
        TipoMonstruo:=MonstruoComerciante;
        comportamiento:=comComerciante;
        codMapa:=fcodMapa;
        duenno:=i;//tipo de comerciante.
        coordx_ant:=posx;
        coordy_ant:=posy;
        if LugarVacioXY(Monstruo[conta_Monstruos_Definidos],posx,posy) then
        begin
          mapaPos[posx,posy].monRec:=ccMon or codigo;
          activar(posx,posy);
        end;
      end;
      inc(conta_Monstruos_Definidos);
    end;
  //Definir los límites de id's de monstruos para este mapa
  if conta_Monstruos_Definidos>=(MaxMonstruos+1) then
    conta_Monstruos_Definidos:=(MaxMonstruos+1);
  IndiceFinalMonstruos:=conta_Monstruos_Definidos-1;
end;

procedure TTableroControlado.EngendrarMonstruo(Rmonstruo:TmonstruoS);
//RMonstruos nunca debe ser nil!!
//Engendra los monstruos del mapa.
begin
  with RMonstruo do
  if (codNido<N_Nidos) then
    with nido[codNido] do
      if LugarVacioXY(RMonstruo,posx,posy) then
        if (ritmoDeVida=0) then
        begin
          mapaPos[posx,posy].monRec:=ccMon or codigo;
          activar(posx,posy);
          //Efectos adicionales
          if infmon[tipoMonstruo].ConsecuenciaMuerte=cmcastilloReclamado then
          begin
            if castillo.clan=ninguno then
              duenno:=ccSinDuenno
            else
              duenno:=ccClan or castillo.clan;
            banderas:=castillo.banderasGuardian;
          end;
          if fcodMapa=0 then banderas:=bnVisionVerdadera or bnArmadura or bnFuerzaGigante or bnApresurar;
          //Engendro de monstruo
          EnviarAlMapa(fCodMapa,'n'+b2aStr(codigo)+char(coordx)+char(coordy)+
            char(dir or (accion shl 4))+char(codAnime));
          if banderas<>0 then
            EnviarAlMapa(fcodmapa,'a'+b2aStr(codigo or ccmon)+
              b2aStr(banderas));
        end
        else
          dec(ritmoDeVida)
      else
        ritmoDeVida:=TurnosEntreEngendroDeMonstruos;
end;

function TTableroControlado.ConjurarMonstruo(Tipo_de_Monstruo,tiempo_vida:byte;x,y:smallint;ObjetivoParaAtacar:word;DuennoMonstruo:TmonstruoS):TmonstruoS;
//Tiempo de vida=255 => hasta que muera.
//Conjura un monstruo para un jugador o para un clan.
var i:integer;
    monstruoQueSeraAtacado:TmonstruoS;
begin
  result:=nil;
  if (word(x)<=MaxMapaAreaExt) and (word(y)<=MaxMapaAreaExt) then
   if lugarVacioXY_PorTipoMonstruo(Tipo_de_Monstruo,x,y) then
    if (tipo_de_monstruo>=Inicio_tipo_monstruos) and (tipo_de_monstruo<=Fin_tipo_monstruos) then
     for i:=Indice_Conjurar_Monstruo to maxMonstruos do
      with Monstruo[i] do
      if not activo then
      begin
        TipoMonstruo:=Tipo_de_Monstruo;
        codMapa:=fcodMapa;
        ritmoDeVida:=tiempo_vida;
        mapaPos[x,y].monRec:=ccMon or codigo;
        activar(x,y);
        if tiempo_vida<>uNoDefinido then
          comportamiento:=comMonstruoConjurado;
        ObjetivoAtacado:=ObjetivoParaAtacar;
        if DuennoMonstruo=nil then
          duenno:=ccSinDuenno
        else
          if (DuennoMonstruo is TjugadorS) then
          begin
            if TjugadorS(DuennoMonstruo).clan<=maxClanesJugadores then
              duenno:=ccClan or TjugadorS(DuennoMonstruo).clan
            else//si NO tiene clan
              duenno:=DuennoMonstruo.codigo;
            //verificar que no ataque a su clan
            monstruoQueSeraAtacado:=GetMonstruoCodigoCasillaS(ObjetivoParaAtacar);
            if monstruoQueSeraAtacado<>nil then
              if not (monstruoQueSeraAtacado is TjugadorS) then
                if monstruoQueSeraAtacado.duenno=duenno then
                  ObjetivoAtacado:=ccVac;
          end
          else
            duenno:=DuennoMonstruo.duenno;
        //Engendro de monstruo
        EnviarAlMapa(fCodMapa,'n'+b2aStr(codigo)+char(coordx)+char(coordy)+
          char(dir or (accion shl 4))+char(codAnime));
        result:=Monstruo[i];
        //Nuevo monstruo conjurado, actualizar el máximo
        if i>Indice_Maximo_Monstruos then
          Indice_Maximo_Monstruos:=i;
        //Como esta era la primera posición libre, la proxima conjurar en la siguiente posición:
        inc(Indice_Conjurar_Monstruo);
        break;
      end;
end;

procedure TTableroControlado.sacarJugador(RJugador:TJugadorS);
begin
  with RJugador do
  begin
    activo:=false;
    EnviarAlMapa_J(Rjugador,'~'+B2aStr(codigo));//Informar a los clientes que salio del mapa
    fDestinoX:=CoordX;//no moverse autom.
    fDestinoY:=CoordY;
    mapaPos[coordx,coordy].monRec:=ccVac;
    if ((Conjuros and $12000000{conjuracion de monstruos})<>0) and (clan>maxClanesJugadores) then
      DisiparMonstruosDeJugadorSinClan(codigo);
  end;
end;

function TTableroControlado.GetRefrescamientoAreaJugador(x,y:integer):string;
const NRO_MAX_REFRESCADOS=128;
var cadena:string;
    i,j,conta:integer;
    casilla:word;
  procedure CerrarPaquete;
  begin
    cadena[2]:=char(conta);
    result:=result+cadena;
    conta:=0;
    cadena:='r0';
  end;
begin
  result:='';
  conta:=0;
  cadena:='r0';
  for j:=maximo2(y-MaxRefrescamientoY,0) to minimo2(y+MaxRefrescamientoY,255) do
    for i:=maximo2(x-MaxRefrescamientoX,0) to minimo2(x+MaxRefrescamientoX,255) do
    begin
      casilla:=mapaPos[i,j].monRec;
      case casilla and fl_Con of
        ccJgdr:
        begin
          with Jugador[casilla and fl_Cod] do
            cadena:=cadena+B2aStr(casilla)+char(coordx)+char(coordy)+char(dir or (accion shl 4));
          inc(conta);
          if conta>=NRO_MAX_REFRESCADOS then CerrarPaquete;
        end;
        ccMon:
        begin
          with Monstruo[casilla and fl_Cod] do
            cadena:=cadena+B2aStr(casilla)+char(coordx)+char(coordy)+char(dir or (accion shl 4));
          inc(conta);
          if conta>=NRO_MAX_REFRESCADOS then CerrarPaquete;
        end;
      end;
    end;
  case conta of
    0:cadena:='';
    1:begin
      cadena:=copy(cadena,2,6);
      cadena[1]:='P';
    end;
    2..255:begin
      cadena[2]:=char(conta);
    end;
  end;
  result:=result+cadena;
end;

function TTableroControlado.colocarJugador(RJugador:TJugadorS;x,y:byte;SoloMover:bytebool):bytebool;
//Teletrans=true si se movio dentro del mismo mapa.
{Cuando el jugador se mueve de un mapa a otro:
1. El cliente inicia evento de cambio de mapa.
2. Antes de comenzar el movimiento en el servidor:
- Llamar al procedimiento sacarJugador.
3. Movimiento en el servidor
- Actualizar el código de mapa (al mapa destino) del jugador en el servidor.(MUY IMPORTANTE)
- Llamar a este método con teletrans=false;
Resultado:
- En el cliente el sistema recupera el mapa y lo prepara.
- En el servidor se realizó el movimiento entre mapas.
}
var c,nx,ny:integer;
    vida:byte;
begin
  c:=0;
  nx:=x;
  ny:=y;
  while not LugarVacioXY(Rjugador,nx,ny) do
  begin
    if (c=MAX_INTENTOS_POSICIONAMIENTO) then
    begin
      result:=false;
      exit;
    end;
    nx:=x+MC_POSICIONAMIENTO_X[c];
    ny:=y+MC_POSICIONAMIENTO_Y[c];
    LimitarExt(nx,ny);
    inc(c);
  end;
  with RJugador do
  begin
    activo:=false;
    if SoloMover then
      mapaPos[coordx,coordy].monRec:=ccVac//borrar marca de existencia
    else
    begin
      //Efectos de pasar a otro mapa:
      TipoTransaccion:=ttNinguna;
      //Datos del nuevo Mapa:
      EnviarDatosInicialesMapa(codigo,nx,ny);
      EnviarSpritesMapa(codigo,nx,ny);
      EnviarDatosFinalesMapa(codigo);
    end;
    mapaPos[nx,ny].monRec:=codigo;
    activar(nx,ny);
    fDestinoX:=CoordX;//no moverse autom.
    fDestinoY:=CoordY;
    if SoloMover then
    begin
      SendText(codigo,'p'+char(coordX)+char(coordy)+char(dir or (accion shl 4))+
        GetRefrescamientoAreaJugador(coordX,coordY));
      //movimiento con efecto
      EnviarAlMapa_J(Rjugador,'*P'+b2aStr(codigo)+char(coordX)+char(coordy)+char(dir or (accion shl 4)));
    end
    else
    begin
      if hp=0 then vida:=0 else vida:=$80;
      EnviarAlMapa_J(Rjugador,'N'+b2aStr(codigo)+char(coordx)+char(coordy)+char(dir or (accion shl 4))+
        char(codAnime)+b2aStr(banderas)+char(nivel)+char(codCategoria or (TipoMonstruo shl 4) or vida)+
        char(comportamiento)+char(clan)+char(fcodCara)+char(length(nombreAvatar))+nombreAvatar);
    end;
  end;
  result:=true;
end;

function TTableroControlado.Mover(elemento:TMonstruoS;dirMov:TDireccionMonstruo;GirarYAvanzar:bytebool):bytebool;
var siguienteX,siguienteY:integer;
    anteriorX,anteriorY,anteriorDir:byte;
begin
  anteriorX:=elemento.coordx;
  anteriorY:=elemento.coordy;
  siguienteX:=anteriorX+MC_avanceX[dirMov];
  siguienteY:=anteriorY+MC_avanceY[dirMov];
  result:=lugarVacioVerificarFronterasXY(elemento,siguienteX,siguienteY);
{
  if InfMon[elemento.TipoMonstruo].tamanno>=4 then//gigantes
  //Ojo aqui no se estan controlando limites, como consecuencia sólo tenemos
  //un ligero efecto de mundo sin bordes.
    case dirMov of
      dsNorte:
        result:=result and lugarVacioXY(elemento,siguientex-1,siguientey)
                and lugarVacioXY(elemento,siguientex+1,siguientey);
      dsSud:
        result:=result and lugarVacioXY(elemento,siguientex-1,siguientey)
                and lugarVacioXY(elemento,siguientex+1,siguientey);
      dsOeste:
        result:=result and lugarVacioXY(elemento,siguientex,siguientey-1)
                and lugarVacioXY(elemento,siguientex,siguientey+1);
      dsEste:
        result:=result and lugarVacioXY(elemento,siguientex,siguientey-1)
                and lugarVacioXY(elemento,siguientex,siguientey+1);
      dsNorEste:
        result:=result
                and lugarVacioXY(elemento,siguientex-1,siguientey)
                and lugarVacioXY(elemento,siguientex,siguientey+1);
      dsNorOeste:
        result:=result
                and lugarVacioXY(elemento,siguientex+1,siguientey)
                and lugarVacioXY(elemento,siguientex,siguientey+1);
      dsSudEste:
        result:=result
                and lugarVacioXY(elemento,siguientex-1,siguientey)
                and lugarVacioXY(elemento,siguientex,siguientey-1);
      else
        result:=result
                and lugarVacioXY(elemento,siguientex+1,siguientey)
                and lugarVacioXY(elemento,siguientex,siguientey-1);
    end;
}
  //result indica si debe moverse o solo girar hacia "dir".
  with elemento do
  begin
    anteriorDir:=dir;
    dir:=dirMov;
    if result and ((dir=anteriorDir) or GirarYAvanzar) then
    begin
      accion:=aaCaminando;
      coordx:=siguienteX;
      coordy:=siguienteY;
      //borrar pos
      mapaPos[anteriorX,anteriorY].monRec:=ccVac;
      if elemento is TJugadorS then
        mapaPos[siguienteX,siguienteY].monRec:=elemento.codigo
      else
        mapaPos[siguienteX,siguienteY].monRec:=ccMon or elemento.codigo
    end
    else
      result:=false;
  end;
end;

procedure TTableroControlado.EliminarMarcaExistencia(Rmonstruo:TmonstruoS);
begin
  with RMonstruo do
  begin
    hp:=0;//Esta muerto.
    if activo then
    begin
      duenno:=ccSinDuenno;
      activo:=false;
      ritmoDeVida:=TurnosEntreEngendroDeMonstruos;
      mapaPos[coordx,coordy].monRec:=ccVac;//borrar rastro
      //Salir si no era un monstruo conjurado:
      if codigo<conta_Monstruos_Definidos then exit;
      //Actualizar Indice Maximo de Monstruos
      if codigo=Indice_Maximo_Monstruos then
        repeat
          dec(Indice_Maximo_Monstruos);
          if monstruo[Indice_Maximo_Monstruos].activo then break;
        until Indice_Maximo_Monstruos<Indice_Conjurar_Monstruo;
      //Si la posición liberada del monstruo es menor a la posición libre, actualizar:
      if codigo<Indice_Conjurar_Monstruo then
        Indice_Conjurar_Monstruo:=codigo;
    end;
  end;
end;

function TTableroControlado.AtaqueMonstruo(monstruoAt:TMonstruoS;Victima:TMonstruoS;TipoAlcance:TAlcanceArma;IdAtaqueElegido:byte):boolean;
//Inicio de Ataque seguro, enemigo al frente.
var lanzada,danno,defensa_en_Combate:integer;
    distancia:integer;
    PoderDelMonstruo:byte;
    VictimaEsJugador:byteBool;
    SonidoArma:char;
begin
  //evita bug del ataque del monstruo fantasma
  if (MonstruoAt.codMapa<>Victima.codMapa) then
  begin
    if Victima is TjugadorS then
      mensaje('Bug de ataque fantasma detectado contra: '+TjugadorS(Victima).nombreAvatar);
    result:=false;
    exit;
  end;
  result:=ListoParaAtacar(monstruoAt);
  if result then
  begin
    VictimaEsJugador:=Victima is TjugadorS;
    if not VictimaEsJugador then
      if Victima.objetivoAtacado=ccVac then
        Victima.objetivoAtacado:=monstruoAt.codigo or ccmon;
    PoderDelMonstruo:=(MonstruoAt.banderas and MskPoderMonstruo) shr DsPoderMonstruo;
    if TipoAlcance<>aaMagica then
    begin
      if VictimaEsJugador then
        defensa_en_Combate:=TJugadorS(Victima).PorcentajeDeDefensaTotal
      else
      begin
        defensa_en_Combate:=InfMon[Victima.TipoMonstruo].defensa;
        //conjuro Armadura:
        if LongBool(Victima.Banderas and BnArmadura) then
          inc(defensa_en_Combate,BONO_CONJURO_ARMADURA)
      end;
      if LongBool(MonstruoAt.Banderas and BnAturdir) then
        inc(defensa_en_Combate,PENA_MALDICION_ATURDIR);
      if bytebool(MC_direccionApunnalada[Victima.dir] and (1 shl MonstruoAt.dir)) then
        dec(defensa_en_Combate,PENA_ATAQUE_POR_ESPALDA);
      dec(defensa_en_Combate,PoderDelMonstruo shl BONO_ATAQUE_POR_NIVEL_PODER);
      if TipoAlcance=aaRango then
        with Victima do
        begin
          distancia:=round(sqrt(sqr(coordx-MonstruoAt.coordx)+sqr(coordy-MonstruoAt.coordy))*4);
          if distancia<7 then distancia:=25;//Si está muy cerca, es más dificil
          inc(defensa_en_Combate,distancia+modificadorClima(false)-InfMon[TipoMonstruo].tamanno*5);
        end;
      lanzada:=random(100);
    end
    else
    begin
      if AtaqueDeMonstruoConHechizos(monstruoAt,Victima) then exit;
      if IdAtaqueElegido>MAX_TIPOS_ATAQUE_MONSTRUO then
      begin
        result:=false;
        exit;
      end;
      with MonstruoAt do
      begin
        if comportamiento=comAtaqueHechizos then
          if mana>=3 then dec(mana,3) else mana:=0
        else
          if mana>=6 then dec(mana,6) else mana:=0;
      end;
      lanzada:=99;
      defensa_en_Combate:=0;
    end;
    InformarAnimacionAtaque(monstruoAt);
    DesactivarInvisibilidadTemporalmente(monstruoAt);
    if (lanzada>=MINIMO_PORCENTAJE_DE_ATAQUE) and
      (((lanzada+InfMon[monstruoAt.TipoMonstruo].NivelAtaque)>=defensa_en_Combate) or
      (lanzada>=NIVEL_ATAQUE_SIEMPRE_EXITOSO)) then
      with InfMon[monstruoAt.TipoMonstruo].Ataque[IdAtaqueElegido] do
      begin
        if (longbool(MonstruoAt.banderas and bnFuerzaGigante)) and (TTipoArma(tipoDanno)<=taVeneno) then
          danno:=BONO_CONJURO_FUERZA
        else
          danno:=0;
        inc(danno,base+random(plus)+(PoderDelMonstruo shl BONO_DANNO_POR_NIVEL_PODER));
        CalcularModificadorFinal(Victima,TTipoArma(tipoDanno),Danno,VictimaEsJugador);
        if danno>=Victima.hp then
        begin
          if (BanderasMapa and bmEsMapaCombate)=0 then
            RealizarNotificarMejoraMonstruo(MonstruoAt,VictimaEsJugador);//Y buscar nueva victima
          if VictimaEsJugador then
            MuerteJugador(TjugadorS(Victima),monstruoAt)
          else
            MuerteMonstruo(Victima,monstruoAt);
        end
        else
          with Victima do
          begin
            dec(hp,danno);
            if VictimaEsJugador then
            begin
              SendText(codigo,#252+B2aStr(hp)+char(cdNombre)+char(monstruoAt.tipoMonstruo));
            end;
          end;
        with Victima do
        begin
          if (Victima is TjugadorS) and EsIdArmaduraMetalica(TjugadorS(Victima).Usando[uArmadura].id) then
            SonidoArma:=Sonido_Ataque_Armadura[cdnombre]
          else
            SonidoArma:=Sonido_Ataque_Exitoso[cdnombre];
           EnviarAlAreaMonstruo(Victima,'S'+char(coordx)+char(coordy)+SonidoArma);
        end;
      end//with
    else
      with monstruoAt do
        EnviarAlAreaMonstruo(monstruoAt,'S'+char(coordx)+char(coordy)+'m');
  end
end;

procedure TTableroControlado.JugadorMataVictima(JugadorAt:TjugadorS;Victima:TmonstruoS;VictimaEsJugador:boolean;idArma:byte);
//Nota: idArma sólo aplicable para efecto de especialidad en armas no conjuradas de combate.
var cadena:string;
    i,NuevoComportamiento:integer;
    AnteriorEspecialidadArma,AnteriorNivelEspecialidad:byte;
begin
  with jugadorAt do
  if Victima=Apuntado then
  begin
    Apuntado:=nil;
    if AccionAutomatica=aaAtaqueMagia then
      AccionAutomatica:=aaNinguna;
  end;
  if VictimaEsJugador then
  begin
    //BEGIN: evitar bug de matar a un muro.
      if Victima.codigo>maxJugadores then exit;//seguridad
      if (Not Victima.activo) or (DatosUsuario[Victima.codigo].estadoUsuario=euNoConectado) then exit;
    //END
    with JugadorAt do//Determinar cambios en reputación
    begin
      //Control de Honor del atacante
      NuevoComportamiento:=comportamiento;
      if TJugadorS(Victima).nivel>=nivel then//Vencio a un jugador de mayor o igual nivel.
        inc(NuevoComportamiento,TJugadorS(Victima).BonoPorVencerAEsteJugador())
      else
        if Victima.comportamiento>=comNormal then//ataco a un jugador honorable
        if (TJugadorS(Victima).NivelAgresividad=0) then//ataco a un jugador NO agresivo
          if TJugadorS(Victima).nivelTruncado<nivelTruncado then//pierde honor
            //si no es mapa de combate
            if (BanderasMapa and bmEsMapaCombate)=0 then
            begin
              dec(NuevoComportamiento,(nivelTruncado-TJugadorS(Victima).nivelTruncado) shl 2);
              if NuevoComportamiento<comDemonio then
                NuevoComportamiento:=comDemonio;
            end;
      if NuevoComportamiento>comheroe then NuevoComportamiento:=comheroe;
      if (comportamiento<>NuevoComportamiento) then
        CambiarHonor(JugadorAt,NuevoComportamiento);
    end;
    cadena:='Im'+b2aStr(Victima.codigo);
    MuerteJugador(TjugadorS(Victima),JugadorAt)
  end
  else
  begin
    cadena:='Im'+b2aStr(Victima.codigo or CCMon);
    with InfMon[Victima.TipoMonstruo] do
    begin
      i:=Pexperiencia;
      if JugadorAt.nivel>nivelMonstruo then
        i:=(i shl 3) div (8+JugadorAt.nivel-nivelMonstruo);
      i:=i+Pexperiencia*((Victima.banderas and MskPoderMonstruo) shr DsPoderMonstruo);
      if ServidorEnModoDeVerificacion then
      begin
        i:=i shl 3;//dinero = 8x mp de la experiencia recibida
        inc(JugadorAt.dinero,i);
        SendText(JugadorAt.codigo,#250+b4aStr(JugadorAt.dinero));//informar nueva cantidad de dinero
        i:=i shl 1;//experiencia ganada = 16x.
      end;
      NotificarModificacionExperienciaRepartida(jugadorAt,i);
    end;
    MuerteMonstruo(Victima,JugadorAt);
  end;
  //Especialidad en armas
  with JugadorAt do
  begin
    AnteriorEspecialidadArma:=EspecialidadArma;
    AnteriorNivelEspecialidad:=NivelEspecializacion and $F8;
    if NivelEspecializacion=0 then
    begin
      if (EspecialidadArma>=16) and (idArma>=16) and (idArma<48)  then
      begin
        EspecialidadArma:=idArma;
        NivelEspecializacion:=2;
        if (AnteriorEspecialidadArma<>EspecialidadArma) then
          cadena:=cadena+'IE'+char(EspecialidadArma);
      end;
    end
    else
    begin
      //Ojo que no debe existir otra función que incremente/decremente "Nivel Especialización"!!!
      if EspecialidadArma<>idArma then
        if NivelEspecializacion>2 then
          dec(NivelEspecializacion,2)
        else
          NivelEspecializacion:=0
      else
        if NivelEspecializacion<253 then
          if nivel>=MIN_NIVEL_CATEGORIA then
            inc(NivelEspecializacion,2)
          else
            inc(NivelEspecializacion)
        else
          NivelEspecializacion:=255;
      if (AnteriorNivelEspecialidad<>(NivelEspecializacion and $F8)) then
        cadena:=cadena+'Ie'+char(NivelEspecializacion);
    end;
    SendText(codigo,cadena);
  end;
end;

function TTableroControlado.RealizarConjuroCombateCasilla(posConjuro_x,posConjuro_y:integer;MonstruoAt:TmonstruoS):boolean;
//Esto realiza los efectos del conjuro en la casilla indicada.
//Primero identifica el TmonstruoS afectado y luego procede.
//Devuelve false si el conjuro debe ser detenido. (En caso de que sea bloqueado por un muro por ejemplo)
//Sus parámetros pueden inidicar posición fuera del tablero, en ese caso no realiza el efecto del conjuro
var contenido:word;
begin
  //control de posición
  if (posConjuro_x<0) or (posConjuro_y<0) or (posConjuro_x>MaxMapaAreaExt) or (posConjuro_y>MaxMapaAreaExt) then
  begin
    result:=false;exit;
  end;
  //Identificar el monstruo afectado
  contenido:=mapaPos[posConjuro_x,posConjuro_y].monRec;
  if (contenido>=ccRec) then
  begin//impedido sólo si impide el conjuro
    result:=contenido>=ccVacRango;
    exit;//Si no existen monstruos en la casilla, salir
  end
  else
    result:=true;//no impedido
  if contenido<=maxJugadores then
    RealizarConjuroCombate(jugador[contenido],MonstruoAt)
  else
    if (contenido and fl_con)=ccMon then
      RealizarConjuroCombate(monstruo[contenido and fl_cod],MonstruoAt)
end;

procedure TTableroControlado.RealizarConjuroCombate(MonstruoVictima,MonstruoAt:TmonstruoS);
var danno,bono:integer;
    VictimaEsJugador:boolean;
    cod_result:byte;
//Sólo si la victima está muerta no será atacada.
begin
  //Afectar al monstruo
  if MonstruoVictima.hp<=0 then exit;//si esta muerto, salir.
  if not MonstruoVictima.activo then exit;
  if MonstruoAt=MonstruoVictima then exit;//si se ataca a si mismo (caso raro donde un jugador se ataca a si mismo por atacar y avanzar en el mismo turno)
  VictimaEsJugador:=MonstruoVictima is TJugadorS;
  if MonstruoAt is TJugadorS then
  begin
    with TJugadorS(MonstruoAt),InfConjuro[ConjuroElegido] do
    begin
      if VictimaEsJugador then
      begin
        if not PuedeAtacarAOtrosAvatares(TJugadorS(MonstruoAt),TJugadorS(MonstruoVictima),cod_result,false) then exit;
        ActivarEstadoAgresivoEInformar(TJugadorS(MonstruoAt));
      end
      else//es un monstruo
        CambiarObjetivoAtaque(MonstruoVictima,TJugadorS(MonstruoAt));
      if InfObj[Usando[uArmaDer].id].TipoArma<>taMagia then Bono:=1 else Bono:=InfObj[Usando[uArmaDer].id].danno1B;
      danno:=((DannoBaseCnjr*Bono*(32+nivel)) shr 6)+random(DannoBonoCnjr);
      CalcularModificadorFinal(MonstruoVictima,TTipoArma(TipoDannoCnjr),Danno,VictimaEsJugador);
    end;
    if danno>=MonstruoVictima.hp then//Le matas
      JugadorMataVictima(TJugadorS(MonstruoAt),MonstruoVictima,VictimaEsJugador,0{Sin efecto de especializacion})
    else
    begin
      dec(MonstruoVictima.hp,danno);
      if VictimaEsJugador then
        with MonstruoVictima do
        begin
          SendText(MonstruoAt.codigo,'D'+b2aStr(danno)+b2aStr(hp)+b2aStr(codigo));
          SendText(codigo,#249+b2aStr(hp)+char(TJugadorS(MonstruoAt).ConjuroElegido)+b2aStr(MonstruoAt.codigo))
        end
      else
      begin
        SendText(MonstruoAt.codigo,'d'+b2aStr(danno)+b2aStr(Monstruovictima.hp));
        //controlar cantidad de exp. ganada
        with infmon[MonstruoVictima.tipoMonstruo] do
          if danno>=nivelMonstruo then
          begin
            if TJugadorS(MonstruoAt).nivel>nivelMonstruo then
              bono:=HPPromedio div (4+TJugadorS(MonstruoAt).nivel-nivelMonstruo)
            else
              bono:=HPPromedio shr 2;
            inc(bono,danno);
          end
          else
            bono:=danno;
        NotificarModificacionExperiencia(TJugadorS(MonstruoAt),bono);
      end;
    end
  end
  else//El atacante no es un jugador
  begin
    if MonstruoVictima.objetivoAtacado=ccVac then
      MonstruoVictima.objetivoAtacado:=MonstruoAt.codigo or ccmon;
    with MonstruoAt,InfConjuro[AtaqueUtilizado and MskIdAtaque] do
    begin
      danno:=DannoBaseCnjr+random(DannoBonoCnjr);
      CalcularModificadorFinal(MonstruoVictima,TTipoArma(TipoDannoCnjr),Danno,VictimaEsJugador);
    end;
    if danno>=MonstruoVictima.hp then
    begin
      if (BanderasMapa and bmEsMapaCombate)=0 then//sólo mejorar si no es mapa de combate
        RealizarNotificarMejoraMonstruo(MonstruoAt,VictimaEsJugador);//Y buscar nueva victima
      //El que lanzo el conjuro es un monstruo
      if VictimaEsJugador then
        MuerteJugador(TjugadorS(MonstruoVictima),MonstruoAt)
      else
        MuerteMonstruo(MonstruoVictima,MonstruoAt);
    end
    else
      with MonstruoVictima do
      begin
        dec(hp,danno);
        if VictimaEsJugador then
          SendText(codigo,#252+B2aStr(hp)+char(AtaqueUtilizado and MskIdAtaque)+char(MonstruoAt.tipoMonstruo));
      end;
  end;
end;

procedure TTableroControlado.LanzarConjuro(jugadorAt:TJugadorS;indArt:byte);
var idMensajeLanzamiento:byte;
    NivelDeManaAnterior,ManaEnVarita:byte;
    SacoManaDeVarita:boolean;
  procedure InformarAnimacionYLanzamientoDeConjuro(CodigoConjuro:byte);
  begin
    with JugadorAt do
    begin
      if (infConjuro[CodigoConjuro].BanderasCnjr<>Msk_ConjuroModificadorObjeto) then
      begin
        AnimarConjuro;//determinar código de animación adecuado para informar a los jugadores
        SendText(codigo,char((Accion and mskAcciones)+176));
        EnviarAlAreaJugador_J(codigo,char((Accion and mskAcciones)+160)+B2aStr(codigo));
        accion:=aaParado;//Fin de animación;
      end;
      DesactivarInvisibilidadTemporalmente(jugadorAt);
      SendText(codigo,'i'+char(CodigoConjuro+i_InicioMensajesExitoDeConjuro));
    end;
  end;
  function LanzarConjuroModificador:byte;
  var nuevaDireccion:TDireccionMonstruo;
      MonstruoObjetivoDelConjuro:TMonstruoS;
    function RealizarConjuroModificador(M_Objetivo:TmonstruoS):byte;
    var ExperienciaGanada:integer;
        idMensajeConjuroMod:byte;
        VictimaEsJugador:boolean;
      procedure CurarHeridas;
      var HpACurar,MaxHPaCurar,MaxHPCurablePorMana:Integer;
      begin
        //Los hp que se pueden curar
        if VictimaEsJugador then
          with TjugadorS(M_Objetivo) do
            MaxHpACurar:=MaxHp-hp
        else
          with M_Objetivo do
          begin
            MaxHpACurar:=InfMon[TipoMonstruo].HPPromedio-hp;
            if MaxHpACurar<0 then
              MaxHpACurar:=0
            else
              if (MaxHpACurar+hp)>MAX_DEMONIO_HP then
                MaxHpACurar:=MAX_DEMONIO_HP-hp;
          end;
        if MaxHpACurar<=0 then exit;
        //Los hp que se curarán
        hpACurar:=(JugadorAt.nivel shl 1);
        if hpACurar>MaxHpACurar then hpACurar:=MaxHpACurar;
        //Los clerigos curan hasta 8hp por punto de mana
        if JugadorAt.codCategoria=CtClerigo then
        begin
          if hpACurar>24 then
          begin//optimizado con desplazadores, sin riesgo de op. en negativos!
            MaxHPCurablePorMana:=(JugadorAt.mana) shl 3;
            if MaxHPCurablePorMana>80 then MaxHPCurablePorMana:=80;
            if hpACurar>MaxHPCurablePorMana then hpACurar:=MaxHPCurablePorMana;
            dec(JugadorAt.mana,(hpACurar-17) shr 3{ManaExtraNecesario})
          end
        end
        else//El resto hasta 2hp por punto de mana
          if hpACurar>6 then
          begin//optimizado con desplazadores, sin riesgo de op. en negativos!
            MaxHPCurablePorMana:=(JugadorAt.mana) shl 1;
            if MaxHPCurablePorMana>40 then MaxHPCurablePorMana:=40;
            if hpACurar>MaxHPCurablePorMana then hpACurar:=MaxHPCurablePorMana;
            dec(JugadorAt.mana,(hpACurar-5) shr 1{ManaExtraNecesario})
          end;
        inc(M_Objetivo.hp,hpACurar);
        if VictimaEsJugador then//Informar que fue curado
          SendText(M_Objetivo.codigo,#255+B2aStr(M_Objetivo.hp));
      end;
      procedure SanarEnfermedad;
      //Igual que la pócima que restituye tu vitalidad.
      var nuevoNivel:integer;
      begin
        if VictimaEsJugador then
          with TJugadorS(M_Objetivo) do
          begin
            sanacionCuracion;
            SendText(codigo,'sS');
            EnviarAlMapa_J(TJugadorS(M_Objetivo),'B'+b2aStr(codigo)+char(banderas shr 8));
          end
        else
          with M_Objetivo do
          begin
            nuevoNivel:=(InfMon[TipoMonstruo].HPPromedio) shr 1;
            if (JugadorAt.CodCategoria<>ctClerigo) then
              nuevoNivel:=nuevoNivel shr 1;
            if nuevoNivel>hp then hp:=nuevoNivel;
            banderas:=(banderas or MskBanderasSanadas) xor MskBanderasSanadas;
            EnviarAlMapa(codmapa,'B'+b2aStr(codigo or ccmon)+char(banderas shr 8));
          end;
      end;
      procedure conjuroResucitar;
      begin
        if VictimaEsJugador then
        with TjugadorS(M_Objetivo) do
          if (hp=0) then
          begin
            RealizarYNotificarResureccionAvatar(TjugadorS(M_Objetivo),false);
            if (JugadorAt.CodCategoria<>ctClerigo) then
            begin
              JugadorAt.hp:=1;
              SendText(JugadorAt.codigo,#255+B2aStr(JugadorAt.hp));
            end;
          end
          else
            idMensajeConjuroMod:=i_SoloParaFantasmas;
      end;
      procedure ArmaduraMagica;
      begin
        with M_objetivo do
        begin
          banderas:=banderas or BnArmadura;
          inicializarTimer(tdArmadura,JugadorAt.TiempoConjuro(true));
          if VictimaEsJugador then
          begin
            TJugadorS(M_Objetivo).CalcularDefensa;
            EnviarAlMapa_J(TJugadorS(M_Objetivo),'A'+b2aStr(codigo)+char(banderas));
            SendText(codigo,'sD');
          end
          else
            EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
        end;
      end;
      procedure FuerzaGigante;
      begin
        with M_objetivo do
        begin
          banderas:=banderas or BnFuerzaGigante;
          inicializarTimer(tdFuerzaGigante,JugadorAt.TiempoConjuro(true));
          if VictimaEsJugador then
          begin
            TJugadorS(M_Objetivo).CalcularDannoBase;
            SendText(codigo,'sF');
            EnviarAlMapa_J(TJugadorS(M_Objetivo),'A'+b2aStr(codigo)+char(banderas));
          end
          else
            EnviarAlMapa(codMapa,'A'+b2aStr(codigo or CCmon)+char(banderas));
        end;
      end;
      Procedure Aturdir;
      begin
        with M_Objetivo do
        begin
          Banderas:=Banderas or BnAturdir;
          inicializarTimer(tdAturdir,JugadorAt.TiempoConjuro(true));
          if VictimaEsJugador then
            with TjugadorS(M_Objetivo) do
            begin
              CalcularNivelAtaque;
              EnviarAlMapa_J(TJugadorS(M_Objetivo),'A'+b2aStr(codigo)+char(banderas));
              SendText(codigo,'sT');
            end
          else
              EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
        end;
      end;
      procedure Apresurar;
      begin
        with M_objetivo do
        begin
          banderas:=banderas or BnApresurar;
          inicializarTimer(tdApresurar,JugadorAt.TiempoConjuro(true));
          if VictimaEsJugador then
          begin
            EnviarAlMapa_J(TJugadorS(M_Objetivo),'A'+b2aStr(codigo)+char(banderas));
            SendText(codigo,'sA');
          end
          else
            EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
        end;
      end;
      procedure ConjuroMaldecirObjeto;
      var i:integer;
      begin
        if VictimaEsJugador then
          with TjugadorS(M_Objetivo) do
            if (Usando[uAmuleto].id=orGemaAntiMaldicion)
              and (random(100)<Usando[uAmuleto].modificador) then
            begin
              idMensajeConjuroMod:=i_TieneGemaAntiMaldicion;
              exit;
            end
            else
              for i:=0 to 7 do
                if MaldecirObjeto(Usando[random(uAmuleto)]) then
                begin
                  CalcularModDefensa;
                  SendText(codigo,char(208+i)+char(Usando[i].id)+char(Usando[i].modificador)+
                    'i'+char(i_MaldicionSobreObjeto));
                  exit;
                end;
        idMensajeConjuroMod:=i_FalloConjuroMaldecir;
      end;
      procedure Paralizar;
      var TiempoParalisis:integer;
      begin
        TiempoParalisis:=JugadorAt.nivel;
        if VictimaEsJugador then
          dec(TiempoParalisis,TJugadorS(M_Objetivo).nivel)
        else
          dec(TiempoParalisis,InfMon[M_Objetivo.TipoMonstruo].nivelMonstruo);
        TiempoParalisis:=TiempoParalisis div 5;
        inc(TiempoParalisis,6);
        if (TiempoParalisis<2) then TiempoParalisis:=2;
        if (TiempoParalisis>10) then TiempoParalisis:=10;
        ParalizarMonstruo(M_Objetivo,TiempoParalisis)
      end;
      procedure DrenajeVampirico;
      //Pasa los hp de la victima y los convierte en maná para el mago.
      var ManaAGanar,HPChupados:integer;
      begin
        with JugadorAt do
        begin
          ManaAGanar:=(MaxMana - Mana) shr 1;
          if ManaAGanar<1 then ManaAGanar:=1;
        end;
        with M_Objetivo do
        begin
          HPChupados:=ManaAGanar;
          if HPChupados>(HP-1) then HPChupados:=(HP-1);
          if (HPChupados<=0) then
          begin
            idMensajeConjuroMod:=i_NoPuedesVampirearle;
            exit;
          end
          else
          begin
            dec(HP,HPChupados);
            if (hp<=1) then
              SendText(JugadorAt.codigo,'i'+char(i_LeDrenasteTodosMenosUnPuntoDeVida));
            with JugadorAt do
            begin
              ManaAGanar:=mana+HPChupados;
              if ManaAGanar>maxMana then ManaAGanar:=maxMana;
              mana:=ManaAGanar;
            end;
            if VictimaEsJugador then
              SendText(codigo,#249+b2aStr(hp)+char(JugadorAt.ConjuroElegido)+b2aStr(JugadorAt.codigo));
            //  Siempre informamos del nuevo nivel de mana al jugador atacante, por lo
            //que no informamos ahora.
          end;
        end;
      end;
      procedure ProteccionDivina;
      begin
        with M_objetivo do
        begin
          banderas:=banderas or BnProteccion;
          inicializarTimer(tdProteccion,JugadorAt.TiempoConjuro(false));
          if VictimaEsJugador then
          begin
            EnviarAlMapa_J(TJugadorS(M_Objetivo),'A'+b2aStr(codigo)+char(banderas));
            SendText(codigo,'sP');
          end
          else
            EnviarAlMapa(codMapa,'A'+b2aStr(codigo or CCmon)+char(banderas));
        end;
      end;
      procedure CambiarAspecto;
      begin
        if VictimaEsJugador then
          with TJugadorS(M_Objetivo) do
          begin
            if M_Objetivo=JugadorAt then
              case random(3) of
                0:codAnime:=129;//diablo
                1:codAnime:=moBeholder;
              else
                codAnime:=110;//gran escorpion
              end
            else
              if (Clan=JugadorAt.clan) and (clan<=MaxClanesJugadores) then
                case random(3) of
                  0:codAnime:=moGolem;
                  1:codAnime:=moEsqueleto;
                else
                  codAnime:=140;//centauro
                end
              else
                case random(3) of
                  0:codAnime:=moAranna;
                  1:codAnime:=moGacela;
                else
                  codAnime:=moNandu;
                end;
            EnviarAlMapa(fcodMapa,'F'+B2aStr(codigo)+char(codAnime));
          end
        else
          with M_Objetivo do
          begin
            case codAnime of
              moAranna..102:codAnime:=104;
              moGacela:codAnime:=moBeholder;
              moNandu:codAnime:=moOgro;
            else
              case random(3) of
                0:codAnime:=moAranna;
                1:codAnime:=moGacela;
              else
                codAnime:=moNandu;
              end;
            end;
            EnviarAlMapa(fcodMapa,'f'+B2aStr(codigo)+char(codAnime));
          end;
      end;
      procedure ConjuroInvisibilidad;
      begin
        with M_Objetivo do
        begin
          banderas:=banderas or bnInvisible;
          inicializarTimer(tdInvisible,JugadorAt.TiempoConjuro(true));
          if VictimaEsJugador then
          begin
            EnviarAlMapa_J(TJugadorS(M_Objetivo),'A'+b2aStr(codigo)+char(banderas));
            SendText(codigo,'sI');
          end
          else
            EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccMon)+char(banderas));
        end;
      end;
      procedure conjuroIdentificarObjetos;
      begin
        with JugadorAt do
          if Artefacto[indArt].id>=4 then
            if IdentificarObjeto(Artefacto[indArt]) then
              sendText(codigo,char(216{Refrescar Objetos}+indArt)+
                char(Artefacto[indArt].id)+char(Artefacto[indArt].modificador))
            else
              idMensajeConjuroMod:=i_YaEstaIdentificado
          else
            idMensajeConjuroMod:=i_SeleccionaObjetoInventario
      end;
      procedure ConjuroCrearObjetoMagico;
      begin
        with JugadorAt do
        begin
          idMensajeConjuroMod:=BendecirObjeto(Artefacto[indArt],Usando[uArmaDer]);
          if idMensajeConjuroMod=i_Ok then
            sendText(codigo,char(216{Refrescar Objetos}+indArt)+
              char(Artefacto[indArt].id)+char(Artefacto[indArt].modificador)+
              char(208{Refrescar Objetos}+uArmaDer)+
              char(Usando[uArmaDer].id)+char(Usando[uArmaDer].modificador))
        end;
      end;
      procedure ConjuroConjurarArma(ArmaArcana:boolean);
      begin
        with JugadorAt do
        begin
          idMensajeConjuroMod:=ConjurarArma(Usando[uArmaDer],ArmaArcana);
          if idMensajeConjuroMod=i_Ok then
            sendText(codigo,char(208{Refrescar Objetos}+uArmaDer)+
              char(Usando[uArmaDer].id)+char(Usando[uArmaDer].modificador));
        end;
      end;
      procedure ConjuroConjurarMonstruos(TipoDeMonstruo:byte);
      var i:integer;
          duracion:integer;
          ObjetivoParaAtacar:word;
      begin
        i:=0;
        with JugadorAt do
        begin
          if usando[uAmuleto].id=orGemaDelConjurador then
            duracion:=250
          else
            duracion:=(nivel shl 1)+INT+SAB;
          if apuntado=nil then
            ObjetivoParaAtacar:=ccvac
          else
            if VictimaEsJugador then
              ObjetivoParaAtacar:=apuntado.codigo
            else
              ObjetivoParaAtacar:=apuntado.codigo or ccmon;
        end;
        while (i<=7) and (conjurarMonstruo(TipoDeMonstruo,duracion,
          M_Objetivo.coordx+MC_avanceX[i],M_Objetivo.coordy+MC_avanceY[i],ObjetivoParaAtacar,JugadorAt)=nil) do inc(i);
        if i>7 then idMensajeConjuroMod:=i_NoPudisteConjurarMonstruo;
      end;
    begin
      VictimaEsJugador:=M_Objetivo is TJugadorS;
      with JugadorAt do
      begin
        if (bytebool(InfConjuro[ConjuroElegido].BanderasCnjr and cjConjuroAgresivo)) and (m_objetivo<>JugadorAt) then
        begin
          if VictimaEsJugador then
          begin
            if not PuedeAtacarAOtrosAvatares(JugadorAt,TJugadorS(M_Objetivo),result,false) then exit;
          end
          else
            if apuntado.duenno=(ccClan or JugadorAt.clan) then
            begin
              result:=i_NoPuedesAtacarMiembrosDeTuClan;exit;
            end;
          if LongBool(M_Objetivo.Banderas and BnProteccion) then
          begin
            result:=i_EstaProtegidoContraHechizosMalvados;exit;
          end;
        end;
        if m_objetivo<>JugadorAt then
        begin
          if ExisteObstaculo(coordx,coordy,m_objetivo.coordx,m_objetivo.coordy) then
          begin
            result:=i_ConjuroObstaculizado;exit;
          end;
          if VictimaEsJugador then
            with TJugadorS(M_Objetivo) do
              sendText(codigo,'C'+char(JugadorAt.ConjuroElegido)+b2AStr(JugadorAt.codigo));
        end;
        InformarAnimacionYLanzamientoDeConjuro(JugadorAt.ConjuroElegido);
        if bytebool(InfConjuro[ConjuroElegido].BanderasCnjr and cjConjuroAgresivo) then
        begin
          if VictimaEsJugador then
          begin
            if m_objetivo<>JugadorAt then//si no se lanzo el conjuro asi mismo.
              ActivarEstadoAgresivoEInformar(JugadorAt)
          end
          else
            CambiarObjetivoAtaque(M_Objetivo,JugadorAt);
        end;
        idMensajeConjuroMod:=M_Objetivo.RealizarResistenciaMagica;
        if idMensajeConjuroMod=i_Ok then
          case ConjuroElegido of
            9:CurarHeridas;
            10:SanarEnfermedad;
            11:conjuroResucitar;
            12:FuerzaGigante;
            13:ArmaduraMagica;
            14:Apresurar;
            15:ConjuroMaldecirObjeto;
            16:Paralizar;
            17:Aturdir;
            18:conjuroIdentificarObjetos;
            19:DisiparMagiaDeMonstruo(M_Objetivo);
            20:ConjuroCrearObjetoMagico;
            21:CambiarAspecto;
            22:ConjuroInvisibilidad;
            23:DarVisionVerdaderaAMonstruo(M_Objetivo,JugadorAt.TiempoConjuro(false));
            24:ConjuroConjurarArma(true);
            25:ConjuroConjurarMonstruos(moGolem);
            26:DrenajeVampirico;
            27:ConjuroConjurarArma(false);
            28:ConjuroConjurarMonstruos(moEsqueleto);
            29:ProteccionDivina;
          end;
        if idMensajeConjuroMod<>i_Ok then
        begin
          result:=idMensajeConjuroMod;
          exit;
        end
        else
        begin
          result:=ConjuroElegido+i_InicioMensajesExitoDeConjuro;
          dec(mana,InfConjuro[ConjuroElegido].nivelMANA);
          //sonido
          EnviarAlAreaMonstruo(M_objetivo,'S'+char(M_objetivo.coordx)+char(M_objetivo.coordy)+char(200+ConjuroElegido));
        end;
        //Experiencia
        with InfConjuro[ConjuroElegido] do
        //NOTA: nivel siempre será >= a nivelJugador, por requisito para lanzar este hechizo
          ExperienciaGanada:=(nivelINT+nivelSAB+nivelMana+nivel) SHR (nivel-nivelJugador);
        NotificarModificacionExperiencia(JugadorAt,ExperienciaGanada);
      end;
    end;
  begin
    MonstruoObjetivoDelConjuro:=nil;
    with InfConjuro[JugadorAt.ConjuroElegido],JugadorAt do
    begin
      result:=ApuntarMonstruoPorCodigoCasilla(JugadorAt);
      if byteBool(BanderasCnjr and cjPuedeLanzarObjetivo) and (apuntado<>nil) then
      begin//conjuro lanzado a un objetivo.
        result:=i_Error;//i_NoPuedesAtacarEsteNPC;
        if (apuntado.hp<=0) and (ConjuroElegido<>CD_CONJURO_RESUCITAR) then exit;
        if byteBool(BanderasCnjr and cjSoloJugadores) and not (apuntado is TjugadorS) then exit;
        nuevaDireccion:=CalcularDirExacta(apuntado.coordx-coordx,apuntado.coordy-coordy);
        if dir<>nuevaDireccion then
        begin
          NroTurnosGastados:=2;//Si solamente gira para lanzar el conjuro
          dir:=NuevaDireccion;
          sendText(codigo,char((dir and mskDirecciones)+144));
          //Comando de dirección 128(cmdDireccion)+direccion monstruo
          EnviarAlAreaJugador_J(codigo,char((dir and mskDirecciones)+128)+B2aStr(codigo));
          exit;
        end;
        MonstruoObjetivoDelConjuro:=apuntado;
      end
      else//Ver si puede lanzarse a si mismo
        if byteBool(BanderasCnjr and cjPuedeLanzarAsimismo) and (ObjetivoDeAtaqueAutomatico=ccVac) then
          MonstruoObjetivoDelConjuro:=JugadorAt;
      //para evitar enviar mensaje de error varias veces
      if apuntado=nil then ObjetivoDeAtaqueAutomatico:=ccVac;
    end;
    if MonstruoObjetivoDelConjuro<>nil then
      result:=RealizarConjuroModificador(MonstruoObjetivoDelConjuro);
  end;
  function LanzarConjuroCombate:byte;
  var i,x,y,p_x,p_y:integer;
      nuevaDireccion:TDireccionMonstruo;
  begin
    with InfConjuro[JugadorAt.ConjuroElegido] do
      if byteBool(BanderasCnjr and cjPuedeLanzarObjetivo) then
        with JugadorAt do
        begin
          result:=ApuntarMonstruoPorCodigoCasilla(JugadorAt);
          if apuntado=nil then ObjetivoDeAtaqueAutomatico:=ccVac;//para evitar enviar mensaje de error varias veces
          if result<>i_Ok then exit;//Asegura que apuntado sea válido y no nil
          if (apuntado.hp<=0) then
          begin
            result:=i_ConjuroSobreAvatarMuerto;
            exit;
          end;
          nuevaDireccion:=CalcularDirExacta(apuntado.coordx-coordx,apuntado.coordy-coordy);
          if dir<>nuevaDireccion then
          begin
            NroTurnosGastados:=2;//Si solamente gira para lanzar el conjuro
            dir:=NuevaDireccion;
            SendText(codigo,char((dir and mskDirecciones)+144));
            //Comando de dirección 128(cmdDireccion)+direccion monstruo
            EnviarAlAreaJugador_J(codigo,char((dir and mskDirecciones)+128)+B2aStr(codigo));
            result:=i_error;
            exit;
          end;
          if apuntado is TJugadorS then
          begin
            if not PuedeAtacarAOtrosAvatares(JugadorAt,TJugadorS(apuntado),result,false) then exit;
          end
          else
            if apuntado.duenno=(ccClan or JugadorAt.clan) then
            begin
              result:=i_NoPuedesAtacarMiembrosDeTuClan;exit;
            end;
          if ExisteObstaculo(coordx,coordy,apuntado.coordx,apuntado.coordy) then
          begin
            result:=i_ConjuroObstaculizado;exit;
          end;
          result:=ConjuroElegido+i_InicioMensajesExitoDeConjuro;
          InformarAnimacionYLanzamientoDeConjuro(ConjuroElegido);
          dec(mana,InfConjuro[ConjuroElegido].nivelMANA);
          EnviarAlAreaMonstruo(apuntado,'S'+char(apuntado.coordx)+char(apuntado.coordy)+char(200+ConjuroElegido));
          RealizarConjuroCombate(apuntado,JugadorAt);
        end
      else
      begin
        with JugadorAt do
        begin
          result:=ConjuroElegido+i_InicioMensajesExitoDeConjuro;
          InformarAnimacionYLanzamientoDeConjuro(ConjuroElegido);
          dec(mana,InfConjuro[ConjuroElegido].nivelMANA);
          EnviarAlAreaMonstruo(JugadorAt,'S'+char(coordx)+char(coordy)+char(200+ConjuroElegido));
          x:=coordx+MC_avanceX[dir];
          y:=coordy+MC_avanceY[dir];
        end;
        if byteBool(BanderasCnjr and cjPuedeLanzarAsimismo) then
        begin
          inc(x,MC_avanceX[JugadorAt.dir]);
          inc(y,MC_avanceY[JugadorAt.dir]);
          for i:=0 to MAX_INTENTOS_POSICIONAMIENTO do//Tormentas
          begin
            p_x:=x+MC_POSICIONAMIENTO_X[i];
            p_y:=y+MC_POSICIONAMIENTO_Y[i];
            RealizarConjuroCombateCasilla(p_x,p_y,JugadorAt)
          end
        end
        else
        begin
          p_x:=x;
          p_y:=y;
          for i:=0 to MAX_NRO_EXPLOSIONES do//Sale en linea recta
          begin
            inc(p_x,MC_avanceX[JugadorAt.dir]);
            inc(p_y,MC_avanceY[JugadorAt.dir]);
            if not RealizarConjuroCombateCasilla(p_x,p_y,JugadorAt) then break;
          end;
          if JugadorAt.ConjuroElegido<>7{no para el rayo} then
          begin
            p_x:=x+MC_avanceX[MC_anteriorDireccion[JugadorAt.dir]];
            p_y:=y+MC_avanceY[MC_anteriorDireccion[JugadorAt.dir]];
            for i:=0 to MAX_NRO_EXPLOSIONES-1 do//Sale en linea recta
            begin
              inc(p_x,MC_avanceX[JugadorAt.dir]);
              inc(p_y,MC_avanceY[JugadorAt.dir]);
              if not RealizarConjuroCombateCasilla(p_x,p_y,JugadorAt) then break;
            end;
            p_x:=x+MC_avanceX[MC_siguienteDireccion[JugadorAt.dir]];
            p_y:=y+MC_avanceY[MC_siguienteDireccion[JugadorAt.dir]];
            for i:=0 to MAX_NRO_EXPLOSIONES-1 do//Sale en linea recta
            begin
              inc(p_x,MC_avanceX[JugadorAt.dir]);
              inc(p_y,MC_avanceY[JugadorAt.dir]);
              if not RealizarConjuroCombateCasilla(p_x,p_y,JugadorAt) then break;
            end;
          end;
        end;
      end;
  end;
  function SacarManaDeVaritaMagica(nivelMana:byte):boolean;
  // OJO, sólo si mana<nivelMANA!!!
  var ManaExtraNecesario:integer;
  begin
    result:=false;
    with JugadorAt do
    begin
      if Usando[uArmaIzq].id<>ihVaritaLlena then exit;
      ManaEnVarita:=Usando[uArmaIzq].modificador;
      ManaExtraNecesario:=nivelMana-mana;
      with Usando[uArmaIzq] do
        if ManaExtraNecesario>ManaEnVarita then
        begin
          modificador:=0;
          id:=ihVaritaVacia;
          SendText(codigo,#209+char(id)+char(modificador)+'i'+char(i_TuVaritaMagicaSeAgoto))
        end
        else
        begin
          modificador:=ManaEnVarita-ManaExtraNecesario;
          mana:=nivelMana;
          result:=true;
        end;
    end;
  end;
begin
  if indArt>MAX_ARTEFACTOS then exit;
  with JugadorAt do
  if (hp<>0) and ((banderas and BnParalisis)=0) then
  if PuedeRecibirComando(12) then
  begin
    if ConjuroElegido>MAX_CONJUROS then exit;//conjuro elegido es revisado en el libro cada vez que cambia.
    fDestinoX:=CoordX;//no moverse autom.
    fDestinoY:=CoordY;
    NivelDeManaAnterior:=mana;
    with InfConjuro[ConjuroElegido] do
    begin
      if (nivel<nivelJugador) and not bytebool(BanderasCnjr and cjConjuroInicial) then exit;
      if mana<nivelMANA then
      begin
        SacoManaDeVarita:=SacarManaDeVaritaMagica(nivelMana);
        if not SacoManaDeVarita then exit;
      end
      else
        SacoManaDeVarita:=false;
      if InfConjuro[ConjuroElegido].TipoCnjr=tcCombate then
      begin
        idMensajeLanzamiento:=LanzarConjuroCombate();
        if (idMensajeLanzamiento<i_InicioMensajesExitoDeConjuro) and
        (idMensajeLanzamiento<>i_error) then
          AccionAutomatica:=aaNinguna;
      end
      else
      begin
        idMensajeLanzamiento:=LanzarConjuroModificador();
        AccionAutomatica:=aaNinguna;
      end;
      if SacoManaDeVarita then
        if (idMensajeLanzamiento<i_InicioMensajesExitoDeConjuro) then
        begin
          Usando[uArmaIzq].modificador:=ManaEnVarita;
          mana:=NivelDeManaAnterior;
        end
        else//todo bien, informar de la nueva cantidad de maná en la varita
          with Usando[uArmaIzq] do
          begin
            if modificador=0 then id:=ihVaritaVacia;
            SendText(codigo,#209+char(id)+char(modificador))
          end;
    end;
    if NivelDeManaAnterior<>mana then
      SendText(codigo,#254+char(mana));
    if idMensajeLanzamiento<>i_Error then
      if idMensajeLanzamiento<i_InicioMensajesExitoDeConjuro then
        SendText(codigo,'i'+char(idMensajeLanzamiento));
  end;
end;

procedure TTableroControlado.atacar(jugadorAt:TJugadorS;AtaqueDefensivo:boolean);
var Ataque_Combate:integer;
    idPosArma,cdError,cdErrorAlApuntar:byte;
  function realizarAtaqueRango(var ObjetoArma,municion:TArtefacto):byte;
  var lanzada,danno,defensa_en_Combate,Bono:integer;
      deltaX,deltaY,distancia:integer;
      Victima:TmonstruoS;
      VictimaEsJugador:boolean;
      nuevaDireccion:TdireccionMonstruo;
      SonidoArma:char;
      DurabilidadArma:byte;
      TipoAtaqueMunicion:TTipoArma;
  begin
    if jugadorAt.apuntado=nil then
    begin
      result:=i_ApuntaPrimero;
      exit;
    end;
    with jugadorAt do
    begin
      if Apuntado.hp<=0 then
      begin
        result:=i_ApuntaPrimero;
        exit;//Si ya esta muerto.
      end;
      Victima:=Apuntado;
      deltax:=Victima.coordx-coordx;
      deltay:=Victima.coordy-coordy;
      nuevaDireccion:=CalcularDirExacta(deltaX,deltaY);
      if dir<>nuevaDireccion then
      begin
        NroTurnosGastados:=2;//Si solamente gira.
        dir:=NuevaDireccion;
        SendText(codigo,char((dir and mskDirecciones)+144));
        //Comando de dirección 128(cmdDireccion)+direccion monstruo
        EnviarAlAreaJugador_J(codigo,char((dir and mskDirecciones)+128)+B2aStr(codigo));
        result:=i_error;//girando
        exit;
      end;
      VictimaEsJugador:=Victima is TjugadorS;
      //Control de clan
      if VictimaEsJugador then
      begin
        if not PuedeAtacarAOtrosAvatares(JugadorAt,TJugadorS(Victima),result,true) then exit;
      end
      else
      begin
        if Victima.duenno=(ccClan or JugadorAt.clan) then
        begin
          SendText(JugadorAt.codigo,'i'+char(i_NoPuedesAtacarMiembrosDeTuClan));
          result:=i_NoPuedesAtacarMiembrosDeTuClan;exit;
        end;
      end;
    //Salir si el camino al monstruo está bloqueado.
      if ExisteObstaculo(coordx,coordy,Victima.coordx,Victima.coordy) then
      begin
        SendText(codigo,'i'+char(i_disparoObstaculizado));
        exit;
      end;
      //Si no está bloqueado y no es de su clan:
      if VictimaEsJugador then
        ActivarEstadoAgresivoEInformar(JugadorAt)
      else
        CambiarObjetivoAtaque(Victima,JugadorAt);
      DecrementarCantidadMunicion(municion);
      //Informar al cliente que gasto munición:
      SendText(codigo,char(uMunicion+208{refrescar Obj.})+
        char(municion.id)+char(municion.modificador));
      if ObjetoArma.id=idArcabuz then SonidoArma:='A' else SonidoArma:='R';
      EnviarAlAreaMonstruo(JugadorAt,'S'+char(coordx)+char(coordy)+SonidoArma);
    end;
    with InfObj[Municion.id],InfMon[Victima.TipoMonstruo] do //Arma usada,MonstruoAtacado
    begin
      if VictimaEsJugador then
        with TJugadorS(Victima) do
          defensa_en_Combate:=PorcentajeDeDefensaTotal
      else
      begin
        defensa_en_Combate:=defensa;
        //conjuro Armadura:
        if LongBool(Victima.Banderas and BnArmadura) then
          inc(defensa_en_Combate,BONO_CONJURO_ARMADURA)
      end;
      with jugadorAt.usando[uAmuleto] do
        if id=orAmuletoGuardabosques then //amuleto guarda.
          dec(defensa_en_Combate,(modificador and MskEstadoObjetoNormal) shr 2);
      distancia:=round(sqrt(sqr(deltax)+sqr(deltay))*4);
      if distancia<7 then distancia:=25;//Si está muy cerca, es más dificil
      inc(defensa_en_Combate,distancia+modificadorClima(jugadorAt.tieneInfravision())-tamanno*5);
      if JugadorAt.EspecialidadArma=ObjetoArma.id then
        dec(defensa_en_Combate,(JugadorAt.NivelEspecializacion shr 3)+4);
      if bytebool(MC_direccionApunnalada[Victima.dir] and (1 shl JugadorAt.dir)) then
        dec(defensa_en_Combate,PENA_ATAQUE_POR_ESPALDA);
      lanzada:=random(100);
      if (lanzada>=MINIMO_PORCENTAJE_DE_ATAQUE) and
        (((lanzada+Ataque_Combate+CalcularModificadorAtaDef(ObjetoArma)+CalcularModificadorAtaDef(Municion))>=Defensa_en_combate) or (lanzada>=NIVEL_ATAQUE_SIEMPRE_EXITOSO)) then
      begin
        if EstaLloviendo(JugadorAt.coordx,JugadorAt.coordy) then
          DurabilidadArma:=DURABILIDAD_ARMAS_RANGO_EN_LLUVIA
        else
          DurabilidadArma:=DURABILIDAD_ARMAS_RANGO;

        if ((ObjetoArma.id and $7)>=4) or (TieneModificadorDeObjetoHechizado(ObjetoArma)) then //fuerza sólo para arco y flecha, no para ballestas
          danno:=JugadorAt.dannoBase//con efecto de fuerza
        else
          danno:=32;//daño normal = 100%
        inc(danno,JugadorAt.nivel shr 1);//bono por nivel
        if JugadorAt.EspecialidadArma=ObjetoArma.id then//Bono especialidad
          inc(danno,(JugadorAt.NivelEspecializacion shr 3)+1);

        //Modificadores de daño:
        if bytebool(municion.modificador and mskEnvenenado) then
          TipoAtaqueMunicion:=taVeneno
        else
          TipoAtaqueMunicion:=taPunzante;
        //Calcular bono magico y modificador de tipo de danno.
        Bono:=CalcularBono(ObjetoArma,TipoAtaqueMunicion);

        if tamanno<=2 then//monstruos medianos, pequeños y diminutos
          danno:=danno*(InfObj[ObjetoArma.id].danno1b+danno1b+Bono)+random(danno1P*danno)
        else
          danno:=danno*(InfObj[ObjetoArma.id].danno2b+danno2b+Bono)+random(danno2P*danno);
        danno:=smallint(danno shr 5);
        if ObjetoArma.id=idArcabuz then
        begin//Daño del arcabuz
          inc(danno,5-(distancia shr 2));
          DurabilidadArma:=DurabilidadArma shr 1;
        end;
        CalcularModificadorFinal(Victima,TipoAtaqueMunicion,Danno,VictimaEsJugador);
        //Es dardo paralizante?
        if bytebool(municion.modificador and mskParalizante) then
          if ((municion.id=ihDardosParalisis) and (random(2)=0)) or (danno>=10)  then
            if Victima.RealizarResistenciaMagica=i_ok then
              ParalizarMonstruo(Victima,2);
        //Control de arma
        if controlArmaDannada(ObjetoArma,DurabilidadArma) then
          SendText(JugadorAt.codigo,char(234+idPosArma)+char(ObjetoArma.modificador));

        if ObjetoArma.id=idArcabuz then SonidoArma:='C' else SonidoArma:='F';
        if (Victima is TjugadorS) and EsIdArmaduraMetalica(TjugadorS(Victima).Usando[uArmadura].id) then
          if SonidoArma='F' then sonidoArma:='f' else sonidoArma:='g';
        EnviarAlAreaMonstruo(Victima,'S'+char(Victima.coordx)+char(Victima.coordy)+SonidoArma);

        if danno>=Victima.hp then//Le matas
          JugadorMataVictima(JugadorAt,Victima,VictimaEsJugador,ObjetoArma.id)
        else
        begin
          dec(Victima.hp,danno);
          if VictimaEsJugador then
            with Victima do
            begin
              SendText(JugadorAt.codigo,'D'+b2aStr(danno)+b2aStr(hp)+b2aStr(codigo));
              SendText(codigo,#251+b2aStr(hp)+char(ObjetoArma.id)+b2aStr(JugadorAt.codigo))
            end
          else//Experiencia sólo si mata monstruos
          begin
            SendText(JugadorAt.codigo,'d'+b2aStr(danno)+b2aStr(Victima.hp));
            //controlar cantidad de exp. ganada
            if danno>=nivelMonstruo then
            begin
              if JugadorAt.nivel>nivelMonstruo then
                bono:=HPPromedio div (4+JugadorAt.nivel-nivelMonstruo)
              else
                bono:=HPPromedio shr 2;
              inc(bono,danno);
            end
            else
              bono:=danno;
            NotificarModificacionExperiencia(JugadorAt,bono);
          end;
        end;
      end//fin de control de acertar/fallar
    end;//with
  end;
//..............................................................................
  function realizarAtaqueMelee(var ObjetoArma:TArtefacto):byte;
  var contenido,codigoMon:word;
    lanzada,danno,defensa_en_Combate,Bono:integer;
    Victima:TmonstruoS;
    VictimaEsJugador,AtaquePorEspalda:boolean;
    nuevaDireccion:TdireccionMonstruo;
    SonidoArma:char;
    TipoDelDannoDelArma:TTipoArma;
    procedure realizarAtaqueDeAriete;
    var codigoDeSensor,nivelResistencia:byte;
    begin
      with JugadorAt do
      begin
        codigoDeSensor:=mapaSensor[(coordx+MC_avanceX[dir]) and $FF,(coordy+MC_avanceY[dir]) and $FF];
        if codigoDeSensor>=N_sensores then exit;
        with sensor[codigoDeSensor] do
          begin
            SendText(codigo,'S'+char(JugadorAt.coordx)+char(JugadorAt.coordy)+'C');//sonido de golpe
            nivelResistencia:=41;
            if (flagsSensor and fs_parteDelCastillo)<>0 then
            begin
              if (castillo.banderasGuardian and bnArmadura)<>0 then inc(nivelResistencia,8);
              if (castillo.banderasGuardian and bnFuerzaGigante)<>0 then inc(nivelResistencia,8);
              if (castillo.banderasGuardian and bnVendado)<>0 then inc(nivelResistencia,16);
            end;
            if random(nivelResistencia-(dannobase shr 2))=0 then
            begin
            //si logro abrir entonces fijar los flags de este sensor.
              FijarFlagsCalabozo:=FijarFlagsCalabozo or dato1 or(dato2 shl 8)or(dato3 shl 16)or(dato4 shl 24);
              //avanzar!! //anulado por que aún no se despeja la zona
              //AccionAutomatica:=aaNinguna;
              //FDestinoX:=(coordx+MC_avanceX[dir]) and $FF;
              //FDestinoY:=(coordy+MC_avanceY[dir]) and $FF;
            end;
          end;
      end;
    end;
  begin
    //Detectar el lugar atacado (el monstruo o jugador)
    result:=i_OK;
    with JugadorAt do
      codigoMon:=getMonRecXY(coordx+MC_avanceX[dir],coordy+MC_avanceY[dir]);
    contenido:=codigoMon and fl_con;
    if (contenido>ccMon) then//No hay algo atacable al frente!!
      with JugadorAt do
      begin
        //Ver si estamos atacando a un castillo
        if (codigoMon=ccVacRangoMov) or (codigoMon=ccRecMov) then
          if Usando[uArmadura].id=orAriete then
          begin
            realizarAtaqueDeAriete;
            exit;
          end;
        //Girar a un enemigo cercano
        nuevaDireccion:=DireccionEnemigoJugador(jugadorAt,dir);
        if nuevaDireccion<>dir then
        begin
          NroTurnosGastados:=2;//Si solamente gira.
          dir:=nuevaDireccion;
          SendText(codigo,char((dir and mskDirecciones)+144));
          //Comando de dirección 128(cmdDireccion)+direccion monstruo
          EnviarAlAreaJugador_J(codigo,char((dir and mskDirecciones)+128)+B2aStr(codigo));
          result:=i_error;//girando
        end
        else
          AccionAutomatica:=aaNinguna;
        exit;
      end;
    //Para generalizar:
    VictimaEsJugador:=contenido=ccJgdr;
    codigoMon:=codigoMon and fl_cod;
    if VictimaEsJugador then
      Victima:=Jugador[codigoMon]
    else
      Victima:=Monstruo[codigoMon];
    //Realizar el ataque:
    if Victima.hp<>0 then
    begin
      result:=i_Fallaste;
      if VictimaEsJugador then
      begin
        if not PuedeAtacarAOtrosAvatares(JugadorAt,TJugadorS(Victima),result,true) then exit;
        ActivarEstadoAgresivoEInformar(JugadorAt);
        defensa_en_Combate:=TJugadorS(Victima).PorcentajeDeDefensaTotal
      end
      else
      begin
        if Victima.duenno=(ccClan or JugadorAt.clan) then
        begin
          SendText(JugadorAt.codigo,'i'+char(i_NoPuedesAtacarMiembrosDeTuClan));
          result:=i_NoPuedesAtacarMiembrosDeTuClan;exit;
        end;
        CambiarObjetivoAtaque(Victima,JugadorAt);
        defensa_en_Combate:=InfMon[Victima.TipoMonstruo].defensa;
        //conjuro Armadura:
        if LongBool(Victima.Banderas and BnArmadura) then
          inc(defensa_en_Combate,BONO_CONJURO_ARMADURA)
      end;
      with InfObj[ObjetoArma.id],InfMon[Victima.TipoMonstruo] do //Arma usada,MonstruoAtacado
      begin
        with jugadorAt.usando[uAmuleto] do
          if id=orAmuletoGuerrero then //amuleto guerrero
            dec(defensa_en_Combate,(modificador and MskEstadoObjetoNormal) shr 2);
        if JugadorAt.EspecialidadArma=ObjetoArma.id then//Especialidad
          dec(defensa_en_Combate,(JugadorAt.NivelEspecializacion shr 3)+4);
        AtaquePorEspalda:=bytebool(MC_direccionApunnalada[Victima.dir] and (1 shl JugadorAt.dir));
        if AtaquePorEspalda then
          dec(defensa_en_Combate,PENA_ATAQUE_POR_ESPALDA);
        lanzada:=random(100);
        if (lanzada>=MINIMO_PORCENTAJE_DE_ATAQUE) and
          (((lanzada+Ataque_Combate+CalcularModificadorAtaDef(ObjetoArma))>=defensa_en_Combate) or (lanzada>=NIVEL_ATAQUE_SIEMPRE_EXITOSO)) then
        begin
          result:=i_OK;
          //sonido de golpe
          TipoDelDannoDelArma:=TipoArma;
          if TipoDelDannoDelArma=taContundente then sonidoArma:='C' else sonidoArma:='E';
          if (Victima is TjugadorS) and EsIdArmaduraMetalica(TjugadorS(Victima).Usando[uArmadura].id) then
            if SonidoArma='E' then sonidoArma:='e' else sonidoArma:='g';
          EnviarAlAreaMonstruo(JugadorAt,'S'+char(JugadorAt.coordx)+char(JugadorAt.coordy)+sonidoArma);
          with JugadorAt do
          begin
            if (ObjetoArma.id shr 3)=1 then
            begin
              Danno:=32;//100%
              bono:=0
            end
            else
            begin
              Danno:=dannoBase;//definido por el nivel de FRZ
              //adicional por especialidad
              if EspecialidadArma=ObjetoArma.id then
                inc(danno,(NivelEspecializacion shr 3)+1);
              //Bono de armas hechizadas:
              Bono:=CalcularBono(ObjetoArma,TipoDelDannoDelArma);
            end;
            inc(danno,nivel shr 1);//bono por nivel
            if longbool(banderas and BnZoomorfismo) then
              if (ObjetoArma.id<4) then//solo "garras"
              begin
                inc(danno,nivel shl 1);
                inc(bono,3);
              end;
            //Daño por arma
            if tamanno<=2 then//medianos, pequeños y diminutos
              danno:=danno*(danno1b+Bono)+random(danno*danno1P)
            else
              danno:=danno*(danno2b+Bono)+random(danno*danno2P);
            danno:=smallint(danno shr 5);
            //Apuñalar
            if AtaquePorEspalda and longBool(Pericias and hbApunnalar)
             and (TipoArma=taPunzante) and (PesoArma=paLigera) then
            begin
              inc(danno,nivel);
              // Para bribones bono por destreza
              if (CodCategoria=ctBribon) then inc(danno, DES);
            end;
          end;
          //Modificadores de daño:
          CalcularModificadorFinal(Victima,TipoDelDannoDelArma,Danno,VictimaEsJugador);
          //Control de arma
          if controlArmaDannada(ObjetoArma,DURABILIDAD_ARMAS_MELEE) then
            SendText(JugadorAt.codigo,char(234+idPosArma)+char(ObjetoArma.modificador));

          //muerte y daño.
          if danno>=Victima.hp then//Le matas
            JugadorMataVictima(JugadorAt,Victima,VictimaEsJugador,ObjetoArma.id)
          else
          begin
            dec(Victima.hp,danno);
            if VictimaEsJugador then
              with Victima do
              begin
                SendText(JugadorAt.codigo,'D'+b2aStr(danno)+b2aStr(hp)+b2aStr(codigo));
                SendText(codigo,#251+b2aStr(hp)+char(ObjetoArma.id)+b2aStr(JugadorAt.codigo))
              end
            else//Experiencia sólo si mata monstruos
            begin
              SendText(JugadorAt.codigo,'d'+b2aStr(danno)+b2aStr(Victima.hp));
              //controlar cantidad de exp. ganada
              if JugadorAt.nivel>nivelMonstruo then
                bono:=HPPromedio div (4+JugadorAt.nivel-nivelMonstruo)
              else
                bono:=HPPromedio shr 2;
              inc(bono,danno);
              NotificarModificacionExperiencia(JugadorAt,bono);
            end;
          end;
        end;
      end;
      if result=i_Fallaste then
      begin
        result:=i_Ok;
        EnviarAlAreaMonstruo(JugadorAt,'S'+char(JugadorAt.coordx)+char(JugadorAt.coordy)+'m');//golpe fallado
      end;
    end;//Realizar Ataque Melee
  end;
begin
  with JugadorAt do
  if (hp<>0) and ((banderas and BnParalisis)=0) then
  if PuedeRecibirComando(12) then
  begin
    fDestinoX:=CoordX;//no moverse autom.
    fDestinoY:=CoordY;
    if AtaqueDefensivo then
    begin
      Banderas:=Banderas or BnModoDefensivo;
      Ataque_Combate:=(NivelAtaque shr 1);//Al 50%
      inicializarTimer(tdCombate,6);
    end
    else
      Ataque_Combate:=NivelAtaque;
    if Longbool(Banderas and BnEfectoBardo) then
      inc(Ataque_Combate,BONO_EFECTO_BARDO);
    cdError:=i_SinArma;
    for idPosArma:=uArmaIzq downto uArmaDer do
      if InfObj[Usando[idPosArma].id].AlcanceArma=aaRango then
      begin
        //para evitar enviar mensaje de error varias veces
        if JugadorAt.ObjetivoDeAtaqueAutomatico=ccVac then continue;
        //definir objetivo del ataque
        cdErrorAlApuntar:=ApuntarMonstruoPorCodigoCasilla(JugadorAt);
        if JugadorAt.apuntado=nil then JugadorAt.ObjetivoDeAtaqueAutomatico:=ccVac;//para evitar enviar mensaje de error varias veces
        if cdErrorAlApuntar<>i_Ok then
          SendText(codigo,'i'+char(cdErrorAlApuntar))
        else
          if MunicionCorrecta(Usando[idPosArma],Usando[uMunicion]) then
            cdError:=realizarAtaqueRango(Usando[idPosArma],Usando[uMunicion])
          else
            cdError:=i_MunicionIncorrecta;
      end
      else
      begin
        if (Usando[idPosArma].id<4) then//Para definir correctamente el arma
          if (idPosArma=uArmaIzq) and (InfObj[Usando[uArmaDer].id].PesoArma=paPesada) then
            Usando[uArmaIzq].id:=3//No es un arma.
          else
            Usando[idPosArma].id:=idPosArma;//Puño derecho, izquierdo
        if InfObj[Usando[idPosArma].id].AlcanceArma=aaMelee then
          cdError:=realizarAtaqueMelee(Usando[idPosArma]);
      end;
    if not ByteBool(cdError) then//si todo está ok:
    begin
      AnimarAtaque;//control de animacion, asignar código de animacion adecuado, informar a jugadores
      SendText(codigo,char((Accion and mskAcciones)+176));
      //Comando de ataque 160(cmdAtaque)+accion monstruo
      EnviarAlAreaJugador_J(codigo,char((Accion and mskAcciones)+160)+B2aStr(codigo));
      accion:=aaParado;//Fin de animación, los clientes están informados.
      DesactivarInvisibilidadTemporalmente(jugadorAt);
    end
    else
    //Si no ataco y no estaba buscando un objetivo de ataque, anular accion automatica
      if cdError<>i_error then AccionAutomatica:=aaNinguna;
    banderas:=(banderas or BnSiguiendo) xor BnSiguiendo;
  end;
end;

procedure TTableroControlado.MoverAutomaticamente(Rjugador:TjugadorS);
//  Ver procedure FijarMovimiento en la unidad Mundo, que informa
//cuando un personaje gira.
//El personaje SÓLO se debe mover con este comando.
//Para indicar una posicion destino, cambiar fdestinoX,fdestinoY.
var
    dirDestino,tempDir:TdireccionMonstruo;
    tempX,tempY:byte;
  procedure InformarPosicionesAlJugador;
  var i,limIzq,LimDer,limInf,LimSup,conta:integer;
      casilla:word;
      s:string;
  //  Es posible que los monstruos ubicados en las esquinas se refresquen 2 veces,
  //cuando la dirección es diagonal.
  begin      //Informar de monstruos parados en la periferia:
    s:='r0';
    conta:=0;
    with RJugador do
    begin
      if (dir=dsNorte) or (dir=dsNorEste) or (dir=dsNorOeste) then
      begin
        LimIzq:=coordx-MaxVisionX;
        if LimIzq<0 then LimIzq:=0;
        LimDer:=coordx+MaxVisionX;
        if LimDer>255 then LimDer:=255;
        LimSup:=coordy-MaxVisionY;
        if (LimSup>=0) then
          for i:=LimIzq to LimDer do
          begin
            casilla:=mapaPos[i,LimSup].monRec;
            if casilla and fl_con=ccMon then
              with Monstruo[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end
            else if casilla and fl_con=ccJgdr then
              with Jugador[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end;
          end;
      end;
      if (dir=dsSud) or (dir=dsSudEste) or (dir=dsSudOeste) then
      begin
        LimIzq:=coordx-MaxVisionX;
        if LimIzq<0 then LimIzq:=0;
        LimDer:=coordx+MaxVisionX;
        if LimDer>255 then LimDer:=255;
        LimInf:=coordy+MaxVisionY;
        if (LimInf<=255) then
          for i:=LimIzq to LimDer do
          begin
            casilla:=mapaPos[i,LimInf].monRec;
            if casilla and fl_con=ccMon then
              with Monstruo[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end
            else if casilla and fl_con=ccJgdr then
              with Jugador[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end;
          end;
      end;
      if (dir=dsOeste) or (dir=dsSudOeste) or (dir=dsNorOeste) then
      begin
        LimSup:=coordy-MaxVisionY;
        if LimSup<0 then LimSup:=0;
        LimInf:=coordy+MaxVisionY;
        if LimInf>255 then LimInf:=255;
        LimIzq:=coordX-MaxVisionX;
        if (LimIzq>=0) then
          for i:=LimSup to LimInf do
          begin
            casilla:=mapaPos[LimIzq,i].monRec;
            if casilla and fl_con=ccMon then
              with Monstruo[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end
            else if casilla and fl_con=ccJgdr then
              with Jugador[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end;
          end;
      end;
      if (dir=dsEste) or (dir=dsNorEste) or (dir=dsSudEste) then
      begin
        LimSup:=coordy-MaxVisionY;
        if LimSup<0 then LimSup:=0;
        LimInf:=coordy+MaxVisionY;
        if LimInf>255 then LimInf:=255;
        LimDer:=coordX+MaxVisionX;
        if (LimDer<=255) then
          for i:=LimSup to LimInf do
          begin
            casilla:=mapaPos[LimDer,i].monRec;
            if casilla and fl_con=ccMon then
              with Monstruo[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end
            else if casilla and fl_con=ccJgdr then
              with Jugador[casilla and fl_cod] do
              begin
                s:=s+b2aStr(casilla)+char(coordX)+char(coordy)+char(dir or (accion shl 4));
                inc(conta);
              end;
          end;
      end;
      case conta of
        0:s:='';
        1:begin
          s:=copy(s,2,6);
          s[1]:='P';
        end;
        2..maxint:begin
          s[2]:=char(conta);
        end;
      end;
      //Control de ocultados
      if longbool(banderas and bnOcultarse) then
        if not (Usando[uAmuleto].id=ihAmuletoDeCamuflaje) then
          if random(20)>=DES then
          begin
            banderas:=banderas xor bnOcultarse;
            if longbool(banderas and BnInvisible) then TerminarTimer(tdInvisible);
          end;
      if s<>'' then
        SendText(codigo,s);
    end;
  end;
  procedure ControlDeObjetosDelPiso;
  var codigo_de_Bolsa:word;
    procedure QuemarseEnFogata;
    var danno:integer;
    begin
      danno:=random(4)+1;
      CalcularModificadorFinal(RJugador,taFuego,danno,true);
      with Rjugador do
        if hp>danno then
        begin
          dec(hp,danno);
          SendText(codigo,#255+B2aStr(hp));
        end
        else//Muerte del jugador
          MuerteJugador(Rjugador,nil);
    end;
    procedure CaerEnLaTrampa;
    var tiempoParalisis:integer;
    begin
      with Rjugador do
      if bolsa[codigo_de_Bolsa].Item[1].modificador<>clan then
      begin
        //realizar paralisis
        banderas:=banderas or BnParalisis;
        begin
          EnviarAlMapa_J(RJugador,'A'+b2aStr(codigo)+char(banderas));
          SendText(codigo,'s(');
        end;
        tiempoParalisis:=25-nivel;
        if tiempoParalisis<5 then tiempoParalisis:=5;
        if tiempoParalisis>12 then tiempoParalisis:=12;
        inicializarTimer(tdParalisis,tiempoParalisis);
        //eliminar trampa
        EliminarBolsaDelMapaYComunicarlo(coordx,coordy);
      end;
    end;
  begin
    with RJugador do
      codigo_de_Bolsa:=MapaPos[coordx,coordy].terBol and mskBolsa;
    if codigo_de_Bolsa<=maxBolsas then
      with bolsa[codigo_de_Bolsa] do
        if (tipo>=tbFogata) then
          QuemarseEnFogata
        else
          if tipo=tbTrampaMagica then
            CaerEnLaTrampa;
  end;
  function EsRecomendableBuscarCaminoParaSeguirMoviendose:boolean;
  var distanciaHastaElDestino,temp:integer;
  begin
    with Rjugador do
    begin
      temp:=abs(coordx-fdestinox);
      distanciaHastaElDestino:=abs(coordy-fdestinoy);
      if temp>distanciaHastaElDestino then distanciaHastaElDestino:=temp;
      result:=(((mapaPos[fdestinox,fdestinoy].monRec=ccVac)or(mapaPos[fdestinox,fdestinoy].monRec<ccRec)) or
                (distanciaHastaElDestino>=4)) and
              (distanciaHastaElDestino>1);
    end;
  end;
begin
with Rjugador do
begin
  //Bolsas
  if hp<>0 then
    ControlDeObjetosDelPiso;
  //Movimiento del jugador
  if LongBool(banderas and bnParalisis) then
  begin
    fdestinoX:=coordX;
    fdestinoY:=coordY;
    AccionAutomatica:=aaNinguna;
    banderas:=banderas or bnSiguiendo xor bnSiguiendo;
  end;
  //Efecto de seguir al apuntado
  if Longbool(banderas and bnSiguiendo) then
  begin
    if apuntado<>nil then
      if (apuntado.codMapa=codMapa) and ((accion=aacaminando) or (accion=aaparado)) then
      begin
        fdestinoX:=apuntado.coordX;
        fdestinoY:=apuntado.coordY;
      end
      else
        banderas:=banderas xor bnSiguiendo
    else
      banderas:=banderas xor bnSiguiendo;
  end;
  if (AccionAutomatica>=aaInicioDeAtaques) then
    EjecutarComandoIniciarAtaque(Rjugador,ObjetivoDeAtaqueAutomatico,AccionAutomatica,true);
  //Mover a coordenadas fdestino
  if (coordX<>fdestinoX) or (coordY<>fdestinoY) then
  begin
    //Elementos que son inicializados al moverse el avatar
    FlagsComunicacion:=(FlagsComunicacion or flRevisandoBolsa) xor flRevisandoBolsa;
    //Transacciones son anuladas.
    TipoTransaccion:=ttNinguna;
    //Movimiento y dirección
    tempDir:=dir;
    tempx:=coordX;
    tempy:=coordY;
    dirDestino:=calcularDirExacta(fdestinox-coordx,fdestinoy-coordy);
    //Determinar siguiente posicion
    if self.Mover(Rjugador,dirDestino,true) then
      Control_Movimiento:=0//No usar flags de movimiento si se puede mover adelante
    else//buscar camino si la casilla adelante esta bloqueada
      if EsRecomendableBuscarCaminoParaSeguirMoviendose() then
      begin
        if (Control_Movimiento and $2)=0 then
          DeterminarFlagDeDireccionParaMovimiento(RJugador,dirDestino);//Fijar flag para usar bit de direccion y flag de direccion
        if not self.Mover(Rjugador,self.BuscarDireccionLibre(RJugador,dirDestino),true) then
        begin
          RJugador.Control_Movimiento:=RJugador.Control_Movimiento xor $1;//ir por la otra direccion
          self.Mover(Rjugador,dirDestino,false);
        end;
      end;
    if (tempx<>coordx) or (tempy<>coordy) then
    begin
      InformarPosicionesAlJugador;
      SendText(codigo,'p'+char(coordX)+char(coordy)+char(dir or (accion shl 4)));
      EnviarAlAreaJugador_J(codigo,'P'+b2aStr(codigo)+char(coordX)+char(coordy)+char(dir or (accion shl 4)));
      //Por moverse
      DatosUsuario[codigo].TimerDesconeccionPorOcio:=MAX_TIEMPO_OCIO;
      if (Jugador[codigo].FlagsComunicacion and flSaliendoDelServidor)<>0 then
      begin
        Jugador[codigo].FlagsComunicacion:=Jugador[codigo].FlagsComunicacion xor flSaliendoDelServidor;
        SendText(codigo,'I'+#9);
      end;
    end
    else
    begin
      fDestinoX:=CoordX;//no moverse autom.
      fDestinoY:=CoordY;
      if (tempdir<>Dir) then
      begin
        //Comando de dirección exclusivo jugador 144(cmdDireccion)+direccion sprite
        SendText(codigo,char((Dir and mskDirecciones)+144));
        //Comando de dirección 128(cmdDireccion)+direccion sprite
        EnviarAlMapa_J(RJugador,char((Dir and mskDirecciones)+128)+b2aStr(codigo));
      end;
    end;
  end
  else
 //Viajar a otro mapa por los bordes
    if (coordx=0) then
    begin
      if dir=dsOeste then
        TeletransportarJugador(Rjugador,MapaOeste,MaxMapaAreaExt,coordy)
    end
    else if (coordx=MaxMapaAreaExt) then
    begin
      if dir=dsEste then
        TeletransportarJugador(Rjugador,MapaEste,0,coordy)
    end
    else if (coordy=0) then
    begin
      if dir=dsNorte then
        TeletransportarJugador(Rjugador,MapaNorte,coordx,MaxMapaAreaExt)
    end
    else if (coordy=MaxMapaAreaExt) then
      if dir=dsSud then
        TeletransportarJugador(Rjugador,MapaSur,coordx,0);
end;
end;

function TTableroControlado.ApuntarmonstruoXY(x,y:integer):TmonstruoS;
var info:word;
    px,py,ipos:integer;
  procedure verificar(x,y:integer);
  begin
    info:=getMonRecXY(x,y);
    case info and fl_con of
      ccJgdr:result:=Jugador[info and fl_cod];
      ccMon:result:=monstruo[info and fl_cod];
      else
        result:=nil;
    end;
  end;
begin
  iPos:=-1;
  px:=x;
  py:=y;
  repeat
    if iPos>=0 then
    begin
      px:=x+MC_avanceX[iPos];
      py:=y+MC_avanceY[iPos];
    end;
    verificar(px,py);
    inc(iPos);
  until (result<>nil) or (iPos>=8)
end;

procedure TTableroControlado.ControlBolsasMapa(ControlarTodo:longbool);
  function BolsaSinContenidoImportante(codBolsa:integer):boolean;
  const Umbral=100;
  var i,costo:integer;
  begin
    costo:=0;
    with Bolsa[codBolsa] do
      for i:=0 to MAX_ITEMS_BOLSA do
        if Item[i].id>=4 then
        begin
          inc(costo,PrecioArtefacto(Item[i]));
          if costo>Umbral then
          begin
            result:=false;exit;
          end;
        end;
    result:=true;
  end;
var i:integer;
begin
  if (controlParaApagarFogatas>=0) then//Apagar fogatas
  begin
    i:=0;
    while i<16 do//Apagar 16 fogatas cada turno.
    begin
      with Bolsa[controlParaApagarFogatas] do
        if tipo>=tbFogata then
          if (mapapos[posx,posy].terbol and ft_cubierto)=0 then
          begin
            if tipo=tbFogata then
              tipo:=tbCenizas
            else
              tipo:=tbCadaverQuemado;
            EnviarAlMapa(fcodMapa,#197+char(posx)+char(posy));//Apagar fogata.
            inc(i);
          end;
      dec(controlParaApagarFogatas);
      if controlParaApagarFogatas<0 then break;//salir del ciclo
    end;
  end;
  {TODO: generalizar ambos}
  if (controlParaEliminarCadaveres>=0) then//eliminar cadáveres
  begin
    i:=0;
    while i<16 do //eliminar 16 bolsas en cada turno
    begin
      with Bolsa[controlParaEliminarCadaveres] do
        if ((tipo>=tbCadaver) and (tipo<=tbCenizas) and (tipo<>tbCadaverAvatar)) or (BolsaSinContenidoImportante(controlParaEliminarCadaveres)) then
        begin
          tipo:=tbNinguna;
          mapaPos[posx,posy].terBol:=mapaPos[posx,posy].terBol or mskBolsa;
          EnviarAlMapa(fcodMapa,#192{Eliminar bolso}+char(posx)+char(posy));
          inc(i);
        end;
      dec(controlParaEliminarCadaveres);
      if controlParaEliminarCadaveres<0 then break;//salir del ciclo
    end;
  end;
end;

procedure TTableroControlado.vidaCriatura(monstr:TmonstruoS);
//Realiza el control de vida de criatura.
//Necesita una referencia a un TmonstruoS (monstr) que cumpla los requisitos:
// 1. el monstruo debe estar activo
// 2. el monstruo debe estar vivo (hp<>0)
var posAFM_x,posAFM_y:smallint;//Posición al frente del monstruo
    dirM:TdireccionMonstruo;
    victima:TmonstruoS;
    tempX,tempY,tempDir:byte;
    alinAmiga:byte;//Alineacion Amiga
    ContinuarElTickDeVida:boolean;
  procedure BuscarCaminoParaAvanzar(escapar,IntentarAvanzarAdelante:boolean);
  { En MonstruoObjetivo atacado va el código de la víctima o el agresor si el
  monstruo está escapando. Se intenta avanzar en la dirección actual del
  monstruo. Adicionalmente se utiliza la variable "control_movimiento" definida
  en cada objeto TmonstruoS para lo que pueda ser necesario.
  }
  var conta:integer;
      distanciaActual:integer;
      MonstruoObjetivo:TmonstruoS;
  begin
    with monstr do
    begin
      if IntentarAvanzarAdelante then
        if lugarVacioAlFrente(monstr) then
        begin
          case InfMon[TipoMonstruo].movimiento of
            0:if ((conta_Universal+codigo) mod 3)=2 then exit;//66.6%
            1:if ((conta_Universal+codigo) and $3)=1 then exit;//75%
            2:if ((conta_Universal+codigo) and $7)=0 then exit;//87.5%
          end;
          Mover(monstr,dir,false);
          exit;
        end;
      conta:=0;
      MonstruoObjetivo:=GetMonstruoCodigoCasillaS(objetivoAtacado);
      if MonstruoObjetivo<>nil then
      begin
        distanciaActual:=Maximo2(abs(MonstruoObjetivo.coordx-coordx),abs(MonstruoObjetivo.coordy-coordy));
        if (distanciaActual<=1) and (not escapar) then
        begin
          dir:=calcularDirExacta(MonstruoObjetivo.coordx-coordx,MonstruoObjetivo.coordy-coordy);
          exit;
        end
      end;
      while (conta<=3) do
      begin
        if (Control_Movimiento) and $1=0 then
          P_anteriorDireccion(dir)
        else
          P_siguienteDireccion(dir);
        if conta=2 then//Antes de revisar la última
        begin
          dir:=MC_DarVueltaDireccion[dir];
          if lugarVacioAlFrente(monstr) then
          begin
            inc(Control_Movimiento);
            Mover(monstr,dir,true);
            exit;
          end;
          dir:=MC_DarVueltaDireccion[dir];
        end;
        if lugarVacioAlFrente(monstr) then
        begin
          if IntentarAvanzarAdelante then
            Mover(monstr,dir,true);
          exit;
        end;
        inc(conta);
      end;
    end;
  end;
  procedure RealizarAtaqueRangoParaMonstruo;
  var distancia:integer;
  begin//usa monstruo.objetivoAtacado
    if monstr.objetivoAtacado=ccVac then exit;
    victima:=GetMonstruoCodigoCasillaS(monstr.objetivoAtacado);
    if victima<>nil then
      with victima do
        if activo and (hp<>0) and ((banderas and bnInvisible=0) or longbool(monstr.banderas and bnVisionVerdadera)) then
        begin//vivo y visible
          distancia:=maximo2(abs(coordx-monstr.coordx),abs(coordy-monstr.coordy));
          if distancia<=MaxRangoArqueroEnNormaCuadrado then
          begin
            monstr.dir:=CalcularDirExacta(coordx-monstr.coordx,coordy-monstr.coordy);
            if (distancia>RangoArqueroEnNormaCuadrado) and (monstr.hp>hp) then
              BuscarCaminoParaAvanzar(false,true)
            else
              if (distancia<3) then
              begin
                if not ExisteObstaculo(coordx,coordy,monstr.coordx,monstr.coordy) then
                  if ataqueMonstruo(monstr,victima,aaRango,SeleccionarAtaqueMonstruo) then
                    exit;
                P_DarVueltaDireccion(monstr.dir);//escapar
                BuscarCaminoParaAvanzar(true,true)
              end
              else
                if not ExisteObstaculo(coordx,coordy,monstr.coordx,monstr.coordy) then
                  ataqueMonstruo(monstr,victima,aaRango,SeleccionarAtaqueMonstruo)
                else
                  BuscarCaminoParaAvanzar(false,true);
            exit;
          end;
          if (distancia<=MaxRangoSeguirEnNormaCuadrado) then exit;
        end;
    monstr.objetivoAtacado:=ccVac;
  end;
  function RealizarAtaqueMagiaParaMonstruo(PuedeMoverse:boolean;AtaqueElegido:byte):bytebool;
  //falso si está fuera de rango
  var distancia:integer;
  begin//usa monstruo.objetivoAtacado
    result:=false;
    if monstr.objetivoAtacado=ccVac then exit;
    victima:=GetMonstruoCodigoCasillaS(monstr.objetivoAtacado);
    if victima<>nil then
      with victima do
        if activo and (hp<>0) and ((banderas and bnInvisible=0) or longbool(monstr.banderas and bnVisionVerdadera)) then
        begin//vivo y visible
          distancia:=maximo2(abs(coordx-monstr.coordx),abs(coordy-monstr.coordy));
          if distancia<=MaxRangoArqueroEnNormaCuadrado then
          begin
            monstr.dir:=CalcularDirExacta(coordx-monstr.coordx,coordy-monstr.coordy);
            if PuedeMoverse then
            begin
              if (distancia>RangoArqueroEnNormaCuadrado) and (monstr.hp>hp shr 1) and (monstr.mana>=6) then
                BuscarCaminoParaAvanzar(false,true)
              else
                if (distancia<3) then
                begin
                  if not ExisteObstaculo(coordx,coordy,monstr.coordx,monstr.coordy) then
                    if (monstr.mana>=3) and ataqueMonstruo(monstr,victima,aaMagica,AtaqueElegido) then
                      exit;
                  P_DarVueltaDireccion(monstr.dir);//escapar
                  BuscarCaminoParaAvanzar(true,true)
                end
                else
                  if not ExisteObstaculo(coordx,coordy,monstr.coordx,monstr.coordy) then
                    result:=ataqueMonstruo(monstr,victima,aaMagica,AtaqueElegido)
                  else
                    BuscarCaminoParaAvanzar(false,true);
            end
            else
            begin
              if (distancia<=MaxAlcanceY) and (monstr.mana>=3) then
                if not ExisteObstaculo(coordx,coordy,monstr.coordx,monstr.coordy) then
                  result:=ataqueMonstruo(monstr,victima,aaMagica,AtaqueElegido);
            end;
            exit;
          end;
          if (distancia<=MaxRangoSeguirEnNormaCuadrado) then exit;
        end;
    monstr.objetivoAtacado:=ccVac;
  end;
  function ObtenerEnemigoAlFrente:TmonstruoS;
  var casilla,contenido:word;
      objetivo:Tmonstruos;
  begin
    result:=nil;
    if (word(posAFM_x)>MaxMapaAreaExt)or(word(posAFM_y)>MaxMapaAreaExt) then exit;
    casilla:=mapaPos[posAFM_x,posAFM_y].monRec;
    contenido:=casilla and fl_con;
    if contenido=ccMon then
    begin
      objetivo:=Monstruo[casilla and fl_cod];
      if (InfMon[objetivo.TipoMonstruo].alineacion<>alinAmiga) or (monstr.objetivoAtacado=casilla) then
      begin
        if (objetivo.hp<>0) and (casilla<>monstr.duenno) then result:=objetivo;
      end
      else//Si al frente está un compañero, avisar del enemigo.
        if objetivo.objetivoAtacado=ccVac then
          objetivo.objetivoAtacado:=monstr.objetivoAtacado;
    end
    else
      if casilla<=maxJugadores then
      begin
        objetivo:=jugador[casilla];//sólo para jugadores, contenido Casilla=código jugador
        if (((AlinAmiga<>Al_Neutral) or (objetivo.comportamiento<comNormal))
              or (monstr.objetivoAtacado=casilla)) and (objetivo.hp<>0) then
          result:=objetivo;
      end;
  end;

  function ObtenerEnemigoClanAlFrente:TmonstruoS;
  var casilla,contenido:word;
  begin
    result:=nil;
    if (word(posAFM_x)>MaxMapaAreaExt)or(word(posAFM_y)>MaxMapaAreaExt) then exit;
    casilla:=mapaPos[posAFM_x,posAFM_y].monRec;
    contenido:=casilla and fl_con;
    if contenido=ccMon then
    begin
      result:=Monstruo[casilla and fl_cod];
      if (monstr.objetivoAtacado<>casilla) or (result.hp=0) then
        result:=nil
      else
        //avisar del objetivo atacado a los amigos
        if (result.duenno=monstr.duenno) and (result.objetivoAtacado=ccVac) then
          result.objetivoAtacado:=monstr.objetivoAtacado;
    end
    else
      if casilla<MaxJugadores then
      begin
        result:=jugador[casilla];//sólo para jugadores, contenido Casilla=código jugador
        if (monstr.objetivoAtacado<>casilla) or (result.hp=0) then
          result:=nil;
      end;
  end;

  function SinAgresorPotencial:boolean;
  //usa pos_x y pos_y para ver si existe un enemigo en dicha casilla.
  var deltax,deltay:integer;
      casilla:word;
  begin
    casilla:=monstr.objetivoAtacado;
    result:=casilla=ccVac;
    if result then exit;
    if casilla<=MaxJugadores then
      victima:=jugador[casilla]
    else
      victima:=monstruo[casilla and fl_cod];
    with victima do
      if activo and (hp<>0) then
      begin
        deltax:=coordx-monstr.coordx;
        deltaY:=coordy-monstr.coordy;
        if (abs(deltax)<=MaxRangoArqueroEnNormaCuadrado) and (abs(deltay)<MaxRangoArqueroEnNormaCuadrado) and//en rango
         ((banderas and bnInvisible=0) or longbool(monstr.banderas and bnVisionVerdadera)) then//visible
          begin
            monstr.dir:=MC_DarVueltaDireccion[CalcularDirExacta(deltax,deltay)];
            BuscarCaminoParaAvanzar(true,true);
            exit;
          end;
      end;
    monstr.objetivoAtacado:=ccVac;
  end;
  function SinObjetivoDeAtaque:boolean;
  //Sólo para monstruos con ataque sólo melee
  //false si el monstruo está siguiendo a otro, true si no tiene un objetivo
  var deltax,deltay:integer;
      casilla:word;
  begin
    casilla:=monstr.objetivoAtacado;
    result:=casilla=ccVac;

    if result then exit;
    if casilla<=MaxJugadores then
      victima:=jugador[casilla]//directo para jugadores
    else
      victima:=monstruo[casilla and fl_cod];
    with victima do
      if activo and (hp<>0) then
      begin
        deltax:=coordx-monstr.coordx;
        deltaY:=coordy-monstr.coordy;
        if (abs(deltax)<=MaxRangoArqueroEnNormaCuadrado) and (abs(deltay)<=MaxRangoArqueroEnNormaCuadrado) then
        begin
          if (banderas and bnOcultarse)=0 then
            monstr.dir:=CalcularDireccion(deltax,deltay,bytebool(monstr.codigo and $1));
          if ((banderas and bnInvisible)=0) or longbool(monstr.banderas and bnVisionVerdadera) then//visible
          begin
            if ataqueMonstruo(monstr,victima,aaMagica,Ninguno) then exit;
            BuscarCaminoParaAvanzar(false,true);
            exit;
          end;
        end;
      end;
    monstr.objetivoAtacado:=ccVac
  end;

  function SinObjetivoParaSeguir:boolean;
  //Sólo para monstruos con ataque sólo melee
  //false si el monstruo está siguiendo a otro, true si no tiene un objetivo
  var deltax,deltay:integer;
      casilla:word;
  begin
    casilla:=monstr.objetivoASeguir;
    result:=casilla=ccVac;
    if result then exit;
    if casilla<=MaxJugadores then
      victima:=jugador[casilla]//directo para jugadores
    else
      victima:=monstruo[casilla and fl_cod];
    with victima do
    begin
      deltax:=coordx-monstr.coordx;
      deltay:=coordy-monstr.coordy;
      if activo and
       (abs(deltax)<=MaxRangoSeguirEnNormaCuadrado) and (abs(deltay)<=MaxRangoSeguirEnNormaCuadrado) then
        begin
          if abs(deltax)+abs(deltay)>3 then
          begin
            monstr.dir:=CalcularDireccion(deltax,deltay,bytebool(monstr.codigo and $1));
            BuscarCaminoParaAvanzar(false,true)
          end;
        end
      else
        monstr.objetivoASeguir:=ccVac
   end;
  end;

  function SinObjetivoDeAtaqueGuerreroMago:boolean;
  //false si el monstruo está siguiendo a otro, true si no tiene un objetivo
  var deltax,deltay:integer;
      casilla:word;
  begin
    casilla:=monstr.objetivoAtacado;
    result:=casilla=ccVac;

    if result then exit;
    if casilla<=MaxJugadores then
      victima:=jugador[casilla]//directo para jugadores
    else
      victima:=monstruo[casilla and fl_cod];
    with victima do
      if activo and (hp<>0) then
      begin
        deltax:=coordx-monstr.coordx;
        deltay:=coordy-monstr.coordy;
        if (abs(deltax)<=MaxRangoArqueroEnNormaCuadrado) and (abs(deltay)<=MaxRangoArqueroEnNormaCuadrado) and
          (((banderas and bnInvisible)=0) or longbool(monstr.banderas and bnVisionVerdadera)) then//visible
        begin
          monstr.dir:=CalcularDireccion(deltaX,deltaY,bytebool(monstr.codigo and $1));
          if (maximo2(abs(deltax),abs(deltay))<=RangoArqueroEnNormaCuadrado) and (monstr.mana>=6) and
            not ExisteObstaculo(coordx,coordy,monstr.coordx,monstr.coordy) then
            ataqueMonstruo(monstr,victima,aaMagica,2)
          else
            BuscarCaminoParaAvanzar(false,true);
          exit;
        end;
      end;
    monstr.objetivoAtacado:=ccVac;
  end;

  procedure RealizarConjuracionMonstruo(MonstruoConjurador:TmonstruoS;TipoMonstruoConjurado:byte;TiempoDeVida:byte);
  var ElConjurado,MonstruoObjetivo:TmonstruoS;
      i:integer;
  begin
    with MonstruoConjurador do
      if mana>=25 then
      begin
        MonstruoObjetivo:=GetMonstruoCodigoCasillaS(ObjetivoAtacado);
        if MonstruoObjetivo=nil then
          MonstruoObjetivo:=MonstruoConjurador;
        for i:=0 to 7 do
        begin//conjurar guardias:
          ElConjurado:=ConjurarMonstruo(TipoMonstruoConjurado,TiempoDeVida,
            MonstruoObjetivo.coordx+MC_avanceX[i],MonstruoObjetivo.coordy+MC_avanceY[i],
            objetivoAtacado,MonstruoConjurador);
          if ElConjurado<>nil then
          begin
            dec(mana,20);
            if ElConjurado.duenno=(ccClan or Castillo.clan) then
            begin
              ElConjurado.banderas:=castillo.banderasGuardian and $FFFF;
              if ElConjurado.banderas<>0 then
                EnviarAlMapa(fcodmapa,'a'+b2aStr(ElConjurado.codigo or ccmon)+
                  b2aStr(ElConjurado.banderas));
            end;
            break;
          end;
        end;
      end;
  end;

  procedure ElegirMonstruoYTiempoDeVida;
  var tipoDeMonstruo,TiempoDeVida:byte;
  begin
    with monstr do
      if (banderas and bnModoDefensivo)<>0 then
      begin
        if (monstr.banderas and bnDuracion)=0 then
          TiempoDeVida:=70
        else
          TiempoDeVida:=200;
        if (monstr.banderas and bnVendado)=0 then
          tipoDeMonstruo:=moGolem
        else
          tipoDeMonstruo:=moOgro;
        RealizarConjuracionMonstruo(monstr,tipoDeMonstruo,TiempoDeVida)
      end;
  end;

  procedure ControlDeObjetosDelPiso;
  var codigo_de_Bolsa:word;
    procedure CaerEnLaTrampa;
    var tiempoParalisis:integer;
    begin
      with monstr do
      if (duenno=ccSinDuenno) or ((duenno and ccClan)<>ccClan) or ((duenno and $FF)<>bolsa[codigo_de_bolsa].item[1].modificador) then
      begin//si el bicho no tiene dueño o no tiene clan o no corresponde con el clan de la trampa:
        //realizar paralisis
        banderas:=banderas or BnParalisis;
        begin
          EnviarAlMapa(codMapa,'A'+b2aStr(codigo or ccmon)+char(banderas));
        end;
        tiempoParalisis:=25-infmon[tipoMonstruo].nivelMonstruo;
        if tiempoParalisis<5 then tiempoParalisis:=5;
        if tiempoParalisis>12 then tiempoParalisis:=12;
        inicializarTimer(tdParalisis,tiempoParalisis);
        ContinuarElTickDeVida:=false;
        //eliminar trampa
        EliminarBolsaDelMapaYComunicarlo(coordx,coordy);
      end;
    end;

    procedure QuemarseEnFogata;
    var danno:integer;
      procedure MoverseAOtroLugar;
      var dirMonstruoActual:integer;
      begin
        for dirMonstruoActual:=0 to 7 do
          if lugarVacioVerificarFronterasXY(monstr,posAFM_x+MC_avanceX[dirMonstruoActual],
            posAFM_y+MC_avanceY[dirMonstruoActual]) then
          begin
            mover(monstr,dirMonstruoActual,true);
            monstr.objetivoAtacado:=ccVac;
            ContinuarElTickDeVida:=false;
            exit;
          end;
      end;
    begin
      danno:=random(4)+1;
      with monstr do
      begin
        CalcularModificadorFinal(monstr,taFuego,danno,false);
        if danno>1 then//Para que todos los monstruos de alta resistencia al fuego no mueran en una fogata.
          if hp>danno then
          begin
            dec(hp,danno);
            //Tratar de escapar a otro lugar:
            if (hp<16) then
              MoverseAOtroLugar;
          end
          else//Muerte
          begin
            MuerteMonstruo(monstr,nil);
            ContinuarElTickDeVida:=false;
          end;
      end;
    end;
  begin
    codigo_de_bolsa:=MapaPos[tempX,tempY].terBol and mskBolsa;
    if codigo_de_bolsa<=MaxBolsas then
      with bolsa[codigo_de_bolsa] do
        if (tipo>=tbFogata) then//Fogatas:
          QuemarseEnFogata
        else
          if tipo=tbTrampaMagica then
            CaerEnLaTrampa;
  end;
begin
  ContinuarElTickDeVida:=true;
  tempX:=monstr.coordx;
  tempY:=monstr.coordy;
  tempDir:=monstr.dir;
  //Control de efectos dependiente de la posición del monstruo:
  if monstr.comportamiento<>comComerciante then
    ControlDeObjetosDelPiso;
  if ((monstr.banderas and bnAturdir)<>0) and ((Conta_Universal+monstr.codigo) and $3=0) then
    ContinuarElTickDeVida:=false;
  if ContinuarElTickDeVida then
  begin
    alinAmiga:=InfMon[monstr.TipoMonstruo].alineacion;
    with monstr do//Calcular la posición al frente del monstruo
    begin
      posAFM_x:=coordx+MC_AvanceX[dir];
      posAFM_y:=coordy+MC_AvanceY[dir];
    end;
    case monstr.comportamiento of
      comHerbivoro:
        if SinAgresorPotencial then
        begin
          dirM:=DireccionEnemigo(monstr,0,dsIndefinido);
          if (dirM<>dsIndefinido) then //escapar!!
          begin
            monstr.dir:=MC_DarVueltaDireccion[dirM];
            mover(monstr,monstr.dir,false);
          end
          else
            if (Conta_Universal+monstr.codigo)and $F=0 then
            begin
              dirM:=monstr.dir;
              case random(4) of
                0:P_anteriorDireccion(dirM);
                1:P_siguienteDireccion(dirM);
              end;
              mover(monstr,dirM,false);
            end;
        end;
      comPacifico://pacífico no escapa, ataca si te acercas
      begin
        victima:=ObtenerEnemigoAlFrente();
        if victima<>nil then
          ataqueMonstruo(monstr,victima,aaMelee,SeleccionarAtaqueMonstruo)
        else
          if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
            BuscarCaminoParaAvanzar(false,false)
          else
            if SinObjetivoDeAtaque then
              if random(6)=0 then
              begin
                case random(3) of
                  0:P_anteriorDireccion(monstr.dir);
                  1:P_siguienteDireccion(monstr.dir);
                end;
                mover(monstr,monstr.dir,false);
              end;
      end;
      comTerritorial://ataca si te acercas.
      begin
        victima:=ObtenerEnemigoAlFrente();
        if victima<>nil then
          ataqueMonstruo(monstr,victima,aaMelee,SeleccionarAtaqueMonstruo)
        else
          if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
            BuscarCaminoParaAvanzar(false,false)
          else
            if SinObjetivoDeAtaque then
              if random(6)=0 then
              begin
                case random(3) of
                  0:P_anteriorDireccion(monstr.dir);
                  1:P_siguienteDireccion(monstr.dir);
                end;
                mover(monstr,monstr.dir,false);
                monstr.dir:=DireccionEnemigo(monstr,0,monstr.dir);
              end;
      end;
      comAgresivo://agresivo
      begin
        victima:=ObtenerEnemigoAlFrente();
        if victima<>nil then//atacar al enemigo
          ataqueMonstruo(monstr,victima,aaMelee,SeleccionarAtaqueMonstruo)
        else
          if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
            BuscarCaminoParaAvanzar(false,false)
          else//perseguir enemigo
            if SinObjetivoDeAtaque then
              if random(4)=0 then
                monstr.dir:=DireccionEnemigo(monstr,4,monstr.dir)
              else//Girar.
                case ((conta_Universal shr 2)+monstr.codigo) and $7 of
                  0:P_anteriorDireccion(monstr.dir);
                  4:P_siguienteDireccion(monstr.dir);
                end;
      end;
      comGuardia://estatua que ataca.
      begin
        victima:=ObtenerEnemigoAlFrente();
        if victima<>nil then//Atacar al enemigo
          ataqueMonstruo(monstr,victima,aaMelee,SeleccionarAtaqueMonstruo)
        else
          if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
            BuscarCaminoParaAvanzar(false,false)
          else
            if SinObjetivoDeAtaque then
              monstr.dir:=DireccionEnemigo(monstr,0,monstr.dir);
      end;
      comGuerreroMago:
      begin
        victima:=ObtenerEnemigoAlFrente();
        if victima<>nil then//atacar al enemigo
          ataqueMonstruo(monstr,victima,aaMelee,random(2))
        else
          if SinObjetivoDeAtaqueGuerreroMago then
          begin
            if random(4)=0 then
              monstr.dir:=DireccionEnemigo(monstr,3,monstr.dir)
            else//Girar.
              case ((conta_Universal shr 2)+monstr.codigo) and $7 of
                0:P_anteriorDireccion(monstr.dir);
                4:P_siguienteDireccion(monstr.dir);
              end;
            if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
              BuscarCaminoParaAvanzar(false,false)
            else
              if ((conta_Universal+monstr.codigo) and $F)=0 then mover(monstr,monstr.dir,false);
          end;
      end;
      comMonstruoConjurado:
      begin
        victima:=ObtenerEnemigoClanAlFrente();
        if victima<>nil then//Atacar al enemigo
          ataqueMonstruo(monstr,victima,aaMelee,SeleccionarAtaqueMonstruo)
        else
          if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
            BuscarCaminoParaAvanzar(false,false)
          else
            if SinObjetivoDeAtaque then
              if SinObjetivoParaSeguir then
                monstr.dir:=DireccionEnemigoClan(monstr,2,monstr.dir);
      end;
      comAtaqueRango:begin
        if (monstr.objetivoAtacado=ccVac) then
          if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
          begin//Buscar camino
            case ((conta_Universal shr 4)+monstr.codigo) and $1 of
              0:P_anteriorDireccion(monstr.dir);
              1:P_siguienteDireccion(monstr.dir);
            end;
            mover(monstr,monstr.dir,true);
          end
          else
            case random(16) of
              0:P_anteriorDireccion(monstr.dir);
              1:P_siguienteDireccion(monstr.dir);
              2..10:monstr.dir:=DireccionEnemigo(monstr,3,monstr.dir);//elegir monstruo para atacar
              15:mover(monstr,monstr.dir,false);
              else
                monstr.dir:=DireccionEnemigo(monstr,0,monstr.dir);
            end
        else
          RealizarAtaqueRangoParaMonstruo();
      end;
      comAtaqueHechizos:begin
        if (monstr.objetivoAtacado=ccVac) then
          if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
          begin
            //Buscar camino
            case ((conta_Universal shr 4)+monstr.codigo) and $1 of
              0:P_anteriorDireccion(monstr.dir);
              1:P_siguienteDireccion(monstr.dir);
            end;
            mover(monstr,monstr.dir,true);
          end
          else
            case random(16) of
              0:P_anteriorDireccion(monstr.dir);
              1:P_siguienteDireccion(monstr.dir);
              2..7:monstr.dir:=DireccionEnemigo(monstr,4,monstr.dir);//elegir monstruo para atacar
              15:mover(monstr,monstr.dir,false);
              else
                monstr.dir:=DireccionEnemigo(monstr,0,monstr.dir);
            end
        else
          RealizarAtaqueMagiaParaMonstruo(true,SeleccionarAtaqueMonstruo);
      end;
      comObjetoDummy:begin
      end;
      comDefensaEstatica:begin
        if (monstr.banderas and bnVendado)<>0 then
        begin
          inc(monstr.hp, InfMon[monstr.TipoMonstruo].Regeneracion shl 2);
          if (monstr.hp)>(InfMon[monstr.TipoMonstruo].HPPromedio) then
            monstr.hp:=(InfMon[monstr.TipoMonstruo].HPPromedio);
        end;
        if (monstr.objetivoAtacado=ccVac) then
        begin
          case (conta_Universal and $3) of
            0:if random(2)=0 then
                if random(2)=0 then
                  P_anteriorDireccion(monstr.dir)
                else
                  P_siguienteDireccion(monstr.dir);
            1:monstr.dir:=DireccionEnemigoClan(monstr,4,monstr.dir);//elegir monstruo para atacar
            else
              if (monstr.banderas and bnVisionVerdadera)<>0 then
                monstr.dir:=DireccionEnemigoClan(monstr,3,monstr.dir)
              else
                monstr.dir:=DireccionEnemigoClan(monstr,1,monstr.dir);
          end;
          if (monstr.banderas and bnMana)<>0 then
            if monstr.mana<250 then inc(monstr.mana,2);
        end
        else
        begin
          if (random(2)=0) or (monstr.mana<3) then
          begin
            victima:=ObtenerEnemigoClanAlFrente();
            if victima<>nil then//atacar al enemigo
              ataqueMonstruo(monstr,victima,aaMelee,0)
          end
          else
            victima:=nil;
          if victima=nil then
          begin
            //Intentar ataque a distancia
            if random(6)=0 then ElegirMonstruoYTiempoDeVida;
            if not RealizarAtaqueMagiaParaMonstruo(false,1+random(2)) then
            begin
              ElegirMonstruoYTiempoDeVida;
              monstr.objetivoAtacado:=ccVac;
            end;
          end;
        end;
      end;
      comComerciante:begin
        if monstr.TimerActivo(tdBasico) then
          monstr.ticktimer(tdBasico)
        else
          with monstr do
            if (conta_Universal+codigo) and $3=0 then
              case random(16) of
                0..1:P_anteriorDireccion(dir);
                2..3:P_siguienteDireccion(dir);
                7:if abs(coordx-coordx_ant)+abs(coordy-coordy_ant)>=MAXIMA_DISTANCIA_COMERCIO then
                    self.mover(monstr,CalcularDirExacta(coordx_ant-coordx,coordy_ant-coordy),true)
                  else
                    self.mover(monstr,dir,false);
                else
                  if not lugarVacioVerificarFronterasXY(monstr,posAFM_x,posAFM_y) then
                    P_DarVueltaDireccion(dir);
              end;
      end;
    end;//case
  end;
  //Envio de mensajes a los clientes:
  with monstr do
    if (tempx<>coordx) or (tempy<>coordy) then
      EnviarAlAreaMonstruo(monstr,'P'+b2aStr(codigo or ccMon)+char(coordX)+char(coordy)+char(dir or (accion shl 4)))
    else if (tempdir<>Dir) then
      //Comando de dirección 128(cmdDireccion)+direccion monstruo
      EnviarAlAreaMonstruo(monstr,char((Dir and mskDirecciones)+128)+b2aStr(codigo or ccMon));
end;

procedure TTableroControlado.MuerteJugador(RJugador:TjugadorS;Verdugo:Tmonstruos);
var casilla:word;
begin
//  assert(RJugador<>nil,'RJugador=nil en MuerteJugador');
  with RJugador do
  begin
    morir;
    casilla:=ccvac;
    if verdugo<>nil then
      if verdugo is TjugadorS then
        casilla:=verdugo.codigo
      else
        if verdugo is TmonstruoS then
          casilla:=verdugo.codigo or ccmon;
    SendText(codigo,'IM'+B2aStr(casilla));//notificar que murio
    EnviarAlMapa_J(RJugador,'_'+B2aStr(codigo));
    if ((BanderasMapa and bmEsMapaSeguro)=0) and (comportamiento<comAdminB) then
      SoltarObjetosMuerto(RJugador);
  end;
end;

procedure TTableroControlado.DisolverMonstruo(Rmonstruo:TmonstruoS);
begin
  assert(Rmonstruo<>nil,'Rmonstruo=nil en DisolverMonstruo');
  with Rmonstruo do
  begin
    //Disolver monstruo
    EnviarAlMapa(fcodMapa,'~'+B2aStr(codigo or ccMon));
    EliminarMarcaExistencia(Rmonstruo);
  end;
end;

procedure TTableroControlado.MuerteMonstruo(Rmonstruo:TmonstruoS;verdugo:TmonstruoS);
  procedure SoltarObjetosDelMonstruo;
  var Artefacto:Tartefacto;
      TipoCadaver:TTipoBolsa;
      CodigoCadaver:char;
  begin
    with Rmonstruo,Artefacto do
    begin
      if (BanderasMapa and bmEsMapaCombate)=0 then
      begin
        id:=InfMon[Tipomonstruo].tesoro;
        modificador:=InfMon[Tipomonstruo].ModificadorTesoro;
        if modificador=0 then
        begin
          modificador:=2;
          if NumeroElementos(Artefacto)>1 then
          begin
            modificador:=PrecioArtefacto(Artefacto);
            if modificador>0 then
              modificador:=(random(100) div modificador)+1
            else
              modificador:=1;
          end
          else//Indicar estado del objeto:
            modificador:=random(50)+14;
        end;
      end
      else
      begin
        if not (verdugo is TjugadorS) then exit;
        if TJugadorS(verdugo).nivel>MAX_NIVEL_NEWBIE then exit;
        inc(TJugadorS(verdugo).dinero,(MAX_NIVEL_NEWBIE-TJugadorS(verdugo).nivel)*5+15);
        SendText(TJugadorS(verdugo).codigo,#250+b4aStr(TJugadorS(verdugo).dinero));//informar nueva cantidad de dinero
        exit;
      end;
      //Informar del cadaver.
      case infmon[tipomonstruo].EstiloMuerte of
        emSangreVerde:begin
          CodigoCadaver:=#199;
          TipoCadaver:=tbCadaverVerde;
        end;
        emSangreNegra:begin
          CodigoCadaver:=#200;
          TipoCadaver:=tbCadaverQuemado;
        end;
        emEnergiaDisipada:begin
          CodigoCadaver:=#201;
          TipoCadaver:=tbCadaverEnergia;
        end;
      else
        begin
          CodigoCadaver:=#198;
          TipoCadaver:=tbCadaver;
        end;
      end;
      //Soltar objetos (No importa que no deje objetos, en ese caso es para mostrar un cadaver)
      SoltarObjetoXY(Artefacto,coordx,coordy,TipoCadaver,true);
      EnviarAlMapa(fcodMapa,CodigoCadaver+char(coordx)+char(coordy));
      //opcional:
      id:=InfMon[Tipomonstruo].tesoroAzar;
      case id of
        1://Ingredientes
        begin
          id:=random(random(9));//0..7
          modificador:=8-id+random(InfMon[Tipomonstruo].nivelMonstruo shr 2);
          inc(id,orIngredienteInicial);
        end;
        2://Gemas no talladas
        begin
          id:=random(random(9));//0..7
          modificador:=1+random(InfMon[Tipomonstruo].nivelMonstruo shr 2);
          inc(id,orGemaInicialSinTallar);
        end;
        3://Pergaminos magia
        if InfMon[Tipomonstruo].nivelMonstruo>10 then
        begin
          id:=InfConjuro[modificador].IconoPergamino;
          modificador:=random(30);
          if InfConjuro[modificador].CostoCnjr>random(16000) then
          case random(3) of
            0:modificador:=6;//Ataque psítico
            1:modificador:=9;//Curar heridas
            else modificador:=18;//Identificar Objeto
          end;
        end
        else
        begin
          modificador:=1+random(4);
          id:=orPergamino;
        end;
        4://Gemas talladas
        begin
          if InfMon[Tipomonstruo].nivelMonstruo>10 then
            id:=random(random(random(10)))//0..7
          else
            id:=random(random(4));//0..2
          modificador:=random(random(random(102)))+1;//1..100
          inc(id,orGemaInicial);
        end;
        5://Pociones
        begin
          id:=random(random(9));//0..7
          modificador:=1+random(InfMon[Tipomonstruo].nivelMonstruo shr 2);
          inc(id,orPocimaInicial);
        end;
        6://oro
        begin
          id:=5;
          modificador:=InfMon[Tipomonstruo].nivelMonstruo;
        end;
      end;
      if id>=4 then
        SoltarObjetoXY(Artefacto,coordx,coordy,TipoCadaver,true);
    end;
  end;
var
  i:integer;
  ClanDelVerdugo:byte;
  AlineacionDeLaVictima:byte;
  NivelDelAgresor:byte;
  mensaje:string;
begin
  assert(Rmonstruo<>nil,'Rmonstruo=nil en MuerteMonstruo');
  with Rmonstruo do
  begin
    //Todos los monstruos cercanos de su misma alineación te atacan.
    if objetivoAtacado<>ccVac then
      if comportamiento=comMonstruoConjurado then
        LlamarALasArmas(Rmonstruo)
      else
        //Los monstruos no piden ayuda en el mapa de combate
        if (verdugo is TjugadorS) and ((BanderasMapa and bmEsMapaCombate)=0) then
        begin
          AlineacionDeLaVictima:=infmon[tipomonstruo].alineacion;
          NivelDelAgresor:=TjugadorS(verdugo).nivel;
          for i:=IndiceInicioMonstruos to IndiceFinalMonstruos do
            with monstruo[i] do
              if activo then
                if infmon[tipomonstruo].alineacion=AlineacionDeLaVictima then
                  if objetivoAtacado=ccvac then
                    if (infmon[tipomonstruo].nivelMonstruo shr 1)<NivelDelAgresor then
                      if (abs(coordx-Rmonstruo.coordx)<=MaxRangoArqueroEnNormaCuadrado) and (abs(coordy-Rmonstruo.coordy)<=MaxRangoArqueroEnNormaCuadrado) then
                        objetivoAtacado:=Rmonstruo.objetivoAtacado;
        end;
    //Reclamar castillo por matar a un guardian
    if (infmon[tipomonstruo].ConsecuenciaMuerte=cmCastilloReclamado) and (verdugo<>nil) then
    begin
      if (verdugo is TjugadorS) then
        ClanDelVerdugo:=TjugadorS(verdugo).clan
      else
        if (verdugo.duenno and ccClan)=ccClan then
          ClanDelVerdugo:=verdugo.duenno and $FF
        else
          ClanDelVerdugo:=ninguno;
      if ClanDelVerdugo>maxClanesJugadores then ClanDelVerdugo:=ninguno;
      castillo.Clan:=ClanDelVerdugo;
      castillo.banderasGuardian:=0;
      EnviarAlMapa(fcodMapa,'IQ'+char(castillo.Clan));
      if (ClanDelVerdugo<>ninguno) then
      begin
        mensaje:='Nuestro clan conquistó el castillo de "'+nombreMapa+'"';
        EnviarAlClan_J(verdugo.codigo,'IG'+char(length(mensaje))+mensaje);
      end;
    end;
    //Muerte Std monstruo
    EnviarAlMapa(fcodMapa,'_'+B2aStr(codigo or ccMon));
    EliminarMarcaExistencia(RMonstruo);
    //No soltar objetos en terreno donde no se puede soltar objetos =P
    if (mapaPos[coordx,coordy].terBol and MskTerreno_SoltarBolsa)=0 then exit;
    //Soltar objetos si no es monstruo conjurado:
    if (Comportamiento<>comMonstruoConjurado) then
      SoltarObjetosDelMonstruo;
  end;
end;

procedure TTableroControlado.RecogerObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte);
var ObjetoTemporal,EstadoInicial:TArtefacto;
    codBolsa:word;
begin
  if IndArtefacto<=MAX_ARTEFACTOS then
  with RJugador do
  begin
    if (not activo) or longbool(banderas and BnParalisis) or ((hp=0) and (comportamiento<=comHeroe)) then exit;
    CodBolsa:=MapaPos[coordx,coordy].terbol and mskBolsa;
    if CodBolsa<=maxBolsas then
      with Bolsa[codBolsa] do
        if tipo<>tbNinguna then
          if Item[IndArtefacto].id>=4 then
          begin
            EstadoInicial:=Item[IndArtefacto];
            ExtraerCantidadObjeto(Item[IndArtefacto],ObjetoTemporal,cantidad);
            if not RealizarNotificarAgregarObjeto(RJugador,ObjetoTemporal) then
              SendText(codigo,'i'+char(i_TuInventarioEstaLleno));
            if ObjetoTemporal.id<>0 then//falto algo por colocar
              if Item[IndArtefacto].id=0 then//se movio todo a objeto temporal
                Item[IndArtefacto]:=ObjetoTemporal
              else//falto agregar algo, restituir al nivel original
                AgregarObjetoAObjeto(ObjetoTemporal,Item[IndArtefacto]);
            with Item[IndArtefacto] do
              if (id<>EstadoInicial.id) or (modificador<>EstadoInicial.modificador) then
                InformarNuevoEstadoDeBolsa(RJugador);
          end;
  end;
end;

procedure TTableroControlado.SoltarObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte);
var ObjetoTemporal,EstadoInicial:TArtefacto;
begin
  if IndArtefacto>MAX_ARTEFACTOS then exit;
  with RJugador do
  begin
    if (not activo) or longbool(banderas and BnParalisis) or ((hp=0) and (comportamiento<=comHeroe)) then exit;
    if Artefacto[IndArtefacto].id<4 then exit;
    EstadoInicial:=Artefacto[IndArtefacto];
    ExtraerCantidadObjeto(Artefacto[IndArtefacto],ObjetoTemporal,cantidad);
    if not SoltarObjetoXY(ObjetoTemporal,coordx,coordy,tbComun,false) then
      SendText(codigo,'i'+char(i_NoHayLugarParaSoltarElObjeto));
    if ObjetoTemporal.id<>0 then//falto algo por colocar
      if Artefacto[IndArtefacto].id=0 then//se movio todo a objeto temporal
        Artefacto[IndArtefacto]:=ObjetoTemporal
      else//falto agregar algo, restituir al nivel original
        AgregarObjetoAObjeto(ObjetoTemporal,Artefacto[IndArtefacto]);
    with Artefacto[IndArtefacto] do
      if (id<>EstadoInicial.id) or (modificador<>EstadoInicial.modificador) then
      begin
        SendText(codigo,char(IndArtefacto+8{del Inventario}+208{Refrescar Objetos})+char(id)+char(modificador));
        InformarNuevoEstadoDeBolsa(RJugador);
      end;
  end;
end;

function TTableroControlado.SoltarObjetoXY(var Artefacto:Tartefacto;x,y:byte;tipoBolsa:TTipoBolsa;ReemplazarObjetoMenosCostoso:boolean):boolean;
//Ojo No controla que el artefacto sea >=4.
var    i:integer;
       codBolsa:word;
       TagTipoBolsa:char;
  procedure RealizarReemplazarObjetoMenosCostoso;
  var i:integer;
      menorPrecio,precio:integer;
      indiceDeMenorPrecio:byte;
  begin
    menorPrecio:=PrecioArtefacto(Artefacto);
    indiceDeMenorPrecio:=ninguno;
    with Bolsa[codBolsa] do
    begin
      for i:=0 to MAX_ITEMS_BOLSA do
      begin
        precio:=PrecioArtefacto(Item[i]);
        if precio<=menorPrecio then
        begin
          menorPrecio:=precio;
          indiceDeMenorPrecio:=i;
        end;
      end;
      if indiceDeMenorPrecio<=MAX_ITEMS_BOLSA then
        Item[indiceDeMenorPrecio]:=Artefacto;
    end;
    Artefacto:=ObNuloMDV;
  end;
begin
  result:=true;
  codBolsa:=MapaPos[x,y].terbol and mskBolsa;
  if codBolsa<=MaxBolsas then
    with Bolsa[codBolsa] do
      if (posx=x) and (posy=y) then//para evitar bug de soltar un objeto y que "desaparezca"
      begin
        //si existiera bug donde continua una marca de una bolsa que fue removida
        if tipo=tbNinguna then
        begin
          tipo:=tbComun;
          for i:=0 to MAX_ITEMS_BOLSA do
            Item[i]:=ObNuloMDV;
        end;
        //si cae un cadaver, controlar si cae sobre fogata
        if (tipoBolsa>=tbCadaver) and (tipoBolsa<=tbCadaverQuemado) then
          if (tipo>=tbFogata) and (tipo<=tbCadaverArdiente) then
            if tipoBolsa<>tbCadaverEnergia then
              tipo:=tbCadaverArdiente
            else
              tipo:=tbFogata
          else
            tipo:=tipoBolsa;//si cae un cadaver el tipo de bolsa cambia al tipo de cadaver
        //verificar no dejar objetos sobre trampas
        if tipo=tbTrampaMagica then
        begin
          result:=false;
          exit;
        end;
        if ((tipo>=tbLenna) and (tipo<=tbCenizas) and (tipo<>tbCadaverAvatar)) and (tipoBolsa=tbComun) then
        begin
          tipo:=tbComun;
          EnviarAlMapa(fcodMapa,#194+char(x)+char(y));
        end;
        if artefacto.id<4 then exit;
        for i:=0 to MAX_ITEMS_BOLSA do
          if AgregarObjetoAObjeto(artefacto,Item[i])=MOVIO_TODO_A_DESTINO then exit;
        for i:=0 to MAX_ITEMS_BOLSA do
          if Item[i].id<4 then
          begin
            Item[i]:=Artefacto;
            Artefacto:=ObNuloMDV;
            exit;
          end;
        if ReemplazarObjetoMenosCostoso then
          RealizarReemplazarObjetoMenosCostoso
        else
          result:=false;
        exit;//Ya solto el objeto, salir
      end
      else
      begin
        result:=false;
        exit;//Error, no pudo soltar la bolsa.
      end;
  //Si no pudo soltar en una bolsa existente, soltar en una nueva bolsa
  codBolsa:=Bolsalibre;
  //Ojo, controlar con el límite de bolsas (<=maxBolsas) disponibles para los jugadores.
  if BolsaLibre<maxBolsas then
    inc(BolsaLibre)
  else
    bolsaLibre:=0;
  with Bolsa[codBolsa] do
  begin
    if tipo<>tbninguna then// si era otra bolsa, retirar marca de existencia en el mapa
    begin
      MapaPos[posx,posy].terbol:=MapaPos[posx,posy].terbol or NoExisteBolsa;
      EnviarAlMapa(fcodMapa,#192{Eliminar bolso}+char(posx)+char(posy));
    end;
    MapaPos[x,y].terbol:=(MapaPos[x,y].terbol and mskTerreno) or codBolsa;
    posx:=x;
    posy:=y;
    //Actualizar contenido de la bolsa
    tipo:=tipoBolsa;
    Item[0]:=Artefacto;
    Artefacto:=ObNuloMDV;
    for i:=1 to MAX_ITEMS_BOLSA do
      Item[i]:=ObNuloMDV;
    //Enviar actualización a los jugadores del mapa
    case tipoBolsa of
      tbLenna:TagTipoBolsa:=#195;
      tbFogata:TagTipoBolsa:=#196;
      tbTrampaMagica:begin
        TagTipoBolsa:=#203;
        //Cuando se prepara una trampa, en el modificador del objeto va el clan del jugador
        //el clan debe quedar en el segundo objeto y el primero con modificador 1.
        Item[1].modificador:=Item[0].modificador;
        Item[0].modificador:=1;
      end;
      else TagTipoBolsa:=#194;//Bolsa Comun
    end;
    if tipoBolsa<>tbCadaver then
      EnviarAlMapa(fcodMapa,TagTipoBolsa+char(x)+char(y));
  end;
end;

procedure TTableroControlado.SacarDinero(RjugadorOrigen,RJugadorDestino:TjugadorS;cantidad:integer);
var Monedas:Tartefacto;
    Mone100,MoneO,MoneP:byte;
    NotificarBolsoLleno:boolean;
begin
  if RJugadorDestino.hp=0 then exit;
  if longbool(RJugadorDestino.banderas and BnParalisis) then exit;
  if RJugadorOrigen.hp=0 then exit;
  if longbool(RJugadorOrigen.banderas and BnParalisis) then exit;
  NotificarBolsoLleno:=false;
  with RjugadorOrigen do
  begin
    if cantidad>dinero then cantidad:=dinero;
    dec(dinero,cantidad);
    if cantidad>=10000 then
    begin
      Mone100:=cantidad div 10000;
      cantidad:=cantidad mod 10000;
    end
    else
      Mone100:=0;
    MoneO:=cantidad div 100;
    MoneP:=cantidad mod 100;
    if Mone100>0 then
    begin
      Monedas.id:=7;
      Monedas.modificador:=Mone100;
      NotificarBolsoLleno:=not RealizarNotificarAgregarObjeto(RJugadorDestino,Monedas);
      if NotificarBolsoLleno then
        inc(dinero,Mone100*10000);
    end;
    if MoneO>0 then
    begin
      Monedas.id:=5;
      Monedas.modificador:=MoneO;
      NotificarBolsoLleno:=not RealizarNotificarAgregarObjeto(RJugadorDestino,Monedas);
      if NotificarBolsoLleno then
        inc(dinero,MoneO*100);
    end;
    if MoneP>0 then
    begin
      Monedas.id:=4;
      Monedas.modificador:=MoneP;
      NotificarBolsoLleno:=not RealizarNotificarAgregarObjeto(RJugadorDestino,Monedas);
      if NotificarBolsoLleno then
        inc(dinero,MoneP);
    end;
    //Notificar de cuantas monedas le quedan en su bolso de monedas:
    SendText(codigo,#250{Dinero}+B4aStr(dinero));
  end;
  if NotificarBolsoLleno then
    SendText(RJugadorDestino.codigo,'i'+char(i_TuInventarioEstaLleno));
end;

procedure TTableroControlado.LlamarAtencionNPC(RJugador:TjugadorS;CodigoMonstruo:word);
var PNJcomerciante:TmonstruoS;
begin
  with RJugador do
  begin
    if hp=0 then exit;
    if longbool(banderas and BnParalisis) then exit;
    if CodigoMonstruo>MaxMonstruos then exit;//fuera de rango
    //Limpiar flag de modo seguir npj/pj
    banderas:=(banderas or bnSiguiendo) xor bnSiguiendo;
    PNJcomerciante:=Monstruo[CodigoMonstruo];
    if PNJcomerciante.comportamiento<>comComerciante then exit;
    if abs(PNJcomerciante.coordx-coordx)+abs(PNJcomerciante.coordy-coordy)>MAXIMA_DISTANCIA_COMERCIO then exit;
    PNJcomerciante.dir:=CalcularDirExacta(coordx-PNJcomerciante.coordx,coordy-PNJcomerciante.coordy);
    //El comerciante mira al comprador y se queda quieto.
    EnviarAlMapa(fcodMapa,char(128{Refres.Dir}+PNJcomerciante.dir)+b2aStr(PNJcomerciante.codigo or ccmon));
    PNJcomerciante.inicializarTimer(TdBasico,TIEMPO_ATENCION_COMERCIANTE_AL_COMPRADOR);
  end;
end;

procedure TTableroControlado.ComprarObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte;CodigoMonstruo:word);
var PNJcomerciante:TmonstruoS;
    precio:integer;
begin
  if IndArtefacto<=MAX_ARTEFACTOS then
  with RJugador do
  begin
    if (hp=0) or longbool(banderas and BnParalisis) or (not activo) then exit;
    if CodigoMonstruo>MaxMonstruos then exit;//fuera de rango
    PNJcomerciante:=Monstruo[CodigoMonstruo];
    if PNJcomerciante.comportamiento<>comComerciante then exit;
    if abs(PNJcomerciante.coordx-coordx)+abs(PNJcomerciante.coordy-coordy)>MAXIMA_DISTANCIA_COMERCIO then exit;
    if PNJcomerciante.duenno>=N_Comerciantes then exit;
    with Comerciante[PNJcomerciante.duenno] do//comerciar, realizar oferta de compra.
      if Item[IndArtefacto].id>=8 then
      begin
        //Definir el ObjetoOferta
        ObjetoOferta:=Item[IndArtefacto];
        //si la cantidad no es correcta, salir
        if not FijarNumeroElementos(ObjetoOferta,cantidad) then exit;
        precio:=CalcularModificacionPrecio(PrecioArtefacto(ObjetoOferta),inflacion[IndArtefacto],false,(clan=castillo.Clan) and (clan<=maxClanesJugadores));
        PNJcomerciante.inicializarTimer(TdBasico,TIEMPO_ATENCION_COMERCIANTE_AL_COMPRADOR);//El comerciante se queda quieto.
        if precio<=dinero then
        begin
          //El comerciante mira al comprador
          PNJcomerciante.dir:=CalcularDirExacta(coordx-PNJcomerciante.coordx,coordy-PNJcomerciante.coordy);
          EnviarAlMapa(fcodMapa,char(128{Refres.Dir}+PNJcomerciante.dir)+b2aStr(PNJcomerciante.codigo or ccmon));
          //Especificación de la Oferta:
          DineroOferta:=Precio;
          CodigoMonstruoOferta:=codigoMonstruo;
          IndiceInflacionModificada:=IndArtefacto;
          //No es necesario: //CantidadObjetosOferta:=cantidad;
          TipoTransaccion:=ttCompraAPNJ;
          //Enviar el precio actual
          SendText(codigo,'Ip'+b2aStr(CodigoMonstruo)+b4aStr(Precio)+char(ObjetoOferta.id)+char(ObjetoOferta.modificador));
        end
        else
          SendText(codigo,'I-'+b2aStr(CodigoMonstruo)+b4aStr(Precio)+char(ObjetoOferta.id)+char(ObjetoOferta.modificador));
      end;
  end;
end;

procedure TTableroControlado.VenderObjeto(RJugador:TjugadorS;IndArtefacto,cantidad:byte;CodigoMonstruo:word);
var PNJcomerciante:TmonstruoS;
    precio:integer;
    i:integer;
    ObjetoCantidadAVender:TArtefacto;
begin
  if IndArtefacto<=MAX_ARTEFACTOS then
  with RJugador do
  begin
    if (hp=0) or longbool(banderas and BnParalisis) or (not activo) then exit;
    if CodigoMonstruo>MaxMonstruos then exit;//fuera de rango
    PNJcomerciante:=Monstruo[CodigoMonstruo];
    if PNJcomerciante.comportamiento<>comComerciante then exit;
    if abs(PNJcomerciante.coordx-coordx)+abs(PNJcomerciante.coordy-coordy)>MAXIMA_DISTANCIA_COMERCIO then exit;
    if Artefacto[IndArtefacto].id>=8 then
    begin
      //comienza la venta.
      CopiarCantidadObjeto(Artefacto[IndArtefacto],ObjetoCantidadAVender,cantidad);
      precio:=PrecioArtefacto(ObjetoCantidadAVender);
      if precio=0 then exit;
      if PNJcomerciante.duenno>=N_Comerciantes then exit;
      with Comerciante[PNJcomerciante.duenno] do//comerciar, realizar oferta de compra.
      begin
        PNJcomerciante.inicializarTimer(TdBasico,TIEMPO_ATENCION_COMERCIANTE_AL_COMPRADOR);
        for i:=0 to MAX_ARTEFACTOS do
          if (item[i].id=ObjetoCantidadAVender.id) or (item[i].id=4)then
          begin
            precio:=CalcularModificacionPrecio(Precio,inflacion[i],true,(clan=castillo.Clan) and (clan<=maxClanesJugadores));
            PNJcomerciante.dir:=CalcularDirExacta(coordx-PNJcomerciante.coordx,coordy-PNJcomerciante.coordy);
            EnviarAlMapa(fcodMapa,char(128{Refres.Dir}+PNJcomerciante.dir)+b2aStr(PNJcomerciante.codigo or ccmon));
            //Especificación de la Oferta:
            DineroOferta:=Precio;
            ObjetoOferta:=Artefacto[IndArtefacto];
            IndiceObjetoOferta:=IndArtefacto;
            CodigoMonstruoOferta:=codigoMonstruo;
            IndiceInflacionModificada:=i;
            CantidadObjetosOferta:=cantidad;
            TipoTransaccion:=ttVentaAPNJ;
            //Enviar la oferta
            SendText(codigo,'Io'+b2aStr(CodigoMonstruo)+b4aStr(Precio)+char(ObjetoCantidadAVender.id)+char(ObjetoCantidadAVender.modificador));
            exit;
          end;
      end;
      SendText(codigo,'H'+b2aStr(CodigoMonstruo or ccmon)+char(i_NoComproEsasCosas));
    end
  end;
end;

procedure TTableroControlado.AceptarOferta(Rjugador:TjugadorS);
var comerciantePNJ:TmonstruoS;
begin
  with RJugador do
  begin
  //Controles comunes
    if (hp=0) or longbool(banderas and BnParalisis) or (not activo) then exit;
    if TipoTransaccion>=ttCompraAPNJ then
    begin//Controles comunes de comercio con PNJ;
      if IndiceInflacionModificada>Max_Artefactos then exit;
      if CodigoMonstruoOferta>MaxMonstruos then exit;
      comerciantePNJ:=Monstruo[CodigoMonstruoOferta];
      if comerciantePNJ.comportamiento<>comComerciante then exit;
      if comerciantePNJ.duenno>=N_Comerciantes then exit;
      if abs(comerciantePNJ.coordx-coordx)+abs(comerciantePNJ.coordy-coordy)>MAXIMA_DISTANCIA_COMERCIO then
      begin
        SendText(codigo,'H'+b2aStr(comerciantePNJ.codigo or ccmon)+char(i_EstasMuyLejos));
        exit;
      end;
      if TipoTransaccion=ttVentaAPNJ then
      begin
          if IndiceObjetoOferta>Max_Artefactos then exit;
          if word(ObjetoOferta)=word(Artefacto[IndiceObjetoOferta]) then//Control anti-cheat
          begin
            with Comerciante[comerciantePNJ.duenno] do
              if inflacion[IndiceInflacionModificada]>0 then
                dec(inflacion[IndiceInflacionModificada]);//disminuye el precio.
            ExtraerCantidadObjeto(Artefacto[IndiceObjetoOferta],ObjetoOferta,cantidadObjetosOferta);
            inc(dinero,DineroOferta);
            //Informar Al Jugador
            with Artefacto[IndiceObjetoOferta] do
              SendText(codigo,#250{Refres.Din}+b4astr(dinero)+
                char(216{Refres.Obj}+IndiceObjetoOferta)+char(id)+char(modificador)+
                'H'+b2aStr(CodigoMonstruoOferta or ccmon)+char(i_DialogoNPJqueCompro));
          end
          else
            SendText(codigo,'H'+b2aStr(CodigoMonstruoOferta or ccmon)+char(i_NoIntentesEstafarme));
      end
      else
        if TipoTransaccion=ttCompraAPNJ then
          if dinero>=DineroOferta then
          begin
            with Comerciante[comerciantePNJ.duenno] do
              if (inflacion[IndiceInflacionModificada])<255 then
                inc(inflacion[IndiceInflacionModificada]);//aumenta el precio.
            if RealizarNotificarAgregarObjeto(RJugador,objetoOferta) then
            begin
              dec(dinero,DineroOferta);
              if Castillo.clan<=maxClanesJugadores then
                inc(Castillo.Dinero,DineroOferta shr 3);
              SendText(codigo,#250{Refres.Din}+b4astr(dinero)+
                'H'+b2aStr(CodigoMonstruoOferta or ccmon)+char(i_DialogoNPJqueVendio));
            end;
          end
    end;//if
  end;//with Jugador
end;

function TTableroControlado.EliminarBolsaDelMapaYComunicarlo(x,y:byte):boolean;
//true si existia una bolsa
var CodBolsa:word;
begin
  result:=false;
  CodBolsa:=MapaPos[x,y].terbol and mskBolsa;
  if CodBolsa>maxBolsas then exit;//no existe marca de existencia de bolsa
  result:=EliminarBolsa(codBolsa);
  if result then
    EnviarAlMapa(fcodMapa,#192{Eliminar bolso}+char(x)+char(y));
end;

function TTableroControlado.EliminarBolsa(cdBolsaEliminada:word):boolean;
//true si existia una bolsa. OJO: NECESITA un cdBolsaEliminada válido.
begin
  with bolsa[cdBolsaEliminada] do
  begin//Eliminar la bolsa
    MapaPos[posx,posy].terbol:=MapaPos[posx,posy].terbol or NoExisteBolsa;//eliminada marca de existencia
    result:=tipo<>tbNinguna;//resultado verdadero si había algo en la bolsa.
    tipo:=tbNinguna;
  end;
  with Bolsa[BolsaLibre] do//Cambiar por bolsa libre, para que no se pierda
    if tipo<>tbNinguna then//sólo si la bolsa libre tiene algo
    begin
      Bolsa[cdBolsaEliminada]:=Bolsa[BolsaLibre];//guardar la bolsa libre en esta bolsa que ya no se esta usando
      MapaPos[posx,posy].terbol:=(MapaPos[posx,posy].terbol and mskTerreno) or cdBolsaEliminada;//indicar el nuevo código de la bolsa
      tipo:=tbNinguna;//La bolsa libre ahora no tiene nada.
    end;
end;

procedure TTableroControlado.AlzarObjetos(RJugador:TjugadorS);
var j:integer;
    CodBolsa:word;
    EncontroAlgo:boolean;
begin
  with RJugador do
  begin
    if (not activo) or longbool(banderas and BnParalisis) or ((hp=0) and (comportamiento<=comHeroe)) then exit;
    EncontroAlgo:=False;
    CodBolsa:=MapaPos[coordx,coordy].terbol and mskBolsa;
    if CodBolsa<=maxBolsas then
    begin
      with Bolsa[codBolsa] do
        if tipo<>tbNinguna then
        begin
          if (tipo=tbTrampaMagica) and (DES<=random(20)) then
          begin
            SendText(codigo,'i'+char(i_FallasteAlIntentarDesactivarLaTrampa));
            exit;
          end;
          for j:=0 to MAX_ITEMS_BOLSA do
            if Item[j].id>=4 then
            begin
              if not RealizarNotificarAgregarObjeto(RJugador,Item[j]) then
              begin
                SendText(codigo,'i'+char(i_TuInventarioEstaLleno));
                if EncontroAlgo then InformarNuevoEstadoDeBolsa(Rjugador);
                exit;
              end;
              EncontroAlgo:=true;
            end;
          tipo:=tbNinguna;
        end;
      EliminarBolsa(CodBolsa);
    end;
    if EncontroAlgo then
    begin
      EnviarAlMapa(fcodMapa,#192{Eliminar bolso}+char(coordx)+char(coordy));
      InformarNuevoEstadoDeBolsa(Rjugador);
    end
    else
    begin
      EnviarAlMapa_J(RJugador,#192{Eliminar bolso}+char(coordx)+char(coordy));
      SendText(codigo,#193{Eliminar bolso vacio}+char(coordx)+char(coordy));
    end;
  end;
end;

procedure TTableroControlado.SoltarObjetosMuerto(jug:TjugadorS);
var i:integer;
    x,y,ncoordx,ncoordy:integer;
    casilla:word;
begin
  with jug do
  begin
    if usando[uAmuleto].id=ihAmuletoDeConservacion then
    begin
      usando[uAmuleto]:=ObNuloMDV;
      //No informamos por que asumimos que el cliente lo desvanece también.
      exit;
    end;
    //Soltar Artefactos
    for i:=0 to 7 do
      if EsObjetoQueCae(Usando[i]) then
        SoltarObjetoXY(Usando[i],coordx,coordy,tbCadaverAvatar,true);
    for i:=0 to 4 do
      if EsObjetoQueCae(Artefacto[i]) then
        SoltarObjetoXY(Artefacto[i],coordx,coordy,tbCadaverAvatar,true);
    //Buscar otro lugar para seguir soltando objetos.
    ncoordx:=coordx;
    ncoordy:=coordy;
    for i:=0 to 7 do//revisar casillas alrededor
    begin
      x:=coordx+MC_avancex[i];
      y:=coordy+MC_avancey[i];
      if (x>=0) and (x<=maxmapaareaext) and (y>=0) and (y<=maxmapaareaext) then
        if (mapaPos[x,y].terBol and MskTerreno_SoltarBolsa)<>0 then
        begin
          casilla:=mapapos[x,y].monRec;
          if (casilla<=ccLimiteMonstruos) or (casilla=ccVac) then
          begin
            ncoordx:=x;
            ncoordy:=y;
            break;
          end;
        end;
    end;
    for i:=5 to MAX_ARTEFACTOS do
      if EsObjetoQueCae(Artefacto[i]) then
        SoltarObjetoXY(Artefacto[i],ncoordx,ncoordy,tbComun,true);
    CalcularModDefensa;
    SendText(codigo,'I0'+b4aStr(ObtenerFlagsDeObjetosNulos));
    //informar de nuevo cadaver de avatar
    EnviarAlMapa(fcodMapa,#202+char(coordx)+char(coordy));
  end;
end;

procedure TTableroControlado.FabricarArtefacto(RJugador:TjugadorS;IndArt,idObjeto:byte);
var recurso:word;
    idHerramienta:byte;
    reparar:boolean;
begin
  if puedeUsarHerramienta(Rjugador,IndArt,reparar)=i_Ok then
    if not reparar then
    with RJugador do
    begin
      idHerramienta:=Artefacto[IndArt].id;
      if PuedeConstruir(idHerramienta,idObjeto) then
      begin
        recurso:=ObtenerRecursoAlFrente(RJugador);
        case idHerramienta of
        //Agregar control de condiciones de terreno.
          ihTijeras:ConsumirMateriales(RJugador,idObjeto);
          ihSerrucho:ConsumirMateriales(RJugador,idObjeto);
          ihCalderoMagico:ConsumirMateriales(RJugador,idObjeto);
          ihMartillo:if recurso=irYunque then
            ConsumirMateriales(RJugador,idObjeto);
          ihLibroAlquimia:if recurso=irEstudioAlquimia then
            ConsumirMateriales(RJugador,idObjeto);
        end;
      end;
    end;
end;

procedure TTableroControlado.UtilizarHerramienta(RJugador:TjugadorS;indArt:byte);
//Ojo que no hay control previo de requerimientos para el uso de artefactos.
//Por este motivo cada procedimiento debe controlar TODOS los requerimientos
//necesarios para utilizar la herramienta.
var RecursoDelMapa:word;
  procedure RealizarPescar;
  var Base:integer;
      Arecurso:Tartefacto;
  begin
    with RJugador do
    begin
      base:=SAB+DES;
      if base>random(32) then
      begin
        base:=1+random(base shr 3);
        Arecurso.modificador:=base;
        if random(20)=0 then
          if random(30)=0 then
          begin
            Arecurso.id:=98+random(6);//anillo
            Arecurso.modificador:=63;
          end
          else
            Arecurso.id:=173//baba de medusa
        else
          Arecurso.id:=orPescado;
        EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+'p');//Pescar
        if not RealizarNotificarAgregarObjeto(RJugador,Arecurso) then
        begin
          SendText(codigo,'i'+char(i_TuInventarioEstaLleno));
          exit;
        end;
        if nivel>MAX_NIVEL_NEWBIE then exit;
        NotificarModificacionExperiencia(rjugador,nivel);
      end;
    end;
  end;
  procedure RealizarTalar(IDRecurso:byte);
  var cantidad:integer;
      Arecurso:Tartefacto;
      ConsumoComida:byte;
  begin
    if (IDRecurso>=irLenna) and (IDRecurso<=irMaderaMagica) then
    with RJugador do
    begin
      if longbool(pericias and hbCarpinteria) then
        cantidad:=nivel
      else
        cantidad:=0;
      cantidad:=random(cantidad+FRZ+DES) shr 3;
      if (cantidad<1) then exit;
      ConsumoComida:=0;
      case IDRecurso of
        irMaderaMagica:begin
          cantidad:=cantidad shr 2;
          Arecurso.id:=orMaderaMagica;
          ConsumoComida:=2;
        end;
        irMadera:begin
          cantidad:=cantidad shr 1;
          Arecurso.id:=orMadera;
          ConsumoComida:=1;
        end;
        else Arecurso.id:=orLenna;
      end;
      if cantidad<1 then cantidad:=1;
      if cantidad>5 then cantidad:=5;
      if (consumoComida>0) then
      begin
        if comida<ConsumoComida then comida:=0 else dec(comida,consumoComida);
        SendText(codigo,#253+char(comida));
      end;
      Arecurso.modificador:=cantidad;
      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+'t');//talar
      if not RealizarNotificarAgregarObjeto(RJugador,Arecurso) then
      begin
        SendText(codigo,'i'+char(i_TuInventarioEstaLleno));
        exit;
      end;
      if not longbool(pericias and hbCarpinteria) then exit;
      if nivel>MAX_NIVEL_EXPERIENCIA_POR_TRABAJAR then exit;
      NotificarModificacionExperiencia(rjugador,nivel);
    end;
  end;
  procedure RealizarBuscarIngredientes(IDRecurso:byte);
  var Base:integer;
      bono:longbool;
      Arecurso:Tartefacto;
      ConsumoComida:byte;
  begin
    if (IDRecurso>=irIngrediente0) and (IDRecurso<=irIngrediente7) then
    with RJugador do
    begin
      base:=SAB+INT+irIngrediente0-IDRecurso;
      bono:=longbool(pericias and hbHerbalismo);
      if bono then
        inc(base,nivel);
      if base<=random(32) then exit;
      Arecurso.modificador:=1+random(base shr 4);
      case IDRecurso of
        irIngrediente0..irIngrediente7:with Arecurso do
          id:=168+IDRecurso-irIngrediente0;
        else
          exit;
      end;
      if IDRecurso>irIngrediente2 then
      begin
        if (not bono) and (Arecurso.modificador>1) then Arecurso.modificador:=1;
        ConsumoComida:=IDRecurso-irIngrediente2;
        if comida<ConsumoComida then comida:=0 else dec(comida,consumoComida);
        SendText(codigo,#253+char(comida));
      end;
      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#137);//buscar ingrediente
      if not RealizarNotificarAgregarObjeto(RJugador,Arecurso) then
      begin
        SendText(codigo,'i'+char(i_TuInventarioEstaLleno));
        exit;
      end;
      if (not bono) then exit;
      if nivel>MAX_NIVEL_EXPERIENCIA_POR_TRABAJAR then exit;
      NotificarModificacionExperiencia(rjugador,nivel);
    end;
  end;
  procedure RealizarMineria(IDRecurso:byte);
  var Base,cantidad:integer;
      bono:longbool;
      Arecurso:Tartefacto;
      ConsumoComida:byte;
  begin
    if ((IDRecurso>=irHierro) and (IDRecurso<=irOro)) or
      ((IDRecurso>=irGema0) and (IDRecurso<=irGema7)) or
      (IDRecurso=irGemas) then
    with RJugador do
    begin
      ConsumoComida:=0;
      bono:=longbool(pericias and hbMineria);
      if bono then base:=(nivel shl 2) else base:=nivel;
      inc(base,FRZ);
      cantidad:=random(base) shr 2;
      case IDRecurso of
        irHierro:begin
          Arecurso.id:=200;
          inc(cantidad,4);
        end;
        irArcanita:begin
          Arecurso.id:=201;
        end;
        irPlata:begin
          Arecurso.id:=202;
          dec(cantidad,4);
          ConsumoComida:=1;
        end;
        irOro:begin
          Arecurso.id:=203;
          dec(cantidad,8);
          ConsumoComida:=2;
        end;
        irGemas:with Arecurso do
        begin//Amatistas, topacios y aguamarinas.
          case random(100) of
            86..99:id:=194;//14%
            58..85:id:=193;//28%
            else id:=192;//58%
          end;
          dec(cantidad,8+ID-192);
          ConsumoComida:=2+ID-192;
        end;
        irGema0..irGema7:begin
          Arecurso.id:=192+IDRecurso-irGema0;
          dec(cantidad,8+IDRecurso-irGema0);
          ConsumoComida:=2+IDRecurso-irGema0;
        end;
        else
          exit//recurso no definido.
      end;
      if cantidad<4 then exit;
      cantidad:=cantidad shr 2;
      if (consumoComida>0) then
      begin
        if (not bono) and (cantidad>1) then cantidad:=1;
        if comida<ConsumoComida then comida:=0 else dec(comida,consumoComida);
        SendText(codigo,#253+char(comida));
      end;
      Arecurso.modificador:=cantidad;
      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+'n');//Minar
      if not RealizarNotificarAgregarObjeto(RJugador,Arecurso) then
      begin
        SendText(codigo,'i'+char(i_TuInventarioEstaLleno));
        exit;
      end;
      if not longbool(pericias and hbMineria) then exit;
      if nivel>MAX_NIVEL_EXPERIENCIA_POR_TRABAJAR then exit;
      NotificarModificacionExperiencia(rjugador,nivel);
    end;
  end;

  procedure RealizarFundicion;
  var cantidad,lingotes:integer;
      recurso:byte;
  begin
    with RJugador do
    if longbool(pericias and(hbMineria or hbHerreria)) then
    begin
      recurso:=Artefacto[IndArt].id;
      if (recurso=orHierro) or (recurso=orArcanita) then
        cantidad:=3
      else
        if (recurso=orPlata) then
          cantidad:=6
        else
          cantidad:=15;

      lingotes:=Artefacto[IndArt].modificador;
      if lingotes<cantidad then exit;
      Artefacto[IndArt].id:=recurso+4;
      Artefacto[IndArt].modificador:=(lingotes+random(cantidad)) div cantidad;
      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+'u');//Sonido fundicion
      SendText(codigo,char(216+IndArt)+char(Artefacto[IndArt].id)+
        char(Artefacto[IndArt].modificador));
    end;
  end;

  procedure RealizarLeerMagia;
  var Dificultar_Leer:integer;
      Nro_Conjuro:byte;
  begin
    with RJugador do
    if (maxMana>0) then
    begin
      Nro_Conjuro:=Artefacto[IndArt].modificador;
      if puedeLeerElConjuro(Nro_Conjuro) then
      begin
        Artefacto[IndArt]:=ObNuloMDV;
        Dificultar_Leer:=0;
        with InfConjuro[Nro_conjuro] do
        begin
          if ((Usando[uArmaDer].id<>ihLibroArcano){sinArcano} or (nivelINT<=nivelSAB){noArcano}) and
           ((Usando[uArmaDer].id<>ihLibroOracion){sinSagrado} or (nivelSAB<=nivelINT){noClerical}) then
          begin
            if (nivelINT>INT) then inc(Dificultar_Leer,nivelINT-INT);
            if (nivelSAB>SAB) then inc(Dificultar_Leer,nivelSAB-SAB);
          end;
        end;
        if random(Dificultar_Leer+2)<=1 then
        begin
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#5);//Sonido leer pergamino
          Conjuros:=Conjuros or (1 shl Nro_Conjuro);
        end
        else
          Nro_Conjuro:=$80 or Nro_Conjuro;
        SendText(codigo,char(216+IndArt)+char(Artefacto[IndArt].id)+char(Artefacto[IndArt].modificador)+
          'Ic'+char(Nro_Conjuro));
      end;
    end;
  end;
  procedure RealizarEscribirMagia;
  var Arecurso:Tartefacto;
      nivelHechizoEscrito:byte;
  begin
    with RJugador do
    //Control anti trampa:
    if longbool(pericias and hbEscribir) and
       (PuedeEscribirElConjuroSeleccionado(IndArt)=i_ok) then
    begin
      Arecurso.modificador:=ConjuroElegido;
      Arecurso.id:=InfConjuro[ConjuroElegido].IconoPergamino;
      //Agregar el pergamino escrito
      Usando[uArmaDer]:=Arecurso;
      //Sonido crear pergaminos
      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#4);//crear pergamino
      if Usando[uArmaIzq].modificador>1 then
        dec(Usando[uArmaIzq].modificador)
      else
        Usando[uArmaIzq]:=ObNuloMDV;
      nivelHechizoEscrito:=InfConjuro[ConjuroElegido].nivelJugador;
      if Artefacto[IndArt].modificador>nivelHechizoEscrito then
        dec(Artefacto[IndArt].modificador,nivelHechizoEscrito)
      else
        Artefacto[IndArt]:=ObNuloMDV;
      //209=208+1: refrescar objetos -> objeto usando[1]
      SendText(codigo,
        #208+char(Usando[uArmaDer].id)+char(Usando[uArmaDer].modificador)+
        #209+char(Usando[uArmaIzq].id)+char(Usando[uArmaIzq].modificador)+
        char(216+IndArt)+char(Artefacto[IndArt].id)+char(Artefacto[IndArt].modificador));
    end;
  end;

  procedure RealizarTallarGemas;
  var habilidad,media,minimo:integer;
      Arecurso:Tartefacto;
  begin
    with RJugador do
    //Control anti tramposos:
    if (Usando[uArmaIzq].id shr 3=24) and//Grupo de objetos gemas.
       (Usando[uArmaIzq].modificador>0) then //Por lo menos uno
    begin
      habilidad:=DES shl 2+nivel shl 1;
      if longbool(pericias and hbTallarGemas) and (random(100)<habilidad) then
      begin
        if habilidad>150 then media:=150 else media:=habilidad;
        habilidad:=random(media)+random(media);
        if habilidad>media then
          dec(habilidad,media)
        else
          habilidad:=media-habilidad;
        dec(habilidad,(Usando[uArmaIzq].id and $7) shl 1);
        minimo:=nivel shr 2;
        if habilidad<minimo then habilidad:=minimo;
        if habilidad>=96 then
          case random(31) of
            0:if habilidad>=100 then habilidad:=100;
            1..2:if habilidad>=99 then habilidad:=99;
            3..6:if habilidad>=98 then habilidad:=98;
            7..14:if habilidad>=97 then habilidad:=97;
            else
              habilidad:=96;
          end;
      end
      else
        habilidad:=random(habilidad shr 4)+(habilidad shr 6);
      if habilidad<2 then
      begin
        habilidad:=1;
        SendText(codigo,'i'+char(i_ArruinasteLaGema));
      end;
      Arecurso.modificador:=habilidad;
      Arecurso.id:=Usando[uArmaIzq].id-8;
      //Sonido tallar gemas
      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#129);//tallar gema
      Usando[uArmaDer]:=Arecurso;
      if Usando[uArmaIzq].modificador>1 then
        dec(Usando[uArmaIzq].modificador)
      else
        Usando[uArmaIzq]:=ObNuloMDV;
      //209=208+1: refrescar objetos -> objeto usando[1]
      SendText(codigo,
        #208+char(Usando[uArmaDer].id)+char(Usando[uArmaDer].modificador)+
        #209+char(Usando[uArmaIzq].id)+char(Usando[uArmaIzq].modificador));
    end;
  end;
  procedure RealizarAfilar;
  var Codigo_Bolsa:word;
      x,y:smallint;
      nivelRep:byte;
    procedure IntentarAfilarObjeto(IndiceDeObjeto:byte);
    begin
      with RJugador do
      if InfObj[Usando[IndiceDeObjeto].id].TipoReparacion=trAfilar then
      begin
        if nivelRep>Usando[IndiceDeObjeto].modificador then
        begin
          Usando[IndiceDeObjeto].modificador:=nivelRep;
          SendText(codigo,char(208+IndiceDeObjeto)+char(Usando[IndiceDeObjeto].id)+char(Usando[IndiceDeObjeto].modificador))
        end;
        if Artefacto[IndArt].modificador>1 then
          dec(Artefacto[IndArt].modificador)
        else
          Artefacto[IndArt]:=ObNuloMDV;
      end;
    end;
  begin
    with RJugador do
      if (InfObj[Usando[uArmaDer].id].TipoReparacion=trAfilar) or
         (InfObj[Usando[uArmaIzq].id].TipoReparacion=trAfilar) then
      begin
        nivelRep:=NivelMaximoQuePuedeReparar(trAfilar);
        IntentarAfilarObjeto(uArmaDer);
        IntentarAfilarObjeto(uArmaIzq);
        //Informar al jugador nuevo estado de su piedra de afilar:
        SendText(codigo,char(216+IndArt)+char(Artefacto[IndArt].id)+char(Artefacto[IndArt].modificador));
        EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#130);//afilar
        //Prender la fogata
        //Ubicar la posición al frente
        x:=coordX+MC_AvanceX[dir];
        if word(x)>MaxMapaAreaExt then exit;
        y:=coordY+MC_AvanceY[dir];
        if word(y)>MaxMapaAreaExt then exit;
        Codigo_Bolsa:=mapaPos[x,y].terbol and mskBolsa;//Obtener el código de la bolsa
        if Codigo_Bolsa<=maxBolsas then//Si existe una bolsa en dicha posicion
          with Bolsa[Codigo_Bolsa] do
          if tipo=tbLenna then//Si el tipo de bolsa es leña lista para la fogata
          begin
            if EstaLloviendo(x,y) then
            begin
              SendText(codigo,'i'+char(i_NoPuedesEncenderFogataPorLluvia));
              exit;
            end;
            if Item[0].id=orLenna then//Ver si hay suficiente leña:
              if Item[0].modificador>=NRO_LENNOS_FOGATA then
              begin
                tipo:=tbFogata;
                Item[0]:=ObNuloMDV;
                EnviarAlMapa(fcodmapa,#196+char(x)+char(y));
              end;
          end;
      end;
  end;
  procedure RealizarAceitar;
  var nivelRep:byte;
  begin
    with RJugador do
      if InfObj[Usando[uArmaDer].id].TipoReparacion=trAceitar then
      begin
        nivelRep:=NivelMaximoQuePuedeReparar(trAceitar);
        if Artefacto[IndArt].modificador>1 then
          dec(Artefacto[IndArt].modificador)
        else
          Artefacto[IndArt]:=ObNuloMDV;
        if nivelRep>Usando[uArmaDer].modificador then
        begin
          Usando[uArmaDer].modificador:=nivelRep;
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#131);//aceitar
          SendText(codigo,char(208+uArmaDer)+char(Usando[uArmaDer].id)+char(Usando[uArmaDer].modificador)+
            char(216+IndArt)+char(Artefacto[IndArt].id)+char(Artefacto[IndArt].modificador));
        end;
      end;
  end;
  procedure RealizarMartillar;
  var nivelRep:byte;
  begin
    with RJugador do
      if InfObj[Usando[uArmaDer].id].TipoReparacion=trMartillar then
      begin
        nivelRep:=NivelMaximoQuePuedeReparar(trMartillar);
        if nivelRep>Usando[uArmaDer].modificador then
        begin
          Usando[uArmaDer].modificador:=nivelRep;
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#132);//martillar
          SendText(codigo,char(208+uArmaDer)+char(Usando[uArmaDer].id)+
            char(Usando[uArmaDer].modificador));
        end;
      end;
  end;
  procedure RealizarHacerFogata;
  var nroLennosRestantes:byte;
  begin
    with RJugador do
    begin
      if AlFrenteUnBuenLugarParaFogatas(RJugador) then
        if Artefacto[IndArt].modificador>=NRO_LENNOS_FOGATA then
        begin
          nroLennosRestantes:=Artefacto[IndArt].modificador-NRO_LENNOS_FOGATA;
          Artefacto[IndArt].modificador:=NRO_LENNOS_FOGATA;
          SoltarObjetoXY(Artefacto[IndArt],coordX+MC_avanceX[dir],coordY+MC_avanceY[dir],tbLenna,false);
          with Artefacto[IndArt] do
          begin
            if nroLennosRestantes>0 then
            begin
              id:=orLenna;//importante!!, soltar objeto deja en id=nulo
              modificador:=nroLennosRestantes;
            end;
            SendText(codigo,char(IndArt+216{Refrescar Objetos Inventario})+char(id)+char(modificador));
          end;
        end
        else
          SendText(codigo,'i'+char(i_NecesitasMasLennos));
    end;
  end;
  procedure RealizarPrepararTrampa;
  var trampasRestantes:byte;
  begin
    with RJugador do
    begin
      if AlFrenteUnBuenLugarParaFogatas(RJugador) then
        if Artefacto[IndArt].modificador>0 then
        begin
          trampasRestantes:=Artefacto[IndArt].modificador-1;
          Artefacto[IndArt].modificador:=clan;//al soltar una trampa, indicar aqui el clan
          SoltarObjetoXY(Artefacto[IndArt],coordX+MC_avanceX[dir],coordY+MC_avanceY[dir],tbTrampaMagica,false);
          with Artefacto[IndArt] do
          begin
            if trampasRestantes>0 then
            begin
              id:=orTrampaMagica;//importante!!, soltar objeto deja en id=nulo
              modificador:=trampasRestantes;
            end;
            SendText(codigo,char(IndArt+216{Refrescar Objetos Inventario})+char(id)+char(modificador));
          end;
        end;
    end;
  end;
  procedure RealizarAgregarMonedas;
  var cantidad:integer;
  begin
    with RJugador,Artefacto[IndArt] do
    begin
      cantidad:=modificador;
      case id of
        5:cantidad:=cantidad*100;
        6:cantidad:=cantidad*1000;
        7:cantidad:=cantidad*10000;
      end;
      Artefacto[IndArt]:=ObNuloMDV;
      inc(dinero,cantidad);
      SendText(codigo,char(IndArt+216{Refrescar Objetos Inventario})+char(id)+char(modificador)+
        #250{Dinero}+b4aStr(dinero));
    end;
  end;
  procedure RealizarCoser;
  var nivelRep:byte;
  begin
    with RJugador do
      if InfObj[Usando[uArmaDer].id].TipoReparacion=trCoser then
      begin
        nivelRep:=NivelMaximoQuePuedeReparar(trCoser);
        if nivelRep>Usando[uArmaDer].modificador then
        begin
          Usando[uArmaDer].modificador:=nivelRep;
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#133);//coser
          SendText(codigo,char(208+uArmaDer)+char(Usando[uArmaDer].id)+
            char(Usando[uArmaDer].modificador));
        end;
      end;
  end;
  procedure RealizarVendar;
  begin
    with RJugador,Artefacto[IndArt] do
      if modificador>0 then
        if (hp<maxhp) and ((banderas and BnVendado)=0) then//esta algo dañado y sin vendas
        begin
          if modificador>1 then
            dec(modificador)
          else
            Artefacto[IndArt]:=ObNuloMDV;
          banderas:=Banderas or BnVendado;
          SendText(codigo,
            char(216+IndArt)+char(id)+char(modificador)+'sV');
        end;
  end;
  procedure RealizarLlenarVarita;
  begin
    with RJugador,Artefacto[IndArt] do
    if mana>0 then
    begin
      modificador:=mana;
      mana:=0;
      id:=ihVaritaLlena;
      SendText(codigo,char(IndArt+216{Refrescar Objetos Inventario})+char(id)+char(modificador)+
        #254{Maná}+char(mana));
    end;
  end;
  procedure FabricarTela;
  var piezas,piezashabilidad:integer;
  begin
    with RJugador do
    if longbool(pericias and hbSastreria) then
    begin
      piezas:=Artefacto[IndArt].modificador;
      if piezas<MIN_FIBRASxTELA then exit;
      piezas:=piezas shr 1;//en el mejor de los casos la mitad se convierte en tela
      piezashabilidad:=((random(SAB+DES)+nivel)*piezas) shr 5;
      if piezashabilidad<(piezas shr 1) then piezashabilidad:=(piezas shr 1);
      if piezashabilidad>piezas then piezashabilidad:=piezas;
      Artefacto[IndArt].id:=orTela;
      Artefacto[IndArt].modificador:=piezashabilidad;

      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#128);//Sonido fabricar Tela
      SendText(codigo,char(216+IndArt)+char(Artefacto[IndArt].id)+
        char(Artefacto[IndArt].modificador));
    end;
  end;
  procedure RealizarCurtirPieles;
  var piezas,piezashabilidad:integer;
  begin
    with RJugador do
    if longbool(pericias and(hbSastreria)) then
    begin
      piezas:=Artefacto[IndArt].modificador;
      if piezas<MIN_PIELESxCUERO then exit;
      piezas:=piezas shr 1;//en el mejor de los casos la mitad se convierte en cuero
      piezashabilidad:=((random(SAB+DES)+nivel)*piezas) shr 5;
      if piezashabilidad<(piezas shr 1) then piezashabilidad:=(piezas shr 1);
      if piezashabilidad>piezas then piezashabilidad:=piezas;
      Artefacto[IndArt].id:=orCuero;
      Artefacto[IndArt].modificador:=piezashabilidad;

      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#6);//Sonido curtir
      SendText(codigo,char(216+IndArt)+char(Artefacto[IndArt].id)+
        char(Artefacto[IndArt].modificador));
    end;
  end;
  procedure TocarInstrumento(ConsumirInstrumento:boolean);
  const ALCANCE_EFECTO=6;
  var
      TiempoEfecto:byte;
      TipoSonido:char;
      EsHonorable,SinClan:bytebool;
     procedure realizarEfecto;
     var i,jcodmapa,jx,jy:integer;
     begin
       with RJugador do
       begin
         jcodmapa:=codMapa;
         jx:=coordx;
         jy:=coordy;
       end;
       for i:=0 to maxjugadores do
       with Jugador[i] do
         if codMapa=jcodmapa then
           if activo then
             if (abs(coordx-jx)<=ALCANCE_EFECTO) and (abs(coordy-jy)<=ALCANCE_EFECTO) then
               if ((not SinClan) and (clan=RJugador.clan)) or//sólo a su clan
                  (SinClan and (EsHonorable xor (comportamiento<comNormal))) then//sólo a su alineación
               begin
                 Banderas:=Banderas or BnEfectoBardo;
                 inicializarTimer(tdCombate,TiempoEfecto);
                 Sendtext(codigo,'i'+char(i_EstasBajoEfectodeJuglaria));
                 EnviarAlMapa(codMapa,'B'+b2aStr(codigo)+char(banderas shr 8));
               end
               else
                 if (not ConsumirInstrumento) and ((TiempoEfecto shr 4)>0) and ((Banderas and bnProteccion)=0) then
                 begin
                   Banderas:=Banderas or BnAturdir;
                   inicializarTimer(tdAturdir,TiempoEfecto shr 4);
                   EnviarAlMapa_J(Jugador[i],'A'+b2aStr(codigo)+char(banderas));
                   SendText(codigo,'sT');
                 end;
     end;
  begin
    with RJugador do
    if ConsumirInstrumento or ((CodCategoria=ctBardo) and (mana>=MANA_USAR_INSTRUMENTO)) then
    begin
      if not ConsumirInstrumento then
      begin
        dec(mana,MANA_USAR_INSTRUMENTO);
        SendText(codigo,#254{Maná}+char(mana));
      end
      else
      with Artefacto[IndArt] do
      begin
        if modificador>1 then
          dec(modificador)
        else
          Artefacto[IndArt]:=ObNuloMDV;
        SendText(codigo,char(216+IndArt)+char(id)+char(modificador));
      end;
      case Artefacto[IndArt].id of
        orFlauta:begin
          TipoSonido:=#134;
          TiempoEfecto:=DES+nivel;
        end;
        orLaud:begin
          TipoSonido:=#135;
          TiempoEfecto:=(DES+nivel) shl 1;
        end;
        else begin//orCuerno
          TipoSonido:=#136;
          TiempoEfecto:=DES shl 1+CON+FRZ;
        end
      end;
      EsHonorable:=comportamiento>=comNormal;
      SinClan:=clan>maxClanesJugadores;
      realizarEfecto;
      EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+TipoSonido);//tocar instrumento
    end
  end;
  procedure RealizarEnvenenarObjeto;
  var MascaraDeVeneno:byte;
  begin
    with RJugador,Artefacto[IndArt] do
      if modificador>0 then
      begin
        if Artefacto[IndArt].id=ihParalizante then
          MascaraDeVeneno:=MskParalizante
        else
          MascaraDeVeneno:=MskEnvenenado;
        if EnvenenarObjeto(MascaraDeVeneno,Usando[uArmaDer]) then
        begin
          if modificador>1 then
            dec(modificador)
          else
            Artefacto[IndArt]:=ObNuloMDV;
          EnviarAlAreaJugador_J(codigo,'S'+char(coordx)+char(coordy)+#139);//sonido envenenar
          SendText(codigo,char(208+uArmaDer)+char(Usando[uArmaDer].id)+char(Usando[uArmaDer].modificador)+
            char(216+IndArt)+char(id)+char(modificador));
        end;
      end;
  end;
  procedure LanzarFuegoArtificial;
  begin
    with RJugador,Artefacto[IndArt] do
      if modificador>0 then
      begin
        if modificador>1 then
          dec(modificador)
        else
          Artefacto[IndArt]:=ObNuloMDV;
        enviarAlMapa(codmapa,'S'+char(coordx)+char(coordy)+'*'{lanzar fuego art.});
        SendText(codigo,char(216+IndArt)+char(id)+char(modificador));
      end;
  end;
  procedure UsarTomoDeLaExperiencia;
  begin
    with Rjugador,Artefacto[IndArt] do
    begin
      enviarAlMapa(codmapa,'S'+char(coordx)+char(coordy)+#140{leer tomo exp.});
      NotificarModificacionExperiencia(RJugador,modificador*100);
      Artefacto[IndArt]:=ObNuloMDV;
      SendText(codigo,char(216+IndArt)+char(id)+char(modificador));
    end;
  end;
begin
  if IndArt<=MAX_ARTEFACTOS then
  with RJugador do
  if (hp<>0) and ((banderas and BnParalisis)=0) then
  begin
    RecursoDelMapa:=ObtenerRecursoAlFrente(RJugador);
    case Artefacto[IndArt].id of
      ihPico:RealizarMineria(RecursoDelMapa);
      ihHacha:RealizarTalar(RecursoDelMapa);
      ihHerramientasHerbalista:RealizarBuscarIngredientes(RecursoDelMapa);
      ihCanna:if RecursoDelMapa=irAguaConPeces then RealizarPescar;

      ihTallador:RealizarTallarGemas;

      ihPlumaMagica:if RecursoDelMapa=irEstudioMago then RealizarEscribirMagia;
      orHierro..orOro:if RecursoDelMapa=irFundicion then RealizarFundicion;
      orPiel:if RecursoDelMapa=irCurtidora then RealizarCurtirPieles;
      orFibras:if RecursoDelMapa=irTelar then FabricarTela;

      ihAfilador:RealizarAfilar;
      ihAceite:RealizarAceitar;
      ihVeneno,ihParalizante:RealizarEnvenenarObjeto;
      ihMartillo:RealizarMartillar;
      ihTijeras:RealizarCoser;
      ihVaritaVacia:RealizarLlenarVarita;

      orMonedaPlata..or100MonedasOro:RealizarAgregarMonedas;
      ihPergaminoA,ihPergaminoS:RealizarLeerMagia;
      ihVendas:RealizarVendar;
      orLenna:RealizarHacerFogata;
      orTrampaMagica:RealizarPrepararTrampa;
      orFlauta,orLaud:TocarInstrumento(false);
      orCuerno:TocarInstrumento(true);
      orBaulMagico:EnviarBaulCompleto(Rjugador);
      orFuegoArtificial:LanzarFuegoArtificial;
      orTomoExperiencia:UsarTomoDeLaExperiencia;
    end;
  end;
end;

function TTableroControlado.DireccionEnemigoJugador(jugador_mirando:TJugadorS;dirst:TdireccionMonstruo):TdireccionMonstruo;
//Detecta enemigo muy cercano
//SOLO PARA JUGADORES
var
    i,px,py:integer;
    x,y:smallint;
    codigoM,duennoAmigo:word;
    ClanAmigo:byte;
    TengoClan:bytebool;
begin
  result:=dirst;//dir previa
  with jugador_Mirando do
  begin
    ClanAmigo:=clan;
    TengoClan:=clan<=maxClanesJugadores;
    if TengoClan then
      duennoAmigo:=ccClan or clan//monstruos de su clan.
    else
    begin
      ClanAmigo:=ninguno;
      duennoAmigo:=codigo;//como no tiene clan sólo si es su monstruo
    end;
    px:=coordx;
    py:=coordy;
  end;
  //El monstruo ve en el tablero
  for i:=0 to MC_DE_Limite_Superior[0] do
  begin
    x:=px+MC_DE_deltaX[i];
    if word(x)<=MaxMapaAreaExt then
    begin
      y:=py+MC_DE_deltaY[i];
      if word(y)<=MaxMapaAreaExt then
      begin
        codigoM:=mapaPos[x,y].monrec;
        if codigoM<>ccVac then
        case codigoM and fl_con of //case contenido de la casilla
          ccMon:begin
            with Monstruo[codigoM and fl_cod] do
              if (duenno<>duennoAmigo) and (hp<>0) then
              begin
                result:=MC_DE_Direcciones[i];
                exit
              end;
          end;
          ccJgdr:begin
            with jugador[codigoM] do //sólo para jugadores, usar directamente el código de casilla como código de jugador
              if (((not TengoClan) and (comportamiento<comNormal)) or (TengoClan and (clan<>clanAmigo)))
               and (hp<>0) then
              begin
                result:=MC_DE_Direcciones[i];
                exit
              end;
          end;
        end;
      end;//if y
    end;//if x
  end;
end;

function TTableroControlado.DireccionEnemigoClan(monstruo_mirando:TMonstruoS;rango:byte;dirst:TdireccionMonstruo):TdireccionMonstruo;
//Detecta enemigo comenzando desde puntos cercanos, está optimizado
//rango=0 => casillas adyacentes.
//rango=1 => casillas adyacentes y una casila mas lejos...
//SOLO PARA MONSTRUOS, para jugadores usar DirecciónEnemigoJugador
var
    revisar:array[0..7] of bytebool;
    i,px,py:integer;
    x,y:smallint;
    codigoM:word;
    DuennoAmigo:word;
    ClanAmigo:byte;
begin
  result:=dirst;//dir previa
  with monstruo_Mirando do
  begin
    with InfMon[TipoMonstruo] do
    begin
      if rango>0 then
        case visibilidad of
          0:begin
            inc(rango,3);
            for i:=0 to 7 do revisar[i]:=false;
            revisar[dir]:=true;
          end;
          1:begin
            inc(rango,2);
            for i:=0 to 7 do revisar[i]:=false;
            revisar[dir]:=true;
            revisar[MC_siguienteDireccion[dir]]:=true;
            revisar[MC_anteriorDireccion[dir]]:=true;
          end;
          2:begin
            inc(rango);
            for i:=0 to 7 do revisar[i]:=true;
            i:=MC_DarVueltaDireccion[dir];
            revisar[i]:=false;
            revisar[MC_siguienteDireccion[i]]:=false;
            revisar[MC_anteriorDireccion[i]]:=false;
          end;
          else
            for i:=0 to 7 do revisar[i]:=true;
        end
      else
        for i:=0 to 7 do revisar[i]:=true;
      //determinar el clan de este monstruo:
      if (duenno and fl_con)=ccClan then
        ClanAmigo:=duenno and $FF
      else
        ClanAmigo:=ninguno;//$FF
      if ClanAmigo>maxClanesJugadores then
        ClanAmigo:=$FF;//Atacar a todos los que tienen clan
      DuennoAmigo:=duenno;
    end;
    px:=coordx;
    py:=coordy;
    objetivoAtacado:=ccVac;
  end;
  if rango>maxCapacidadVision then rango:=maxCapacidadVision;
  //El monstruo ve en el tablero
  for i:=0 to MC_DE_Limite_Superior[rango] do
    if revisar[MC_DE_Direcciones[i]] then
    begin
      x:=px+MC_DE_deltaX[i];
      if word(x)<=MaxMapaAreaExt then
      begin
        y:=py+MC_DE_deltaY[i];
        if word(y)<=MaxMapaAreaExt then
        begin
          codigoM:=mapaPos[x,y].monrec;
          if codigoM<ccVacRango then
          case codigoM and fl_con of //case contenido de la casilla
            ccMon:begin
              with Monstruo[codigoM and fl_cod] do
                if (Duenno<>DuennoAmigo) and (hp<>0) then
                begin
                  monstruo_mirando.objetivoAtacado:=codigoM;
                  result:=MC_DE_Direcciones[i];
                  exit
                end;
            end;
            ccJgdr:begin
              with jugador[codigoM] do //sólo para jugadores, usar directamente el código de casilla como código de jugador
                if (clanAmigo<>clan) and (hp<>0) then
                begin
                  monstruo_mirando.objetivoAtacado:=codigoM;
                  result:=MC_DE_Direcciones[i];
                  exit
                end;
            end;
            ccRec:revisar[MC_DE_Direcciones[i]]:=false;
          end;
        end;//if y
      end;//if x
    end;//if revisar
  if (monstruo_mirando.mana>=25) and ((monstruo_mirando.PericiasDinamicas and permon__visionVerdadera)<>0) then
  begin
    dec(monstruo_mirando.mana,25);
    DarVisionVerdaderaAMonstruo(monstruo_mirando,8+infmon[monstruo_mirando.tipomonstruo].nivelMonstruo shr 2);
  end;
end;

function TTableroControlado.DireccionEnemigo(monstruo_mirando:TMonstruoS;rango:byte;dirst:TdireccionMonstruo):TdireccionMonstruo;
//Detecta enemigo comenzando desde puntos cercanos, está optimizado
//rango=0 => casillas adyacentes.
//rango=1 => casillas adyacentes y una casila mas lejos...
//SOLO PARA MONSTRUOS, para jugadores usar DirecciónEnemigoJugador
var
    revisar:array[0..7] of bytebool;
    i,px,py:integer;
    x,y:smallint;
    codigoM:word;
    codigocasilla_monstruo_mirando:word;
    tipoAmigo,NivelMonstruoAtacante:byte;
begin
  result:=dirst;//dir previa
  with monstruo_Mirando do
  begin
    with InfMon[TipoMonstruo] do
    begin
      if rango>0 then
        case visibilidad of
          0:begin
            inc(rango,3);
            for i:=0 to 7 do revisar[i]:=false;
            revisar[dir]:=true;
          end;
          1:begin
            inc(rango,2);
            for i:=0 to 7 do revisar[i]:=false;
            revisar[dir]:=true;
            revisar[MC_siguienteDireccion[dir]]:=true;
            revisar[MC_anteriorDireccion[dir]]:=true;
          end;
          2:begin
            inc(rango);
            for i:=0 to 7 do revisar[i]:=true;
            i:=MC_DarVueltaDireccion[dir];
            revisar[i]:=false;
            revisar[MC_siguienteDireccion[i]]:=false;
            revisar[MC_anteriorDireccion[i]]:=false;
          end;
          else
            for i:=0 to 7 do revisar[i]:=true;
        end
      else
        for i:=0 to 7 do revisar[i]:=true;
      NivelMonstruoAtacante:=nivelMonstruo;
      tipoAmigo:=alineacion;
    end;
    px:=coordx;
    py:=coordy;
    objetivoAtacado:=ccVac;
    codigocasilla_monstruo_mirando:=codigo or ccmon;
  end;
  if rango>maxCapacidadVision then rango:=maxCapacidadVision;
  //El monstruo ve en el tablero
  for i:=0 to MC_DE_Limite_Superior[rango] do
    if revisar[MC_DE_Direcciones[i]] then
    begin
      x:=px+MC_DE_deltaX[i];
      if word(x)<=MaxMapaAreaExt then
      begin
        y:=py+MC_DE_deltaY[i];
        if word(y)<=MaxMapaAreaExt then
        begin
          codigoM:=mapaPos[x,y].monrec;
          if codigoM<>ccVac then
          case codigoM and fl_con of //case contenido de la casilla
            ccMon:begin
              with Monstruo[codigoM and fl_cod] do
                if (Infmon[TipoMonstruo].alineacion<>tipoAmigo) and (hp<>0) and (Duenno<>codigocasilla_monstruo_mirando) and (codigoM<>monstruo_mirando.duenno) then
                begin
                //encantamiento
                  if ((Infmon[monstruo_mirando.TipoMonstruo].PericiasMonstruo and permon_Encantamiento)<>0) and (monstruo_mirando.mana>=10) and (duenno=ccSinDuenno) then
                  begin
                    dec(monstruo_mirando.mana,10);
                    duenno:=codigocasilla_monstruo_mirando;
                    monstruo_mirando.duenno:=codigocasilla_monstruo_mirando;
                    monstruo_mirando.dir:=calcularDirExacta(coordx-monstruo_mirando.coordx,coordy-monstruo_mirando.coordy);
                    InformarAnimacionAtaque(monstruo_mirando);
                    EnviarAlAreaMonstruo(Monstruo[codigoM and fl_cod],'S'+char(coordx)+char(coordy)+Sonido_Ataque_Exitoso[16{Hechizo}]);
                    exit;
                  end
                  else
                    //Atacar si es de nivel cercano o es un monstruo con duenno clan o jugador
                    if (abs(Infmon[TipoMonstruo].nivelMonstruo-NivelMonstruoAtacante)<=6) or (duenno and fl_con=ccClan) or (duenno and fl_con=ccJgdr) then
                    begin
                      monstruo_mirando.objetivoAtacado:=codigoM;
                      result:=MC_DE_Direcciones[i];
                      exit;
                    end;
                end;
            end;
            ccJgdr:begin
              with jugador[codigoM] do //sólo para jugadores, usar directamente el código de casilla
              if ((tipoAmigo<>al_neutral) or (comportamiento<comNormal))
                 and (hp<>0) then
                begin
                  result:=MC_DE_Direcciones[i];
                  CambiarObjetivoAtaque(monstruo_mirando,jugador[codigoM]);
                  exit;
                end;
            end;
            ccRec:revisar[MC_DE_Direcciones[i]]:=false;
          end;
        end;//if y
      end;//if x
    end;//if revisar
  if (monstruo_mirando.mana>=25) and ((monstruo_mirando.PericiasDinamicas and permon__visionVerdadera)<>0) then
  begin
    dec(monstruo_mirando.mana,25);
    DarVisionVerdaderaAMonstruo(monstruo_mirando,8+infmon[monstruo_mirando.tipomonstruo].nivelMonstruo shr 2);
  end;
end;

procedure TTableroControlado.EnviarDatosInicialesMapa(codigoJug:word;x,y:byte);
var TipoClima:TClimaAmbiental;
    IntensidadClima:byte;
    PendienteClima:shortint;
    cadena:string;
begin
  if (((TipoClimaGeneral=CL_LLUVIOSO) or (TipoClimaGeneral=CL_LLUVIA_NOCHE)) and longbool(banderasMapa and bmsinLluvia)) or
     ((TipoClimaGeneral=CL_BRUMA) and longbool(banderasMapa and bmsinBruma))
  then
  begin
    if (TipoClimaGeneral=CL_LLUVIA_NOCHE) and longbool(banderasMapa and bmsinLluvia) then
    begin
      TipoClima:=CL_NOCHE;
      IntensidadClima:=255;
    end
    else
    begin
      TipoClima:=CL_NORMAL;
      IntensidadClima:=0;
    end;
    PendienteClima:=0;
  end
  else
  begin
    TipoClima:=TipoClimaGeneral;
    IntensidadClima:=IntensidadClimaGeneral;
    PendienteClima:=PendienteClimaGeneral;
  end;
  cadena:='^'+char(fcodMapa)+char(x)+char(y)+//Datos generales
    char(TipoClima)+char(IntensidadClima)+char(pendienteClima)+//Clima
    char(castillo.clan);//el clan del castillo
  if (castillo.clan<=maxClanesJugadores) then
    with ClanJugadores[castillo.clan] do
      if (MiembrosActivos=0) and (nombre<>'') then
        cadena:=cadena+char(length(nombre))+nombre+b4aStr(PendonClan.color0)+b4aStr(PendonClan.color1)
      else//clan ya está activo o no tiene clan por el nombre=''
        cadena:=cadena+#0
  else//castillo sin clan
    cadena:=cadena+#0;
  sendTextNow(codigoJug,cadena);
end;

procedure TTableroControlado.enviarDatosFinalesMapa(codigoJug:word);
const MaxBolsasXPaquete=240;//hasta 255
var conta,i:integer;
    cad:string;
  procedure DespacharGrupoBolsas;
  begin
    cad[2]:=char(conta);
    sendTextNow(codigoJug,cad);
    conta:=0;
    cad:='&0';
  end;
begin
  //Definir NPJ:
  //Comerciantes:
  cad:='#0';
  conta:=0;
  for i:=IndiceInicioComerciantes to (IndiceInicioComerciantes+N_Comerciantes-1) do
    if i<=MaxMonstruos then
    begin
      cad:=cad+b2aStr(i);
      inc(conta);
    end
    else
      break;
  cad[2]:=char(conta);
  SendTextNow(codigoJug,cad);
  //Puertas:
  //Bolsas:
  conta:=0;
  cad:='&0';
  for i:=0 to maxBolsas do
    with bolsa[i] do
      if tipo<>tbNinguna then
      begin
        cad:=cad+char(posx)+char(posy)+char(tipo);
        inc(conta);
        if conta>=MaxBolsasXPaquete then DespacharGrupoBolsas
      end;
  cad:=cad+'k'+B4aStr(FlagsCalabozo);
  //ojo esto si o si debe ejecutarse para poder informar de los flags
  DespacharGrupoBolsas;
end;

procedure TTableroControlado.enviarSpritesMapa(idConexion:word;x,y:byte);
const MaxMonstruosXPaquete=128;//hasta 255
      MaxJugadoresXPaquete=32;//hasta 255
var i,contaCercanos,contaLejanos:integer;
    infoCercanos,infoLejanos:string;
    vida:byte;
  procedure despacharPaquete(var cadena:string;var contador:integer);
  begin
    if contador>0 then
    begin
      cadena[2]:=char(contador);//2do char: nro de elementos
      SendTextNow(idConexion,cadena);
//      MainForm.mensaje('Longitud enviada:'+intastr(length(cadena))+' Nro elem.:'+intastr(contador));
      contador:=0;
    end;
    delete(cadena,3,maxint);//truncar a 2 chars.
  end;
  procedure EnviarDatosMonstruo(Monstruo_Enviado:TMonstruoS);
  begin
    with Monstruo_Enviado do
    if codMapa=fcodMapa then
      if activo then
        if (abs(x-coordx)>MaxRefrescamientoX) or (abs(y-coordy)>MaxRefrescamientoY) then
        begin
          infoLejanos:=infoLejanos+b2aStr(codigo)+char(codAnime)+B2aStr(banderas);
          inc(contaLejanos);
          if contaLejanos>=MaxMonstruosXPaquete then
            despacharPaquete(infoLejanos,contaLejanos);
        end
        else //enviar todo
        begin
          InfoCercanos:=InfoCercanos+b2aStr(codigo)+char(coordx)+char(coordy)+
            char(dir or (accion shl 4))+char(codAnime)+B2aStr(banderas);
          inc(contaCercanos);
          if contaCercanos>=MaxMonstruosXPaquete then
            despacharPaquete(infoCercanos,contaCercanos);
        end;
  end;
begin
  //Jugadores
  infoCercanos:='J0';
  infoLejanos:='j0';
  contaCercanos:=0;
  contaLejanos:=0;
  for i:=0 to maxJugadores do
    with Jugador[i] do
    if codMapa=fCodMapa then
      if activo then
      begin
        if (hp=0) then vida:=0 else vida:=$80;
        if (abs(x-coordx)>MaxRefrescamientoX) or (abs(y-coordy)>MaxRefrescamientoY) then
        begin
          InfoLejanos:=InfoLejanos+b2aStr(codigo)+
            char(codAnime)+B2aStr(banderas)+char(nivel)+char(codCategoria or (TipoMonstruo shl 4) or vida)+
            char(comportamiento)+char(clan)+char(fcodCara)+char(length(nombreAvatar))+nombreAvatar;
          inc(contaLejanos);
          if contaLejanos>=MaxJugadoresXPaquete then
            despacharPaquete(infoLejanos,contaLejanos);
        end
        else //enviar todo
        begin
          InfoCercanos:=InfoCercanos+b2aStr(codigo)+
            char(coordx)+char(coordy)+char(dir or (accion shl 4))+
            char(codAnime)+B2aStr(banderas)+char(nivel)+char(codCategoria or (TipoMonstruo shl 4) or vida)+
            char(comportamiento)+char(clan)+char(fcodCara)+char(length(nombreAvatar))+nombreAvatar;
          inc(contaCercanos);
          if contaCercanos>=MaxJugadoresXPaquete then
            despacharPaquete(infoCercanos,contaCercanos);
        end;
      end;
  despacharPaquete(infoCercanos,contaCercanos);
  despacharPaquete(infoLejanos,contaLejanos);
  //Monstruos
  InfoCercanos:='M0';
  InfoLejanos:='m0';
  contaCercanos:=0;
  contaLejanos:=0;
  //Del mapa
  for i:=IndiceInicioMonstruos to IndiceFinalMonstruos do
    EnviarDatosMonstruo(Monstruo[i]);
  //Conjurados
  for i:=conta_Monstruos_Definidos to Indice_Maximo_Monstruos do
    if Monstruo[i].codMapa=fcodMapa then
      EnviarDatosMonstruo(Monstruo[i]);
  despacharPaquete(infoCercanos,contaCercanos);
  despacharPaquete(infoLejanos,contaLejanos);
end;

procedure TTableroControlado.MeditarJugador(Rjugador:TjugadorS);
begin
  with Rjugador do
    if (hp<>0) and (banderas and bnParalisis=0) and (comida>0) then
      if (mana<maxMana) and (accion<>aaMeditando) then
      begin
        accion:=aaMeditando;
        AccionAutomatica:=aaNinguna;
        FDestinoX:=coordX;
        FDestinoY:=coordY;
        DeterminarSiEstaCercaDeFogata(Rjugador);
        //Comando de accion exclusivo jugador 176+accion sprite
        SendText(codigo,char((accion and mskAcciones)+176));
        EnviarAlMapa_J(RJugador,char((accion and mskAcciones)+160)+b2aStr(codigo));
      end;
end;

procedure TTableroControlado.DescansarJugador(Rjugador:TjugadorS);
begin
  with Rjugador do
    if (hp<>0) and (accion<>aaDescansando) and ((banderas and bnEnvenenado)=0)
      and (comida>0) then
    begin
      accion:=aaDescansando;
      AccionAutomatica:=aaNinguna;
      FDestinoX:=coordX;
      FDestinoY:=coordY;
      DeterminarSiEstaCercaDeFogata(Rjugador);
      //Comando de accion exclusivo jugador 176+accion sprite
      SendText(codigo,char((accion and mskAcciones)+176));
      EnviarAlMapa_J(RJugador,char((accion and mskAcciones)+160)+b2aStr(codigo));
    end;
end;

procedure TTableroControlado.OcultarJugador(Rjugador:TjugadorS);
var bonoPorBribon:integer;
begin
  with Rjugador do
  if (hp<>0) and ((Banderas and bnParalisis)=0) then
  if Longbool(Pericias and hbCamuflarse) then
  if PuedeRecibirComando(12) then
  begin
    if (CodCategoria=ctBribon) then bonoPorBribon:= 10 else bonoPorBribon:= 0;
    if (random(30)<(DES+bonoPorBribon)) then
    begin
      banderas:=banderas or bnInvisible or bnOcultarse;
      EnviarAlMapa_J(RJugador,'A'+b2aStr(codigo)+char(banderas));
      inicializarTimer(tdInvisible,(nivel+DES+INT+SAB) shr 2+4);
      SendText(codigo,'sO');
    end
    else
      SendText(codigo,'i'+char(i_NoPudisteOcultarte));
  end;
end;

function TTableroControlado.EstaLloviendo(x,y:byte):boolean;
begin
  result:=((TipoClimaGeneral=CL_LLUVIOSO) or (TipoClimaGeneral=CL_LLUVIA_NOCHE)) and
    (IntensidadClimaGeneral>48) and (not longbool(BanderasMapa and bmSinLluvia)) and ((MapaPos[x,y].terbol and ft_Cubierto)=0);
end;

function TTableroControlado.modificadorClima(Infravision:boolean):integer;
//Negativo: menor Defensa, Positivo: mayor defensa
begin
  if longbool(BanderasMapa and bmMapaOscuro) or (TipoClimaGeneral=CL_NOCHE) then
    if Infravision then
      result:=-5//Mapa interno, bono +10 en defensa (atacante con infravision)
    else
      result:=5//Mapa interno, bono +20 defensa
  else
    if (TipoClimaGeneral=CL_BRUMA) and not longbool(BanderasMapa and bmSinBruma) then
      result:=0//Bruma, bono +15 defensa
    else
      result:=-15;//Normal.
end;

function TTableroControlado.BolsaACadena(posx,posy:byte):string;
var i,nroObjetos:integer;
    codBolsa:word;
begin
  result:='';
  codBolsa:=MapaPos[posx,posy].terbol and mskBolsa;
  if codBolsa<=MaxBolsas then
    with Bolsa[codBolsa] do
    begin
      nroObjetos:=0;
      for i:=0 to MAX_ITEMS_BOLSA do
        if Item[i].id>=4 then
        begin
          inc(nroObjetos);
          break;
        end;
      if nroObjetos=0 then
      begin
        mapapos[posx,posy].terBol:=mapapos[posx,posy].terBol or NoExisteBolsa;
        tipo:=tbNinguna;
        exit;
      end;
      for i:=0 to MAX_ITEMS_BOLSA do
        result:=result+char(Item[i].id)+char(Item[i].modificador);
    end;
end;

procedure TTableroControlado.RealizarControlSensores(Rjugador:TjugadorS);
var
  indice,nuevo_Valor:integer;
  posicion:byte;
  procedure ForzarRepelerAvatar;
  var x,y:integer;
  begin
    with RJugador do
    begin//Primero atras, si existe sensor, entonces adelante.
      x:=coordx+MC_avanceX[MC_DarVueltaDireccion[dir]];
      y:=coordy+MC_avanceY[MC_DarVueltaDireccion[dir]];
      limitarExt(x,y);
      if (mapaSensor[x,y]<N_Sensores) or (not lugarVacioXY_PorTipoMonstruo(TipoMonstruo,x,y)) then
      begin
        x:=coordx+MC_avanceX[dir];
        y:=coordy+MC_avanceY[dir];
        limitarExt(x,y);
      end;
      FDestinoX:=x;
      FDestinoY:=y;
    end;
  end;
  procedure RepelerAvatar;
  begin
    if (sensor[indice].flagsSensor and fs_repelerAvatar)<>0 then
      ForzarRepelerAvatar;
  end;
  procedure ConsumirLlave;
  begin
    if (sensor[indice].flagsSensor and fs_consumirLlave)<>0 then
      ConsumirLaLlave(Rjugador,indice,posicion);
  end;
begin
//Aplicable sólo a JUGADORES
  with Rjugador do
  begin
    indice:=mapaSensor[coordx,coordy];
    if indice>=N_Sensores then exit;
    with sensor[indice] do
    begin
      if tipo=tsCBandera then exit;
      posicion:=(sensor[indice].flagsSensor and fs_consumirLlave);
      if TieneLaLlave(llave1,llave2,flagsCalabozo,posicion) then
      begin
        //Sólo fantasmas?
        if (flagsSensor and fs_soloFantasma)<>0 then
          if (RJugador.hp<>0) then
          begin
            RepelerAvatar;
            exit;
          end;
        //Sólo aprendices?
        if (flagsSensor and fs_soloAprendiz)<>0 then
          if (RJugador.nivel>MAX_NIVEL_NEWBIE) then
          begin
            RepelerAvatar;
            exit;
          end;
        //Sólo clan dominante?
        if (flagsSensor and fs_soloClan)<>0 then
          if (RJugador.clan>MaxClanesJugadores) or (RJugador.clan<>Castillo.clan) then
          begin
            RepelerAvatar;
            exit;
          end;
        case tipo of
          tsResurreccion:
            with RJugador do
              if (hp=0) then
              begin
                ConsumirLlave;
                if (dato1<>0) or (dato2<>0) or (dato3<>0) then
                  TeletransportarJugador(RJugador,dato1,dato2,dato3);
                RealizarYNotificarResureccionAvatar(Rjugador,false);
              end;
          tsRegFisica:if conta_Universal and $F=8 then
            with RJugador do
              if (hp<>0) and (hp<maxhp) then
              begin
                ConsumirLlave;
                nuevo_Valor:=hp+(maxhp shr 3)+1;
                if nuevo_Valor>maxhp then hp:=maxhp else hp:=nuevo_Valor;
                SendText(codigo,#255+B2aStr(hp));
              end
              else
                repelerAvatar;
          tsRegPsitica:if conta_Universal and $F=8 then
            with RJugador do
              if (maxmana>0) and (mana<maxmana) and (hp<>0) then
              begin
                ConsumirLlave;
                nuevo_Valor:=mana+(maxmana shr 3)+1;
                if nuevo_Valor>maxMana then mana:=maxMana else mana:=nuevo_Valor;
                SendText(codigo,#254+char(mana));
              end
              else
                repelerAvatar;
          tsPortal:
          begin
            ConsumirLlave;
            TeletransportarJugador(RJugador,dato1,dato2,dato3);
          end;
          tsCambiarObjeto:
            with usando[posicion] do
              //si la llave es un artefacto, o no existe un objeto en esta posición
              if (llave1>=4) or (id<4) then
              begin
                ConsumirLlave;
                id:=dato2;
                modificador:=dato3;
                SendText(codigo,char(208+posicion)+char(id)+char(modificador)+
                  'S'+char(coordX)+char(coordY)+#218);
                RepelerAvatar;
              end
              else
              begin
                SendText(codigo,'i'+char(i_NecesitasManoDerechaLibre));
                ForzarRepelerAvatar;
              end;
          tsFundarClan:
          begin
            if (pericias and hbLiderazgo)<>0 then
              if nivel>MAX_NIVEL_CON_BONO then
                if clan>maxClanesJugadores then//sin clan
                  if FundarClanJugadores(RJugador) then
                  begin
                    ConsumirLlave;
                    if (dato1<>0) or (dato2<>0) or (dato3<>0) then
                      TeletransportarJugador(RJugador,dato1,dato2,dato3);
                    exit;//Para que el avatar no sea repelido
                  end
                  else
                    SendText(codigo,'i'+char(i_NoPuedesCrearOtroClan));
            RepelerAvatar;
          end;
          tsFBandera:
          begin
            ConsumirLlave;
            FijarFlagsCalabozo:=FijarFlagsCalabozo or dato1 or(dato2 shl 8)or(dato3 shl 16)or(dato4 shl 24);
            RepelerAvatar;
          end;
          tsLBandera:
          begin
            ConsumirLlave;
            BorrarFlagsCalabozo:=BorrarFlagsCalabozo or dato1 or(dato2 shl 8)or(dato3 shl 16)or(dato4 shl 24);
            RepelerAvatar;
          end;
        end;//case
      end
      else
        RepelerAvatar;
    end;
  end;//with
end;

function TTableroControlado.RealizarComportamientoFlag(numero:byte):boolean;
const
  MC0_dX:array[0..4] of smallint=(0,0,0,-1,1);
  MC0_dY:array[0..4] of smallint=(0,-1,1,0,0);
var flagActivo,i,j:integer;
begin
  result:=true;
  numero:=numero and $1F;
  flagActivo:=FlagsCalabozo and (1 shl numero);
  case TTipoEfectoFlagS(ComportamientoFlag[numero] and $F) of
    efsDesactiva2x2:
    begin
      if flagActivo=0 then
      begin
        for i:=0 to 1 do
          for j:=0 to 1 do
            if (mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec<ccRec) then
            begin
              result:=false;
              exit;
            end;
        for i:=0 to 1 do
          for j:=0 to 1 do
            if (mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec=ccVac) then
              mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec:=ccRecMov
      end
      else
        for i:=0 to 1 do
          for j:=0 to 1 do
            if (mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec=ccRecMov) then
              mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec:=ccVac;
    end;
    efsDesactivaReja2x2:
    begin
      if flagActivo=0 then
      begin
        for i:=0 to 1 do
          for j:=0 to 1 do
            if (mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec<ccRec) then
            begin
              result:=false;
              exit;
            end;
        for i:=0 to 1 do
          for j:=0 to 1 do
            if (mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec=ccVac) then
              mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec:=ccVacRangoMov
      end
      else
        for i:=0 to 1 do
          for j:=0 to 1 do
            if (mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec=ccVacRangoMov) then
              mapaPos[(i+Dato1Flag[numero])and $FF,(j+Dato2Flag[numero]) and $FF].monRec:=ccVac;
    end;
    efsDesactiva3x3:
    begin
      if flagActivo=0 then
      begin
        for i:=0 to 4 do
          if (mapaPos[(MC0_dX[i]+Dato1Flag[numero])and $FF,(MC0_dY[i]+Dato2Flag[numero]) and $FF].monRec<ccRec) then
          begin
            result:=false;
            exit;
          end;
        for i:=0 to 4 do
          if (mapaPos[(MC0_dX[i]+Dato1Flag[numero])and $FF,(MC0_dY[i]+Dato2Flag[numero]) and $FF].monRec=ccVac) then
            mapaPos[(MC0_dX[i]+Dato1Flag[numero])and $FF,(MC0_dY[i]+Dato2Flag[numero]) and $FF].monRec:=ccRecMov
      end
      else
        for i:=0 to 4 do
          if (mapaPos[(MC0_dX[i]+Dato1Flag[numero])and $FF,(MC0_dY[i]+Dato2Flag[numero]) and $FF].monRec=ccRecMov) then
            mapaPos[(MC0_dX[i]+Dato1Flag[numero])and $FF,(MC0_dY[i]+Dato2Flag[numero]) and $FF].monRec:=ccVac;
    end;
  end;
end;

procedure TTableroControlado.ConsumirLaLlave(RJugador:TjugadorS;indiceDelSensor,indiceDeLaLlave:byte);
begin
  //Consumir la llave
  with Rjugador,sensor[indiceDelSensor] do
    case llave1 of
      1://por flags de mapa
        BorrarFlagsCalabozo:=BorrarFlagsCalabozo or (1 shl (llave2 and $1F));
      2://por honor
        if comportamiento<=comheroe then
          CambiarHonor(Rjugador,comportamiento-llave2);
      0,3:;
    else
      begin
        usando[indiceDeLaLlave]:=ObNuloMDV;
        SendText(codigo,char(208+indiceDeLaLlave)+char(Usando[indiceDeLaLlave].id)+char(Usando[indiceDeLaLlave].modificador));
      end;
    end;
end;

procedure TTableroControlado.CambiarObjetivoAtaque(monstr:TmonstruoS;JugadorAtacante:TjugadorS);
var i:integer;
    tipoAmigo:byte;
begin
  if monstr.objetivoAtacado=ccVac then
  begin
    monstr.objetivoAtacado:=JugadorAtacante.Codigo;
    //convocar a todos sus aliados
    if ((Infmon[monstr.TipoMonstruo].PericiasMonstruo and permon_liderazgo)<>0) and (JugadorAtacante.hp>monstr.hp shr 2) then
    begin
      tipoAmigo:=infmon[monstr.tipomonstruo].alineacion;
      for i:=IndiceInicioMonstruos to IndiceFinalMonstruos do
        with monstruo[i] do
          if activo then
            if objetivoAtacado=ccvac then
              if (infmon[tipomonstruo].alineacion=tipoAmigo) or (duenno=(monstr.codigo or ccmon)) then
                if (abs(coordx-monstr.coordx)<=MaxRangoSeguirEnNormaCuadrado) and (abs(coordy-monstr.coordy)<=MaxRangoSeguirEnNormaCuadrado) then
                  objetivoAtacado:=JugadorAtacante.Codigo;
    end
  end
  else
    if (monstr.objetivoAtacado<=MaxJugadores) then//es codigo de jugador
      if JugadorAtacante.hp<(jugador[monstr.objetivoAtacado].hp shr 1) then
        monstr.objetivoAtacado:=JugadorAtacante.Codigo;
end;


procedure TTableroControlado.SensorClick(RJugador:TjugadorS;x,y:byte);
var flagsAfectados,distancia:integer;
    indiceSensor,indiceUsando:byte;
begin
  indiceSensor:=mapaSensor[x,y];
  if indiceSensor<N_Sensores then
    if ((Rjugador.hp<>0)or(Rjugador.comportamiento>comHeroe)) and (Rjugador.banderas and bnParalisis=0) then
    if RJugador.PuedeRecibirComando(8) then
      with sensor[indiceSensor] do
        if tipo=tsCBandera then
        begin
          //control: solo miembros del clan dominante:
          if ((flagsSensor and fs_soloclan)<>0) and ((RJugador.clan>MaxClanesJugadores) or (RJugador.clan<>Castillo.clan)) then
            exit;
          //control de llave y distancia:
          indiceUsando:=(flagsSensor and fs_consumirLlave);
          if RJugador.TieneLaLlave(llave1,llave2,flagsCalabozo,indiceUsando) then
          begin
            distancia:=round(sqr(RJugador.coordx-x)+sqr(RJugador.coordy-y));
            if (distancia<=5) and (
              ((flagsSensor and fs_repelerAvatar)<>0) or //Si "mayor zona de efecto" o
              ((distancia<=4) and (RJugador.coordy>=(y-1)))//"dentro de menor zona"
              ) then
            begin
              flagsAfectados:=dato1 or(dato2 shl 8)or(dato3 shl 16)or(dato4 shl 24);
              //consumir:
              if (flagsSensor and fs_consumirLlave)<>0 then
              begin
                if (flagsAfectados and FlagsCalabozo)=flagsAfectados then exit;
                ConsumirLaLlave(Rjugador,indiceSensor,indiceUsando);
              end;
              CambiarFlagsCalabozo:=CambiarFlagsCalabozo xor flagsAfectados;
            end;
          end;
        end;
end;

end.

