program EMapas;

uses
  Forms,
  windows,
  sysutils,
  dialogs,
  main in 'main.pas' {FCmundo},
  SScreen in 'SScreen.pas' {FEsperar},
  Graficos in '..\Laa\Graficos.pas',
  DirectDraw in '..\Laa\DirectDraw.pas',
  Graficador in '..\Laa\Graficador.pas',
  Demonios in '..\Laa\Demonios.pas',
  objetos in '..\Laa\objetos.pas',
  Tablero in '..\Laa\Tablero.pas',
  def_banderas in 'def_banderas.pas' {F_Banderas},
  Md5 in '..\Laa\Md5.pas',
  DXCommon in '..\Laa\DXCommon.pas';

{$R *.RES}

begin
  if not fileexists(rutaGraficosTablero+'grf\logo'+ExtArc) then
  begin
    showmessage('Este programa debe estar ubicado en la carpeta "Editores"');
    exit;
  end;
  FEsperar:=TFEsperar.create(nil);
  with FEsperar do
  try
    FEsperar.show;
    FEsperar.update;
    Application.Initialize;
    Application.CreateForm(TFCmundo, FCmundo);
  Application.CreateForm(TF_Banderas, F_Banderas);
  finally
    free;
  end;
  Application.Run;
end.
