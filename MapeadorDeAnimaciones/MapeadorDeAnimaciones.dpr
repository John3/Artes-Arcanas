program MapeadorDeAnimaciones;

uses
  Forms,
  main in 'main.pas' {FormMain},
  objetos in '..\Laa\objetos.pas',
  Demonios in '..\Laa\Demonios.pas',
  VisorAnimacion in 'VisorAnimacion.pas' {FormVisor},
  Reportes in 'Reportes.pas' {FormReporte};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormReporte, FormReporte);
  Application.CreateForm(TFormVisor, FormVisor);
  Application.Run;
end.
