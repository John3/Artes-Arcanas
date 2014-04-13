(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit UCliente;

interface
uses forms,controls,classes,stdCtrls,windows,graphics,directDraw,sprites,graficador,demonios;

const MAX_LABELESxDIBUJADOR=15;//16
      MAX_PANELESxDIBUJADOR=4;//4
      NOMBRE_FONT='Times New Roman';
//Posiciones de los iconos de materiales para construir:
      POSX_IconosMaterialesConstruccion=491;
      POSY_IconosMaterialesConstruccion=50;
      IP_SERVIDOR_LOCAL='127.0.0.1';
//      MC_NECESARIO_MODO16BITS='En modo ventana es necesaria'+#13+'resolución de color de 16 bits';
      MC_CONTRASENNA_CORTA='Tu contraseña no debe ser tan corta';
      MC_CONTRASENNA_CONFIRMACION='La contraseña difiere de la confirmación';
      MC_CONTRASENNA_CON_LOGIN='Tu contraseña no debe ser similar al nombre';
      MC_CONTRASENNA_CON_REPETICIONES='La contraseña no debe tener repeticiones';
      MC_INDICA_IDENTIFICADOR='Indica la contraseña actual y nueva sin espacios';
      MEN_ANTI_ABUSO_CREACION='Ya creaste varios avatares. Tienes que subir de nivel'+#13+
                              'con alguno de ellos antes de poder crear más.';
      MEN_ABRE_EL_BAUL='Primero abre el baúl mágico';
      MEN_REVISA_LA_BOLSA='Primero elige el objeto que quieres recoger';
      MEN_SIN_MULTIPLES_SESIONES='XQ¯Q†:†1©J£M¥\ J‡P‚\ŒD’1“9¦B‘V4°SŒ=”5Š^°0©>–G¬]¤BŽA®1—@£8–5¯B¯0¦_ C“Z®\’VƒW‰5§[¯PŠ';

type
//LABEL LOGICO
  TRegistroPaneles=record
         left,top:integer;
         canvas:Tcanvas;
       end;
  TVentanaActivada=(vaNinguna,vaMenuConstruccion,vaMenuOpciones,vaMenuConfirmacion,vaMenuComercio,vaInformacion,vaMenuBaul,vaMenuObjetos);
  Tetiqueta=string[39];
  TDibujadorLabel=class;
  TLabelLogico=class(Tobject)
  private
    fcaption:Tetiqueta;
    fDibujadorLabel:TDibujadorLabel;//referencia
    procedure setCaption(Ncaption:Tetiqueta);
  public
    left,top:integer;
    ancho_a,alto_a:integer;
    IdPanel:integer;
    Color:Tcolor;
    valido:bytebool;
    alineacion:TAlineacionX;
    constructor create(Nleft,Ntop,NIdPanel:integer;DibujadorLabel:TDibujadorLabel);
    property caption:Tetiqueta read fcaption write setCaption;
  end;

//DIBUJADOR DE LABEL LOGICO
  TDibujadorLabel=class(Tobject)
  private
    valido:bytebool;
    fancho,falto:integer;
    fsuperficie:IDirectDrawSurface7;//referencia
    fLabel:array[0..MAX_LABELESxDIBUJADOR] of TLabelLogico;//referencias
    fPanel:array[0..MAX_PANELESxDIBUJADOR] of TRegistroPaneles;
  public
    destructor destroy; override;
    procedure invalidar;
    function NecesitaDibujarse:bytebool;
    constructor create(superficie:IDirectDrawSurface7;ancho,alto:integer);
    procedure Registrar(NidPanel,Nleft,Ntop:integer;NCanvas:Tcanvas);
    procedure CrearLabel(var etiqueta:TlabelLogico;Nleft,Ntop,NIdPanel:integer;color:Tcolor);
//    procedure InvalidarTodosLosLabels;
    procedure InvalidarPanel(AidPanel:integer);
    function actualizarLabeles(AidPanel:integer):bytebool;
  end;

//GRID LOGICO
  TEventoDibujarCelda = procedure (ACol, AFil: integer;
    ARect: TRect; Seleccionado:bytebool) of object;
  TEventoDelRaton = procedure (Button: TMouseButton;Acol,Afil:shortint) of object;

  TGridLogico=class(Tobject)
  private
    FDibujarCelda: TEventoDibujarCelda;
    FClikearCelda: TEventoDelRaton;
    PosicionX,PosicionY:smallint;
    Ffilas,Fcolumnas,
    Ffilasv,Fcolumnasv,
    FFila,Fcolumna,
    FPrimeraFila,FPrimeraColumna,
    anchoCelda,anchoTotal:shortint;
    procedure SetFila(fila:shortint);
    procedure SetColumna(columna:shortint);
    procedure DibujarCelda(ACol, AFil: integer; ARect: TRect;Seleccionado:bytebool);
    function GetIndice:integer;
  public
    property Indice:integer read GetIndice;
    property NroFil:shortint read Ffilas;
    property NroCol:shortint read Fcolumnas;
    property NroFilVisibles:shortint read Ffilasv;
    property NroColVisibles:shortint read Fcolumnasv;
    property col:shortint read Fcolumna write SetColumna;
    property fil:shortint read Ffila write SetFila;
    property PrimeraFil:shortint read FPrimeraFila;
    property PrimeraCol:shortint read FPrimeraColumna;
    property FuncionDibujarCelda:TEventoDibujarCelda read FDibujarCelda write FDibujarCelda;
    property FuncionClikearCelda:TEventoDelRaton read FClikearCelda write FClikearCelda;

    constructor create;
    procedure PintarCeldas;
    procedure personalizar(NroColumnas,nroFilas,
      nroColumnasVisibles,nroFilasVisibles:byte);
    procedure setPosicion(x,y:smallint);
    function ClikearCelda(Button: TMouseButton;X,Y:integer):bytebool;
    function LimitesCelda(columna,fila:integer):Trect;
    function seleccionado(columna,fila:shortint):bytebool;
  end;

//Barra de progreso
  TBarraProgreso=class(TObject)
  //0..100
  private
    canvas:Tcanvas;
    Posicion,
    top,left,
    height,width:smallint;
  public
    constructor create(canvas:Tcanvas;left,top,width,height:smallint);
    procedure StepBy(n:integer);
    procedure Paint;
  end;

  //SplashScreen
  TFEsperar = class(TForm)
  private
    { Private declarations }
    Logo:Tbitmap;
  protected
    procedure paint; override;
  public
    LB_progreso: TLabel;
    PBar:TbarraProgreso;
    destructor destroy; override;
    constructor create(AOwner:Tcomponent); override;
  end;

//------------------------------------------------------------------------------
// Menu de opciones:
  TElementoMenuAbstracto=record
    etiqueta:string[18];
    marcado:boolean;
  end;
  TMenuAbstracto=record
    elemento:array[0..12] of TElementoMenuAbstracto;
    nroElementos:integer;
    limites:Trect;
  end;
  procedure InicializarMenuOpciones;
  procedure PintarMenuOpciones;
  procedure EjecutarComandosMenuOpciones(x,y:integer);
//------------------------------------------------------------------------------
// Menu de construccion:
  procedure PintarMenuConfirmacion;
  procedure PintarMenuInformacion;
  procedure PintarMenuConstruccion;
  procedure PintarMenuComercio;
  procedure PintarMenuObjetos(Tipo:TVentanaActivada);
  function PrepararMenuConstruccion(jug:Tjugador;idHerramienta:byte):boolean;
  function PrepararMenuComercio(RefComerciante:TmonstruoS):boolean;
  procedure EjecutarComandosMenuConstruccion(x,y:integer);
  procedure EjecutarComandosMenuObjetos(x,y:integer;Tipo:TVentanaActivada);
  procedure EjecutarComandosMenuConfirmacion(x,y:integer);
  procedure MovimientoSobreMenuConstruccion(x,y:integer);
  procedure MovimientoSobreMenuObjetos(x,y:integer;Tipo:TVentanaActivada);
  procedure RealizarPeticionParaComprar(la_cantidad:byte);
  function VerificarArchivosYConfiguraciones:bytebool;
  procedure MostrarMensajeErrorEnSocket(Error:integer;elSocket:pointer;const origen:string);
  function repeticionEnContrasenna(const cad:string):boolean;
  function loguinParecidoAContrasenna(const cad1,cad2:string):boolean;
  function ColorParaLabel(const nivel,maximo:integer):Tcolor;

  function GuardarAvatarActual:boolean;
  function EscribirFichaPersonaje:bytebool;


var
  DatosMenuOpciones:TMenuAbstracto;
  MensajeVentanaInformacion:string;
  TimerMenuInformacion:word;//0=desactivado.
  NumeroComercioActivo,IndiceDeArtefactoSeleccionadoEnElBaul,IndiceDeArtefactoSeleccionadoEnElBolso:byte;

implementation
uses MundoEspejo,Sonidos,Juego,Umensajes,SysUtils,Globales,Graficos,Objetos,Tablero,ShellAPI,URapidas;

const
  AreaFijaTablaCons3Iconos:Trect=(left:0;top:48;right:ANCHO_TABLA_DER;bottom:108);
  AreaFijaTablaConsLista:Trect=(left:0;top:132;right:ANCHO_TABLA_DER;bottom:alto_dd);
  AreaBotonFabricar:Trect=(left:0;top:0;right:ANCHO_TABLA_DER;bottom:48);
  AreaBotonFabricarPrendido:Trect=(left:0;top:352;right:ANCHO_TABLA_DER;bottom:400);
  AreaTablaConsPaginas:Trect=(left:0;top:108;right:ANCHO_TABLA_DER;bottom:132);
  AreaB11Construccion:Trect=(left:0;top:108;right:ANCHO_TABLA_DER shr 1;bottom:132);
  AreaB12Construccion:Trect=(left:ANCHO_TABLA_DER shr 1;top:108;right:ANCHO_TABLA_DER;bottom:132);
  AreaB21Construccion:Trect=(left:0;top:400;right:ANCHO_TABLA_DER shr 1;bottom:424);
  AreaB22Construccion:Trect=(left:ANCHO_TABLA_DER shr 1;top:400;right:ANCHO_TABLA_DER;bottom:424);

  AreaTablaIconos:Trect=(left:0;top:0;right:ANCHO_TABLA_DER;bottom:alto_dd);
  AreaOrBotonGuardarEnBaul:Trect=(left:8;top:354;right:48;bottom:394);
  AreaOrBotonSacarDeBaul:Trect=(left:110;top:358;right:152;bottom:396);
  AreaBotonGuardarEnBaul:Trect=(left:488;top:292;right:528;bottom:332);
  AreaBotonSacarDeBaul:Trect=(left:590;top:296;right:632;bottom:334);

  AreaDeIconoDeBaul:Trect=(left:50;top:352;right:108;bottom:396);
  AreaDeIconoDeCadaver:Trect=(left:48;top:396;right:96;bottom:440);
  AreaDeIconoDeBolsa:Trect=(left:0;top:396;right:48;bottom:440);

  AreaAceptarOferta:Trect=(left:240;top:30;right:300;bottom:58);
  AreaRechazarOferta:Trect=(left:338;top:30;right:404;bottom:58);

type
  TListaArtefactosConstruibles=array[0..255] of byte;
  TArtefactosConstruibles=record
    lista:TListaArtefactosConstruibles;
    NroElementos:byte;
    pagina:byte;
    nroPaginas:byte;
    IndiceSel:byte;
  end;
  TArtefactosComerciables=record
    Comerciante:TmonstruoS;
    lista:TInventarioArtefactos;
    NroElementos:byte;
    IndiceSel:byte;
  end;
var
  ArtefactosConstruibles:TArtefactosConstruibles;
  ArtefactosComerciables:TArtefactosComerciables;
  IdentificadorDeHerramientaDeConstruccion:byte;

function loguinParecidoAContrasenna(const cad1,cad2:string):boolean;
begin
  if abs(length(cad1)-length(cad2))<4 then
    result:=(Pos(cad1,cad2)>0) or (Pos(cad2,cad1)>0)
  else
    result:=false;
end;

function repeticionEnContrasenna(const cad:string):boolean;
var
   tamanno,i,j,repetidos:integer;
begin
  tamanno:=length(cad);
  i:=1;
  result:=false;
  while(i<=tamanno) do
  begin
    j:=i+1;
    repetidos:=0;
    while (j<=tamanno) do
    begin
      if (cad[i]=cad[j]) then
      begin
        inc(repetidos);
        if (tamanno-repetidos)<3 then
        begin
          result:=true;
          exit;
        end;
      end;
      inc(j);
    end;
    inc(i);
  end;
end;

procedure IntrprtrLnaArchvoCnfgrcn(const cadena:string);
var id,valor,texto:string;
    PosicionChar:integer;
begin
  if length(cadena)<=0 then exit;
  if cadena[1]<'A' then exit;
  PosicionChar:=pos('=',cadena);
  id:=trimright(copy(UpperCase(cadena),1,PosicionChar-1));
  texto:=trimleft(copy(cadena,PosicionChar+1,length(cadena)));
  valor:=UpperCase(texto);
  if id='SERVIDOR' then
  begin
    if length(valor)>0 then G_NombreDelServidor:=texto;
  end
  else if id='WEB' then
  begin
    if length(valor)>0 then G_ServidorWEB:=valor;
  end
  else if id='MOSTRAR FPS' then
  begin
    G_IniciarConMusica:=false;
    G_MostrarFPS:=valor='SI'
  end
  else if id='ESTÉREO INVERSO' then
  begin
    G_StereoInverso:=valor='SI'
  end
  else if id='PUERTO' then
  begin
    val(valor,G_PuertoComunicacion,PosicionChar);
    if (PosicionChar<>0) or (G_PuertoComunicacion<MIN_PUERTO_COMUNICACION) or (G_PuertoComunicacion>MAX_PUERTO_COMUNICACION) then
      G_PuertoComunicacion:=PUERTO_COMUNICACION;
  end
  else if id='MUSICA' then
  begin
    G_ExtensionMusica1:=copy(valor,1,3);
    if G_ExtensionMusica1='MID' then
    begin
      G_ExtensionMusica2:='MP3';
    end
    else if (copy(valor,1,2)='MP') then
    begin
      G_ExtensionMusica2:='MID';
    end
    else
    begin
      G_ExtensionMusica1:='MID';
      G_IniciarConMusica:=false;
    end;
  end
  else if id='MOVER CON IZQUIERDO' then
  begin
    G_MoverConClickIzquierdo:=valor='SI';
  end
  else if id='MODO DE 15BITS' then
  begin
    G_PantallaEn15Bits:=valor='SI';
  end
  else if id='MODO VENTANA' then
  begin
    G_ModoVentana:=valor='SI';
  end
  else if id='APLICAR DESFASE' then
  begin
    G_Aplicar_Desfase:=valor='SI';
  end;
end;

function VerificarArchivosYConfiguraciones:bytebool;
var f:textfile;
    s:string;

  procedure IniciarModoOffLine;
  var
    zFileName, zParams: array[0..15] of Char;
    zDir: array[0..79] of Char;
    Controlador:integer;
  begin
    //Llamar al servidor con cadenas Z
    zFileName:='arkhos.exe'+#0;
    zParams:='ACTIVAR'+#0;
    Controlador:=integer(nil);
    if ShellExecute(Controlador,nil,@zFileName,@zParams,StrPCopy(zDir,
        copy(Ruta_Aplicacion,1,length(Ruta_Aplicacion)-4)+'Servidor\'),SW_SHOW)<=32 then
      showmessageZ('No fue posible activar el Servidor');
    //Configuración de IP
    G_NombreDelServidor:=IP_SERVIDOR_LOCAL;
  end;
begin
  Ruta_Aplicacion:=ExtractFilePath(ParamStr(0));
  //Inicializar Variables configuración:
  Sonidos.DirectSound_Funcionando:=false;
  Sonidos.Emitir_Sonidos:=false;
  G_PantallaEn15Bits:=false;
  G_NombreDelServidor:=IP_SERVIDOR_LOCAL;
  G_ServidorWEB:='';
  G_GameHosting:='Versión '+getVersion;
  G_PuertoComunicacion:=PUERTO_COMUNICACION;
  G_MostrarFPS:=false;
  G_StereoInverso:=false;
  G_IniciarConMusica:=true;
  G_ExtensionMusica1:='MID';
  G_ExtensionMusica2:='MP3';
  G_MoverConClickIzquierdo:=false;
  G_Aplicar_Desfase:=false;
  if EjecutableCorrompido(ParamStr(0)) then
  begin
    showmessageZ(M_EjecutableDannado);
    result:=false;exit;
  end;
  {$I-}
  assignFile(f,Ruta_Aplicacion+'opciones.txt');
  filemode:=0;
  reset(f);
  while not eof(f) do
  begin
    readln(f,s);
    intrprtrLnaArchvoCnfgrcn(trim(s));
  end;
  closeFile(f);
  {$I+}
  Application.title:='LAA - '+getVersion;
  result:=(IOResult=0) and
    FileExists(Ruta_Aplicacion+CrptGDD+'logo'+ExtArc);//evita en buena manera que ejecuten el cliente sin sus archivos
  if not result then
  begin
    showmessageZ(M_FaltanArchivosDelJuego);
    exit;
  end;
  if paramcount>=1 then
    if paramStr(1)='LOCAL' then
      IniciarModoOffLine;
end;

procedure TLabelLogico.setCaption(Ncaption:Tetiqueta);
begin
  if (fcaption<>Ncaption) then
  begin
    fcaption:=Ncaption;
    valido:=false;
    fDibujadorLabel.invalidar;
  end;
end;

constructor TLabelLogico.create(Nleft,Ntop,NIdPanel:integer;DibujadorLabel:TDibujadorLabel);
begin
  inherited create;
  left:=Nleft;
  top:=Ntop;
  IdPanel:=NIdPanel;
  valido:=false;
  ancho_a:=0;
  alto_a:=0;
  fDibujadorLabel:=DibujadorLabel;
  fcaption:='';
  alineacion:=AxIzquierda;
end;

// DIBUJADOR DE LABELES
//**********************************************************

constructor TDibujadorLabel.create(superficie:IDirectDrawSurface7;ancho,alto:integer);
var i:integer;
begin
  inherited create;
  valido:=false;
  fsuperficie:=superficie;
  fancho:=ancho;
  falto:=alto;
  for i:=0 to MAX_LABELESxDIBUJADOR do
    fLabel[i]:=nil;
end;

destructor TDibujadorLabel.destroy;
var i:integer;
begin
  fsuperficie:=nil;
  for i:=MAX_LABELESxDIBUJADOR downto 0 do
    fLabel[i].free;
  inherited destroy;
end;

procedure TDibujadorLabel.Registrar(NidPanel,Nleft,Ntop:integer;NCanvas:Tcanvas);
begin
  with fPanel[NidPanel] do
  begin
    canvas:=Ncanvas;
    left:=Nleft;
    top:=Ntop;
  end;
end;

procedure TDibujadorLabel.CrearLabel(var etiqueta:TlabelLogico;Nleft,Ntop,NIdPanel:integer;color:Tcolor);
var i:integer;
begin
  for i:=0 to MAX_LABELESxDIBUJADOR do
    if fLabel[i]=nil then
    begin
      fLabel[i]:=TLabelLogico.create(Nleft,Ntop,NIdPanel,self);
      fLabel[i].color:=color;
      etiqueta:=fLabel[i];
      exit;
    end;
  etiqueta:=fLabel[0];
  showmessagez('MAX_LABELESxDIBUJADOR++ !');
end;
{
procedure TDibujadorLabel.InvalidarTodosLosLabels;
var i:integer;
begin
  for i:=0 to MAX_LABELESxDIBUJADOR do
    if fLabel[i]<>nil then
      with fLabel[i] do
        valido:=false;
  valido:=false;
end;
}
procedure TDibujadorLabel.InvalidarPanel(AidPanel:integer);
var i:integer;
begin
  for i:=0 to MAX_LABELESxDIBUJADOR do
    if fLabel[i]<>nil then
      with fLabel[i] do
        if idPanel=AidPanel then
          valido:=false;
  valido:=false;
end;

function TDibujadorLabel.actualizarLabeles(AidPanel:integer):bytebool;
var correctorAlineacion,
    i,handleBg:integer;
    resu,limites:Trect;
    HDCSuperficie:HDC;
  function actualizacionNecesaria:bytebool;
  var i:integer;
  begin
    result:=true;
    for i:=0 to MAX_LABELESxDIBUJADOR do
    if fLabel[i]<>nil then
      with fLabel[i] do
      if idPanel=AidPanel then
       if not valido then exit;
    result:=false;
  end;
begin
 result:=false;
 if not valido then
 begin
  valido:=true;
  if actualizacionNecesaria then
  begin
   TextoDDraw.SuperficieDestino:=fsuperficie;
   limites:=rect(0,0,fancho,falto);
   TextoDDraw.LimitesTexto:=@limites;
   HandleBg:=fPanel[AidPanel].canvas.handle;
   result:=true;
   for i:=0 to MAX_LABELESxDIBUJADOR do
    if fLabel[i]<>nil then
     with fLabel[i] do
       if idPanel=AidPanel then
       begin
         if not valido then
         begin
           TextoDDraw.AlineacionX:=alineacion;
           if alineacion=axCentro then
             correctorAlineacion:=-ancho_a div 2
           else
             correctorAlineacion:=0;
           if fsuperficie.GetDC(HDCSuperficie)=DD_OK then
           begin
             bitblt(HDCSuperficie,left+correctorAlineacion,top,ancho_a,alto_a,HandleBg,
               left+correctorAlineacion+fPanel[AidPanel].left,top+fPanel[AidPanel].top,SRCCOPY);
             fsuperficie.ReleaseDC(HDCSuperficie);
           end;
           TextoDDraw.color:=color;
           resu:=TextoDDraw.TextOut(left,top,caption);
           alto_a:=resu.Bottom-resu.Top;
           ancho_a:=resu.Right-resu.Left;
           valido:=true;
         end;
       end
       else
         valido:=false;
   TextoDDraw.SuperficieDestino:=SuperficieRender;
   TextoDDraw.LimitesTexto:=@Rectangulo_Origen;
  end;
 end;
end;

function TDibujadorLabel.NecesitaDibujarse:bytebool;
begin
  result:=not Valido;
end;

procedure TDibujadorLabel.invalidar;
begin
  valido:=false;
end;

// GRID LOGICO
//***************************************************

procedure TGridLogico.personalizar(NroColumnas,nroFilas,
      nroColumnasVisibles,nroFilasVisibles:byte);
begin
  Ffilas:=nroFilas;
  Fcolumnas:=nroColumnas;
  if nroFilasVisibles>nroFilas then nroFilasVisibles:=nroFilas;
  Ffilasv:=nroFilasVisibles;
  if nroColumnasVisibles>nroColumnas then nroColumnasVisibles:=nroColumnas;
  Fcolumnasv:=nroColumnasVisibles;
end;

procedure TGridLogico.SetPosicion(x,y:smallint);
begin
  PosicionX:=x;
  PosicionY:=y;
end;

function TGridLogico.Seleccionado(columna,fila:shortint):bytebool;
begin
  result:=(fila=Ffila) and (columna=Fcolumna)
end;

constructor TGridLogico.Create;
begin
  inherited create;
  FDibujarCelda:=nil;
  Ffilas:=8;
  Fcolumnas:=3;
  Ffilasv:=3;
  Fcolumnasv:=3;
  FFila:=0;
  Fcolumna:=0;
  FPrimeraFila:=FFila;
  FPrimeraColumna:=Fcolumna;
  anchoCelda:=40;
  anchoTotal:=42;
  PosicionX:=0;
  PosicionY:=0;
end;

procedure TGridLogico.DibujarCelda(ACol, AFil: integer; ARect: TRect;Seleccionado:bytebool);
begin
  if Assigned(FDibujarCelda) then FDibujarCelda(ACol, AFil, ARect, Seleccionado);
end;

function TGridLogico.ClikearCelda(Button: TMouseButton;X,Y:integer):bytebool;
var antCol,antFil,fila,columna:shortint;
begin
  antCol:=Fcolumna;
  antFil:=Ffila;
  columna:=X div anchoTotal;
  fila:=Y div anchoTotal;
  if Assigned(FClikearCelda) then FClikearCelda(Button,columna,fila);
  SetColumna(columna+FprimeraColumna);
  SetFila(fila+FprimeraFila);
  if (Fcolumna<>antCol) or (FFila<>antFil) then
  begin
    DibujarCelda(Fcolumna,Ffila,LimitesCelda(Fcolumna,FFila),true);
    DibujarCelda(antcol,antfil,LimitesCelda(antcol,antfil),false);
    result:=true
  end
  else
    result:=false;
end;

function TGridLogico.LimitesCelda(columna,fila:integer):Trect;
begin
  fila:=fila-FprimeraFila;
  columna:=columna-FprimeraColumna;
  if ((columna>=0) and (columna<FcolumnasV) and (fila>=0) and (fila<FfilasV)) then
  begin
    fila:=fila*anchoTotal+posiciony;
    columna:=columna*anchoTotal+posicionx;
    Result:=rect(columna,fila,columna+AnchoCelda,fila+AnchoCelda);
  end
  else
    Result:=rect(0,0,0,0);
end;

procedure TGridLogico.PintarCeldas;
var i,j:integer;
begin
  for j:=FPrimeraFila to FPrimeraFila+FFilasV-1 do
    for i:=FPrimeraColumna to FPrimeraColumna+FColumnasV-1 do
      DibujarCelda(i,j,LimitesCelda(i,j),seleccionado(i,j));
end;

function TGridLogico.GetIndice:integer;
begin
  result:=FColumna+Ffila*FColumnas;
end;

procedure TGridLogico.SetFila(Fila:shortint);
var Temporal:shortint;
begin
  if (Fila>=0) and (Fila<Ffilas) then
  begin
    FFila:=Fila;
    Temporal:=FPrimeraFila;
    if (FFila<FPrimeraFila) then
      Temporal:=FFila
    else
      if (FFila>=FPrimeraFila+FFilasV) then
        Temporal:=FFila-FFilasV+1;
    if Temporal<>FPrimeraFila then
    begin
      FPrimeraFila:=Temporal;
      PintarCeldas;
    end;
  end;
end;

procedure TGridLogico.SetColumna(Columna:shortint);
var Temporal:shortint;
begin
  if (Columna>=0) and (Columna<FColumnas) then
  begin
    FColumna:=Columna;
    Temporal:=FPrimeraColumna;
    if (FColumna<FPrimeraColumna) then
      Temporal:=FColumna
    else
      if (FColumna>=FPrimeraColumna+FColumnasV) then
        Temporal:=FColumna-FColumnasV+1;
    if Temporal<>FPrimeraColumna then
    begin
      FPrimeraColumna:=Temporal;
      PintarCeldas;
    end;
  end;
end;

//TBARRA DE PROGRESO
//------------------

constructor TBarraProgreso.create(canvas:Tcanvas;left,top,width,height:smallint);
begin
  self.canvas:=canvas;
  self.left:=left;
  self.top:=top;
  self.width:=width;
  self.height:=height;
  posicion:=0;
end;

procedure TBarraProgreso.StepBy(n:integer);
begin
  n:=posicion+n;
  if n>100 then posicion:=100 else posicion:=n;
  paint;
end;

procedure TBarraProgreso.Paint;
var i:integer;
begin
  with canvas do
    for i:=0 to height do
      if i and $1=0 then
      begin
        pen.color:=(i*63 div height)*$0304;
        moveTo(left,top+i);
        LineTo(left+width*posicion div 100,top+i);
      end;
end;

// TFEsperar
//-----------------------------------------------------------------------------
constructor TFEsperar.create(AOwner:Tcomponent);
begin
  inherited create(AOwner);
  Scaled:=False;
  BorderStyle:=bsNone;
  Ctl3D:=False;
  Color:=clBlack;
  Position:=poScreenCenter;
  Left:=0;
  Top:=0;
  Width:=640;
  Height:=480;
  ParentFont:=True;
  PixelsPerInch:=96;
  controlStyle:=controlStyle+[csOpaque];
  LB_progreso:=TLabel.Create(self);
  with LB_progreso do
  begin
    left:=32;
    top:=328;
    font.PixelsPerInch:=96;// :(
    font.Name:=NOMBRE_FONT;
    font.Size:=16;
    font.Style:=[fsBold,fsItalic];
    font.color:=clBlanco;
    caption:='Inicializando Direct X...';
    Transparent := True
  end;
  LB_progreso.parent:=self;
  PBar:=TBarraProgreso.create(self.canvas,0,356,640,24);
  Logo:=CrearDeGdd(Ruta_Aplicacion+CrptGDD+'logo'+ExtArc);
  brush.Style:=bsClear;
end;

destructor TFEsperar.destroy;
begin
  hide;
  Logo.free;
  Pbar.free;
  inherited destroy;
end;

procedure TFEsperar.Paint;
begin
  self.canvas.FillRect(rect(0,0,ClientWidth,100));
  self.Canvas.draw(0,100,Logo);
  self.canvas.FillRect(rect(0,380,ClientWidth,480));
  PBar.paint;
end;
//Interfaces varias:
//==================
//                MENU DE OPCIONES
//------------------------------------------------------------------------------
procedure InicializarMenuOpciones;
begin
with DatosMenuOpciones do
begin
  with elemento[0] do
  begin
    etiqueta:='Nombres F3';
    marcado:=Mostrar_Nombres_Sprites;
  end;
  with elemento[1] do
  begin
    etiqueta:='Rostros F4';
    marcado:=Mostrar_rostros;
  end;
  with elemento[2] do
  begin
    etiqueta:='Transparencias F5';
    marcado:=Graficos_Transparentes;
  end;
  with elemento[3] do
  begin
    etiqueta:='Zoom F6';
    marcado:=Zoom_Pantalla;
  end;
  with elemento[4] do
  begin
    etiqueta:='Antialisado F7';
    marcado:=Aplicar_Antialisado;
  end;
  with elemento[5] do
  begin
    etiqueta:='--- '+#155+' ---';//Desfase
    marcado:=G_Aplicar_Desfase;
  end;
  with elemento[6] do
  begin
    etiqueta:='Sonido F9';
    marcado:=DirectSound_Funcionando;
  end;
  with elemento[7] do
  begin
    etiqueta:='Música F10';
    marcado:=G_IniciarConMusica;
  end;
  with elemento[8] do
  begin
    etiqueta:='Ver mensajes F11';
    marcado:=Texto_Modalidad_Chat;
  end;
  with elemento[9] do
  begin
    etiqueta:='Teclas rápidas F12';
    marcado:=false;
  end;
  with elemento[10] do
  begin
    etiqueta:='--- '+#155+' ---';
    marcado:=false;
  end;
  with elemento[11] do
  begin
    etiqueta:='Salir del Juego';
    marcado:=false;
  end;
  nroElementos:=12;
  limites:=rect(520,0,640,10+nroElementos*18);
end;
end;

procedure PintarMenuConfirmacion;
var AnchoMedio,posicion:integer;
    cad1,cad2:string;
begin
  with TextoDDraw do
  begin
    posicion:=pos(#13,MensajeVentanaInformacion);
    if posicion>0 then
    begin
      cad1:=copy(MensajeVentanaInformacion,1,posicion-1);
      cad2:=copy(MensajeVentanaInformacion,posicion+1,length(MensajeVentanaInformacion))
    end
    else
    begin
      cad1:=MensajeVentanaInformacion;
      cad2:='';
    end;
    AnchoMedio:=maximo2(TextWidth(cad1) shr 1,TextWidth(cad2) shr 1);
    bltFondo(rect(305-AnchoMedio,0,335+AnchoMedio,60));
    alineacionX:=axcentro;
    color:=clBronce;
    if cad2<>'' then
    begin
      TextOut(mitad_ancho_dd,4,cad1);
      TextOut(mitad_ancho_dd,20,cad2)
    end
    else
      TextOut(mitad_ancho_dd,12,cad1);
    if PuntoDentroRect(PosicionRaton_X,PosicionRaton_Y,AreaAceptarOferta) then
      color:=clBlanco
    else
      color:=clBronce;
    TextOut(270,38,#183+'ACEPTAR'+#183);
    if PuntoDentroRect(PosicionRaton_X,PosicionRaton_Y,AreaRechazarOferta) then
      color:=clBlanco
    else
      color:=clBronce;
    TextOut(370,38,#183+'RECHAZAR'+#183);
  end;
end;

procedure PintarMenuInformacion;
var AnchoMedio:integer;
begin
  with TextoDDraw do
  begin
    if TimerMenuInformacion>=1 then
    begin
      dec(TimerMenuInformacion);
      if TimerMenuInformacion=0 then JForm.VentanaActivada:=vaNinguna;
    end;
    AnchoMedio:=TextWidth(MensajeVentanaInformacion) shr 1;
    bltFondo(rect(310-AnchoMedio,0,330+AnchoMedio,40));
    alineacionX:=axcentro;
    color:=clBronce;
    TextOut(mitad_ancho_dd,12,MensajeVentanaInformacion);
  end;
end;

procedure RealizarPeticionParaComprar(la_cantidad:byte);
var maxima_cantidad:byte;
    mensaje:String;
begin
  with ArtefactosComerciables do
    if abs(Comerciante.coordx-JugadorCl.coordx)+abs(Comerciante.coordy-JugadorCl.coordy)<=MAXIMA_DISTANCIA_COMERCIO then
    begin
      maxima_cantidad:=MaximaCantidadPorCasilla(lista[IndiceSel]);
      if la_cantidad<=maxima_cantidad then
        if JugadorCl.TieneLugarVacio(lista[IndiceSel],la_cantidad) then
          Cliente.SendTextNow('C'+b2aStr(Comerciante.Codigo)+char(la_cantidad)+char(IndiceSel))
        else
          Jform.MensajeAyuda:=JugadorCl.MensajeResultado(i_NecesitasCasillaLibreEnBolso,0,0)
      else
      begin
        if maxima_cantidad=1 then
          mensaje:='Ese tipo de objetos los vendo uno por uno'
        else
          mensaje:='Sólo vendo hasta '+intastr(maxima_cantidad)+' unidades a la vez';
        ControlMensajes.setMensaje(Comerciante,mensaje);
      end;
    end
    else
      ControlMensajes.setMensaje(Comerciante,JugadorCl.MensajeResultado(i_EstasMuyLejos,0,0))
end;

procedure EjecutarComandosMenuConfirmacion(x,y:integer);
begin
  //Aceptar o Rechazar ofertas.
  if PuntoDentroRect(x,y,AreaAceptarOferta) then
    cliente.SendTextNow(')')
  else
    if PuntoDentroRect(x,y,AreaRechazarOferta) then
      ControlMensajes.setMensaje(ArtefactosComerciables.Comerciante,'...')
    else
      exit;
  with jform do
    if VolverAMostrarVentanaComercio then
      VentanaActivada:=vaMenuComercio
    else
      VentanaActivada:=vaNinguna;
end;

procedure PintarMenuOpciones;
var i,posx,posy:integer;
begin
with DatosMenuOpciones do
begin
  bltFondo(limites);
  with TextoDDraw do
  begin
    alineacionX:=axcentro;
    posx:=(limites.Right+limites.Left) div 2;
    posy:=limites.top+6;
    for i:=0 to nroElementos-1 do
    with elemento[i] do
    begin
      if marcado then
        color:=clBlanco
      else
        color:=clBronce;
      TextOut(posx,posy+i*18,etiqueta);
    end;
  end;
end;
end;

procedure EjecutarComandosMenuOpciones(x,y:integer);
begin
with DatosMenuOpciones do
begin
  if (x>Limites.Left) and (x<Limites.Right) and
     (y>Limites.Top) and (y<Limites.Bottom) then
    case (y-6-limites.top) div 18 of
    0:begin
      Mostrar_Nombres_Sprites:=not Mostrar_Nombres_Sprites;
      elemento[0].marcado:=Mostrar_Nombres_Sprites;
    end;
    1:begin
      Mostrar_rostros:=not Mostrar_rostros;
      elemento[1].marcado:=Mostrar_rostros;
    end;
    2:begin
      Graficos_Transparentes:=not Graficos_Transparentes;
      elemento[2].marcado:=Graficos_Transparentes;
    end;
    3:begin
      Zoom_Pantalla:=not Zoom_Pantalla;
      elemento[3].marcado:=Zoom_Pantalla;
      Jform.VentanaActivada:=Jform.VentanaActivada;//Actualiza el area dibujable.
    end;
    4:begin
      Aplicar_Antialisado:=not Aplicar_Antialisado;
      elemento[4].marcado:=Aplicar_Antialisado;
    end;
{    5:begin
      G_Aplicar_Desfase:=not G_Aplicar_Desfase;
      elemento[5].marcado:=G_Aplicar_Desfase;
    end;}
    6:begin
      if DirectSound_Funcionando then
        sonidos.Emitir_Sonidos:=not sonidos.Emitir_Sonidos
      else
        sonidos.Emitir_Sonidos:=FALSE;
      elemento[6].marcado:=sonidos.Emitir_Sonidos;
    end;
    7:begin
      if Jform.MusicaActivada then Jform.DesactivarMusica else Jform.ActivarMusica;
      elemento[7].marcado:=Jform.MusicaActivada;
    end;
    8:begin
      Texto_Modalidad_Chat:=not Texto_Modalidad_Chat;
      elemento[8].marcado:=Texto_Modalidad_Chat;
    end;
    9:with TFRapidas.create(Application) do
    begin
      showmodal;
      free;
    end;
    11:Jform.FinalizarJuego;
    end
  else
    Jform.VentanaActivada:=vaNinguna;
end;
end;

//---------------------------------- MENU CONSTRUCCION
function PrepararMenuConstruccion(jug:Tjugador;idHerramienta:byte):boolean;
var i,conta:integer;
begin
  conta:=0;
  for i:=0 to 255 do
    if jug.PuedeConstruir(idHerramienta,i) then
    begin
      ArtefactosConstruibles.lista[conta]:=i;
      inc(conta);
    end;
  with ArtefactosConstruibles do
  begin
    NroElementos:=conta;
    pagina:=0;
    IndiceSel:=0;
    nroPaginas:=(NroElementos+11) div 12;
    result:=NroElementos>0;
  end;
  IdentificadorDeHerramientaDeConstruccion:=idHerramienta;
end;

function PrepararMenuComercio(RefComerciante:TmonstruoS):boolean;
var i,conta,indiceComercio:integer;
//Ojo Comerciante debe referenciar a un monstruo comerciante válido cercano.
begin
  indiceComercio:=RefComerciante.duenno;
  if indiceComercio>=MapaEspejo.NumeroDeComerciantes then
  begin
    ArtefactosComerciables.Comerciante:=nil;
    result:=false;exit;
  end;
  with ArtefactosComerciables,MapaEspejo.Comerciante[indiceComercio] do
  begin
    conta:=0;
    Comerciante:=RefComerciante;
    for i:=0 to MAX_ARTEFACTOS do
    begin
      if item[i].id<8 then break;
      lista[conta]:=item[i];
      inc(conta);
    end;
    NroElementos:=conta;
    IndiceSel:=0;
    result:=NroElementos>0;
  end;
end;

procedure PintarIconoObjetoSRender(x,y:integer;id,cantidad:byte);
//Usa el color de TextoDDraw actual.
begin
  CopiarCanvasASuperficie(SuperficieRender,x,y,40,40,
    Jform.Iconos_Objetos.Canvas.handle,(id and $7)*40,(id shr 3)*40);
  if cantidad>1 then
    with TextoDDraw do
    begin
      AlineacionX:=axIzquierda;
      TextOut(x,y+27,intastr(cantidad));
    end;
end;

procedure PintarObjetoDDraw(x,y:integer;Artefacto:Tartefacto;conCuadro,conBrillo:boolean);
var HDCSuperficie:HDC;
begin
  if SuperficieRender.GetDC(HDCSuperficie)=DD_OK then
  begin
    Jform.PintarObjeto(artefacto,true,x,y,HDCSuperficie,conCuadro,conBrillo);
    SuperficieRender.ReleaseDC(HDCSuperficie);
  end;
end;

procedure PintarMenuConstruccion;
var i,primero,ultimo,x:integer;
    cad:string;
begin
  //Partes que no cambian:
  SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,48,Jform.tablaCC_Botones,@AreaFijaTablaCons3Iconos,DDBLTFAST_NOCOLORKEY);
  SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,132,Jform.tablaCC_Botones,@AreaFijaTablaConsLista,DDBLTFAST_NOCOLORKEY);
  //botonFabricar
  if (PosicionRaton_X>=530) and (PosicionRaton_Y>=10) and (PosicionRaton_Y<=43) then
    SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,0,Jform.tablaCC_Botones,@AreaBotonFabricarPrendido,DDBLTFAST_NOCOLORKEY)
  else
    SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,0,Jform.tablaCC_Botones,@AreaBotonFabricar,DDBLTFAST_NOCOLORKEY);
  if (PosicionRaton_Y>=108) and (PosicionRaton_Y<=132) then
    if (PosicionRaton_X>=486) and (PosicionRaton_X<=538) then
    begin//botones paginas
      SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,108,Jform.tablaCC_Botones,@AreaB21Construccion,DDBLTFAST_NOCOLORKEY);
      SuperficieRender.BltFast(Ancho_DD-(ANCHO_TABLA_DER shr 1),108,Jform.tablaCC_Botones,@AreaB12Construccion,DDBLTFAST_NOCOLORKEY);
    end
    else
      if (PosicionRaton_X>=586) and (PosicionRaton_X<=634) then
      begin//botones paginas
        SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,108,Jform.tablaCC_Botones,@AreaB11Construccion,DDBLTFAST_NOCOLORKEY);
        SuperficieRender.BltFast(Ancho_DD-(ANCHO_TABLA_DER shr 1),108,Jform.tablaCC_Botones,@AreaB22Construccion,DDBLTFAST_NOCOLORKEY);
      end
      else
        SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,108,Jform.tablaCC_Botones,@AreaTablaConsPaginas,DDBLTFAST_NOCOLORKEY)
  else
    SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,108,Jform.tablaCC_Botones,@AreaTablaConsPaginas,DDBLTFAST_NOCOLORKEY);
  with TextoDDraw do
  begin
    x:=Ancho_DD-(ANCHO_TABLA_DER div 2)+1;
    with ArtefactosConstruibles do
    begin
      primero:=pagina*12;
      ultimo:=primero+11;
      if ultimo>=NroElementos then
        ultimo:=NroElementos-1;
      with InfObj[lista[IndiceSel]] do
      begin
        Color:=clFondo;
        PintarIconoObjetoSRender(485,5,lista[IndiceSel],cantidadConstruida);
        AlineacionX:=axCentro;
        for i:=0 to 2 do
          if cantidadX[i]>0 then
          begin
            cad:=intastr(cantidadX[i]);
            if (i=2) and (cantidadConstruida=1) then
              case RecursoX[2] shr 3 of
                23://gemas
                  cad:='25%+';
                2..5,7..12://hechizables
                  cad:='80%+';
              end;
            TextOut(511+50*i,90,cad);
            PintarIconoObjetoSRender(491+50*i,50,RecursoX[i],0);
          end;
      end;
      TextOut(x,112,intastr(pagina+1)+' de '+intastr(nroPaginas));
    end;
    for i:=primero to ultimo do
    begin
      if i=ArtefactosConstruibles.IndiceSel then color:=clWhite else color:=clFondo;
      TextOut(x,141+(i-primero)*16,NomObj[ArtefactosConstruibles.lista[i]]);
    end;
  end;
