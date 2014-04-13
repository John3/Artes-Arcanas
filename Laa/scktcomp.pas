{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{       Windows socket components                       }
{                                                       }
{       Copyright (c) Borland International             }
{                                                       }
{*******************************************************}
{
Editado por Sergio:
Este es el codigo fuente del componente sockets de delphi,
le agregue algunas cosas que creo que necesitaba :).
En especial un pequeño buffer de envio de datos y un identificador de
socket para hacer fácil relacionar un usuario con su socket
de comunicación. También modifique la forma en que se generaban los
mensajes de error, para que se registren en el log del servidor en
lugar de mostrar ventanitas de error.
}

//{$DEFINE PRUEBA_DE_ESTABILIDAD}

unit ScktComp;

interface

uses SysUtils, Windows, Messages, Classes, WinSock;

const
  CM_SOCKETMESSAGE = WM_USER + $0001;
  CM_DEFERFREE = WM_USER + $0002;
  ID_NULO = $7FFF;
  TAMANNO_BUFFER_ENVIO=78;

type
//******************************************************************************
//Sincronización de objetos:
//******************************************************************************

  TCriticalSection = class(TObject)
  private
    FSection: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Enter;
    procedure Leave;
  end;

//******************************************************************************
//Sockets
//******************************************************************************
  ESocketError = class(Exception);

  TCMSocketMessage = record
    NotUsedMsg: Cardinal;
    Socket: TSocket;
    SelectEvent: Word;
    SelectError: Word;
    NotUsedResult: Longint;
  end;

  TCustomWinSocket = class;
  TCustomSocket = class;
  TServerWinSocket = class;
  TServerClientWinSocket = class;

  TClientType = (ctNonBlocking, ctBlocking);
  TAsyncStyle = (asRead, asWrite, asOOB, asAccept, asConnect, asClose);
  TAsyncStyles = set of TAsyncStyle;
  TSocketEvent = (seLookup, seConnecting, seConnect, seDisconnect, seListen,
    seAccept, seWrite, seRead);
  TErrorEvent = (eeGeneral, eeSend, eeReceive, eeConnect, eeDisconnect, eeAccept);

  TSocketEventEvent = procedure (Sender: TObject; Socket: TCustomWinSocket;
    SocketEvent: TSocketEvent) of object;
  TSocketErrorEvent = procedure (Sender: TObject; Socket: TCustomWinSocket;
    ErrorEvent: TErrorEvent; var ErrorCode: Integer) of object;
  TGetSocketEvent = procedure (Sender: TObject; Socket: TSocket;
    var ClientSocket: TServerClientWinSocket) of object;
  TSocketNotifyEvent = procedure (Sender: TObject; Socket: TCustomWinSocket) of object;

  TCustomWinSocket = class
  private
    FSocket: TSocket;
    FHandle: HWnd;
    FAsyncStyles: TASyncStyles;
    FOnSocketEvent: TSocketEventEvent;
    FOnErrorEvent: TSocketErrorEvent;
    FSocketLock: TCriticalSection;
    //Envia S.
    procedure FSendText(const S: string);


    public procedure DefaultHandler(var Message); override;
    private procedure WndProc(var Message: TMessage);
    procedure CMSocketMessage(var Message: TCMSocketMessage); message CM_SOCKETMESSAGE;
    procedure CMDeferFree(var Message); message CM_DEFERFREE;
    procedure DeferFree;
    procedure DoSetAsyncStyles;
    function GetHandle: HWnd;
    function GetLocalHost: string;
    function GetLocalAddress: string;
    function GetLocalPort: Integer;
    function GetRemoteHost: string;
    function GetRemoteAddress: string;
    function GetRemotePort: Integer;
    function GetRemoteAddr: TSockAddrIn;
  protected
    FConnected: Boolean;
    function InitSocket(var Name, Address: string; Port: Word;
      Client: Boolean): TSockAddrIn;
    procedure Event(Socket: TCustomWinSocket; SocketEvent: TSocketEvent); dynamic;
    procedure Error(Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer); dynamic;
    procedure SetAsyncStyles(Value: TASyncStyles);
    procedure Listen(var Name, Address: string; Port: Word;
      QueueSize: Integer);
    procedure Open(var Name, Address: string; Port: Word);
    procedure Accept(Socket: TSocket); virtual;
    procedure Connect(Socket: TSocket); virtual;
    procedure Disconnect(Socket: TSocket); virtual;
    procedure Read(Socket: TSocket); virtual;
    procedure Write(Socket: TSocket); virtual;
  public
    // El servidor define este identificador para cada cliente
    Identificador:integer;
    BufferEnvio:string[TAMANNO_BUFFER_ENVIO];
    BufferRecepcion:string;
    constructor Create(ASocket: TSocket);
    destructor Destroy; override;
    procedure Close;
    procedure Lock;
    procedure Unlock;
    function LookupName(const name: string) : TInAddr;
    function ReceiveBuf(var Buf; Count: Integer): Integer;
    function ReceiveText: string;
    //function SendBuf(var Buf; Count: Integer): Integer;
    //function SendStream(AStream: TStream): Boolean;
    //function SendStreamThenDrop(AStream: TStream): Boolean;
    //Si S entra en el buffer entonces lo almacena, sino envia el buffer y luego s.
    procedure SendText(const S: string);
    //Envia el buffer y luego s.
    procedure SendTextNow(const s: string);
    //Envia el buffer
    procedure SendBufferedTextNow;
    property LocalHost: string read GetLocalHost;
    property LocalAddress: string read GetLocalAddress;
    property LocalPort: Integer read GetLocalPort;

    property RemoteHost: string read GetRemoteHost;
    property RemoteAddress: string read GetRemoteAddress;
    property RemotePort: Integer read GetRemotePort;
    property RemoteAddr: TSockAddrIn read GetRemoteAddr;

    property Connected: Boolean read FConnected;
    property ASyncStyles: TAsyncStyles read FAsyncStyles write SetAsyncStyles;
    property Handle: HWnd read GetHandle;
    property SocketHandle: TSocket read FSocket;

    property OnSocketEvent: TSocketEventEvent read FOnSocketEvent write FOnSocketEvent;
    property OnErrorEvent: TSocketErrorEvent read FOnErrorEvent write FOnErrorEvent;
  end;

  TClientWinSocket = class(TCustomWinSocket)
  private
    FClientType: TClientType;
  protected
    procedure Connect(Socket: TSocket); override;
    procedure SetClientType(Value: TClientType);
  public
    property ClientType: TClientType read FClientType write SetClientType;
  end;

  TServerClientWinSocket = class(TCustomWinSocket)
  private
    FServerWinSocket: TServerWinSocket;
  public
    constructor Create(Socket: TSocket; ServerWinSocket: TServerWinSocket);
    destructor Destroy; override;
    property ServerWinSocket: TServerWinSocket read FServerWinSocket;
  end;

  TServerWinSocket = class(TCustomWinSocket)
  private
    FConnections: TList;
    FActiveThreads: TList;
    FListLock: TCriticalSection;
    FOnGetSocket: TGetSocketEvent;
    FOnClientConnect: TSocketNotifyEvent;
    FOnClientDisconnect: TSocketNotifyEvent;
    FOnClientRead: TSocketNotifyEvent;
    FOnClientWrite: TSocketNotifyEvent;
    FOnClientError: TSocketErrorEvent;
    procedure AddClient(AClient: TServerClientWinSocket);
    procedure RemoveClient(AClient: TServerClientWinSocket);
    procedure ClientEvent(Sender: TObject; Socket: TCustomWinSocket;
      SocketEvent: TSocketEvent);
    function GetActiveConnections: Integer;
  protected
    procedure Accept(Socket: TSocket); override;
    procedure Disconnect(Socket: TSocket); override;
    procedure Listen(var Name, Address: string; Port: Word;
      QueueSize: Integer);
    function GetClientSocket(Socket: TSocket): TServerClientWinSocket; dynamic;
    procedure ClientRead(Socket: TCustomWinSocket); dynamic;
    procedure ClientWrite(Socket: TCustomWinSOcket); dynamic;
    procedure ClientConnect(Socket: TCustomWinSOcket); dynamic;
    procedure ClientDisconnect(Socket: TCustomWinSOcket); dynamic;
    procedure ClientErrorEvent(Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer); dynamic;
  public
    constructor Create(ASocket: TSocket);
    destructor Destroy; override;
    property ActiveConnections: Integer read GetActiveConnections;
    property OnGetSocket: TGetSocketEvent read FOnGetSocket write FOnGetSocket;
    property OnClientConnect: TSocketNotifyEvent read FOnClientConnect write FOnClientConnect;
    property OnClientDisconnect: TSocketNotifyEvent read FOnClientDisconnect write FOnClientDisconnect;
    property OnClientRead: TSocketNotifyEvent read FOnClientRead write FOnClientRead;
    property OnClientWrite: TSocketNotifyEvent read FOnClientWrite write FOnClientWrite;
    property OnClientError: TSocketErrorEvent read FOnClientError write FOnClientError;
  end;

  TCustomSocket = class(TComponent)
  private
    FActive: Boolean;
    FOnLookup: TSocketNotifyEvent;
    FOnConnect: TSocketNotifyEvent;
    FOnConnecting: TSocketNotifyEvent;
    FOnDisconnect: TSocketNotifyEvent;
    FOnListen: TSocketNotifyEvent;
    FOnAccept: TSocketNotifyEvent;
    FOnRead: TSocketNotifyEvent;
    FOnWrite: TSocketNotifyEvent;
    FOnError: TSocketErrorEvent;
    FPort: Integer;
    FAddress: string;
    FHost: string;
    procedure DoEvent(Sender: TObject; Socket: TCustomWinSocket;
      SocketEvent: TSocketEvent);
    procedure DoError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  protected
    procedure Event(Socket: TCustomWinSocket; SocketEvent: TSocketEvent); virtual;
    procedure Error(Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer); virtual;
    procedure DoActivate(Value: Boolean); virtual; abstract;
    procedure Loaded; override;
    procedure SetActive(Value: Boolean);
    procedure SetAddress(Value: string);
    procedure SetHost(Value: string);
    procedure SetPort(Value: Integer);
    property Active: Boolean read FActive write SetActive;
    property Address: string read FAddress write SetAddress;
    property Host: string read FHost write SetHost;
    property Port: Integer read FPort write SetPort;
    property OnLookup: TSocketNotifyEvent read FOnLookup write FOnLookup;
    property OnConnecting: TSocketNotifyEvent read FOnConnecting write FOnConnecting;
    property OnConnect: TSocketNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TSocketNotifyEvent read FOnDisconnect write FOnDisconnect;
    property OnListen: TSocketNotifyEvent read FOnListen write FOnListen;
    property OnAccept: TSocketNotifyEvent read FOnAccept write FOnAccept;
    property OnRead: TSocketNotifyEvent read FOnRead write FOnRead;
    property OnWrite: TSocketNotifyEvent read FOnWrite write FOnWrite;
    property OnError: TSocketErrorEvent read FOnError write FOnError;
  public
    procedure Open;
    procedure Close;
  end;

  TClientSocket = class(TCustomSocket)
  private
    FClientSocket: TClientWinSocket;
  protected
    procedure DoActivate(Value: Boolean); override;
    function GetClientType: TClientType;
    procedure SetClientType(Value: TClientType);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Socket: TClientWinSocket read FClientSocket;
  published
    property Active;
    property Address;
    property ClientType: TClientType read GetClientType write SetClientType;
    property Host;
    property Port;
    property OnLookup;
    property OnConnecting;
    property OnConnect;
    property OnDisconnect;
    property OnRead;
    property OnWrite;
    property OnError;
  end;

  TCustomServerSocket = class(TCustomSocket)
  protected
    FServerSocket: TServerWinSocket;
    procedure DoActivate(Value: Boolean); override;
    function GetGetSocketEvent: TGetSocketEvent;
    function GetOnClientEvent(Index: Integer): TSocketNotifyEvent;
    function GetOnClientError: TSocketErrorEvent;
    procedure SetGetSocketEvent(Value: TGetSocketEvent);
    procedure SetOnClientEvent(Index: Integer; Value: TSocketNotifyEvent);
    procedure SetOnClientError(Value: TSocketErrorEvent);
    property OnGetSocket: TGetSocketEvent read GetGetSocketEvent
      write SetGetSocketEvent;
    property OnClientConnect: TSocketNotifyEvent index 2 read GetOnClientEvent
      write SetOnClientEvent;
    property OnClientDisconnect: TSocketNotifyEvent index 3 read GetOnClientEvent
      write SetOnClientEvent;
    property OnClientRead: TSocketNotifyEvent index 0 read GetOnClientEvent
      write SetOnClientEvent;
    property OnClientWrite: TSocketNotifyEvent index 1 read GetOnClientEvent
      write SetOnClientEvent;
    property OnClientError: TSocketErrorEvent read GetOnClientError write SetOnClientError;
  public
    destructor Destroy; override;
  end;

  TServerSocket = class(TCustomServerSocket)
  public
    constructor Create(AOwner: TComponent); override;
    property Socket: TServerWinSocket read FServerSocket;
  published
    property Address;//To work with multiple IPs
    property Active;
    property Port;
    property OnListen;
    property OnAccept;
    property OnGetSocket;
    property OnClientConnect;
    property OnClientDisconnect;
    property OnClientRead;
    property OnClientWrite;
    property OnClientError;
  end;

