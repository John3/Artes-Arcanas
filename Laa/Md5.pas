unit Md5;
//MESSAGE DIGEST V.5

//Obtiene una "Huella digital" de un archivo, array de bytes o cadena

interface
uses SysUtils, Classes, Controls;

Type

  TMD5Hash=array[0..3] of integer;
  TMd5SourceType=(MD5SourceType_Archivo,MD5SourceType_ArregloDeBytes,MD5SourceType_Cadena);

  TMD5 = class(TObject)
  Private
   { Private declarations }
    FInputFilePath: String;
    pInputArray: ^Byte;                      {Puntero al arreglo de bytes}
    FSourceLength: integer;                  {Longitud del arreglo de bytes}
    FInputString: String;
    FActiveBlock: Array[0..15] of Longword;   {Para procesar el bloque de 64 Bytes}
    FA, FB, FC, FD, FAA, FBB, FCC, FDD: Longword;
    scrambler:longword;
    Hash_Calculado:boolean;
    FType : TMd5SourceType;                     {Tipo: file, array, string}
    Procedure FF(var a:Longword; b, c, d,x:Longword; s: BYTE; ac: Longword);
    Procedure GG(var a:Longword; b, c, d,x:Longword; s: BYTE; ac: Longword);
    Procedure HH(var a:Longword; b, c, d,x:Longword; s: BYTE; ac: Longword);
    Procedure II(var a:Longword; b, c, d,x:Longword; s: BYTE; ac: Longword);
    procedure setFInputFilePath(const InputFilePath: String);
    procedure setFInputString(const InputString: String);
    procedure setFSourceLength(SourceLength:integer);
    procedure setpInputArray(InputPointer:pointer);
    function readPInputArray:Pointer;
    Procedure Transformar;// procesa bloques de 64Bytes
    Procedure Hash_Bytes;
    Procedure Hash_File;
    Procedure procesar;
  public
    { Public declarations }
    function toString:string;
    function getHash:TMD5Hash;
    Property FileName: String read FInputFilePath write setFInputFilePath;
    Property InputString: String read FInputString write setFInputString;
    Property InputLength: integer read FSourceLength write setFSourceLength;
    Property InputPointer: pointer read readPInputArray write setPInputArray;
  end;

implementation

Const
{Constantes de desplazamiento}
  S11=7;   S12=12;          S13=17;  S14=22;
  S21=5;   S22=9;           S23=14;  S24=20;
  S31=4;   S32=11;          S33=16;  S34=23;
  S41=6;   S42=10;          S43=15;  S44=21;

Function ROL(n:integer; desplazamiento:byte): integer; Assembler;
asm
  mov cl, desplazamiento
  rol eax, cl
end;

procedure TMD5.setFInputFilePath(const InputFilePath: String);
begin
  Hash_Calculado:=false;
  FType:=MD5SourceType_Archivo;
  FInputFilePath:=InputFilePath;
end;

procedure TMD5.setFInputString(const InputString: String);
begin
  Hash_Calculado:=false;
  FType:=MD5SourceType_Cadena;
  FInputString:=InputString;
end;

procedure TMD5.setFSourceLength(SourceLength:integer);
begin
  Hash_Calculado:=false;
  FType:=MD5SourceType_ArregloDeBytes;
  FSourceLength:=SourceLength;
end;

function TMD5.readPInputArray:Pointer;
begin
  result:=pointer(pInputArray);
end;

procedure TMD5.setpInputArray(InputPointer:pointer);
begin
  Hash_Calculado:=false;
  FType:=MD5SourceType_ArregloDeBytes;
  pInputArray:=InputPointer;
  if InputPointer=nil then
    FSourceLength:=0;
end;

Procedure TMD5.FF(var a:Longword; b, c, d, x:Longword; s: BYTE; ac: Longword);
// Round 1:
// a = b + ((a + F(b,c,d) + x + ac) <<< s), donde F(b,c,d) = b And c Or Not(b) And d
begin
  inc(a,{Fret}((b And c) Or ((Not b) And d)) + x + ac);
  a:=ROL(a, s);
  Inc(a,b);
end;

Procedure TMD5.GG(var a:Longword; b, c, d, x:Longword; s: BYTE; ac: Longword);
// Round 2
// a = b + ((a + G(b,c,d) + x + ac) <<< s), donde G(b,c,d) = b And d Or c Not d
begin
  inc(a,{Gret}((b And d) Or (c And (Not d))) + x + ac);
  a:=ROL(a, s);
  Inc(a,b);
