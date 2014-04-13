program Arkhos;
//{$DEFINE SOLO_UNA_INSTANCIA}
uses
  Forms,
  windows,
  smain in 'smain.pas' {MainForm},
  Mundo in 'Mundo.pas',
  Usuarios in 'Usuarios.pas',
  Demonios in '..\Laa\demonios.pas',
  objetos in '..\Laa\objetos.pas',
  Tablero in '..\Laa\Tablero.pas',
  TableroControlado in 'TableroControlado.pas',
  Globales in '..\Laa\Globales.pas',
  ScktComp in '..\Laa\scktcomp.pas',
  TrayIcon in 'TRAYICON.PAS',
  GTimer in '..\Laa\GTimer.pas';

//Para cambiar los iconos: cambiar el nombre de este res y editarlo
{$R ARKHOS.RES}
{$IFDEF SOLO_UNA_INSTANCIA}
var
  IdBOO:word;
  Cadena_ATOM_UN_SERVIDOR: array[0..11] of Char;
  ATOM_UN_SERVIDOR:Pchar;
begin
  Cadena_ATOM_UN_SERVIDOR:='Zh¯Ï‰Õ+D0%.'#0;
  Cadena_ATOM_UN_SERVIDOR[2]:=char(versionlA);
  ATOM_UN_SERVIDOR:=@Cadena_ATOM_UN_SERVIDOR;
//GlobalDeleteAtom(GlobalFindAtom(ATOM_UN_SERVIDOR));
  if GlobalFindAtom(ATOM_UN_SERVIDOR)=0 then IdBOO:=GlobalAddAtom(ATOM_UN_SERVIDOR) else exit;
{$ELSE}
begin
{$ENDIF}
  if LeerArchivoConfiguracionServidor then
  begin
    Application.Initialize;
    Application.CreateForm(TMainForm, MainForm);
  Application.Run;
  end;
{$IFDEF SOLO_UNA_INSTANCIA}
  GlobalDeleteAtom(idBOO);
{$ENDIF}
end.