end;

procedure EjecutarComandosMenuConstruccion(x,y:integer);
var IndArt:byte;
begin
  if (x>=Area_Dibujable_TablaD.right) and (y<=333) then
    with ArtefactosConstruibles do
    begin
      //Comandos Menu Construccion:
      case y of
        10..43:
          if x>=530 then//Enviar mensaje de construir al servidor
          begin
            if JugadorCl.TieneMaterialSuficiente(lista[IndiceSel]) then
            begin
              IndArt:=JugadorCl.BuscarObjetoEnInventario(IdentificadorDeHerramientaDeConstruccion);
              if IndArt<=MAX_ARTEFACTOS then
                Cliente.SendTextNow('F'+char(IndArt)+char(lista[IndiceSel]))
              else
              begin
                Jform.VentanaActivada:=vaNinguna;
                Jform.MensajeAyuda:='Necesitas un'+AgregarSufijoSexuadoA(nombreCortoObjeto(ObjetoArtefacto(IdentificadorDeHerramientaDeConstruccion,0)));
              end;
            end
            else
              JForm.MensajeAyuda:=JugadorCl.MensajeResultado(i_NoTienesTodosLosMateriales,0,0)
          end;
        142..333:
        begin
          y:=((y-142) div 16)+pagina*12;
          if y<NroElementos then IndiceSel:=y;
        end;
        108..132:
          case x of
            486..538:
              if pagina>0 then dec(pagina);
            586..634:
              if pagina<(NroPaginas-1) then inc(pagina);
          end;
      end;
    end
  else
    Jform.VentanaActivada:=vaNinguna;
