
{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{                                                       }
{       Copyright (c) 1995,97 Borland International     }
{                                                       }
{*******************************************************}
{
Editado por Sergio:

Básicamente es una version menor del MPlayer para reducir el tamaño del .exe del juego
Esta removido todo lo que tenga que ver con grabación de sonido o manejo de otro tipo de dispositivos que no use el juego
}

unit MPlayerLite;

{$R-}

interface

uses Windows, Classes, Controls, Forms, Messages,
  MMSystem,SysUtils;

type
  TMPLastAction=(mpaNone,mpaOpen,mpaClose,mpaPlay,mpaRec,mpaStop,mpaPause,mpaResume,mpaSeek,mpaEject);

  TMPGlyph = (mgEnabled, mgDisabled, mgColored);

  TMPDeviceTypes = (dtAutoSelect, dtAVIVideo, dtCDAudio, dtSequencer, dtWaveAudio,dtMP3Music,dtMPEGVideo);

  TMPTimeFormats = (tfMilliseconds, tfHMS, tfMSF, tfFrames, tfSMPTE24, tfSMPTE25,
    tfSMPTE30, tfSMPTE30Drop, tfBytes, tfSamples, tfTMSF);
  TMPModes = (mpNotReady, mpStopped, mpPlaying, mpRecording, mpSeeking,
    mpPaused, mpOpen);
  TMPNotifyValues = (nvSuccessful, nvSuperseded, nvAborted, nvFailure);

  TMPDevCaps = (mpCanStep, mpCanEject, mpCanPlay, mpCanRecord, mpUsesWindow);
  TMPDevCapsSet = set of TMPDevCaps;

  EMCIDeviceError = class(Exception);

  TMediaPlayer = class(TCustomControl)
  private
    fLastAction: TMPLastAction;
    FOnNotify: TNotifyEvent;
    MCIOpened: Boolean;
    FCapabilities: TMPDevCapsSet;
    FCanPlay: Boolean;
    FCanStep: Boolean;
    FCanEject: Boolean;
    FCanRecord: Boolean;
    FHasVideo: Boolean;
    FFlags: Longint;
    FWait: Boolean;
    FNotify: Boolean;
    FUseWait: Boolean;
    FUseNotify: Boolean;
    FUseFrom: Boolean;
    FUseTo: Boolean;
    FDeviceID: Word;
    FDeviceType: TMPDeviceTypes;
    FTo: Longint;
    FFrom: Longint;
    FFrames: Longint;
    FError: Longint;
    FNotifyValue: TMPNotifyValues;
    FDisplay: TWinControl;
    FDWidth: Integer;
    FDHeight: Integer;
    FElementName: string;
    FAutoEnable: Boolean;
    FAutoOpen: Boolean;
    FAutoRewind: Boolean;
    FShareable: Boolean;

    procedure WMGetDlgCode(var Message: TWMGetDlgCode);
      message WM_GETDLGCODE;
    procedure CheckIfOpen;
    procedure SetPosition(Value: Longint);
    procedure SetDeviceType( Value: TMPDeviceTypes );
    procedure SetWait( Flag: Boolean );
    procedure SetNotify( Flag: Boolean );
    procedure SetFrom( Value: Longint );
    procedure SetTo( Value: Longint );
    procedure SetTimeFormat( Value: TMPTimeFormats );
    procedure SetDisplay( Value: TWinControl );
    procedure SetOrigDisplay;
    procedure SetDisplayRect( Value: TRect );
    function GetDisplayRect: TRect;
    procedure GetDeviceCaps;
    function GetStart: Longint;
    function GetLength: Longint;
    function GetMode: TMPModes;
    function GetTracks: Longint;
    function GetPosition: Longint;
    function GetErrorMessage: string;
    function GetTimeFormat: TMPTimeFormats;
    function GetTrackLength(TrackNum: Integer): Longint;
    function GetTrackPosition(TrackNum: Integer): Longint;
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MMNotify(var Message: TMessage); message MM_MCINOTIFY;
    procedure DoNotify; dynamic;
  public
    destructor Destroy; override;  
    constructor Create(AOwner: TComponent); override;
    procedure Open;
    procedure Close;
    procedure Play;
    procedure Stop;
    procedure Pause; {Pause & Resume/Play}
    procedure Step;
    procedure Back;
    procedure Previous;
    procedure Next;
    procedure Eject;
    procedure Save;
    procedure PauseOnly;
    procedure Resume;
    procedure Rewind;
    property TrackLength[TrackNum: Integer]: Longint read GetTrackLength;
    property TrackPosition[TrackNum: Integer]: Longint read GetTrackPosition;
    property Capabilities: TMPDevCapsSet read FCapabilities;
    property Error: Longint read FError;
    property ErrorMessage: string read GetErrorMessage;
    property Start: Longint read GetStart;
    property Length: Longint read GetLength;
    property Tracks: Longint read GetTracks;
    property Frames: Longint read FFrames write FFrames;
    property Mode: TMPModes read GetMode;
    property LastAction: TMPLastAction read fLastAction;
    property Position: Longint read GetPosition write SetPosition;
    property Wait: Boolean read FWait write SetWait;
    property Notify: Boolean read FNotify write SetNotify;
    property NotifyValue: TMPNotifyValues read FNotifyValue;
    property StartPos: Longint read FFrom write SetFrom;
    property EndPos: Longint read FTo write SetTo;
    property DeviceID: Word read FDeviceID;
    property TimeFormat: TMPTimeFormats read GetTimeFormat write SetTimeFormat;
    property DisplayRect: TRect read GetDisplayRect write SetDisplayRect;
  published
    property AutoOpen: Boolean read FAutoOpen write FAutoOpen default False;
    property AutoRewind: Boolean read FAutoRewind write FAutoRewind default True;
    property DeviceType: TMPDeviceTypes read FDeviceType write SetDeviceType default dtAutoSelect;
    property Display: TWinControl read FDisplay write SetDisplay;
    property FileName: string read FElementName write FElementName;
    property Shareable: Boolean read FShareable write FShareable default False;
    property OnNotify: TNotifyEvent read FOnNotify write FOnNotify;
  end;

implementation

uses Consts;

const
  mci_Back     = $0899;  { mci_Step reverse }

constructor TMediaPlayer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoEnable := True;
  FAutoOpen := False;
  FAutoRewind := True;
  FDeviceType := dtAutoSelect; {select through file name extension}
  visible := false;
  fLastAction:= mpaNone;
end;

destructor TMediaPlayer.Destroy;
var
  GenParm: TMCI_Generic_Parms;
begin
  if FDeviceID <> 0 then
    mciSendCommand( FDeviceID, mci_Close, mci_Wait, Longint(@GenParm));
  inherited Destroy;
end;

procedure TMediaPlayer.Loaded;
begin
  inherited Loaded;
  if (not (csDesigning in ComponentState)) and FAutoOpen then
    Open;
end;

procedure TMediaPlayer.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

{MCI message generated when Notify=True, and MCI command completes}
procedure TMediaPlayer.MMNotify(var Message: TMessage);
begin
  case Message.WParam of
    mci_Notify_Successful: FNotifyValue := nvSuccessful;
    mci_Notify_Superseded: FNotifyValue := nvSuperseded;
    mci_Notify_Aborted: FNotifyValue := nvAborted;
    mci_Notify_Failure: FNotifyValue := nvFailure;
  end;
  DoNotify;
end;

{for MCI Commands to make sure device is open, else raise exception}
procedure TMediaPlayer.CheckIfOpen;
begin
  if not MCIOpened then raise EMCIDeviceError.Create(sNotOpenErr);
end;

procedure TMediaPlayer.DoNotify;
begin
  if Assigned(FOnNotify) then FOnNotify(Self);
end;

{***** MCI Commands *****}

procedure TMediaPlayer.Open;
const
  DeviceName: array[TMPDeviceTypes] of PChar = ('', 'AVIVideo', 'CDAudio', 'Sequencer',
    'WaveAudio','MPEGVideo2','MPEGVideo');
var
  OpenParm: TMCI_Open_Parms;
  DisplayR: TRect;
begin
  if MCIOpened then Close; {must close MCI Device first before opening another}
  OpenParm.dwCallback := Handle;
  if FDeviceType <> dtAutoSelect then {fill in Device Type}
   OpenParm.lpstrDeviceType := DeviceName[FDeviceType];
  if FElementName <> '' then
    OpenParm.lpstrElementName := PChar(FElementName);
  FFlags := 0;
  if FUseWait then
  begin
    if FWait then FFlags := mci_Wait;
    FUseWait := False;
  end
  else FFlags := mci_Wait;
  if FUseNotify then
  begin
    if FNotify then FFlags := FFlags or mci_Notify;
    FUseNotify := False;
  end;
  if FElementName <> '' then FFlags := FFlags or mci_Open_Element;
  if FDeviceType <> dtAutoSelect then FFlags := FFlags or mci_Open_Type;
  if FShareable then FFlags := FFlags or mci_Open_Shareable;
  OpenParm.dwCallback := Handle;
  fLastAction:= mpaOpen;
  FError := mciSendCommand(0,MCI_OPEN, FFlags, Longint(@OpenParm));
  if FError <> 0 then {problem opening device}
    raise EMCIDeviceError.Create(ErrorMessage)
  else {device successfully opened}
  begin
    MCIOpened := True;
    FDeviceID := OpenParm.wDeviceID;
    FFrames := Length div 10;  {default frames to step = 10% of total frames}
    GetDeviceCaps; {must first get device capabilities}
    if FHasVideo then {used for video output positioning}
    begin
      Display := FDisplay; {if one was set in design mode}
      DisplayR := GetDisplayRect;
      FDWidth := DisplayR.Right-DisplayR.Left;
      FDHeight := DisplayR.Bottom-DisplayR.Top;
    end;
    if (FDeviceType = dtCDAudio) then
      TimeFormat := tfTMSF; {set timeformat to use tracks}
  end;
end;

procedure TMediaPlayer.Close;
var
  GenParm: TMCI_Generic_Parms;
begin
  if FDeviceID <> 0 then
  begin
    FFlags := 0;
    if FUseWait then
    begin
      if FWait then FFlags := mci_Wait;
      FUseWait := False;
    end
    else FFlags := mci_Wait;
    if FUseNotify then
    begin
      if FNotify then FFlags := FFlags or mci_Notify;
      FUseNotify := False;
    end;
    GenParm.dwCallback := Handle;
    fLastAction:= mpaClose;
    FError := mciSendCommand( FDeviceID, mci_Close, FFlags, Longint(@GenParm));
    if FError = 0 then
    begin
      MCIOpened := False;
      FDeviceID := 0;
    end;
  end; {if DeviceID <> 0}
end;

procedure TMediaPlayer.Play;
var
  PlayParm: TMCI_Play_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  {if at the end of media, and not using StartPos or EndPos - go to start}
  if FAutoRewind and (Position = Length) then
    if not FUseFrom and not FUseTo then Rewind;

  FFlags := 0;
  if FUseNotify then
  begin
    if FNotify then FFlags := mci_Notify;
    FUseNotify := False;
  end else FFlags := mci_Notify;
  if FUseWait then
  begin
    if FWait then FFlags := FFlags or mci_Wait;
    FUseWait := False;
  end;
  if FUseFrom then
  begin
    FFlags := FFlags or mci_From;
    PlayParm.dwFrom := FFrom;
    FUseFrom := False; {only applies to this mciSendCommand}
  end;
  if FUseTo then
  begin
    FFlags := FFlags or mci_To;
    PlayParm.dwTo := FTo;
    FUseTo := False; {only applies to this mciSendCommand}
  end;
  PlayParm.dwCallback := Handle;
  fLastAction:= mpaPlay;
  FError := mciSendCommand( FDeviceID, mci_Play, FFlags, Longint(@PlayParm));
end;

procedure TMediaPlayer.Stop;
var
  GenParm: TMCI_Generic_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  FFlags := 0;
  if FUseWait then
  begin
    if FWait then FFlags := mci_Wait;
    FUseWait := False;
  end
  else FFlags := mci_Wait;
  if FUseNotify then
  begin
    if FNotify then FFlags := FFlags or mci_Notify;
    FUseNotify := False;
  end;
  GenParm.dwCallback := Handle;
  fLastAction:= mpaStop;
  FError := mciSendCommand( FDeviceID, mci_Stop, FFlags, Longint(@GenParm));
end;

procedure TMediaPlayer.Pause;
begin
  CheckIfOpen;//Anteriormente contenía el código del procedimiento llamado
  if Mode = mpPlaying then PauseOnly
  else
   if Mode = mpPaused then Resume;
end;

procedure TMediaPlayer.PauseOnly;
var
  GenParm: TMCI_Generic_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  FFlags := 0;
  if FUseWait then
  begin
    if FWait then FFlags := mci_Wait;
    FUseWait := False;
  end
  else FFlags := mci_Wait;
  if FUseNotify then
  begin
    if FNotify then FFlags := FFlags or mci_Notify;
    FUseNotify := False;
  end;
  GenParm.dwCallback := Handle;
  fLastAction:= mpaPause;
  FError := mciSendCommand( FDeviceID, mci_Pause, FFlags, Longint(@GenParm));
end;

procedure TMediaPlayer.Resume;
var
  GenParm: TMCI_Generic_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  FFlags := 0;
  if FUseNotify then
  begin
    if FNotify then FFlags := mci_Notify;
  end
  else FFlags := mci_Notify;
  if FUseWait then
  begin
    if FWait then FFlags := FFlags or mci_Wait;
  end;
  GenParm.dwCallback := Handle;
  fLastAction:= mpaResume;
  FError := mciSendCommand( FDeviceID, mci_Resume, FFlags, Longint(@GenParm));
  
  {if error calling resume (resume not supported),  call Play}
  if FError <> 0 then
    Play {FUseNotify & FUseWait reset by Play}
  else
  begin
    if FUseNotify then
      FUseNotify := False;
    if FUseWait then
      FUseWait := False;
  end;
end;

procedure TMediaPlayer.Next;
var
  SeekParm: TMCI_Seek_Parms;
  TempFlags: Longint;
begin
  CheckIfOpen; {raises exception if device is not open}

  FFlags := 0;
  if FUseWait then
  begin
    if FWait then FFlags := mci_Wait;
    FUseWait := False;
  end
  else FFlags := mci_Wait;
  if FUseNotify then
  begin
    if FNotify then FFlags := FFlags or mci_Notify;
    FUseNotify := False;
  end;

  TempFlags := FFlags; {preserve FFlags from GetTimeFormat & GetPosition}
  if TimeFormat = tfTMSF then {using Tracks}
  begin
    if Mode = mpPlaying then 
    begin
      if mci_TMSF_Track(Position) = Tracks then {if at last track}
         StartPos := GetTrackPosition(Tracks) {go to beg of last}
      else {go to next track}
         StartPos := GetTrackPosition((mci_TMSF_Track(Position))+1);
      Play;
      Exit;
    end
    else
    begin
      if mci_TMSF_Track(Position) = Tracks then {if at last track}
         SeekParm.dwTo := GetTrackPosition(Tracks) {go to beg of last}
      else {go to next track}
         SeekParm.dwTo := GetTrackPosition((mci_TMSF_Track(Position))+1);
      FFlags := TempFlags or mci_To;
    end;
  end
  else
    FFlags := TempFlags or mci_Seek_To_End;
    
  SeekParm.dwCallback := Handle;
  fLastAction:= mpaSeek;
  FError := mciSendCommand( FDeviceID, mci_Seek, FFlags, Longint(@SeekParm));
end; {Next}


procedure TMediaPlayer.Previous;
var
  SeekParm: TMCI_Seek_Parms;
  tpos,cpos,TempFlags: Longint;
begin
  CheckIfOpen; {raises exception if device is not open}

  FFlags := 0;
  if FUseWait then
  begin
    if FWait then FFlags := mci_Wait;
    FUseWait := False;
  end
  else FFlags := mci_Wait;
  if FUseNotify then
  begin
    if FNotify then FFlags := FFlags or mci_Notify;
    FUseNotify := False;
  end;
  
  TempFlags := FFlags; {preserve FFlags from GetTimeFormat & GetPosition}
  if TimeFormat = tfTMSF then {using Tracks}
  begin
    cpos := Position;
    tpos := GetTrackPosition(mci_TMSF_Track(Position));
    if Mode = mpPlaying then
    begin
    	{if not on first track, and at beginning of current track}
    	if (mci_TMSF_Track(cpos) <> 1) and
      	(mci_TMSF_Minute(cpos) = mci_TMSF_Minute(tpos)) and
      	(mci_TMSF_Second(cpos) = mci_TMSF_Second(tpos)) then
      	StartPos := GetTrackPosition(mci_TMSF_Track(Position)-1) {go to previous}
    	else
      	StartPos := tpos; {otherwise, go to beginning of current}
      Play;
      Exit;
	 end
	 else
	 begin
    	{if not on first track, and at beginning of current track}
    	if (mci_TMSF_Track(cpos) <> 1) and
      	(mci_TMSF_Minute(cpos) = mci_TMSF_Minute(tpos)) and
      	(mci_TMSF_Second(cpos) = mci_TMSF_Second(tpos)) then
      	SeekParm.dwTo := GetTrackPosition(mci_TMSF_Track(Position)-1) {go to previous}
    	else
      	SeekParm.dwTo := tpos; {otherwise, go to beginning of current}
    	FFlags := TempFlags or mci_To;
	 end;
  end
  else
    FFlags := TempFlags or mci_Seek_To_Start;
    
  SeekParm.dwCallback := Handle;
  fLastAction:= mpaSeek;  
  FError := mciSendCommand( FDeviceID, mci_Seek, FFlags, Longint(@SeekParm));
end; {Previous}

procedure TMediaPlayer.Step;
var
  AStepParm: TMCI_Anim_Step_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  if FHasVideo then
  begin
    if FAutoRewind and (Position = Length) then Rewind;

    FFlags := 0;
    if FUseWait then
    begin
      if FWait then FFlags := mci_Wait;
      FUseWait := False;
    end
    else FFlags := mci_Wait;
    if FUseNotify then
    begin
      if FNotify then FFlags := FFlags or mci_Notify;
      FUseNotify := False;
    end;
    FFlags := FFlags or mci_Anim_Step_Frames;
    AStepParm.dwFrames := FFrames;
    AStepParm.dwCallback := Handle;
    fLastAction:= mpaSeek;    
    FError := mciSendCommand( FDeviceID, mci_Step, FFlags, Longint(@AStepParm) );
  end; {if HasVideo}
end;

procedure TMediaPlayer.Back;
var
  AStepParm: TMCI_Anim_Step_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  if FHasVideo then
  begin
    FFlags := 0;
    if FUseWait then
    begin
      if FWait then FFlags := mci_Wait;
      FUseWait := False;
    end
    else FFlags := mci_Wait;
    if FUseNotify then
    begin
      if FNotify then FFlags := FFlags or mci_Notify;
      FUseNotify := False;
    end;
    FFlags := FFlags or mci_Anim_Step_Frames or mci_Anim_Step_Reverse;
    AStepParm.dwFrames := FFrames;
    AStepParm.dwCallback := Handle;
    fLastAction:= mpaSeek;    
    FError := mciSendCommand( FDeviceID, mci_Step, FFlags, Longint(@AStepParm) );
  end; {if HasVideo}
end; {Back}

procedure TMediaPlayer.Eject;
var
  SetParm: TMCI_Set_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  if FCanEject then
  begin
    FFlags := 0;
    if FUseWait then
    begin
      if FWait then FFlags := mci_Wait;
      FUseWait := False;
    end
    else FFlags := mci_Wait;
    if FUseNotify then
    begin
      if FNotify then FFlags := FFlags or mci_Notify;
      FUseNotify := False;
    end;
    FFlags := FFlags or mci_Set_Door_Open;
    SetParm.dwCallback := Handle;
    fLastAction:= mpaEject;
    FError := mciSendCommand( FDeviceID, mci_Set, FFlags, Longint(@SetParm) );
  end; {if CanEject}
end; {Eject}

procedure TMediaPlayer.SetPosition(Value: Longint);
var
  SeekParm: TMCI_Seek_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}

  FFlags := 0;
  if FUseWait then
  begin
    if FWait then FFlags := mci_Wait;
    FUseWait := False;
  end
  else FFlags := mci_Wait;
  if FUseNotify then
  begin
    if FNotify then FFlags := FFlags or mci_Notify;
    FUseNotify := False;
  end;
  FFlags := FFlags or mci_To;
  SeekParm.dwCallback := Handle;
  SeekParm.dwTo := Value;
  fLastAction:= mpaSeek;
  FError := mciSendCommand( FDeviceID, mci_Seek, FFlags, Longint(@SeekParm));