threadvar
  SocketErrorProc: procedure (ErrorCode: Integer; elSocket: pointer;const origen:string);

implementation

uses Forms;

// Mensajes de error de sockets:
const
  sWindowsSocketError='Windows socket error: %s (%d), on API ''%s''';
  sASyncSocketError='Asynchronous socket error %d';
  sNoAddress='No address specified';
  sCannotListenOnOpen='Can''t listen on an open socket';
  sCannotCreateSocket='Can''t create new socket';
  sSocketAlreadyOpen='Socket already open';
  sCantChangeWhileActive='Can''t change value while socket is active';

var
  WSAData: TWSAData;

function CheckSocketResult(ResultCode: Integer; elSocket: pointer; const Op: string): Integer;
begin
  if ResultCode <> 0 then
  begin
    Result := WSAGetLastError;
    if Result <> WSAEWOULDBLOCK then
      if Assigned(SocketErrorProc) then
        SocketErrorProc(Result,elSocket,'CheckSocketResult: '+op)
      else
        raise ESocketError.CreateFmt(sWindowsSocketError,
          [SysErrorMessage(Result), Result, Op])
  end else Result := 0;
end;

procedure Startup;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSAStartup($0101, WSAData);
  if ErrorCode <> 0 then
    if Assigned(SocketErrorProc) then
      SocketErrorProc(ErrorCode,nil,'Startup')
    else
      raise ESocketError.CreateFmt(sWindowsSocketError,
        [SysErrorMessage(ErrorCode), ErrorCode, 'WSAStartup']);
