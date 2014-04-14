program MANARC;

uses
  Sysutils,
  Dialogs,
  Forms,
  main in 'main.pas' {Form1},
  objetos in '..\Laa\objetos.pas',
  Demonios in '..\Laa\Demonios.pas';

{$R *.RES}

begin
  if FileExists('..\laa\bin\cjr.b') then
  begin
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  end
  else
    showmessage('Este programa debe estar ubicado en la carpeta "Editores"');
end.
