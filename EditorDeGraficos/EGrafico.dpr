program EGrafico;

uses
  Forms,
  Elementos in 'Elementos.pas' {Form1},
  objetos in '..\Laa\objetos.pas',
  Tablero in '..\Laa\Tablero.pas',
  Demonios in '..\Laa\Demonios.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