end;

procedure Cleanup;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSACleanup;
  if ErrorCode <> 0 then
    if Assigned(SocketErrorProc) then
      SocketErrorProc(ErrorCode,nil,'Cleanup')
    else
      raise ESocketError.CreateFmt(sWindowsSocketError,
        [SysErrorMessage(ErrorCode), ErrorCode, 'WSACleanup']);
end;

{ TCustomWinSocket }

constructor TCustomWinSocket.Create(ASocket: TSocket);
begin
  inherited Create;
  Identificador:=ID_NULO;//Sin id
  BufferRecepcion:='';
  Startup;
  FSocketLock := TCriticalSection.Create;
  FASyncStyles := [asRead, asWrite, asConnect, asClose];
  FSocket := ASocket;
  FConnected := FSocket <> INVALID_SOCKET;
end;

destructor TCustomWinSocket.Destroy;
begin
  FOnSocketEvent := nil;  { disable events }
  if FConnected and (FSocket <> INVALID_SOCKET) then
    Disconnect(FSocket);
  {$WARN SYMBOL_DEPRECATED OFF}
  if FHandle <> 0 then DeallocateHWnd(FHandle);
  {$WARN SYMBOL_DEPRECATED ON}
  FSocketLock.Free;
  Cleanup;
  inherited Destroy;
end;

procedure TCustomWinSocket.Accept(Socket: TSocket);
begin
end;

procedure TCustomWinSocket.Close;
begin
  //originalmente sólo: Disconnect(FSocket);
  if Connected then Disconnect(FSocket);
end;