end;

procedure MostrarMensajeErrorEnSocket(Error:integer;elSocket:pointer;const origen:string);
var mensajeE:string;
begin
  with Jform do
  begin
    if EstadoGeneralDelJuego>=EjProgreso then FinalizarJuego;
    if EstadoGeneralDelJuego=ejConectando then
    begin
      EstadoGeneralDelJuego:=ejMenu;
      ActualizarElementosDePantalla;
    end;
    case Error of
      10053:mensajeE:='Conexión abortada por software';
      10061:mensajeE:='La máquina '+G_NombreDelServidor+' no tiene un servidor activado'+#13+'o no es posible comunicarse mediante el puerto '+inttostr(G_PuertoComunicacion)+'.';
      10049:mensajeE:='La dirección del servidor no es válida:'+#13+G_NombreDelServidor;
      10060:mensajeE:='No existe respuesta a la solicitud de conexión:'+#13+G_NombreDelServidor;
      10065:mensajeE:='No fue posible encontrar una ruta hasta:'+#13+G_NombreDelServidor;
      else
        mensajeE:='Error de conexión: '+intastr(Error)
    end;
    ShowmessageZ(mensajeE);
  end
end;

procedure MovimientoSobreMenuConstruccion(x,y:integer);
var i:integer;
    mensaje:string;
