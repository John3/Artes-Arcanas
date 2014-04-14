(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

//Módulo libre de bibliotecas externas al juego
unit Globales;
//{$DEFINE CONTROL_EJECUTABLE}
interface
uses Objetos,demonios;
const
//Generales
// NOTA: un mensaje codificado demasiado largo es causa de error
  PUERTO_COMUNICACION=31715;
  CREADO_POR='Sergio A. Chávez R.';
  IDENTIFICADOR_EJECUTABLE:integer=$76543210;
  M_FaltanArchivosDelJuego='Faltan archivos del juego';
  M_EjecutableDannado='¡Ejecutable Dañado!';
//  CaracteresNoPermitidos:set of char=[#0..#31,',','.','\','/',':','*','?','"','<','>','|','(',')',#127];
  CaracteresPermitidos:set of char=['a'..'z','A'..'Z','0'..'9',#32,'-','_','''',#159,#192..#214,#216..#246,#248..#255];
  MIN_PUERTO_COMUNICACION=21;
  MAX_PUERTO_COMUNICACION=32767;
  //Opciones del servidor, Flags (4)
  FS_ModoDePruebas=$80;
  FS_ComunicacionTotal=$40;
  CARPETA_AVATARES='avatares\';
  EXT_ARCH_AVATARES='.avt';
  //OJO REVISAR SIEMPRE ESTO!!!
  TAMANNO_DE_INSTANCIA_DE_TJUGADORS=252;//no debe ser diferente a 252 o perdemos todos los personajes
  TAMANNO_DE_INSTANCIA_DE_TCLANJUGADORES=64;//SIEMPRE REVISAR AL CAMBIAR TCLANJUGADORES!!!

type
// Sincronizar con
// TFxAmbiental=(FxANinguno,fxLluvia,fxNieve,fxNiebla,fxEventoMagico1,fxEventoMagico2,FxNoche,FxNocheLluvia);
  TClimaAmbiental=(CL_NORMAL,CL_LLUVIOSO,CL_NIEVE,CL_BRUMA,CL_MAGICO1,CL_MAGICO2,CL_NOCHE,CL_LLUVIA_NOCHE);
  TPersonaje=array[0..TAMANNO_DE_INSTANCIA_DE_TJUGADORS-1] of byte;
  TUsuario=record
    ControlDeSuma:integer;//control anti tramposos.
    Personaje:TPersonaje;
    Datos:TDatosUsuario;
  end;

  function PareceIP(const cadena:string):boolean;
  function EmpaquetarPassword(const cad,identificador:string):TPassword;
  function PasswordAStr(const Login:Tpassword):string;
  function ObtenerLoginDeCadena(const cadena:string):TCadenaLogin;
  function QuitarCaracteresNoPermitidos(const cadena:string):string;
//de cadena encriptada a TPassword y viceversa
  function ControlParametroEntero(const cadena:string;LimInf,LimSup:integer;var numero:integer):boolean;
  function EscribirCuenta(const DatosUsuario:TDatosUsuario;const Carpeta:string;Jugador:TjugadorS):boolean;

  function Criptico(var datos;Lngtd:integer):integer;
  function DeCriptico(var datos;Lngtd:integer):integer;
  function EjecutableCorrompido(const nombre:string):boolean;
  function IPAutorizado(const IP:integer):boolean;
  function ObtenerAutentificacion(NroAleatorioServidor:integer):integer;
  function AutentificacionCorrecta(Codigo_Autenticacion,NroAleatorioServidor:integer):boolean;
  function PendienteDeClima(tipoClima:byte):integer;

var
  semilla_aleatoria:longint;
  ID_ATOM_SOLO_UNA_INSTANCIA:word;
  EJECUTABLE_INTEGRO:Boolean;

implementation

//------------------------------------------------------------------------------
//  UTILITARIOS DE ENCRIPTACION
//------------------------------------------------------------------------------
Const
{Es importante que cambien estos numeros. Mejor si 1 y 2 son primos.}
      OCValor1=3712237;
      OCValor2=1711417;
      OCValor3=13741;
      OCValor4=3;
      OCValor5=113723;

function aleatorio(i:integer):integer;
var t:double;
begin
  t:=(semilla_aleatoria*OCValor1+sqr(semilla_aleatoria)*OCValor2) mod OCValor3;
  semilla_aleatoria:=trunc(t);
  result:=trunc(abs(t/OCValor3)*i);
end;

const Constante_Semilla:longword=$1c47e971;
      Constante_Cadena:byte=$4e;
      Constante_Comprobacion:longword=$a25ef017;

function Criptico(var datos;Lngtd:integer):integer;
var pun:pointer;
    limite,desplazador:integer;
    anterior:byte;
begin
     semilla_aleatoria:=Constante_Semilla;
     anterior:=Constante_Cadena;
     result:=Constante_Comprobacion;
     pun:=@datos;
     limite:=integer(pun)+Lngtd;
     desplazador:=0;
     while integer(pun)<limite do
     begin
       byte(pun^):=byte(pun^) xor anterior xor aleatorio(256);
       anterior:=byte(pun^);
       // el $18 es para que desplace a 0,8 , 16 y 24
       result:=result xor (anterior shl (desplazador and $18));
       inc(desplazador);
       inc(integer(pun));
     end;
end;

function DeCriptico(var datos;Lngtd:integer):integer;
var pun:pointer;
    limite,desplazador:integer;
    anterior,coder:byte;
begin
     semilla_aleatoria:=Constante_Semilla;
     anterior:=Constante_Cadena;
     result:=Constante_Comprobacion;
     pun:=@datos;
     limite:=integer(pun)+Lngtd;
     desplazador:=0;
     while integer(pun)<limite do
     begin
       coder:=byte(pun^);
       result:=result xor (coder shl (desplazador and $18));
       byte(pun^):=byte(pun^) xor anterior xor aleatorio(256);
       anterior:=coder;
       inc(desplazador);
       inc(integer(pun));
     end;
end;

function ControlParametroEntero(const cadena:string;LimInf,LimSup:integer;var numero:integer):boolean;
var code:integer;
begin
  val(cadena,numero,code);
  result:=(code=0) and (Numero>=LimInf) and (Numero<=LimSup);
end;

function ObtenerLoginDeCadena(const cadena:string):TCadenaLogin;
var i,inicio,longitud:integer;
    ncar:char;
begin
  result:='';
  inicio:=1;
  longitud:=length(cadena);
  if (longitud=0) then exit;
  //no procesar espacios iniciales
  while (cadena[inicio]=#32) and (inicio<longitud) do inc(inicio);
  //no procesar espacios finales
  while (cadena[longitud]=#32) and (longitud>1) do dec(longitud);
  if (longitud-inicio)<2 then exit;
  //filtrar caracteres
  for i:=inicio to longitud do
    if (cadena[i] in caracteresPermitidos) then
    begin
      case cadena[i] of
        'a'..'z':ncar:=upcase(cadena[i]);
        'A'..'Z','0'..'9':ncar:=cadena[i];
        'Á','À','Ä','Â','á','à','ä','â','Å','å','Ã','ã':ncar:='A';
        'É','È','Ë','Ê','é','è','ë','ê':ncar:='E';
        'Í','Ì','Ï','Î','í','ì','ï','î':ncar:='I';
        'Ó','Ò','Ö','Ô','ó','ò','ö','ô','Õ','õ':ncar:='O';
        'Ú','Ù','Ü','Û','ú','ù','ü','û':ncar:='U';
        'Ý','ý','ÿ','Ÿ':ncar:='Y';
        'ñ','Ñ':ncar:='N';
        'ç','Ç':ncar:='C';
        else
          ncar:='_';
      end;
      result:=result+ncar;
      if length(result)=16 then exit;//se llegó al máximo
    end;
  //evitar nombres de sistema como aux, com1, com2, prn, lpt1, etc.
  if (length(result)<4) or ((length(result)=4) and (result[4]<=#57)) then
    result:=result+'_';
end;

function QuitarCaracteresNoPermitidos(const cadena:string):string;
var i:integer;
begin
  result:='';
  for i:=1 to length(cadena) do
    if (cadena[i] in caracteresPermitidos) then result:=result+cadena[i];
end;

function PasswordAStr(const Login:Tpassword):string;
var i:integer;
begin
  result:='';
  for i:=0 to 7 do result:=result+char(login[i]);
end;

function EmpaquetarPassword(const cad,Identificador:string):TPassword;
var i,j:integer;
begin
  if length(cad)<4 then exit;
  j:=length(Identificador);
  if j>8 then j:=8;
  for i:=1 to j do
    result[i-1]:=ord(Identificador[i]);
  for i:=j to 7 do result[i]:=0;
  Semilla_aleatoria:=ord(cad[1])+(ord(cad[2]) shl 8)+(ord(cad[3]) shl 16)+(ord(cad[4]) shl 24);
  for i:=1 to length(cad) do
  begin
    j:=(i-1) and $7;
    result[j]:=result[j] xor ord(cad[i]) xor aleatorio(256);
  end;
end;

function EjecutableCorrompido(const nombre:string):boolean;
var
{$IFDEF CONTROL_EJECUTABLE}
  f:file;
  buffer:array[0..8191] of integer;
  i,leido,codia,
{$ENDIF}
  suma:integer;
begin
{$IFDEF CONTROL_EJECUTABLE}
  assignFile(f,nombre);
  filemode:=0;
  reset(f,1);
  suma:=0;//Id Base Check SUM
  repeat
    blockread(f,buffer,sizeOf(buffer),Leido);
    for i:=0 to (leido shr 2)-1 do
    begin
      codia:=buffer[i];
      asm
        mov eax,codia
        mov ecx,i
        xor ecx,eax
        and ecx,$1F
        rol eax,cl
        xor suma,eax
      end;
    end;
  until leido<sizeOf(buffer);
  closeFile(f);
{$ELSE}
  suma:=0;
{$ENDIF}
  EJECUTABLE_INTEGRO:=suma=0;
  result:=LongBool(suma);
end;

function IPAutorizado(const IP:integer):boolean;
//IMPLEMENTAR AQUI EL CONTROL DE RESTRICCIONES DE IP.
begin
  result:=true;
end;

function ObtenerAutentificacion(NroAleatorioServidor:integer):integer;
begin
  semilla_aleatoria:=IDENTIFICADOR_EJECUTABLE;
  result:=aleatorio(NroAleatorioServidor);
end;

function AutentificacionCorrecta(Codigo_Autenticacion,NroAleatorioServidor:integer):boolean;
begin
  semilla_aleatoria:=IDENTIFICADOR_EJECUTABLE;
  result:=aleatorio(NroAleatorioServidor)=Codigo_Autenticacion;
end;

function PendienteDeClima(tipoClima:byte):integer;
begin
  case TClimaAmbiental(tipoClima) of
    CL_NOCHE,CL_NORMAL:result:=1;
    CL_BRUMA:result:=1;
    else
      result:=4;//lluvias
  end;
end;

function EscribirCuenta(const DatosUsuario:TDatosUsuario;const Carpeta:string;Jugador:TjugadorS):boolean;
var fusuae:file of Tusuario;
    usuario:Tusuario;
    NombreArchivo:string;
    tamanno:integer;
    DeshabilitarArchivoOriginal:boolean;
begin
  usuario.datos:=DatosUsuario;
  DeshabilitarArchivoOriginal:=usuario.datos.EstadoUsuario=euBaneado;
  if DeshabilitarArchivoOriginal then
    usuario.datos.EstadoUsuario:=euNormal;
//Parte peligrosa:
//----------------------------------------
  //Tamaño del objeto TjugadorS, sin su referencia a clase.
  tamanno:=TAMANNO_DE_INSTANCIA_DE_TJUGADORS;
  //Limitarnos al tamaño del buffer destino
  if tamanno>sizeOf(TPersonaje) then tamanno:=sizeOf(TPersonaje);
  //Copiar el objeto (menos referencia a clase) a la variable destino (evitando pisar los 4 bytes iniciales de referencia a clase)
  move(pointer(integer(jugador)+4)^,Usuario.Personaje[4],tamanno-4);
//---------------------------------------------
  //Llenar los 4 bytes iniciales con números al azar.
  semilla_aleatoria:=random($1000000);
  Usuario.Personaje[3]:=aleatorio($100);
  Usuario.Personaje[2]:=random($100);
  Usuario.Personaje[1]:=aleatorio($100);
  Usuario.Personaje[0]:=random($100);
  nombreArchivo:=Carpeta+Usuario.datos.IdLogin+EXT_ARCH_AVATARES;
  if DeshabilitarArchivoOriginal then
  begin
    {$I-}
    assignFile(fusuae,nombreArchivo);
    erase(fusuae);//Sólo si se abre el archivo cerrarlo antes de borrarlo
    {$I+}
    result:=IOResult=0;
    nombreArchivo:=nombreArchivo+'.ban';//grabar el nuevo con distinto nombre
  end
  else
    result:=true;
  Usuario.ControlDeSuma:=Criptico(Usuario.Personaje,sizeOf(Usuario.Personaje)) xor Criptico(Usuario.Datos,sizeOf(Usuario.Datos));
  assignFile(fusuae,nombreArchivo);
  {$I-}
  Rewrite(fusuae);
  write(fusuae,usuario);
  CloseFile(fusuae);
  {$I+}
  result:=result and (IOResult=0);
end;

function PareceIP(const cadena:string):boolean;
const LOS_CARACTERES_DE_UN_IP: set of char=['0'..'9','.'];

var i,contaPuntos:integer;
begin
  result:=false;
  if (length(cadena)<7) or (length(cadena)>15) then exit;
  if not (cadena[1] in ['0'..'9']) then exit;
  contaPuntos:=0;
  for i:=2 to length(cadena) do
  begin
    if not (cadena[i] in LOS_CARACTERES_DE_UN_IP) then exit;
    if cadena[i]='.' then inc(contaPuntos);
  end;
  if contapuntos<>3 then exit;
  result:=true;
end;


end.