end;

Procedure TMD5.HH(var a:Longword; b, c, d, x:Longword; s: BYTE; ac: Longword);
// Round 3
// a = b + ((a + H(b,c,d) + x + ac) <<< s), donde H(b,c,d) = b Xor c Xor d
begin
  inc (a,{Hret}(b Xor c Xor d) + x + ac);
  a:=ROL(a, s);
  inc(a,b);
end;

Procedure TMD5.II(var a:Longword; b, c, d, x:Longword; s: BYTE; ac: Longword);
// Round 4 of the Transform.
// a = b + ((a + I(b,c,d) + x + ac) <<< s), donde I(b,c,d) = C Xor (b Or Not(d))
begin
  inc(a,{Iret}(c Xor (b Or (Not d))) + x + ac);
  a:= ROL(a, s );
  inc(a,b);
end;

Procedure TMD5.Transformar;
// Este proceso se aplica a los bloques de 64Bytes sucesivamente en orden.
begin
  FAA := FA;
  FBB := FB;
  FCC := FC;
  FDD := FD;
// Round 1
  FF (FA, FB, FC, FD, FActiveBlock[ 0], S11, $d76aa478); { 1 }
  FF (FD, FA, FB, FC, FActiveBlock[ 1], S12, $e8c7b756); { 2 }
  FF (FC, FD, FA, FB, FActiveBlock[ 2], S13, $242070db); { 3 }
  FF (FB, FC, FD, FA, FActiveBlock[ 3], S14, $c1bdceee); { 4 }
  FF (FA, FB, FC, FD, FActiveBlock[ 4], S11, $f57c0faf); { 5 }
  FF (FD, FA, FB, FC, FActiveBlock[ 5], S12, $4787c62a); { 6 }
  FF (FC, FD, FA, FB, FActiveBlock[ 6], S13, $a8304613); { 7 }
  FF (FB, FC, FD, FA, FActiveBlock[ 7], S14, $fd469501); { 8 }
  FF (FA, FB, FC, FD, FActiveBlock[ 8], S11, $698098d8); { 9 }
  FF (FD, FA, FB, FC, FActiveBlock[ 9], S12, $8b44f7af); { 10 }
  FF (FC, FD, FA, FB, FActiveBlock[10], S13, $ffff5bb1); { 11 }
  FF (FB, FC, FD, FA, FActiveBlock[11], S14, $895cd7be); { 12 }
  FF (FA, FB, FC, FD, FActiveBlock[12], S11, $6b901122); { 13 }
  FF (FD, FA, FB, FC, FActiveBlock[13], S12, $fd987193); { 14 }
  FF (FC, FD, FA, FB, FActiveBlock[14], S13, $a679438e); { 15 }
  FF (FB, FC, FD, FA, FActiveBlock[15], S14, $49b40821); { 16 }
// Round 2
  GG (FA, FB, FC, FD, FActiveBlock[ 1], S21, $f61e2562); { 17 }
  GG (FD, FA, FB, FC, FActiveBlock[ 6], S22, $c040b340); { 18 }
  GG (FC, FD, FA, FB, FActiveBlock[11], S23, $265e5a51); { 19 }
  GG (FB, FC, FD, FA, FActiveBlock[ 0], S24, $e9b6c7aa); { 20 }
  GG (FA, FB, FC, FD, FActiveBlock[ 5], S21, $d62f105d); { 21 }
  GG (FD, FA, FB, FC, FActiveBlock[10], S22, $02441453); { 22 }
  GG (FC, FD, FA, FB, FActiveBlock[15], S23, $d8a1e681); { 23 }
  GG (FB, FC, FD, FA, FActiveBlock[ 4], S24, $e7d3fbc8); { 24 }
  GG (FA, FB, FC, FD, FActiveBlock[ 9], S21, $21e1cde6); { 25 }
  GG (FD, FA, FB, FC, FActiveBlock[14], S22, $c33707d6); { 26 }
  GG (FC, FD, FA, FB, FActiveBlock[ 3], S23, $f4d50d87); { 27 }
  GG (FB, FC, FD, FA, FActiveBlock[ 8], S24, $455a14ed); { 28 }
  GG (FA, FB, FC, FD, FActiveBlock[13], S21, $a9e3e905); { 29 }
  GG (FD, FA, FB, FC, FActiveBlock[ 2], S22, $fcefa3f8); { 30 }
  GG (FC, FD, FA, FB, FActiveBlock[ 7], S23, $676f02d9); { 31 }
  GG (FB, FC, FD, FA, FActiveBlock[12], S24, $8d2a4c8a); { 32 }
