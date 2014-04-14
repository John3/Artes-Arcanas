(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit Graficos;

interface
uses windows,classes,Graphics,DirectDraw,Demonios,graficador,Tablero;

const
  INICIO_EDIFICIOS=256; //hmm...
  INICIO_EXTENDIDO=512;

  Mz_nulo=-1;
  MZ_h=0;
  MZ_v=1;
  MZ_h2=2;
  MZ_v2=3;
  MZ_si=4;
  MZ_sd=5;
  MZ_ii=6;
  MZ_id=7;

  MaxGraficosArboles=7;//8 graficos [0..7]

  clCongelado=$00FFA000;
  clEnvenenado=$0000FF40;
  clAturdir=$004000FF;

  MC_espejo:array[0..7] of bytebool=(false,false,false,true,true,false,false,true);
  MC_DirAnimacion:array[0..7] of byte=(0,1,2,2,3,4,3,4);
type
  TDatoAnimacion=record
      inicioy:smallint;//inicio acumulado en y
      alto,ancho,cenx,ceny:byte;
    end;
  TdaJugador=record
      anchoMax:smallint;
      modix,modiy:byte;
      acumy:array[0..MaxCuadrosJ] of smallint;
      ancho:array[0..MaxCuadrosJ] of byte;
      cenx,ceny:array[0..MaxCuadrosJ] of byte
    end;
  TdaMonstruo=record
      anchoMax:smallint;
      modix,modiy:byte;
      acumy:array[0..MaxCuadrosM] of smallint;
      ancho:array[0..MaxCuadrosM] of byte;
      cenx,ceny:array[0..MaxCuadrosM] of byte
    end;

  TAnimacion=Class(Tobject)
  //Para cualquier tipo de sprite
  private
    { Private declarations }
  public
    { Public declarations }
    procedure draw(akmonstruo:TmonstruoS;x,y:integer);virtual;abstract;
  end;

  TAnimacionObjeto=Class(TAnimacion)
  //Para cualquier tipo de animación sin direccion
  private
    { Private declarations }
    Superficie:IDirectDrawSurface7;
    posicionA:TdaMonstruo;
  public
    { Public declarations }
    destructor destroy; override;
    constructor create(const filename:string;Imagen:Tbitmap);
    procedure drawEspecial(x,y:integer;ritmoAnim,flagsFx:byte);
    procedure draw(akmonstruo:TmonstruoS;x,y:integer);override;
  end;

  TAnimacionEfectoSuperficie=Class;

  TAnimacionEfecto=Class(TAnimacion)
  //Para cualquier tipo de animación sin direccion
  //No posee una superficie propia, sino una prestada.
  private
    { Private declarations }
    //Para que sea dibujado por otros.
    Superficie:Tbitmap;
    posicionA:TdaMonstruo;
    colorFx:Tcolor;
    tipo:TFxAlpha;
  public
    { Public declarations }
    property MiSuperficie:Tbitmap read Superficie;
    property MiPosicionA:TdaMonstruo read posicionA;
    constructor create(const ReferenciaAnimacionEfecto:TAnimacionEfectoSuperficie;color:Tcolor;estilo:TFxAlpha);
    procedure draw(akmonstruo:TmonstruoS;x,y:integer);override;
    procedure drawXY(x,y,ritmoAnim:integer);
    procedure drawXYEfecto(x,y,ritmoAnim:integer;color:Tcolor;estilo:TFxAlpha);
    procedure drawFX(x,y,ritmoAnim:integer;color:Tcolor;estilo:TFxAlpha;reflejado:bytebool);
    //Especial para estandartes
    procedure drawXYTablaColor(x,y,ritmoAnim,Color0,Color1:integer;flagsFx:byte);
  end;

  TAnimacionEfectoSuperficie=Class(TAnimacionEfecto)
  //Para cualquier tipo de animación sin direccion
  //Crea y destruye su propia superficie.
  public
    { Public declarations }
    destructor destroy; override;
    function getSuperficie:Tbitmap;
    function getFormatoAnimacion:TdaMonstruo;
    constructor create(const filename:string;imagen:Tbitmap;const color:Tcolor;const estilo:TFxAlpha);
  end;

  TAnimacionDireccionada=Class(TAnimacion)
  private
    { Private declarations }
    Superficie:array[0..MaxDirAni] of IDirectDrawSurface7;
    FlagsEstilosAnimacion:integer;
  public
    { Public declarations }
    destructor destroy; override;
    function obtenerFrame(akmonstruo:TmonstruoS):byte;
    procedure RealizarDibujar(akmonstruo:TmonstruoS;x,y:integer;rorigen:Trect);
  end;

  TAnimacionMonstruo=Class(TAnimacionDireccionada)
  private
    { Private declarations }
    posicionA:array[0..MaxDirAni] of TdaMonstruo;
  public
    { Public declarations }
    constructor create(const filename:string;Imagen:Tbitmap);
    procedure draw(akmonstruo:TmonstruoS;x,y:integer);override;
  end;

  TAnimacionJugador=Class(TAnimacionDireccionada)
  private
    { Private declarations }
    posicionA:array[0..MaxDirAni] of TdaJugador;
  public
    { Public declarations }
    constructor create(const filename:string;Imagen:Tbitmap);
    procedure draw(akmonstruo:TmonstruoS;x,y:integer);override;
  end;

  TColeccionAnimaciones=Class(TObject)
  public
    animacion:array[0..255] of Tanimacion;
    destructor destroy; override;
    constructor create;
  end;

  TElementoGrafico=Class(TObject)
  //grafico Arboles, casas, fijos,etc
  private
    { Private declarations }
    Superficie:IDirectDrawSurface7;
    PosicionX,PosicionY:smallint;
    PosicionX_R:smallint;
    ancho,alto:smallint;
    flagsPorGrafico:byte;
  public
    { Public declarations }
    destructor destroy; override;
    //El procemiento se encarga de centrarlo y colocarlo donde debe ser.
    procedure Draw(x,y:integer;flagsPorSprite:byte);
//    procedure Drawsombra(x,y:integer);
    Constructor create(imagen:Tbitmap;posx,posy,posx_r:integer;losFlagsPorGrafico:byte);
  end;

  TcoleccionGraficosTablero=class(Tobject)
  public
    SuperficieTerreno:IDirectDrawSurface7;
    grafico:array[0..MAX_OBJETOS_GRAFICOS] of TElementoGrafico;
    destructor destroy; override;
    Constructor create;
  end;

  function PuntoDentroRect(x,y:integer;const rectangulo:Trect):boolean;
  procedure FijarRutaRecuperacionArchivos(const ruta:string);

var
  //Objetos graficos y sprites
  Animas:TcoleccionAnimaciones;
  GrafTablero:TcoleccionGraficosTablero;
  Msk_AniSincro,
  Desplazador_AniSincro:integer;
  Aplicar_Antialisado:bytebool;
  PosicionRaton_X,PosicionRaton_Y:smallint;

implementation
uses objetos,sysutils;

const EXT_CRG='.cr9';
var Ruta_Aplicacion:string;

procedure FijarRutaRecuperacionArchivos(const ruta:string);
begin
  Ruta_Aplicacion:=ruta;
end;

function PuntoDentroRect(x,y:integer;const rectangulo:Trect):boolean;
begin
  with rectangulo do
    result:=(x>=Left) and (x<Right) and (y>=top) and (y<bottom);
end;


//**********            TColeccionGraficosTablero
//***********************************************

constructor TcoleccionGraficosTablero.create;
var i:integer;
    imagen:Tbitmap;
    directorio:string;
  procedure CrearObjetoGrafico(const filename:string;n:word);
  var NFlagsGrafico:byte;
  begin
    if n<=MAX_OBJETOS_GRAFICOS then
      if Grafico[n]=nil then
      if bytebool(Tablero.InfGra[n].FlagsDesGrafico and dg_recuperarArchivo) then
      try
        imagen.loadFromFile(directorio+filename+ExtArc);
        with Tablero.InfGra[n] do
        begin
          //mucho ojo con no pisar los flags:
          NFlagsGrafico:=0;
          // tipo=tg_normal then
            if (FlagsDesGrafico and dg_EvitarAntialisado)=0 then
              NFlagsGrafico:=NFlagsGrafico or fgfx_Antialisado;
          if (FlagsDesGrafico and dg_PermiteAutoTransparencia)<>0 then
            NFlagsGrafico:=NFlagsGrafico or dg_PermiteAutoTransparencia;
          Grafico[n]:=TElementoGrafico.create(imagen,posx,posy,posx_r,NFlagsGrafico);
        end;
      except
      end;
  end;
begin
  inherited create;
  directorio:=Ruta_Aplicacion+CrptGDD;
  //El terreno
  try
    //Creación de superficie
    CrearSuperficieOculta(superficieTerreno,576,480,etNinguno);
    if superficieTerreno<>nil then
    begin
      imagen:=CrearDeJDD(directorio+'terreno'+ExtArc2);
      CopiarCanvasASuperficie(SuperficieTerreno,0,0,imagen.Width,imagen.Height,imagen.canvas.Handle,0,0);
    end;
  except
  end;
  for i:=0 to MAX_OBJETOS_GRAFICOS do
    Grafico[i]:=nil;//necesario
  for i:=0 to 255 do
    CrearObjetoGrafico(intastr(i),i);
  for i:=0 to 255 do
    CrearObjetoGrafico('c'+intastr(i),i+INICIO_EDIFICIOS);
  for i:=0 to 255 do
    CrearObjetoGrafico('x'+intastr(i),i+INICIO_EXTENDIDO);
  imagen.free;
end;

destructor TcoleccionGraficosTablero.destroy;
var i:integer;
begin
  for i:=MAX_OBJETOS_GRAFICOS downto 0 do
    Grafico[i].free;
  superficieTerreno:=nil;
  inherited destroy;
end;

// TAnimacionObjeto:
//**********************
constructor TAnimacionObjeto.create(const filename:string;Imagen:Tbitmap);
var f:file;
begin
  inherited create;
  try
    assignfile(f,Ruta_Aplicacion+CrptGDD+filename+EXT_CRG);
    FileMode:=0;
    reset(f,1);
    blockread(f,posicionA,sizeOf(posicionA));
    closeFile(f);
  except
  end;
  CrearSuperficieOculta(superficie,imagen.Width,imagen.Height,etNegro);
  if superficie<>nil then
    CopiarCanvasASuperficie(Superficie,0,0,imagen.Width,imagen.Height,imagen.{Bitmap.}canvas.Handle,0,0);
end;

procedure TAnimacionObjeto.draw(akmonstruo:TmonstruoS;x,y:integer);
var flagsFX,ritmoTemp:byte;
begin
  if longbool(akMonstruo.banderas and bnInvisible) then//Oculto
    flagsFX:=fgfx_TransparenteForzado
  else
    flagsFX:=0;
  ritmoTemp:=(akMonstruo.ritmoDeVida shr Desplazador_AniSincro) and $7;
  inc(akMonstruo.ritmoDeVida);
  case akmonstruo.accion of
    aaParado:ritmoTemp:=NroFrameAnimacionParado;
    aaAtacando1..aaAtacando4:
      case ritmoTemp of
        0:ritmoTemp:=5;
        1:ritmoTemp:=6;
        else ritmoTemp:=7;
      end;
  end;
  //Determinar direccion de dibujo
  if MC_espejo[akmonstruo.dir] then
    flagsFX:=flagsFX or fgfx_espejo;
  drawEspecial(x,y,ritmoTemp,flagsFX);
end;

procedure TAnimacionObjeto.drawEspecial(x,y:integer;ritmoAnim,flagsFx:byte);
var rdestino,rorigen:Trect;
    arriba:integer;
    espejo:bytebool;
begin
//Control de animacion
  ritmoAnim:=ritmoAnim and $7;
  if ritmoAnim>0 then
    arriba:=posicionA.acumy[ritmoAnim-1]
  else
    arriba:=0;
  with posicionA do
  begin
    rorigen:=rect(0,arriba,ancho[ritmoAnim],acumy[ritmoAnim]);
    with rdestino do
    begin
      left:=x-modix+cenx[ritmoAnim];
      top:=y-modiy+ceny[ritmoAnim];
      right:=left+ancho[ritmoAnim];
      bottom:=top+acumy[ritmoAnim]-arriba;
    end;
    espejo:=bytebool(flagsFx and fgfx_Espejo);
    if EstaEnPantalla(rDestino,rOrigen,espejo) then
      if bytebool(flagsFx and fgfx_Transparencia) then
        if (flagsFx and fgfx_Transparencia)=fgfx_Transparencia then
          BltAlpha(rdestino,Superficie,rorigen,espejo,64)
        else
          BltTrans(rdestino,Superficie,rorigen,espejo)
      else
        if Aplicar_Antialisado then
          BltAntiAlisado(rdestino,Superficie,rorigen,espejo)
        else
          BltMejorado(rdestino,Superficie,rorigen,espejo);
  end;
end;

destructor TAnimacionObjeto.destroy;
begin
  superficie:=nil;
  inherited destroy;
end;

// TAnimacionEfecto:
//******************

procedure TAnimacionEfecto.drawFX(x,y,ritmoAnim:integer;color:Tcolor;estilo:TFxAlpha;reflejado:bytebool);
var AnteriorColorFx:integer;
    tipot:TFxAlpha;
begin
  AnteriorColorFx:=colorFx;
  colorFx:=color;
  tipot:=tipo;
  tipo:=estilo;
  if reflejado then tipo:=TFxAlpha(byte(tipo) or Msk_FX_Reflejo);
  drawXY(x,y,ritmoAnim);
  colorFx:=AnteriorColorFx;
  tipo:=tipot;
end;

procedure TAnimacionEfecto.drawXYEfecto(x,y,ritmoAnim:integer;color:Tcolor;estilo:TFxAlpha);
var AnteriorColorFx:integer;
    tipot:TFxAlpha;
begin
  AnteriorColorFx:=colorFx;
  colorFx:=color;
  tipot:=tipo;
  tipo:=estilo;
  drawXY(x,y,ritmoAnim);
  colorFx:=AnteriorColorFx;
  tipo:=tipot;
end;

constructor TAnimacionEfecto.create(const ReferenciaAnimacionEfecto:TAnimacionEfectoSuperficie;color:Tcolor;estilo:TFxAlpha);
begin
  if ReferenciaAnimacionEfecto<>nil then
  begin
    superficie:=ReferenciaAnimacionEfecto.getSuperficie;
    posicionA:=ReferenciaAnimacionEfecto.getFormatoAnimacion;
  end;
  colorFX:=color;
  tipo:=estilo;
end;

procedure TAnimacionEfecto.drawXYTablaColor(x,y,ritmoAnim,Color0,Color1:integer;flagsFx:byte);
var rdestino,rorigen:Trect;
    arriba:integer;
    espejo:bytebool;
begin
  if ritmoAnim>0 then
    arriba:=posicionA.acumy[ritmoAnim-1]
  else
    arriba:=0;
  with posicionA do
  begin
    rorigen:=rect(0,arriba,ancho[ritmoAnim],acumy[ritmoAnim]);
    with rdestino do
    begin
      left:=x-modix+cenx[ritmoAnim];
      top:=y-modiy+ceny[ritmoAnim];
      right:=left+ancho[ritmoAnim];
      bottom:=top+acumy[ritmoAnim]-arriba;
    end;
    espejo:=bytebool(flagsFx and fgfx_Espejo);
    if EstaEnPantalla(rDestino,rOrigen,espejo) then
    begin
      PrepararTablaColores(Color0,Color1);
      BltTablaColor(rdestino,Superficie,rorigen,espejo,bytebool(flagsFx and fgfx_Transparencia));
    end;
  end;
end;

procedure TAnimacionEfecto.drawXY(x,y,ritmoAnim:integer);
var rdestino,rorigen:Trect;
    arriba:integer;
    reflejado:bytebool;
begin
  if ritmoAnim>0 then
    arriba:=posicionA.acumy[ritmoAnim-1]
  else
    arriba:=0;
  with posicionA do
  begin
    rorigen:=rect(0,arriba,ancho[ritmoAnim],acumy[ritmoAnim]);
    with rdestino do
    begin
      reflejado:=bytebool(ord(tipo) and Msk_FX_Reflejo);
      if reflejado then
        left:=x-ancho[ritmoAnim]+modix-cenx[ritmoAnim]
      else
        left:=x-modix+cenx[ritmoAnim];
      top:=y-modiy+ceny[ritmoAnim];
      right:=left+ancho[ritmoAnim];
      bottom:=top+acumy[ritmoAnim]-arriba;
    end;
    if EstaEnPantalla(rDestino,rOrigen,reflejado) then
      BltFx(rdestino,Superficie,rorigen,colorFX,tipo);
  end;
end;

procedure TAnimacionEfecto.draw(akmonstruo:TmonstruoS;x,y:integer);
var rdestino,rorigen:Trect;
    ritmoTemp,arriba:integer;
begin
//Control de animacion
  ritmoTemp:=(akMonstruo.ritmoDeVida shr Desplazador_AniSincro) and $7;
  inc(akMonstruo.ritmoDeVida);
  if ritmoTemp>0 then
    arriba:=posicionA.acumy[ritmoTemp-1]
  else
    arriba:=0;
  with posicionA do
  begin
    rorigen:=rect(0,arriba,ancho[ritmoTemp],acumy[ritmoTemp]);
    with rdestino do
    begin
      if MC_espejo[akMonstruo.dir] then
      begin
        tipo:=TFxAlpha(byte(tipo) or Msk_FX_Reflejo);
        left:=x-ancho[ritmoTemp]+modix-cenx[ritmoTemp]
      end
      else
      begin
        tipo:=TFxAlpha(ord(tipo) and Msk_FX_Estilo);
        left:=x-modix+cenx[ritmoTemp];
      end;
      top:=y-modiy+ceny[ritmoTemp];
      right:=left+ancho[ritmoTemp];
      bottom:=top+acumy[ritmoTemp]-arriba;
    end;
    if EstaEnPantalla(rDestino,rOrigen,false) then
      BltFx(rdestino,Superficie,rorigen,colorFX,tipo);
  end;
end;

// TAnimacionEfectoSuperficie:
//**********************

function TAnimacionEfectoSuperficie.getSuperficie:Tbitmap;
begin
  result:=Superficie
end;

function TAnimacionEfectoSuperficie.getFormatoAnimacion:TdaMonstruo;
begin
  result:=posicionA;
end;

constructor TAnimacionEfectoSuperficie.create(const filename:string;imagen:Tbitmap;const color:TColor;const estilo:TFxAlpha);
var f:file;
begin
  inherited create(nil,color,estilo);
  try
    assignfile(f,Ruta_Aplicacion+CrptGDD+filename+EXT_CRG);
    FileMode:=0;
    reset(f,1);
    BlockRead(f,posicionA,sizeOf(posicionA));
    closeFile(f);
  except
  end;
  superficie:=Imagen;
end;

destructor TAnimacionEfectoSuperficie.destroy;
begin
  superficie.free;
  inherited destroy;
end;

procedure TAnimacionDireccionada.RealizarDibujar(akmonstruo:TmonstruoS;x,y:integer;rorigen:Trect);
var rdestino:Trect;
    espejo:bytebool;
    dir:TDireccionMonstruo;
begin
  espejo:=MC_espejo[akMonstruo.dir];
  dir:=MC_DirAnimacion[akMonstruo.dir];
  rdestino:=rect(x,y,x+rOrigen.Right,y+rorigen.Bottom-rorigen.top);
  if EstaEnPantalla(rDestino,rOrigen,espejo) then
    if longBool(akMonstruo.banderas and BnFantasma) then
      BltTransFan(rdestino,Superficie[dir],rorigen,espejo)
    else if longbool(akMonstruo.banderas and bnInvisible) then
        BltTrans(rdestino,Superficie[dir],rorigen,espejo)
      else if LongBool(akMonstruo.Banderas and BnCongelado) then
          BltFxColor(rdestino,Superficie[dir],rorigen,espejo,clCongelado)
        else if LongBool(akMonstruo.Banderas and BnEnvenenado) then
            BltFxColor(rdestino,Superficie[dir],rorigen,espejo,clEnvenenado)
          else if LongBool(akMonstruo.Banderas and BnAturdir) then
              BltFxColor(rdestino,Superficie[dir],rorigen,espejo,clAturdir)
            else if Aplicar_Antialisado then
                BltAntialisado(rdestino,Superficie[dir],rorigen,espejo)
              else
                BltMejorado(rdestino,Superficie[dir],rorigen,espejo);
end;

function TAnimacionDireccionada.obtenerFrame(akmonstruo:TmonstruoS):byte;
begin
  result:=(akMonstruo.ritmoDeVida shr Desplazador_AniSincro) and $3;
  case akmonstruo.accion of
    aaParado:result:=NroFrameAnimacionParado;
    aaAtacando1..aaAtacando5:
      case FlagsEstilosAnimacion of
        1:case result of
            0:result:=5;
            2:result:=7;
            else result:=6;
          end;
        2:case result of
            0:result:=7;
            1:result:=5;
            else
              result:=6;
          end;
        3:case result of
            0:result:=6;
            1:result:=5;
            else result:=7;
          end;
        else
          case result of
            0:result:=5;
            1:result:=6;
            else
              result:=7;
          end;
      end;
  end;
  inc(akMonstruo.ritmoDeVida);
end;

destructor TAnimacionDireccionada.destroy;
var i:integer;
begin
  //Eliminar superficie
  for i:=0 to MaxDirAni do
    superficie[i]:=nil;
  inherited destroy;
end;

// TAnimacionMonstruo:
//**********************
constructor TAnimacionMonstruo.create(const filename:string;Imagen:Tbitmap);
var f:file;
    i,pos_x:integer;
begin
  inherited create;
  try
    assignfile(f,Ruta_Aplicacion+CrptGDD+filename+EXT_CRG);
    FileMode:=0;
    reset(f,1);
    for i:=0 to MaxDirAni do
      Blockread(f,posicionA[i],sizeOf(posicionA[i]));
    if not eof(f) then
      Blockread(f,FlagsEstilosAnimacion,sizeOf(FlagsEstilosAnimacion));
    closeFile(f);
  except
  end;
  pos_x:=0;
  for i:=0 to MaxDirAni do
  begin
    CrearSuperficieOculta(superficie[i],posicionA[i].anchoMax,posicionA[i].acumy[MaxCuadrosM],etNegro);
    if superficie[i]<>nil then
      CopiarCanvasASuperficie(Superficie[i],0,0,posicionA[i].anchoMax,imagen.Height,imagen.{Bitmap.}canvas.Handle,pos_x,0);
    inc(pos_x,posicionA[i].anchoMax);
  end;
end;


// TAnimacionJugador:
//**********************
constructor TAnimacionJugador.create(const filename:string;Imagen:Tbitmap);
var f:file;
    i,pos_x:integer;
begin
  inherited create;
  try
    assignfile(f,Ruta_Aplicacion+CrptGDD+filename+EXT_CRG);
    FileMode:=0;
    reset(f,1);
    for i:=0 to MaxDirAni do
      Blockread(f,posicionA[i],sizeOf(posicionA[i]));
    if not eof(f) then
      Blockread(f,FlagsEstilosAnimacion,sizeOf(FlagsEstilosAnimacion));
    closeFile(f);
  except
  end;
  pos_x:=0;
  for i:=0 to MaxDirAni do
  begin
    CrearSuperficieOculta(superficie[i],posicionA[i].anchoMax,posicionA[i].acumy[MaxCuadrosJ],etNegro);
    if superficie[i]<>nil then
      CopiarCanvasASuperficie(Superficie[i],0,0,posicionA[i].anchoMax,imagen.Height,imagen.canvas.Handle,pos_x,0);
    inc(pos_x,posicionA[i].anchoMax);
  end;
end;

procedure TanimacionMonstruo.draw(akmonstruo:TmonstruoS;x,y:integer);
var posy:integer;
    rorigen:Trect;
    dir:TDireccionMonstruo;
    NroFrame:byte;
begin
  NroFrame:=obtenerFrame(akMonstruo);
  dir:=MC_DirAnimacion[akMonstruo.dir];
  if MC_espejo[akMonstruo.dir] then
    inc(x,-posicionA[dir].ancho[NroFrame]+posicionA[dir].modix-posicionA[dir].cenx[NroFrame])
  else
    inc(x,posicionA[dir].cenx[NroFrame]-posicionA[dir].modix);
  inc(y,posicionA[dir].ceny[NroFrame]-posicionA[dir].modiy);
  if NroFrame<=0 then posy:=0 else posy:=posicionA[dir].acumy[NroFrame-1];
  rorigen:=rect(0,posy,posicionA[dir].ancho[NroFrame],posicionA[dir].acumy[NroFrame]);
  RealizarDibujar(akmonstruo,x,y,rorigen);
end;

procedure TanimacionJugador.draw(akmonstruo:TmonstruoS;x,y:integer);
var posy:integer;
    rorigen:Trect;
    dir:TDireccionMonstruo;
    NroFrame:byte;
begin
  NroFrame:=obtenerFrame(akMonstruo);
  if akmonstruo.accion>=aaAtacando2 then
    inc(NroFrame,(akmonstruo.accion-aaAtacando1)*3);
  dir:=MC_DirAnimacion[akMonstruo.dir];
  if MC_espejo[akMonstruo.dir] then
    inc(x,-posicionA[dir].ancho[NroFrame]+posicionA[dir].modix-posicionA[dir].cenx[NroFrame])
  else
    inc(x,posicionA[dir].cenx[NroFrame]-posicionA[dir].modix);
  inc(y,posicionA[dir].ceny[NroFrame]-posicionA[dir].modiy);
  if NroFrame<=0 then posy:=0 else posy:=posicionA[dir].acumy[NroFrame-1];
  rorigen:=rect(0,posy,posicionA[dir].ancho[NroFrame],posicionA[dir].acumy[NroFrame]);
  RealizarDibujar(akmonstruo,x,y,rorigen);
end;

// TColeccionAnimaciones
//*************************************************
constructor TColeccionAnimaciones.create;
const
      MaxDirecciones=4;//5
      MaxTamannoSimple=104;//Archivo de animación simple 20 frames
      MinTamannoSimple=44;//Archivo de animación simple 8 frames
type TTipoSprite=(tsNoSoportado,tsObjeto,tsEfecto,tsMonstruo,tsJugador);
var i:integer;
  procedure RecuperarFx(indice:byte;const nombre:string;color:Tcolor;estilo:TFxAlpha);
  var f:file;
      tamannoArchivo:integer;
      BitmapDeLaSuperficie:Tbitmap;
      tipoSprite:TTipoSprite;
      ElGraficoFueAbierto:boolean;
  begin
    if Animacion[indice]=nil then
    begin
      {$I-}
        assignfile(f,Ruta_Aplicacion+CrptGDD+nombre+EXT_CRG);
        FileMode:=0;
        reset(f,1);
        tamannoArchivo:=fileSize(f)-4;
        closeFile(f);
      {$I+}
      if (IOResult<>0) then exit;
      if tamannoArchivo<=MaxTamannoSimple then //Una sola direccion
        if tamannoArchivo<=MinTamannoSimple then
          if estilo<>fxNinguno then
            tipoSprite:=tsEfecto
          else
            tipoSprite:=tsObjeto
        else
          tipoSprite:=tsNoSoportado
      else//Varias direcciones
        if tamannoArchivo<=MinTamannoSimple*(MaxDirecciones+1) then
          tipoSprite:=tsMonstruo//
        else
          tipoSprite:=tsJugador;
      //Abrir el .bmp
      BitmapDeLaSuperficie:=nil;
      try
        try
          if tipoSprite<>tsEfecto then
          begin
            BitmapDeLaSuperficie:=Tbitmap.create;
            BitmapDeLaSuperficie.loadFromFile(Ruta_Aplicacion+CrptGDD+nombre+ExtArc);
          end
          else
            BitmapDeLaSuperficie:=CrearDeGDD8bits(Ruta_Aplicacion+CrptGDD+nombre+ExtArc);
          ElGraficoFueAbierto:=true;
        except
          ElGraficoFueAbierto:=false;
        end;
        if ElGraficoFueAbierto then
          case tipoSprite of
            tsEfecto:Animacion[indice]:=TAnimacionEfectoSuperficie.create(nombre,BitmapDeLaSuperficie,color,estilo);
            tsObjeto:Animacion[indice]:=TAnimacionObjeto.create(nombre,BitmapDeLaSuperficie);
            tsMonstruo:Animacion[indice]:=TAnimacionMonstruo.create(nombre,BitmapDeLaSuperficie);
            tsJugador:Animacion[indice]:=TAnimacionJugador.create(nombre,BitmapDeLaSuperficie);
          end;
      finally
        if tipoSprite<>tsEfecto then//En este caso la animación se queda con el objeto, y lo destruirá a su tiempo
          BitmapDeLaSuperficie.free;
      end;
    end;
  end;
  procedure ClonarFx(indice,indiceAClonar:byte;color:Tcolor;estilo:TFxAlpha);
  //Crea un TAnimacionEfecto con una superficie "prestada", no crea ninguna superficie
  begin
    if Animacion[indice]=nil then
      if Animacion[indiceAClonar]<>nil then
        if Animacion[indiceAClonar] is TAnimacionEfecto then
          Animacion[indice]:=TAnimacionEfecto.create(TAnimacionEfectoSuperficie(Animacion[indiceAClonar]),color,estilo);
  end;
  procedure Recuperar(indice:byte;const nombre:string);
  begin
    RecuperarFx(indice,nombre,0,fxNinguno);
  end;
begin
  for i:=0 to Fin_tipo_monstruos do
    if InfMon[i].nombre<>'' then
      Recuperar(i,'m'+intastr(i));
  Recuperar(anBolsa,'bolsa');
  Recuperar(anCadaver,'cadaver');
  Recuperar(anMoscas,'moscas');
  for i:=0 to 3 do
    RecuperarFx(i+anEstandarte,'b'+intastr(i),0,FxTablaColores);
  RecuperarFx(fxPersonalizado0,'fx0',$A0DFE0,fxSumaSaturadaColor);
  RecuperarFx(fxPersonalizado1,'fx1',$A0E0DF,fxSumaSaturadaColor);
  RecuperarFx(fxPersonalizado2,'fx2',$E0DFA0,fxSumaSaturadaColor);

  RecuperarFx(fxFogata,'fogata',$70C8FF,fxSumaSaturadaColor);
  ClonarFx(fxFlamaAzul,fxFogata,$FFFE80,fxExtraColorido);
  ClonarFx(fxFlamaBlanca,fxFogata,$FFE0A0,FxSumaSaturada);
  ClonarFx(fxHumo,fxFogata,$A0A0A0,FxPlano);
  RecuperarFx(fxSangre,'muerte',$0060FF,fxColorido);
  ClonarFx(fxAcido,fxSangre,$60C080,FxColorido);
  RecuperarFx(fxMira,'mira',$C0FFA0,fxGradiente);
  RecuperarFx(fxAura0,'a0',$0,FxPlano);
  RecuperarFx(fxAura1,'a1',$6080B0,FxSumaSaturadaColor);//Aura envolvente
  RecuperarFx(fxAura2,'a2',$F0E0E0,fxPlano);
  RecuperarFx(fxAura3,'a3',$0040FF,fxPlano);
  RecuperarFx(fxAura4,'a4',$FF4080,fxSumaSaturadaColor);
  RecuperarFx(fxAura5,'a5',$0,fxPlano);
  RecuperarFx(fxAura6,'a6',$0,FxPlano);
  RecuperarFx(fxOjo,'ojo',$FFA880,FxSumaSaturadaColor);
  RecuperarFx(fxZZZ,'zzz',$FFA880,FxSumaSaturadaColor);
  RecuperarFx(fxRayo,'rayo',$FF6060,fxSumaSaturada);
  RecuperarFx(fxMana,'Mana',$FFFEFE,fxExtraColorido);
  RecuperarFx(fxChispasDoradas,'Chispas',$80D0FF,fxSumaSaturadaColor);
  ClonarFx(fxChispasAzules,fxChispasDoradas,$FFD080,fxSumaSaturadaColor);
  ClonarFx(fxChispasRojas,fxChispasDoradas,$A050FF,fxSumaSaturadaColor);
  RecuperarFx(fxExplosion1,'ingreso',$00A0C0,fxSumaSaturadaColor);
  ClonarFx(fxExplosion2,fxExplosion1,$00C000,fxSumaSaturada);
  ClonarFx(fxExplosion3,fxExplosion1,$FF7050,fxSumaSaturada);
  RecuperarFx(fxBolaR,'esfera',$40A0FF,fxSumaSaturadaColor);
  ClonarFx(fxBolaG,fxBolaR,$FFFEA0,fxExtraColorido);
  ClonarFx(fxBolaB,fxBolaR,$FF7060,fxSumaSaturada);
  ClonarFx(fxFuegoArtificial1,fxBolaR,$A08060,fxSumaSaturadaColor);
  ClonarFx(fxFuegoArtificial2,fxExplosion1,$3CA4FF,fxSumaSaturadaColor);
  RecuperarFx(fxArdienteR,'arder',$32B0FF,fxSumaSaturadaColor);
  ClonarFx(fxArdienteG,fxArdienteR,$FFFEA0,fxExtraColorido);
  ClonarFx(fxArdienteB,fxArdienteR,$E05858,fxSumaSaturada);
  RecuperarFx(fxPortal,'portal',$808080,fxSumaSaturada);
end;

destructor TColeccionAnimaciones.destroy;
var i:integer;
begin
  for i:=255 downto 0 do
    Animacion[i].free;
  inherited destroy;
end;

//************************************ TElementoGrafico
Constructor TElementoGrafico.create(imagen:Tbitmap;posx,posy,posx_r:integer;losFlagsPorGrafico:byte);
begin
  inherited create;
  ancho:=imagen.Width;
  alto:=imagen.height;
  Posicionx:=posx;
  Posiciony:=posy;
  PosicionX_R:=posx_r;
  FlagsPorGrafico:=losFlagsPorGrafico;
  //Creación de superficie
  CrearSuperficieOculta(superficie,imagen.Width,imagen.Height,etNegro);
  if superficie<>nil then
    CopiarCanvasASuperficie(Superficie,0,0,imagen.Width,imagen.Height,imagen.canvas.Handle,0,0);
end;

destructor TElementoGrafico.destroy;
begin
  superficie:=nil;
  inherited destroy;
end;

procedure TElementoGrafico.Draw(x,y:integer;flagsPorSprite:byte);
var rOrigen,rDestino:Trect;
    Espejo:bytebool;
begin
  Espejo:=bytebool(flagsPorSprite and fgfx_Espejo);
  rOrigen:=rect(0,0,ancho,alto);
  with rDestino do
  begin
    if Espejo then left:=Posicionx_r else left:=Posicionx;
    inc(left,x);
    top:=Posiciony+y;
    right:=left+ancho;
    bottom:=top+alto;
  end;
  if EstaEnPantalla(rDestino,rOrigen,Espejo) then
  begin
    if bytebool(flagsPorSprite and fgfx_Transparencia) then
      if (flagsPorSprite and fgfx_Transparencia)=fgfx_Transparencia then
        BltTrans(rdestino,Superficie,rorigen,espejo)
      else
        if bytebool(FlagsPorGrafico and fgfx_Antialisado) then
          if bytebool(FlagsPorGrafico and dg_PermiteAutoTransparencia) and PuntoDentroRect(PosicionRaton_X,PosicionRaton_Y,rdestino) then
            BltTrans(rdestino,Superficie,rorigen,espejo)
          else
            BltAlpha(rdestino,Superficie,rorigen,espejo,192)
        else
          BltTrans(rdestino,Superficie,rorigen,espejo)
    else
      if Aplicar_Antialisado and bytebool(FlagsPorGrafico and fgfx_Antialisado) then
        BltAntiAlisado(rdestino,Superficie,rOrigen,Espejo)
      else
        BltMejorado(rdestino,Superficie,rOrigen,Espejo)
  end;
end;

end.

