(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit sonidos;
interface
uses
  windows,DirectSound,InterfazDS;

const
  MAX_SONIDOS=52;
  MAX_SONIDOS_AMBIENTE=18;

  //Sonidos
  snNinguno=255;
  snAmbienteNocturno=254;
  snAmbienteDiurno=253;
  snTrueno=252;
  snAmbienteMazmorra=251;
  snAmbienteDesiertoNocturno=250;
  snAmbienteDesiertoDiurno=249;
  snAmbienteHielos=248;
  snAmbienteInterior=247;



  snMagiaBoom=4;
  snComer=5;
  snGolpeGarraEnCarne=6;
  snGolpeEspadaEnCarne=52;
  snGolpeEspadaEnArmadura=7;
  snGolpeGarraEnArmadura=51;
  snGolpeFlechaEnCarne=8;
  snGolpeFlechaEnArmadura=50;
  snGolpeContundente=39;
  snMagiaCorto=9;
  snGolpeFallado=10;
  snArco=11;
  snMinar=12;
  snPescar=13;
  snTalar=14;
  snCarpintero=15;
  snHerrero=16;
  snFundir=17;
  snCuracion=18;
  snTijeras=19;
  snMuerteH=20;
  snMuerteM=21;
  snArcabuz=22;
  snFlauta=23;
  snLaud=24;
  snMeteoro=25;
  snTormenta=26;
  snCampana=27;
  snAfilar=28;
  snMaldicion=29;
  snTermina=30;
  snCuerno=31;
  snMagiaHada=32;
  snLijar=33;
  snCavar=34;
  snPrepararPocima=35;
  snCurtir=36;
  snAceitar=37;//goteo de aceite
  snError=38;//Mensaje de error
  snArmaArmaduraDestrozada=40;
  snLluvia=41;
  snRayoPsitico=42;
  snAtaquePsitico=43;
  snMuerteMonstruo=44;
  snHielo=45;
  snCerrarPuerta=46;
  snAbrirPuerta=47;
  snPorticullis=48;
  snPalanca=49;


  //----------------------------
  //    ALIAS DE SONIDOS
  //----------------------------
  snFabricarTela=snLijar;
  snRealizarVendar=snLijar;
  snOcultarse=snLijar;

  snEcharVeneno=snCurtir;
  snCoser=snTijeras;

  snVaritaMagica=snMagiaCorto;
  snBuscarIngrediente=snCavar;
  snBeber=snComer;
  snTallarGemas=snMinar;
  snMartillarReparar=snHerrero;
  snAlquimia=snPrepararPocima;
  snEscribirMagia=snMagiaHada;
  snLeerPergamino=snMagiaCorto;
  snEnvenenarFlechas=snAceitar;
  snSubioNivel=snMagiaHada;
  snClan=snCuerno;
  snFuegoArtificial=snArcabuz;
  snPrepararTrampa=snCavar;
  snLeerTomoDeLaExperiencia=snMagiaHada;
  snResucitar=snCampana;

  function FijarVolumenMidi(Porcentaje:integer):boolean;
  function crearSonidos(HWNDventana:HWND;const Directorio:string;StereoInverso:bytebool):bytebool;
  procedure DetenerSonidos;
  procedure liberarSonidos;
  procedure Sonido(Tipo:integer);
  procedure SonidoIntensidad(Tipo,Intensidad:integer);
  procedure SonidoAmbiental(Tipo:integer;Intensidad:byte);
  procedure SonidoXY(Tipo,deltaX,deltaY:integer);
  //Tipo: lowWord = tipo de sonido, highWord = copia preferida
  procedure SonidoPasosXY(Tipo,deltaX,deltaY:integer);

var
  Emitir_Sonidos,DirectSound_Funcionando:boolean;

implementation
uses mmSystem;
const
  CS_FLAGS_PLAY=0;//DSBPLAY_TERMINATEBY_TIME;
var
  sonidoDS:array[0..MAX_SONIDOS] of TGrupoSonidos;
  sonidoDS_a:array[0..MAX_SONIDOS_AMBIENTE] of TGrupoSonidos;
  FactorDePaneo:integer;

function intastr(valor:integer):string;
begin
  str(valor,result);
end;

function VolumenMidi(Volumen_Midi_L,Volumen_Midi_R:integer):boolean;
var NroDispositivos,i:integer;
    {MidiOutPutDev:string;
    MidiOutputDevid,amt,t:integer;
    MidiCap:TMIDIOUTCAPS;}
begin
{  with TRegistry.Create do
  begin
    RootKey := HKEY_CURRENT_USER;
    OpenKey('Software\Microsoft\Windows\CurrentVersion\Multimedia\MIDIMap', false);
    if ValueExists('CurrentInstrument') then
      MidiOutPutDev:=ReadString('CurrentInstrument')
    else
      MidiOutPutDev:='';
    free;
  end;
  amt := MidiOutGetNumDevs;
  MidiOutputDevid := - 1;
  for t := 0 to amt-1 do
  begin
    MidiOutGetDevCaps(t, @Midicap, Sizeof(Midicap));
    if StrPas(@MidiCap.szPName)= MidiOutPutDev then
      MidiOutputDevid := t;
  end;
  result:=midiOutSetVolume(MidiOutputDevid, (VOLUMEN_MIDI_R shl 16) + VOLUMEN_MIDI_L)=MMSYSERR_NOERROR;
  }
  result:=false;
  try
    NroDispositivos:=MidiOutGetNumDevs;
    for i := 0 to NroDispositivos-1 do
      result:=result or (midiOutSetVolume(i, (VOLUMEN_MIDI_R shl 16) + VOLUMEN_MIDI_L)=MMSYSERR_NOERROR);
  except
  end;
end;

function FijarVolumenMidi(Porcentaje:integer):boolean;
begin
  if porcentaje<1 then
    Porcentaje:=0
  else
    if porcentaje>=100 then
      Porcentaje:=65535
    else
      Porcentaje:=Porcentaje*640;
  result:=VolumenMidi(Porcentaje,Porcentaje);
end;

function crearSonidos(HWNDventana:HWND;const Directorio:string;StereoInverso:bytebool):bytebool;
var i,nroCopias:integer;
begin
  result:=false;
  if StereoInverso then FactorDePaneo:=-1 else FactorDePaneo:=1;
  DirectSound_Funcionando:=InterfazDS.InicializarDSound(HWNDventana,Directorio,msStereo,ms10KH,ms16bit)=DS_OK;
  if DirectSound_Funcionando then
  try
    nroCopias:=3;
    for i:=0 to 3 do
      CrearBufferSonido(sonidoDS[i],intastr(i),nroCopias,i<>0);
    for i:=4 to MAX_SONIDOS do
    begin
      case i of
        4,6..11,18,22,25,26,29,32,39,42,43,50..52:nroCopias:=2;
        5,17,20,21,30,31,38,40,34,44,45:nroCopias:=1;
        else nroCopias:=0;
      end;
      CrearBufferSonido(sonidoDS[i],intastr(i),nroCopias,false);
    end;
    for i:=0 to MAX_SONIDOS_AMBIENTE do
      CrearBufferSonido(sonidoDS_a[i],'a'+intastr(i),0,false);
    result:=true;
  except
  end;
end;

procedure liberarSonidos;
var i,j:integer;
begin
  if DirectSound_Funcionando then
  begin
    for i:=MAX_SONIDOS downto 0 do
      for j:=MAXCOPIAS_BUFFERS_SONIDOS downto 0 do
        SonidoDS[i,j]:=nil;
    for i:=MAX_SONIDOS_AMBIENTE downto 0 do
      for j:=MAXCOPIAS_BUFFERS_SONIDOS downto 0 do
        SonidoDS_a[i,j]:=nil;
    InterfazDS.FinalizarDSound;
  end;
end;

//Tipo: lowWord=tipo de sonido, highWord=copia preferida
function EmitirSonido(Tipo,intensidad,nivelPaneo:integer):boolean;
var i,copiaPreferida:integer;
  function ReproducirSonido(buffer:IDirectSoundBuffer):boolean;
  var statusBuffer:longword;
  begin
    result:=false;
    if buffer=nil then exit;//Sin objeto
    buffer.GetStatus(statusBuffer);
    if (statusBuffer and DSBSTATUS_PLAYING)<>0 then exit;//objeto ocupado
    buffer.SetVolume(intensidad);
    buffer.SetPan(nivelpaneo*FactorDePaneo);
    buffer.Play(0,0,CS_FLAGS_PLAY);
    result:=true;
  end;
begin
  //definir el sonido preferido:
  copiaPreferida:=(tipo shr 16);
  tipo:=tipo and $FFFF;
  result:=true;
  if (copiaPreferida>0) and (copiaPreferida<=MAXCOPIAS_BUFFERS_SONIDOS) then
    if ReproducirSonido(sonidoDS[tipo,copiaPreferida]) then exit;
  for i:=0 to MAXCOPIAS_BUFFERS_SONIDOS do
    if ReproducirSonido(sonidoDS[tipo,i]) then exit;
  result:=false;
end;

procedure SonidoAmbiental(Tipo:integer;Intensidad:byte);
var IntensidadDS:integer;
begin
  if Emitir_Sonidos and (intensidad>0) then
  begin
    case Tipo of
      snLluvia:if sonidoDS[tipo,0]<>nil then
      with sonidoDS[tipo,0] do
      begin
        IntensidadDS:=(255-intensidad)shl 4;
        if IntensidadDS<1024 then IntensidadDS:=1024;
        SetVolume(-intensidadDS);
        Play(0,0,DSBPLAY_LOOPING);
      end;
    end
  end
  else
    if DirectSound_Funcionando then
      case Tipo of
        snLluvia:if sonidoDS[tipo,0]<>nil then sonidoDS[tipo,0].stop
      end
end;

procedure DetenerSonidos;
begin
  if DirectSound_Funcionando then
  begin
  //Aqui solo detener los sonidos que sabemos que serán usados con la modalidad
  //de looping o extremadamente largos.
    if sonidoDS[snLluvia,0]<>nil then
      SonidoDS[snLluvia,0].stop;
  end;
end;

procedure SonidoPasosXY(Tipo,deltaX,deltaY:integer);
var intensidad:integer;
begin
  if not Emitir_Sonidos then exit;
  deltay:=round(sqrt(sqr(deltaX)+sqr(deltay)));
  if deltay>16 then exit;
  intensidad:=-(1200+deltaY*64);
  EmitirSonido(tipo,intensidad,deltaX*176{nivelPaneo});
end;


procedure SonidoXY(Tipo,deltaX,deltaY:integer);
var intensidad,nivelpaneo:integer;
begin
  if not Emitir_Sonidos then exit;
  deltay:=round(sqrt(sqr(deltaX)+sqr(deltay)));
  if deltay>16 then exit;
  intensidad:=-deltaY*70;
  nivelPaneo:=deltaX*176;
  EmitirSonido(tipo,intensidad,nivelPaneo);
end;

procedure SonidoIntensidad(Tipo,Intensidad:integer);
begin
  if Emitir_Sonidos then
    if (Tipo>=0) and (Tipo<=MAX_SONIDOS) then
      EmitirSonido(tipo,intensidad,0);
end;

procedure Sonido(Tipo:integer);
const CS_MAX_ATENUACION=2000;
      CS_MAX_PAN=1250;
      CS_RANDOM_PAN=CS_MAX_PAN*2;
  procedure SonidoAmbientalPosicionAlAzar(subTipo:integer;paneoExtremo:boolean);
  begin
    if sonidoDS_a[subTipo,0]<>nil then
      with sonidoDS_a[subTipo,0] do
      begin
        if paneoExtremo then
        begin
          SetVolume(-random(700));
          SetPan((1400-random(2800))*FactorDePaneo);
        end
        else
        begin
          SetVolume(-random(CS_MAX_ATENUACION));
          SetPan((CS_MAX_PAN-random(CS_RANDOM_PAN))*FactorDePaneo);
        end;
        Play(0,0,CS_FLAGS_PLAY);
      end;
  end;
begin
  if (Emitir_Sonidos) then
  case Tipo of
    0..MAX_SONIDOS:
      EmitirSonido(tipo,0,0);
    //ambientales
    snTrueno:
      SonidoAmbientalPosicionAlAzar(18,true);
    snAmbienteDiurno:
      SonidoAmbientalPosicionAlAzar(random(8),false);
    snAmbienteNocturno:
      SonidoAmbientalPosicionAlAzar(random(7)+5,false);
    snAmbienteMazmorra:
      SonidoAmbientalPosicionAlAzar(15+random(3),false);
    snAmbienteDesiertoNocturno:
      SonidoAmbientalPosicionAlAzar(random(6)+6,false);
    snAmbienteDesiertoDiurno:
      SonidoAmbientalPosicionAlAzar(random(3)+12,false);
    snAmbienteHielos:
      SonidoAmbientalPosicionAlAzar(random(3)+12,false);
    snAmbienteInterior://TODO: Agregar sonidos para el interior de castillos;
  end;
end;

end.