// Round 3
  HH (FA, FB, FC, FD, FActiveBlock[ 5], S31, $fffa3942); { 33 }
  HH (FD, FA, FB, FC, FActiveBlock[ 8], S32, $8771f681); { 34 }
  HH (FC, FD, FA, FB, FActiveBlock[11], S33, $6d9d6122); { 35 }
  HH (FB, FC, FD, FA, FActiveBlock[14], S34, $fde5380c); { 36 }
  HH (FA, FB, FC, FD, FActiveBlock[ 1], S31, $a4beea44); { 37 }
  HH (FD, FA, FB, FC, FActiveBlock[ 4], S32, $4bdecfa9); { 38 }
  HH (FC, FD, FA, FB, FActiveBlock[ 7], S33, $f6bb4b60); { 39 }
  HH (FB, FC, FD, FA, FActiveBlock[10], S34, $bebfbc70); { 40 }
  HH (FA, FB, FC, FD, FActiveBlock[13], S31, $289b7ec6); { 41 }
  HH (FD, FA, FB, FC, FActiveBlock[ 0], S32, $eaa127fa); { 42 }
  HH (FC, FD, FA, FB, FActiveBlock[ 3], S33, $d4ef3085); { 43 }
  HH (FB, FC, FD, FA, FActiveBlock[ 6], S34, $04881d05); { 44 }
  HH (FA, FB, FC, FD, FActiveBlock[ 9], S31, $d9d4d039); { 45 }
  HH (FD, FA, FB, FC, FActiveBlock[12], S32, $e6db99e5); { 46 }
  HH (FC, FD, FA, FB, FActiveBlock[15], S33, $1fa27cf8); { 47 }
  HH (FB, FC, FD, FA, FActiveBlock[ 2], S34, $c4ac5665); { 48 }
// Round 4
  II (FA, FB, FC, FD, FActiveBlock[ 0], S41, $f4292244); { 49 }
  II (FD, FA, FB, FC, FActiveBlock[ 7], S42, $432aff97); { 50 }
  II (FC, FD, FA, FB, FActiveBlock[14], S43, $ab9423a7); { 51 }
  II (FB, FC, FD, FA, FActiveBlock[ 5], S44, $fc93a039); { 52 }
  II (FA, FB, FC, FD, FActiveBlock[12], S41, $655b59c3); { 53 }
  II (FD, FA, FB, FC, FActiveBlock[ 3], S42, $8f0ccc92); { 54 }
  II (FC, FD, FA, FB, FActiveBlock[10], S43, $ffeff47d); { 55 }
  II (FB, FC, FD, FA, FActiveBlock[ 1], S44, $85845dd1); { 56 }
  II (FA, FB, FC, FD, FActiveBlock[ 8], S41, $6fa87e4f); { 57 }
  II (FD, FA, FB, FC, FActiveBlock[15], S42, $fe2ce6e0); { 58 }
  II (FC, FD, FA, FB, FActiveBlock[ 6], S43, $a3014314); { 59 }
  II (FB, FC, FD, FA, FActiveBlock[13], S44, $4e0811a1); { 60 }
  II (FA, FB, FC, FD, FActiveBlock[ 4], S41, $f7537e82); { 61 }
  II (FD, FA, FB, FC, FActiveBlock[11], S42, $bd3af235); { 62 }
  II (FC, FD, FA, FB, FActiveBlock[ 2], S43, $2ad7d2bb); { 63 }
  II (FB, FC, FD, FA, FActiveBlock[ 9], S44, $eb86d391); { 64 }
{
  FA:=FA xor (scrambler xor FActiveBlock[(scrambler shr (FD and $F)) and $F]);
  scrambler:=FA;
  FB:=FB xor (scrambler xor FActiveBlock[(scrambler shr (FC and $F)) and $F]);
  scrambler:=FB;
  FC:=FC xor (scrambler xor FActiveBlock[(scrambler shr (FB and $F)) and $F]);
  scrambler:=FC;
  FD:=FD xor (scrambler xor FActiveBlock[(scrambler shr (FA and $F)) and $F]);
  scrambler:=FD;
}
  Inc(FA, FAA);
  Inc(FB, FBB);
  Inc(FC, FCC);
  Inc(FD, FDD);