end;

procedure TMediaPlayer.Rewind;
var
  SeekParm: TMCI_Seek_Parms;
  RFlags: Longint;
begin
  CheckIfOpen; {raises exception if device is not open}
  RFlags := mci_Wait or mci_Seek_To_Start;
  fLastAction:= mpaSeek;
  mciSendCommand( FDeviceID, mci_Seek, RFlags, Longint(@SeekParm));
end;

function TMediaPlayer.GetTrackLength(TrackNum: Integer): Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}
  FFlags := mci_Wait or mci_Status_Item or mci_Track;
  StatusParm.dwItem := mci_Status_Length;
  StatusParm.dwTrack := Longint(TrackNum);
  mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := StatusParm.dwReturn;
end;

function TMediaPlayer.GetTrackPosition(TrackNum: Integer): Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  FFlags := mci_Wait or mci_Status_Item or mci_Track;
  StatusParm.dwItem := mci_Status_Position;
  StatusParm.dwTrack := Longint(TrackNum);
  mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := StatusParm.dwReturn;
end;

procedure TMediaPlayer.Save;
var
  SaveParm: TMCI_SaveParms;
begin
  CheckIfOpen; {raises exception if device is not open}
  if FElementName <> '' then {make sure a file has been specified to save to}
  begin
    SaveParm.lpfilename := PChar(FElementName);

    FFlags := 0;
    if FUseWait then
    begin
      if FWait then FFlags := mci_Wait;
      FUseWait := False;
    end
    else FFlags := mci_Wait;
    if FUseNotify then
    begin
      if FNotify then FFlags := FFlags or mci_Notify;
      FUseNotify := False;
    end;
    SaveParm.dwCallback := Handle;
    FFlags := FFlags or mci_Save_File;
    FError := mciSendCommand(FDeviceID, mci_Save, FFlags, Longint(@SaveParm));
    end;
