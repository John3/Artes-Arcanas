program Recortador;

uses
  Forms,
  main in 'main.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Optimizador de im�genes transparentes';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