procedure TCustomWinSocket.Connect(Socket: TSocket);
begin
end;

procedure TCustomWinSocket.Lock;
begin
  FSocketLock.Enter;
end;

procedure TCustomWinSocket.Unlock;
begin
  FSocketLock.Leave;
end;

procedure TCustomWinSocket.CMSocketMessage(var Message: TCMSocketMessage);

  function CheckError: Boolean;
  var
    ErrorEvent: TErrorEvent;
    ErrorCode: Integer;
  begin
    if Message.SelectError <> 0 then
    begin
      Result := False;
      ErrorCode := Message.SelectError;
      case Message.SelectEvent of
        FD_CONNECT: ErrorEvent := eeConnect;
        FD_CLOSE: ErrorEvent := eeDisconnect;
        FD_READ: ErrorEvent := eeReceive;
        FD_WRITE: ErrorEvent := eeSend;
        FD_ACCEPT: ErrorEvent := eeAccept;
      else
        ErrorEvent := eeGeneral;
      end;
      Error(Self, ErrorEvent, ErrorCode);
      if ErrorCode <> 0 then
        if assigned(SocketErrorProc) then
          SocketErrorProc(ErrorCode,self,'CheckError #'+inttostr(identificador))
        else
          raise ESocketError.CreateFmt(sASyncSocketError, [ErrorCode])
    end else Result := True;
  end;

begin
  with Message do
    if CheckError then
      case SelectEvent of
        FD_CONNECT: Connect(Socket);
        FD_CLOSE: Disconnect(Socket);
        FD_READ: Read(Socket);
        FD_WRITE: Write(Socket);
        FD_ACCEPT: Accept(Socket);
      end;
end;

procedure TCustomWinSocket.CMDeferFree(var Message);
begin
  Free;
end;

procedure TCustomWinSocket.DeferFree;
begin
  if FHandle <> 0 then PostMessage(FHandle, CM_DEFERFREE, 0, 0);
end;

procedure TCustomWinSocket.DoSetAsyncStyles;
var
  Msg: Integer;
  Wnd: HWnd;
  Blocking: Longint;
begin
  Msg := 0;
  Wnd := 0;
  if FAsyncStyles <> [] then
  begin
    Msg := CM_SOCKETMESSAGE;
    Wnd := Handle;
  end;
  WSAAsyncSelect(FSocket, Wnd, Msg, Longint(Byte(FAsyncStyles)));
  if FASyncStyles = [] then
  begin
    Blocking := 0;
    ioctlsocket(FSocket, FIONBIO, Blocking);
  end;
end;

function TCustomWinSocket.GetHandle: HWnd;
begin
  {$WARN SYMBOL_DEPRECATED OFF}
  if FHandle = 0 then FHandle := AllocateHwnd(WndProc);
  {$WARN SYMBOL_DEPRECATED ON}
  Result := FHandle;
end;

function TCustomWinSocket.GetLocalAddress: string;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Lock;
  try
    Result := '';
    if FSocket = INVALID_SOCKET then Exit;
    Size := SizeOf(SockAddrIn);
    if getsockname(FSocket, SockAddrIn, Size) = 0 then
      Result := inet_ntoa(SockAddrIn.sin_addr);
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.GetLocalHost: string;
var
  LocalName: array[0..255] of Char;
begin
  Lock;
  try
    Result := '';
    if FSocket = INVALID_SOCKET then Exit;
    if gethostname(LocalName, SizeOf(LocalName)) = 0 then
      Result := LocalName;
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.GetLocalPort: Integer;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Lock;
  try
    Result := -1;
    if FSocket = INVALID_SOCKET then Exit;
    Size := SizeOf(SockAddrIn);
    if getsockname(FSocket, SockAddrIn, Size) = 0 then
      Result := ntohs(SockAddrIn.sin_port);
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.GetRemoteHost: string;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
  HostEnt: PHostEnt;
begin
  Lock;
  try
    Result := '';
    if not FConnected then Exit;
    Size := SizeOf(SockAddrIn);
    CheckSocketResult(getpeername(FSocket, SockAddrIn, Size),self, 'getpeername');
    HostEnt := gethostbyaddr(@SockAddrIn.sin_addr.s_addr, 4, PF_INET);
    if HostEnt <> nil then Result := HostEnt.h_name;
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.GetRemoteAddress: string;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Lock;
  try
    Result := '';
    if not FConnected then Exit;
    Size := SizeOf(SockAddrIn);
    CheckSocketResult(getpeername(FSocket, SockAddrIn, Size),self, 'getpeername');
    Result := inet_ntoa(SockAddrIn.sin_addr);
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.GetRemotePort: Integer;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Lock;
  try
    Result := 0;
    if not FConnected then Exit;
    Size := SizeOf(SockAddrIn);
    CheckSocketResult(getpeername(FSocket, SockAddrIn, Size),self, 'getpeername');
    Result := ntohs(SockAddrIn.sin_port);
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.GetRemoteAddr: TSockAddrIn;
var
  Size: Integer;
begin
  Lock;
  try
    FillChar(Result, SizeOf(Result), 0);
    if not FConnected then Exit;
    Size := SizeOf(Result);
    if getpeername(FSocket, Result, Size) <> 0 then
      FillChar(Result, SizeOf(Result), 0);
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.LookupName(const Name: string): TInAddr;
var
  HostEnt: PHostEnt;
  InAddr: TInAddr;
