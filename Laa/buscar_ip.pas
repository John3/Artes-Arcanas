(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit buscar_ip;

interface
uses ScktComp,classes;

type
  TGetIPClientSocket=class(TClientSocket)
  private
    fServidor:string;
    fPuerto:integer;
  public
    property Servidor:string read fServidor;
    property Puerto:integer read fPuerto;
    function SolicitarServidor(nombreServidorWEB:string):boolean;
    procedure AlConectar(Sender:TObject;Socket:TCustomWinSocket);
    procedure ObtenerServidorYPuerto(ElSocket:TCustomWinSocket);
  end;

implementation
uses sysutils,juego;

function TGetIPClientSocket.SolicitarServidor(nombreServidorWEB:string):boolean;
begin
  result:=false;
  if nombreServidorWEB='' then exit;
  OnConnect:=AlConectar;
  if Active then Close;
  fservidor:='';
  fpuerto:=0;
  ClientType:=ctNonBlocking;
  Port:=80;
  Host:=nombreServidorWEB;
  Active:=true;
  result:=true;
end;

procedure TGetIPClientSocket.AlConectar(Sender:TObject;Socket:TCustomWinSocket);
begin
{  Socket.SendText('GET /inf.txt HTTP/1.1'+#13+#10+'Host: '+host+#13+#10+
    'User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.8) Gecko/20050511 Firefox/1.0.4'+#13+#10+
    'Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'+#13+#10+
    'Accept-Language: en-us,en;q=0.7,es;q=0.3'+#13+#10+'Accept-Encoding: gzip,deflate'+#13+#10+
    'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7'+#13+#10+'Keep-Alive: 300'+#13+#10+
    'Connection: keep-alive'+#13+#10+#13+#10);}

{  Socket.SendText('GET http://'+host+'/inf.txt'+#13+#10+'Host: '+host+#13+#10+
    'User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.8) Gecko/20050511 Firefox/1.0.4'+#13+#10+
    'Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'+#13+#10+
    'Accept-Language: en-us,en;q=0.7,es;q=0.3'+#13+#10+'Accept-Encoding: gzip,deflate'+#13+#10+
    'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7'+#13+#10+'Keep-Alive: 300'+#13+#10+
    'Connection: keep-alive'+#13+#10+#13+#10);}

  Socket.SendText('GET http://'+host+'/inf.txt'+#13+#10+'Host: '+host+#13+#10+
    'User-Agent: Mozilla/5.0 '+#13+#10+
    'Accept: text/html;q=0.9,text/plain;q=0.8'+#13+#10+
    'Accept-Charset: ISO-8859-1,utf-8'+#13+#10+
    'Keep-Alive: 300'+#13+#10+
    'Connection: keep-alive'+#13+#10+#13+#10);
end;

procedure TGetIPClientSocket.ObtenerServidorYPuerto(ElSocket:TCustomWinSocket);
var posicionSeparador,posicionEspacio,code:integer;
begin
  fservidor:=trim(ElSocket.ReceiveText);
  if copy(fservidor,1,4)<>'LAA=' then exit;
  Delete(fservidor,1,4);
  posicionSeparador:=pos(':',fservidor);
  posicionEspacio:=pos(' ',fservidor);
  Val(copy(fservidor,posicionSeparador+1,posicionEspacio-posicionSeparador-1),fpuerto,code);
  if code<>0 then fpuerto:=0;
  G_GameHosting:=trim(copy(fservidor,posicionEspacio+1,255));
  Delete(fservidor,posicionSeparador,255);
  fservidor:=trim(fservidor);
end;

end.