begin
  mensaje:='';
  if PuntoDentroRect(x,y,rect(491,50,631,90)) then
    with ArtefactosConstruibles,InfObj[lista[IndiceSel]] do
    begin
      for i:=0 to 2 do
        if cantidadX[i]>0 then
          if PuntoDentroRect(x,y,
            rect(POSX_IconosMaterialesConstruccion+i*50,POSY_IconosMaterialesConstruccion,
              POSX_IconosMaterialesConstruccion+40+i*50,POSY_IconosMaterialesConstruccion+40)) then
          begin
            mensaje:=NomObj[RecursoX[i]];
            break;
          end;
    end
  else
    if PuntoDentroRect(x,y,rect(484,4,524,44)) then
      with ArtefactosConstruibles do
        mensaje:=NomObj[lista[IndiceSel]];
  Jform.MensajeTip:=mensaje;
end;

function ColorParaLabel(const nivel,maximo:integer):Tcolor;
begin
  if nivel>(maximo shr 1){/2} then
    result:=clFondo
  else
    if nivel<=(maximo shr 2){/4} then result:=clRubi else result:=clOro;
end;

function GuardarAvatarActual:boolean;
var DatosUsuario:TDatosUsuario;
begin
  result:=G_ServidorEnModoDePruebas;
  with DatosUsuario do
  begin
    Password:=EmpaquetarPassword(Jform.ContrasennaUU,Jform.IdentificadorUU);
    ultimoIngreso:=0;
    UltimoIP:=$7F000001;//127.0.0.1
    IdLogin:=Jform.IdentificadorUU;
    EstadoUsuario:=euNormal;
    IdentificadorDeServidor:=0;//Id. no válido, así que al ingresar con este avatar ejecuta el control de consistencia
  end;
  if result then exit;
  result:=EscribirCuenta(DatosUsuario,Ruta_Aplicacion+CARPETA_AVATARES,JugadorCl);