end;


{*** procedures that set control flags for MCI Commands ***}
procedure TMediaPlayer.SetWait( Flag: Boolean );
begin
  if Flag <> FWait then FWait := Flag;
  FUseWait := True;
end;

procedure TMediaPlayer.SetNotify( Flag: Boolean );
begin
  if Flag <> FNotify then FNotify := Flag;
  FUseNotify := True;
end;

procedure TMediaPlayer.SetFrom( Value: Longint );
begin
  if Value <> FFrom then FFrom := Value;
  FUseFrom := True;
end;

procedure TMediaPlayer.SetTo( Value: Longint );
begin
  if Value <> FTo then FTo := Value;
  FUseTo := True;
end;


procedure TMediaPlayer.SetDeviceType( Value: TMPDeviceTypes );
begin
  if Value <> FDeviceType then FDeviceType := Value;
end;

procedure TMediaPlayer.SetTimeFormat( Value: TMPTimeFormats );
var
  SetParm: TMCI_Set_Parms;
begin
  begin
    FFlags := mci_Notify or mci_Set_Time_Format;
    SetParm.dwTimeFormat := Longint(Value);
    FError := mciSendCommand( FDeviceID, mci_Set, FFlags, Longint(@SetParm) );
  end;
end;

{setting a TWinControl to display video devices' output}
procedure TMediaPlayer.SetDisplay( Value: TWinControl );
var
  AWindowParm: TMCI_Anim_Window_Parms;
begin
  if (Value <> nil) and MCIOpened and FHasVideo then
  begin
    FFlags := mci_Wait or mci_Anim_Window_hWnd;
    AWindowParm.Wnd := Longint(Value.Handle);
    FError := mciSendCommand( FDeviceID, mci_Window, FFlags, Longint(@AWindowParm) );
    if FError <> 0 then
      FDisplay := nil {alternate window not supported}
    else
    begin
      FDisplay := Value; {alternate window supported}
      Value.FreeNotification(Self);
    end;
  end
  else FDisplay := Value;
end;

procedure TMediaPlayer.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDisplay) then
  begin
    if MCIOpened then SetOrigDisplay;
    FDisplay := nil;
  end;
