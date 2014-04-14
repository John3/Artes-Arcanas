(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

//Módulo libre de bibliotecas externas al juego
unit Tablero;
//Del servidor, sin gráficos
interface
uses Demonios,Objetos;

const
  MAX_TOTAL_MAPAS=254;//NO CAMBIAR NUNCA!! 255 mapas disponibles (0 a 254)
  MaxMapaArea=63; //63 (0..63)
  MaxMapaAreaExt=255; //255 64*4
  MaxMapaAreaExt_plus1=MaxMapaAreaExt+1;
  MAX_INTENTOS_POSICIONAMIENTO=20;
  MC_POSICIONAMIENTO_X:array[0..MAX_INTENTOS_POSICIONAMIENTO] of shortint=(
    0,0,1,-1,//Base cruz
    -1,1,-1,1,//Base equix
    0,0,2,-2,//Cruz
    1,-2,-1,2,
    -1,-2,1,2,0{final});
  MC_POSICIONAMIENTO_Y:array[0..MAX_INTENTOS_POSICIONAMIENTO] of shortint=(
    1,-1,0,0,//Base cruz
    -1,1,1,-1,//Base equix
    2,-2,0,0,//Cruz
    2,1,-2,-1,
    2,-1,-2,1,0{final});
  MC_NombresComerciantes:array[0..MAX_TIPOS_COMERCIO] of string[15]=(
    'Minero','Armero','Armero','Armero','Armero','Gran Armero',
    'Gran Armero','Sastre','Herrero','Carpintero','Hostelero','Joyero',
    'Diamantista','Herbalista','Alquimista','Mercader','Hechicero','Clérigo','Marinero',
    'Gran Armero','1','2','3','4','5','6','7','8','-','-','-','-');
  //TERBOL
  maxBolsas=1022; //hasta 1022 ( maximo 1022, 1023 está reservado para indicar que no existe bolsa)
  MAX_ITEMS_BOLSA=MAX_ARTEFACTOS;//NO modificar
  mskBolsa=$3FF;//el campo TerBol and mskBolsa da el codigo_bolsa
  mskTerreno=$FC00;
  NoExisteBolsa=mskBolsa;
  MAX_ID_CLANES_FIJOS=3;//0..3 = 4 clanes fijos

  MAX_OBJETOS_GRAFICOS=511;//NO MODIFICAR!!!
  INFLACION_BASE=128;
  DINERO_GENERADO_CAMPESINO=20;//max 100, min 10.
  TICKS_POR_DIA=57600;//256*25*9
  TICKS_POR_HORA=TICKS_POR_DIA div 24;//256*25*9
  TICKS_POR_MINUTO=TICKS_POR_HORA div 60;//256*25*9
  INICIO_NOCHE=TICKS_POR_DIA shr 1;// /2

  max_Graficos=2047;
  //Para Sprites=and $FF da el codigo_Animacion.

  max_nidos=63;
  max_npc=15;//8
  max_comerciantes=15;//15
  max_sensores=249;//Sensores por mapa

  max_guardianes=1;//0..1 =2

  //flags de objetos del terreno
  fgfx_Espejo=$01;//Muy importante para el servidor
  fgfx_TransparenteNatural=$02;
  fgfx_TransparenteForzado=$04;
  fgfx_Ilusion=$08;
  fgfx_SensibleAFlags=$20;
  fgfx_Antialisado=$40;//si puede ser antialisado
  fgfx_Levitacion=$80;
  fgfx_Transparencia=fgfx_TransparenteForzado or fgfx_TransparenteNatural;

  //Tipos de graficos:
  tg_Normal=0;
  tg_Techo=1;
  tg_Piso=2;
  tg_Puente=3;
  //Flags Descriptores de graficos
  dg_RecuperarArchivo=$1;
  dg_DejarPasarMisiles=$2;
  dg_PermiteAutoTransparencia=$80;//Cuando el jugador pasa el cursor encima del grafico se hace transparente
  dg_EvitarAntialisado=$40;//Evita que el grafico sea antialisado
// Otros
  maxCapacidadVision=7;//7 cuadros de radio [0..6]
  maxCapacidadMatriz=sqr(2*maxCapacidadVision+3)-2;//no modificar!!!

  //Banderas de los mapas
  bmEsMapaSeguro=$0001;//No se caen tus cosas.
  bmEsMapaCombate=$0002;//Todos matan sin perder/ganar honor
  bmMapaDeInterior=$0010;//Cavernas, minas, mazmorras

  bmSinLluvia=$0020;//Nunca llueve
  bmSinBruma=$0040;//Nunca hay bruma.

  bmMapaOscuro=$0080;//siempre de noche;
  bmAbismoVacio=$0100;
  mskSonidosMapas=$F000;//NO modificar
  bmSonidosBosque=$0000;//NO modificar
  bmSonidosDesierto=$1000;//NO modificar
  bmSonidosHielos=$2000;//NO modificar
  bmSonidosMazmorras=$3000;//NO modificar
  bmSonidosInterior=$4000;//NO modificar
  bmSonidosBosqueOscuro=$5000;//NO modificar
  //Para usar
  bmEsMapaMazmorra=bmSinLluvia or bmSinBruma or bmMapaDeInterior or bmMapaOscuro;
  bmEsMapaSinLluviaNiBrumaNiNieve=bmSinLluvia or bmSinBruma;

  //FlagsSensor
  fs_ConsumirLlave=$01;
  fs_RepelerAvatar=$02;
  fs_SoloClan=$10;
  fs_SoloAprendiz=$20;
  fs_SoloFantasma=$40;
  fs_ParteDelCastillo=$80;

type
//Inf. general del tablero
  //Ojo, el control de apagado de fogatas requiere que después de tbFogata
  //sean ubicados los tipos de "bolsa" que pueden "arder"
  //Después de TbFogata los otros tipos de "bolsa" q sirven para descansar como
  //fogatas o puden quemarte.
  //nota: después de cadaver vienen sólo distintos tipos de cadáveres
  TTipoBolsa=(tbNinguna,tbComun,tbTrampaMagica,tblenna,tbCadaver,tbCadaverVerde,tbCadaverEnergia,tbCadaverAvatar,tbCadaverQuemado,tbcenizas,tbFogata,tbCadaverArdiente);//Fogatas al final, no colocar otro tipo de bolsa al final
  TDatosMapa=record//No modificar
    nombre:string[23];
    N_Graficos:word;
    BanderasMapa:word;
    MapaNorte,MapaSur,MapaEste,MapaOeste:byte;
    N_Sensores_Deprecado{deprecado},N_nidos,N_NPC,N_Comerciantes:byte;
    N_Sensores,nousado1,nousado2,nousado3,
    nousado5,nousado6,nousado7,BytesDatosExtendidos:byte;
  end;

  TArreglo32bytes=array[0..31] of byte;
  TArreglo8bytes=array[0..7] of byte;
  TArreglo8Dwords=array[0..7] of integer;
  TDatosMapaExtendido=record//modificar con cautela, nunca deberá pasar de 252 bytes de tamaño.
//alinear a 4Bytes, nunca agregar campos ANTES de los que ya existen
    //Posicion para palabra del retorno
    posx_PalabraRetorno,posy_PalabraRetorno:byte;
    mapa_PalabraRetorno,noUsadoX2:byte;//2bytes, 4 en total
    //Para los flags del mapa
    FlagsCalabozo:integer;//estado inicial de los flags.//4B, 8 en total
    FlagsAutolimpiables:integer;//si se auto inicializa a 0 //12
    ComportamientoFlag:TArreglo32bytes;//efecto en servidor(4 bits bajos) y cliente(4 bits altos) //32 bytes, 44 en total
    Dato1Flag:TArreglo32bytes;//32 bytes, 76 en total
    Dato2Flag:TArreglo32bytes;//32 bytes, 108 en total
    //Extension no implementada...:(
    ComportamientoDetector:TArreglo8bytes;//8B 116 Total
    Dato1Detector:TArreglo8bytes;//8B 124 Total
    Dato2Detector:TArreglo8bytes;//8B 132 Total
    FlagsADetectar:TArreglo8Dwords;//Define cuales flags se tomarán en cuenta//32B 164 Total
    EstadosADetectar:TArreglo8Dwords;//Define el estado esperado de los flags//32B 196 Total
  end;
  TTipoSensor=(tsRegFisica,tsRegPsitica,tsResurreccion,tsPortal,tsCambiarObjeto,
  tsFBandera,tsLBandera,tsCBandera,tsNOUSADO,tsFundarClan);
  //7 comportamientos, el bit $8 indica que el comportamiento está temporalmente desactivado.
  TTipoEfectoFlagS=(efsNinguno,efsDesactiva2x2,efsDesactiva3x3,efsDesactivaReja2x2);
  TTipoEfectoFlagC=(efcNinguno,efcPuerta,efcPorticullis,efcPalanca);
  TSensor=record
    Tipo:TTipoSensor;
    posx,posy:byte;
    llave1,llave2:byte;
    dato1,dato2,dato3:byte;
    dato4,flagsSensor:byte;
  end;
  TTextoSensor=string[127];
  TTextoComerciante=string[79];
  TListaTextoSensor=array[0..max_sensores] of TTextoSensor;
  PListaTextoSensor=^TListaTextoSensor;
  TListaTextoComerciante=array[0..max_comerciantes] of TTextoComerciante;
  PListaTextoComerciante=^TListaTextoComerciante;
{  TNPC_mapa=record //Será objeto
    Tipo:byte;
    posx,posy,dato1:byte;
    cantidad:array[0..11] of byte;
    item:array[0..11] of Tartefacto;
    texto:string[111];
  end;}
  TComerciante_mapa=record
    //Generales:
    Tipo:byte;
    posx,posy,
    MonstruoComerciante:byte;
    item:TInventarioArtefactos;//Objetos
    inflacion:array[0..MAX_ARTEFACTOS] of byte;//0= 255 objetos, 255=0 objetos
    //precio de compra:(128+inflacion)*precio shr 7
    //precio de venta:(128+inflacion)*precio shr 9
  end;
(*
  Tipo=tipo NPC
  dato1=subtipo
  dato2=estado
  dato3=flags por raza.
  items=nro disponible.
*)
  const MskCodigoGrafico=$03FF;
  const MskFlagInverso=$0400;
  const DzSensibilidadFlags=11;
  type

  TGrafico=record
    codigoFlags:word;
    posx,posy:byte;
    flagsGrafico:byte;
    sub_z:byte;
  end;

  TGraficosMapa=array[0..max_graficos] of Tgrafico;
  PGraficosMapa=^TGraficosMapa;


  TNidoCriaturas=record
    tipo:byte; //tipo de criatura;
    posx,posy:byte;
    cantidad:byte;//control de cantidad de criaturas.
  end;

  TCasMapa=record
             terBol:word;//terreno y bolsas
{
  w1 and $F800=flags del tipo de terreno.
  w1 and $07FF<$07FF then exite bolsa o cadaver.
  w1 and $07FF=codigo_bolsa/cadaver.}
             monRec:word;//monstruos y recursos
           end;
  TBolso=record
           tipo:TTipoBolsa;
           nousado:byte;
           posx,posy:byte;
           Item:TInventarioArtefactos;
         end;
  TGrupoBolsas=array[0..maxBolsas] of Tbolso;
  PGrupoBolsas=^TGrupoBolsas;

  TLineaMapaAreaPos=array[0..MaxMapaAreaExt] of TCasMapa;
  PLineaMapaAreaPos=^TLineaMapaAreaPos;
  TMapaAreaPos=array[0..MaxMapaAreaExt] of PLineaMapaAreaPos;
  PMapaAreaPos=^TMapaAreaPos;

  TLineaMapaAreaSensor=array[0..MaxMapaAreaExt] of byte;
  PLineaMapaAreaSensor=^TLineaMapaAreaSensor;
  TMapaAreaSensor=array[0..MaxMapaAreaExt] of PLineaMapaAreaSensor;
  PMapaAreaSensor=^TMapaAreaSensor;



//  TmapaAreaSimple=array[0..MaxMapaArea,0..MaxMapaArea] of byte;

  TCadena23=string[23];
  TIndicadorCasillasOcupadas=array[0..7] of byte;

  TDescriptorGrafico=packed Record
    posx,posy:smallint;
    casillaOcupada,casillaOculta:TIndicadorCasillasOcupadas;
    alinY,NoUsado0:byte;
    tipo:byte;
    sub_valorZ:byte;
    Nousado1:word;
    RecursoEfecto:byte;
    FlagsDesGrafico:byte;
    posx_r:smallint;
  end;

  TNombresGraficos=array[0..MAX_OBJETOS_GRAFICOS] of Tcadena23;
  PNombresGraficos=^TNombresGraficos;
  TDescriptoresGraficos=array[0..MAX_OBJETOS_GRAFICOS] of TDescriptorGrafico;
  TArchivoGraficos=record
    Nombres:TNombresGraficos;
    Datos:TDescriptoresGraficos;
    CheckSum:integer;
  end;

  TCastillo=record
    Dinero:Integer;//Guardado en el castillo
    Clan:byte;//Id del clan
    Impuestos:byte;//1..DINERO_GENERADO_CAMPESINO-1.
    HP:Word;//0..50000 hp
    banderasGuardian:integer;//En flags.
  end;

  TLineaMapaTiles=array[0..MaxMapaAreaExt] of byte;
  PLineaMapaTiles=^TLineaMapaTiles;
  TMapaTiles=array[0..MaxMapaAreaExt] of PLineaMapaTiles;
  PMapaTiles=^TMapaTiles;

  TTablero=Class(TObject)
  protected
    //Datos del mapa:
    fCodMapa:byte;
    N_Sensores,N_nidos,
    N_Comerciantes:byte;
    N_Graficos:word;
    BolsaLibre:word;
    bolsa:PGrupoBolsas;
    mapaPos:PMapaAreaPos;//Tablero de verdad
    mapaSensor:PMapaAreaSensor;//Tablero de sensores
    Sensor:array[0..max_sensores] of Tsensor;
    Nido:array[0..max_nidos] of TNidoCriaturas;
//    NPC:array[0..max_npc] of TNPC_mapa;//Serán objetos NPC con una conversación.
    function lugarVacioXY(elemento:TmonstruoS;x,y:byte):bytebool;
    function lugarVacioXY_PorTipoMonstruo(TipoDeMonstruo,x,y:byte):bytebool;
    function lugarVacioVerificarFronterasXY(elemento:TmonstruoS;x,y:smallint):bytebool;
    function lugarVacioAlFrente(elemento:TmonstruoS):bytebool;
    function getMonRecXY(x,y:smallint):word;
  public
    { Public declarations }
    nombreMapa:string[23];
    castillo:Tcastillo;
    MapaNorte,MapaSur,MapaEste,MapaOeste:byte;
    FlagsCalabozo:Integer;//modificados en el juego
    CambiarFlagsCalabozo:Integer;//para aplicar xor
    FijarFlagsCalabozo:Integer;//para fijar
    BorrarFlagsCalabozo:Integer;//para borrar
    FlagsAutolimpiables:Integer;//aquellos que vuelven a 0 cada turno.
    ComportamientoFlag:TArreglo32bytes;//32 bytes, 44 en total
    Dato1Flag:TArreglo32bytes;//32 bytes, 76 en total
    Dato2Flag:TArreglo32bytes;//32 bytes, 108 en total
    Comerciante:array[0..max_comerciantes] of TComerciante_Mapa;
    CodigoMonstruoGuardian:array[0..max_guardianes] of word;
    BanderasMapa:word;//estáticas
    Posx_PalabraRetorno,Posy_PalabraRetorno,
    Mapa_PalabraRetorno:byte;
    destructor Destroy; override;//tiene que estar en el area protected y no en private!!!    
    property NumeroDeComerciantes:byte read N_Comerciantes;
    constructor create(codMapa:integer);
//Recupera todos los datos y crea el terreno de tiles.
//    procedure LoadFromFile(const FileName:string);
    function RecuperarMapa(codigoMapa:byte;ListaTextoSensor:PListaTextoSensor;ListaTextoComerciante:PListaTextoComerciante;MapaTiles:PMapaTiles;Grafico:PGraficosMapa):boolean;
//SOLO ALCUNOS METODOS PARA EL CLIENTE Y PARA EL SERVIDOR
    function ApuntarCasilla(x,y:integer;preciso:boolean):word;
    function PuedeUsarHerramienta(jug:TjugadorS;indArt:byte; var Reparar:boolean):byte;
    function ExisteObstaculo(xOrigen,yOrigen,xDestino,yDestino:byte):boolean;
    function PosicionMonstruoValidaXY(elemento:TmonstruoS;x,y:byte):bytebool;
    function ObtenerRecursoAlFrente(jug:TjugadorS):byte;
    function getCodBolsaVerificarFronterasXY(x,y:smallint):integer;
    function AlFrenteUnBuenLugarParaFogatas(jug:TjugadorS):bytebool;
    function PuedeMoverseAEsteLugar(elemento:TmonstruoS;x,y:byte):bytebool;
    procedure DeterminarFlagDeDireccionParaMovimiento(RJugador:TjugadorS;dirMovimiento:TDireccionMonstruo);
    function BuscarDireccionLibre(RJugador:TjugadorS;dirMovimiento:TDireccionMonstruo):TDireccionMonstruo;
    procedure DeterminarSiEstaCercaDeFogata(jug:TjugadorS);
  end;
  procedure limitar(var x,y:integer);//A maxMapaArea
  procedure limitarExt(var x,y:integer);// MaxMapaAreaExt
  procedure InicializarConstantesTablero(const directorio:string;NomGra:PNombresGraficos);
  function EnLimites(const x,y:integer):boolean;
  function EnLimites_MenosFronteras(const x,y:integer):boolean;
  function TicksDelServidorAHoraEnCadena(ticks:integer):string;

  var InfGra:TDescriptoresGraficos;
      MC_DE_Direcciones:array[0..maxCapacidadMatriz] of TdireccionMonstruo;
      MC_DE_DeltaX:array[0..maxCapacidadMatriz] of integer;
      MC_DE_DeltaY:array[0..maxCapacidadMatriz] of integer;
      MC_DE_Limite_Superior:array[0..maxCapacidadvision] of integer;

implementation

var
// definidos por: InicializarColeccionPosicionesGraficos
  DirectorioRaiz:String;

procedure limitar(var x,y:integer);
begin
  if x<0 then x:=0
  else
    if x>MaxMapaArea then x:=MaxMapaArea;
  if y<0 then y:=0
  else
    if y>MaxMapaArea then y:=MaxMapaArea;
end;

procedure limitarExt(var x,y:integer);
begin
  if x<0 then x:=0
  else
    if x>MaxMapaAreaExt then x:=MaxMapaAreaExt;
  if y<0 then y:=0
  else
    if y>MaxMapaAreaExt then y:=MaxMapaAreaExt;
end;

function EnLimites(const x,y:integer):boolean;
begin
  result:=(x>=0) and (y>=0) and (x<=MaxMapaAreaExt) and (y<=MaxMapaAreaExt);
end;

function EnLimites_MenosFronteras(const x,y:integer):boolean;
//No incluye casillas frontera
begin
  result:=(x>=1) and (y>=1) and (x<MaxMapaAreaExt) and (y<MaxMapaAreaExt);
end;

function TicksDelServidorAHoraEnCadena(ticks:integer):string;
var horas,minutos:integer;
begin
  horas:=((ticks div ticks_por_hora)+6) mod 24;
  ticks:=ticks mod ticks_por_hora;
  minutos:=ticks div ticks_por_minuto;
  ticks:=horas mod 12;
  if ticks=0 then ticks:=12;
  result:=intastr(ticks)+':';
  if minutos>9 then
    result:=result+intastr(minutos)
  else
    result:=result+'0'+intastr(minutos);
  case horas of
    5..6:result:=result+' (madrugada)';
    18:result:=result+' (ocaso)';
    0:result:=result+' (media noche)';
    12:result:=result+' (medio día)';
    7..11:result:=result+' (mañana)';
    13..17:result:=result+' (tarde)';
    else
      result:=result+' (noche)'
  end;
end;

procedure InicializarConstantesTablero(const directorio:string;NomGra:PNombresGraficos);
  var f:File;{TArchivoGraficos;}
//      InfGraficos:TArchivoGraficos;
      i,j,contador,checksum:integer;
begin
  //Inicializa NomGra e InfGra.
  //Datos de los elementos gráficos
  DirectorioRaiz:=directorio;
  assignfile(f,directorio+'oc.b');
  filemode:=0;
  reset(f,1);
{ TArchivoGraficos=record
    Nombres:TNombresGraficos;
    Datos:TDescriptoresGraficos;
    CheckSum:integer;
  end;}
//  read(f,InfGraficos);
    //Primero leer nombres
    if NomGra<>nil then
      blockread(f,NomGra^,SizeOf(TNombresGraficos))
    else
      seek(f,SizeOf(TNombresGraficos));
    blockread(f,InfGra,SizeOf(TDescriptoresGraficos));
    blockread(f,checksum,sizeOf(checksum));
  closefile(f);
{  if checksum<>DeCriptico(InfGra,sizeOf(InfGra)) then
    Halt(1); //Error en archivo!!}

//Antiguo, recuperación por Tipo de Archivo.
{if InfGraficos.checksum<>DeCriptico(InfGraficos.datos,sizeOf(InfGraficos.datos)) then
    Halt(1); //Error en archivo!!
//para recuperar los nombres de los graficos.
  if NomGra<>nil then
    NomGra^:=InfGraficos.nombres;//Ojo que es asignacion de contenido no solo puntero
//  InfGra:=InfGraficos.datos;
}
//Matriz de direcciones
//***********************
  for i:=0 to maxCapacidadVision do
    MC_DE_Limite_Superior[i]:=sqr(2*i+3)-2;
// Optimiza la función de encontrar criaturas enemigas.
  contador:=0;
  for i:=0 to maxCapacidadVision do
  begin
    for j:=-1-i to 1+i do
    begin
      MC_DE_Direcciones[contador]:=calcularDirExacta(j,-i-1);
      MC_DE_DeltaX[contador]:=j;
      MC_DE_DeltaY[contador]:=-i-1;
      inc(contador);
    end;
    for j:=-i to i do
    begin
      MC_DE_Direcciones[contador]:=calcularDirExacta(i+1,j);
      MC_DE_DeltaX[contador]:=i+1;
      MC_DE_DeltaY[contador]:=j;
      inc(contador);
    end;
    for j:=1+i downto -1-i do
    begin
      MC_DE_Direcciones[contador]:=calcularDirExacta(j,i+1);
      MC_DE_DeltaX[contador]:=j;
      MC_DE_DeltaY[contador]:=i+1;
      inc(contador);
    end;
    for j:=i downto -i do
    begin
      MC_DE_Direcciones[contador]:=calcularDirExacta(-i-1,j);
      MC_DE_DeltaX[contador]:=-i-1;
      MC_DE_DeltaY[contador]:=j;
      inc(contador);
    end;
  end;
end;

//****************************************************************************************
//**********            TTablero
constructor TTablero.create(codMapa:integer);
var i:integer;
begin
  inherited create;
  for i:=0 to max_guardianes do
    CodigoMonstruoGuardian[i]:=ccVac;//sin monstruo guardian
  fcodMapa:=codMapa;
  nombreMapa:='';
  bolsa:=nil;
  getmem(mapaPos,sizeof(TMapaAreaPos));
  for i:=0 to MaxMapaAreaExt do
    getmem(mapaPos[i],sizeof(TLineaMapaAreaPos));
  getmem(mapaSensor,sizeof(TMapaAreaSensor));
  for i:=0 to MaxMapaAreaExt do
    getmem(mapaSensor[i],sizeof(TLineaMapaAreaSensor));
end;

destructor TTablero.Destroy;
var i:integer;
begin
  if Bolsa<>nil then
    freeMem(Bolsa);
  for i:=0 to MaxMapaAreaExt do
    freeMem(mapaSensor[i]);
  freeMem(mapaSensor);
  for i:=0 to MaxMapaAreaExt do
    freeMem(mapaPos[i]);
  freeMem(mapaPos);
  inherited destroy;
end;

function TTablero.RecuperarMapa(codigoMapa:byte;ListaTextoSensor:PListaTextoSensor;ListaTextoComerciante:PListaTextoComerciante;MapaTiles:PMapaTiles;Grafico:PGraficosMapa):boolean;
type
    TmapaCompreso=array[0..MaxMapaArea,0..MaxMapaArea] of byte;
var
    i,j,code:integer;
    f:file;
    //auxiliares temporales
    DatosMapa:TDatosMapa;
    DatosMapaExt:TDatosMapaExtendido;
    Mapa:TmapaCompreso;
  procedure CrearMapaDeSensores;
  var x,y:integer;
  begin
    for y:=0 to MaxMapaAreaExt do
      for x:=0 to MaxMapaAreaExt do
        mapaSensor[x,y]:=Ninguno;
    for x:=0 to N_Sensores-1 do
      with Sensor[x] do
        mapaSensor[posx,posy]:=x;
  end;
  function getTerreno(x,y:integer):integer;
  begin
    limitar(x,y);
    result:=Mapa[x,y];
  end;
  procedure ActualizarTableroTiles;
  var terreno,i,j,a,b:integer;
      s,e,n:integer;
    function NoEsPiso(x,y:integer):bytebool;
    //Para que cuevas(abismos) y montañas se vean mejor al asignar terreno a las esquinas
    begin
      limitar(x,y);
      x:=Mapa[x,y];
      result:=(x<=16) or (x>=28);
    end;
  begin
    for j:=0 to MaxMapaArea do
      for i:=0 to MaxMapaArea do
      begin
        terreno:=mapa[i,j];
  {      if (terreno<20) or (terreno>26) then}
        begin
          //Pedazo superior izquierdo
          n:=terreno;
          if((getTerreno(i-1,j)=getTerreno(i-1,j-1)) and
            (getTerreno(i,j-1)<>getTerreno(i,j)))or
            ((getTerreno(i,j-1)=getTerreno(i-1,j-1)) and
            (getTerreno(i-1,j)<>getTerreno(i,j))) then
            begin
              if NoEsPiso(i-1,j-1) or (getTerreno(i-1,j)=getTerreno(i,j-1)) then
                n:=getTerreno(i-1,j-1)
            end
            else
              if (getTerreno(i-1,j)=getTerreno(i,j-1)) and
                ((getTerreno(i,j)<getTerreno(i-1,j)) or
                (getTerreno(i,j)<>getTerreno(i-1,j-1))) then
                  n:=getTerreno(i-1,j);
          //Pedazo superior derecho
          e:=terreno;
          if((getTerreno(i+1,j)=getTerreno(i+1,j-1)) and
            (getTerreno(i,j-1)<>getTerreno(i,j)))or
            ((getTerreno(i,j-1)=getTerreno(i+1,j-1)) and
            (getTerreno(i+1,j)<>getTerreno(i,j))) then
            begin
              if NoEsPiso(i+1,j-1) or (getTerreno(i+1,j)=getTerreno(i,j-1)) then
                e:=getTerreno(i+1,j-1)
            end
          else
            if (getTerreno(i+1,j)=getTerreno(i,j-1)) and
               ((getTerreno(i,j)<getTerreno(i+1,j)) or
               (getTerreno(i,j)<>getTerreno(i+1,j-1)))then
                 e:=getTerreno(i+1,j);
          //Pedazo inferior izquierdo
          s:=terreno;
          if((getTerreno(i-1,j)=getTerreno(i-1,j+1)) and
            (getTerreno(i,j+1)<>getTerreno(i,j)))or
            ((getTerreno(i,j+1)=getTerreno(i-1,j+1)) and
            (getTerreno(i-1,j)<>getTerreno(i,j))) then
            begin
              if noEsPiso(i-1,j+1) or (getTerreno(i-1,j)=getTerreno(i,j+1))then
                s:=getTerreno(i-1,j+1)
            end
          else
            if (getTerreno(i-1,j)=getTerreno(i,j+1)) and
               ((getTerreno(i,j)<getTerreno(i-1,j)) or
               (getTerreno(i,j)<>getTerreno(i-1,j+1)))then
                 s:=getTerreno(i-1,j);
          for a:=0 to 3 do
            for b:=0 to 3 do
            begin
              code:=terreno;
              //Control de pisos de interior:
              if (a+b<=1) then  //pedazo superior izquierdo
                code:=n
              else if (a-b>=3) then //pedazo superior derecho
                     code:=e
                 else if (b-a>=3) then //pedazo inferior izquierdo
                          code:=s;
  {            if (code>=20) and (code<=26) then
                code:=terreno;}
//              mapaTiles[i*4+a,j*4+b]:=(mapaTiles[i*4+a,j*4+b] and $E0) or (code and $1F);
              mapaPos[i*4+a,j*4+b].terBol:=code;
            end;
        end
      end
  end;
  procedure crearMapaLogico;
  var i,j,n:integer;
      k,x,y,p_x,p_y:integer;
      codigoDelGrafico:integer;
      reflejado:bytebool;
      TipoContenido:word;
  begin
  //Cambiar de codigos de tiles a grupos de terreno:
    for j:=0 to MaxMapaAreaExt do
      for i:=0 to MaxMapaAreaExt do
      begin
        //Corrector de tipo de terreno para mejorar relación interfaz-tablero:
        if (j<MaxMapaAreaExt) and (i<MaxMapaAreaExt) then//necesario!!
          if ((j and $3)=3) and ((i and $3)=3) then
            if (mapaPos[i+1,j].terBol=mapaPos[i+1,j+1].terBol) and (mapaPos[i+1,j].terBol=mapaPos[i,j+1].terBol) then
              mapaPos[i,j].terBol:=mapaPos[i+1,j].terBol;
        if (((j and $3)=1) and ((i and $3)=0)) or (((j and $3)=0) and ((i and $3)=1)) then
          mapaPos[i,j].terBol:=mapaPos[i+1,j+1].terBol;
        mapaPos[i,j].monRec:=ccVac;//inicializar a vacio;
        //obtener flags.
        case mapaPos[i,j].terBol of
          0:begin
            n:=0;//ningún monstruo pasa por aqui
            if (banderasMapa and bmAbismoVacio)=0 then
              mapaPos[i,j].monRec:=ccRec;//inicializar a ocupado.
          end;
          3:n:=ft_TerrenoSolido or ft_TierraSalvaje;
          13..15:n:=ft_TierraSalvaje or ft_Cubierto;
          17..24:n:=ft_TerrenoSolido or ft_ZonaCivilizada;
          25..27:n:=ft_TerrenoSolido;
          28:n:=0;//los monstruos no pasan por aqui
          29:n:=ft_fuego;
          31:n:=ft_agua;
          30:n:=ft_agua or ft_TierraSalvaje;
        else
          n:=ft_TierraSalvaje;
        end;
        mapaPos[i,j].terBol:=n or NoExisteBolsa;
      end;
  //Inicializar posiciones ocupadas por Edificios
    for k:=0 to n_graficos-1 do
    begin
      //Modificar mapa de tiles:
      codigoDelGrafico:=grafico[k].codigoFlags and MskCodigoGrafico;
      if codigoDelGrafico<=MAX_OBJETOS_GRAFICOS then
        with InfGra[codigoDelGrafico] do
        begin
          if bytebool(grafico[k].flagsGrafico and fgfx_Ilusion) then continue;
          x:=grafico[k].posx-4;
          y:=grafico[k].posy-aliny;
          reflejado:=bytebool(grafico[k].flagsGrafico and fgfx_Espejo);
          if tipo<>tg_Techo then
          begin
            if (FlagsDesGrafico and dg_DejarPasarMisiles)=0 then
              TipoContenido:=ccRec or RecursoEfecto
            else//tipo piso: Dejar pasar flechas y conjuros.
              TipoContenido:=ccVacRango or RecursoEfecto;
            if tipo=tg_Puente then
              for i:=0 to 7 do//Definir areas para caminos
              begin
                if reflejado then
                  p_x:=x+7-i
                else
                  p_x:=x+i;
                for j:=0 to 7 do
                begin
                  p_y:=y+j;
                  if enlimites(p_x,p_y) then
                    if bytebool(casillaOcupada[j] and mascarB[i]) and ((MapaPos[p_x,P_y].terbol and mskTerreno)<>mskTerreno_Pisos) then
                      MapaPos[p_x,P_y].terbol:=(MapaPos[p_x,P_y].terbol and mskBolsa) or mskTerreno_Pisos;
                end;
              end
            else//tipos normal y piso/terreno
              for i:=0 to 7 do//Definir tipos de recursos
              begin
                if reflejado then
                  p_x:=x+7-i
                else
                  p_x:=x+i;
                for j:=0 to 7 do
                begin
                  p_y:=y+j;
                  if enlimites(p_x,p_y) then
                    if bytebool(casillaOcupada[j] and mascarB[i]) then
                      if (longbool(MapaPos[p_x,P_y].terbol and mskTerreno)) then
                      begin
                        if (MapaPos[p_x,P_y].monRec and $FF00)<>ccRec then//ccRec tiene prioridad
                          MapaPos[p_x,P_y].monRec:=TipoContenido
                        else
                          if (MapaPos[p_x,P_y].monRec)=ccRec then
                            MapaPos[p_x,P_y].monRec:=ccRec or RecursoEfecto;
                      end
                      else//tipo de terreno=0, no permitir paso de conjuros ni municiones
                        MapaPos[p_x,P_y].monRec:=ccRec or RecursoEfecto;
                end;
              end;
          end
          else//Definir areas cubiertas por techos.
            for i:=0 to 7 do
            begin
              if reflejado then
                p_x:=x+7-i
              else
                p_x:=x+i;
              for j:=0 to 7 do
              begin
                p_y:=y+j;
                if enlimites(p_x,p_y) then
                  if bytebool(casillaOcupada[j] and mascarB[i]) then
                    MapaPos[p_x,P_y].terbol:=
                      MapaPos[p_x,P_y].terbol or ft_Cubierto;
              end;
            end;
        end;//with
    end;
    //Asegurar que la referencias a bolsas sea nil:
    Bolsa:=nil;
  end;

begin
  {$I-}
  assignFile(f,DirectorioRaiz+intaStr(codigoMapa)+'.mpv');
  fileMode:=0;
  reset(f,1);
  blockread(f,DatosMapa,SizeOf(DatosMapa));
//Inicializar variables globales del mapa:
  N_Graficos:=DatosMapa.N_Graficos;
  N_Sensores:=DatosMapa.N_Sensores;
  N_nidos:=DatosMapa.N_nidos;
//  N_NPC:=DatosMapa.N_NPC;
  N_Comerciantes:=DatosMapa.N_Comerciantes;
  nombreMapa:=DatosMapa.nombre;
  BanderasMapa:=DatosMapa.BanderasMapa;
  MapaNorte:=DatosMapa.MapaNorte;
  MapaSur:=DatosMapa.MapaSur;
  MapaEste:=DatosMapa.MapaEste;
  MapaOeste:=DatosMapa.MapaOeste;
//El mapa del terreno 64x64, expandido por el código a 256x256:
  blockread(f,Mapa,SizeOf(Mapa));
//Leer con bucles:
  //Loops de contenido
//Nr_Graficos,Nr_Sensores,Nr_nidos,Nr_NPC:byte;
  for i:=0 to n_graficos-1 do
    blockread(f,Grafico[i],SizeOf(Grafico[i]));
  for i:=0 to N_Sensores-1 do
  begin
    blockread(f,Sensor[i],SizeOf(Sensor[i]));
    if ListaTextoSensor<>nil then
      blockread(f,ListaTextoSensor[i],SizeOf(ListaTextoSensor[i]))
    else
      seek(f,filePos(f)+SizeOf(TTextoSensor));
  end;
  for i:=0 to N_nidos-1 do
    blockread(f,Nido[i],SizeOf(Nido[i]));
  for i:=0 to N_comerciantes-1 do
  begin
    blockread(f,Comerciante[i],SizeOf(Comerciante[i]));
    if ListaTextoComerciante<>nil then
      blockread(f,ListaTextoComerciante[i],SizeOf(ListaTextoComerciante[i]))
    else
      seek(f,filePos(f)+SizeOf(TTextoComerciante));
  end;
{  for i:=0 to N_npc-1 do
    blockread(f,Npc[i],SizeOf(Npc[i]));}
  fillchar(DatosMapaExt,sizeOf(DatosMapaExt),0);
  if DatosMapa.BytesDatosExtendidos>0 then
  begin
    i:=sizeOf(DatosMapaExt);
    if i>DatosMapa.BytesDatosExtendidos then i:=DatosMapa.BytesDatosExtendidos;
    blockread(f,DatosMapaExt,i);
  end;
  posX_PalabraRetorno:=DatosMapaExt.posX_PalabraRetorno;
  posY_PalabraRetorno:=DatosMapaExt.posY_PalabraRetorno;
  Mapa_PalabraRetorno:=DatosMapaExt.mapa_PalabraRetorno;
  FlagsCalabozo:=DatosMapaExt.FlagsCalabozo;
  FlagsAutolimpiables:=DatosMapaExt.FlagsAutolimpiables;
  ComportamientoFlag:=DatosMapaExt.ComportamientoFlag;
  Dato1Flag:=DatosMapaExt.Dato1Flag;
  Dato2Flag:=DatosMapaExt.Dato2Flag;

  closeFile(f);
  {$I+}
  result:=ioresult=0;
  result:=result and (DatosMapa.N_Sensores_Deprecado=0);
  //  A partir del mapa compreso: "mapa" llenamos datos iniciales par
  //Mapapos[x,y].terBol, que indicará como serán los tiles y tipo de terreno.
  ActualizarTableroTiles;
  CrearMapaDeSensores;
  //Antes de crear el mapa lógico salvar las casillas de tiles
  if MapaTiles<>nil then
    for j:=0 to MaxMapaAreaExt do
      for i:=0 to MaxMapaAreaExt do
        MapaTiles[i,j]:=Mapapos[i,j].terBol;
  CrearMapaLogico;
end;

function TTablero.PosicionMonstruoValidaXY(elemento:TmonstruoS;x,y:byte):bytebool;
begin
  result:=(InfMon[elemento.TipoMonstruo].Terreno and mapaPos[x,y].terBol)<>0;
end;

function TTablero.PuedeMoverseAEsteLugar(elemento:TmonstruoS;x,y:byte):bytebool;
var c,nx,ny:smallint;
begin
  c:=0;
  nx:=x;
  ny:=y;
  while not lugarVacioVerificarFronterasXY(elemento,nx,ny) do
  begin
    if (c=MAX_INTENTOS_POSICIONAMIENTO) then
    begin
      result:=false;
      exit;
    end;
    nx:=x+MC_POSICIONAMIENTO_X[c];
    ny:=y+MC_POSICIONAMIENTO_Y[c];
    inc(c);
  end;
  result:=true;
end;

function TTablero.lugarVacioXY(elemento:TmonstruoS;x,y:byte):bytebool;
begin
  //Comprobar lugar vacio, verdadero si es distinto de 0, es decir que existe un bicho ahi.
  if mapaPos[x,y].monRec=ccVac then
  //comprobar tipo de terreno, si es "0" no concuerda con el terreno
    result:=(InfMon[elemento.TipoMonstruo].Terreno and mapaPos[x,y].terBol)<>0
  else
    result:=false;
end;

function TTablero.lugarVacioXY_PorTipoMonstruo(TipoDeMonstruo,x,y:byte):bytebool;
begin
  //Comprobar lugar vacio, verdadero si es distinto de 0, es decir que existe un bicho ahi.
  if mapaPos[x,y].monRec=ccVac then
  //comprobar tipo de terreno, si es "0" no concuerda con el terreno
    result:=(InfMon[TipoDeMonstruo].Terreno and mapaPos[x,y].terBol)<>0
  else
    result:=false;
end;

function TTablero.lugarVacioVerificarFronterasXY(elemento:TmonstruoS;x,y:smallint):bytebool;
begin
  result:=(word(x)<=MaxMapaAreaExt) and (word(y)<=MaxMapaAreaExt) and LugarVacioXY(elemento,x,y);
end;

procedure TTablero.DeterminarFlagDeDireccionParaMovimiento(RJugador:TjugadorS;dirMovimiento:TDireccionMonstruo);
//Determina si es mejor moverse a derecha o izquierda, no considera moverse adelante
//dirMovimiento debe estar en los limites correctos: 0..7
var i,intentos:integer;
    deltaX,deltaY:integer;
    flagDeDireccion:byte;
    dirMov:TDireccionMonstruo;
begin
  flagDeDireccion:=1;
  deltaX:=RJugador.fdestinox-RJugador.coordx;
  deltaY:=RJugador.fdestinoy-RJugador.coordy;
  case dirMovimiento of
    dsNorte:
      if deltaX>0 then flagDeDireccion:=0;
    dsNorEste:
      if deltaX>abs(deltaY) then flagDeDireccion:=0;
    dsEste:
      if deltaY>0 then flagDeDireccion:=0;
    dsSudEste:
      if deltaY>deltaX then flagDeDireccion:=0;
    dsSud:
      if deltaX<0 then flagDeDireccion:=0;
    dsSudOeste:
      if abs(deltaX)>deltaY then flagDeDireccion:=0;
    dsOeste:
      if deltaY<0 then flagDeDireccion:=0;
    dsNorOeste:
      if abs(deltaY)>abs(deltaX) then flagDeDireccion:=0;
  end;
  intentos:=0;
  repeat
    if intentos>=7 then exit;
    dirMov:=dirMovimiento;
    flagDeDireccion:=flagDeDireccion xor $1;
    if flagDeDireccion=0 then
      for i:=0 to (intentos shr 1) do
        dirMov:=MC_siguienteDireccion[dirMov]
    else
      for i:=0 to (intentos shr 1) do
        dirMov:=MC_anteriorDireccion[dirMov];
    inc(intentos);
  until lugarVacioVerificarFronterasXY(RJugador,RJugador.coordx+MC_avanceX[dirMov],RJugador.coordy+MC_avanceY[dirMov]);
  RJugador.Control_movimiento:=$2 or flagDeDireccion;
end;

function TTablero.BuscarDireccionLibre(RJugador:TjugadorS;dirMovimiento:TDireccionMonstruo):TDireccionMonstruo;
var i,intentos:integer;
begin
  intentos:=0;
  repeat
    result:=dirMovimiento;
    if intentos>2 then exit;
    if (RJugador.Control_Movimiento and $1=0) then
      for i:=0 to intentos do
        result:=MC_siguienteDireccion[result]
    else
      for i:=0 to intentos do
        result:=MC_anteriorDireccion[result];
    inc(intentos);
  until lugarVacioVerificarFronterasXY(RJugador,RJugador.coordx+MC_avanceX[result],RJugador.coordy+MC_avanceY[result]);
end;

function TTablero.lugarVacioAlFrente(elemento:TmonstruoS):bytebool;
var x,y:smallint;
begin
  with elemento do
  begin
    x:=coordX+MC_avanceX[dir];
    y:=coordY+MC_avanceY[dir];
  end;
  result:=(word(x)<=MaxMapaAreaExt) and (word(y)<=MaxMapaAreaExt) and LugarVacioXY(elemento,x,y);
end;

function TTablero.getCodBolsaVerificarFronterasXY(x,y:smallint):integer;
begin
  if (word(x)>MaxMapaAreaExt) or (word(y)>MaxMapaAreaExt) then
  begin
    result:=mskBolsa;
    exit;
  end;
 result:=mapaPos[x,y].terbol and mskBolsa;
end;

function TTablero.getMonRecXY(x,y:smallint):word;
begin
  if (word(x)>MaxMapaAreaExt) or (word(y)>MaxMapaAreaExt) then
  begin
    result:=ccVac;
    exit;
  end;
  result:=mapaPos[x,y].monRec;
end;

procedure Ttablero.DeterminarSiEstaCercaDeFogata(jug:TjugadorS);
var i,codigoBolsa:integer;
begin
  jug.aurasExternas:=jug.aurasExternas or flAuraExtFogata;//fijar bandera
  for i:=0 to MAX_INTENTOS_POSICIONAMIENTO-1 do//buscar fogata
  begin
    codigoBolsa:=getCodBolsaVerificarFronterasXY(
      jug.coordX+MC_POSICIONAMIENTO_X[i],jug.coordy+MC_POSICIONAMIENTO_Y[i]);
    if codigoBolsa<=maxBolsas then
    if (bolsa[codigoBolsa].tipo>=tbFogata) then exit;
  end;
  if (ObtenerRecursoAlFrente(jug)=irFundicion) then exit;
  jug.aurasExternas:=jug.aurasExternas xor flAuraExtFogata;//limpiar bandera
end;

function TTablero.AlFrenteUnBuenLugarParaFogatas(jug:TjugadorS):bytebool;
var x,y:smallint;
    recurso:word;
begin
  result:=false;
  with jug do
  begin
    x:=coordx+MC_avanceX[dir];
    y:=coordy+MC_avanceY[dir];
    if (word(x)>MaxMapaAreaExt) or (word(y)>MaxMapaAreaExt) then exit;
    if mapaPos[x,y].monRec<>ccvac then exit;
    recurso:=mapaPos[x,y].terBol;
    result:=((recurso and (MskBolsa or ft_agua))=mskBolsa) and
      ((recurso and mskTerreno)<>mskTerreno_InteriorVivienda) and
      ((recurso and mskTerreno)<>mskTerreno_Cultivos);
  end;
end;

function TTablero.ObtenerRecursoAlFrente(jug:TjugadorS):byte;
var x,y:smallint;
    recursoActual:word;
begin
  with jug do
  begin
    x:=coordx+MC_avanceX[dir];
    y:=coordy+MC_avanceY[dir];
    if (word(x)>MaxMapaAreaExt) or (word(y)>MaxMapaAreaExt) then
      result:=SIN_RECURSOS
    else
    begin
      recursoActual:=mapaPos[x,y].monRec;
      if recursoActual>=ccRec then
      begin
        result:=recursoActual and $FF;
        if result=$FF then//casilla vacia de recursos
          if (mapaPos[x,y].terbol and mskTerreno)=ft_Agua then
            result:=irAguaConPeces;
      end
      else
        result:=SIN_RECURSOS;
    end;
  end;
end;

function TTablero.PuedeUsarHerramienta(jug:TjugadorS;indArt:byte; var Reparar:boolean):byte;
var recurso:word;
    idArticulo:byte;
  function ControlFundicion(minimoMineral:integer):byte;
  begin
    if recurso=irFundicion then
      if longbool(jug.Pericias and (hbMineria or hbHerreria)) then
        if (jug.artefacto[indArt].modificador>=minimoMineral) then
          result:=i_OK
        else
          result:=i_NecesitasMasMineral
      else
        result:=i_NoSabesFundir
    else
      result:=i_SinFundicion
  end;
begin
//Revisar:
//Objetos, function DeterminarIconoApropiado(objeto:Tartefacto):shortint;
//Para verificar los tipos de objetos.
  result:=i_error;
  reparar:=false;
  with jug do
  if indArt<=MAX_ARTEFACTOS then
  if hp<>0 then
    if not longbool(banderas and BnParalisis) then
    begin
      idArticulo:=artefacto[indArt].id;
      if InfObj[idArticulo].NivelMinimo>jug.nivel then
      begin
        result:=i_TeFaltaNivelParaUsarElObjeto;
        exit;
      end;
      recurso:=obtenerRecursoAlFrente(jug);
      case idArticulo of
        orMonedaPlata..or100MonedasOro:result:=i_ok;
        ihVeneno,ihParalizante:
          if Usando[uArmaDer].id>=4 then
            //si es Objeto Envenenable => OK
            if MaximaCantidadDeEsteObjeto(Usando[uArmaDer])=toCantidad_60 then
              result:=i_OK
            else
              result:=i_noEsEnvenenable
          else
            result:=i_ColocaAlgoParaEnvenenarEnManoDerecha;
        ihAfilador:
          if (InfObj[Usando[uArmaDer].id].TipoReparacion=trAfilar) or
             (InfObj[Usando[uArmaIzq].id].TipoReparacion=trAfilar) then
            if((InfObj[Usando[uArmaDer].id].TipoReparacion=trAfilar) and (NivelMaximoQuePuedeReparar(trAfilar)>Usando[uArmaDer].modificador)) or
              ((InfObj[Usando[uArmaIzq].id].TipoReparacion=trAfilar) and (NivelMaximoQuePuedeReparar(trAfilar)>Usando[uArmaIzq].modificador)) or
              //Esto solo se aplica al cliente, donde el codigo de bolsa es el tipo de bolsa:
              (ttipoBolsa(getCodBolsaVerificarFronterasXY(coordX+MC_AvanceX[dir],coordY+MC_AvanceY[dir]))=tbLenna) then
            begin
              reparar:=true;
              result:=i_OK
            end
            else
              result:=i_NoPuedesRepararMejor
          else
            result:=i_SinArmaAfilable;
        ihAceite:
          if InfObj[Usando[uArmaDer].id].TipoReparacion=trAceitar then
            if NivelMaximoQuePuedeReparar(trAceitar)>Usando[uArmaDer].modificador then
            begin
              reparar:=true;
              result:=i_OK
            end
            else
              result:=i_NoPuedesRepararMejor
          else
            result:=i_SinArmaAceitable;
        ihVendas:
          if hp<maxhp then
            result:=i_OK
          else
            result:=i_NoNecesitasVendas;
        ihPico:
          case recurso of
            irHierro..irOro,irGemas,irGema0..irGema7:result:=i_Ok
          else
            result:=i_SinMinerales;
          end;
        ihHacha:
          case recurso of
            irLenna..irMaderaMagica:result:=i_Ok
          else
            result:=i_NadaParaTalar;
          end;
        ihCanna:
          if recurso=irAguaConPeces then
            result:=i_Ok
          else
            result:=i_NadaParaPescar;
        orLenna:
        begin
          if AlFrenteUnBuenLugarParaFogatas(jug) then
            result:=i_OK
          else
            result:=i_LugarNoAdecuadoParaFogata
        end;
        orTrampaMagica:
        begin
          if AlFrenteUnBuenLugarParaFogatas(jug) then
            result:=i_OK
          else
            result:=i_LugarNoAdecuadoParaTrampa
        end;
        ihTallador:
          if (Usando[uArmaIzq].id shr 3)=24 then
            if Usando[uArmaDer].id<4 then
              result:=i_OK
            else
              result:=i_NecesitasManoDerechaLibre
          else
            result:=i_NadaParaTallar;
        ihCalderoMagico:
          if longbool(Pericias and hbHerbalismo) then
            result:=i_OK
          else
            result:=i_NoSabesHacerPocimas;
        orHierro,orArcanita:result:=ControlFundicion(4);
        orPlata,orOro:result:=ControlFundicion(40);
        orCuerno,orFuegoArtificial,orBaulMagico,orTomoExperiencia:result:=i_Ok;
        orFlauta,orLaud:
          if CodCategoria=ctBardo then
            if mana>=MANA_USAR_INSTRUMENTO then
              result:=i_OK
            else
              result:=i_NecesitasManaParaJuglaria
          else
            result:=i_NoEresBardo;
        orPiel:
          if recurso=irCurtidora then
            if longbool(Pericias and hbSastreria) then
              if (artefacto[indArt].modificador>=MIN_PIELESxCUERO) then
                result:=i_OK
              else
                result:=i_NecesitasMasPieles
            else
              result:=i_NoSabesCurtir
          else
            result:=i_SinCurtidora;
        orFibras:
          if recurso=irTelar then
            if longbool(Pericias and hbSastreria) then
              if (artefacto[indArt].modificador>=MIN_FIBRASxTELA) then
                result:=i_OK
              else
                result:=i_NecesitasMasFibras
            else
              result:=i_noFabricasTela
          else
            result:=i_SinTelar;
        ihTijeras:
          if InfObj[Usando[uArmaDer].id].TipoReparacion=trCoser then
            if NivelMaximoQuePuedeReparar(trCoser)>Usando[uArmaDer].modificador then
            begin
              reparar:=true;
              result:=i_OK
            end
            else
              result:=i_NoPuedesRepararMejor
          else
            if Usando[uArmaDer].id<4 then
              if longbool(Pericias and hbSastreria) then
                result:=i_OK
              else
                if InfObj[Usando[uArmaIzq].id].TipoReparacion=trCoser then
                  result:=i_ObjetoRemendableEnManoDer
                else
                  result:=i_noEresSastre
            else
              if InfObj[Usando[uArmaIzq].id].TipoReparacion=trCoser then
                result:=i_ObjetoRemendableEnManoDer
              else
                result:=i_NecesitasManoDerechaLibre;
        ihMartillo:
          if InfObj[Usando[uArmaDer].id].TipoReparacion=trMartillar then
            if NivelMaximoQuePuedeReparar(trMartillar)>Usando[uArmaDer].modificador then
            begin
              reparar:=true;
              result:=i_OK
            end
            else
              result:=i_NoPuedesRepararMejor
          else
            if Usando[uArmaDer].id<4 then
              if recurso=irYunque then
                if longbool(Pericias and hbHerreria) then
                  result:=i_OK
                else
                  if InfObj[Usando[uArmaIzq].id].TipoReparacion=trMartillar then
                    result:=i_ObjetoMartillableEnManoDer
                  else
                    result:=i_noEresHerrero
              else
                result:=i_SinYunque
            else
              if InfObj[Usando[uArmaIzq].id].TipoReparacion=trMartillar then
                result:=i_ObjetoMartillableEnManoDer
              else
                result:=i_NecesitasManoDerechaLibre;
        ihSerrucho:
          if longbool(Pericias and hbCarpinteria) then
            result:=i_OK
          else
            result:=i_noEresCarpintero;
        ihLibroAlquimia:
          if longbool(Pericias and hbAlquimia) then
            if recurso=irEstudioAlquimia then
              result:=i_OK
            else
              result:=i_SinEstudioDeAlquimia
          else
            result:=i_noEresAlquimico;
        ihVaritaVacia:
          if MaxMana>0 then
            if Mana>0 then
              result:=i_OK
            else
              result:=i_NoTienesMana
          else
            result:=i_NoPuedesHacerMagia;
        ihPlumaMagica:
          if longbool(Pericias and hbEscribir) then
            if recurso=irEstudioMago then
              result:=PuedeEscribirElConjuroSeleccionado(indArt)
            else
              result:=i_SinEstudioDeMago
          else
            result:=i_noEresMagoEscritor;
        ihHerramientasHerbalista:
          case recurso of
            irIngrediente0..irIngrediente7:result:=i_Ok
          else
            result:=i_SinIngredientes;
          end;
        ihPergaminoA,ihPergaminoS:
          if maxMana>0 then
            if PuedeLeerElConjuro(artefacto[indArt].modificador) then
              if longbool(Conjuros and (1 shl artefacto[indArt].modificador)) then
                result:=i_YaConocesElConjuro
              else
                result:=i_Ok
            else
              result:=i_FaltaNivelParaLeelElPergamino
          else
            result:=i_NoPuedesHacerMagia;
        else;
      end
    end
    else
      result:=i_EstasParalizado
  else
    result:=i_EstasMuerto;
end;

function TTablero.ApuntarCasilla(x,y:integer;preciso:boolean):word;
var px,py,ipos:integer;
    contenido:word;
begin
  iPos:=0;
  px:=x;
  py:=y;
  repeat
    result:=getMonRecXY(px,py);
    contenido:=result and fl_con;
    if (contenido<=ccMon) then exit;//encontramos uno
    px:=x+MC_avanceX[iPos];
    py:=y+MC_avanceY[iPos];
    inc(iPos);
  until preciso or (iPos>=8);
  result:=ccVac;
end;

function TTablero.ExisteObstaculo(xOrigen,yOrigen,xDestino,yDestino:byte):boolean;
var conta,deltaX,deltaY:integer;
    factor:single;
    DatoCasilla:word;
begin
  result:=true;
  deltax:=xDestino-xOrigen;
  deltay:=yDestino-yOrigen;
  //=( , si están al lado, no existe obstaculo.
  if (abs(deltax)<=1) and (abs(deltay)<=1) then
  begin
    result:=false;
    exit;
  end;
  //siempre revisando de izq. a der. o de arriba pa abajo.
  if abs(deltaX)>abs(deltaY) then
  begin//barrido horizontal
    factor:=deltaY/deltaX;
    if deltaX<0 then//corrección de dirección de barrido
    begin
      deltaX:=-deltaX;
      xOrigen:=xDestino;
      yOrigen:=yDestino;
    end;
    for conta:=1 to deltaX-1 do
    begin
      DatoCasilla:=mapaPos[(xOrigen+conta)and $FF,(yOrigen+round(conta*factor))and$FF].monRec;
      if (DatoCasilla>=ccRec) and (DatoCasilla<ccVacRango) then exit;
     end;
  end
  else//barrido vertical
  begin
    factor:=deltaX/deltaY;
    if deltaY<0 then//corrección de dirección de barrido
    begin
      deltaY:=-deltaY;
      xOrigen:=xDestino;
      yOrigen:=yDestino;
    end;
    for conta:=1 to deltaY-1 do
    begin
      DatoCasilla:=mapaPos[(xOrigen+round(conta*factor))and$FF,(yOrigen+conta)and$FF].monRec;
      if (DatoCasilla>=ccRec) and (DatoCasilla<ccVacRango) then exit;
    end;
  end;
  result:=false;
end;

end.

