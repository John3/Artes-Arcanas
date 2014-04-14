(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit LectorWAV;
(*
Autor: Ing. Sergio A. Chávez R.
La clase TlectorWav permite leer un archivo .WAV PCM en un buffer para directSound.
Pasos para usarlo:
 1.- Crear el objeto TlectorWav indicando el nombre del archivo ".WAV".
 2.- Verificar la propiedad ".preparado" de TlectorWav, falso=>cancelar , error al leer el archivo.
 3.- Preparar el descriptor de buffer para directsound usando ".TamannoDatos" y ".formatoOnda" de TlectorWav;
 4.- Crear el buffer de sonido directsound con el descriptor de buffer preparado.
 5.- Usar el procedimiento "lock" del buffer de sonido directsound creado para obtener la referencia al buffer y su tamaño.
 6.- Llamar al método ".Leer" de TlectorWav indicando la posición inicial del buffer y el tamaño del buffer.
*)
interface

uses mmsystem;//Para el TWaveFormatEx, para usar con directSound.

type
  TWavTag=array[0..3] of char;
  TErrorWavSound=integer;

const
  //Errores:
  WV_Ok=0;
  WV_EncabezadoIncorrecto=1;
  //Constantes auxiliares
  MaxTammanoBuffer=32768;
  smTelefono:integer=11025;
  smRadio:integer=22050;
  smCD:longword=44100;
  chMono:word=1;
  chStereo:word=2;
  rsRadio:word=8;
  rsCD:word=16;
  Inicio_Area_Datos=44;
  tgRIFF:TWavTag=('R','I','F','F');
  tgWAVE:TWavTag=('W','A','V','E');
  tgfmt:TWavTag=('f','m','t',' ');
  tgdata:TWavTag=('d','a','t','a');
(*
Control de tamaño de archivo. Es totalmente opcional pero es recomendable no
crear buffers demasiado grandes fraccionandolos en varios de menor tamaño.
*)
  MaximoAceptable=1048576;//Máximo archivos de 1MB
  //Tags Para formato PCM
  PCMversion1:integer=$10;
  PCMversion2:word=$1;

type
  TlectorWav=class(TObject)
  private
    Tamanno_Datos:integer;
    formato:TWaveFormatEx;
    fabierto:bytebool;
    archivo:file;
  public
    destructor destroy; override;
    property TamannoDatos:Integer read Tamanno_Datos;
    property BitsPorMuestra:word read formato.wbitspersample;
    property Canales:word read formato.nchannels;
    property Muestras:longword read formato.nSamplesPerSec;
    property FormatoOnda:TWaveFormatEx read formato;
    property Preparado:bytebool read fabierto;
    constructor create(const FileName:string);
    function Leer(var Buffer; Longitud:integer):boolean;
  end;

implementation

constructor TlectorWav.create(const FileName:string);
  function LeerEncabezado:TErrorWavSound;
  var tag:TWavTag;
      ver1,Bytes_Por_Segundo,Tamanno_Total:integer;
      ver2,Bytes_Por_Muestra:word;
  begin
    result:=WV_EncabezadoIncorrecto;
    BlockRead(Archivo,tag,4);
    if tag<>tgRIFF then exit;
    BlockRead(Archivo,Tamanno_Total,4);
    if Tamanno_Total>MaximoAceptable then exit;
    BlockRead(Archivo,tag,4);
    if tag<>tgWAVe then exit;
    BlockRead(Archivo,tag,4);
    if tag<>tgfmt then exit;
    BlockRead(Archivo,ver1,4);
    if ver1<>PCMversion1 then exit;
    BlockRead(Archivo,ver2,2);
    if ver2<>PCMversion2 then exit;
    BlockRead(Archivo,formato.nchannels,2);
    if formato.nchannels>2 then exit;
    BlockRead(Archivo,formato.nsamplespersec,4);
    if formato.nsamplespersec>smCD then exit;
    BlockRead(Archivo,Bytes_Por_Segundo,4);
    BlockRead(Archivo,Bytes_Por_Muestra,2);
    BlockRead(Archivo,formato.wbitspersample,2);
    if formato.wbitspersample>rsCD then exit;
    BlockRead(Archivo,tag,4);
    if tag<>tgdata then exit;
    BlockRead(Archivo,Tamanno_Datos,4);
    if Tamanno_Datos>Tamanno_Total then exit;
    //Formato:
    with Formato do
    begin
      wFormatTag:=Wave_Format_PCM;
      nblockalign:=(nchannels*wbitspersample) div 8;
      nAvgBytesPerSec:=nsamplespersec*nblockalign;
      cbSize:=0;
    end;
    result:=WV_Ok
  end;
begin
  inherited create;
  fabierto:=false;
  assignfile(Archivo,FileName);
  FileMode:=0;
  reset(Archivo,1);
  if LeerEncabezado=WV_Ok then
    fabierto:=true
  else
    CloseFile(Archivo);
end;

function TlectorWav.Leer(var Buffer; Longitud:integer):boolean;
var tama,leido,totalleido,posActual:integer;
    referenciaDatos:pointer;
begin
  if fabierto then
  begin
    posActual:=filepos(archivo);
    totalleido:=0;
    referenciaDatos:=@Buffer;
    while totalleido<longitud do
    begin
      if longitud-totalleido<MaxTammanoBuffer then
        tama:=longitud-totalleido
      else
        tama:=MaxTammanoBuffer;
      blockread(archivo,referenciaDatos^,tama,leido);
      inc(integer(referenciaDatos),leido);
      inc(totalleido,leido);
      if (tama<>leido) then
        break;
    end;
    seek(archivo,posActual);
    result:=longitud=totalleido;
  end
  else
    result:=false;
end;

destructor TlectorWav.destroy;
begin
  if fabierto then
    CloseFile(Archivo);
  inherited destroy;
end;

end.