end;

{ special case to set video display back to original window,
  when FDisplay's TWinControl is deleted at runtime }
procedure TMediaPlayer.SetOrigDisplay;
var
  AWindowParm: TMCI_Anim_Window_Parms;
begin
  if MCIOpened and FHasVideo then
  begin
    FFlags := mci_Wait or mci_Anim_Window_hWnd;
    AWindowParm.Wnd := mci_Anim_Window_Default;
    FError := mciSendCommand( FDeviceID, mci_Window, FFlags, Longint(@AWindowParm) );
  end;
end;

{setting a rect for user-defined form to display video devices' output}
procedure TMediaPlayer.SetDisplayRect( Value: TRect );
var
  RectParms: TMCI_Anim_Rect_Parms;
  WorkR: TRect;
begin
  if MCIOpened and FHasVideo then
  begin
    {special case, use default width and height}
    if (Value.Bottom = 0) and (Value.Right = 0) then
    begin
      with Value do
        WorkR := Rect(Left, Top, FDWidth, FDHeight);
    end
    else WorkR := Value;
    FFlags := mci_Anim_RECT or mci_Anim_Put_Destination;
    RectParms.rc := WorkR;
    FError := mciSendCommand( FDeviceID, mci_Put, FFlags, Longint(@RectParms) );
  end;
end;


{***** functions to get device capabilities and status ***}

function TMediaPlayer.GetDisplayRect: TRect;
var
  RectParms: TMCI_Anim_Rect_Parms;
begin
  if MCIOpened and FHasVideo then
  begin
    FFlags := mci_Anim_Where_Destination;
    FError := mciSendCommand( FDeviceID, mci_Where, FFlags, Longint(@RectParms) );
    Result := RectParms.rc;
  end;
end;

{ fills in static properties upon opening MCI Device }
procedure TMediaPlayer.GetDeviceCaps;
var
  DevCapParm: TMCI_GetDevCaps_Parms;
  devType: Longint;
  RectParms: TMCI_Anim_Rect_Parms;
  WorkR: TRect;
begin
  FFlags := mci_Wait or mci_GetDevCaps_Item;

  DevCapParm.dwItem := mci_GetDevCaps_Can_Play;
  mciSendCommand(FDeviceID, mci_GetDevCaps, FFlags,  Longint(@DevCapParm) );
  FCanPlay := Boolean(DevCapParm.dwReturn);
  if FCanPlay then Include(FCapabilities, mpCanPlay);

  DevCapParm.dwItem := mci_GetDevCaps_Can_Record;
  mciSendCommand(FDeviceID, mci_GetDevCaps, FFlags,  Longint(@DevCapParm) );
  FCanRecord := Boolean(DevCapParm.dwReturn);
  if FCanRecord then Include(FCapabilities, mpCanRecord);

  DevCapParm.dwItem := mci_GetDevCaps_Can_Eject;
  mciSendCommand(FDeviceID, mci_GetDevCaps, FFlags,  Longint(@DevCapParm) );
  FCanEject := Boolean(DevCapParm.dwReturn);
  if FCanEject then Include(FCapabilities, mpCanEject);

  DevCapParm.dwItem := mci_GetDevCaps_Has_Video;
  mciSendCommand(FDeviceID, mci_GetDevCaps, FFlags,  Longint(@DevCapParm) );
  FHasVideo := Boolean(DevCapParm.dwReturn);
  if FHasVideo then Include(FCapabilities, mpUsesWindow);

  DevCapParm.dwItem := mci_GetDevCaps_Device_Type;
  mciSendCommand(FDeviceID, mci_GetDevCaps, FFlags,  Longint(@DevCapParm) );
  devType := DevCapParm.dwReturn;
  if (devType = mci_DevType_Animation) or
     (devType = mci_DevType_Digital_Video) or
     (devType = mci_DevType_Overlay) or
     (devType = mci_DevType_VCR) then FCanStep := True;
  if FCanStep then Include(FCapabilities, mpCanStep);

  FFlags := mci_Anim_Where_Source;
  FError := mciSendCommand( FDeviceID, mci_Where, FFlags, Longint(@RectParms) );
  WorkR := RectParms.rc;
  FDWidth := WorkR.Right - WorkR.Left;
  FDHeight := WorkR.Bottom - WorkR.Top;
end; {GetDeviceCaps}

function TMediaPlayer.GetStart: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}
  FFlags := mci_Wait or mci_Status_Item or mci_Status_Start;
  StatusParm.dwItem := mci_Status_Position;
  FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := StatusParm.dwReturn;
end;

function TMediaPlayer.GetLength: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}
  FFlags := mci_Wait or mci_Status_Item;
  StatusParm.dwItem := mci_Status_Length;
  FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := StatusParm.dwReturn;
