program mons;

uses
  Forms,
  SysUtils,
  Dialogs,
  main in 'main.pas' {Form1},
  objetos in '..\Laa\objetos.pas',
  Globales in '..\Laa\Globales.pas',
  Demonios in '..\Laa\Demonios.pas';

{$R *.RES}

begin
  if FileExists('..\laa\bin\std.mon') then
  begin
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  end
  else
    showmessage('Este programa debe estar ubicado en la carpeta "Editores"');
end.