begin
  HostEnt := gethostbyname(PChar(Name));
  FillChar(InAddr, SizeOf(InAddr), 0);
  if HostEnt <> nil then
  begin
    with InAddr, HostEnt^ do
    begin
      S_un_b.s_b1 := h_addr^[0];
      S_un_b.s_b2 := h_addr^[1];
      S_un_b.s_b3 := h_addr^[2];
      S_un_b.s_b4 := h_addr^[3];
    end;
  end;
  Result := InAddr;
end;

function TCustomWinSocket.InitSocket(var Name, Address: string; Port: Word;
  Client: Boolean): TSockAddrIn;
begin
  Result.sin_family := PF_INET;
  if Name <> '' then
    Result.sin_addr := LookupName(name)
  else if Address <> '' then
    Result.sin_addr.s_addr := inet_addr(PChar(Address))
  else if not Client then
    Result.sin_addr.s_addr := INADDR_ANY
  else raise ESocketError.Create(sNoAddress);
    Result.sin_port := htons(Port);
end;

procedure TCustomWinSocket.Listen(var Name, Address: string; Port: Word;
  QueueSize: Integer);
var
  SockAddrIn: TSockAddrIn;
begin
  if FConnected then raise ESocketError.Create(sCannotListenOnOpen);
  FSocket := socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
  if FSocket = INVALID_SOCKET then raise ESocketError.Create(sCannotCreateSocket);
  try
    SockAddrIn := InitSocket(Name, Address, Port, False);
    CheckSocketResult(bind(FSocket, SockAddrIn, SizeOf(SockAddrIn)),self, 'bind');
    DoSetASyncStyles;
    if QueueSize > SOMAXCONN then QueueSize := SOMAXCONN;
    Event(Self, seListen);
    CheckSocketResult(Winsock.listen(FSocket, QueueSize),self, 'listen');
    FConnected := True;
  except
    Disconnect(FSocket);
    raise;
  end;
end;

procedure TCustomWinSocket.Open(var Name, Address: string; Port: Word);
var
  SockAddrIn: TSockAddrIn;
begin
  if FConnected then raise ESocketError.Create(sSocketAlreadyOpen);
  FSocket := socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
  if FSocket = INVALID_SOCKET then raise ESocketError.Create(sCannotCreateSocket);
  try
    Event(Self, seLookUp);
    SockAddrIn := InitSocket(Name, Address, Port, True);
    DoSetASyncStyles;
    Event(Self, seConnecting);
    CheckSocketResult(WinSock.connect(FSocket, SockAddrIn, SizeOf(SockAddrIn)),self, 'connect');
    if not (asConnect in FAsyncStyles) then
    begin
      FConnected := FSocket <> INVALID_SOCKET;
      Event(Self, seConnect);
    end;
  except
    Disconnect(FSocket);
    raise;
  end;
end;

procedure TCustomWinSocket.Disconnect(Socket: TSocket);
begin
  Lock;
  try
    if (Socket = INVALID_SOCKET) or (Socket <> FSocket) then exit;
    Event(Self, seDisconnect);
    CheckSocketResult(closesocket(FSocket),self, 'closesocket');
    FSocket := INVALID_SOCKET;
    FConnected := False;
  finally
    Unlock;
  end;
end;

// Default handler of non processed messages
procedure TCustomWinSocket.DefaultHandler(var Message);
begin
  with TMessage(Message) do
    if FHandle <> 0 then
      Result := CallWindowProc(@DefWindowProc, FHandle, Msg, wParam, lParam);
end;

procedure TCustomWinSocket.Event(Socket: TCustomWinSocket; SocketEvent: TSocketEvent);
begin
  if Assigned(FOnSocketEvent) then FOnSocketEvent(Self, Socket, SocketEvent);
end;