end;

Procedure TMD5.procesar;
  Procedure Inicializar;
  begin
  //std
    FA:=$67452301;
    FB:=$efcdab89;
    FC:=$98badcfe;
    FD:=$10325476;

{
    FA:=$67452301;
    FB:=$efcdab89;
    FC:=$98badcfe;
    FD:=$10325476;
}
    scrambler:=$f922d7ba;
  end;
var
 pStr: PChar;
begin
  Hash_Calculado:=false;
  Inicializar;
  case FType of
    MD5SourceType_Archivo:
      Hash_File;
    MD5SourceType_ArregloDeBytes:
      Hash_Bytes;
    MD5SourceType_Cadena:
    begin
      //Convertir la cadena a arreglo de bytes
      pStr := StrAlloc(Length(FInputString) + 1);//+1 por el char 0
      try
        StrPCopy(pStr, FInputString);
        FSourceLength := Length(FInputString);
        pInputArray := Pointer(pStr);
        Hash_Bytes;
      finally
        StrDispose(pStr);
      end;
    end;
  end;
  Hash_Calculado:=true;
end;

Procedure TMD5.Hash_Bytes;
var
  Buffer: array[0..4159] of Byte;//4KB+64B
  Count64: Comp;
  index: integer;
begin
  Move(pInputArray^, Buffer, FSourceLength);
  Count64 := FSourceLength * 8;//Longitud en bits antes de rellenar
  Buffer[FSourceLength] := $80;//El relleno comienza con uno
  inc(FSourceLength);
  while (FSourceLength mod 64)<>56 do
  begin
    Buffer[FSourceLength] := 0;
    Inc(FSourceLength);
  end;
  Move(Count64,Buffer[FSourceLength],SizeOf(Count64));
  index := 0;
  Inc(FSourceLength, 8);
  repeat
    Move(Buffer[Index], FActiveBlock, 64);
    Transformar;
    Inc(Index,64);
  until Index = FSourceLength;
end;

Procedure TMD5.Hash_File;
const MAX_BUFFER=4096;
var
  InputFile: File;
  Count64: Comp;
  Index: integer;
  NumRead: integer;
  Buffer:array[0..4159] of BYTE;//4KB+64B
  DoneFile : Boolean;
begin
  DoneFile := False;
  AssignFile(InputFile, FInputFilePath);
  filemode:=0;//read only
  Reset(InputFile, 1);
  Count64 := 0;
  repeat
    BlockRead(InputFile,Buffer,MAX_BUFFER,NumRead);
    Count64 := Count64 + NumRead;
    if NumRead<>MAX_BUFFER then // se llego al final del archivo
    begin
      Buffer[NumRead]:= $80;
      Inc(NumRead);
      while (NumRead mod 64)<>56 do
      begin
        Buffer[ NumRead ] := 0;
        Inc(NumRead);
      end;
      Count64 := Count64 * 8;
      Move(Count64,Buffer[NumRead],8);
      Inc(NumRead,8);
      DoneFile := True;
    end;
    Index := 0;
    repeat
      Move(Buffer[Index], FActiveBlock, 64);
      Transformar;
      Inc(Index,64);
    until Index = NumRead;
  until DoneFile;
  CloseFile(InputFile);
end;

function TMD5.getHash:TMD5Hash;
begin
  if not Hash_Calculado then procesar;
  result[0]:=FA;
  result[1]:=FB;
  result[2]:=FC;
  result[3]:=FD;
end;

function TMD5.toString:string;
type
  string8=array[0..7] of char;
const
  HEXAchar:array[0..15] of char=
    ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
  function int32ToHex(n:integer):string8;
  var i:integer;
  begin
    for i:=0 to 3 do
    begin
      result[i shl 1+1]:=HEXAchar[n and $F];
      n:=n shr 4;
      result[i shl 1]:=HEXAchar[n and $F];
      n:=n shr 4;
    end;
  end;
begin
  if not Hash_Calculado then procesar;
  result:=int32ToHex(FA)+int32ToHex(FB)+int32ToHex(FC)+int32ToHex(FD);
end;

end.