end;

function EscribirFichaPersonaje:bytebool;
var f:textfile;
    i:integer;
begin
  result:=true;
  with Jform do
  try
    assignFile(f,Ruta_Aplicacion+CARPETA_AVATARES+IdentificadorUU+'.txt');
    rewrite(f);
    with DatosPersonajeCl do
    begin
      writeln(f,'AVATAR: '+nombre);
      writeln(f,'');
      writeln(f,'DESCRIPCIÓN:');
      writeln(f,'  '+InfMon[cod_raza and $7].nombre+' '+
        MC_Nombre_Categoria[cod_categoria and $7]+' '+MC_Genero[cod_genero and $1]);
      writeln(f,'PERICIAS:');
      for i:=0 to 15 do
        if longBool(pericias and (1 shl i)) then
          writeln(f,'  '+MC_Pericias[i]);
      writeln(f,'HABILIDADES:');
      writeln(f,'  '+NmbrsHabilidades[0]+' '+intastr(FRZ*5));
      writeln(f,'  '+NmbrsHabilidades[1]+' '+intastr(CON*5));
      writeln(f,'  '+NmbrsHabilidades[2]+' '+intastr(INT*5));
      writeln(f,'  '+NmbrsHabilidades[3]+' '+intastr(SAB*5));
      writeln(f,'  '+NmbrsHabilidades[4]+' '+intastr(DES*5));
    end;
    closefile(f);
  except
    result:=false;
  end
