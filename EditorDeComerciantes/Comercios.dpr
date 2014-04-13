program Comercios;

uses
  Forms,
  sysUtils,
  Dialogs,
  main in 'main.pas' {FMain},
  objetos in '..\Laa\objetos.pas',
  Tablero in '..\Laa\Tablero.pas',
  Demonios in '..\Laa\Demonios.pas';

{$R *.RES}

begin
  if fileExists('..\laa\grf\obj.jpg') then
  begin
    Application.Initialize;
    Application.CreateForm(TFMain, FMain);
  Application.Run;
  end
  else
    showmessage('Este programa debe estar ubicado en la carpeta "Editores"');
end.
