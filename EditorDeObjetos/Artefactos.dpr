program Artefactos;

uses
  Forms,
  main in 'main.pas' {Form1},
  objetos in '..\Laa\objetos.pas',
  GIFImage in 'GIFImage.pas',
  Demonios in '..\Laa\Demonios.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