end;

procedure PintarMenuComercio;
var i,x,y,iluminado:integer;
begin
  x:=PosicionRaton_X;
  y:=PosicionRaton_Y;
  SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,0,Jform.TablaCC_Arca,@AreaTablaIconos,DDBLTFAST_NOCOLORKEY);
  if PuntoDentroRect(x,y,AreaBotonGuardarEnBaul) then
    SuperficieRender.BltFast(AreaBotonGuardarEnBaul.left,AreaBotonGuardarEnBaul.top,
      Jform.tablaCC_Arca,@AreaOrBotonGuardarEnBaul,DDBLTFAST_NOCOLORKEY)
  else
    if PuntoDentroRect(x,y,AreaBotonSacarDeBaul) then
      SuperficieRender.BltFast(AreaBotonSacarDeBaul.left,AreaBotonSacarDeBaul.top,
        Jform.tablaCC_Arca,@AreaOrBotonSacarDeBaul,DDBLTFAST_NOCOLORKEY);
  x:=(x-491) div 46;
  y:=(y-9) div 46;
  if (x>=0) and (x<=2) and (y>=0) and (y<=5) then
    iluminado:=x+y*3
  else
    iluminado:=-1;
  with ArtefactosComerciables do
    for i:=0 to NroElementos-1 do
      if lista[i].id>=5 then
      begin
        x:=494+(i mod 3)*46;
        y:=12+(i div 3)*46;
        if (lista[i].id>=ihPergaminoA) and (lista[i].id<=ihPergaminoS) then
        begin
          CopiarCanvasASuperficie(SuperficieRender,x,y,40,40,
            Jform.IconosCjr.Canvas.handle,(lista[i].modificador and $7)*40,((lista[i].modificador shr 3) and $3)*40);
          if i=IndiceSel then
            CopyTransMagenta(SuperficieRender,x,y,40,40,Jform.CuadroResalte,0,0)
        end
        else
          PintarObjetoDDraw(x,y,lista[i],(i=IndiceSel),(i=IndiceSel) or (i=iluminado));
          if (i=IndiceSel) and not JugadorCl.puedeUsar(lista[i].id) then
            CopyTransMagenta(SuperficieRender,x+26,y+2,12,12,Jform.CuadroNoPuedesUsar,0,0)
      end;
