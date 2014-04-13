program Laa;//Leyenda de las artes arcanas.
uses
  Forms in 'Forms.pas',
  Juego in 'Juego.pas' {JForm},
  Tablero in 'Tablero.pas',
  Sprites in 'Sprites.pas',
  objetos in 'objetos.pas',
  Graficador in 'Graficador.pas',
  Demonios in 'Demonios.pas',
  DirectDraw in 'DirectDraw.pas',
  UCliente in 'UCliente.pas',
  Graficos in 'Graficos.pas',
  InterfazDS in 'InterfazDS.pas',
  DirectSound in 'DirectSound.pas',
  LectorWAV in 'LectorWAV.pas',
  Sonidos in 'Sonidos.pas',
  UMensajes in 'UMensajes.pas',
  MundoEspejo in 'MundoEspejo.pas',
  Globales in 'Globales.pas',
  GTimer in 'GTimer.pas',
  MPlayerLite in 'mplayerLite.pas',
  ScktComp in 'scktcomp.pas',
  URapidas in 'URapidas.pas',
  UEstandartes in 'UEstandartes.pas' {FEstandartes},
  UColor8 in 'UColor8.pas',
  buscar_ip in 'buscar_ip.pas',
  Gboton in 'Gboton.pas',
  Circbuf in 'Midi\CIRCBUF.PAS',
  Delphmcb in 'Midi\DELPHMCB.PAS',
  Midicons in 'Midi\Midicons.pas',
  Mididefs in 'Midi\MIDIDEFS.PAS',
  MidiFile in 'Midi\MidiFile.pas',
  MidiIn in 'Midi\Midiin.pas',
  MidiOut in 'Midi\MidiOut.pas',
  MidiScope in 'Midi\MidiScope.pas',
  Miditype in 'Midi\MIDITYPE.PAS';

{$R Laa.RES}
begin
  ID_ATOM_SOLO_UNA_INSTANCIA:=0;
  if VerificarArchivosYConfiguraciones then
  begin
    Application.Initialize;
    Application.CreateForm(TJForm, JForm);
    Application.CreateForm(TFEstandartes, FEstandartes);
    Application.Run;
  end;
end.