end;

function TMediaPlayer.GetTracks: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}
  FFlags := mci_Wait or mci_Status_Item;
  StatusParm.dwItem := mci_Status_Number_Of_Tracks;
  FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := StatusParm.dwReturn;
end;

function TMediaPlayer.GetMode: TMPModes;
var
  StatusParm: TMCI_Status_Parms;
begin
  FFlags := mci_Wait or mci_Status_Item;
  StatusParm.dwItem := mci_Status_Mode;
  FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := TMPModes(StatusParm.dwReturn - 524); {MCI Mode #s are 524+enum}
end;

function TMediaPlayer.GetPosition: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  FFlags := mci_Wait or mci_Status_Item;
  StatusParm.dwItem := mci_Status_Position;
  FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := StatusParm.dwReturn;
end;

function TMediaPlayer.GetTimeFormat: TMPTimeFormats;
var
  StatusParm: TMCI_Status_Parms;
begin
  CheckIfOpen; {raises exception if device is not open}
  FFlags := mci_Wait or mci_Status_Item;
  StatusParm.dwItem := mci_Status_Time_Format;
  FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
  Result := TMPTimeFormats(StatusParm.dwReturn);
end;

function TMediaPlayer.GetErrorMessage: string;
var
  ErrMsg: array[0..4095] of Char;
begin
  if not mciGetErrorString(FError, ErrMsg, SizeOf(ErrMsg)) then
    Result := SMCIUnknownError
  else SetString(Result, ErrMsg, StrLen(ErrMsg));
end;

end.