end;

procedure PintarMenuObjetos(tipo:TVentanaActivada);
var i,x,y,iluminado,indiceSeleccionado:integer;
    ReferenciaArtefactos:^TInventarioArtefactos;
begin
  x:=PosicionRaton_X;
  y:=PosicionRaton_Y;
  SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER,0,Jform.TablaCC_Arca,@AreaTablaIconos,DDBLTFAST_NOCOLORKEY);
  case tipo of
    vaMenuBaul:begin
      SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER+50,290,Jform.TablaCC_Arca,@AreaDeIconoDeBaul,DDBLTFAST_NOCOLORKEY);//OK
      indiceSeleccionado:=IndiceDeArtefactoSeleccionadoEnElBaul;
      ReferenciaArtefactos:=@JugadorCl.Baul;
    end;
    else
    begin
      if TTipoBolsa(MapaEspejo.getCodBolsaVerificarFronterasXY(JugadorCl.coordx,JugadorCl.coordy))>=tbCadaver then
        SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER+56,290,Jform.TablaCC_Arca,@AreaDeIconoDeCadaver,DDBLTFAST_NOCOLORKEY)
      else
        SuperficieRender.BltFast(Ancho_DD-ANCHO_TABLA_DER+56,290,Jform.TablaCC_Arca,@AreaDeIconoDeBolsa,DDBLTFAST_NOCOLORKEY);//OK
      indiceSeleccionado:=IndiceDeArtefactoSeleccionadoEnElBolso;
      ReferenciaArtefactos:=@MapaEspejo.BolsoDelMapa;
    end;
  end;
  if PuntoDentroRect(x,y,AreaBotonGuardarEnBaul) then
    SuperficieRender.BltFast(AreaBotonGuardarEnBaul.left,AreaBotonGuardarEnBaul.top,
      Jform.tablaCC_Arca,@AreaOrBotonGuardarEnBaul,DDBLTFAST_NOCOLORKEY)
  else
    if PuntoDentroRect(x,y,AreaBotonSacarDeBaul) then
      SuperficieRender.BltFast(AreaBotonSacarDeBaul.left,AreaBotonSacarDeBaul.top,
        Jform.tablaCC_Arca,@AreaOrBotonSacarDeBaul,DDBLTFAST_NOCOLORKEY);
  x:=(x-491) div 46;
  y:=(y-9) div 46;
  if (x>=0) and (x<=2) and (y>=0) and (y<=5) then
    iluminado:=x+y*3
  else
    iluminado:=-1;
  for i:=0 to max_Artefactos do
    with JugadorCl do
      PintarObjetoDDraw(494+(i mod 3)*46,12+(i div 3)*46,(ReferenciaArtefactos^)[i],
        (i=indiceSeleccionado),(i=indiceSeleccionado) or (i=iluminado));
