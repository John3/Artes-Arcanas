(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

//Módulo libre de bibliotecas externas
unit objetos;
//  Este módulo también incluye los
//descriptores de conjuros.
//  El resto de la parte de magia está
//implementado mayormente en módulos del servidor y
//sus efectos reflejos en módulos del cliente.

interface

const
  versionLA:byte=255;
  MC_TipoDeArma:array[0..8] of string[12]=('Cortante','Punzante','Contundente','Veneno','Fuego','Hielo','Rayo','Magia','Munición');
  MAX_ARTEFACTOS=17;//En inventario
  MAX_TIPOS_COMERCIO=31;
  //CapacidadesIdentificacion:
  ciMagia=$01;
  ciMaldad=$02;
  ciVeneno=$04;
  ciInvisibles=$10;
  ciVerRealmente=$FF;
  //Banderas de conjuros:
  cjConjuroInicial=$01;
  cjPuedeLanzarAsimismo=$02;
  cjPuedeLanzarObjetivo=$04;
  cjSoloJugadores=$08;
  cjConjuroAgresivo=$10;
  Msk_ConjuroModificadorObjeto=cjSoloJugadores or cjPuedeLanzarAsimismo;
  //Grupos de objetos
  grFlechas=6;
  grComida=18;
  grBebida=19;
  //Características de objetos
  PUNTOS_HP_MANA_POCION=15;
  //Códigos de mensajes de error
  //----------------------------------------------------------------------------
  i_Ok=0;
  i_Error=1;
  i_NegadoRaza=2;
  i_NegadoCategoria=3;
  i_CasillaIncorrecta=4;
  i_NecesitasAmbasManos=5;
  i_UsalaEnLaOtraMano=6;
  i_SinAmbidextria=7;
  i_ArruinasteLaGema=8;
  i_EstasMuerto=9;
  i_NecesitasCasillaLibreEnBolso=10;
  i_EstasParalizado=11;
  i_ElObjetoVaEnOtraMano=12;
  i_SinArmaAfilable=13;
  i_SinArmaAceitable=14;
  i_ObjetoMartillableEnManoDer=15;
  i_ObjetoRemendableEnManoDer=16;
  i_NoPuedesRepararMejor=17;
  i_LugarNoAdecuadoParaFogata=18;
  i_NecesitasMasLennos=19;
  i_NoPuedesEncenderFogataPorLluvia=20;
  i_SinMinerales=21;
  i_NadaParaPescar=22;
  i_NadaParaTalar=23;
  i_NadaParaTallar=24;
  i_SinFundicion=25;
  i_NoSabesFundir=26;
  i_NecesitasMasMineral=27;
  i_NoPuedesTeletransportarte=28;

  i_NoSabesHacerPocimas=30;

  i_SinTelar=32;
  i_NoEresSastre=33;
  i_NecesitasMasFibras=34;
  i_noEresHerrero=35;
  i_noFabricasTela=36;
  i_noEresCarpintero=37;
  i_noEresAlquimico=38;
  i_noEresMagoEscritor=39;
  i_SinYunque=40;
  i_SinPergamino=41;
  i_CalmasSed=42;
  i_CalmasHambre=43;
  i_BebesPocima=44;
  i_EchasElVeneno=45;
  i_SinHambre=46;
  i_SinSed=47;
  i_SinHeridas=48;
  i_ManaMaximo=49;
  i_NoTeSirvePocimasParaMana=50;
  i_NoNecesitasVendas=51;
  i_DisparoObstaculizado=52;
  i_SinArma=53;
  i_MunicionIncorrecta=54;
  i_ApuntaPrimero=55;
  i_Fallaste=56;
  i_EstasMuyLejos=57;
  i_ElNPCEstaProtegido=58;
  i_PrimeroApuntaAUnJugador=59;
  i_NoHayLugarParaSoltarElObjeto=60;
  i_TuInventarioEstaLleno=61;
  i_NecesitasManoDerechaLibre=62;
  i_LugarNoAdecuadoParaTrampa=63;
  i_AunNoPuedesConstruirNada=64;
  i_NoSabesCurtir=65;
  i_SinCurtidora=66;
  i_NecesitasMasPieles=67;
  i_NoTienesTodosLosMateriales=68;
  i_SinIngredientes=69;
  i_NoEstasEnvenenado=70;
  i_IraNecesitaMasHP=71;
  i_noEsEnvenenable=72;
  i_ColocaAlgoParaEnvenenarEnManoDerecha=73;
  i_NoEresBardo=74;
  i_SinEstudioDeMago=75;
  i_SinEstudioDeAlquimia=76;
  i_SinTintaMagicaSuficiente=77;
  i_DialogoNPJqueCompro=78;
  i_DialogoNPJqueVendio=79;
  i_SeleccionaObjetoInventario=80;
  i_RechazaTuOferta=81;
  i_NoPuedesVenderEso=82;
  i_ApuntaParaComerciar=83;
  i_NoEsUnComerciante=84;
  i_NoComproEsasCosas=86;
  i_NoIntentesEstafarme=87;

  i_FaltaNivelONoConocesConjuroParaEscribirlo=90;
  i_NoTienesSuficienteMana=91;
  i_NoPuedesHacerMagia=92;
  i_FaltaNivelParaLeelElPergamino=93;
  i_LeDrenasteTodosMenosUnPuntoDeVida=94;
  i_conjuroParaJugadores=95;
  i_falloElConjuro=96;
  i_ConjuroObstaculizado=97;
  i_FalloConjuroMaldecir=98;
  i_EstaProtegidoContraHechizosMalvados=99;
  i_NoPuedesVampirearle=100;
  i_YaEstaIdentificado=101;
  i_NoPudisteConjurarMonstruo=102;
  i_NecesitasGemaTallada=103;
  i_NecesitasGemaParaArcana=104;
  i_NecesitasGemaParaSagrada=105;
  i_EstaGemaNoEsAdecuada=106;
  i_NecesitasObjetoValioso=107;
  i_NecesitasGema90a100=108;
  i_YaConocesElConjuro=109;
  i_NoTienesMana=110;
  i_TuVaritaMagicaSeAgoto=111;
  i_ConjuroSobreAvatarMuerto=112;
  i_MaldicionSobreObjeto=113;
  i_ConjuroSobreNPCProtegido=114;
  i_TieneGemaAntiMaldicion=115;
  i_NoConocesElConjuro=116;
  i_TeFaltaNivelParaUsarElObjeto=117;
  i_ElBrillanteNoAfectaArmaduras=118;

  i_NoTienesLaPericiaOcultarse=120;
  i_NoPudisteOcultarte=121;
  i_NoTienesLaPericiaIraTenax=122;
  i_NoTienesLaPericiaZoomorfismo=123;
  i_NoPuedesIniciarZoomorfismo=124;
  i_YaEstasUsandoZoomorfismo=125;
  i_NecesitasManaParaZoomorfismo=126;
  i_NecesitasManaParaJuglaria=127;
  i_EstasBajoEfectodeJuglaria=128;
  i_NoEstasEnModoPKiller=129;
  i_ElObjetoNoSePuedeHechizar=130;
  i_NoTieneCalidadParaBendecir=131;
  i_ElObjetoYaEstaHechizado=132;
  i_NoPuedesAtacarAvataresPacifistas=133;
  i_NoPuedesAtacarInvisibles=134;
  i_TieneOcultarYElAmuletoDeCamuflaje=135;

  //140 -> Parties
  i_NoHayEspacioEnTuParty=140;
  i_NoHayEspacioEnSuParty=141;
  i_TieneQueAgregarteASuParty=142;
  i_YaEstaEnTuParty=143;

  i_NoTienesSuficienteNivel=151;
  i_SoloParaFantasmas=152;
  i_EsInvulnerableAConjuros=153;
  i_FallasteAlIntentarDesactivarLaTrampa=154;
  i_EsTuMonstruo=155;
  i_NecesitasELAnilloDelConjurador=156;
  i_ApuntaAUnMonstruo=157;

  i_CreasteNuevoClan=160;
  i_NoTieneClan=161;
  i_NoPuedesCrearOtroClan=162;
  i_YaTieneClan=163;//reclutar
  i_NoEstaEnTuClan=164;//expulsar
  i_NoEresElLiderDelClan=165;
  i_NoPertenecesAUnClan=166;
  i_NoPuedesAtacarMiembrosDeTuClan=167;
  i_YaExisteUnNombreMuyParecido=168;

  i_ElCastilloNoTieneTantoDinero=170;
  i_YaSeRealizoEsaMejoraEnElGuardian=171;
  i_HasMejoradoLaDefensaDelCastillo=172;
  i_TuBaulEstaLleno=173;
  i_SeleccionaObjetoBaul=174;

  i_NoTienesPrivilegioParaUsarEseComando=194;
  i_NecesitasTenerLibreLaPrimeraCasilla=195;
  i_NoPuedesActivarOtraSesion=196;
  i_NecesitasMayorNivelAdministrativo=197;
  i_NoEstasCercaDeCatedral=198;
  i_UsasPalabraRetornoFantasma=199;
  //200..231 mensajes de conjuros.
  i_InicioMensajesExitoDeConjuro=200;//Todos reservados para conjuros exitosos
  //232..255 mensajes de conjuros especiales.

type
  TCadena4=string[4];
  TCadenaLogin=string[16];
  TCadena15=string[15];
  TCadena23=string[23];
  TCadena63=string[63];
  TPassword=array[0..7] of byte;
  TArtefacto=record
    id,modificador:byte;
  end;
  TDatosNuevoPersonaje=record
    Pericias:word;
    nombre:TCadenaLogin;
    cod_categoria,cod_raza,cod_genero:byte;
    FRZ,SAB,CON,INT,DES:byte;
  end;
  TEstadoUsuario=(euNoConectado,euNoAutentificado,euAutentificado,euBaneado,euNormal,euAdminC_noUsado,euAdminB,euAdminA,euGameMaster,euSuperGameMaster);
  TDatosUsuario=record
    Password:TPassword;//8 bytes
    ultimoIngreso:word;//2
    DiaDeCreacion:word;//2
    PermisosDelUsuario:longword;//4
    UltimoIP:integer;//Ip del cliente. 4 bytes
    IdLogin:TCadenaLogin;//17 bytes
    EstadoUsuario:TEstadoUsuario;//1 byte
    TimerDesconeccionPorOcio:byte;
    AgresividadVerbal:byte;//Para evitar que hablen >= 100, 100=por servidor, >100=por admin, normal = 0, >0 = controlado. 
    IdentificadorDeServidor:Integer;//Inicializado al azar...
    IdentificadorDeClan:integer;
    ProcesarBufferRecepcion:boolean;
  end;

  TInventarioArtefactos=array[0..MAX_ARTEFACTOS] of Tartefacto;
  TArchivoComercios=record
    Artefactos:array[0..MAX_TIPOS_COMERCIO] of TInventarioArtefactos;
    CheckSum:integer;
  end;
  TcapacidadIdentificacion=byte;
  TIconoSeleccionado=byte;
  TbrilloObjeto=(boNinguno,boMagico,boMalvado,boVenenoso,boOscuro);
  TTipoMagiaArtefacto=(maNinguna,maModificador,maElemento,maHechizo);
  TPesoArma=(paLigera,paNormal,paPesada,paNoEsArma);
  //No modificar el orden!!!
  TTipoArma=(taCortante,taPunzante,taContundente,taVeneno,taFuego,taHielo,taRayo,taMagia,taMunicion,taNoEsArma);
  TArmadurasJugador=array[0..7] of shortint;
  TAlcanceArma=(aaMelee,aaRango,aaMagica,aaNoEsArma);
  TClaseConstruye=(ccNoSeConstruye,ccHerrero,ccGranHerrero,ccAlquimista,ccGranAlquimista,ccSastre,ccGranSastre,ccCarpinteroArmero,ccHerbalista,ccCarpintero,ccGranCarpintero);
  TTipoConjuro=(tcCombate,tcModificador,tcNecesitaArtefactoInventario);
  TTipoReparacion=(trNoReparable,trAfilar,trAceitar,trMartillar,trCoser);
  TTipoAnimacionArma=(taaNinguno,taaPunno,taaDaga,taaEspada,taaHacha,taaPica,taaMaza,taaMangual,taaArco,taaBallesta,taaArcabuz,taaBallestaMano,taaManoMagia,taaCayadoMelee,taaCetroMago,taaSimboloSagrado,taaEspadaHielo);
  TDescriptorConjuro=packed Record
    CostoCnjr:word;
    BanderasCnjr:byte;
    TipoCnjr:TTipoConjuro;
    nivelINT,nivelSAB,nivelMANA:byte;
    DannoBaseCnjr,DannoBonoCnjr,TipoDannoCnjr:byte;
    AnimacionCnjr:byte;
    IconoPergamino:byte;
    nivelJugador:byte;
    EscuelaConjuro:byte;
    _No_Usado_2:word;
  end;
  TDescriptoresConjuros=array[0..31] of TDescriptorConjuro;
  TNombresConjuros=array[0..31] of string[23];
  TArchivoconjuros=record
    Nombre:TNombresConjuros;
    Datos:TDescriptoresConjuros;
    CheckSum:integer;
  end;
  TDescriptorObjeto=Record
    costo:word; //0=no se puede vender ni comprar.
    danno1B,danno1P,danno2B,danno2P:shortint;//punzante,cortante,contundente,magia
    RazasNoPermitidas,ClasesNoPermitidas:byte;
    modificadorADC:shortint;
    PesoArma:TPesoArma;
    TipoArma:TTipoArma;
    AlcanceArma:TAlcanceArma;//Es el que define si es un arma o no.
    Construye:TClaseConstruye;
    HerramientaRequerida:byte;
    CantidadConstruida:byte;//Para indicar la cantidad construida
    NivelConstructor:byte;//De habilidad necesaria.
    RecursoX:array[0..2] of byte;
    CantidadX:array[0..2] of byte;
    TipoReparacion:TTipoReparacion;
    NivelMinimo:byte;
    FlagsArtefacto:integer;
    TipoAnimacion:TTipoAnimacionArma;
    NoUsado1:byte;
    NoUsado2:word;
  end;
  TNombresObjetos=array[0..255] of string[31];
  TDescriptoresObjetos=array[0..255] of TDescriptorObjeto;
  TArchivoObjetos=record
    Nombre:TNombresObjetos;
    Datos:TDescriptoresObjetos;
    CheckSum:integer;
  end;
  TTipoObjetoPorCantidad=(toCantidad_1,toCantidad_60,toCantidad_250);
const
  MAX_NRO_OBJETOSxCASILLA=250;
  NRO_LENNOS_FOGATA=5;
  MOVIO_TODO_A_DESTINO=2;
  MskNroObjetos=$3F;
  MAX_NRO_OBJETOS_VENENOxCASILLA=60;//para objetos que pueden ser envenenados
  MskEnvenenado=$80;
  MskParalizante=$40;
  MskDescriptorEnvenenables=MskEnvenenado or MskParalizante;

//Para objetos magicos/malditos:
//Flags de tipo de artefacto: $80 $40

// $00 :
// Objeto normal, sin magia, bits:
//*********************************

// 0 0 (? ? ? ? ? ?)
//     +--Estado---+

// Estado va de 0 a 63 (+$3F), visualizado como (N*2)%, visualmente truncado a 100%

// $40 :
// Objeto maldito o bendito, con magia, bits:
//********************************************

// 0 1 (?) (?)  (?)   (?  ?  ?)
//     Id. Daño Mald. +-Nivel-+

// Id: Determina si está identificado si es 1 (+$20), si es 0 no está identificado.
// Daño: Determina si el modificador es de daño/armadura si es 1 (+$10), si es 0 es de ataque/defensa.
// Mald.: Determina si el efecto es negativo si es 1 (+$08), si es 0 es positivo.
// Nivel: Va de 0 a 7 (+$07), visualizado como +1 a +8, o +5% a +40% o -1 a -8 o -5% a -40%.

// $80:
// Objeto mágico con tipo de daño modificado:
//********************************************

// 0 1 (?) (? ?) (?  ?  ?)
//     Id. Tipo  +-Nivel-+

// Id: Determina si está identificado si es 1 (+$40), si es 0 no está identificado.
// Tipo: Determina el tipo de daño mágico:
//   00 = Veneno (+$00)
//   01 = Fuego  (+$08)
//   10 = Hielo  (+$10)
//   11 = Rayo   (+$18)
// Nivel: Va de 0 a 7 (+$07), visualizado como +1 a +8.

// $C0:
// Objeto mágico especial:
//*************************

// 0 1 (?) (? ? ? ? ?)
//     Id. +--Tipo---+

// Id: Determina si está identificado si es 1 (+$40), si es 0 no está identificado.
// Tipo: Determina el tipo de efecto mágico, va de 0 a 31 (+$1F)

  MskIdentificado=$20;
  MskBendicionMaldicion=$40;
  MskDanno=$10;//si no esta presente es ataque
  MskMaldito=$08;//si no esta presente es Bendito

  MskModificadorDeDannoPorElemento=$80;
  MskBitsDeTipoDeDannoPorElemento=$18;
  MskDannoVeneno=MskModificadorDeDannoPorElemento or $00;
  MskDannoFuego=MskModificadorDeDannoPorElemento or $08;
  MskDannoHielo=MskModificadorDeDannoPorElemento or $10;
  MskDannoRayo=MskModificadorDeDannoPorElemento or $18;

  MskMagiaEspecial=$C0;
  MskTipoMagiaEspecial=$1F;

  MskEstadoObjetoNormal=$3F;
  MskEstadoMagico=$07;
  MIN_FIBRASxTELA=4;//no cambiar de 4
  MIN_PIELESxCUERO=4;//no cambiar de 4
  //Máscaras para extraer casilla ocupada:
  MascarB:array[0..7] of byte=($01,$02,$04,$08,$10,$20,$40,$80);
  //Indican el objeto que se esta usando como:
  uNoDefinido=255;
  uArmaDer=0;
  uArmaIzq=1;
  uArmadura=2;
  uCasco=3;
  uBrazaletes=4;
  uAnillo=5;
  uAmuleto=6;
  uMunicion=7;
  uConjuro=8;
  uConsumible=9;
  uHerramienta=10;
  uConstructor=11;
  //Ids de Objetos Varios:
  idArcabuz=43;
  //Ids de Herramientas:
  ihPico=120;
  ihHacha=121;
  ihCanna=122;
  ihHerramientasHerbalista=125;
  ihPlumaMagica=141;
  ihLibroAlquimia=130;
  ihTijeras=131;
  ihMartillo=132;
  ihSerrucho=133;
  ihTallador=134;
  ihCalderoMagico=128;
  ihPergaminoA=232;
  ihPergaminoS=233;
  ihAmuletoVisionVerdadera=108;
  ihAmuletoDeMago=111;
  ihAmuletoDeRegeneracion=106;
  ihAmuletoDeConservacion=105;
  ihAmuletoDeCamuflaje=107;
  ihAmuletoDePersistencia=104;
  ihBallestaDeMano=40;
  ihLibroArcano=115;
  ihLibroOracion=119;
  ihAfilador=136;
  ihAceite=137;
  ihVaritaVacia=124;
  ihVaritaLlena=142;
  ihVeneno=219;
  ihParalizante=227;
  orTomoExperiencia=236;
  ihDardosParalisis=48;
  //Objetos-Recursos
  orHierro=200;
  orArcanita=201;
  orPlata=202;
  orOro=203;
  orLingoteHierro=204;
  orLingoteArcanita=205;
  orLingotePlata=206;
  orLingoteOro=207;
  orMadera=208;
  orPescado=147;
  orMaderaMagica=223;
  orLenna=209;
  orPocimaInicial=160;
  orIngredienteInicial=168;
  orIngredienteFinal=175;
  orFibras=214;
  orTela=215;
  orFuegoArtificial=226;
  orTrampaMagica=225;
  orBebidaAntiVeneno=156;
  orBebidaMasMANA=158;
  orBebidaMasHP=159;

  orCuerda=212;
  orMango=211;
  orPiel=221;
  orCuero=213;
  orCueroDragon=216;
  orMizril=217;
  orAnilloDelControl=100;
  orPergamino=210;
  orGemaInicialSinTallar=192;
  orGemaInicial=184;
  orGemaFinal=191;
  orGemaAntiMaldicion=184;
  orGemaHielo=186;//Aguamarina
  orGemaRayo=187;//Zafiro
  orGemaVeneno=188;//esmeralda
  orGemaFuego=189;//rubi
  orDiamante=190;
  orOricalco=218;
  orHuesosCadaver=220;
  orCabezaAriete=241;
  orAriete=248;
  orFlauta=126;
  orLaud=127;
  ihVendas=222;
  orMonedaPlata=4;
  or100MonedasOro=7;
  orCuerno=139;
  orAmuletoGuerrero=110;
  orAmuletoGuardabosques=109;
  orBaulMagico=237;
  orGemaDelConjurador=238;
  orGemaMando=239;
  orUmbo=80;
  //Objetos
  ObHuesosCadaver:TArtefacto=(id:orHuesosCadaver;modificador:1);
  ObAmuletoMaligno:TArtefacto=(id:orHuesosCadaver;modificador:1);
  ObNuloMDV:TArtefacto=(id:0;modificador:0);//y mano derecha vacia
  ObManoIzqVacia:TArtefacto=(id:1;modificador:0);
  ObManoIzqOcupada:TArtefacto=(id:3;modificador:0);
  obCalderoMagico:TArtefacto=(id:ihCalderoMagico;modificador:0);
  obVaritaVacia:TArtefacto=(id:ihVaritaVacia;modificador:0);

// IDENTIFICADORES DE RECURSOS:
  SIN_RECURSOS=0;//igual que 255
  irLenna=1;
  irMadera=2;
  irMaderaMagica=3;
  irHierro=4;
  irArcanita=5;
  irPlata=6;
  irOro=7;
  irIngrediente0=8;
  irIngrediente1=9;
  irIngrediente2=10;
  irIngrediente3=11;
  irIngrediente4=12;
  irIngrediente5=13;
  irIngrediente6=14;
  irIngrediente7=15;
  irGema0=16;
  irGema1=17;
  irGema2=18;
  irGema3=19;
  irGema4=20;
  irGema5=21;
  irGema6=22;
  irGema7=23;
  irVegetal0=24;
  irVegetal1=25;
  irVegetal2=26;
  irVegetal3=27;
  irVegetales=28;
  irGemas=29;
  irBaulMagico=30;
  irFibrasParaTela=31;
  irFundicion=32;
  irTelar=33;
  irYunque=34;
  irCurtidora=35;
  irCarpinteria=36;
  irSastreria=37;
  irCastillo=38;
  irEstudioAlquimia=39;

  irEstudioMago=40;
  irTalladoGemas=41;
  irLugarEntrenamiento=42;
  irLugarDescanso=43;
  irLugarComunicacion=44;
  irAltarBendicion=45;
  irAltarConjuracion=46;
  irAltarAlineacionPlanetas=47;
  //Especiales:
  irAguaConPeces=200;

  COSTO_MEJORAR_VISION=       12500;
  COSTO_MEJORAR_ARMADURA=     12500;
  COSTO_MEJORAR_GUARDIA=      25000;
  COSTO_MEJORAR_FUERZA=       50000;
  COSTO_MEJORAR_TIEMPO=      100000;
  COSTO_MEJORAR_ATAQUE=      200000;
  COSTO_MEJORAR_MANA=        400000;
  COSTO_MEJORAR_RESISTENCIA= 800000;

  BONO_REGENERACION_GUARDIAN=50;

function B2aStr(nro:integer):TCadena4;
function B3aStr(nro:integer):TCadena4;
function B4aStr(nro:integer):TCadena4;
function strACadena127(const cad:string):string;
function intastr(valor:integer):string;
function GetVersion:string;//TODO: Cambiar nombre a GetLaaVersion   
function GetVersionCliente(version:byte):string;

procedure InicializarColeccionObjetos(const nombre:string);
procedure InicializarColeccionConjuros(const nombre:string);
function DefinirObjeto(grupo,codigo,modificador:byte):TArtefacto;
function ObjetoArtefacto(id,modificador:byte):TArtefacto;
function nombreObjeto(objeto:TArtefacto;const CapIdentificacion:TcapacidadIdentificacion):string;
function DescribirObjeto(objeto:TArtefacto;const CapIdentificacion:TcapacidadIdentificacion):string;
function nombreCortoObjeto(objeto:TArtefacto):string;
function BrilloObjeto(const objeto:TArtefacto;const CapIdentificacion:TcapacidadIdentificacion):TBrilloObjeto;
function MunicionCorrecta(const objeto,municion:TArtefacto):bytebool;
function ModificadorDefensaObjeto(const objeto:TArtefacto):integer;
function ModificadorDanno(const objeto:TArtefacto; var tipoDanno:TTipoArma):integer;
function CalcularModificadorAtaDef(const objeto:TArtefacto):integer;
function CalcularBono(const objeto:TArtefacto; var tipoDanno:TTipoArma):integer;//Tiene que estar reforzado
function RestarCantidadDeMaterialConst(var Objeto:Tartefacto;var cantidad:integer;SoloObjetosEnBuenEstado,ModificarObjeto:boolean):boolean;
//procedure QuitarMaldicionObjeto(var Objeto:Tartefacto);
function AgregarObjetoAObjeto(var ObjetoOrigen,ObjetoDestino:Tartefacto):byte;
function DeterminarIconoApropiado(objeto:Tartefacto):TIconoSeleccionado;
function IdentificarObjeto(var Objeto:Tartefacto):boolean;
function MaldecirObjeto(var Objeto:Tartefacto):boolean;
function BendecirObjeto(var Objeto,objetoValioso:Tartefacto):byte;
//function NivelMinimoDeObjetoMagico(Objeto:Tartefacto):byte;
function conjurarArma(var objetoGema:Tartefacto;ArmaArcana:bytebool):byte;
function controlArmaDannada(var arma:Tartefacto;durabilidad:byte):boolean;
function esObjetoQueCae(const Objeto:Tartefacto):boolean;
function NivelDanno(base,bono:integer):string;
function TieneModificadorDeObjetoHechizado(const objeto:Tartefacto):boolean;

function PrecioArtefacto(const objeto:Tartefacto):integer;
function NumeroElementos(const objeto:Tartefacto):byte;
function FijarNumeroElementos(var objeto:Tartefacto;nro_elementos:byte):bytebool;
procedure DecrementarCantidadMunicion(var Municion:Tartefacto);
procedure ExtraerCantidadObjeto(var objetoOrigen,ObjetoDestino:Tartefacto;cantidad:byte);
procedure CopiarCantidadObjeto(const objetoOrigen:Tartefacto;var ObjetoDestino:Tartefacto;cantidad:byte);
function MaximaCantidadDeEsteObjeto(const Objeto:Tartefacto):TTipoObjetoPorCantidad;
function EnvenenarObjeto(MascaraDeEnvenenamiento:byte;var Objeto:Tartefacto):boolean;
function DannarObjetoArmadura(var armadura:Tartefacto;danno:integer):boolean;
function EsIdObjetoHechizable(IdObjeto:byte):bytebool;
function EsIdDeArmadura(idObjeto:byte):bytebool;
function EsIdArmaduraMetalica(idObjeto:byte):bytebool;
function EsIdDeArmaOArmadura(IdObjeto:byte):bytebool;
procedure TruncarMagiaDeArtefacto(var Artefacto:Tartefacto);
function DineroAStr(dinero:integer):string;
function MaximaCantidadPorCasilla(const Objeto:Tartefacto):byte;

function HexToInt(const cadenaHex:string):integer;
function ArmaduraPorcentual(nivel_n:integer):string;

var
    InfObj:TDescriptoresObjetos;
    InfConjuro:TDescriptoresConjuros;
    NomObj:TNombresObjetos;
    NomConjuro:TNombresConjuros;


implementation

//------------------------------------------------------------------------------
//Implementacion
//------------------------------------------------------------------------------

function B2aStr(nro:integer):TCadena4;
begin
  result[0]:=#2;
  result[1]:=chr(nro and $FF);
  result[2]:=chr((nro shr 8) and $FF);
end;

function B3aStr(nro:integer):TCadena4;
begin
  result[0]:=#3;
  result[1]:=chr(nro and $FF);
  result[2]:=chr((nro shr 8 )and $FF);
  result[3]:=chr((nro shr 16)and $FF);
end;

function B4aStr(nro:integer):TCadena4;
begin
  result[0]:=#4;
  result[1]:=chr(nro and $FF);
  result[2]:=chr((nro shr 8 )and $FF);
  result[3]:=chr((nro shr 16)and $FF);
  result[4]:=chr((nro shr 24)and $FF);
end;

function intaStr(valor:integer):string;
begin
  str(valor,result);
end;

function HexToInt(const cadenaHex:string):integer;
var i:integer;
    c:char;
begin
  result:=0;
  for i:=1 to length(cadenaHex) do
  begin
    result:=result shl 4;
    c:=upcase(cadenaHex[i]);
    case c of
      '0'..'9':inc(result,ord(c)-ord('0'));
      'A'..'F':inc(result,ord(c)-ord('A')+10);
    end;
  end;
end;

function StrACadena127(const cad:string):string;
begin
  result:=copy(cad,1,127);
  result:=char(length(result))+result;
end;

function GetVersionCliente(version:byte):string;
begin
  case version of
    0..99:result:='Gold';
    100..199:result:='0.9';
    200..255:result:='Beta';
  end;
  result:=result+'.';
  if (version mod 100)<10 then result:=result+'0';
  result:=result+intastr(version mod 100);
end;

function GetVersion:string;
begin
  result:=GetVersionCliente(versionLA)
end;

function ArmaduraPorcentual(nivel_n:integer):string;
begin
  if nivel_n>0 then
    result:=intastr(100-(400 div (nivel_n+4)))+'%'
  else
    if nivel_n<0 then
      result:='-'+intastr((100*(-nivel_n)) shr 2)+'%'
    else
      result:='0%'
end;

procedure InicializarColeccionObjetos(const nombre:string);
var f:file of TArchivoObjetos;
    datosObjetos:TArchivoObjetos;
begin
    assignFile(f,nombre);
    fileMode:=0;
    reset(f);
    read(f,datosObjetos);
    closeFile(f);
{    if datosObjetos.CheckSum<>DeCriptico(datosObjetos.datos,sizeof(datosObjetos.datos)) then
      Halt(1);}
    NomObj:=datosObjetos.Nombre;
    InfObj:=datosObjetos.datos;
end;

procedure InicializarColeccionConjuros(const nombre:string);
var f:file of TArchivoConjuros;
    datosConjuros:TArchivoConjuros;
begin
  //Conjuros
  assignFile(f,nombre);
  fileMode:=0;
  reset(f);
  read(f,datosConjuros);
  closeFile(f);
{  if datosConjuros.CheckSum<>DeCriptico(datosConjuros.datos,sizeof(datosConjuros.datos)) then
    Halt(1);}
  NomConjuro:=datosConjuros.Nombre;
  InfConjuro:=datosConjuros.datos;
end;

function DefinirObjeto(grupo,codigo,modificador:byte):TArtefacto;
begin
  result.id:=(grupo shl 3) or (codigo and $7);
  result.modificador:=modificador;
end;

function ObjetoArtefacto(id,modificador:byte):TArtefacto;
begin
  result.id:=id;
  result.modificador:=modificador;
end;

// UTILITARIOS DE OBJETOS:

function MunicionCorrecta(const objeto,municion:TArtefacto):bytebool;
var tipo_municion,tipo_arco:byte;
//no controla que el objeto arma de rango sea en efecto un arma de rango
begin
  if municion.id shr 3=grFlechas then
  begin
    tipo_municion:=municion.id and $7;
    tipo_arco:=objeto.id and $7;
    result:=((tipo_municion>=4)and(tipo_arco>=4)) or (tipo_municion=tipo_arco);
  end
  else
    result:=false;
end;

function CalcularModificadorAtaDef(const objeto:TArtefacto):integer;
//Calcula modificador de ataque/defensa
//No controla el tipo de objeto
var tipoMagia:TTipoMagiaArtefacto;
begin
  tipoMagia:=TTipoMagiaArtefacto(objeto.modificador shr 6);
  //Si es objeto maldito/bendito que no modifica el daño/armadura
  if (tipoMagia=maModificador) and ((objeto.modificador and MskDanno)=0) then
    if (objeto.modificador and MskMaldito)=0 then//es bendito
      result:=(objeto.modificador and MskEstadoMagico)+1
    else//es maldito
      result:=-(objeto.modificador and MskEstadoMagico)-1
  else
    result:=0;
  result:=result*5{/20=>/100>}+InfObj[objeto.id].modificadorADC;
end;

function ModificadorDefensaObjeto(const objeto:TArtefacto):integer;
begin   //Sólo si es un objeto de protección/maldición
  if ((Objeto.id>=56) and (Objeto.id<=103)) or ((Objeto.id>=248) and (Objeto.id<=253)) then
    result:=CalcularModificadorAtaDef(objeto)
  else
    result:=0;
end;

function ModificadorDanno(const objeto:TArtefacto; var tipoDanno:TTipoArma):integer;
begin   //Sólo si es un objeto de protección/maldición
  if ((Objeto.id>=56) and (Objeto.id<=103)) or ((Objeto.id>=248) and (Objeto.id<=253)) then
    result:=CalcularBono(objeto, tipoDanno)
  else
    result:=0;
end;

function CalcularBono(const objeto:TArtefacto; var tipoDanno:TTipoArma):integer;
var tipoMagia:TTipoMagiaArtefacto;
begin
  result:=0;
  tipoMagia:=TTipoMagiaArtefacto(objeto.modificador shr 6);
  if (tipoMagia=maModificador) then
  begin
    if (objeto.modificador and MskDanno)<>0 then//modifica el danno
      if (objeto.modificador and mskMaldito)=0 then//es objeto bendito
        result:=(objeto.modificador and MskEstadoMagico)+1
      else//es objeto maldito
        result:=-(objeto.modificador and MskEstadoMagico)-1;
  end
  else
    if (tipoMagia=maElemento) then
    begin
      result:=(objeto.modificador and MskEstadoMagico)+1;
      TipoDanno:=TTipoArma(((objeto.modificador and MskBitsDeTipoDeDannoPorElemento) shr 3)+3);
    end;
end;

function EstadoObjeto(const Modificador:byte;var tipoMagia:TTipoMagiaArtefacto;var modificaDanno,malvado,identificado:bytebool):byte;
//Requerimientos:
//identificado inicialmente tiene que tener el estado de vision verdadera.
begin
  //Objetos normales: $3F= estado uso.
  modificaDanno:=bytebool(modificador and MskDanno);//True,False (objetos mágicos)
  identificado:=bytebool(modificador and MskIdentificado);
  tipoMagia:=TTipoMagiaArtefacto(modificador shr 6);
  malvado:=false;
  if tipoMagia=maNinguna then
    result:=modificador and MskEstadoObjetoNormal//0..63 (para normales, se deterioran, 63=excelente estado)
  else
    if tipoMagia=maHechizo then
      result:=modificador and $1F//para objetos mágicos especiales
    else
    begin
      result:=modificador and MskEstadoMagico;//para objetos de alineación mágica malvada/bendita y los modificados por elementos
      malvado:=(tipoMagia=maModificador) and ((modificador and mskMaldito)<>0);
    end;
end;

function BrilloObjeto(const objeto:TArtefacto;const CapIdentificacion:TcapacidadIdentificacion):TBrilloObjeto;
var tipoMagia:TTipoMagiaArtefacto;
    estaIdentificado,modificaDanno,esMalvado:bytebool;
begin
  result:=boNinguno;
  case objeto.id of
    16..47,56..103,248..253://Artefactos benditos/malditos por bono en daño,ataque,defensa.
    begin
      EstadoObjeto(objeto.modificador,tipoMagia,modificaDanno,esMalvado,estaIdentificado);
      if (tipoMagia<>maNinguna) then
        if estaIdentificado or (CapIdentificacion=ciVerRealmente) then
        begin
          if (tipoMagia=maModificador) and esMalvado then
            result:=boMalvado
          else
            result:=boMagico;
        end
        else
        begin
          if (tipoMagia=maModificador) and esMalvado and bytebool(CapIdentificacion and ciMaldad) then
            result:=boMalvado
          else
            if bytebool(CapIdentificacion and ciMagia) then
              result:=boMagico;
        end;
    end;
    104..111,ihCalderoMagico,ihVaritaLlena,orMaderaMagica,ihPlumaMagica,orTrampaMagica,
      orBaulMagico,orGemaMando,orGemaDelConjurador,orTomoExperiencia:result:=boMagico;
    48..55://envenenables
    begin
      if ByteBool(objeto.modificador and MskEnvenenado) then
        result:=boVenenoso;
      if ByteBool(objeto.modificador and MskParalizante) then
        result:=boMagico
    end;
  end;
end;

function nombreObjeto(objeto:TArtefacto;const CapIdentificacion:TcapacidadIdentificacion):string;
var estado,nroObjetos:byte;
    tipoMagia:TTipoMagiaArtefacto;
    modificaDanno,estaIdentificado,esMaldito:bytebool;
  function EstadoPorcentual(estado:integer):string;
  begin
    estado:=(estado shl 1);
    if estado>100 then estado:=100;
    result:=intastr(estado);
  end;
begin
  result:=NomObj[objeto.id];
  case objeto.id of
  4..7://Para el dinero
    result:=intastr(objeto.modificador)+result;
  16..47,56..103,248..253://Artefactos benditos/malditos por bono en daño,ataque,defensa.
  begin
    estado:=EstadoObjeto(objeto.modificador,tipoMagia,modificaDanno,esMaldito,estaIdentificado);
    estaIdentificado:=estaIdentificado or (CapIdentificacion=ciVerRealmente);
    if tipoMagia=maNinguna then
    begin
      if (objeto.id<=97) or (objeto.id>=248) then//No para anillos
        result:=result+' ('+EstadoPorcentual(estado)+'%)'
    end
    else
      if estaIdentificado then
        case tipoMagia of
          maModificador:
            if esMaldito then
            begin
              if modificaDanno then
              begin
                result:=result+' -'+intastr(estado+1)+' ';
                if objeto.id>=56 then//armaduras
                  result:=result+'armadura'
                else//armas
                  result:=result+'daño';
              end
              else
              begin
                result:=result+' -'+intastr((estado+1)*5)+'% ';
                if objeto.id>=56 then//armaduras
                  result:=result+'defensa'
                else//armas
                  result:=result+'ataque';
              end
            end
            else
            begin
              if modificaDanno then
              begin
                result:=result+' +'+intastr(estado+1)+' ';
                if objeto.id>=56 then//armaduras
                  result:=result+'armadura'
                else//armas
                  result:=result+'daño';
              end
              else
              begin
                result:=result+' +'+intastr((estado+1)*5)+'% ';
                if objeto.id>=56 then//armaduras
                  result:=result+'defensa'
                else//armas
                  result:=result+'ataque';
              end
            end;
          maHechizo:result:=result+' +Hechizo';
          maElemento:
          begin
            result:=result+' +'+intastr(estado+1)+' ';
            case (objeto.modificador and (MskBitsDeTipoDeDannoPorElemento or MskModificadorDeDannoPorElemento)) of
              MskDannoFuego:result:=result+' (Fuego)';
              MskDannoHielo:result:=result+' (Hielo)';
              MskDannoRayo:result:=result+' (Rayo)';
              else result:=result+' (Veneno)';
            end;
          end;
        end
      else
      begin
        if (tipoMagia=maModificador) and (esMaldito) and
          bytebool(CapIdentificacion and ciMaldad) then
          result:=result+' +Maldición'
        else
          if bytebool(CapIdentificacion and ciMagia) then
            result:=result+' +Hechizo'
          else
            if (objeto.id<=97) or (objeto.id>=248) then//No para anillos
              result:=result+' (100%)';
      end;
  end;
  ihPergaminoA,ihPergaminoS:
    with InfConjuro[Objeto.modificador and $1F] do
      result:=NomConjuro[Objeto.modificador and $1F]+', Nivel:'+intastr(nivelJugador)+
        ' Int:'+intastr(nivelINT*5)+'% Sab:'+intastr(nivelSAB*5)+'%';
  144..175,192..231://Recursos
  begin
    nroObjetos:=objeto.modificador;
    if nroObjetos<>1 then result:=result+' ('+intastr(nroObjetos)+' unidades)';
  end;
  48..55://Envenenables
  begin
    nroObjetos:=objeto.modificador and MskNroObjetos;
    if nroObjetos<>1 then result:=result+' ('+intastr(nroObjetos)+' piezas)';
    if ByteBool(objeto.modificador and MskEnvenenado) then
      if ByteBool(objeto.modificador and MskParalizante) then
        result:=result+' +Ven.+Par.'
      else
        result:=result+' +Veneno'
    else
      if ByteBool(objeto.modificador and MskParalizante) then
        result:=result+' +Parálisis'
  end;
  136..140,143://Consumibles
    result:=result+' ('+intastr(objeto.modificador)+' usos)';
  141:
    result:=result+' ('+intastr(objeto.modificador)+' gr.)';
  142:
    result:=result+' ('+intastr(objeto.modificador)+' maná)';
  orAmuletoGuardabosques,orAmuletoGuerrero:
    result:=result+' +'+intastr(Objeto.modificador shr 2)+'%';

  176..183://llaves
    if objeto.modificador<>0 then result:=result+' (#'+intastr(objeto.modificador)+')';
  orTomoExperiencia:
    result:=result+' ('+intastr(objeto.modificador*1000)+' exp.)';
  orGemaInicial..orGemaFinal://Gemas
  begin
    estado:=objeto.modificador;
    if estado<=100 then
      result:=result+' '+intastr(estado)+'%'
    else
      result:=result+' de tallado único';
    end;
  end;
//  result:=result+' '+intastr(precioArtefacto(objeto))+'mp'
end;

function NivelDanno(base,bono:integer):string;
begin
  if bono<=1 then
    if base=0 then
      result:='---'
    else
      if base>0 then
        result:='+'+intastr(base)
      else
        result:=intastr(base)
  else
    result:=intastr(base)+' a '+intastr(base+bono-1);
end;

function DescribirObjeto(objeto:TArtefacto;const CapIdentificacion:TcapacidadIdentificacion):string;
var BonoVisible,ModificadorVisible:integer;
  tipoDanno:TTipoArma;
  function intastrPorcentual(valor:integer):string;
  begin//Para mostrar armas y armaduras encantadas
    str(valor,result);
    if valor>0 then result:='+'+result;
    result:=result+'%';
  end;
begin
  with infObj[objeto.id] do
  begin
    tipoDanno:=TipoArma;
    if ((Objeto.modificador and MskIdentificado)<>0) or (CapIdentificacion=ciVerRealmente) then
    begin
      BonoVisible:=calcularBono(Objeto,tipoDanno);
      ModificadorVisible:=calcularModificadorAtaDef(Objeto);
    end
    else
    begin
      BonoVisible:=0;
      ModificadorVisible:=infObj[objeto.id].modificadorADC;
    end;
    case objeto.id of
      //armas conjuradas, municiones, no tienen bonos
      8..15,48..55:result:='Ataque: '+intastrPorcentual(infObj[objeto.id].modificadorADC)+
        '  Daño: '+NivelDanno(danno1B,danno1P)+' PM / '+NivelDanno(danno2B,danno2P)+' G  ('+
        MC_TipoDeArma[ord(TipoArma)]+')';
      //armas
      16..47:result:='Ataque: '+intastrPorcentual(ModificadorVisible)+
        '  Daño: '+NivelDanno(danno1B+BonoVisible,danno1P)+' PM / '+NivelDanno(danno2B+BonoVisible,danno2P)+' G  ('+
        MC_TipoDeArma[integer(tipoDanno)]+')';
      //armaduras
      56..103,248..253:result:='Defensa: '+intastrPorcentual(ModificadorVisible)+
        '  Punz: '+ArmaduraPorcentual(danno1B)+
        '  Cort: '+ArmaduraPorcentual(danno1P)+
        '  Cont: '+ArmaduraPorcentual(danno2B)+
        '  Mágica: '+ArmaduraPorcentual(danno2P+BonoVisible);
    else
      result:='';
    end;
  end;
end;

//Funciones que consideran objetos que se pueden acumular en una casilla.

function MaximaCantidadDeEsteObjeto(const Objeto:Tartefacto):TTipoObjetoPorCantidad;
begin
  case objeto.id of
    48..55://Objetos que pueden ser envenenados
      result:=toCantidad_60;
    4..15,144..175,192..231://Objetos con cantidad 1byte;
      result:=toCantidad_250;
    else result:=toCantidad_1;
  end;
end;

function MaximaCantidadPorCasilla(const Objeto:Tartefacto):byte;
begin
  case MaximaCantidadDeEsteObjeto(objeto) of
    toCantidad_60://Objetos que pueden ser envenenados
      result:=60;
    toCantidad_250://Objetos con cantidad 1byte;
      result:=250;
    else result:=1;
  end;
end;

function NumeroElementos(const objeto:Tartefacto):byte;
begin
  case MaximaCantidadDeEsteObjeto(objeto) of
    toCantidad_60://Objetos que pueden ser envenenados
      result:=objeto.modificador and mskNroObjetos;
    toCantidad_250://Objetos con cantidad 1byte;
      result:=objeto.modificador
    else result:=1;
  end;
end;

function FijarNumeroElementos(var objeto:Tartefacto;nro_elementos:byte):bytebool;
begin
  if nro_elementos=0 then
  begin
    result:=false;
    exit;
  end;
  case MaximaCantidadDeEsteObjeto(objeto) of
    toCantidad_60://Objetos que pueden ser envenenados
    begin
      result:=nro_elementos<=MAX_NRO_OBJETOS_VENENOxCASILLA;
      if result then
        objeto.modificador:=(objeto.modificador and MskDescriptorEnvenenables) or nro_elementos;
    end;
    toCantidad_250://Objetos con cantidad 1byte;
    begin
      result:=nro_elementos<=MAX_NRO_OBJETOSxCASILLA;
      if result then
        objeto.modificador:=nro_elementos;
    end
    else
      result:=nro_elementos=1;
  end;
end;


function PrecioArtefacto(const objeto:Tartefacto):integer;
var esMaldito,modificaDanno,estaIdentificado:byteBool;
    estado:integer;
    tipoMagia:TTipoMagiaArtefacto;
begin
  result:=InfObj[objeto.id].costo;
  if result=0 then exit;
  case MaximaCantidadDeEsteObjeto(objeto) of
    toCantidad_60://envenenables
      if bytebool(objeto.modificador and MskDescriptorEnvenenables) then
        result:=(result*(objeto.modificador and MskNroObjetos)) shl 1
      else
        result:=result*(objeto.modificador and MskNroObjetos);
    toCantidad_250:
      result:=result*objeto.modificador;
    else
      case objeto.id of
        //normales, cantidad 1byte (23=gemas talladas está aqui por que su precio se calcula
        //como si su identificador fuera cantidad.)
        orAmuletoGuerrero,orAmuletoGuardabosques://Amuletos
          result:=(result*objeto.modificador) shr 5;//Nota: en realidad 32=100% del precio
        orGemaInicial..orGemaFinal://Gemas
          result:=result*objeto.modificador;
        //Pergaminos, los otros objetos quedan con el precio especificado en el editor de artefactos
        ihPergaminoA,ihPergaminoS:
             result:=Infconjuro[objeto.modificador and $1F].CostoCnjr;
        //Hechizables, sincronizar con editor de objetos
        16..47,56..103,248..253:
        begin
          estado:=EstadoObjeto(Objeto.modificador,tipoMagia,modificaDanno,esMaldito,estaIdentificado);
          case tipoMagia of
            maNinguna:begin
              estado:=estado shl 1;//*2 (0..63 a 0..126)
              if estado>64 then estado:=64;
              result:=result*estado shr 6;
              if result<1 then result:=1;
            end;
            maModificador:
              if estaIdentificado then
                if esMaldito then
                  result:=(result+1) shr 1
                else
                begin
                  estado:=1+(objeto.modificador and MskEstadoMagico);
                  inc(result,estado shl 13);
                end;
            maElemento:
              if estaIdentificado then
              begin
                estado:=1+(objeto.modificador and MskEstadoMagico);
                inc(result,estado shl 12);
              end;
            maHechizo:
              if estaIdentificado then inc(result,5000);
          end;
        end;
      end;
  end;
end;

function EnvenenarObjeto(MascaraDeEnvenenamiento:byte;var Objeto:Tartefacto):boolean;
begin
  result:=true;
  with objeto do
  case id of
    48..55:modificador:=modificador or MascaraDeEnvenenamiento
    else result:=false;
  end;
end;

function RestarCantidadDeMaterialConst(var Objeto:Tartefacto;var cantidad:integer;SoloObjetosEnBuenEstado,ModificarObjeto:boolean):boolean;
//SoloObjetosEnBuenEstado=false => cuenta el modificador para efectos., para gemas el valor va de 1 a 100.
//SoloObjetosEnBuenEstado=true => De los hechizables sólo los modificadores de 25 a 63, de las gemas los mod. de 25 a 100
//ModificarObjeto=true, resta cantidad de "Objeto"
//ModificarObjeto=false, no modifica la variable "Objeto"
//No funciona con objetos envenenables.
var NroElementosObjeto:byte;
//OJO cantidad siempre >0!!
begin
  with objeto do
  begin
    case id of
      orGemaInicial..orGemaFinal://gemas
        if (modificador<=100) and ((not SoloObjetosEnBuenEstado) or (modificador>=25)) then
          NroElementosObjeto:=1
        else
          NroElementosObjeto:=0;
      16..47,56..103,248..253:
        if ((modificador>=40) and (modificador<=63)) or (not SoloObjetosEnBuenEstado) then
          NroElementosObjeto:=1
        else
          NroElementosObjeto:=0;
    else
      NroElementosObjeto:=NumeroElementos(Objeto);
    end;
    result:=NroElementosObjeto>0;
    if not result then exit;
    if ModificarObjeto then
      if cantidad>=NroElementosObjeto then
        Objeto:=ObNuloMDV
      else
        dec(modificador,cantidad);
    dec(cantidad,NroElementosObjeto);
    if cantidad<0 then cantidad:=0;
  end;
end;

procedure DecrementarCantidadMunicion(var Municion:Tartefacto);
var cantidadRestante:integer;
begin
  cantidadRestante:=(Municion.modificador and MskNroObjetos);
  if cantidadRestante<=1 then
    Municion:=ObNuloMDV
  else
    dec(Municion.modificador);
end;

function AgregarObjetoAObjeto(var ObjetoOrigen,ObjetoDestino:Tartefacto):byte;
//OJO que si ambos objetos no son iguales no pasa nada.
//Devuelve True si pudo colocar todo o parte del objeto origen en el destino.
//Devuelve MOVIO_TODO_A_DESTINO si ObjetoOrigen=Vacio (coloco todo en el destino);
var cantidadDestino:integer;
begin
result:=0;
if ObjetoOrigen.id=ObjetoDestino.id then
 //flags de envenenado/no envenenado iguales.
 //mskEnvenenado igual en ambos objetos.
  case MaximaCantidadDeEsteObjeto(objetoDestino) of
    toCantidad_250://Objetos con cantidad 1byte
    begin
      cantidadDestino:=ObjetoDestino.modificador;
      if cantidadDestino<MAX_NRO_OBJETOSxCASILLA then
      begin
        inc (cantidadDestino,ObjetoOrigen.modificador{CantidadOrigen});
        if cantidadDestino>MAX_NRO_OBJETOSxCASILLA then
        begin
          ObjetoOrigen.modificador:=CantidadDestino-MAX_NRO_OBJETOSxCASILLA;
          cantidadDestino:=MAX_NRO_OBJETOSxCASILLA;
          result:=1;//MOVIMIENTO PARCIAL
        end
        else
        begin
          result:=MOVIO_TODO_A_DESTINO;
          ObjetoOrigen:=ObNuloMDV;
        end;
        ObjetoDestino.modificador:=cantidadDestino;
      end;
    end;
    toCantidad_60://Objetos que pueden ser envenenados
    if ((ObjetoOrigen.modificador xor ObjetoDestino.modificador) and MskDescriptorEnvenenables)=0 then
    begin//Si ambos modificadores de estatus de objeto envenenable son iguales:
      cantidadDestino:=ObjetoDestino.modificador and mskNroObjetos;
      if cantidadDestino<MAX_NRO_OBJETOS_VENENOxCASILLA then
      begin
        inc (cantidadDestino,ObjetoOrigen.modificador and MskNroObjetos{CantidadOrigen});
        if cantidadDestino>MAX_NRO_OBJETOS_VENENOxCASILLA then
        begin
          ObjetoOrigen.modificador:=(ObjetoOrigen.modificador and MskDescriptorEnvenenables) or
            (CantidadDestino-MAX_NRO_OBJETOS_VENENOxCASILLA){cantidadOrigen};
          cantidadDestino:=MAX_NRO_OBJETOS_VENENOxCASILLA;
          result:=1;
          ObjetoDestino.modificador:=(ObjetoDestino.modificador and MskDescriptorEnvenenables) or cantidadDestino;
        end
        else
        begin
          result:=MOVIO_TODO_A_DESTINO;
          ObjetoOrigen:=ObNuloMDV;
          ObjetoDestino.modificador:=(ObjetoDestino.modificador and MskDescriptorEnvenenables) or cantidadDestino;
        end;
      end;
    end;
  end;
end;

function DeterminarIconoApropiado(objeto:Tartefacto):TIconoSeleccionado;
//Revisar:
//Demonios, function TjugadorS.PuedeConsumir(indArt:byte):boolean;
//Para verificar los tipos de objetos.
begin
  case objeto.id of
    48..55:result:=uMunicion;
    56..79,248..253:result:=uArmadura;
    88..95:result:=uCasco;
    96..97:result:=uBrazaletes;
    98..103:result:=uAnillo;
    104..111,orGemaInicial..orGemaFinal,176..183,orGemaDelConjurador,orGemaMando:result:=uAmuleto;
    128..133:result:=uConstructor;
    4..7,120..127,134..141,200..209,211..223,225..237:result:=uHerramienta;
    112..119,168..175{ingredientes..Llaves},240..243{Artefactos}:result:=uArmaDer;
    144..167,224{Comidas,Bebidas,Pociones}:result:=uConsumible;
    80..87{Escudos},192..199{gemas sin tallar},ihVaritaLlena,orPergamino:result:=uArmaIzq;
    8..47:if InfObj[objeto.id].pesoArma=paLigera then result:=uArmaIzq else result:=uArmaDer;
    else
      result:=uNoDefinido;
  end;
end;

function IdentificarObjeto(var Objeto:Tartefacto):boolean;
begin
  result:=false;
  if EsIdObjetoHechizable(Objeto.id) then
    with Objeto do
      if (TTipoMagiaArtefacto(modificador shr 6)<>maNinguna) and
        not byteBool(Objeto.modificador and MskIdentificado) then
      begin
        Objeto.modificador:=Objeto.modificador or MskIdentificado;
        result:=true;
      end;
end;

function MaldecirObjeto(var Objeto:Tartefacto):boolean;
begin
  result:=EsIdObjetoHechizable(objeto.id);
  if result then
    with Objeto do
      case TTipoMagiaArtefacto(modificador shr 6) of
        maNinguna:modificador:=MskBendicionMaldicion or mskMaldito or MskEstadoMagico;//maldicion.
        maModificador:
          if (modificador and MskMaldito)=0 then
            if (modificador and MskEstadoMagico)=0 then
              modificador:=MskEstadoObjetoNormal//Se vuelve arma normal
            else
              modificador:=(modificador and $F8) or ((modificador and MskEstadoMagico)-1)//Pierde 1 nivel
          else
            modificador:=modificador or MskDanno or MskEstadoMagico;//la peor maldición
        maElemento:
          if (modificador and MskEstadoMagico)=0 then
            modificador:=MskEstadoObjetoNormal//Se vuelve arma normal
          else
            modificador:=(modificador and $F8) or ((modificador and MskEstadoMagico)-1);//Pierde 1 nivel
        maHechizo:
          if (modificador and MskTipoMagiaEspecial)=MskTipoMagiaEspecial then
            modificador:=MskEstadoObjetoNormal;//Se vuelve arma normal
          else
            modificador:=modificador or MskTipoMagiaEspecial;//Pierde cualquier otro efecto adicional
      end;
end;

function conjurarArma(var objetoGema:Tartefacto;ArmaArcana:bytebool):byte;
begin
  result:=i_NecesitasGemaTallada;
  if (objetoGema.id<orGemaInicial) or (objetoGema.id>orGemaFinal) then exit;
  if ArmaArcana then
    result:=i_NecesitasGemaParaArcana
  else
    result:=i_NecesitasGemaParaSagrada;
  if ArmaArcana xor ((objetoGema.id and $1)=0) then exit;//no concuerda gema con conjuro
  result:=i_EstaGemaNoEsAdecuada;
  if (objetoGema.modificador<1) or (objetoGema.modificador>100) then exit;
  ObjetoGema.id:=8+(objetoGema.id and $7);
  result:=i_ok;
end;

function BendecirObjeto(var Objeto,objetoValioso:Tartefacto):byte;
var nivelBendicion,nivelDeConsumo:byte;
begin
  with Objeto do
  begin
    if id<4 then
    begin
      result:=i_SeleccionaObjetoInventario;exit;
    end;
    if not EsIdObjetoHechizable(id) then
    begin
      result:=i_ElObjetoNoSePuedeHechizar;exit;//No es bendecible
    end;
    if (modificador>63) then
    begin
      if (TTipoMagiaArtefacto(modificador shr 6)=maModificador) and
        ((modificador and MskMaldito)<>0) then
      begin
        modificador:=50;
        result:=i_ok;
        exit;
      end;
      result:=i_ElObjetoYaEstaHechizado;exit;
    end;
    if (modificador<45) then
    begin
      result:=i_NoTieneCalidadParaBendecir;exit;
    end;
    nivelBendicion:=0;
    result:=i_NecesitasObjetoValioso;
    if (objetoValioso.id>=orGemaHielo) and (objetoValioso.id<=orDiamante) then
    begin
      if (objetoValioso.id=orDiamante) and EsIdDeArmadura(id) then
      begin
        result:=i_ElBrillanteNoAfectaArmaduras;
        exit;
      end;
      if (objetoValioso.modificador>=90) and
        (objetoValioso.modificador<=100) then
      begin
        case objetoValioso.modificador of
          93..94:nivelBendicion:=1;
          95:nivelBendicion:=2;
          96:nivelBendicion:=3;
          97:nivelBendicion:=4;
          98:nivelBendicion:=5;
          99:nivelBendicion:=6;
          100:nivelBendicion:=7;
        end;
        case objetoValioso.id of
          orGemaHielo:nivelBendicion:=nivelBendicion or MskDannoHielo;
          orGemaRayo:nivelBendicion:=nivelBendicion or MskDannoRayo;
          orGemaVeneno:nivelBendicion:=nivelBendicion or MskDannoVeneno;
          orGemaFuego:nivelBendicion:=nivelBendicion or MskDannoFuego;
          orDiamante:nivelBendicion:=nivelBendicion or MskBendicionMaldicion or MskDanno;
        end;
        objetoValioso:=ObNuloMDV;
        result:=i_ok;
      end
      else
      begin
        if (objetoValioso.modificador>100) then
          result:=i_EstaGemaNoEsAdecuada
        else
          result:=i_NecesitasGema90a100;
        exit;
      end;
    end;
    if (objetoValioso.id=orOricalco) and (objetoValioso.modificador>0) then
    begin
      case objetoValioso.modificador of
      //mucho ojo con esto!!!
        1..3:begin
          nivelBendicion:=0; //100%
          nivelDeConsumo:=1;
        end;
        4..8:begin
          nivelBendicion:=1; //200%
          nivelDeConsumo:=4;
        end;
        9..15:begin
          nivelBendicion:=2; //300%
          nivelDeConsumo:=9;
        end;
        16..24:begin
          nivelBendicion:=3;//400%
          nivelDeConsumo:=16;
        end;
        25..35:begin
          nivelBendicion:=4;//500%
          nivelDeConsumo:=25;
        end;
        36..48:begin
          nivelBendicion:=5;//600%
          nivelDeConsumo:=36;
        end;
        49..63:begin
          nivelBendicion:=6;//700%
          nivelDeConsumo:=49;
        end;
        64..255:begin
          nivelBendicion:=7;//800%
          nivelDeConsumo:=64;
        end;
        else
          nivelDeConsumo:=0;
      end;
      dec(objetoValioso.modificador,nivelDeConsumo);
      if objetoValioso.modificador=0 then
        objetoValioso:=ObNuloMDV;
      nivelBendicion:=nivelBendicion or MskBendicionMaldicion;
      result:=i_ok;
    end;
    if result<>i_ok then exit;
    modificador:=nivelBendicion;
  end;
end;

function DannarObjetoArmadura(var armadura:Tartefacto;danno:integer):boolean;
begin
  result:=(((armadura.id>=56) and (armadura.id<=97)) or ((armadura.id>=248) and (armadura.id<=253)))
   and (armadura.modificador<=MskEstadoObjetoNormal);
  if result then
    if (armadura.modificador>danno) then dec(armadura.modificador,danno) else armadura:=ObNuloMDV;
end;

function controlArmaDannada(var arma:Tartefacto;durabilidad:byte):boolean;
//no controla que el objeto sea arma
begin
  //Armas mágicas, armas normales.
  result:=((arma.id shr 3)=1)or ((random(durabilidad)=0)and(arma.modificador<=MskEstadoObjetoNormal)and(arma.id>=16));
  if result then
    if (arma.modificador>1) then dec(arma.modificador) else arma:=ObNuloMDV;
end;

procedure CopiarCantidadObjeto(const objetoOrigen:Tartefacto;var ObjetoDestino:Tartefacto;cantidad:byte);
var ObjetoOrigenTemporal:Tartefacto;
begin
  ObjetoOrigenTemporal:=objetoOrigen;
  ExtraerCantidadObjeto(ObjetoOrigenTemporal,ObjetoDestino,cantidad);
end;

procedure ExtraerCantidadObjeto(var objetoOrigen,ObjetoDestino:Tartefacto;cantidad:byte);
//No controla si ObjetoOrigen es un objeto nulo (id<4), ObjetoDestino es sobreescrito.
var NroElementos,flagModificador:byte;
begin
  NroElementos:=NumeroElementos(objetoOrigen);
  if NroElementos<=cantidad then
  begin//MoverTodo, cant 1.
    ObjetoDestino:=ObjetoOrigen;
    ObjetoOrigen:=ObNuloMDV;
  end
  else
    case ObjetoOrigen.id of
      48..55://Objetos que pueden ser envenenados: clases 6,18..19, cant. 1 a 60
      begin
        ObjetoDestino.id:=ObjetoOrigen.id;
        flagModificador:=ObjetoOrigen.modificador and MskDescriptorEnvenenables;
        ObjetoDestino.modificador:=cantidad or flagModificador;
        ObjetoOrigen.modificador:=(NroElementos-cantidad) or flagModificador;
      end
      else//Objetos con cantidad 1 a 250
      begin
        ObjetoDestino.id:=ObjetoOrigen.id;
        ObjetoDestino.modificador:=cantidad;
        ObjetoOrigen.modificador:=NroElementos-cantidad;
      end
    end;
end;

function nombreCortoObjeto(objeto:TArtefacto):string;
begin
  if (objeto.id=ihPergaminoA) or (objeto.id=ihPergaminoS) then
    result:='Hechizo '+NomConjuro[objeto.modificador and $1F]
  else
    if (objeto.id>=orGemaInicial) and (objeto.id<=orGemaFinal) then
      result:=NomObj[objeto.id]+' '+intastr(objeto.modificador)+'%'
    else
      result:=NomObj[objeto.id];
end;

function EsIdDeArmadura(idObjeto:byte):bytebool;
begin
  result:=((IdObjeto>=56) and (IdObjeto<=103)) or
    ((IdObjeto>=248) and (IdObjeto<=253));
end;

//TODO: agregar al editor de objetos como flag
function EsIdArmaduraMetalica(idObjeto:byte):bytebool;
begin
  result:=((IdObjeto>=62) and (IdObjeto<=71));
end;

function EsIdObjetoHechizable(idObjeto:byte):bytebool;
begin
  result:=((IdObjeto>=16) and (IdObjeto<48)) or EsIdDeArmadura(idObjeto);
end;

function EsIdDeArmaOArmadura(idObjeto:byte):bytebool;
begin
  result:=((IdObjeto>=8) and (IdObjeto<=55)) or EsIdDeArmadura(idObjeto);
end;

procedure TruncarMagiaDeArtefacto(var Artefacto:Tartefacto);
//TODO: Si fuera necesario.
var tipoMagia:TTipoMagiaArtefacto;
    estaIdentificado,modificaDanno,esMalvado:bytebool;
begin
  EstadoObjeto(Artefacto.modificador,tipoMagia,modificaDanno,esMalvado,estaIdentificado);
  if tipoMagia<>maNinguna then
    if tipoMagia=maHechizo then
    //Fijar magia mas simple: Objeto indestructible.
      Artefacto.modificador:=Artefacto.modificador and $E0
    else
    //Fijar modificador de magia en 0.
      Artefacto.modificador:=Artefacto.modificador and $F8
end;

function esObjetoQueCae(const Objeto:Tartefacto):boolean;
begin
  result:=false;
  if PrecioArtefacto(objeto)<=400 then exit;
  case objeto.id of
    16..47,56..103,248..253:
      if ((objeto.modificador and mskMagiaEspecial)=mskMagiaEspecial) and
        ((objeto.modificador and mskTipoMagiaEspecial)=0) then exit;
    176..183:if objeto.modificador<>0 then exit;
  end;
  if objeto.id=orBaulMagico then exit;
  if objeto.id<4 then exit;
  result:=true;
end;

function DineroAStr(dinero:integer):string;
var NroMonedas:integer;
begin
  NroMonedas:=Dinero div 100;
  if NroMonedas>0 then
    result:=intastr(NroMonedas)+'mo'
  else
    result:='';
  NroMonedas:=Dinero mod 100;
  if NroMonedas>0 then
  begin
    if Dinero>=100 then
      result:=result+' y ';
    result:=result+intastr(NroMonedas)+'mp';
  end;
  if result='' then result:='0mo';
end;

function TieneModificadorDeObjetoHechizado(const objeto:Tartefacto):boolean;
begin
  result:=(objeto.modificador and MskNroObjetos)<>0;
end;

end.

