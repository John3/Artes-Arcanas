(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

//Módulo libre de bibliotecas externas al juego
unit Demonios;
//  Orientado al Servidor primordialmente y al Cliente, con ayuda de Sprites que
//contiene información adicional.
//Definiciones usadas por Sprites(servidor y Cliente) y Animacion(Cliente)
interface
uses Objetos;

const
  //Jugadores:

  MaxJugadores=255;//En todos los mapas, maximo 16383.
  MaxMonstruos=8191;//En todos los mapas, maximo 16383.
  MaxClanesJugadores=249;//Maximo 249 total=250,
  //Campo de visión.
  MaxRangoSeguirEnNormaCuadrado=25;
  MaxRangoArqueroEnNormaCuadrado=16;
  RangoArqueroEnNormaCuadrado=9;
  MaxRefrescamientoX=16;
  MaxRefrescamientoY=17;
  MaxVisionX=MaxRefrescamientoX-1;
  MaxVisionY=MaxRefrescamientoY-1;
  MaxAlcanceX=MaxVisionX-3;
  MaxAlcanceY=MaxVisionY-5;
  MaxComida=100;

  MAX_HABILIDADES_SUMADAS=33;
  MAX_NIVEL_NEWBIE=6;
  MAX_NIVEL_CON_BONO=24;
  MIN_NIVEL_CATEGORIA=25;
  MAX_NRO_EXPLOSIONES=8;//Conjuros que lanzan espirales de fuego, hielo o rayo, ojo va 1 mas (0..n).
  MINIMO_DANNO_PARA_ENVENENAMIENTO=4;
  MINIMO_DANNO_PARA_CONGELACION=8;
  MINIMO_DANNO_PARA_REDUCCION_MANA=16;
  MINIMO_DANNO_PARA_EFECTOFUEGO=20;
  PENA_DEFENSA_IRA_TENAX=15;
  PENA_HP_IRA_TENAX=20;
  PENA_ATAQUE_POR_ESPALDA=25;
  BONO_EFECTO_BARDO=25;
  BONO_CONJURO_ARMADURA=20;
  BONO_CONJURO_FUERZA=10;
  PENA_MALDICION_ATURDIR=40;
  MANA_USAR_INSTRUMENTO=2;
  MANA_ZOOMORFISMO=3;
  MAXIMA_DISTANCIA_COMERCIO=3;
  TIEMPO_ATENCION_COMERCIANTE_AL_COMPRADOR=128;
  TIEMPO_MINIMO_CONJURO_POCIMA=20;
  CD_CONJURO_RESUCITAR=11;
  BONO_HP_POR_NIVEL_PODER=4;//=2^(4)=16
  BONO_ATAQUE_POR_NIVEL_PODER=4;//=2^(4)=16
  BONO_DANNO_POR_NIVEL_PODER=3;//=2^(2)=8

  NIVEL_ATAQUE_SIEMPRE_EXITOSO=95;//garantiza 5% de ataques exitosos.
  MINIMO_PORCENTAJE_DE_ATAQUE=5;//garantiza 5% de ataques fallados,
  // ojo que si lo analizan sólo toma efecto cuanto un jugador tiene tanta
  //ventaja en su ataque que aún teniendo una lanzada tan baja podría golpear
  //con éxito, asi que no afeca a los jugadores menos poderosos.
  MAXIMA_CANTIDAD_HORNOR_POR_VICTORIA=5;
  MAX_NIVEL_EXPERIENCIA_POR_TRABAJAR=15;
// No cambiar!!:
  MAX_TIMERS_DEMONIO=15;//n+1(0..n)
  MAX_INDICE_PARTY=3;//NO CAMBIAR!!
  MAX_POSICIONES=MAX_ARTEFACTOS+8;
  BYTES_INVENTARIO=(MAX_POSICIONES+1)*2;
  MAX_CONJUROS=29;//máximo 31
  NIVEL_MAXIMO=100;
  MAX_DEMONIO_HP=32000;
  MAX_CASILLA_NEGADA_ZOOMORFISMO=3;//no usar armas, armaduras ni cascos
  Fin_animaciones_avatares=99;//100 animaciones para avatares.
  Inicio_tipo_monstruos=101;//Indica el inicio de las def. de monstruos
  Fin_tipo_monstruos=183; //tipos de monstruos
  Ninguno=255;
  MAXIMA_EXPERIENCIA_FALTANTE=65000;
  EXPERIENCIA_POR_NIVEL_HONOR=15000;
  //Animaciones de armaduras: 32 armaduras * 8 clases * 8 razas * 2 sexos
  MAX_ANIMACIONES_ARMADURAS=4095;

//FLAGS
  ft_Cubierto=$0400; //cubierto con techo

{  ft_Fertil=$0800;
  ft_SuaveSalvaje=$1000;
  ft_CaminoPisos=$2000; }

  ft_ZonaCivilizada=$0800;
  ft_TerrenoSolido=$1000;
  ft_TierraSalvaje=$2000;

  ft_Fuego=$4000;
  ft_Agua=$8000;

  Dz_Nadar=2;

  mskTerreno_Cultivos=ft_ZonaCivilizada;//no es terreno sólido ni está cubierto
  mskTerreno_Pisos=ft_TerrenoSolido or ft_ZonaCivilizada;
  mskTerreno_InteriorVivienda=ft_TerrenoSolido or ft_ZonaCivilizada or ft_Cubierto;//todos
  MskTerreno_SoltarBolsa=mskTerreno_InteriorVivienda or ft_TierraSalvaje;//casi todos los terrenos

  MskIdAtaque=$3F;//Para identificador de ataque de mosntruos

//Para el tablero:
  fl_con:word=$C000;//flag_contenido
  fl_cod:word=$3FFF;//flag_codigo
  ccJgdr=$0000;
  ccMon=$4000;
  ccLimiteMonstruos=$7FFF;
  ccClan=$8000;//para indicar que el dueño de un monstruo es un clan.
  ccRec=$FD00;//recursos, impiden el movimiento.
  ccRecMov=$FDFF;//modificable por flags del mapa
  //Mayor o igual a ccVacRango, pero menor a ccVac => impide movimiento pero deja pasar municiones y conjuros.
  ccVacRango=$FE00;//recursos, impiden el movimiento, pero no el paso de misiles
  ccVacRangoMov=$FEFF;//modificable por flags del mapa
  ccVac=$FFFF;//NO cambiar (casilla vacia)
  ccSinDuenno=ccVac;

//Sincronización para optimizar comunicación
  flYaConoceSuBaul=$01;
  flModoPKiller=$02;
  flRevisandoBolsa=$04;
  flSaliendoDelServidor=$80;

//Flags de auras externas:
  flAuraExtFogata=$1;
type
  TAccionMonstruo=byte;
  TDireccionMonstruo=byte;
  //TdBasico:
  {
    Monstruos: Comerciantes: Tiempo de atencion
    Jugadores:               Tiempo de duración de su agresividad.
  }
  TTimerDemonio=(tdBasico,tdInvisible,tdArmadura,tdFuerzaGigante,tdApresurar,tdProteccion,tdVisionVerdadera,tdParalisis,tdIraTenax,TdCongelado,tdCombate,tdAturdir,tdAspectoNN,tdNoUsado);
  TTipoTransaccion=(ttNinguna,ttCompraPJ,ttVentaPJ,ttCompraAPNJ,ttVentaAPNJ,ttHacerParty);
  TEstiloAnimacion=(eaNormal,eaAtaqueEsporadico,eaNoDesplazar,eaNoDesplazarPausado,eaLevitacion);
  TEstiloMuerte=(emSangreRoja,emSangreNegra,emSangreVerde,emEnergiaDisipada,emMaderas,emPiedras,emMetales,emAvatar);
  TAccionAutomatica=(aaNinguna,aaCaminar,aaTrabajar,aaInicioDeAtaques,aaAtaqueOfensivo,aaAtaqueDefensivo,aaAtaqueMagia);
  TConsecuenciaMuerteMonstruo=(cmNinguno,cmCastilloReclamado);
  TArregloHabilidades=array[0..4] of byte;
  TBanderaClan=record
    color0,color1:longword;
    //color0=0: sin estandarte.
    //color1 shr 30= modelo de bandera.
    //$3F=6 bits para cada color rgb.
  end;
  Tposicion=record
    x,y:smallint;
  end;
const
  //Otros
  MAX_PERICIAS=3;
  //Timer:
  MaxFramesTimer=7;
  //Acciones
  mskAcciones=$F;
  aaParado=0;
  aaMeditando=1;
  aaDescansando=2;
  aaCaminando=3;
  //ataques
  aaAtacando1=8;
  aaPrimerAtaque=aaAtacando1;
  aaAtacando2=aaAtacando1+1;
  aaAtacando3=aaAtacando1+2;
  aaAtacando4=aaAtacando1+3;
  aaAtacando5=aaAtacando1+4;
  aaUltimoAtaque=aaAtacando5;
  //Comportamientos monsruos
  comPacifico=0;//meleé
  comTerritorial=1;//meleé
  comAgresivo=2;//meleé
  comAtaqueRango=3;//Arqueros, arcabuceros, ballesteros, honderos: entras en rango y te atacan.
  comHerbivoro=4;//escapan, comen hierbas.
  comGuardia=5;//meleé, te acercas mucho y te atacan
  comAtaqueHechizos=6;//lanza conjuros, pero puede atacar con meleé, escapa si no tiene maná ni ataque meleé.
  comGuerreroMago=7;//el 3er ataque es un conjuro que puede lanzarlo.
  comObjetoDummy=8;//No ataca y no se mueve.
  comDefensaEstatica=9;
  comComerciante=10;
  comMonstruoConjurado=11;//>=11 => monstruo conjurado
  //Comportamientos Avatares
  comDemonio=-100;
  comNormal=0;
  comHeroe=100;//no cambiar
  comGameMaster=127;
  comAdminA=126;
  comAdminB=125;
  //Categorías de jugadores
  ctGuerrero=0;
  ctClerigo=1;
  ctMago=2;
  ctBribon=3;
  ctMontaraz=4;
  ctPaladin=5;
  ctBardo=6;
  ctGuerreroMago=7;
  //REsalte de habilidades:
  HbFuerza=$00;
  HbConstitucion=$01;
  HbInteligencia=$02;
  HbSabiduria=$03;
  HbDestreza=$04;
  //Direcciones
  mskDirecciones=$7;
  mskMovimientoContinuo=$40;
  //Habilidades
  mskHabilidadMejorada=$7;
  mskHabilidadDisminuida=$38;
  mskHabilidadResaltada=mskHabilidadMejorada or mskHabilidadDisminuida;
//Banderas de monstruos y jugadores:
//16 primeras=visibles
//24 primeras=persistentes
//8 últimas=sólo en el cliente.
  //Banderas visibles por otros jugadores (16)
  BnIraTenax           =$1;//jug
  BnInvisible          =$2;
  BnArmadura           =$4;
  BnFuerzaGigante      =$8;
  BnApresurar         =$10;
  BnProteccion        =$20;
  BnAturdir           =$40;
  BnParalisis         =$80;

  BnCongelado        =$100;
  BnEfectoBardo      =$200;//sólo jug
  BnVisionVerdadera  =$400;
  BnEnvenenado       =$800;
{
  BnNoUsado1        =$1000;
  BnNoUsado2        =$2000;
}
  //Estatus de monstruo ,*,**,***
  MskPoderMonstruo=$C000;//0..3, (((x)shr 14) and $3)
  DsPoderMonstruo=14;

  //No visibles (8)
  BnZoomorfismo    =$10000;
  BnOcultarse      =$20000;
  BnVendado        =$40000;
  BnModoDefensivo  =$80000;

//Superiores (8), usados separadamente en cliente/servidor:
//Sólo en el servidor:
  BnSiguiendo    =$1000000;//siguiendo a un monstruo o avatar
  BnDuracion     =$2000000;//mayor tiempo de duración.

  BnControlado   =$8000000;//indica si el monstruo está bajo control de GM, para Avatares indica si está en la carcel
//Sólo en el cliente:
  BnFantasma    =$10000000;
  BnMana        =$20000000;//efecto de acumular mana
  BnDescansar   =$40000000;//efecto descansando

//Banderas que son visibles
  MskBanderasConAura=$FFFF or BnMana;
//Banderas que son disipadas por sanación
  MskBanderasSanadas=bnEnvenenado or BnCongelado;
//Banderas que no son afectadas por disipar magia
  MskBanderasNoMagia=$FF000000 or MskBanderasSanadas
    or BnModoDefensivo or BnVendado or MskPoderMonstruo;
//Banderas positivas
  MskBanderasPositivas=BnIraTenax or BnInvisible or BnArmadura or
    BnFuerzaGigante or BnApresurar or BnProteccion or BnEfectoBardo or
    BnVisionVerdadera or BnZoomorfismo or BnVendado or BnModoDefensivo;
//Banderas magicas negativas
  MskBanderasNegativasDisipables=BnAturdir or BnParalisis;

  //Código especial para avatares muertos:
  moAriete=50;
//  moFantasma=100;
  //Códigos de monstruos
  //Monstruos (100..183)
  moAranna=101;
  moOgro=142;
  moGolem=181;
  MoEsqueleto=112;
  moBeholder=182;
  moNandu=160;
  moGacela=161;
  moOso=150;
  moOsoPardo=151;

  dsNorte=0;
  dsSud=1;
  dsOeste=2;
  dsEste=3;
  dsNorEste=4;
  dsSudOeste=5;
  dsNorOeste=6;
  dsSudEste=7;
  dsIndefinido=8;
  //Matrices constantes para optimización de tiempo.
  MC_avanceX:array[0..7] of smallint=(0,0,-1,1,1,-1,-1,1);
  MC_avanceY:array[0..7] of smallint=(-1,1,0,0,-1,1,-1,1);
  MC_direccionApunnalada:array[0..7] of byte=(
    (1 shl dsNorte) or (1 shl dsNorEste) or (1 shl dsNorOeste),//dsNorte
    (1 shl dsSud) or (1 shl dsSudEste) or (1 shl dsSudOeste),//dsSud
    (1 shl dsOeste) or (1 shl dsSudOeste) or (1 shl dsNorOeste),//dsOeste
    (1 shl dsEste) or (1 shl dsSudEste) or (1 shl dsNorEste),//dsEste
    (1 shl dsNorEste) or (1 shl dsNorte) or (1 shl dsEste),//dsNorEste
    (1 shl dsSudOeste) or (1 shl dsSud) or (1 shl dsOeste),//dsSudOeste
    (1 shl dsNorOeste) or (1 shl dsNorte) or (1 shl dsOeste),//dsNorOeste
    (1 shl dsSudEste) or (1 shl dsSud) or (1 shl dsEste)//dsSudEste
    );
  MC_direccion:array[-1..1,-1..1] of TDireccionMonstruo=((dsNorOeste,dsOeste,dsSudOeste),
    (dsNorte,dsSud{dsIndefinido},dsSud),(dsNorEste,dsEste,dsSudEste));
  MC_DarVueltaDireccion:array[0..7] of byte=
    (dsSud,dsNorte,dsEste,dsOeste,dsSudOeste,dsNorEste,dsSudEste,dsNorOeste);
  MC_ordenDireccion:array[0..7] of byte=(0,4,2,6,7,3,1,5);
(*  MC_ordenRevisionRuta:array[0..7,0..6] of byte=
   ({0}(4,5,2,1,6,3,7),
    {1}(5,3,0,7,4,6,2),
    {2}(6,4,7,0,5,3,1),
    {3}(1,7,5,6,0,2,4),
    {4}(2,0,6,5,7,1,3),
    {5}(0,1,4,3,2,7,6),
    {6}(7,2,3,4,1,0,5),
    {7}(3,6,1,2,5,4,0));*)
  MC_anteriorDireccion:array[0..7] of byte=
    (dsNorEste,dsSudOeste,dsNorOeste,dsSudEste,dsEste,dsOeste,dsNorte,dsSud);
  MC_siguienteDireccion:array[0..7] of byte=
    (dsNorOeste,dsSudEste,dsSudOeste,dsNorEste,dsNorte,dsSud,dsOeste,dsEste);
  //0=nro animacion,1=espejo
  MC_Nombre_Categoria:array[0..7] of string[13]=(
    'Guerrero','Clérigo','Mago','Bribón','Montaraz','Paladín','Bardo','Guerrero Mago');
  MC_Nombre_Categoria2:array[0..7] of string[15]=(
    'Campeón','Maestre Clérigo','Archimago','Gran Bribón','Guardabosques','Maestre Paladín','Gran Bardo','Campeón Arcano');
  MC_Genero:array[0..1] of string[5]=('Varón','Mujer');
  MC_Pericias:array[0..15] of string[15]=(
    'Alquimia','Escribir magia','Herbalismo','Tallar gemas',
    'Herrería','Carpintería','Sastrería','Regatear',
    'Minería','Liderazgo','Regeneración','Ambidextría',
    'Apuñalar','Ocultarse','Ira Tenax','Zoomorfismo');
  MC_HabilidadBase:array[0..7] of byte=(
    HbFuerza or (HbInteligencia shl 3),
    HbSabiduria or (HbDestreza shl 3),
    HbInteligencia or (HbFuerza shl 3),
    HbDestreza or (HbSabiduria shl 3),
    HbDestreza or (HbSabiduria shl 3),
    HbFuerza or (HbInteligencia shl 3),
    HbDestreza or (HbSabiduria shl 3),
    HbInteligencia or (HbSabiduria shl 3));
  //Pericias:
  hbAlquimia=   $0001;
  hbEscribir=   $0002;
  hbHerbalismo= $0004;
  hbTallarGemas=$0008;
  hbHerreria=   $0010;
  hbCarpinteria=$0020;
  hbSastreria=  $0040;
  hbRegatear=   $0080;
  hbMineria=    $0100;
  hbLiderazgo=  $0200;
  hbRegenerar=  $0400;
  hbAmbidextria=$0800;
  hbApunnalar=  $1000;
  hbCamuflarse= $2000;
  hbIraTenax=   $4000;
  hbZoomorfismo=$8000;
{Flags:
    ctGuerrero=$1;
    ctClerigo=$2;
    ctMago=$4;
    ctBribon=$8;
    ctMontaraz=$10;
    ctPaladin=$20;
    ctBardo=$40;
    ctGuerreroMago=$80;  }
  categoriasDenegadas:array [0..6] of byte=(
  {rzHumano}   $40 or $80,
  {rzElfo}     $8 or $20,
  {rzEnano}    $4 or $10 or $40 or $80,
  {rzGnomo}    $10 or $20 or $40 or $80,
  {rzSemielfo} $0,
  {rzOrco}     $4 or $10 or $20 or $40,
  {rzDrow}     $2 or $10 or $20 or $40);
  periciasDenegadas:array [0..7] of longword=(
    hbEscribir or hbAlquimia or hbTallarGemas or hbHerbalismo or hbZoomorfismo,//Guerrero
    hbAmbidextria or hbApunnalar or hbIraTenax or hbCamuflarse or hbMineria,//Clerigo
    hbAmbidextria or hbApunnalar or hbMineria or hbIraTenax or hbHerreria or hbZoomorfismo or hbCarpinteria or hbRegenerar,//Mago
    hbEscribir or hbAlquimia or hbHerbalismo or hbIraTenax or hbZoomorfismo or hbMineria,//Bribón
    hbEscribir or hbAlquimia or hbMineria or hbTallarGemas or hbSastreria or hbHerreria or hbCarpinteria,//Montaraz
    hbEscribir or hbAlquimia or hbTallarGemas or hbApunnalar or hbHerbalismo or hbZoomorfismo,//Paladín
    hbEscribir or hbAlquimia or hbMineria or hbIraTenax or hbHerreria or hbZoomorfismo,//Bardo
    hbMineria or hbHerreria or hbZoomorfismo or hbCarpinteria or hbIraTenax or hbApunnalar or hbSastreria or hbCamuflarse or hbAmbidextria);//Guerrero Mago
  //Razas de jugadores
  rzHumano=0;
  rzElfo=1;
  rzEnano=2;
  rzGnomo=3;
  rzSemielfo=4;
  rzOrco=5;
  rzDrow=6;
  //Otros:
  MaxNombresAtaques=29;
  Nombre_Ataque:array[0..MaxNombresAtaques] of string[15]=
  ('ácido','aguijón','alabarda','aliento','arcabuz','arco y flecha','ballesta',
   'cola','cuernos','daga','embestida','espada','fuego','garra',
   'golpe','hacha','hechizo','hielo','lanza','mandoble','maza',
   'dardo venenoso','mordida','patada','picotazo','rayo','tenazas',
   'flecha venenosa','aliento frio','dedo de muerte');
  Sonido_Ataque_Exitoso:array[0..MaxNombresAtaques] of Char=
  ({'ácido'}'u',{'aguijón'}'G',{'alabarda'}'E',{'aliento'}#197,{'arcabuz'}'A',
  {'arco y flecha'}'F',{'ballesta'}'F',{'cola'}'C',{'cuernos'}'G',{'daga'}'E',
  {'embestida'}'C',{'espada'}'E',{'fuego'}#200,{'garra'}'G',{'golpe'}'C',
  {'hacha'}'E',{'hechizo'}#199,{'hielo'}#203,{'lanza'}'E',{'mandoble'}'E',{'maza'}'C',
  {'dardo venenoso'}'F',{'mordida'}'G',{'patada'}'C',{'picotazo'}'G',{'rayo'}#198,
  {'tenazas'}'G',{flecha venenosa}'F',#196{aliento frio},{'hechizo matar'}#215);
  Sonido_Ataque_Armadura:array[0..MaxNombresAtaques] of Char=
  ({'ácido'}'u',{'aguijón'}'g',{'alabarda'}'e',{'aliento'}#197,{'arcabuz'}'f',
  {'arco y flecha'}'f',{'ballesta'}'f',{'cola'}'g',{'cuernos'}'g',{'daga'}'e',
  {'embestida'}'g',{'espada'}'e',{'fuego'}#200,{'garra'}'g',{'golpe'}'g',
  {'hacha'}'e',{'hechizo'}#199,{'hielo'}#203,{'lanza'}'e',{'mandoble'}'e',{'maza'}'g',
  {'dardo venenoso'}'f',{'mordida'}'g',{'patada'}'g',{'picotazo'}'g',{'rayo'}#198,
  {'tenazas'}'g',{flecha venenosa}'f',#196{aliento frio},{'hechizo matar'}#215);

//Alineaciones de monstruos
  Al_Neutral=0;
  Al_Herbivoro=1;
  Al_Carnivoro=2;
  Al_Malvado=3;
  Al_NoMuerto=4;

//Pericias monstruos
  //Pericias dinamicas, pueden variar entre monstruos del mismo tipo
  perMon__Paralizar = $04;
  perMon__VisionVerdadera = $08;
  perMon__Aturdir = $10;
  perMon__DisiparMagia = $20;
  //Pericias estaticas, no varian entre monstruos del mismo tipo
  perMon_Liderazgo = $100;//convocar a las armas si el enemigo tiene mayor hp o nivel.
  perMon_Encantamiento = $200;//encantar monstruos enemigos de menor nivel.


// Codigos de animaciones
//estadísticas base de animacion

  MaxCuadrosJ=19;//20 (0..19) MaxFrames+4*3=7+12
  MaxCuadrosM=MaxFramesTimer;//8
  MaxAnicuerpo=3;
  NroFrameAnimacionParado=4;
  MaxAnicuerpoJ=5;//6
  MaxDirAni=4;//5+3 espejo;

  //Personajes
  aSAElfo=rzElfo;
  aSAHumano=rzHumano;
  aSAEnano=rzEnano;
  aSAOrco=rzOrco;
  aSADrow=rzDrow;
  aHumanoMago=20;
  aHumanoClerigo=21;
  aEnanoClerigo=23;
  aHumanoGuerrero=30;
  aHumanoGuerreroCuero=33;
  aEnanoGuerrero=31;
  aOrcoGuerrero=32;
  aDrowGuerreroMago=34;
  aBardo=22;
  aHerrero=49;
  //animaciones compuestas para el mapa (0..49):
  fxFundicion=0;
  fxHumoChimenea=1;
  fxAntorcha1=2;
  fxAntorcha2=3;
  fxAntorcha3=4;
  fxAntorchaR=5;
  fxAntorchaG=6;
  fxAntorchaB=7;
  fxAltar1=8;
  fxAltar2=9;
  fxAltar3=10;
  fxAltarR=11;
  fxAltarG=12;
  fxAltarB=13;
  fxPortal1=14;
  fxPortal2=15;
  fxPortal3=16;
  fx0R=17;
  fx0G=18;
  fx0B=19;
  fx1R=20;
  fx1G=21;
  fx1B=22;
  fx2R=23;
  fx2G=24;
  fx2B=25;
  fxFlamaAltar1=48;
  fxFlamaAltar2=49;
  //animaciones fx 208..255
  fxSangre=255;
  fxMira=254;
  fxExplosion3=253;
  fxExplosion2=252;
  fxExplosion1=251;
  fxAcido=250;
  fxBolaB=249;
  fxBolaG=248;
  fxBolaR=247;
  fxRayo=246;
  fxArdienteB=245;
  fxArdienteG=244;
  fxArdienteR=243;
  fxAura0=242;
  fxAura1=241;
  fxAura2=240;
  fxAura3=239;
  fxAura4=238;
  fxAura5=237;
  fxAura6=236;
  fxMana=235;
  fxChispasDoradas=234;
  fxChispasAzules=233;
  fxChispasRojas=232;
  fxOjo=231;
  fxZZZ=230;
  anDisolviendo=fxExplosion3;
  anIngresando=fxExplosion1;
  fxHumo=223;
  fxFlamaBlanca=222;
  fxFlamaAzul=221;
  fxFogata=220;
  fxFuegoArtificial1=219;
  fxFuegoArtificial2=218;
  fxPortal=217;

  fxPersonalizado2=210;
  fxPersonalizado1=209;
  fxPersonalizado0=208;
  //Animados 207 al 184
  anCadaver=202;
  anBolsa=201;
  anMoscas=200;
  anEstandarte=192;//192..195 ocupados.
type
  //Propios
  TCadena255=string[255];
  TCadena127=string[127];
  TDanno=record
  //base+random(plus)
    base:byte;
    plus:byte;//+Al azar
    tipoDanno:byte;
    cdnombre:byte;//codigo_nombre
  end;
const MAX_TIPOS_ATAQUE_MONSTRUO=2;//NO MODIFICAR!!
type
  TDescripcionMonstruo=record
      nombre:string[31];
      Terreno:word;//para optimizar con el mapa de posiciones.
      nivelMonstruo:byte;
      alineacion:byte;
      resistencias:integer;
      Defensa:byte;
      NoUsado1:byte;//Puntos de vida al maximo
      //Capacidad de ataque
      NivelAtaque:byte;
      Comportamiento:byte;
      Regeneracion:byte;
      ModificadorTesoro:byte;
      PExperiencia:word;//que da por derrotarlo
      //Daños.
      Ataque:array[0..MAX_TIPOS_ATAQUE_MONSTRUO] of TDanno;
      tesoro:byte;
      visibilidad:byte;
      //indice de movimiento
      movimiento:byte;
      EstiloMuerte:TEstiloMuerte;
      //Tamaño de la criatura:
      //0=diminuto 1=peque 2=medi 3=grande 4=gigante
      tamanno:byte;
      TesoroAzar:byte;
      EstiloAnimacion:TEstiloAnimacion;
      ConsecuenciaMuerte:TConsecuenciaMuerteMonstruo;
      ConjurosLanzables:integer;
      TiempoEntreAtaques:byte;//1,2,3
      nousado2:byte;
      HPPromedio:word;
      PericiasMonstruo:integer;//como llamar a las armas.
      nousado3:integer;
  end;

  TDescripcionMonstruoYTipo=packed record
    tipoMonstruo:byte;
    descripcion:TDescripcionMonstruo;
  end;

  TMapeoDeAtaques=record
    ConArmas:byte;
    NoUsado0:byte;
    NoUsado1:word;
  end;

  //[32 objetos][8 clases][8 razas][2 generos]
  TInformacionDeMapeoDeAtaques=array[0..Fin_animaciones_avatares] of TMapeoDeAtaques;
  TInformacionDeMapeoDeAnimaciones=array [0..MAX_ANIMACIONES_ARMADURAS] of byte;

  TInformacionMonstruos=array[0..Fin_tipo_monstruos] of TDescripcionMonstruo;
//  PInformacionMonstruos=^TInformacionMonstruos;

  TMonstruoS=Class(Tobject)
  //(S) por (S)imple del (S)ervidor (S)in animaciones.
  //Tmonstruo es descendiente de TMonstruoS.
  private
    { Private declarations }
    fTimer:array[0..MAX_TIMERS_DEMONIO] of byte;
  public
    { Public declarations }
    TipoMonstruo:byte;//codigo_tipo_monstruo
    dir:TDireccionMonstruo;
    coordx,coordy:byte;

    hp:word;//actuales muerto:=hp=0.
    mana:byte;
    noUsadoZ1:byte;

    activo:bytebool;
    codMapa:byte;//código de mapa.
    accion:TAccionMonstruo;
    codAnime:byte;

    codigo:word; //código monstruo/jugador. = identificador del socket de conexion
    codNido:byte;//Servidor: Código nido para monstruos definidos en el mapa. Cliente: bits $3 = sincronizador de sonidos de pasos.
    comportamiento:shortint;//reputacion para jugadores.

    //estados: paralizado, envenenado, invisible, etc.
    banderas:integer;

    //Para monstruos:código de jugador dueño de este monstruo.
    //Para Personajes no jugadores (comerciantes): Indice de comercio.
    //Libre de modificar en TjugadorS
    duenno:word;
    //Monstruo o jugador que atacara, contiene el código y el flag de contenido
    //que indica el código corresponde a un monstruo o un jugador.
    AtaqueUtilizado:byte;//and $3F=0..63=conjuros, shr 6=nro ataque utilizado
    PericiasDinamicas:byte;//Flags que indican los hechizos variantes que puede usar el monstruo.

    objetivoAtacado:word;//Indica que monstruo/jugador está atacando. En Tjugador es el apuntado en formato casilla
    objetivoASeguir:word;

    //Los siguientes son usados en forma separada en el cliente y en el servidor.
    RitmoDeVida:byte;//usado en el servidor para el tiempo de vida de monstruos conjurados, en el cliente para animacion
               //Tambien indica si ya puede surgir un monstruo nuevo (ritmo=0).
    Control_Movimiento:byte;//En el servidor almacena flags para busqueda de caminos. En el cliente sincroniza animaciones
    //Para los jugadores funciona de esta forma:
    //?0 Usar siguiente dirección
    //?1 Usar anterior dirección
    //0? No usar flag de dirección
    //1? Usar flag de dirección
    coordx_ant,coordy_ant:byte;//En el servidor: posiciones base para guardias y comerciantes.
    constructor create(codigo_n:word);
    procedure activar(const x,y:byte);
    procedure inicializarTimer(TipoTimer:TTimerDemonio;valor:byte);
    function TickTimer(TipoTimer:TTimerDemonio):bytebool;
    function TimerActivo(TipoTimer:TTimerDemonio):bytebool;
    procedure ReducirTiempoDeTimer(TipoTimer:TTimerDemonio;ticksReducidos:byte);
    procedure TerminarTimer(TipoTimer:TTimerDemonio);
    procedure AnimarAtaque;//Asigna un código de animacion
    function RealizarResistenciaMagica{(ConjuroAgresivo:bytebool)}:byte;//Devuelve un mensaje apropiado según el caso: ok al conjuro, el conjuro falla, invulnerable a conjuros.
    function mejorar(MatoAUnJugador:boolean):boolean;//true si elevo su nivel de poder
    procedure disiparMagia();
    function esNecesarioDisiparMagia():boolean;
    function esNecesarioSanar():boolean;
  end;

  TJugadorS=Class(TMonstruoS)
  //JugadorS sin Animaciones
  private
    { Private declarations }
  protected
  public
    { Public declarations }
    NroTurnosGastados:shortint;
    fCodCara:byte;
    FDestinoX,FDestinoY:byte;

    CodCategoria:byte;
    nivel:byte;
    experiencia:word;//cuando llega a 0, sube de nivel.

    nombreAvatar:TCadenaLogin;//(17 bytes)
    CapacidadId:TCapacidadIdentificacion;
    comida:byte;
    aurasExternas:byte;//Originalmente byte reservado para "bebida", ahora indica:
    // $1: cerca de una fogata o fragua
    // $2, $4, $8, $10, $20, $40, $80: otros efectos

    Pericias:longword;
    apuntado:TmonstruoS;//Referencia a objeto,se pierde al guardar el mapa
    dinero:integer;
    noUsado4Bytes:integer;

    Conjuros:longword;//Flags de conjuros del libro.
    dineroBanco:integer;//no usado por el momento
    //Artefactos
    Usando:array[0..7] of TArtefacto;
    Artefacto:TInventarioArtefactos;
    NivelAtaque:byte;//Completo menos arma usada.
    Defensa:byte;//Defensa
    ModDefensa:shortint;//Modificadores de ac Vestimentas,armadura,escudo
    dannoBase:byte;//danno de bono

    EspecialidadArma:byte;//código de arma.
    NivelEspecializacion:byte;
    HabilidadResaltada:byte;//la habilidad a mejorar y la habilidad a reducir
    //Formato HabilidadResaltada: $07: habilidad a mejorar, $38: habilidad a disminuir
    //$3F=bits utilizados
    FRZ,CON,INT,SAB,DES:byte;//5b

    //8 bytes
    armadura:TArmadurasJugador;

    ConjuroElegido:byte;
    NivelDeCategoria:Byte;// para recibir bendición en las armas //no usado por el momento
    FlagsComunicacion:Byte;// para reducir flujo de inf.
    Clan:byte;

    Baul:TInventarioArtefactos;

    //Vida y mana maximos
    maxhp:word;
    maxMana:byte;
    Meditacion255:byte;

    ObjetivoDeAtaqueAutomatico:word;
    AccionAutomatica:TAccionAutomatica;
    MensajesEnviadosEn16Turnos:byte;
    //Quest:
    //no iniciado: not QuestEnCurso and not QuestLogrado
    //iniciado: QuesEnCurso and not QuestLogrado.
    //casi completado, sólo falta el premio: QuestEnCurso and QuestLogrado
    //completado: not QuestEnCurso and QuestLogrado.
    QuestEnCurso:integer;//no usado por el momento
    QuestLogrado:integer;//no usado por el momento
    CamaradasParty:array[0..MAX_INDICE_PARTY] of word;
    //Los siguientes no son necesarios guardarlos:
    //Para comerciar(12 bytes :( )
    DineroOferta:integer;//El precio fijado
    CodigoMonstruoOferta:word;//sólo el código, con TipoTransaccion se verifican si es jugador o monstruo
    objetoOferta:TArtefacto;//Si es distinto del seleccionado por el jugador=>Trampa!!
    IndiceObjetoOferta:byte;//En el inventario de objetos para control.
    IndiceInflacionModificada:byte;//Para no buscarlo denuevo
    TipoTransaccion:TTipoTransaccion;//Para asegurar consistencia
    CantidadObjetosOferta:byte;//Necesario.
    property NivelAgresividad:byte read RitmoDeVida;
    function nuevoPersonaje(const datosPJ:TDatosNuevoPersonaje):boolean;
    procedure CalcularDefensa;
    procedure CalcularModDefensa;
    procedure CalcularDannoBase;
    procedure CalcularNivelAtaque;
    procedure CalcularMana;
    procedure CalcularHP;
    function ActivarEstadoAgresivo:bytebool;//true si no estaba agresivo
    procedure IncrementarTiempoDeCarcel;
    function TickTimerAgresividad:bytebool;//true si bajo a cero
    function ModificarExperiencia(cantidad:integer):bytebool;//true si vario el nivel
    function esVaron:bytebool;
    function BuscarObjetoEnInventario(idObj:byte):byte;//devuelve la posicion o ninguno=255 si no tiene.
    function TieneElObjeto(idObj:byte):bytebool;
    function TieneLaLlave(idObj,modificadorObj:byte;flagsCalabozo:integer;var indiceUsando:byte):bytebool;
    function IntercambiarObjetos(PosObjO,PosObjD:byte):byte;
    function TieneInfravision:bytebool;
    procedure ObtenerPosicionInicial(var nMapa,px,py:byte);
    function ElegirHabilidadParaCambiar(Habilidad:byte;mejorarHab:boolean):bytebool;
    procedure Morir;
    function PuedeRecibirComando(nroTurnosAGastar:shortInt):bytebool;
    procedure TickTiempoDeComandos;
    procedure prepararParaIngresarJuego;
    function BaulACadena:TCadena63;
    function InventarioACadena:TCadena63;
    procedure CadenaAInventario(const cadena:string);
    procedure CalculosNuevoNivel;
    procedure determinarAnimacion;
    procedure Resucitar;
    procedure restitucionAtributos;
    procedure repararAvatar;
    procedure crearHeroeLegendario;
    procedure SanacionCuracion;
    procedure AnimarAtaque;
    procedure AnimarConjuro;
    function PuedeConsumir(indArt:byte):byte;
    function MonstruoApuntadoIncorrecto:byteBool;
    function PuedeAtacar:byte;
    function getHabilidades:integer;
    procedure setHabilidades(B4_Hab:integer);
    procedure DefinirCapacidadIdentificacion;
    procedure TruncarArmasMagicasPoderosas;
    function PuedeConstruir(idHerramienta,idObjeto:byte):boolean;
    function TieneMaterialSuficiente(idObjeto:byte):boolean;
    function PuedeEscribirElConjuroSeleccionado(IndiceObjetoTintaMagica:byte):byte;//devuelve el código de mensaje apropiado
    function PuedeLeerElConjuro(nro_conjuro:byte):boolean;
    function NivelMaximoQuePuedeReparar(TipoReparacion:TTipoReparacion):integer;
    function PuedeActivarIraTenax:byte;
    function PuedeActivarZoomorfismo:byte;
    function PuedeOcultarse:byte;
    function PorcentajeDeDefensaTotal:integer;
    function CalcularModificacionPrecio(Precio,inflacion:integer;EsPrecioVenta,BonoClan:bytebool):integer;
    function ExtraerDatosEnCadena:Tcadena127;
    function NombreCategoria:string;
    function Reputacion:string;
    function ListarPericias:Tcadena127;
    function CamaradasPartyACadena:TCadena15;
    function ObtenerFlagsDeObjetosNulos:Integer;
    function nivelTruncado:byte;
    function TiempoConjuro(EsConjuroArcano:boolean):byte;
    function BonoPorVencerAEsteJugador:integer;
  end;

  TClanJugadores=Class(TObject)
  public
    //colores 30 bits (6*5), 2 últimos bits=modelo de estandarte
    Nombre:TCadena23;
    PendonClan:TBanderaClan;//modelo y colores de estandarte
    Lider:TCadenaLogin;
    CodigoClan:byte;
    MiembrosActivos:word;//20
    UltimoLogIn:word;//-30000 días de TdateTime
    ColorClan:byte;
    Nousado1:byte;
    IdentificadorDeClan:integer;
    constructor create(codigoClan_n:byte);
  end;

  procedure InicializarMonstruos(const nombre:string);
  procedure InicializarMapeoAtaques(const nombre:string);
  procedure InicializarMapeoAnimaciones(const nombre:string);
  procedure DefinirHabilidadesAlAzar(var DatosPJ:TDatosNuevoPersonaje);
  function ContarPericias(const Pericias:word):integer;
  procedure P_GirarHaciaDireccion(var dir:TDireccionMonstruo;const dirDestino:TDireccionMonstruo);
  procedure P_DarVueltaDireccion(var dir:TDireccionMonstruo);
  procedure P_anteriorDireccion(var dir:TDireccionMonstruo);
  procedure P_siguienteDireccion(var dir:TDireccionMonstruo);
  function calcularDirExacta(deltax,deltay:integer):TDireccionMonstruo;
  function calcularDireccion(deltax,deltay:integer;const exacto:bytebool):TDireccionMonstruo;
  function SeleccionarAtaqueMonstruo:byte;
  function maximo2(a,b:integer):integer; register;
var
  //Inicializado desde el modulo "Mundo" en el servidor
  //  "       "             "    "Juego" en el cliente
  InfMon:TInformacionMonstruos;
  InfMapeoAtaques:TInformacionDeMapeoDeAtaques;
  InfMapeoAnimaciones:TInformacionDeMapeoDeAnimaciones;
  PosicionesInicialesDeAvatares:array[0..9,0..2] of byte;

implementation

function maximo2(a,b:integer):integer; register;
asm
  cmp eax,edx
  jg @AEsMayor
    mov eax,edx
  @AEsMayor:
end;

procedure InicializarMonstruos(const nombre:string);
var f:file of TDescripcionMonstruoYTipo;
    des:TDescripcionMonstruoYTipo;
    n:integer;
begin
  assignfile(f,nombre);
  filemode:=0;//read only
  reset(f);
  for n:=0 to filesize(f)-1 do
  begin
    read(f,des);
    if des.tipoMonstruo<=Fin_tipo_monstruos then
      InfMon[des.tipoMonstruo]:=des.descripcion;
  end;
  closefile(f);
end;

procedure InicializarMapeoAtaques(const nombre:string);
var f:file of TInformacionDeMapeoDeAtaques;
begin
  assignfile(f,nombre);
  filemode:=0;//read only
  reset(f);
  read(f,InfMapeoAtaques);
  closefile(f);
end;

procedure InicializarMapeoAnimaciones(const nombre:string);
var f:file of TInformacionDeMapeoDeAnimaciones;
begin
  assignfile(f,nombre);
  filemode:=0;//read only
  reset(f);
  read(f,InfMapeoAnimaciones);
  closefile(f);
end;

//Utilitarios:
function ContarPericias(const Pericias:word):integer;
var i:integer;
begin
  result:=0;
  for i:=0 to 15 do
    if Pericias and (1 shl i)<>0 then inc(result);
end;

procedure DefinirHabilidadesAlAzar(var datosPJ:TDatosNuevoPersonaje);
var FRZ,CON,INT,SAB,DES:byte;
    cd_categoria,cd_raza:byte;
    procedure LlenarArregloHabilidades(var habil:TArregloHabilidades);
    begin
      habil[HbFuerza]:=FRZ;
      habil[HbConstitucion]:=CON;
      habil[HbInteligencia]:=INT;
      habil[HbSabiduria]:=SAB;
      habil[HbDestreza]:=DES;
    end;
    procedure VaciarArregloHabilidades(const habil:TArregloHabilidades);
    begin
      with datosPJ do
      begin
        FRZ:=habil[HbFuerza];
        CON:=habil[HbConstitucion];
        INT:=habil[HbInteligencia];
        SAB:=habil[HbSabiduria];
        DES:=habil[HbDestreza];
      end;
    end;
    procedure Minimo(mnFRZ,mnDES,mnCON,mnINT,mnSAB:byte);
    begin
      if FRZ<mnFRZ then FRZ:=mnFRZ;
      if DES<mnDES then DES:=mnDES;
      if CON<mnCON then CON:=mnCON;
      if INT<mnINT then INT:=mnINT;
      if SAB<mnSAB then SAB:=mnSAB;
    end;
    procedure Inicializar_por_Raza;
      procedure Inicializar(inFRZ,inDES,inCON,inINT,inSAB:byte);
      begin
        FRZ:=inFRZ;
        DES:=inDES;
        CON:=inCON;
        INT:=inINT;
        SAB:=inSAB;
      end;
    begin
      case cd_raza of //sumados max 16;
        rzElfo:Inicializar(1,7,1,6,1);
        rzSemielfo:Inicializar(1,6,1,5,1);
        rzEnano:Inicializar(5,1,8,1,1);
        rzGnomo:Inicializar(1,5,3,6,1);
        rzOrco:Inicializar(7,1,6,1,1);
        rzDrow:Inicializar(1,6,1,7,1);
        else Inicializar(1,1,1,1,1);
      end;
    end;
    procedure Minimos_por_Categoria;//sumados max. 24
    begin
      case cd_categoria of
        ctPaladin:Minimo(6,1,4,1,8);//+4
        ctGuerrero:Minimo(10,4,6,1,1);//+2
        ctMago:Minimo(1,4,1,10,4);//+4
        ctClerigo:Minimo(4,1,2,1,10);//+6
        ctBardo:Minimo(4,9,1,9,1);//24
        ctGuerreroMago:Minimo(9,4,1,9,1);//24
        ctBribon:Minimo(6,10,1,4,1);//+2
        ctMontaraz:Minimo(4,9,1,1,9);//24
      end;
    end;
    procedure Agregar_Restantes_Al_azar;
    var PuntosPorDistribuir,HbSeleccionada:integer;
        Habilidades:TArregloHabilidades;
    begin
      PuntosPorDistribuir:=MAX_HABILIDADES_SUMADAS-FRZ-DES-CON-INT-SAB;
      LlenarArregloHabilidades(Habilidades);
      if PuntosPorDistribuir<=2 then
      begin
        FRZ:=0;INT:=0;DES:=0;SAB:=0;CON:=0;
        LlenarArregloHabilidades(Habilidades);
      end
      else
      while PuntosPorDistribuir>0 do
      begin
        HbSeleccionada:=random(5);
        if Habilidades[HbSeleccionada]<20 then
        begin
          dec(PuntosPorDistribuir);
          inc(Habilidades[HbSeleccionada])
        end;
      end;
      VaciarArregloHabilidades(Habilidades);
    end;
begin
  with datosPJ do
  begin
    cod_categoria:=cod_categoria and $7;
    cod_raza:=cod_raza mod 7;
    cd_categoria:=cod_categoria;
    cd_raza:=cod_raza;
  end;
  Inicializar_Por_Raza;
  Minimos_Por_Categoria;
  Agregar_Restantes_Al_azar;
end;

function SeleccionarAtaqueMonstruo:byte;
begin
  result:=random(4);
  if result>=3 then dec(result,3);
end;

procedure P_GirarHaciaDireccion(var dir:TDireccionMonstruo;const dirDestino:TDireccionMonstruo);
begin
  if dir<>dirDestino then
    if (MC_ordenDireccion[dirDestino]-MC_ordenDireccion[dir]) and $7<4 then
      dir:=MC_siguienteDireccion[dir] else dir:=MC_anteriorDireccion[dir];
end;

procedure P_DarVueltaDireccion(var dir:TDireccionMonstruo);
begin
  dir:=MC_darVueltaDireccion[dir];
end;

procedure P_anteriorDireccion(var dir:TDireccionMonstruo);
begin
  dir:=MC_anteriorDireccion[dir];
end;

procedure P_siguienteDireccion(var dir:TDireccionMonstruo);
begin
  dir:=MC_siguienteDireccion[dir];
end;

CONST
  UMBRAL_MOVIMIENTO_EN_Y=106;
  UMBRAL_MOVIMIENTO_EN_X=618;

function calcularDirExacta(deltax,deltay:integer):TDireccionMonstruo;
var factor:integer;
begin
  if (deltax<>0) then
  begin
    factor:=(abs(deltay) shl 8) div abs(deltax);
    if factor<=UMBRAL_MOVIMIENTO_EN_Y then
      deltay:=0
    else
      if factor>=UMBRAL_MOVIMIENTO_EN_X then
        deltax:=0;
    if deltaX<-1 then deltaX:=-1
      else if deltaX>1 then deltaX:=1;
  end;
  if deltaY<-1 then deltaY:=-1
    else if deltaY>1 then deltaY:=1;
  result:=MC_Direccion[deltaX,deltaY];
end;

function calcularDireccion(deltax,deltay:integer;const exacto:bytebool):TDireccionMonstruo;
var factor:integer;
begin
  if exacto and (deltax<>0) then
  begin
    factor:=(abs(deltay) shl 8) div abs(deltax);
    if factor<=UMBRAL_MOVIMIENTO_EN_Y then
      deltay:=0
    else
      if factor>=UMBRAL_MOVIMIENTO_EN_X then
        deltax:=0;
  end;
  if deltaX<-1 then deltaX:=-1
    else if deltaX>1 then deltaX:=1;
  if deltaY<-1 then deltaY:=-1
    else if deltaY>1 then deltaY:=1;
  result:=MC_Direccion[deltaX,deltaY];
end;


//Demonios
//================================================
// TMonstruo
//******************
constructor TMonstruoS.create(codigo_n:word);
begin
  inherited create;
  codigo:=codigo_n;
  TipoMonstruo:=Inicio_tipo_monstruos;
  comportamiento:=0;//de monstruo
  Control_Movimiento:=codigo and $1;
  codNido:=Ninguno;
  activo:=false;
  hp:=0;
end;

procedure TMonstruoS.activar(const x,y:byte);
var i:integer;
begin
  if not (self is TjugadorS) then
  begin//solo monstruos
    if comportamiento=comComerciante then
    begin
      hp:=0;{Invulnerable}
      dir:=dsSud;
    end
    else
    begin
      PericiasDinamicas:=InfMon[TipoMonstruo].PericiasMonstruo and $FF;
      comportamiento:=InfMon[TipoMonstruo].Comportamiento;
      mana:=InfMon[TipoMonstruo].nivelMonstruo;
      i:=InfMon[TipoMonstruo].HPPromedio;
      inc(i,(i shr 2)-random(i shr 1));
      if i>MAX_DEMONIO_HP then hp:=MAX_DEMONIO_HP else hp:=i;
      duenno:=ccSinDuenno;
      dir:=random(8);//8 direcciones.
    end;
    codAnime:=TipoMonstruo;
    banderas:=0;
    ObjetivoASeguir:=ccVac;
    for i:=0 to MAX_TIMERS_DEMONIO do fTimer[i]:=0;
  end;
  ObjetivoAtacado:=ccVac;
  coordx:=x;
  coordy:=y;
  accion:=aaParado;
  activo:=true;
end;

function TMonstruoS.mejorar(MatoAUnJugador:boolean):boolean;
//devuelve true si subio su nivel de poder
var nuevoNivel,maxRegeneracion:integer;
begin
  result:=false;
  if TipoMonstruo>=Inicio_tipo_monstruos then //solo monstruos
  with InfMon[TipoMonstruo] do
  begin
    if comportamiento=comComerciante then
      hp:=0//invulnerabilidad para comerciantes
    else
    begin
      if MatoAUnJugador and (comportamiento<comMonstruoConjurado) and (ConsecuenciaMuerte=cmNinguno) then
      begin
        //subir de nivel de poder: (0=normal a 3=campeon)
        result:=true;
        nuevoNivel:=(banderas and MskPoderMonstruo) shr DsPoderMonstruo;
        if nuevoNivel<3 then inc(nuevoNivel);
        banderas:=(banderas or MskPoderMonstruo) and (nuevonivel shl DsPoderMonstruo);
        if nuevoNivel>=1 then
        begin
          banderas:=banderas or BnArmadura;
          if nuevoNivel>=2 then
          begin
            banderas:=banderas or BnVisionVerdadera;
            if nuevoNivel>=3 then
            case comportamiento of
              comAtaqueRango,comPacifico,comHerbivoro:banderas:=banderas or BnApresurar;
              comAgresivo,comTerritorial,comGuardia:banderas:=banderas or BnFuerzaGigante;
              comAtaqueHechizos,comGuerreroMago:banderas:=banderas or BnProteccion;
            end;
          end;
        end;
      end
      else
        nuevoNivel:=0;
      //Con cada victoria se regenera en 50% de su HPpromedio.
      maxRegeneracion:=HPPromedio;
      inc(maxRegeneracion,maxRegeneracion shr 2);//HPPromedio+25%
      inc(maxRegeneracion,nuevoNivel shl BONO_HP_POR_NIVEL_PODER);//Bono por niveles
      if maxRegeneracion>MAX_DEMONIO_HP then maxRegeneracion:=MAX_DEMONIO_HP;
      //Ahora nuevoNivel calcula el nivel de hp
      nuevoNivel:=hp+(HPPromedio shr 1);
      if nuevoNivel>maxRegeneracion then hp:=maxRegeneracion else hp:=nuevoNivel;
    end;
    ObjetivoAtacado:=ccVac;
  end;
end;

function TMonstruoS.esNecesarioSanar():boolean;
begin
  result:=longbool(banderas and MskBanderasSanadas);
end;

function TMonstruoS.esNecesarioDisiparMagia:boolean;
begin
  result:=longbool(banderas and MskBanderasNegativasDisipables);
end;

procedure TMonstruoS.disiparMagia();
begin
  banderas:=banderas and MskBanderasNoMagia;
  fTimer[byte(tdInvisible)]:=0;
  fTimer[byte(tdArmadura)]:=0;
  fTimer[byte(tdFuerzaGigante)]:=0;
  fTimer[byte(tdApresurar)]:=0;
  fTimer[byte(tdProteccion)]:=0;
  fTimer[byte(tdVisionVerdadera)]:=0;
  fTimer[byte(tdParalisis)]:=0;
  fTimer[byte(tdIraTenax)]:=0;
end;

procedure TMonstruoS.AnimarAtaque;
begin
  if accion<aaAtacando1 then
    accion:=aaAtacando1;
end;

procedure TMonstruoS.inicializarTimer(TipoTimer:TTimerDemonio;valor:byte);
begin
  if fTimer[byte(TipoTimer)]<valor then fTimer[byte(TipoTimer)]:=valor;
end;

procedure TMonstruoS.ReducirTiempoDeTimer(TipoTimer:TTimerDemonio;ticksReducidos:byte);
var tiempoTimer:byte;
begin
  tiempoTimer:=fTimer[byte(TipoTimer)];
  if tiempoTimer>ticksReducidos then
    fTimer[byte(TipoTimer)]:=tiempoTimer - ticksReducidos
  else
    if tiempoTimer>=1 then
      fTimer[byte(TipoTimer)]:=1;
end;

function TMonstruoS.TickTimer(TipoTimer:TTimerDemonio):bytebool;
//Sólo es verdad si el timer estaba en 1.
begin
  result:=fTimer[byte(TipoTimer)]=1;
  if fTimer[byte(TipoTimer)]>0 then dec(fTimer[byte(TipoTimer)]);
end;

function TMonstruoS.TimerActivo(TipoTimer:TTimerDemonio):bytebool;
begin
  result:=fTimer[byte(TipoTimer)]>0;
end;

procedure TMonstruoS.TerminarTimer(TipoTimer:TTimerDemonio);
begin
  if fTimer[byte(TipoTimer)]>0 then fTimer[byte(TipoTimer)]:=1;
end;

//si fallo el conjuro devuelve el codigo de error, caso contrario devuelve i_ok
function TMonstruoS.RealizarResistenciaMagica{(ConjuroAgresivo:bytebool)}:byte;
var nivelResistencia:byte;
begin
  nivelResistencia:=(InfMon[TipoMonstruo].resistencias shr 28) and $7;
  if nivelResistencia=0 then
    result:=i_ok
  else
    if nivelResistencia=7 then
      result:=i_EsInvulnerableAConjuros
    else
      if random(8)>nivelResistencia then
        result:=i_ok
      else
        result:=i_falloElConjuro;
  //1 (25%) 2 (37.5%) 3 (50%) 4 (62.5%) 5 (75%) 6 (87.5%)
end;

//***************************************************************************
// TJugador
//***************************************************************************

procedure TjugadorS.DefinirCapacidadIdentificacion;
begin
  if longBool(Banderas and BnVisionVerdadera) or (Usando[uAmuleto].id=ihAmuletoVisionVerdadera) then
    CapacidadId:=ciVerRealmente
  else
    case codCategoria of
      ctClerigo,ctPaladin:CapacidadId:=ciMaldad;
      ctMago,ctGuerreroMago:CapacidadId:=ciMagia;
      else
        CapacidadId:=0;
    end;
end;

procedure TjugadorS.CalcularHP;
//Por nivel, clase y CON
var bono:integer;
begin
  case codCategoria of
    ctGuerrero:bono:=16;
    ctPaladin:bono:=14;
    ctMago:bono:=8;
    else
      bono:=12;
  end;
  //Por constitucion
  inc(bono,CON);
  //Por nivel
  if nivel<=24 then
    bono:=(bono*nivel) shr 1
  else
    bono:=(bono*(nivel + 24)) shr 2;//niveles 25+
  inc(bono,CON+10);
  if bono>=MAX_DEMONIO_HP then bono:=MAX_DEMONIO_HP;
  MaxHP:=bono;
end;

procedure TjugadorS.CalcularNivelAtaque;
//Por nivel, clase y DES
var bono,bonoSuperior:integer;
begin
  case codCategoria of
    ctPaladin:
      if (comportamiento<0) then
        bono:=2
      else
        bono:=6;
    ctGuerrero,ctMontaraz,ctBribon:bono:=6;
    else
      bono:=4;
  end;
  inc(bono,DES);
  if longbool(banderas and BnZoomorfismo) then inc(bono,4);
  //Por nivel
  if nivel<=24 then
    bono:=(bono*nivel) shr 3
  else
  begin
    bono:=bono*3;//24 niveles anteriores
    bonoSuperior:=0;
    if (DES>17) then inc(bonoSuperior,DES-17);
    inc(bono,bonoSuperior*(nivel-24));
  end;
  if LongBool(Banderas and bnAturdir) then dec(bono,PENA_MALDICION_ATURDIR);
  if bono<0 then bono:=0;
  if bono>250 then bono:=250;
  NivelAtaque:=bono;
end;

procedure TjugadorS.CalcularMana;
// por nivel, INT, SAB y Clase
var bono,bonoSuperior:integer;
begin
  case codCategoria of
    ctMago:bono:=40;
    ctGuerreroMago,ctClerigo:bono:=15;
    ctPaladin,ctBardo,ctMontaraz:bono:=1;
    else
    begin//clases no magicas
      maxmana:=0;
      Meditacion255:=0;
      exit;
    end;
  end;
  //Por INT y SAB
  case codCategoria of
    ctMago,ctGuerreroMago,ctBardo:inc(bono,(INT shl 1)+SAB);
    ctClerigo,ctPaladin,ctMontaraz:inc(bono,(SAB shl 1)+INT);
  end;
  //Por Nivel
  if nivel<=24 then
    bono:=(bono*nivel) shr 4
  else
  begin
    bono:=(bono*3) shr 1;
    bonoSuperior:=0;
    if (INT>17) then inc(bonoSuperior,INT-17);
    if (SAB>17) then inc(bonoSuperior,SAB-17);
    inc(bono,(bonoSuperior*(nivel-24)));
  end;
  if bono<3 then bono:=3;
  if bono>=255 then
  begin
    Meditacion255:=(bono-251) shr 2;
    bono:=255;
  end
  else
    Meditacion255:=0;
  MaxMana:=bono;
end;

procedure TjugadorS.CalcularDannoBase;
//Por FRZ
begin
  if FRZ<=20 then DannoBase:=FRZ else DannoBase:=0;//castigar a tramposos
  if longbool(banderas and BnFuerzaGigante) then inc(DannoBase,8);
  if longbool(banderas and BnIraTenax) then inc(DannoBase,12);
  DannoBase:=DannoBase shl 2;
end;

procedure TjugadorS.CalcularDefensa;
//Por DES, Clase y modificadores
var defensa_basico,bono:integer;
begin
  case codCategoria of
    ctPaladin:
      if (comportamiento<0) then
        bono:=0
      else
        bono:=2;
    ctBribon,ctBardo:bono:=2;
  else
    bono:=1;//Otros
  end;
  defensa_basico:=46;
  if longbool(banderas and BnZoomorfismo) then inc(bono,2);
  inc(defensa_basico,nivel);
  if DES<=20 then
    inc(defensa_basico,DES*bono);
  if longbool(banderas and BnArmadura) then inc(defensa_basico,BONO_CONJURO_ARMADURA);
  if longbool(banderas and BnIraTenax) then dec(defensa_basico,PENA_DEFENSA_IRA_TENAX);
  if LongBool(Banderas and bnAturdir) then dec(defensa_basico,PENA_MALDICION_ATURDIR);
  if defensa_basico<0 then
    defensa_basico:=0
  else
    if defensa_basico>255 then
      defensa_basico:=255;
  Defensa:=defensa_basico;
end;

procedure TjugadorS.CalcularModDefensa;
var modificadores_defensa,i,id,bonoMagico,bono:integer;
    TipoDanno:TTipoArma;
begin
  modificadores_defensa:=0;
  bonoMagico:=0;
  FillChar(armadura,sizeof(armadura),0);
  //Modificadores de agilidad para la defensa
  for i:=uArmadura to uAnillo do
    inc(modificadores_defensa,ModificadorDefensaObjeto(Usando[i]));//ModificadorAC verifica tipo_de objeto.
  for i:=uArmadura to uAnillo do
  begin
    TipoDanno:=taMagia;
    bono:=ModificadorDanno(Usando[i],TipoDanno);
    if TipoDanno=taMagia then
      inc(bonoMagico,bono)
    else
      inc(armadura[integer(TipoDanno)],bono);//ModificadorDaño verifica tipo_de objeto.
  end;
  for i:=uArmaDer to uArmaIzq do
    if (Usando[i].id shr 3)=10 then//Control sólo para Escudos
    begin
      inc(modificadores_defensa,CalcularModificadorAtaDef(Usando[i]));//Calcular modificador no verifica tipo_de objeto.
      TipoDanno:=taMagia;
      bono:=CalcularBono(Usando[i],TipoDanno);
      if TipoDanno=taMagia then
        inc(bonoMagico,bono)
      else
        inc(armadura[integer(TipoDanno)],bono);
    end;
  if modificadores_defensa>125 then modificadores_defensa:=125;
  if modificadores_defensa<-125 then modificadores_defensa:=-125;
  modDefensa:=modificadores_defensa;
  //Modificadores de armadura
  id:=Usando[uArmadura].id;
  if (id>=56) and (id<80) then
  begin
    inc(armadura[integer(taPunzante)],InfObj[id].danno1B);
    inc(armadura[integer(taCortante)],InfObj[id].danno1P);
    inc(armadura[integer(taContundente)],InfObj[id].danno2B);
    inc(bonoMagico,InfObj[id].danno2P);
  end;
  //Modificadores de armadura de cabeza
  id:=Usando[uCasco].id;
  if (id>=88) and (id<96) then
  begin
    inc(armadura[integer(taPunzante)],InfObj[id].danno1B);
    inc(armadura[integer(taCortante)],InfObj[id].danno1P);
    inc(armadura[integer(taContundente)],InfObj[id].danno2B);
    inc(bonoMagico,InfObj[id].danno2P);
  end;
  //Bonos por hechizos mágicos positivos y negativos
  inc(armadura[integer(taHielo)],bonoMagico);
  inc(armadura[integer(taFuego)],bonoMagico);
  inc(armadura[integer(taRayo)],bonoMagico);
  inc(armadura[integer(taVeneno)],bonoMagico);
  //Otros modificadores
  DefinirCapacidadIdentificacion;
  //cada 2bits indica una resistencia, con valores 0,1,2,3
  bonoMagico:=usando[uAmuleto].modificador shr 5;
  if bonoMagico>0 then
  begin
    if bonoMagico>3 then bonoMagico:=3;
    case usando[uAmuleto].id of
      orGemaVeneno:inc(armadura[integer(taVeneno)],bonoMagico);
      orGemaFuego:inc(armadura[integer(taFuego)],bonoMagico);
      orGemaHielo:inc(armadura[integer(taHielo)],bonoMagico);
      orGemaRayo:inc(armadura[integer(taRayo)],bonoMagico);
    end;
  end;
end;

function TjugadorS.PorcentajeDeDefensaTotal:integer;
begin
  result:=defensa+modDefensa;
  if LongBool(Banderas and BnModoDefensivo) then
  begin
    Banderas:=Banderas xor bnModoDefensivo;
    inc(result,5);
    if (Usando[uArmaDer].id shr 3)=10 then//Escudos
      inc(result,CalcularModificadorAtaDef(Usando[uArmaDer]));
    if (Usando[uArmaIzq].id shr 3)=10 then//Escudos
      inc(result,CalcularModificadorAtaDef(Usando[uArmaIzq]));
    //cast a smallint para que funcione "shr 3" con negativos como "div 8"
    inc(result,smallint((result*DES) shr 2));
  end;
  if ((accion=aadescansando) or (accion=aameditando)) and (result>0) then result:=0;
end;

procedure TjugadorS.determinarAnimacion;
var genero,artefacto:integer;
begin
  //32 objetos,8clases,8razas,2generos
  if esVaron() then genero:=0 else genero:=1 shl 11;
  if (Usando[uarmadura].id>=4) then
  begin
    artefacto:=Usando[uarmadura].id-56;
    if (artefacto>=24) then dec(artefacto,168);
  end
  else
    if (hp=0) and (nivel>MAX_NIVEL_NEWBIE) then
      artefacto:=31//animacion para fantasma de no newbie
    else
      artefacto:=30;//sin armadura/vestimenta
  codAnime:=InfMapeoAnimaciones[(artefacto+(CodCategoria shl 5)+(TipoMonstruo shl 8)+genero) and $FFF];
end;

procedure TjugadorS.AnimarConjuro;
var item:byte;
begin
  item:=usando[0].id;
  if codAnime<=Fin_animaciones_avatares then//si es animacion de avatar
    case InfObj[item].TipoAnimacion of
      taaPunno,taaManoMagia:
        case InfMapeoAtaques[codAnime].ConArmas of
          3,4:accion:=aaAtacando4;
        else
          accion:=aaAtacando1;
        end;
      taaCetroMago,taaCayadoMelee:
        case InfMapeoAtaques[codAnime].ConArmas of
          2,3,5:accion:=aaAtacando5;
          0,1,4:accion:=aaAtacando2;
        else
          accion:=aaAtacando1;
        end;
      taaSimboloSagrado:
        case InfMapeoAtaques[codAnime].ConArmas of
          4:accion:=aaAtacando5;
        else
          accion:=aaAtacando1;
        end;
      else
        accion:=aaAtacando1;
    end
  else
    accion:=aaAtacando1;
end;

procedure TjugadorS.AnimarAtaque;
var item,itemSec:byte;
begin
  item:=usando[0].id;
  itemSec:=usando[1].id;
  if (InfObj[item].TipoAnimacion=taaNinguno) and (InfObj[itemSec].TipoAnimacion<>taaNinguno) then
    item:=itemSec;
//Determinar animacion:
//Estilos:
//0: Puños/daga, Maza, Espada, Hacha, Arma de rango
//1: Puños/daga, Maza, Espada, Pica, Arma de rango
//2: Puños/daga, Maza, Espada, Arma de rango, Cetro
//3: Puños/daga, Hielo, Fuego, Manos magia, Cetro
//4: Puños/daga, Maza, Fuego, Manos magia, Simbolo
//5: Puños/daga, Pica, Espada, Arma de rango, Cetro
//6: Todos, [No asignar], [No asignar], [No asignar], [No asignar]
  if codAnime<=Fin_animaciones_avatares then//si es animacion de avatar
    case InfObj[item].TipoAnimacion of
      taaEspada:
        case InfMapeoAtaques[codAnime].ConArmas of
          6:accion:=aaAtacando1;
        else
          accion:=aaAtacando3;
        end;
      taaHacha:
        case InfMapeoAtaques[codAnime].ConArmas of
          0:accion:=aaAtacando4;
          1,2,5:accion:=aaAtacando3;
          4:accion:=aaAtacando2;
        else
          accion:=aaAtacando1;
        end;
      taaPica:
        case InfMapeoAtaques[codAnime].ConArmas of
          0,2:accion:=aaAtacando3;
          1:accion:=aaAtacando4;
          5:accion:=aaAtacando2;
        else
          accion:=aaAtacando1;
        end;
      taaMaza,taaMangual,taaCayadoMelee://taaCayadoMelee(!)
        case InfMapeoAtaques[codAnime].ConArmas of
          0,1,2,4:accion:=aaAtacando2;
        else
          accion:=aaAtacando1;
        end;
      taaArco,taaBallesta,taaArcabuz:
        case InfMapeoAtaques[codAnime].ConArmas of
          0,1:accion:=aaAtacando5;
          2,5,3,4:accion:=aaAtacando4;
        else
          accion:=aaAtacando1;
        end;
      taaManoMagia:
        case InfMapeoAtaques[codAnime].ConArmas of
          3,4:accion:=aaAtacando4;
        else
          accion:=aaAtacando1;
        end;
      taaCetroMago:
        case InfMapeoAtaques[codAnime].ConArmas of
          2,3,5:accion:=aaAtacando5;
          0,1,4:accion:=aaAtacando2;
        else
          accion:=aaAtacando1;
        end;
      taaSimboloSagrado:
        case InfMapeoAtaques[codAnime].ConArmas of
          4:accion:=aaAtacando5;
        else
          accion:=aaAtacando1;
        end;
      taaEspadaHielo:
        case InfMapeoAtaques[codAnime].ConArmas of
          0,1,2,5:accion:=aaAtacando3;
          3:accion:=aaAtacando2;
        else
          accion:=aaAtacando1;
        end;
      else//taaNinguno,taaPunno,taaDaga,taaBallestaMano
        accion:=aaAtacando1;
    end
  else
    accion:=aaAtacando1;//animacion de monstruo = 1 ataque
end;

procedure TjugadorS.ObtenerPosicionInicial(var nMapa,px,py:byte);
begin
  nMapa:=PosicionesInicialesDeAvatares[TipoMonstruo and $7,0];
  px:=PosicionesInicialesDeAvatares[TipoMonstruo and $7,1];
  py:=PosicionesInicialesDeAvatares[TipoMonstruo and $7,2];
end;

function TjugadorS.nuevoPersonaje(const datosPJ:TDatosNuevoPersonaje):boolean;
var i:integer;
  function VerificarDatosIniciales:boolean;
  begin
    //raza y categoría
    result:=false;
    if TipoMonstruo>6 then exit;
    if codCategoria>7 then exit;
    if bytebool(categoriasDenegadas[TipoMonstruo] and (1 shl codcategoria)) then exit;
    //Habilidades
    if (FRZ+INT+SAB+CON+DES<>MAX_HABILIDADES_SUMADAS) then exit;
    if (contarPericias(pericias)<>MAX_PERICIAS) then exit;
    if longbool(pericias and PericiasDenegadas[codCategoria]) then exit;
    result:=true;
  end;

  procedure Definir_Especialidad_Armas;
  begin
    NivelEspecializacion:=1;
    case codCategoria of
      ctGuerrero:
      begin
        case tipoMonstruo of
          rzEnano:EspecialidadArma:=24;//hacha de mano
          rzOrco:EspecialidadArma:=35;//garrote de puas
          else EspecialidadArma:=18;//espada corta
        end;
      end;
      ctBribon:
        EspecialidadArma:=16;//daga
      else
      begin
        EspecialidadArma:=7;//no es arma
        NivelEspecializacion:=0;
      end;
    end;
  end;

  procedure Equipo_inicial;
  var i:integer;
  begin
    Usando[0]:=ObjetoArtefacto(16,60);//daga
    for i:=1 to 7 do
      Usando[i]:=ObManoIzqVacia;
    Artefacto[0]:=ObjetoArtefacto(144,10);//comida
    Artefacto[1]:=ObjetoArtefacto(152,10);//agua
    Artefacto[2]:=ObjetoArtefacto(222,25);//vendas
    Artefacto[3]:=ObjetoArtefacto(ihAfilador,50);
    Artefacto[4]:=ObjetoArtefacto(orLenna,50);
    Artefacto[5]:=ObjetoArtefacto(orBebidaAntiVeneno,50);
    for i:=6 to MAX_ARTEFACTOS do
      Artefacto[i]:=ObNuloMDV;
    case codCategoria of
      ctGuerrero,ctPaladin,ctMontaraz,ctClerigo,ctBribon:
      begin
        Usando[1]:=ObjetoArtefacto(80,35);//rodela
        Usando[uArmadura]:=ObjetoArtefacto(56,35);
        Usando[uCasco]:=ObjetoArtefacto(88,35);
        if (codCategoria<>ctBribon) then
          Artefacto[6]:=ObjetoArtefacto(34,50);//garrote
      end
      else
        Artefacto[6]:=ObjetoArtefacto(orBebidaMasMANA,20);
        Artefacto[7]:=ObjetoArtefacto(orBebidaMasHP,40);
    end;
  end;
  function DefinirRostro:byte;
  begin
    if byteBool(DatosPJ.Cod_genero) then //Mujeres
      case DatosPJ.cod_raza of
        rzEnano:result:=58;
        rzGnomo:result:=59;
        rzHumano:result:=random(8)+40;
        rzSemielfo:result:=random(12)+40;
        rzElfo:result:=random(8)+44;
        rzOrco:result:=56+random(2);
        rzDrow:result:=60+random(2);
      else
        result:=63;
      end
    else //Varones
      case DatosPJ.cod_raza of
        rzEnano:result:=random(8);
        rzGnomo:result:=random(8)+8;
        rzHumano:result:=random(8)+16;
        rzSemielfo:result:=random(8)+20;
        rzElfo:result:=random(8)+24;
        rzOrco:result:=random(8)+32;
        rzDrow:result:=random(4)+52;
      else
        result:=63;
      end
  end;
  procedure Conjuros_iniciales;
  begin
    case codCategoria of
      ctMago:conjuroElegido:=6;
      ctClerigo,ctPaladin,ctMontaraz:conjuroElegido:=9;
      else conjuroElegido:=18;
    end;
    Conjuros:=1 shl conjuroElegido;
  end;
begin
  result:=false;
//Definidos por el clente
  codCategoria:=DatosPJ.cod_categoria;
  TipoMonstruo:=DatosPJ.Cod_raza;
  FRZ:=DatosPJ.FRZ;
  CON:=DatosPJ.CON;
  INT:=DatosPJ.INT;
  DES:=DatosPJ.DES;
  SAB:=DatosPJ.SAB;
  Pericias:=DatosPJ.Pericias;
  if not VerificarDatosIniciales then exit;
  nombreAvatar:=DatosPJ.nombre;
//Predeterminados
  for i:=0 to MAX_TIMERS_DEMONIO do ftimer[i]:=0;
  RitmoDeVida:=0;//=P (ritmo, usado aqui como "Agresividad" en 0)
  comida:=maxComida;
  comportamiento:=comNormal;
  Clan:=ninguno;
  fCodCara:=DefinirRostro;
  HabilidadResaltada:=MC_HabilidadBase[codCategoria];
  ObtenerPosicionInicial(codMapa,coordx,coordy);
//Inicialización en nivel 1
  experiencia:=0;
  NivelDeCategoria:=MIN_NIVEL_CATEGORIA;//Cuando el nivel sea igual a este,
  nivel:=0;
  ModificarExperiencia(1);//Subir de nivel a 1.
  hp:=maxHp;
  mana:=maxMana;
//Inicialización de Objetos
  Equipo_inicial;
  Definir_Especialidad_Armas;
  Conjuros_Iniciales;
  dinero:=150;
  dineroBanco:=0;
  CalcularModDefensa;
  DeterminarAnimacion;
  result:=true;
end;

function TjugadorS.esVaron:bytebool;
begin
  result:=(fCodCara<40) or ((fCodCara>=52) and (fCodCara<=55));
end;

function ExperienciaNecesaria(Nivel:byte):word;
var expTemp:integer;
begin
  expTemp:=nivel*(nivel+1)*100;
  if expTemp>MAXIMA_EXPERIENCIA_FALTANTE then
    result:=MAXIMA_EXPERIENCIA_FALTANTE
  else
    result:=expTemp;
end;

function TjugadorS.BonoPorVencerAEsteJugador():integer;
begin
  result:=ExperienciaNecesaria(nivel)-Experiencia;
  if result<EXPERIENCIA_POR_NIVEL_HONOR then
    result:=0
  else
    result:=result div EXPERIENCIA_POR_NIVEL_HONOR;
end;

procedure TjugadorS.CalculosNuevoNivel;
begin
  CalcularDefensa;
  CalcularDannoBase;
  calcularHP;
  calcularNivelAtaque;
  calcularMana;
  DefinirCapacidadIdentificacion;
  experiencia:=ExperienciaNecesaria(Nivel);
end;

procedure TjugadorS.TruncarArmasMagicasPoderosas;
var i:integer;
begin
  for i:=0 to 7 do
    if EsIdObjetoHechizable(Usando[i].id) then
      TruncarMagiaDeArtefacto(Usando[i]);
  for i:=0 to MAX_ARTEFACTOS do
  begin
    if EsIdObjetoHechizable(Artefacto[i].id) then
      TruncarMagiaDeArtefacto(Artefacto[i]);
    if EsIdObjetoHechizable(Baul[i].id) then
      TruncarMagiaDeArtefacto(Baul[i]);
  end;
end;

procedure TjugadorS.prepararParaIngresarJuego;
var i:integer;
begin
  ConjuroElegido:=ninguno;
  apuntado:=nil;
  MensajesEnviadosEn16Turnos:=0;
  //Aqui estaba inicializado "duenno"
  FlagsComunicacion:=0;
  AccionAutomatica:=aaNinguna;
  calcularHP;
  calcularMana;
  calcularNivelAtaque;
  CalcularDefensa;
  CalcularModDefensa;
  CalcularDannoBase;
//  if hp=0 then codAnime:=moFantasma;//Evitar la mancha de sangre que se mueve.
  for i:=0 to 3 do CamaradasParty[i]:=ccVac;
  TipoTransaccion:=ttNinguna;
{
Los siguientes son actualizados en el cliente en determinadas circunstancias:
  DineroBanco (Al realizar transacciones bancarias)
  Posiciones destino de movimiento (Inicializados al colocar el jugador en un mapa)
}
end;

function TjugadorS.ModificarExperiencia(cantidad:integer):bytebool;
  function SubirNivel:boolean;
    procedure EvitarHabilidadResaltadaAlMaximo;
    begin
      if ElegirHabilidadParaCambiar(HabilidadResaltada and mskHabilidadMejorada,true) then exit;
      if ElegirHabilidadParaCambiar(HbDestreza,true) then exit;
      if ElegirHabilidadParaCambiar(HbConstitucion,true) then exit;
      if ElegirHabilidadParaCambiar(HbFuerza,true) then exit;
      if ElegirHabilidadParaCambiar(HbInteligencia,true) then exit;
      if ElegirHabilidadParaCambiar(HbSabiduria,true) then exit;
    end;
    procedure IncrementarHabilidadResaltada;
    begin
      case (HabilidadResaltada and mskHabilidadMejorada) of
        HbFuerza:inc(FRZ);
        HbInteligencia:inc(INT);
        HbSabiduria:inc(SAB);
        HbDestreza:inc(DES);
        else
          inc(CON);
      end
    end;
    procedure EvitarHabilidadDecrementadaAlMinimo;
    begin
      if ElegirHabilidadParaCambiar(HabilidadResaltada shr 3,false) then exit;
      if ElegirHabilidadParaCambiar(HbDestreza,false) then exit;
      if ElegirHabilidadParaCambiar(HbConstitucion,false) then exit;
      if ElegirHabilidadParaCambiar(HbFuerza,false) then exit;
      if ElegirHabilidadParaCambiar(HbInteligencia,false) then exit;
      if ElegirHabilidadParaCambiar(HbSabiduria,false) then exit;
    end;
    procedure DecrementarHabilidadResaltada;
    begin
      case (HabilidadResaltada shr 3) of
        HbFuerza:dec(FRZ);
        HbInteligencia:dec(INT);
        HbSabiduria:dec(SAB);
        HbDestreza:dec(DES);
        else
          dec(CON);
      end
    end;
  begin
    result:=nivel<NIVEL_MAXIMO;
    if not result then exit;
    if (nivel>=1) then
      if (nivel<=MAX_NIVEL_CON_BONO) then //Bonos en habilidades!!
      begin
        EvitarHabilidadResaltadaAlMaximo;//evitar subir más de 100%
        IncrementarHabilidadResaltada;
        if nivel<MAX_NIVEL_CON_BONO then
          EvitarHabilidadResaltadaAlMaximo//si ya subimos al 100%, elegir otra habilidad
        else
        begin//habilidad a resaltar=habilidad a decrementar
          HabilidadResaltada:=HabilidadResaltada and mskHabilidadMejorada;
          HabilidadResaltada:=HabilidadResaltada or (HabilidadResaltada shl 3);
        end;
      end
      else
      if (HabilidadResaltada shr 3)<>(HabilidadResaltada and mskHabilidadMejorada) then
      begin
        EvitarHabilidadDecrementadaAlMinimo;
        DecrementarHabilidadResaltada;
        EvitarHabilidadDecrementadaAlMinimo;
        EvitarHabilidadResaltadaAlMaximo;//evitar subir más de 100%
        IncrementarHabilidadResaltada;
        EvitarHabilidadResaltadaAlMaximo;//si ya subimos al 100%, elegir otra habilidad
      end;
    inc(nivel);
    CalculosNuevoNivel;
    hp:=maxhp;
    if mana>maxMana then mana:=maxMana;
  end;
begin
  result:=false;
  if experiencia<=cantidad then
    result:=SubirNivel    //subio de nivel
  else
    dec(experiencia,cantidad)
end;

function TjugadorS.TieneInfravision:bytebool;
begin
  result:=(TipoMonstruo=rzElfo) or (TipoMonstruo=rzSemiElfo) or (TipoMonstruo=rzDrow);
end;

function TjugadorS.BuscarObjetoEnInventario(idObj:byte):byte;
//devuelve la posicion o ninguno=255 si no tiene.
var i:integer;
begin
  for i:=0 to MAX_ARTEFACTOS do
    if Artefacto[i].id=idObj then
    begin
      result:=i;
      exit;
    end;
  result:=ninguno;
end;

function TjugadorS.TieneElObjeto(idObj:byte):bytebool;
var i:integer;
begin
  result:=true;
  if idObj<4 then exit;
  for i:=0 to 1 do
    if Usando[i].id=idObj then exit;
  for i:=0 to MAX_ARTEFACTOS do
    if Artefacto[i].id=idObj then exit;
  result:=false;
end;

function TjugadorS.TieneLaLlave(idObj,modificadorObj:byte;flagsCalabozo:integer;var indiceUsando:byte):bytebool;
//indiceUsando<>0 => sólo buscar en las manos.
var i,limite:integer;
//Objeto nulo (id 0..3) => Sin control de objeto
//Modificador=0 => sin control de modificador.
begin
  if (idObj<4) then
  begin
    indiceUsando:=0;
    case idObj of
      1://banderas calabozo
        result:=(FlagsCalabozo and (1 shl modificadorObj))<>0;
      2://honor
        result:=(byte(comportamiento)>=modificadorObj);
      3://banderas jugador
      begin
        i:=modificadorObj and $F;
        case (modificadorObj shr 4) of
          0:result:=NivelAgresividad=0;
          1:result:=codCategoria=i;
          2:result:=tipoMonstruo=i;
          3:result:=nivel>=i*5;
          4:result:=(Pericias and (1 shl i))<>0;
          5:result:=(Pericias and (1 shl (i+16)))<>0;
          6:Result:=hp>=i*10;
          7:Result:=mana>=i*10;
          8:result:=(Conjuros and (1 shl i))<>0;
          9:result:=(Conjuros and (1 shl (i+16)))<>0;
          10:result:=DannoBase>=i shl 3;//nota: danno base esta con (shl 2)
          11:result:=CON>=i shl 1;
          12:result:=INT>=i shl 1;
          13:result:=SAB>=i shl 1;
          14:result:=DES>=i shl 1;
          else
            result:=false;
        end;
      end;
      else
        result:=true;
    end;
    exit;
  end;
  if indiceUsando<>0 then limite:=uArmaIzq else limite:=uAmuleto;
  for i:=uArmaDer to limite do
    if (i<=uArmaIzq) or (i>=uAnillo) then
      if (Usando[i].id=idObj) and ((modificadorObj=0) or (modificadorObj=Usando[i].modificador)) then
      begin
        indiceUsando:=i;
        result:=true;
        exit;
      end;
  result:=false;
end;

function TjugadorS.IntercambiarObjetos(PosObjO,PosObjD:byte):byte;
(*
- Devuelve true si intercambio dos objetos
- Las posiciones indicadas están en el rango 0..7 para los q se están usando
  y 8..MAX_POSICIONES para los de inventario.
- Controla que no se pueda "usar" un objeto no permitido por clase, raza u otros.
*)
var ObjTemp:Tartefacto;
    idObjOrig:byte;
  function VerificarPosicionDestino:byte;
  var ClaseObjetoOrigen:byte;
  begin
    result:=i_CasillaIncorrecta;
    ClaseObjetoOrigen:=idObjOrig shr 3;
    case PosObjD of
      uArmaDer:
      begin
        if (InfObj[idObjOrig].pesoArma=paPesada) and (Usando[uArmaIzq].id>=4) then
          //En caso de tener la mano derecha libre:
          if Usando[uArmaDer].id<4 then
          begin
            Usando[uArmaDer]:=Usando[uArmaIzq];
            Usando[uArmaIzq]:=ObNuloMDV;
          end
          else
          begin
            result:=i_NecesitasAmbasManos;
            exit;
          end;
        //Objetos que nunca se usan en la mano derecha:
        if (ClaseObjetoOrigen=24){gemas no talladas} or
          (idObjOrig=orPergamino) or (idObjOrig=ihVaritaVacia) or (idObjOrig=ihVaritaLlena) then
          begin
            result:=i_ElObjetoVaEnOtraMano;
            exit;
          end;
      end;
      uArmaIzq:
      begin
        if (ClaseObjetoOrigen=14) then//Objetos que nunca se usan en la mano izquierda
        begin
          result:=i_ElObjetoVaEnOtraMano;
          exit;
        end;
        if (InfObj[idObjOrig].pesoArma=paPesada) then
        begin
          result:=i_UsalaEnLaOtraMano;
          exit;
        end
        else
          if (InfObj[idObjOrig].pesoArma=paNormal) and ((hbAmbidextria and Pericias)=0) then
          begin
            result:=i_SinAmbidextria;
            exit;
          end;
        if (InfObj[Usando[uArmaDer].id].pesoArma=paPesada) then
        begin
          Usando[uArmaIzq]:=Usando[uArmaDer];
          Usando[uArmaDer]:=ObNuloMDV;
        end;
      end;
      uBrazaletes:
        if ClaseObjetoOrigen<>12 then exit;
      uAmuleto:
        if (ClaseObjetoOrigen<>22) then
          if DeterminarIconoApropiado(Artefacto[PosObjO])<>PosObjD then exit;
      else
        if DeterminarIconoApropiado(Artefacto[PosObjO])<>PosObjD then exit;
    end;
    result:=i_Ok;
  end;
begin
  if (hp=0) and (comportamiento<=comHeroe) then
  begin
    result:=i_EstasMuerto;exit;
  end;
  result:=i_Error;//No mostrar mensaje de error para este caso
  if PosObjO<>PosObjD then //Que sean distintos
  if (PosObjO>=8) and (PosObjO<=MAX_POSICIONES) and (PosObjD<=MAX_POSICIONES) then //Que su posicion sea válida
    if (PosObjD<8) then//Destino = icono => Equipar un objeto
    begin
      if longbool(banderas and bnParalisis) then
      begin
        result:=i_EstasParalizado;
        exit
      end;
      dec(PosObjO,8);
      idObjOrig:=Artefacto[PosObjO].id;
      if (idObjOrig<4) and (Usando[PosObjD].id<4) then exit;//Objetos vacio
      if (idObjOrig>=4) then
      begin
        //Verificar Objetos permitidos:
        if bytebool(infobj[idObjOrig].ClasesNoPermitidas and mascarB[codCategoria]) then
        begin
          result:=i_NegadoCategoria;exit
        end;
        if bytebool(infobj[idObjOrig].RazasNoPermitidas and mascarB[TipoMonstruo]) then
        begin
          result:=i_NegadoRaza;exit
        end;
        if nivel<infobj[idObjOrig].nivelMinimo then
        begin
          result:=i_TeFaltaNivelParaUsarElObjeto;exit;
        end;
        //VerificarPosiciones:
        result:=VerificarPosicionDestino;
        if byteBool(result) then exit;//Posicion no permitida
      end
      else
        result:=i_Ok;
      if (PosObjD=uMunicion) then
      begin//Municiones
        if not byteBool(AgregarObjetoAObjeto(Artefacto[PosObjO],Usando[PosObjD])) then
        begin
          ObjTemp:=Artefacto[PosObjO];
          Artefacto[PosObjO]:=Usando[PosObjD];
          Usando[PosObjD]:=ObjTemp;
        end;
      end
      else
      begin
        if not byteBool(AgregarObjetoAObjeto(Usando[PosObjD],Artefacto[PosObjO])) then
        begin
          ObjTemp:=Artefacto[PosObjO];
          Artefacto[PosObjO]:=Usando[PosObjD];
          Usando[PosObjD]:=ObjTemp;
        end;
        CalcularModDefensa;
      end;
    end
    else//Intercambio dentro del baúl de objetos:
    begin
      dec(PosObjO,8);
      dec(PosObjD,8);
      if (Artefacto[PosObjO].id<4) and (Artefacto[PosObjD].id<4) then
        exit;
      if not byteBool(AgregarObjetoAObjeto(Artefacto[PosObjD],Artefacto[PosObjO])) then
      begin
        ObjTemp:=Artefacto[PosObjO];
        Artefacto[PosObjO]:=Artefacto[PosObjD];
        Artefacto[PosObjD]:=ObjTemp;
      end;
      result:=i_Ok;
    end;
end;

function TjugadorS.ElegirHabilidadParaCambiar(Habilidad:byte;mejorarHab:boolean):bytebool;
  function ObtenerNivelActual(La_Habilidad:byte):byte;
  begin
    case La_habilidad of
      HbFuerza:result:=FRZ;
      HbInteligencia:result:=INT;
      HbSabiduria:result:=SAB;
      HbDestreza:result:=DES;
    else
      result:=CON;
    end;
  end;
begin
  result:=false;
  if mejorarHab then
  begin
    if ObtenerNivelActual(habilidad)<20 then
    begin
      HabilidadResaltada:=(HabilidadResaltada and mskHabilidadDisminuida) or habilidad;
      result:=true;
    end;
  end
  else
    if ObtenerNivelActual(Habilidad)>1 then
    begin
      HabilidadResaltada:=(HabilidadResaltada and mskHabilidadMejorada) or (Habilidad shl 3);
      result:=true;
    end;
end;

procedure TjugadorS.Morir;
begin
  hp:=0;
  comida:=0;
  mana:=0;
  //evitar que salga de prision
  banderas:=banderas and bnControlado;
  NroTurnosGastados:=0;
  accion:=aaParado;
//  codAnime:=moFantasma;
  CalcularDefensa;
  CalcularNivelAtaque;
  CalcularDannoBase;
  determinarAnimacion;  
end;

procedure TjugadorS.restitucionAtributos;
begin
  disiparMagia();
  CalcularDefensa;
  CalcularDannoBase;
  calcularHP;
  calcularNivelAtaque;
  calcularMana;
  CalcularModDefensa;
end;

procedure TjugadorS.SanacionCuracion;
begin
  banderas:=(banderas or MskBanderasSanadas) xor MskBanderasSanadas;
  calcularHP;//por si existe maldición.
  if hp<=(maxHp shr 2) then//curar hasta llegar a amarillo
    hp:=(maxHp shr 2)+1;
end;

procedure TjugadorS.Resucitar;
var NuevoNivelExp,ExperienciaTope,NivelPenalizacionCompleta:integer;
begin
  ExperienciaTope:=ExperienciaNecesaria(nivel);
  NivelPenalizacionCompleta:=MIN_NIVEL_CATEGORIA shl 1;
  if nivel<NivelPenalizacionCompleta then
    NuevoNivelExp:=ExperienciaTope*nivel div NivelPenalizacionCompleta
  else
    NuevoNivelExp:=ExperienciaTope;
  inc(NuevoNivelExp,Experiencia);
  if NuevoNivelExp<ExperienciaTope then
    experiencia:=NuevoNivelExp
  else
    experiencia:=ExperienciaTope;
  if comportamiento>=comNormal then
  begin
    if maxhp>50 then hp:=50 else hp:=maxhp;
    comida:=100;
  end
  else//no honorables
  begin
    if maxhp>10 then hp:=10 else hp:=maxhp;
    comida:=20;
  end;
  mana:=0;
  accion:=aaParado;
  //NuevoNivelExp usado como variable para el for:
  for NuevoNivelExp:=0 to MAX_TIMERS_DEMONIO do fTimer[NuevoNivelExp]:=0;//Todos los timers en 0.
  NroTurnosGastados:=4;
  banderas:=banderas and bnControlado;
  fDestinoX:=CoordX;//no moverse autom.
  fDestinoY:=CoordY;
end;

function TjugadorS.PuedeRecibirComando(nroTurnosAGastar:shortint):bytebool;
begin
  result:=(NroTurnosGastados<=0) and activo;
  if result then NroTurnosGastados:=nroTurnosAGastar;
end;

procedure TjugadorS.TickTiempoDeComandos;
begin
  if NroTurnosGastados>0 then
    if LongBool(Banderas and BnCongelado) then
      if Longbool(Banderas and BnApresurar) then
        dec(NroTurnosGastados,3)
      else
        dec(NroTurnosGastados,2)
    else
      if Longbool(Banderas and BnApresurar) then
        dec(NroTurnosGastados,5)
      else
        dec(NroTurnosGastados,3)
end;

function TJugadorS.InventarioACadena:Tcadena63;
var i:integer;
begin
  result:='';
  for i:=0 to 7 do
    result:=result+char(Usando[i].id)+char(Usando[i].modificador);
  for i:=0 to MAX_ARTEFACTOS do
    result:=result+char(Artefacto[i].id)+char(Artefacto[i].modificador);
end;

function TJugadorS.ObtenerFlagsDeObjetosNulos:Integer;
var i:integer;
begin
  result:=0;
  for i:=0 to 7 do
    if Usando[i].id<4 then
      result:=result or (1 shl i);
  for i:=0 to MAX_ARTEFACTOS do
    if Artefacto[i].id<4 then
      result:=result or (1 shl (i+8));
end;

function TJugadorS.BaulACadena:Tcadena63;
var i:integer;
begin
  result:='';
  for i:=0 to MAX_ARTEFACTOS do
    result:=result+char(Baul[i].id)+char(Baul[i].modificador);
end;


procedure TJugadorS.CadenaAInventario(const cadena:string);
var i:integer;
begin
  if length(cadena)=BYTES_INVENTARIO then
  begin
    for i:=0 to 7 do
    begin
      Usando[i].id:=ord(cadena[i shl 1+1]);
      Usando[i].modificador:=ord(cadena[i shl 1+2]);
    end;
    for i:=0 to MAX_ARTEFACTOS do
    begin
      Artefacto[i].id:=ord(cadena[i shl 1+17]);
      Artefacto[i].modificador:=ord(cadena[i shl 1+18]);
    end;
  end
end;

function TjugadorS.MonstruoApuntadoIncorrecto:byteBool;
begin
  if Apuntado=nil then
  begin
    byte(result):=i_ApuntaPrimero;
    exit;
  end;
  if (Apuntado.codMapa=codMapa) then
    if (abs(Apuntado.coordx-coordx)<=MAXALCANCEX) and (abs(Apuntado.coordy-coordy)<=MAXALCANCEY) then
      if ((apuntado.banderas and bnInvisible)=0) or ((CapacidadId and ciInvisibles)<>0) then
      begin
        byte(result):=i_Ok;//0=false = sin error
        if (apuntado is TjugadorS) then
          with TJugadorS(apuntado) do
            if (longbool(banderas and bnOcultarse) and (coordx=FDestinoX) and (coordy=FDestinoY) and (NroTurnosGastados<=0) and (usando[uAmuleto].id=ihAmuletoDeCamuflaje)) then
              byte(result):=i_TieneOcultarYElAmuletoDeCamuflaje;//esta camuflado
      end
      else
        byte(result):=i_NoPuedesAtacarInvisibles//es invisible
    else
      byte(result):=i_EstasMuyLejos//fuera de alcance
  else
    byte(result):=i_ApuntaPrimero;
  if result then apuntado:=nil;
end;

function TjugadorS.PuedeConstruir(idHerramienta,idObjeto:byte):boolean;
begin
  with InfObj[idObjeto] do
    result:=(HerramientaRequerida=idHerramienta) and (NivelConstructor<=nivel) and
      not bytebool(RazasNoPermitidas and mascarB[tipoMonstruo]) and
      not bytebool(ClasesNoPermitidas and mascarB[CodCategoria]);
end;

function TjugadorS.TieneMaterialSuficiente(idObjeto:byte):boolean;
//  Devuelve true si tiene materiales suficientes.
//  Si consumir=true y tiene materiales suficientes resta los materiales necesarios,
//además devuelve en Cadena los indices
var i,j:integer;
    contadores:array[0..2] of integer;
//  Básicamente va revisando los artefactos, si este es del tipo_requerido y
//la cantidad necesaria todavia es mayor a 0, decrementa la cantidad necesaria
//de acuerdo al número de elementos.
//  Si al finalizar todavia uno de los contadores es mayor a 0, significa que
//faltan materiales.
begin
  result:=false;
  with InfObj[idObjeto] do
  begin
    for j:=0 to 2 do
      contadores[j]:=CantidadX[j];
    for i:=0 to MAX_ARTEFACTOS do//Revisar toda la bolsa de objetos
      for j:=0 to 2 do//Verificar con cada recurso necesario
        if Contadores[j]>0 then
          if artefacto[i].id=RecursoX[j] then
            if RestarCantidadDeMaterialConst(artefacto[i],contadores[j],CantidadConstruida<>0,false) then
              break;
    for i:=0 to 2 do
      if contadores[i]>0 then exit;
  end;
  result:=true;
end;

function TjugadorS.PuedeConsumir(indArt:byte):byte;
var idObj:byte;
begin
//Revisar:
//Objetos, function DeterminarIconoApropiado(objeto:Tartefacto):shortint;
//Para verificar los tipos de objetos.
  result:=i_Error;
  if hp<>0 then
    begin
      if indArt<=MAX_ARTEFACTOS then
      if numeroElementos(artefacto[indArt])>0 then
      begin
        idObj:=artefacto[indArt].id;
        if nivel<infobj[idObj].NivelMinimo then
        begin
          result:=i_TeFaltaNivelParaUsarElObjeto;exit
        end;
        if bytebool(infobj[idObj].ClasesNoPermitidas and mascarB[codCategoria]) then
        begin
          result:=i_NegadoCategoria;exit
        end;
        if bytebool(infobj[idObj].RazasNoPermitidas and mascarB[TipoMonstruo]) then
        begin
          result:=i_NegadoRaza;exit
        end;
        result:=i_OK;
        case idObj of
          144..151:if (comida>=maxComida) then result:=i_SinHambre;
          152..155,157:if (comida>=maxComida) then result:=i_SinSed;
          orBebidaAntiVeneno:if (comida>0) and ((banderas and bnEnvenenado)=0) then result:=i_NoEstasEnvenenado;
          orBebidaMasHP,160:if (comida>0) and (hp>=maxHp) then result:=i_SinHeridas;//HP
          orBebidaMasMANA,162:
            if (comida>0) then
            begin
              if (maxMana=0) then
                result:=i_NoTeSirvePocimasParaMana
              else
                if mana>=maxMana then result:=i_ManaMaximo;//Mana
            end;
        end;
      end;
    end
  else
    result:=i_EstasMuerto;
end;

function TjugadorS.getHabilidades:integer;
begin
  result:=
    (FRZ and $1F) or
    ((INT and $1F) shl 5) or
    ((DES and $1F) shl 10) or
    ((SAB and $1F) shl 15) or
    ((CON and $1F) shl 20) or
    ((HabilidadResaltada and mskHabilidadResaltada) shl 25)
end;

procedure TjugadorS.setHabilidades(B4_Hab:integer);
begin
  FRZ:=B4_Hab and $1F;
  B4_Hab:=B4_Hab shr 5;
  INT:=B4_Hab and $1F;
  B4_Hab:=B4_Hab shr 5;
  DES:=B4_Hab and $1F;
  B4_Hab:=B4_Hab shr 5;
  SAB:=B4_Hab and $1F;
  B4_Hab:=B4_Hab shr 5;
  CON:=B4_Hab and $1F;
  B4_Hab:=B4_Hab shr 5;
  HabilidadResaltada:=B4_Hab and mskHabilidadResaltada;
end;

function TjugadorS.PuedeLeerElConjuro(nro_conjuro:byte):boolean;
begin
  result:=false;
  if nro_conjuro<=31 then
    with InfConjuro[nro_conjuro] do
      result:=nivelJugador<=Nivel;
end;

function TjugadorS.PuedeEscribirElConjuroSeleccionado(IndiceObjetoTintaMagica:byte):byte;
//No controla: escritorio de mago, pericia escribir magia.
begin
  result:=i_error;
  if ConjuroElegido>31 then exit;
  result:=i_FaltaNivelONoConocesConjuroParaEscribirlo;
  if (Conjuros and (1 shl ConjuroElegido))<>0 then
    with InfConjuro[ConjuroElegido] do
    if ((nivelINT<=INT) and (nivelSAB<=SAB) and (nivelJugador<=nivel)) or ((nivelJugador shl 2)<=nivel) then
      if (artefacto[IndiceObjetoTintaMagica].modificador)>=nivelJugador then
        if (Usando[uArmaIzq].id=orPergamino) and (Usando[uArmaIzq].modificador>0) then
          if Usando[uArmaDer].id<4 then
            result:=i_OK
          else
            result:=i_NecesitasManoDerechaLibre
        else
          result:=i_SinPergamino
      else
        result:=i_SinTintaMagicaSuficiente
end;

function TjugadorS.ActivarEstadoAgresivo:bytebool;
begin
  result:=RitmoDeVida=0;//true si no estaba agresivo
  if RitmoDeVida<18 then RitmoDeVida:=18;//Usado como nivel de agresividad, unos 60 seg. en 4 turnos por seg.
end;

procedure TjugadorS.IncrementarTiempoDeCarcel;
var i:integer;
begin
  if nivel>MAX_NIVEL_NEWBIE then
    if nivel>=MIN_NIVEL_CATEGORIA then
      i:=RitmoDeVida+225
    else
      i:=RitmoDeVida+150
  else
    i:=RitmoDeVida+75;
  if ritmoDeVida<255 then RitmoDeVida:=i else RitmoDeVida:=255;
  Banderas:=Banderas or BnControlado;
end;

function TjugadorS.TickTimerAgresividad:bytebool;
begin//Nota: Para los jugadores "RitmoDeVida" sirve para control de agresividad.
  if RitmoDeVida>0 then
  begin
    dec(RitmoDeVida);
    result:=RitmoDeVida=0;
  end
  else
    result:=false;
end;

function TjugadorS.NivelMaximoQuePuedeReparar(TipoReparacion:TTipoReparacion):integer;
begin
  result:=nivel shl 1;
  case TipoReparacion of
    trAfilar:begin
      if LongBool(Pericias and hbHerreria) then
        result:=result shl 1;
      inc(result,FRZ+DES)
    end;
    trAceitar:begin
      if LongBool(Pericias and hbCarpinteria) then
        result:=result shl 1;
      inc(result,SAB+DES)
    end;
    trMartillar:begin
      if LongBool(Pericias and hbHerreria) then
        result:=result shl 1;
      inc(result,FRZ+DES)
    end;
    trCoser:begin
      if LongBool(Pericias and hbSastreria) then
        result:=result shl 1;
      inc(result,SAB+DES)
    end;
    else result:=0;
  end;
  if result>MskEstadoObjetoNormal then result:=MskEstadoObjetoNormal;
end;

function TjugadorS.PuedeActivarIraTenax:byte;
begin
  if hp<>0 then
    if (banderas and bnIraTenax)=0 then
      if longbool(pericias and hbIraTenax) then
        if (hp>PENA_HP_IRA_TENAX) then
          result:=i_Ok
        else
          result:=i_IraNecesitaMasHP
      else
        result:=i_NoTienesLaPericiaIraTenax
    else
      result:=i_error
  else
    result:=i_EstasMuerto
end;

function TjugadorS.PuedeActivarZoomorfismo:byte;
var i:integer;
begin
  if hp<>0 then
    if (banderas and bnZoomorfismo)=0 then
      if longbool(pericias and hbZoomorfismo) then
        if mana>=MANA_ZOOMORFISMO then
        begin
          //revisar que no tengan nada de armadura en las manos
          for i:=0 to MAX_CASILLA_NEGADA_ZOOMORFISMO do // de uArmaDer a uCasco
            if (Usando[i].id>=56) and (Usando[i].id<=95) then
            begin
              result:=i_NoPuedesIniciarZoomorfismo;exit
            end;
          result:=i_Ok
        end
        else
          result:=i_NecesitasManaParaZoomorfismo
      else
        result:=i_NoTienesLaPericiaZoomorfismo
    else
      result:=i_YaEstasUsandoZoomorfismo
  else
    result:=i_EstasMuerto
end;

function TjugadorS.PuedeOcultarse:byte;
begin
  if not LongBool(Banderas and bnparalisis) then
    if hp<>0 then
      if (banderas and bnOcultarse)=0 then
        if longbool(pericias and hbCamuflarse) then
          result:=i_Ok
        else
          result:=i_NoTienesLaPericiaOcultarse
      else
        result:=i_error 
    else
      result:=i_EstasMuerto
  else
    result:=i_EstasParalizado
end;

function TjugadorS.PuedeAtacar:byte;
var idPosArma:byte;
begin
  if not LongBool(Banderas and bnparalisis) then
    if hp<>0 then
    begin
      result:=i_SinArma;
      for idPosArma:=uArmaIzq downto uArmaDer do
        if InfObj[Usando[idPosArma].id].AlcanceArma=aaRango then
          if MunicionCorrecta(Usando[idPosArma],Usando[uMunicion]) then
          begin
            result:=byte(MonstruoApuntadoIncorrecto);
            if result=i_Ok then
              //Nota "result=i_Ok" implica que "apuntado" es un TmonstruoS válido.
              if (Apuntado is TJugadorS) or (Apuntado.comportamiento<>comComerciante) then
                exit//para salir del ciclo.
              else
                result:=i_ElNPCEstaProtegido//monstruo comerciante
          end
          else
            result:=i_MunicionIncorrecta
        else
        begin
          if (Usando[idPosArma].id<4) then//Para definir correctamente el arma
            if (idPosArma=uArmaIzq) and (InfObj[Usando[uArmaDer].id].PesoArma=paPesada) then
              Usando[uArmaIzq].id:=3//No es un arma.
            else
              Usando[idPosArma].id:=idPosArma;//Puño derecho, izquierdo
          if InfObj[Usando[idPosArma].id].AlcanceArma=aaMelee then
          begin
            result:=i_Ok;exit //para salir del ciclo.
          end;
        end
    end
    else
      result:=i_EstasMuerto
  else
    result:=i_EstasParalizado
end;

procedure TjugadorS.crearHeroeLegendario;
var i:integer;
begin
  Conjuros:=$FFFFFFFF;
  Dinero:=$FFFFFF;
  for i:=0 to 9 do
    ModificarExperiencia($FFFF);
  NivelEspecializacion:=$FF;
end;

procedure TjugadorS.repararAvatar;
var  PericiaResaltada:longword;
     TotalPuntos:byte;
begin
  if dinero<0 then dinero:=0;
  if nivel<1 then nivel:=1;
  //quitar pericias denegadas
  pericias:=pericias and ($FFFFFFFF xor PericiasDenegadas[codCategoria]);
  TotalPuntos:=contarPericias(pericias);
  //si existe demasiadas pericias borrar todas
  if (TotalPuntos>MAX_PERICIAS) then
  begin
    Pericias:=0;
    TotalPuntos:=0;
  end;
  PericiaResaltada:=1;
  while (TotalPuntos<MAX_PERICIAS) and (PericiaResaltada<=$8000) do
  begin
    if (PericiasDenegadas[codCategoria] and PericiaResaltada)=0 then
    begin
      pericias:=pericias or PericiaResaltada;
      TotalPuntos:=contarPericias(pericias);
    end;
    PericiaResaltada:=PericiaResaltada shl 1;
  end;
  apuntado:=nil;
  AccionAutomatica:=aaNinguna;
  if (CodCategoria<>ctGuerrero) and (CodCategoria<>ctBribon) then
  begin
    NivelEspecializacion:=0;
    EspecialidadArma:=7;
  end;
  if FRZ>20 then FRZ:=20;
  if CON>20 then CON:=20;
  if DES>20 then DES:=20;
  if SAB>20 then SAB:=20;
  if INT>20 then INT:=20;
  if FRZ<1 then FRZ:=1;
  if CON<1 then CON:=1;
  if DES<1 then DES:=1;
  if SAB<1 then SAB:=1;
  if INT<1 then INT:=1;
  if nivel>MAX_NIVEL_CON_BONO then
    TotalPuntos:=MAX_NIVEL_CON_BONO
  else
    TotalPuntos:=Nivel-1;
  inc(TotalPuntos,MAX_HABILIDADES_SUMADAS);
  if FRZ+CON+DES+SAB+INT<>TotalPuntos then
  begin
    SAB:=TotalPuntos div 5;
    dec(TotalPuntos,SAB);
    INT:=TotalPuntos shr 2{div 4};
    dec(TotalPuntos,INT);
    FRZ:=TotalPuntos div 3;
    dec(TotalPuntos,FRZ);
    CON:=TotalPuntos shr 1{div 2};
    dec(TotalPuntos,CON);
    DES:=TotalPuntos;
  end;
  Banderas:=0;
  CalcularNivelAtaque;
  CalcularDannoBase;
  CalcularMana;
  CalcularHP;
  CalcularDefensa;
  CalcularModDefensa;
  if mana>maxmana then mana:=maxMana;
  if hp>maxhp then hp:=maxhp;
end;

function TjugadorS.CalcularModificacionPrecio(Precio,inflacion:integer;EsPrecioVenta,BonoClan:bytebool):integer;
begin
  result:=Precio;
  if result>0 then
  begin
    if not EsPrecioVenta then
      dec(inflacion,comportamiento);
    if LongBool(Pericias and hbRegatear) then
      if EsPrecioVenta then
        inc(inflacion,nivel shl 2)//+ inflacion, vendiendo al PNJ
      else
        dec(inflacion,nivel shl 2);//- inflacion, comprando del PNJ
    if inflacion<0 then inflacion:=0;
    if inflacion>255 then inflacion:=255;
    if (not EsPrecioVenta) and BonoClan then
      inflacion:=inflacion shr 1;
    result:=result*(inflacion+128);
    if EsPrecioVenta then result:=result shr 9 else result:=result shr 7;
    if result>=10000 then result:=(result div 100)*100
    else
      if result>=1000 then result:=(result div 10)*10
      else
        if result<1 then result:=1;
  end;
end;

function TjugadorS.ExtraerDatosEnCadena:Tcadena127;
begin
  result:=B2aStr(HP)+chr(Mana)+char(comida)+chr(dir)+chr(codAnime)+B3aStr(Banderas)+
  //no temporales
    chr(codCategoria or (TipoMonstruo shl 4))+
    B2aStr(Pericias)+chr(nivel)+B2aStr(Experiencia)+
    B4aStr(Conjuros)+chr(EspecialidadArma)+chr(NivelEspecializacion)+
    chr(fcodCara)+chr(comportamiento)+char(clan)+B4aStr(Dinero)+
    b4aStr(getHabilidades)+InventarioACadena+nombreAvatar[0]+nombreAvatar;
end;

function TjugadorS.NombreCategoria:string;
begin
  codCategoria:=codCategoria and $7;
  if nivel<MIN_NIVEL_CATEGORIA then
    if nivel>MAX_NIVEL_NEWBIE then
      result:=MC_Nombre_Categoria[codCategoria]
    else
      result:=MC_Nombre_Categoria[codCategoria]+' aprendiz'
  else
    result:=MC_Nombre_Categoria2[codCategoria];
end;

function TjugadorS.Reputacion:string;
begin
  case comportamiento of
    0:result:='Plebeyo';
    1..99:result:='Noble '+intastr(comportamiento)+'%';
    comHeroe:result:='Héroe';
    comHeroe+1..comAdminB:result:='Admin. clase B';
    comAdminA:result:='Admin. clase A';
    comGameMaster:result:='Amo del Calabozo';
    else result:='Escoria '+intastr(-comportamiento)+'%';
  end;
end;

function TJugadorS.ListarPericias:Tcadena127;
var i:integer;
begin
  for i:=0 to 15 do
    if longBool(pericias and (1 shl i)) then
      result:=result+MC_Pericias[i]+', ';
  i:=length(result);
  if i>2 then Delete(result,i-1,2);
end;

function TJugadorS.CamaradasPartyACadena:Tcadena15;
var i:integer;
begin
  result:='';
  for i:=0 to MAX_INDICE_PARTY do
    result:=result+b2astr(camaradasParty[i]);
end;

function TJugadorS.nivelTruncado:byte;
begin
  if Nivel>MIN_NIVEL_CATEGORIA then result:=MIN_NIVEL_CATEGORIA else result:=Nivel;
end;

function TJugadorS.TiempoConjuro(EsConjuroArcano:boolean):byte;
begin
  result:=4+nivel shr 3;
  if (nivel and $7)>random(8) then inc(result);
  if EsConjuroArcano then
    inc(result,INT)
  else
    inc(result,SAB);
end;

//TClanJugadores
//*****************************************************
constructor TClanJugadores.create(codigoClan_n:byte);
begin
  inherited create;
  codigoClan:=codigoClan_n;
  MiembrosActivos:=0;
  Lider:='';
  Nombre:='';
  ColorClan:=255;
  Nousado1:=0;
  IdentificadorDeClan:=0;
  PendonClan.color0:=$80000000;
  PendonClan.color1:=PendonClan.color0;
end;

end.