procedure TCustomWinSocket.Error(Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  if Assigned(FOnErrorEvent) then FOnErrorEvent(Self, Socket, ErrorEvent, ErrorCode);
end;

procedure TCustomWinSocket.SendBufferedTextNow;
begin
  if length(BufferEnvio)>0 then
  begin
    FSendText(BufferEnvio);
    BufferEnvio:='';
  end;
end;

procedure TCustomWinSocket.SendText(const s: string);
begin
  if length(s)+length(bufferEnvio)>TAMANNO_BUFFER_ENVIO then
  begin
    SendBufferedTextNow;
    FSendText(s);
  end
  else
    BufferEnvio:=BufferEnvio+s;
end;

procedure TCustomWinSocket.SendTextNow(const s: string);
begin
  SendBufferedTextNow;
  FSendText(s);
end;

{$IFDEF PRUEBA_DE_ESTABILIDAD}
procedure TCustomWinSocket.FSendText(const s: string);
  var i,j,QuitarControlEstabilidad:integer;
  procedure fff(const s: string);
  var
    ErrorCode,LongitudEnviada: Integer;
  begin
    if not FConnected then Exit;//Required to avoid "Lock" having a disconnected socket.
    Lock;
    try
      if FConnected then//Required if disconnected just after the first test.
      begin
        LongitudEnviada:=send(FSocket, Pointer(S)^, Length(S), 0);
        if LongitudEnviada = SOCKET_ERROR then
        begin
          ErrorCode := WSAGetLastError;
          if (ErrorCode <> WSAEWOULDBLOCK) then
          begin
            Error(Self, eeSend, ErrorCode);
            Disconnect(FSocket);
            if ErrorCode <> 0 then
              if assigned(SocketErrorProc) then
                SocketErrorProc(ErrorCode,self,'SendText #'+inttostr(identificador)+' Datos:'+s)
              else
                raise ESocketError.CreateFmt(sWindowsSocketError,
                  [SysErrorMessage(ErrorCode), ErrorCode, 'send']);
          end;
        end
        else
          if LongitudEnviada<Length(S) then
            if assigned(SocketErrorProc) then
              SocketErrorProc(0,self,'SendText #'+inttostr(identificador)+' Faltaron '+inttostr(Length(S)-longitudEnviada)+' Bytes')
      end;
    finally
      Unlock;
    end;
  end;
begin
  i:=length(s);
  if i>1 then
  begin
    fff(copy(s,1,i div 2));
    for j:=0 to 40000000 do
      QuitarControlEstabilidad:=(QuitarControlEstabilidad+j+i)*QuitarControlEstabilidad;
    fff(copy(s,(i div 2)+1,i));
  end
  else
    fff(s);
end;
{$ELSE}
procedure TCustomWinSocket.FSendText(const s: string);
var
  ErrorCode,LongitudEnviada: Integer;
begin
  if not FConnected then Exit;//Required to avoid "Lock" having a disconnected socket.
  Lock;
  try
    if FConnected then//Required if disconnected just after the first test.
    begin
      LongitudEnviada:=send(FSocket, Pointer(S)^, Length(S), 0);
      if LongitudEnviada = SOCKET_ERROR then
      begin
        ErrorCode := WSAGetLastError;
        if (ErrorCode <> WSAEWOULDBLOCK) then
        begin
          Error(Self, eeSend, ErrorCode);
          Disconnect(FSocket);
          if ErrorCode <> 0 then
            if assigned(SocketErrorProc) then
              SocketErrorProc(ErrorCode,self,'SendText #'+inttostr(identificador)+' Datos:'+s)
            else
              raise ESocketError.CreateFmt(sWindowsSocketError,
                [SysErrorMessage(ErrorCode), ErrorCode, 'send']);
        end;
      end
      else
        if LongitudEnviada<Length(S) then
          if assigned(SocketErrorProc) then
            SocketErrorProc(0,self,'SendText #'+inttostr(identificador)+' Faltaron '+inttostr(Length(S)-longitudEnviada)+' Bytes')
    end;
  finally
    Unlock;
  end;
end;
{$ENDIF}

procedure TCustomWinSocket.SetAsyncStyles(Value: TASyncStyles);
begin
  if Value <> FASyncStyles then
  begin
    FASyncStyles := Value;
    if FSocket <> INVALID_SOCKET then
      DoSetAsyncStyles;
  end;
end;


procedure TCustomWinSocket.Read(Socket: TSocket);
begin
  if (FSocket = INVALID_SOCKET) or (Socket <> FSocket) then Exit;
  Event(Self, seRead);
end;

function TCustomWinSocket.ReceiveBuf(var Buf; Count: Integer): Integer;
var
  ErrorCode: Integer;
begin
  Lock;
  try
    Result := 0;
    if (Count = -1) and FConnected then
      ioctlsocket(FSocket, FIONREAD, Longint(Result))
    else begin
      if not FConnected then Exit;
      Result := recv(FSocket, Buf, Count, 0);
      if Result = SOCKET_ERROR then
      begin
        ErrorCode := WSAGetLastError;
        if ErrorCode <> WSAEWOULDBLOCK then
        begin
          Error(Self, eeReceive, ErrorCode);
          Disconnect(FSocket);
          if ErrorCode <> 0 then
            if assigned(SocketErrorProc) then
              SocketErrorProc(ErrorCode,self,'ReceiveBuf #'+inttostr(identificador))
            else
              raise ESocketError.CreateFmt(sWindowsSocketError,
                [SysErrorMessage(ErrorCode), ErrorCode, 'recv']);
        end;
      end;
    end;
  finally
    Unlock;
  end;
end;

function TCustomWinSocket.ReceiveText: string;
{
begin
  SetLength(Result, ReceiveBuf(Pointer(nil)^, -1));
  ReceiveBuf(Pointer(Result)^, Length(Result));
end;
}
var
  longitud:Longint;
  ErrorCode: Integer;
begin
  Lock;
  try
    if not FConnected then Exit;
    ioctlsocket(FSocket, FIONREAD, longitud);
    SetLength(Result, longitud);
    if recv(FSocket,Pointer(Result)^, Length(Result), 0) = SOCKET_ERROR then
    begin
      ErrorCode := WSAGetLastError;
      if ErrorCode <> WSAEWOULDBLOCK then
      begin
        Error(Self, eeReceive, ErrorCode);
        Disconnect(FSocket);
        if ErrorCode <> 0 then
          if assigned(SocketErrorProc) then
            SocketErrorProc(ErrorCode,self,'ReceiveText #'+inttostr(identificador))
          else
            raise ESocketError.CreateFmt(sWindowsSocketError,
              [SysErrorMessage(ErrorCode), ErrorCode, 'recv']);
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TCustomWinSocket.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;

procedure TCustomWinSocket.Write(Socket: TSocket);
begin
  if (FSocket = INVALID_SOCKET) or (Socket <> FSocket) then Exit;
  //if not SendStreamPiece then
  Event(Self, seWrite);
end;

{ TClientWinSocket }

procedure TClientWinSocket.Connect(Socket: TSocket);
begin
  FConnected := True;
  Event(Self, seConnect);
end;

procedure TClientWinSocket.SetClientType(Value: TClientType);
begin
  if Value <> FClientType then
    if not FConnected then
    begin
      FClientType := Value;
      if FClientType = ctBlocking then
        ASyncStyles := []
      else ASyncStyles := [asRead, asWrite, asConnect, asClose];
    end else raise ESocketError.Create(sCantChangeWhileActive);
end;

{ TServerClientWinsocket }

constructor TServerClientWinSocket.Create(Socket: TSocket; ServerWinSocket: TServerWinSocket);
begin
  FServerWinSocket := ServerWinSocket;
  if Assigned(FServerWinSocket) then
  begin
    FServerWinSocket.AddClient(Self);
    if FServerWinSocket.AsyncStyles <> [] then
      OnSocketEvent := FServerWinSocket.ClientEvent;
  end;
  inherited Create(Socket);
  if FServerWinSocket.ASyncStyles <> [] then DoSetAsyncStyles;
  if FConnected then Event(Self, seConnect);
end;

destructor TServerClientWinSocket.Destroy;
begin
  if Assigned(FServerWinSocket) then
    FServerWinSocket.RemoveClient(Self);
  inherited Destroy;
end;

{ TServerWinSocket }

constructor TServerWinSocket.Create(ASocket: TSocket);
begin
  FConnections := TList.Create;
  FActiveThreads := TList.Create;
  FListLock := TCriticalSection.Create;
  inherited Create(ASocket);
  FAsyncStyles := [asAccept];
end;

destructor TServerWinSocket.Destroy;
begin
  inherited Destroy;
  FConnections.Free;
  FActiveThreads.Free;
  FListLock.Free;
end;

procedure TServerWinSocket.AddClient(AClient: TServerClientWinSocket);
begin
  FListLock.Enter;
  try
    if FConnections.IndexOf(AClient) < 0 then
      FConnections.Add(AClient);
  finally
    FListLock.Leave;
  end;
end;

procedure TServerWinSocket.RemoveClient(AClient: TServerClientWinSocket);
begin
  FListLock.Enter;
  try
    FConnections.Remove(AClient);
  finally
    FListLock.Leave;
  end;
end;

procedure TServerWinSocket.ClientEvent(Sender: TObject; Socket: TCustomWinSocket;
  SocketEvent: TSocketEvent);
begin
  case SocketEvent of
    seAccept,
    seLookup,
    seConnecting,
    seListen:
      begin end;
    seConnect:begin
      BufferRecepcion:='';
      ClientConnect(Socket);
    end;
    seDisconnect: ClientDisconnect(Socket);
    seRead: ClientRead(Socket);
    seWrite: ClientWrite(Socket);
  end;
end;

function TServerWinSocket.GetActiveConnections: Integer;
begin
  Result := FConnections.Count;
end;

procedure TServerWinSocket.Accept(Socket: TSocket);
var
  ClientSocket: TServerClientWinSocket;
  ClientWinSocket: TSocket;
  Addr: TSockAddrIn;
  Len: Integer;
begin
  Len := SizeOf(Addr);
  ClientWinSocket := WinSock.accept(Socket, @Addr, @Len);
  if ClientWinSocket <> INVALID_SOCKET then
  begin
    ClientSocket := GetClientSocket(ClientWinSocket);
    if Assigned(FOnSocketEvent) then
      FOnSocketEvent(Self, ClientSocket, seAccept);
  end;
end;

procedure TServerWinSocket.Disconnect(Socket: TSocket);
begin
  Lock;
  try
    while FConnections.Count > 0 do
      TCustomWinSocket(FConnections.Last).Free;
    inherited Disconnect(Socket);
  finally
    Unlock;
  end;
end;

procedure TServerWinSocket.Listen(var Name, Address: string; Port: Word;
  QueueSize: Integer);
begin
  inherited Listen(Name, Address, Port, QueueSize);
end;

function TServerWinSocket.GetClientSocket(Socket: TSocket): TServerClientWinSocket;
begin
  Result := nil;
  if Assigned(FOnGetSocket) then FOnGetSocket(Self, Socket, Result);
  if Result = nil then
    Result := TServerClientWinSocket.Create(Socket, Self);
end;

procedure TServerWinSocket.ClientConnect(Socket: TCustomWinSocket);
begin
  if Assigned(FOnClientConnect) then FOnClientConnect(Self, Socket);
end;

procedure TServerWinSocket.ClientDisconnect(Socket: TCustomWinSocket);
begin
  if Assigned(FOnClientDisconnect) then FOnClientDisconnect(Self, Socket);
  Socket.DeferFree;
end;

procedure TServerWinSocket.ClientRead(Socket: TCustomWinSocket);
begin
  if Assigned(FOnClientRead) then FOnClientRead(Self, Socket);
end;

procedure TServerWinSocket.ClientWrite(Socket: TCustomWinSocket);
begin
  if Assigned(FOnClientWrite) then FOnClientWrite(Self, Socket);
end;

procedure TServerWinSocket.ClientErrorEvent(Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  if Assigned(FOnClientError) then FOnClientError(Self, Socket, ErrorEvent, ErrorCode);
end;

{ TCustomSocket }

procedure TCustomSocket.DoEvent(Sender: TObject; Socket: TCustomWinSocket;
  SocketEvent: TSocketEvent);
begin
  Event(Socket, SocketEvent);
end;

procedure TCustomSocket.DoError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  Error(Socket, ErrorEvent, ErrorCode);
end;

procedure TCustomSocket.Event(Socket: TCustomWinSocket; SocketEvent: TSocketEvent);
begin
  case SocketEvent of
    seLookup: if Assigned(FOnLookup) then FOnLookup(Self, Socket);
    seConnecting: if Assigned(FOnConnecting) then FOnConnecting(Self, Socket);
    seConnect:
      begin
        socket.BufferRecepcion:='';
        FActive := True;
        if Assigned(FOnConnect) then FOnConnect(Self, Socket);
      end;
    seListen:
      begin
        FActive := True;
        if Assigned(FOnListen) then FOnListen(Self, Socket);
      end;
    seDisconnect:
      begin
        FActive := False;
        if Assigned(FOnDisconnect) then FOnDisconnect(Self, Socket);
      end;
    seAccept: if Assigned(FOnAccept) then FOnAccept(Self, Socket);
    seRead: if Assigned(FOnRead) then FOnRead(Self, Socket);
    seWrite: if Assigned(FOnWrite) then FOnWrite(Self, Socket);
  end;
end;

procedure TCustomSocket.Error(Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  if Assigned(FOnError) then FOnError(Self, Socket, ErrorEvent, ErrorCode);
end;

procedure TCustomSocket.SetActive(Value: Boolean);
begin
  if Value <> FActive then
  begin
    if (csDesigning in ComponentState) or (csLoading in ComponentState) then
      FActive := Value;
    if not (csLoading in ComponentState) then
      DoActivate(Value);
  end;
end;

procedure TCustomSocket.Loaded;
begin
  inherited Loaded;
  DoActivate(FActive);
end;

procedure TCustomSocket.SetAddress(Value: string);
begin
  if CompareText(Value, FAddress) <> 0 then
  begin
    if not (csLoading in ComponentState) and FActive then
      raise ESocketError.Create(sCantChangeWhileActive);
    FAddress := Value;
  end;
end;

procedure TCustomSocket.SetHost(Value: string);
begin
  if CompareText(Value, FHost) <> 0 then
  begin
    if not (csLoading in ComponentState) and FActive then
      raise ESocketError.Create(sCantChangeWhileActive);
    FHost := Value;
  end;
end;

procedure TCustomSocket.SetPort(Value: Integer);
begin
  if FPort <> Value then
  begin
    if not (csLoading in ComponentState) and FActive then
      raise ESocketError.Create(sCantChangeWhileActive);
    FPort := Value;
  end;
end;

procedure TCustomSocket.Open;
begin
  Active := True;
end;

procedure TCustomSocket.Close;
begin
  Active := False;
end;

{ TClientSocket }
constructor TClientSocket.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FClientSocket := TClientWinSocket.Create(INVALID_SOCKET);
  FClientSocket.OnSocketEvent := DoEvent;
  FClientSocket.OnErrorEvent := DoError;
end;

destructor TClientSocket.Destroy;
begin
  FClientSocket.Free;
  inherited Destroy;
end;

procedure TClientSocket.DoActivate(Value: Boolean);
begin
  if (Value <> FClientSocket.Connected) and not (csDesigning in ComponentState) then
  begin
    if FClientSocket.Connected then
      FClientSocket.Disconnect(FClientSocket.FSocket)
    else FClientSocket.Open(FHost, FAddress, FPort);
  end;
end;

function TClientSocket.GetClientType: TClientType;
begin
  Result := FClientSocket.ClientType;
end;

procedure TClientSocket.SetClientType(Value: TClientType);
begin
  FClientSocket.ClientType := Value;
end;

{ TCustomServerSocket }

destructor TCustomServerSocket.Destroy;
begin
  FServerSocket.Free;
  inherited Destroy;
end;

procedure TCustomServerSocket.DoActivate(Value: Boolean);
begin
  if (Value <> FServerSocket.Connected) and not (csDesigning in ComponentState) then
  begin
    if FServerSocket.Connected then
      FServerSocket.Disconnect(FServerSocket.SocketHandle)
    else FServerSocket.Listen(FHost, FAddress, FPort, 1024);
  end;
end;

function TCustomServerSocket.GetGetSocketEvent: TGetSocketEvent;
begin
  Result := FServerSocket.OnGetSocket;
end;

procedure TCustomServerSocket.SetGetSocketEvent(Value: TGetSocketEvent);
begin
  FServerSocket.OnGetSocket := Value;
end;

function TCustomServerSocket.GetOnClientEvent(Index: Integer): TSocketNotifyEvent;
begin
  case Index of
    0: Result := FServerSocket.OnClientRead;
    1: Result := FServerSocket.OnClientWrite;
    2: Result := FServerSocket.OnClientConnect;
    3: Result := FServerSocket.OnClientDisconnect;
  end;
end;

procedure TCustomServerSocket.SetOnClientEvent(Index: Integer;
  Value: TSocketNotifyEvent);
begin
  case Index of
    0: FServerSocket.OnClientRead := Value;
    1: FServerSocket.OnClientWrite := Value;
    2: FServerSocket.OnClientConnect := Value;
    3: FServerSocket.OnClientDisconnect := Value;
  end;
end;

function TCustomServerSocket.GetOnClientError: TSocketErrorEvent;
begin
  Result := FServerSocket.OnClientError;
end;

procedure TCustomServerSocket.SetOnClientError(Value: TSocketErrorEvent);
begin
  FServerSocket.OnClientError := Value;
end;

{ TServerSocket }

constructor TServerSocket.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FServerSocket := TServerWinSocket.Create(INVALID_SOCKET);
  FServerSocket.OnSocketEvent := DoEvent;
  FServerSocket.OnErrorEvent := DoError;
end;

//******************************************************************************
//Sincronización de objetos:
//******************************************************************************

{ TCriticalSection }

constructor TCriticalSection.Create;
begin
  inherited Create;
  InitializeCriticalSection(FSection);
end;

destructor TCriticalSection.Destroy;
begin
  DeleteCriticalSection(FSection);
  inherited Destroy;
end;

procedure TCriticalSection.Enter;
begin
  EnterCriticalSection(FSection);
end;

procedure TCriticalSection.Leave;
begin
  LeaveCriticalSection(FSection);
end;

end.

