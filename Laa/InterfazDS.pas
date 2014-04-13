(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit InterfazDS;
interface

uses Windows,DirectSound,MMSystem;
const MAXCOPIAS_BUFFERS_SONIDOS=3;

type TdsmCanales=(msCStd,msMono,msStereo);
     TdsmMuestreo=(msMStd,ms5kh,ms10kh,ms20kh);
     TdsmResolucion=(msRStd,ms8bit,ms16bit);
     TGrupoSonidos=array[0..MAXCOPIAS_BUFFERS_SONIDOS] of IDirectSoundBuffer;
//Notas en volumen y paneo:
{
volumen: [-10000..0] (mudo a full volumen)
paneo:   [-10000..10000]  (de izquierda(full a -10000, mudo a 10000) a derecha, 0=normal)

Métodos de IDirectSoundBuffer:
        function GetVolume(var lplVolume: integer) : HResult; stdcall;
        function SetVolume(lVolume: integer) : HResult; stdcall;
        function GetPan(var lplPan: integer) : HResult; stdcall;
        function SetPan(lPan: integer) : HResult; stdcall;
        function Play(dwReserved1,dwReserved2,dwFlags: DWORD) : HResult; stdcall;
        //dwFlags: DSBPLAY_LOOPING = Repetir indefinidamente.
        function Stop: HResult; stdcall;
}
function InicializarDSound(HWNDventana:HWND;DirectorioArchivos:string;canales:TdsmCanales;Muestreo:TdsmMuestreo;Resolucion:TdsmResolucion):Hresult;
function CrearBufferSonido(var GrupoBufferSonido:TGrupoSonidos;const nombre:String;NumeroCopias:byte;leerVariantes:boolean):hresult;
procedure FinalizarDSound;

implementation
uses LectorWav;

var
  ObjetoDirectSound:IDirectSound;
  BufferSonidoPrimario:IDirectSoundBuffer;
  FormatoEstandar:TwaveformatEx;
  CarpetaDeSonidos:string;

function InicializarDSound(HWNDventana:HWND;DirectorioArchivos:string;canales:TdsmCanales;Muestreo:TdsmMuestreo;Resolucion:TdsmResolucion):Hresult;
const
  PrimaryDesc: TDSBufferDesc = (
      dwSize: SizeOf (PrimaryDesc);
      dwFlags: DSBCAPS_PRIMARYBUFFER{ or DSBCAPS_STICKYFOCUS});
begin
  CarpetaDeSonidos:=DirectorioArchivos;
  result:=DirectSoundCreate(nil, ObjetoDirectSound, nil);
  if result=ds_ok then
  begin
//    result:=ObjetoDirectSound.SetCooperativeLevel(HWNDventana,DSSCL_EXCLUSIVE);
    result:=ObjetoDirectSound.SetCooperativeLevel(HWNDventana,DSSCL_NORMAL);
    if result=ds_ok then
    begin
      //Buffer primario:
      result:=ObjetoDirectSound.CreateSoundBuffer(PrimaryDesc,BufferSonidoPrimario,nil);
      if result=ds_ok then
      begin
        FillChar(FormatoEstandar,sizeof(TwaveformatEx),0);
        with FormatoEstandar do
        begin
          wFormatTag:=Wave_Format_PCM;
          case canales of
            msMono:nchannels:=1;
          else
            nchannels:=2;
          end;
          case muestreo of
            ms5kh:nsamplespersec:=11025;
            ms20kh:nsamplespersec:=44100;
          else
            nsamplespersec:=22050;
          end;
          case resolucion of
            ms16bit:wbitspersample:=16;
          else
            wbitspersample:=8;
          end;
          nblockalign:=(nchannels*wbitspersample) shr 3;//div 8
          nAvgBytesPerSec:=nsamplespersec*nblockalign;
          cbSize:=0;
        end;
        BufferSonidoPrimario.SetFormat(FormatoEstandar);
      end;
    end;
  end;
end;

procedure FinalizarDSound;
begin
  BufferSonidoPrimario:=nil;
  ObjetoDirectSound:=nil;
end;

function CrearBufferSonido(var GrupoBufferSonido:TGrupoSonidos;
  const nombre:String; NumeroCopias:byte; leerVariantes:boolean):hresult;
//estático=true => Si no se desea variar el volumen o paneo de este sonido.
var
  Audio: PByte;
  Junk: Pointer;
  NumBytesLocked: DWORD;
  JunkBytes: DWORD;
  ArchivoWav:TlectorWav;
  BufDesc: TDSBufferDesc;
  i,j,nroArchivosAdicionales:integer;
  nombreArchivo: string;
begin
  //Inicializar buffers en nil
  for i:=0 to MAXCOPIAS_BUFFERS_SONIDOS do
    GrupoBufferSonido[i]:=nil;//Seguridad, si es nil no fue creado.
  //Evitar pasar del máximo permitido de copias por sonido
  if NumeroCopias>MAXCOPIAS_BUFFERS_SONIDOS then
    NumeroCopias:=MAXCOPIAS_BUFFERS_SONIDOS;

  if leerVariantes then
  begin
    nroArchivosAdicionales:=NumeroCopias;//adicionales al primario
    NumeroCopias:=0;
  end
  else
    nroArchivosAdicionales:=0;

  result:=DS_OK;
  for j:=0 to nroArchivosAdicionales do
  begin
    if j>0 then
      nombreArchivo:=CarpetaDeSonidos+nombre+'-'+char(j+64)
    else
      nombreArchivo:=CarpetaDeSonidos+nombre;
    //Crear objeto para leer el wav
    ArchivoWav:=TlectorWav.create(nombreArchivo+'.wav');
    if ArchivoWav.preparado then
    begin
      //Definir las características del nuevo buffer de sonido
      Fillchar(BufDesc, SizeOf(TDSBufferDesc), 0);
      with BufDesc do
      begin
        dwSize := SizeOf(TDSBufferDesc);
      //DSBCAPS_STATIC = Si el sonido no variará en volumen y paneo.
      //DSBCAPS_LOCHARDWARE = para obligar a usar memoria del hardware.
       {if estatico then
          dwFlags := DSBCAPS_STATIC
        else}
          dwFlags := DSBCAPS_CTRLPAN or DSBCAPS_CTRLVOLUME or DSBCAPS_STICKYFOCUS;
        dwBufferBytes := ArchivoWav.TamannoDatos;
        lpwfxFormat :=@ArchivoWav.formatoOnda;
      end;
      //Crear el buffer de sonido
      result:=DSERR_GENERIC;
      for i:=j to j+NumeroCopias do
      begin
        if i>MAXCOPIAS_BUFFERS_SONIDOS then exit;
        result:=ObjetoDirectSound.CreateSoundBuffer(BufDesc, GrupoBufferSonido[i], nil);
        //Copiar los datos del archivo al buffer de sonido
        if result=DS_Ok then
        begin
          if GrupoBufferSonido[i].Lock(0, 0, Pointer(Audio), NumBytesLocked, Junk,
            JunkBytes, DSBLOCK_ENTIREBUFFER)=ds_ok then
          begin
            ArchivoWav.Leer(Audio^,NumBytesLocked);
            GrupoBufferSonido[i].Unlock(Audio, NumBytesLocked, nil, 0);
          end;
          GrupoBufferSonido[i].SetFormat(FormatoEstandar);
        end;
      end;
    end
    else
      result:=DSERR_BADFORMAT;
    //Eliminar el objeto que abrio y leyo los datos del wav
    ArchivoWav.free;
  end;
end;

end.