end;

procedure EjecutarComandosMenuObjetos(x,y:integer;Tipo:TVentanaActivada);
begin
with ArtefactosComerciables do
  if PuntoDentroRect(x,y,AreaBotonGuardarEnBaul) then
    case Tipo of
      vaMenuComercio:MapaEspejo.JVender(Jform.DGObjetos.indice,0,JugadorCl.apuntado);
      vaMenuBaul:MapaEspejo.JGuardarEnBaul(Jform.DGObjetos.indice,0);
      vaMenuObjetos:MapaEspejo.JSoltarObjetoElegido(0);
    end
  else
    if PuntoDentroRect(x,y,AreaBotonSacarDeBaul) then
      case Tipo of
        vaMenuComercio:RealizarPeticionParaComprar(numeroElementos(lista[IndiceSel]));
        vaMenuBaul:MapaEspejo.JSacarDeBaul(IndiceDeArtefactoSeleccionadoEnElBaul,0);
        vaMenuObjetos:MapaEspejo.JRecogerObjetoElegido(IndiceDeArtefactoSeleccionadoEnElBolso,0);
      end
    else
      if x>=480 then
      begin
        x:=(x-491) div 46;
        y:=(y-9) div 46;
        if (x>=0) and (x<=2) and (y>=0) and (y<=5) then
          case tipo of
            vaMenuComercio:begin
              y:=x+y*3;
              if y<NroElementos then
                if indiceSel<>y then
                  IndiceSel:=y
                else//mostrar descripcion
                  with Jform do
                    if EsIdDeArmaOArmadura(lista[IndiceSel].id) then
                    begin
                      AgregarMensaje('·Descripción de: '+nombreObjeto(lista[IndiceSel],ciVerRealmente));
                      AgregarMensaje('+  '+DescribirObjeto(lista[IndiceSel],ciVerRealmente));
                    end;
            end;
            vaMenuBaul:IndiceDeArtefactoSeleccionadoEnElBaul:=x+y*3;
            vaMenuObjetos:IndiceDeArtefactoSeleccionadoEnElBolso:=x+y*3;
          end
      end
      else
        JForm.VentanaActivada:=vaNinguna;
end;

procedure MovimientoSobreMenuObjetos(x,y:integer;Tipo:TVentanaActivada);
var ReferenciaArtefactos:^TInventarioArtefactos;
begin
  if PuntoDentroRect(x,y,AreaBotonGuardarEnBaul) then
  begin
    case Tipo of
      vaMenuComercio:Jform.mensajeTip:='Vender objeto del inventario';
      vaMenuBaul:Jform.mensajeTip:='Guardar objeto en el baúl';
      vaMenuObjetos:Jform.mensajeTip:='Soltar objeto del inventario';
    end;
    exit;
  end;
  if PuntoDentroRect(x,y,AreaBotonSacarDeBaul) then
  begin
    case Tipo of
      vaMenuComercio:Jform.mensajeTip:='Comprar objeto del comerciante';
      vaMenuBaul:Jform.mensajeTip:='Sacar objeto del baúl';
      vaMenuObjetos:Jform.mensajeTip:='Recoger objeto';
    end;
    exit;
  end;
  if x>=491 then
  begin
    dec(x,491);
    dec(y,9);
    x:=x div 46;
    y:=y div 46;
    if (x>=0) and (x<=2) and (y>=0) and (y<=5) then
    begin
      x:=x+y*3;
      case Tipo of
        vaMenuComercio:ReferenciaArtefactos:=@ArtefactosComerciables.lista;
        vaMenuBaul:ReferenciaArtefactos:=@JugadorCl.baul;
        else
          ReferenciaArtefactos:=@MapaEspejo.bolsoDelMapa;
      end;
      Jform.MensajeTip:=NombreObjeto((ReferenciaArtefactos^)[x],JugadorCl.CapacidadId);
      exit;
    end
  end;
  Jform.MensajeTip:='';
end;

end.

