(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit Sprites;
interface
uses Objetos,Demonios,graficador;
const
  FX_Desactivado=0;//FX nulo.
  //Animaciones Especiales (240..255)
  //Tipo de pasos:(0=piso,1=tierra,2=hierbas)
  MC_SndPasosEnTerreno:array[0..31] of byte=(1,2,1,1,2,2,2,2,2,2,1,1,1,1,1,1,
                                             1,0,0,0,0,0,0,0,0,0,0,0,3,1,3,3);
  MA_Levitacion8:array[0..7] of smallint=(0,0,1,2,3,3,2,1);
  //Nombres de posiciones de los objetos:
  NmbrsCsllsObjts:array[0..5] of string=(
      'armaduras y vestimentas',
      'cascos',
      'brazaletes y anillos',
      'anillos',
      'amuletos',
      'municiones');
  cmEstasParalizado='¡Estás paralizado!';
  cmActivasTrampaMagica='Activaste una trampa mágica';
  cmNecesitasNivel_='Necesitas nivel ';
  cm_ParaUsar_=' para usar ';
  //NO MODIFICAR
  MAX_MENSAJES_MONSTRUOS=31;//Número máximo de mensajes en pantalla, usa buffer circular.
  MAX_MENSAJES_CHAT=19;//Número máximo de mensajes chat en pantalla, usa buffer circular.
  NROMAX_MENSAJES_CHAT=MAX_MENSAJES_CHAT+1;
  MAX_SPRITES_FX=127;//Número máximo de efectos en la pantalla, usa buffer circular.
  MAX_TIMER_CONTROL_CHAT=200;

type
  TJugador=Class(TJugadorS)
  private
    { Private declarations }
    //interfaz Sólo Cliente
  public
    { Public declarations }
    function CoordRostro:Tposicion;
    procedure DrawMira(frame:integer);
  //Interfaz cliente-srvidor
    function CalcularColorDeMeditacion:integer;
    function CalcularColorDeMana:integer;
    function MensajeResultado(mensaje,nroArtefacto,icono:byte):string;
    function PuedeUsar(const id_Artefacto:byte):boolean;
    function DescribirConjuro(nroConjuro:byte):string;
    function DescribirEspecialidad:string;
    procedure SonidoArtefacto(NroObjetoBaul:byte);
    function apuntadoEnFormatoCasilla:word;
    function describir:string;
    function ListarEstadoYBanderas:string;
    function RequerimientosParaEscribirPergamino(nro_Conjuro:byte):string;
    function RequerimientosParaLeerPergamino(nro_Conjuro:byte):string;
    function NombreCategoriaEstandar:string;
    procedure PrepararImagenJugador;
    function DineroACadena:string;
    function ObtenerPosicionTopeWordParaCorrer(dirDestino:TDireccionMonstruo):word;
    function MensajeNegarUso(const id_Artefacto:byte;const porRaza:bytebool):string;
    function MensajeAdvertenciaObjetoOfertaNoUsado:string;
    procedure CambiarAnimacionJugador(NuevoCodAnime:byte);
    function PuedeLanzarConjuro:byte;
    procedure ElegirElPrimerConjuroDisponible;
    function TieneLugarVacio(objeto:Tartefacto;cantidad:byte):bytebool;
    function DescribirParty:string;
  end;

  TcontrolMensajes=Class(TObject)
  private
    fmensaje:array [0..MAX_MENSAJES_MONSTRUOS] of String;
    fmonstruo:array [0..MAX_MENSAJES_MONSTRUOS] of TMonstruoS;
    ftimerMensaje:array [0..MAX_MENSAJES_MONSTRUOS] of smallint;
    posLibre:integer;
  public
    procedure draw(CentroX,CentroY:integer);
    procedure setMensaje(Rmonstruo:TmonstruoS;const mensaje:string);
    procedure Inicializar;
    procedure InicializarMensajesMonstruos;
    procedure Tick;
  end;

  TControlChat=Class(TObject)
  private
    fmensaje:array [0..MAX_MENSAJES_CHAT] of String;
    fcolorMensaje:array [0..MAX_MENSAJES_CHAT] of Integer;
    fmensajeImportante:array [0..MAX_MENSAJES_CHAT] of boolean;
    fTimerChat:array [0..MAX_MENSAJES_CHAT] of byte;
    posLibre,NroMensajesDesplegados:integer;
  public
    procedure draw;
    procedure setMensaje(Rmonstruo:TmonstruoS;const mensaje:string;color:Integer);
    procedure setMensajeLinea(Rmonstruo:TmonstruoS;const mensaje:string;color:Integer);
    procedure Inicializar;
  end;

  TControlfx=Class(Tobject)
  private
    fTipoAnimacion,fCoord_fx_x,fcoord_fx_y:array[0..MAX_SPRITES_FX] of byte;
    fdireccion:array[0..MAX_SPRITES_FX] of TDireccionMonstruo;
    fFrame:array[0..MAX_SPRITES_FX] of shortint;
    fMonstruo:array[0..MAX_SPRITES_FX]of TmonstruoS;//nil= fx estático
    posLibre:integer;
  public
    constructor Create;
    procedure Inicializar;
    procedure SetEfecto(x,y:byte;TipoAnimacion:byte;frame:shortint;direccion:TdireccionMonstruo;monstruo:TmonstruoS);
    procedure Tick;
    procedure Draw(Centro_fx_X,Centro_fx_Y:integer;fx_x,fx_y:byte);
  end;

  procedure DrawNombreSprite(RefMonstruo:TmonstruoS;x,y:integer);
  procedure DrawSprite(RefMonstruo:TmonstruoS;centralx,centraly:integer;Camuflado:boolean);
  procedure DrawAurasPiso(RefMonstruo:TmonstruoS;x,y:integer);
  function AgregarSufijoSexuadoA(const nombre:string):string;
  function AgregarSufijoAsexuadoS(const nombre:string):string;
  function DannoPorcentual_125(nivel_125:integer;SoloPorcentaje:boolean):string;
  function DannoPorcentual_3125(nivel_3125:integer):string;
  function nombreAtaquePorObjeto(idObjeto:byte;codigoJugador:word):string;
  function nombreAtaquePorHechizo(idConjuro:byte;codigoJugador:word):string;
  function DescribirAtaqueRealizado(hpReducido,hpTotal:word;codigoJugador:word):string;
  function DescribirHechizoQueLeLanzaron(codHechizo:byte;codigoJugador:word):string;
  function intastrBonoPorcentual(valor:integer):string;// aumenta '+' para positivos, devuelve '' para 0

implementation
uses sonidos,Graficos,MundoEspejo,sysutils,globales,juego;

{   function StrToHex(const cad:string):string;
    const DigitoHexa='0123456789ABCDEF';
    var i:integer;
    begin
      result:='';
      for i:=1 to length(cad) do
      begin
        result:=result+DigitoHexa[ord(cad[i])shr 4+1]+DigitoHexa[ord(cad[i])and $F+1]+' ';
        if (i and $1F)=0 then result:=result+#13+#10;
      end;
    end;}

function intastrBonoPorcentual(valor:integer):string;
begin//Para mostrar armas y armaduras encantadas
  if valor<>0 then
  begin
    str(valor,result);
    if valor>0 then result:='+'+result;
    result:=' ('+result+'%)';
  end
  else
    result:=''
end;

function nombreAtaquePorHechizo(idConjuro:byte;codigoJugador:word):string;
begin
  if codigoJugador<=maxJugadores then
    result:=Jugador[codigoJugador].nombreAvatar
  else
    result:='???';
  result:=result+' te ataca con '+nomConjuro[idConjuro and $1F]
end;

function nombreAtaquePorObjeto(idObjeto:byte;codigoJugador:word):string;
begin
  if codigoJugador<=maxJugadores then
    result:=Jugador[codigoJugador].nombreAvatar
  else
    result:='???';
  if idObjeto>=4 then
    result:=result+' te ataca con '+NomObj[idObjeto]
  else
    result:=result+' te golpea';
end;

function DescribirAtaqueRealizado(hpReducido,hpTotal:word;codigoJugador:word):string;
begin
  result:='Atacas';
  if codigoJugador<=maxJugadores then
    result:=result+' a '+Jugador[codigoJugador].nombreAvatar;
  result:=result+' por '+intastr(hpReducido)+' de '+intastr(hpTotal+hpReducido)+' puntos de salud';
end;

function DescribirHechizoQueLeLanzaron(codHechizo:byte;codigoJugador:word):string;
begin
  if codigoJugador<=maxJugadores then
    result:=Jugador[codigoJugador].nombreAvatar
  else
    result:='???';
  codHechizo:=codHechizo and $1F;
  result:=result+' te lanzó el hechizo "'+NomConjuro[codHechizo]+'"'
end;

function DannoPorcentual_3125(nivel_3125:integer):string;
begin
  result:='';
  if nivel_3125<=0 then exit;
  if nivel_3125 and $7=0 then
    result:='+'+floatToStr(nivel_3125*3.125)
  else
    result:='+'+floatToStrF(nivel_3125*3.125,ffFixed,7,1);
  result:=result+'% daño';
end;

function DannoPorcentual_125(nivel_125:integer;SoloPorcentaje:boolean):string;
begin
  result:='';
  if nivel_125<=0 then exit;
  if not soloPorcentaje then result:='+';
  result:=result+floatToStr(nivel_125*12.5)+'%';
  if not soloPorcentaje then result:=result+' daño';
end;

// TMonstruo
//******************
procedure DrawSprite(refMonstruo:TmonstruoS;centralx,centraly:integer;Camuflado:boolean);
//Ojo solo recibe en x,y Las posicion central del mapa.
var ritmoAnimacionFx,x,y:integer;
    refJugador:Tjugador;
  procedure drawPoderMonstruo;
  var cad:string;
      nivelPoder:integer;
  begin
    nivelPoder:=(refMonstruo.banderas and MskPoderMonstruo) shr DsPoderMonstruo;
    if nivelPoder>0 then
      with TextoDDraw do
      begin
        alineacionX:=axCentro;
        color:=clOro;
        case nivelPoder of
          2:cad:=#175+#32+#175;
          3:cad:=#175+#32+#175+#32+#175;
          else cad:=#175;
        end;
        TextOut(x,y,cad);
      end;
  end;

begin
  with refMonstruo do
  begin
    if (accion=aaParado) and ((banderas and bnParalisis)=0) then
      case InfMon[codAnime].EstiloAnimacion of
        eaAtaqueEsporadico:
          if ((codigo+sincro_conta_Universal) and $1F)<=8 then
            accion:=aaAtacando1;
        eaNoDesplazarPausado:
          if ((codigo+sincro_conta_Universal) and $10)=0 then
            accion:=aaCaminando;
        eaNoDesplazar:
          accion:=aaCaminando;
        eaLevitacion:
          dec(centraly,MA_Levitacion8[(conta_Universal+codigo) shr Desplazador_AniSincro and $7]-1);
      end;
    x:=centralx+coordx*ancho_tile+
      (coordx_ant-coordx)*Paso_InterpoladoX*control_movimiento;
    y:=centraly+coordy*alto_tile+
      (coordy_ant-coordy)*Paso_InterpoladoY*control_movimiento;
    if refMonstruo is Tjugador then
      refJugador:=Tjugador(refMonstruo)
    else
      refJugador:=nil;
    if Mostrar_rostros and (refJugador<>nil) and (codAnime<Inicio_tipo_monstruos) then
    begin
      if camuflado then exit;
      refJugador.PrepararImagenJugador;
      CopiarCanvasASuperficie(SuperficieRender,x-20,y-38,40,40,JForm.Imagen40.Canvas.Handle,0,0);
    end
    else
      if animas.animacion[codAnime]<>nil then
        animas.animacion[codAnime].draw(refMonstruo,x,y);
    if camuflado then exit;
    ritmoAnimacionFx:=fast_sincro_conta_Universal and $F;
    if ritmoAnimacionFx>=8 then ritmoAnimacionFx:=15-ritmoAnimacionFx;
    if LongBool(Banderas and BnParalisis) then
      TAnimacionEfecto(animas.animacion[fxAura4]).drawXY(x,y,sincro_conta_Universal and $7);
    if LongBool(Banderas and BnVisionVerdadera) then
      TAnimacionEfecto(animas.animacion[fxOjo]).drawXY(x,y,fast_sincro_conta_Universal and $7);
    drawPoderMonstruo;
    if not Graficos_Transparentes then
      DrawNombreSprite(refMonstruo,x,y);
    if refJugador<>nil then
    begin
      if LongBool(Banderas and BnDescansar) then
        TAnimacionEfecto(animas.animacion[fxZZZ]).drawXY(x,y,ritmoAnimacionFx);
      ritmoAnimacionFx:=fast_sincro_conta_Universal and $7;
      if LongBool(Banderas and bnEfectoBardo) then
        TAnimacionEfecto(animas.animacion[fxAura1]).drawXYEfecto(x,y+2,ritmoAnimacionFx,$504028,fxsumaSaturada);
      if LongBool(Banderas and BnIraTenax) then
        TAnimacionEfecto(animas.animacion[fxAura1]).drawXY(x,y,fast_sincro_conta_Universal and $7);
      if LongBool(Banderas and BnMana) then
        TAnimacionEfecto(animas.animacion[fxAura1]).drawXYEfecto(x,y-8,ritmoAnimacionFx,Tjugador(refMonstruo).CalcularColorDeMeditacion,FxSumaSaturada);
    end;
  end;
end;

procedure DrawNombreSprite(RefMonstruo:TmonstruoS;x,y:integer);
var refJugador:TjugadorS;
  procedure drawNombre;
  var colorTemp:integer;
  begin
    with TextoDDraw do
    begin
      alineacionX:=axCentro;
      if refJugador=nil then
      begin
        color:=0;
        TextOut(x,y,MapaEspejo.NombreMonstruo(refMonstruo,false));
      end
      else
        with refJugador do
        begin
          if (clan<=maxClanesJugadores) then
          begin
            color:=TablaDeColorIndexado676[clanJugadores[clan].colorClan];
            TextOut(x,y+13,clanJugadores[clan].nombre);
          end;
          colorTemp:=comportamiento;
          if colorTemp<0{comNormal} then
            color:=$5060FF+((100+colorTemp) shl 8)
          else
            if colorTemp>comHeroe then
              color:=$A0F8FF
            else
              color:=$9BFF90-(colorTemp shr 1)-((colorTemp shr 1) shl 8)+(colorTemp shl 16);
          if JugadorCl.comportamiento>comHeroe then
            TextOut(x,y,ObtenerLoginDeCadena(nombreAvatar))
          else
            TextOut(x,y,nombreAvatar);
        end;
    end;
  end;
begin
  if refMonstruo is TJugadorS then refJugador:=TJugadorS(refMonstruo) else refJugador:=nil;
  with refMonstruo do
    if (comportamiento=comComerciante) or
      ( (refJugador<>nil) and ((codAnime<Inicio_tipo_monstruos) or (comportamiento>comHeroe) or (JugadorCl.CapacidadId=ciVerRealmente) or (JugadorCl.comportamiento>comHeroe)) ) then
      if Zoom_Pantalla then
      begin
        if (abs((PosicionRaton_X+mitad_ancho_dd)/2-x)<=21) and (abs((PosicionRaton_Y+mitad_alto_dd)/2-y)<=14) or Mostrar_Nombres_Sprites then
          drawNombre;
      end
      else
        if (abs(PosicionRaton_X-x)<=36) and (abs(PosicionRaton_Y-y)<=24) or Mostrar_Nombres_Sprites then
          drawNombre;
end;

procedure DrawAurasPiso(RefMonstruo:TmonstruoS;x,y:integer);
var contador,colorEspecial:integer;
begin
 contador:=fast_sincro_conta_Universal and $7;
  with RefMonstruo do
  begin
    if LongBool(Banderas and BnFantasma) then
      colorEspecial:=$800000
    else
      colorEspecial:=$280000;
    TAnimacionEfecto(animas.animacion[fxAura3]).drawXYEfecto(x,y,(InfMon[RefMonstruo.TipoMonstruo].tamanno+1) shr 2{frame 0 o 1},colorEspecial,fxPlano);
    if RefMonstruo is TJugador then
      if LongBool(Banderas and BnMana) then
        TAnimacionEfecto(animas.animacion[fxMana]).drawXYEfecto(x,y,contador,TJugador(RefMonstruo).CalcularColorDeMana,fxSumaSaturada);
    if LongBool(Banderas and BnArmadura) then
    begin
      colorEspecial:=fast_sincro_conta_Universal and $F;
      if colorEspecial>=8 then colorEspecial:=15-colorEspecial;
      TAnimacionEfecto(animas.animacion[fxAura2]).drawXY(x,y,colorEspecial);
    end;
    if LongBool(Banderas and BnApresurar) then
    begin
      colorEspecial:=fast_sincro_conta_Universal and $1F;
      if colorEspecial>=16 then colorEspecial:=31-colorEspecial;
      colorespecial:=(colorespecial shl 12) or (colorespecial shl 4) or $0F0F;
      TAnimacionEfecto(animas.animacion[fxAura5]).drawXYEfecto(x,y,contador,colorEspecial,fxSumaSaturada);
    end;
    if LongBool(Banderas and BnFuerzaGigante) then
    begin
      colorEspecial:=(fast_sincro_conta_Universal+16) and $1F;
      if colorEspecial>=16 then colorEspecial:=31-colorEspecial;
      colorEspecial:=colorEspecial shl 12+$F00;
      TAnimacionEfecto(animas.animacion[fxAura0]).drawXYEfecto(x,y,contador,colorEspecial,fxSumaSaturada);
    end;
    if LongBool(Banderas and BnProteccion) then
    begin
      colorEspecial:=fast_sincro_conta_Universal and $FF;
      if colorEspecial>=128 then colorEspecial:=255-colorEspecial;
      colorEspecial:=(colorEspecial shl 8) + $0040FF;
      TAnimacionEfecto(animas.animacion[fxAura6]).drawXYEfecto(x,y,contador,colorEspecial,FxSumaSaturadaColor);
    end;
    if LongBool(Banderas and BnAturdir) then
      TAnimacionEfecto(animas.animacion[fxAura3]).drawXY(x,y,Contador);
  end;
end;

function Tjugador.CoordRostro:Tposicion;
begin
  result.x:=(fCodCara and $7) * 40;
  result.y:=(fCodCara shr 3) * 40;
end;

function Tjugador.ObtenerPosicionTopeWordParaCorrer(dirDestino:TDireccionMonstruo):word;
var x,y:integer;
begin
//Sin control de rango, casos revisados, no existe peligro de valores fuera
//del rango [0..255].
  case dirDestino of
    dsNorte:begin
      FdestinoX:=coordX;
      FdestinoY:=0;
    end;
    dsSud:begin
      FdestinoX:=coordX;
      FdestinoY:=255;
    end;
    dsEste:begin
      FdestinoX:=255;
      FdestinoY:=coordY;
    end;
    dsOeste:begin
      FdestinoX:=0;
      FdestinoY:=coordY;
    end;
    dsNorOeste:begin
      if coordx<coordy then
      begin
        y:=coordy-coordx;
        FdestinoY:=y;
        FdestinoX:=0;
      end
      else
      begin
        x:=coordx-coordy;
        FdestinoX:=x;
        FdestinoY:=0;
      end;
    end;
    dsSudEste:begin
      if coordy>coordx then
      begin
        X:=(255-coordy)+coordx;
        FdestinoX:=X;
        FdestinoY:=255;
      end
      else
      begin
        Y:=(255-coordx)+coordy;
        FdestinoY:=Y;
        FdestinoX:=255;
      end;
    end;
    dsSudOeste:begin
      if coordy>(255-coordx) then
      begin
        X:=coordX-(255-coordy);
        FdestinoX:=X;
        FdestinoY:=255;
      end
      else
      begin
        Y:=coordY+coordX;
        FdestinoY:=Y;
        FdestinoX:=0;
      end;
    end;
    dsNorEste:begin
      if coordx>(255-coordy) then
      begin
        Y:=coordy-(255-coordX);
        FdestinoY:=Y;
        FdestinoX:=255;
      end
      else
      begin
        X:=coordX+coordY;
        FdestinoX:=X;
        FdestinoY:=0;
      end;
    end;
  end;
  result:=FDestinoX or (FDestinoY shl 8);
end;

procedure Tjugador.DrawMira(frame:integer);
var ColorMira:integer;
begin
  if MonstruoApuntadoIncorrecto then exit;
  with apuntado do
  begin
    if not (apuntado is TjugadorS) then
      if comportamiento=comComerciante then
        ColorMira:=$E07048
      else
        case InfMon[tipoMonstruo].comportamiento of
          comTerritorial,comGuardia:ColorMira:=$40A8C8;
          comGuerreroMago,comAgresivo,comAtaqueHechizos,comAtaqueRango:ColorMira:=$6080D8;
          else ColorMira:=$70b840;
        end
    else
      ColorMira:=$b8b0a8;
    TAnimacionEfecto(animas.animacion[fxMira]).drawXYEfecto(DDraw_mitad_sprite_X+(coordX-self.CoordX)*ancho_tile-interpolador_MaestroX+
        (coordx_ant-coordx)*Paso_InterpoladoX*control_movimiento,
      DDraw_mitad_sprite_Y+(coordY-self.CoordY)*alto_tile-interpolador_MaestroY+
        (coordy_ant-coordy)*Paso_InterpoladoY*control_movimiento,frame,ColorMira,FxSumaSaturadaColor);
  end;
end;

function Tjugador.mensajeNegarUso(const id_Artefacto:byte;const porRaza:bytebool):string;
begin
  case id_Artefacto shr 3 of//clase
    1..6:result:='usa ese tipo de arma';
    7..8:result:='usa ese tipo de armadura';
    9:result:='usa esa vestimenta';
    10:result:='usa este tipo de escudo';
    11,12:result:='usa '+NomObj[id_Artefacto];
    14:result:='usa el '+NomObj[id_Artefacto];
    18:result:='come eso';
    19:result:='toma eso';
    else result:='usa ese objeto';
  end;
  result:=' no '+result;
  if porRaza then
    result:=infMon[TipoMonstruo].nombre+result
  else
    result:=NombreCategoriaEstandar+result;
  result:='Un '+result;
end;

function Tjugador.MensajeResultado(mensaje,nroArtefacto,icono:byte):string;
{
NOTA:
  Delphi optimiza los "case ... of" con saltos directos, asi que no son sólo "if then" anidados.
}
begin
  result:='';
  case mensaje of
    i_NoPuedesTeletransportarte:result:='No puedes moverte o pararte en el lugar donde quieres ir.';
    i_ApuntaPrimero:result:='Tienes que apuntar a un monstruo o a un avatar';
    i_ApuntaAUnMonstruo:result:='Tienes que apuntar a un monstruo';
    i_PrimeroApuntaAUnJugador:result:='Tienes que apuntar a un avatar';
    i_SinArma:result:='Coloca un arma en tus manos para atacar';
    i_NegadoRaza:result:=mensajeNegarUso(Artefacto[nroArtefacto].id,true);
    i_NegadoCategoria:result:=mensajeNegarUso(Artefacto[nroArtefacto].id,false);
    i_TeFaltaNivelParaUsarElObjeto:begin
      icono:=Artefacto[nroArtefacto].id;//para optimizar... este es el id. del objeto
      if icono=114 then
        //considerando que el cetro es el id.114 y tiene 21 como mínimonivel
        result:='Sólo un Archimago puede utilizar el Cetro de Archimago'
      else
        if (icono>=113) and (icono<=119) and (InfObj[Artefacto[nroArtefacto].id].nivelminimo=7) then
          result:='Los aprendices no pueden utilizar este artefacto mágico'
        else
          result:=cmNecesitasNivel_+intastr(InfObj[Artefacto[nroArtefacto].id].nivelminimo)+cm_ParaUsar_+nombreCortoObjeto(Artefacto[nroArtefacto]);
    end;
    i_CasillaIncorrecta:
      if (icono>=uArmadura) and (icono<=uMunicion) then
        result:='Esta casilla es para '+NmbrsCsllsObjts[icono-2];
    i_MunicionIncorrecta:
      if Usando[uMunicion].id<4 then
        result:='No te queda munición'
      else
        result:='Tu munición no corresponde con tu arma';
    i_LugarNoAdecuadoParaTrampa:result:='Busca otro lugar para armar la trampa';
    i_LugarNoAdecuadoParaFogata:result:='Busca otro lugar para hacer la fogata';
    i_NoPuedesEncenderFogataPorLluvia:result:='Busca un lugar protegido de la lluvia';
    i_TuInventarioEstaLleno:result:='Ya no tienes espacio en tu inventario';
    i_EstasMuyLejos:result:='Acércate, estás demasiado lejos';
    i_NecesitasAmbasManos:result:='Tus manos están ocupadas y tu bolsa llena';
    i_UsalaEnLaOtraMano:result:='Esa arma va en la otra mano';
    i_SinAmbidextria:result:='No tienes la pericia Ambidextría';
    i_EstasMuerto:result:='Estás muerto, primero necesitas ser resucitado';
    i_NoNecesitasVendas:result:='No necesitas usar vendas';
    i_SinMinerales:result:='Tienes que estar frente a una veta de mineral';
    i_FallasteAlIntentarDesactivarLaTrampa:result:='Fallaste al intentar desactivar la trampa';
    i_SinSed:result:='No tienes sed';
    i_SinHambre:result:='No tienes hambre';
    i_sinHeridas:result:='No tienes heridas';
    i_manaMaximo:result:='Tu nivel de maná está al máximo';
    i_NadaParaPescar:result:='Aqui no hay peces';
    i_NadaParaTalar:result:='Tienes que estar frente a un árbol para talarlo';
    i_NadaParaTallar:result:='Pon una gema sin tallar en tu mano izquierda';
    i_NecesitasCasillaLibreEnBolso:result:='Necesitas un espacio libre en tu bolso';
    i_NoSabesFundir:result:='Sólo un herrero o un minero funden metal';
    i_SinFundicion:result:='Tienes que estar frente a una fundición';
    i_SinYunque:result:='Tienes que estar frente a un yunque para construir objetos.';
    i_NecesitasMasMineral:result:='Necesitas más mineral para fundir un lingote';
    i_NoSabesHacerPocimas:result:='Sólo un herbalista puede crear pócimas';
    i_SinTelar:result:='Tienes que estar frente a un telar';
    i_ArruinasteLaGema:result:='Arruinaste la gema, perdió valor al tallarla';
    i_noFabricasTela:result:='Sólo un sastre puede fabricar tela';
    i_noEresSastre:result:='No tienes la pericia Sastrería';
    i_noEresHerrero:result:='No conoces nada de Herrería';
    i_noEresCarpintero:result:='No sabes de Carpintería';
    i_noEresAlquimico:result:='Desconoces los secretos de la Alquimia';
    i_noEresMagoEscritor:result:='No sabes escribir magia';
    i_NecesitasMasFibras:result:='Necesitas más fibras para fabricar tela';
    i_EstasParalizado:result:=cmEstasParalizado;
    i_SinPergamino:result:='Pon un pergamino en blanco en tu mano izquierda';
    i_ElObjetoVaEnOtraMano:result:='Ese objeto se coloca en la otra mano';
    i_NoTeSirvePocimasParaMana:result:='Esta pócima no es para guerreros ni bribones';
    i_NoConocesElConjuro:result:='No conoces el hechizo "'+nomConjuro[conjuroelegido]+'"';
    i_FaltaNivelONoConocesConjuroParaEscribirlo:result:=RequerimientosParaEscribirPergamino(ConjuroElegido);
    i_FaltaNivelParaLeelElPergamino:result:=RequerimientosParaLeerPergamino(Artefacto[nroArtefacto].modificador);
    i_NoTienesSuficienteMana:result:='El hechizo "'+nomConjuro[conjuroelegido]+'" necesita '+intastr(Infconjuro[conjuroElegido].nivelMana)+' puntos de maná';
    i_NoTienesMana:result:='Ya no te queda maná';
    i_NoPuedesHacerMagia:result:='No sabes hacer magia';
    i_NoEstasEnvenenado:result:='No estás envenenado';
    i_conjuroParaJugadores:result:='Este hechizo sólo afecta a los avatares';
    i_SinArmaAfilable:result:='No tienes nada para afilar en tus manos';
    i_SinArmaAceitable:result:='Pon el arco o ballesta en tu mano derecha';
    i_ObjetoMartillableEnManoDer:result:='Pon lo que repararás en tu mano derecha';
    i_ObjetoRemendableEnManoDer:result:='Pon lo que remendarás en tu mano derecha';
    i_NoPuedesRepararMejor:
      if nivel>=MIN_NIVEL_CATEGORIA then
        result:='Esta en buenas condiciones, no necesitas repararlo'
      else
        result:='Si tratas de repararlo sólo empeorarías su estado actual';
    i_NoTienesLaPericiaOcultarse:result:='No tienes la pericia Ocultarse';
    i_TieneOcultarYElAmuletoDeCamuflaje:result:='Su amuleto de camuflaje no te deja verlo claramente.';
    i_NoPuedesAtacarInvisibles:result:='No puedes atacarle por que no puedes verlo.';
    i_NoPudisteOcultarte:result:='¡No pudiste ocultarte!';
    i_NoTienesLaPericiaIraTenax:result:='No tienes la pericia Ira Tenax';
    i_IraNecesitaMasHP:result:='Para activar Ira Tenax necesitas más de '+intastr(PENA_HP_IRA_TENAX)+' puntos de salud';
    i_NecesitasManoDerechaLibre:result:='Necesitas desocupar la mano derecha';
    i_AunNoPuedesConstruirNada:result:='No tienes suficiente nivel para fabricar con esta herramienta';
    i_falloElConjuro:result:='Tu hechizo fue vencido por resistencia mágica';
    i_EsInvulnerableAConjuros:result:='¡Es invulnerable a tu hechizo!';
    i_TuVaritaMagicaSeAgoto:result:='Falló el hechizo, tu varita mágica se agotó';
    i_DisparoObstaculizado:result:='Un obstáculo del terreno impide atacar a tu objetivo';
    i_ConjuroObstaculizado:result:='Un obstáculo del terreno no deja pasar el hechizo';
    i_CalmasSed:result:='Calmaste tu sed';
    i_CalmasHambre:result:='Calmaste tu hambre';
    i_BebesPocima:result:='Bebes la pócima mágica';
    i_EchasElVeneno:result:='Echaste el brebaje venenoso';
    i_FalloConjuroMaldecir:result:='¡No lograste maldecir sus pertenencias!';
    i_EstaProtegidoContraHechizosMalvados:result:='Está protegido contra hechizos malvados';
    i_NoPuedesVampirearle:result:='No tiene puntos vida que puedas drenarle, está casi muerto';
    i_TieneGemaAntiMaldicion:result:='¡Su amuleto le ha protegido de la maldición!';
    i_YaEstaIdentificado:result:='El objeto elegido del inventario ya está identificado';
    i_NoPudisteConjurarMonstruo:result:='No se puede conjurar el monstruo en ese lugar';
    i_NecesitasGemaTallada:result:='Coloca una gema tallada en tu mano derecha';
    i_NecesitasGemaParaArcana:result:='Necesitas una Amatista, Aguamarina, Esmeralda o un Brillante';
    i_NecesitasGemaParaSagrada:result:='El conjuro requiere un Topacio, Zafiro, Rubí o un Sol oscuro';
    i_EstaGemaNoEsAdecuada:result:='Esta gema es especial y no es adecuada para el conjuro';
    i_ElObjetoNoSePuedeHechizar:result:='El objeto seleccionado en el inventario no es hechizable';
    i_NoTieneCalidadParaBendecir:result:='Tienes que comprar uno nuevo o repararlo a (90+)';
    i_ElObjetoYaEstaHechizado:result:='El objeto elegido del inventario ya está hechizado';
    i_NecesitasObjetoValioso:begin
      jform.AgregarMensaje('!Necesitas colocar en tu mano derecha uno de estos objetos:');
      result:='  Oricalco, Aguamarina, Zafiro, Esmeralda, Rubí o Brillante';
    end;
    i_NecesitasTenerLibreLaPrimeraCasilla:result:='Desocupa la primera casilla de tu inventario';
    i_NoPuedesActivarOtraSesion:result:='No está activo en el servidor la opción de multiples sesiones';
    i_NecesitasMayorNivelAdministrativo:result:='Comando denegado: Necesitas mayor nivel administrativo';
    i_NoHayEspacioEnTuParty:result:='No puedes agregar otro miembro en tu grupo';
    i_NoHayEspacioEnSuParty:result:='No puede agregar otro miembro en su grupo';
    i_YaEstaEnTuParty:result:='El avatar indicado ya forma parte de tu grupo';
    i_TieneQueAgregarteASuParty:result:='Invitaste al avatar a tu grupo';
    i_ElBrillanteNoAfectaArmaduras:result:='El Brillante no tiene efecto en armaduras';
    i_NecesitasGema90a100:result:='Necesitas una Gema de 90% a 100% de calidad';
    i_NecesitasMasLennos:result:='Necesitas cinco leños para preparar la fogata';//Consistente con NRO_LENNOS_FOGATA
    i_NoHayLugarParaSoltarElObjeto:result:='Aqui no hay espacio para dejar más cosas';
    i_YaConocesElConjuro:result:='Ya conoces el hechizo del pergamino';
    i_SeleccionaObjetoInventario:result:='Primero elige un objeto del inventario';
    i_RechazaTuOferta:result:='Rechazó tu oferta, no comprará';
    i_NoPuedesVenderEso:result:='Mejor si no intentas vender eso';
    i_ApuntaParaComerciar:result:='Acércate y señala a un comerciante';
    i_NoEsUnComerciante:result:='No es un comerciante';
    i_noEsEnvenenable:result:='Esta pócima es para envenenar flechas';
    i_ConjuroSobreAvatarMuerto:result:='Este hechizo no actúa en avatares muertos';
    i_NoSabesCurtir:result:='No sabes curtir pieles';
    i_SinCurtidora:result:='Tienes que estar frente a una tina de curtido';
    i_NecesitasMasPieles:result:='Necesitas más pieles';
    i_MaldicionSobreObjeto:result:='¡Han lanzado una maldición sobre tus pertenencias!';
    i_NoTienesLaPericiaZoomorfismo:result:='No tienes la pericia Zoomorfismo';
    i_NoPuedesIniciarZoomorfismo:result:='Desequipa armas, armadura y casco para Zoomorfismo';
    i_YaEstasUsandoZoomorfismo:result:='Ya estás en forma de animal';
    i_NecesitasManaParaZoomorfismo:result:='Zoomorfismo necesita '+intastr(MANA_ZOOMORFISMO)+' puntos de maná';
    i_NecesitasManaParaJuglaria:result:='Necesitas '+intastr(MANA_USAR_INSTRUMENTO)+' puntos de maná';
    i_EstasBajoEfectodeJuglaria:result:='¡Tu moral de combate se ha elevado!';
    i_ColocaAlgoParaEnvenenarEnManoDerecha:result:='Pon en tu mano derecha algo para envenenar';
    i_NoEresBardo:result:='Me temo que no eres bardo';
    i_NoTienesTodosLosMateriales:result:='No tienes los materiales necesarios en tu inventario';
    i_ConjuroSobreNPCProtegido:result:='En realidad no deseas lanzarle hechizos';
    i_ElNPCEstaProtegido:result:='Lo piensas y decides no atacarle';
    i_NoTienesSuficienteNivel:result:='No tienes el nivel mínimo necesario';
    i_SoloParaFantasmas:result:='La resurección es para los muertos';
    i_UsasPalabraRetornoFantasma:result:='Usas la palabra del retorno de fantasmas';
    i_NoEstasCercaDeCatedral:result:='No existe una catedral cerca de esta zona';
    i_SinIngredientes:result:='En este lugar no hay ingredientes de pócimas';
    i_creasteNuevoClan:result:='Has creado un nuevo clan, eres el lider del clan';
    i_YaTieneClan:result:='Ese avatar ya pertenece a otro clan';
    i_NoEstaEnTuClan:result:='No pertenece a tu clan';
    i_NoPuedesCrearOtroClan:result:='No puedes formar otro clan, ya existen demasiados clanes';
    i_NoEresElLiderDelClan:result:='Acción reservada a líderes de clanes';
    i_NoPertenecesAUnClan:result:='No perteneces a un clan';
    i_NoPuedesAtacarMiembrosDeTuClan:result:='Los miembros de un clan no pueden atacarse entre si';
    i_ElCastilloNoTieneTantoDinero:result:='El castillo no tiene esa cantidad de dinero';
    i_YaSeRealizoEsaMejoraEnElGuardian:result:='Esa mejora ya fue realizada';
    i_HasMejoradoLaDefensaDelCastillo:result:='Has mejorado las defensas de tu castillo';
    i_SinEstudioDeMago:result:='Tienes que estar frente a un estudio de magia';
    i_SinEstudioDeAlquimia:result:='Tienes que estar frente a un estudio de alquimia';
    i_TuBaulEstaLleno:result:='Tu baul mágico está lleno';
    i_SeleccionaObjetoBaul:result:='Elige un objeto de tu baúl';
    i_YaExisteUnNombreMuyParecido:result:='Ya existe un nombre muy parecido, elige otro';
    i_SinTintaMagicaSuficiente:result:='Necesitas más tinta: un gramo por nivel del hechizo';
    i_LeDrenasteTodosMenosUnPuntoDeVida:result:='¡Le has quitado casi todos los puntos de salud!';
    i_EsTuMonstruo:result:='Ese monstruo está bajo tus órdenes, no puedes atacarle';
    i_NecesitasELAnilloDelConjurador:result:='Necesitas tener equipado el anillo del control';
    i_NoPuedesAtacarAvataresPacifistas:result:='Sólo puedes atacarle si se vuelve agresivo';
    i_NoTienesPrivilegioParaUsarEseComando:result:='No tienes suficiente nivel administrativo para usar el comando.';
    i_NoEstasEnModoPKiller:result:='Para entrar en modo AGRESIVO escribe: /agr';
    i_NoComproEsasCosas:case random(3) of
      0:result:='No estoy interesado en tu oferta';
      1:result:='No compro esas cosas';
      else result:='No estoy interesado. Busca un mercader que compre de todo';
    end;
    i_NoIntentesEstafarme:result:='¡Ni se te ocurra estafarme!';
    i_DialogoNPJqueCompro:case random(3) of
      0:result:='Fue un buen negocio';
      1:result:='¿Algo más que quieras vender?';
      else result:='¿Comprarás algo ahora que tienes dinero?';
    end;
    i_DialogoNPJqueVendio:case random(3) of
      1:result:='¿Deseas comprar algo más?';
      2:result:='Sigue comprando lo que desees';
      else result:='¡Realizaste una buena compra!';
    end;
    200..229:result:='Lanzaste el hechizo "'+NomConjuro[(mensaje-200)]+'"';
    i_OK:if icono>=uConsumible then
      case Artefacto[nroArtefacto].id of
{        ihPico:
        ihHacha:
        ihCanna:
        ihTallador:}
        orHierro..orOro:result:='Fundes el mineral de '+NomObj[Artefacto[nroArtefacto].id]+' en lingotes';
        orFibras:result:='Fabricas la tela';//fabricar tela
        ihAfilador:
        begin
          if InfObj[Usando[uArmaIzq].id].TipoReparacion=trAfilar then
            result:='Afilas tu '+NomObj[Usando[uArmaIzq].id];
          if InfObj[Usando[uArmaDer].id].TipoReparacion=trAfilar then
          begin
            if result='' then
              result:='Afilas tu '
            else
              result:=result+' y tu ';
            result:=result+NomObj[Usando[uArmaDer].id];
          end;
        end;
        ihAceite:result:='Aceitas la cuerda de tu '+NomObj[Usando[uArmaDer].id];
        ihMartillo:
          if InfObj[Usando[uArmaDer].id].TipoReparacion=trMartillar then
            result:='Reparas tu '+NomObj[Usando[uArmaDer].id];
        ihTijeras:
          if InfObj[Usando[uArmaDer].id].TipoReparacion=trCoser then
            result:='Remiendas tu '+NomObj[Usando[uArmaDer].id];
      end;
  end;
end;

function Tjugador.RequerimientosParaLeerPergamino(nro_Conjuro:byte):string;
begin
  if nro_Conjuro<=31 then
    with InfConjuro[nro_Conjuro] do
      if nivelJugador>nivel then
        result:=cmNecesitasNivel_+intastr(nivelJugador)+' para leer este pergamino'
      else
        result:='Necesitas '+intastr(nivelINT*5)+'% en inteligencia y '+intastr(nivelSAB*5)+
          '% en sabiduría para no fallar'
  else
    result:='';
end;

function Tjugador.RequerimientosParaEscribirPergamino(nro_Conjuro:byte):string;
begin
  if nro_Conjuro<=31 then
    if ((Conjuros and (1 shl nro_Conjuro))<>0) then
      with InfConjuro[nro_Conjuro] do
      begin
        if INT<nivelINT then
          result:='Para escribir "'+NomConjuro[nro_Conjuro]+'" necesitas '+intastr(nivelINT*5)+'% en inteligencia'
        else
          if SAB<nivelSAB then
            result:='Para escribir "'+NomConjuro[nro_Conjuro]+'" necesitas '+intastr(nivelSAB*5)+'% en sabiduría';
      end
    else
      result:='No conoces el hechizo "'+NomConjuro[nro_Conjuro]+'"'
  else
    result:='';
end;

procedure Tjugador.PrepararImagenJugador;
var PosOrigen:Tposicion;
    fxrostro:TbrilloFxObjeto;
begin
  posOrigen:=CoordRostro;
  if longbool(Banderas and bnFantasma) then
    fxRostro:=bfxGris
  else
    if longBool(Banderas and $FFFF) then//sólo las visibles
    begin
      fxrostro:=bfxMagico;
      if longbool(banderas and BnCongelado) then
        fxrostro:=bfxCongelado
      else
        if longbool(banderas and bnEnvenenado) then
          fxrostro:=bfxVenenoso
        else
          if longbool(banderas and (bnParalisis or bnAturdir)) then
            fxrostro:=bfxMalvado
          else
            if longbool(banderas and (BnIraTenax or bnZoomorfismo)) then
              fxrostro:=bfxFuegoInterno
    end
    else
      fxrostro:=bfxNinguno;
  Jform.Imagen40.copiarImagen(posOrigen.x,posOrigen.y,Jform.Rostros,fxrostro);
  Jform.Imagen40.copiarTransMagenta(Jform.CuadroResalte);
end;

function Tjugador.NombreCategoriaEstandar:string;
begin
  result:=MC_Nombre_Categoria[codCategoria and $7];
end;

procedure Tjugador.SonidoArtefacto(NroObjetoBaul:byte);
var IdSonido:integer;
begin
  if NroObjetoBaul<=MAX_ARTEFACTOS then
  begin
    case Artefacto[NroObjetoBaul].id of
      ihPico:IdSonido:=snMinar;
      ihHacha:IdSonido:=snTalar;
      ihCanna:IdSonido:=snPescar;
      ihTallador:IdSonido:=snMinar;
      orHierro..orOro:IdSonido:=snFundir;
      orPiel:IdSonido:=snCurtir;
      ihMartillo:IdSonido:=snHerrero;
      ihSerrucho:IdSonido:=snCarpintero;
      ihTijeras:IdSonido:=sntijeras;
      ihLibroAlquimia:IdSonido:=snAlquimia;
      ihCalderoMagico:IDSonido:=snPrepararPocima;
      ihPlumaMagica:IdSonido:=snEscribirMagia;
      ihVaritaVacia:IdSonido:=snVaritaMagica;
      ihAfilador:IdSonido:=snAfilar;
      ihAceite,ihVeneno,ihParalizante:IdSonido:=snAceitar;
      ihHerramientasHerbalista:IdSonido:=snBuscarIngrediente;
      144..151:IdSonido:=snComer;
      152..167:IdSonido:=snBeber;
      orFibras:IdSonido:=snFabricarTela;
      ihVendas:IdSonido:=snRealizarVendar;
      orFlauta:IdSonido:=snFlauta;
      orLaud:IdSonido:=snLaud;
      orCuerno:IdSonido:=snCuerno;
    else
      IdSonido:=snNinguno;
    end;
    SonidoIntensidad(IdSonido,-random(128));
  end;
end;

function Tjugador.DescribirEspecialidad:string;
begin
  result:='Especialidad: +'+intastr(NivelEspecializacion shr 3+4)+'% ataque '+
    DannoPorcentual_3125((NivelEspecializacion shr 3)+1);
end;

function Tjugador.DescribirConjuro(nroConjuro:byte):string;
begin
  if maxMana>0 then
    with InfConjuro[nroconjuro] do
      result:='"'+NomConjuro[nroconjuro]+'" IS:'+intastr(nivelINT*5)+'%,'+intastr(nivelSAB*5)+
      '% Niv:'+intastr(nivelJugador)+' Maná:'+intastr(nivelMana)
  else
    result:=DescribirEspecialidad;
end;

function Tjugador.describir:string;
begin
  result:=nombreAvatar+', '+InfMon[TipoMonstruo].nombre+', ';
  if comportamiento>comHeroe then
    result:=result+Reputacion()
  else
    result:=result+NombreCategoria()+' nivel '+intastr(nivel);
end;

function TJugador.ListarEstadoYBanderas:string;
begin
  result:='Estado:';
  if (banderas and (bnArmadura or bnFuerzaGigante or bnApresurar or bnProteccion or bnvisionVerdadera))<>0 then result:=result+' Hechizado,';
  if (banderas and bnInvisible)<>0 then
    result:=result+' Invisible,'
  else
    if (banderas and bnOcultarse)<>0 then
      result:=result+' Oculto,';
  if (banderas and bnEnvenenado)<>0 then result:=result+' Envenenado,';
  if (banderas and bnCongelado)<>0 then result:=result+' Congelado,';
  if (banderas and bnIraTenax)<>0 then result:=result+' Ira Tenax,';
  if (banderas and bnAturdir)<>0 then result:=result+' Aturdido,';
  if (banderas and bnParalisis)<>0 then result:=result+' Paralizado,';
  if (banderas and bnVendado)<>0 then result:=result+' Vendado,';
  if (banderas and BnZoomorfismo)<>0 then result:=result+' Forma Animal,';
  if (banderas and bnEfectoBardo)<>0 then result:=result+' Combativo,';
  if length(result)<=8 then
    result:=result+' Normal'
  else
    delete(result,length(result),1);
end;

// TMensajeMonstruo
//--------------------------------------------
procedure TcontrolMensajes.setMensaje(Rmonstruo:TmonstruoS;const mensaje:string);
var i:integer;
begin
  if Rmonstruo=nil then exit;
  for i:=0 to MAX_MENSAJES_MONSTRUOS do
    if fmonstruo[i]=Rmonstruo then
    begin
      if length(mensaje)>0 then
      begin
        ftimerMensaje[i]:=length(mensaje)*3+40;
        fmensaje[i]:=mensaje;
      end
      else
        ftimerMensaje[i]:=0;
      exit;
    end;
  if length(mensaje)=0 then exit;
  fmonstruo[posLibre]:=Rmonstruo;
  ftimerMensaje[posLibre]:=length(mensaje)*3+40;
  fmensaje[posLibre]:=mensaje;
  inc(posLibre);
  if posLibre>MAX_MENSAJES_MONSTRUOS then posLibre:=0;
end;

procedure TcontrolMensajes.InicializarMensajesMonstruos;
var i:integer;
begin
  posLibre:=0;
  for i:=0 to MAX_MENSAJES_MONSTRUOS do
    if fTimerMensaje[i]>0 then
      if fmensaje[i]<>'' then
        if fMonstruo[i]<>nil then
          if not (fMonstruo[i] is TjugadorS) then
            fTimerMensaje[i]:=0;
end;

procedure TcontrolMensajes.Inicializar;
var i:integer;
begin
  posLibre:=0;
  for i:=0 to MAX_MENSAJES_MONSTRUOS do
    fTimerMensaje[i]:=0;
end;

procedure TcontrolMensajes.draw(CentroX,CentroY:integer);
var i:integer;
  procedure DesplegarMensaje(n_mensaje:integer);
  var longitud,c,posc,px,py:integer;
  begin
    with fMonstruo[n_mensaje],TextoDDraw do
    begin
      px:=CentroX+coordx*ancho_tile+(coordx_ant-coordx)*Paso_InterpoladoX*control_movimiento;
      py:=CentroY-56+coordy*alto_tile+(coordy_ant-coordy)*Paso_InterpoladoY*control_movimiento;
      if TextWidth(fmensaje[n_mensaje])>=160 then
      begin
        longitud:=length(fmensaje[n_mensaje]);
        posc:=0;
        c:=1;
        while (c<longitud) do
        begin
           if fmensaje[n_mensaje][c]=' ' then
             if abs(c-(longitud div 2))<abs(posc-(longitud div 2)) then
               posc:=c;
           inc(c);
        end;
        TextOut(px,py-textHeight+1,copy(fmensaje[n_mensaje],1,posc-1));
        TextOut(px,py,copy(fmensaje[n_mensaje],posc+1,longitud));
      end
      else
        TextOut(px,py,fmensaje[n_mensaje]);
    end;
  end;
begin
  TextoDDraw.alineacionX:=axCentro;
  TextoDDraw.color:=clBronce;
  for i:=0 to MAX_MENSAJES_MONSTRUOS do
    if fTimerMensaje[i]>0 then
      if fmensaje[i]<>'' then
        if fMonstruo[i]<>nil then
          if not (fMonstruo[i] is TjugadorS) then
            DesplegarMensaje(i);
  if Texto_Modalidad_Chat then exit;
  TextoDDraw.color:=$FFFFFF;
  for i:=0 to MAX_MENSAJES_MONSTRUOS do
    if fTimerMensaje[i]>0 then
      if fmensaje[i]<>'' then
        if fMonstruo[i]<>nil then
          if fMonstruo[i] is TjugadorS then
            DesplegarMensaje(i);
end;

procedure TcontrolMensajes.Tick;
var i:integer;
begin
for i:=0 to MAX_MENSAJES_MONSTRUOS do
  if fTimerMensaje[i]>0 then
    dec(fTimerMensaje[i]);
end;

// TControlChat **************************************
procedure TcontrolChat.Inicializar;
begin
  posLibre:=0;
  NroMensajesDesplegados:=0;
end;

procedure TcontrolChat.setMensajeLinea(Rmonstruo:TmonstruoS;const mensaje:string;color:Integer);
begin
  fTimerChat[posLibre]:=MAX_TIMER_CONTROL_CHAT;
  fmensajeImportante[posLibre]:=(color<>clBlanco);
  fcolorMensaje[posLibre]:=color;
  if Rmonstruo=nil then
    fmensaje[posLibre]:=mensaje
  else
    if Rmonstruo is TjugadorS then
      fmensaje[posLibre]:=TjugadorS(Rmonstruo).nombreAvatar+': '+mensaje
    else
      fmensaje[posLibre]:=MapaEspejo.NombreMonstruo(Rmonstruo,false)+': '+mensaje;
  inc(posLibre);
  posLibre:=posLibre mod NROMAX_MENSAJES_CHAT;//Ojo para buffer circular
  inc(NroMensajesDesplegados);
  if NroMensajesDesplegados>NROMAX_MENSAJES_CHAT then NroMensajesDesplegados:=NROMAX_MENSAJES_CHAT;
end;

procedure TcontrolChat.setMensaje(Rmonstruo:TmonstruoS;const mensaje:string;color:Integer);
var cad:string;
begin
  if Rmonstruo=nil then
  begin
    cad:=mensaje;
    while length(cad)>0 do
      setMensajeLinea(nil,TextoDDraw.ExtraerTexto(cad,ancho_DD-3),color);
  end
  else
    setMensajeLinea(Rmonstruo,mensaje,color);
end;

procedure TcontrolChat.draw;
var i,posicion,posDibujo:integer;
begin
  TextoDDraw.alineacionX:=AxIzquierda;
  posDibujo:=0;
  for i:=1 to NroMensajesDesplegados do
  begin
    posicion:=(NROMAX_MENSAJES_CHAT+posLibre-i) mod NROMAX_MENSAJES_CHAT;
    if fmensaje[posicion]<>'' then
    begin
      if (fTimerChat[posicion]>0) and ((conta_Universal and Desplazador_AniSincro)=0)  then
        dec(fTimerChat[posicion]);
      if (fmensajeImportante[posicion] and (fTimerChat[posicion]>0) and (posDibujo<=2))
        or Texto_Modalidad_Chat then
        with TextoDDraw do
        begin
          color:=fcolorMensaje[posicion];
          TextOut(2,mitad_ancho_dd-posDibujo*14,fmensaje[posicion]);
          inc(posDibujo);
        end;
    end;
  end;
end;
//  TControlFx  **************************************
constructor TControlfx.Create;
begin
  inherited Create;
  inicializar;
end;

procedure TControlfx.inicializar;
begin
  posLibre:=0;
  FillChar(fTipoAnimacion,sizeOf(fTipoAnimacion),FX_Desactivado);
end;

procedure TControlfx.SetEfecto(x,y:byte;TipoAnimacion:byte;frame:shortint;direccion:TdireccionMonstruo;monstruo:TmonstruoS);
begin
  fmonstruo[posLibre]:=monstruo;
  fCoord_fx_x[posLibre]:=x;
  fCoord_fx_y[posLibre]:=y;
  fdireccion[posLibre]:=direccion;
  fTipoAnimacion[posLibre]:=tipoAnimacion;
  fFrame[posLibre]:=frame;
  inc(posLibre);
  if posLibre>MAX_SPRITES_FX then posLibre:=0;
end;

procedure TControlfx.Draw(Centro_fx_X,Centro_fx_Y:integer;fx_x,fx_y:byte);
var posFXX,posFXY,x,y,i:integer;
    animacion:TAnimacionEfecto;
    posicion_fx_X,posicion_fx_Y:byte;
begin
  for i:=0 to MAX_SPRITES_FX do
    if fTipoAnimacion[i]<>FX_Desactivado then
    begin
      if fmonstruo[i]=nil then
      begin
        posicion_fx_X:=fcoord_fx_x[i];
        posicion_fx_Y:=fcoord_fx_y[i];
        posFXX:=posicion_fx_X*ancho_tile;
        posFXY:=posicion_fx_Y*alto_tile;
      end
      else
        with fmonstruo[i] do
        begin
          posicion_fx_X:=coordx;
          posicion_fx_Y:=coordy;
          posFXX:=coordx*ancho_tile+(coordx_ant-coordx)*Paso_InterpoladoX*control_movimiento;
          posFXY:=coordy*alto_tile+(coordy_ant-coordy)*Paso_InterpoladoY*control_movimiento;
        end;
      if (posicion_fx_Y=fx_y) and (abs(posicion_fx_X-fx_x)<MaxVisionX) and (fframe[i]>=0) then
        if (animas.animacion[fTipoAnimacion[i]] is TAnimacionEfecto) then
        begin
          animacion:=TAnimacionEfecto(animas.animacion[fTipoAnimacion[i]]);
          x:=centro_fx_x+posFXX;
          y:=centro_fx_y+posFXY;
          case fTipoAnimacion[i] of
            fxFuegoArtificial1:
            begin
              if fframe[i]=7 then//explota
              begin
                SonidoXY(snFuegoArtificial,posicion_fx_X-JugadorCl.coordX,posicion_fx_Y-JugadorCl.coordY);
                SetEfecto(posicion_fx_X,posicion_fx_Y,fxFuegoArtificial2,0,0,nil);
              end;
              animacion.drawXY(x,y-(fframe[i] shl 4)-40,fframe[i]);
            end;
            fxFuegoArtificial2:
              animacion.drawXY(x,y-152,fframe[i]);
            fxRayo:
              animacion.drawXY(x,y,(fdireccion[i] and $06)+(sincro_conta_Universal+i)and $1);
            fxSangre:if fmonstruo[i]<>nil then
              case InfMon[fmonstruo[i].tipoMonstruo].estiloMuerte of
                emSangreNegra:
                  animacion.drawXYEfecto(x,y,fframe[i],$000000,fxPlano);
                emSangreVerde:
                  animacion.drawXYEfecto(x,y,fframe[i],$5EC09F,fxColorido);
                emEnergiaDisipada:
                  animacion.drawXYEfecto(x,y,fframe[i],$3040E0,fxSumaSaturada);
              else
                animacion.drawXY(x,y,fframe[i])
              end;
          else
            animacion.drawXY(x,y,fframe[i])
          end;
        end;
    end;
end;

procedure TControlfx.Tick;
var i:integer;
begin
  if ((conta_Universal and Desplazador_AniSincro) = 0) then
    for i:=0 to MAX_SPRITES_FX do
      if fTipoAnimacion[i]<>FX_Desactivado then
      begin
        inc(fframe[i]);
        if fframe[i]>=8 then fTipoAnimacion[i]:=FX_Desactivado;
      end;
end;

function TJugador.apuntadoEnFormatoCasilla:word;
begin
  if apuntado=nil then
    result:=ccVac
  else
  begin
    result:=apuntado.codigo;
    if not (apuntado is TjugadorS) then result:=result or ccMon;
  end;
end;

function TJugador.DineroACadena:string;
begin
  if dinero>0 then
    result:='Tienes '+DineroAStr(dinero)
  else
    result:='No tienes ni una moneda de plata';
end;

function TJugador.PuedeUsar(const id_Artefacto:byte):boolean;
begin
  result:=not bytebool(infobj[id_Artefacto].ClasesNoPermitidas and mascarB[codCategoria]) and
  not bytebool(infobj[id_Artefacto].RazasNoPermitidas and mascarB[TipoMonstruo]) and (nivel>=infobj[id_Artefacto].nivelMinimo);
end;

function TJugador.MensajeAdvertenciaObjetoOfertaNoUsado:string;
var id_Artefacto:byte;
begin
  id_Artefacto:=objetoOferta.id;
  if bytebool(infobj[id_Artefacto].ClasesNoPermitidas and mascarB[codCategoria]) then
    result:=MensajeNegarUso(id_Artefacto,false)
  else
    if bytebool(infobj[id_Artefacto].RazasNoPermitidas and mascarB[TipoMonstruo]) then
      result:=MensajeNegarUso(id_Artefacto,true)
    else
      if nivel<infobj[id_Artefacto].nivelMinimo then
        result:=cmNecesitasNivel_+intastr(infobj[id_Artefacto].nivelMinimo)+cm_ParaUsar_+nombreCortoObjeto(objetoOferta)
      else
        result:='';
end;

function Tjugador.CalcularColorDeMana:integer;
var color1,color2:integer;
begin
  color1:=64+nivel shl 2;
  if color1>160 then color1:=160;
  color2:=128+nivel shl 3;
  if color2>255 then color2:=255;
  case codCategoria of
    ctMago,ctGuerreroMago:result:=(color2 shl 16) or (color1 shl 8);
    ctMontaraz,ctBardo:result:=color2 shl 8;
    ctClerigo,ctPaladin:result:=color2 or (color1 shl 8);
    else result:=0;
  end;
end;

function Tjugador.CalcularColorDeMeditacion:integer;
var color1,color2:integer;
begin
  if (codCategoria=ctMago) or (codCategoria=ctClerigo) then
    color2:=nivel shl 2
  else
    color2:=nivel shl 1;
  color1:=16+color2;
  if color1>160 then color1:=160;
  color2:=64+color2 shl 1;
  if color2>255 then color2:=255;
  case codCategoria of
    ctMago,ctGuerreroMago:result:=(color2 shl 16) or (color1 shl 8);
    ctMontaraz,ctBardo:result:=color2 shl 8;
    ctClerigo,ctPaladin:result:=color2 or (color1 shl 8);
    else result:=0;
  end;
end;

function Tjugador.PuedeLanzarConjuro:byte;
begin
  if not LongBool(Banderas and bnparalisis) then
    if hp<>0 then
      if maxMana>0 then //sólo mágicos
        if conjuroElegido<=31 then  //verificar limites
          if longbool(Conjuros and (1 shl ConjuroElegido)) then //verificar Hechizo en libro
            with InfConjuro[conjuroElegido] do
              if (nivel>=nivelJugador) then
                if (nivelMANA<=mana) or (Usando[uArmaIzq].id=ihVaritaLlena) then //Verificar maná
                  if (ByteBool(BanderasCnjr and cjPuedeLanzarAsimismo) and (apuntado=nil)) or
                      not ByteBool(BanderasCnjr and cjPuedeLanzarObjetivo) then
                    result:=i_Ok
                  else
                  begin
                    result:=byte(MonstruoApuntadoIncorrecto);
                    if result=i_Ok then
                      if (apuntado is TjugadorS) then
                      begin
                        if longbool(apuntado.banderas and bnFantasma) and (conjuroElegido<>CD_CONJURO_RESUCITAR) then
                          result:=i_ConjuroSobreAvatarMuerto
                      end
                      else
                        if ByteBool(BanderasCnjr and cjSoloJugadores) then
                          result:=i_conjuroParaJugadores
                        else
                          if apuntado.comportamiento>=comComerciante then
                            result:=i_ConjuroSobreNPCProtegido
                  end
                else
                  result:=i_NoTienesSuficienteMana
              else
                result:=i_NoTienesSuficienteNivel
          else
            result:=i_NoConocesElConjuro
        else
          result:=i_Error
      else
        result:=i_NoPuedesHacerMagia
    else
      result:=i_EstasMuerto
  else
    result:=i_EstasParalizado;
end;

procedure TJugador.CambiarAnimacionJugador(NuevoCodAnime:byte);
begin
  codAnime:=NuevoCodAnime;
  banderas:=banderas or bnFantasma;
  if hp<>0 then banderas:=banderas xor bnFantasma;
end;

function Tjugador.TieneLugarVacio(objeto:Tartefacto;cantidad:byte):bytebool;
var i:integer;
    objetoT1,objetoT2:Tartefacto;
begin
  result:=true;
  for i:=0 to MAX_ARTEFACTOS do
    if (Artefacto[i].id<4) then exit;
  if FijarNumeroElementos(objeto,cantidad) then
    for i:=0 to MAX_ARTEFACTOS do
      if (Artefacto[i].id=objeto.id) then
      begin
        objetoT1:=objeto;
        objetoT2:=Artefacto[i];
        if AgregarObjetoAObjeto(objetoT1,objetoT2)=MOVIO_TODO_A_DESTINO then
          exit;
      end;
  result:=false;
end;

procedure Tjugador.ElegirElPrimerConjuroDisponible;
var i:integer;
begin
  for i:=0 to 31 do
    if (Conjuros and (1 shl i))<>0 then
    begin
      ConjuroElegido:=i;
      exit;
    end;
end;

function Tjugador.DescribirParty:string;
//Nota solo llamar si se ha actualizado desde el servidor la lista de camaradas del party.
//Caso contrario no listar los nombres de jugadores que esten en otros mapas.
var i,total:integer;
    cantidad:array[0..MAX_INDICE_PARTY] of byte;
  function porcentaje(valor:integer):string;
  begin
    result:=' '+intastr(valor*100 div total)+'%';
  end;
begin
  result:='';
  total:=nivel;
  for i:=0 to MAX_INDICE_PARTY do
  begin
    cantidad[i]:=0;
    if (camaradasParty[i]<=maxJugadores) then
      if (Jugador[camaradasParty[i]].codMapa=codMapa) then
      begin
        cantidad[i]:=Jugador[camaradasParty[i]].nivel;
        inc(total,cantidad[i]);
      end
  end;
  for i:=0 to MAX_INDICE_PARTY do
    if camaradasParty[i]<=maxJugadores then
      with Jugador[camaradasParty[i]] do
        result:=result+nombreAvatar+porcentaje(cantidad[i])+', ';
  if result<>'' then
    result:=result+nombreAvatar+porcentaje(nivel);
end;

function AgregarSufijoSexuadoA(const nombre:string):string;
var pscn:byte;
begin
  result:='';
  if length(nombre)<1 then exit;
  pscn:=pos(' ',nombre);
  if pscn=0 then//una palabra
    pscn:=length(nombre)
  else//letra antes del espacio
    dec(pscn);
  if pscn>0 then
    if Upcase(nombre[pscn])='A' then result:=result+'a';
  result:=result+' '+nombre;
end;

function AgregarSufijoAsexuadoS(const nombre:string):string;
//devuelve nombre con prefijo un o una si termina en 'a'.
var pscn:byte;
begin
  result:='';
  if length(nombre)<1 then exit;
  pscn:=pos(' ',nombre);
  if pscn=0 then//una palabra
    pscn:=length(nombre)
  else//letra antes del espacio
    dec(pscn);
  if pscn>0 then
    if Upcase(nombre[pscn])='S' then result:=result+'s';
  result:=result+' '+nombre;
end;

end.

