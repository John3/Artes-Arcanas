(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit GTimer;
interface
uses
  Windows, Messages, Classes, Controls, Forms;
type
  {  TGTimer  }
  TGTimerEvent = procedure(Sender: TObject) of object;
  TGTimer = class(TObject)
  private
    FInterval: integer;
    FOldTime: DWORD;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnTimer: TGTimerEvent;
    FLastIntervalMs: Integer;
    FLagCount:integer;
    FActiveOnly: Boolean;
    FEnabled: Boolean;
    FInitialized: Boolean;
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    function AppProc(var Message: TMessage): Boolean;
    procedure Finalize;
    procedure Initialize;
    procedure Resume;
    procedure SetActiveOnly(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: integer);
    procedure Suspend;
  protected
    procedure DoActivate; virtual;
    procedure DoDeactivate; virtual;
  public
    destructor Destroy; override;
    property LagCount: Integer read FLagCount;
    constructor Create;
    property LastIntervalMs: Integer read FLastIntervalMs;
  published
    property ActiveOnly: Boolean read FActiveOnly write SetActiveOnly;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Interval: integer read FInterval write SetInterval;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnTimer: TGTimerEvent read FOnTimer write FOnTimer;
  end;

implementation

uses mmsystem;

{  TGTimer  }
constructor TGTimer.Create;
begin
  inherited Create;
  FActiveOnly := False;
  FEnabled := True;
  Interval := 1000;
  FLastIntervalMs := FInterval;
  FLagCount := 0;
  Application.HookMainWindow(AppProc);
  timeBeginPeriod(10);
end;

destructor TGTimer.Destroy;
begin
  Finalize;
  timeEndPeriod(10);
  Application.UnHookMainWindow(AppProc);
  inherited Destroy;
end;

procedure TGTimer.AppIdle(Sender: TObject; var Done: Boolean);
var
  t: DWORD;
  dt: integer;
begin
  Done := False;
  //t := getTickCount(); //Very imprecise
  t := TimeGetTime();
  dt := t-FOldTime;
  if dt>=FInterval then
  begin
    FOldTime:=t;
    fLagCount:=dt-FInterval;
    FLastIntervalMs:=dt;
    //DoTimer
    if Assigned(FOnTimer) then FOnTimer(Self);
  end
  else
  begin
    Sleep(FInterval-dt);
  end;
end;

function TGTimer.AppProc(var Message: TMessage): Boolean;
begin
  Result := False;
  case Message.Msg of
    CM_ACTIVATE:
        begin
          DoActivate;
          if FInitialized and FActiveOnly then Resume;
        end;
    CM_DEACTIVATE:
        begin
          DoDeactivate;
          if FInitialized and FActiveOnly then Suspend;
        end;
  end;
end;

procedure TGTimer.DoActivate;
begin
  if Assigned(FOnActivate) then FOnActivate(Self);
end;

procedure TGTimer.DoDeactivate;
begin
  if Assigned(FOnDeactivate) then FOnDeactivate(Self);
end;

procedure TGTimer.Finalize;
begin
  if FInitialized then
  begin
    Suspend;
    FInitialized := False;
  end;
end;

procedure TGTimer.Initialize;
begin
  Finalize;
  if (not ActiveOnly) or Application.Active then Resume;
  FInitialized := True;
end;

procedure TGTimer.Resume;
begin
  FOldTime := getTickCount();
  Application.OnIdle := AppIdle;
end;

procedure TGTimer.SetActiveOnly(Value: Boolean);
begin
  if FActiveOnly<>Value then
  begin
    FActiveOnly := Value;
    if Application.Active and FActiveOnly then
      if FInitialized and FActiveOnly then Suspend;
  end;
end;

procedure TGTimer.SetEnabled(Value: Boolean);
begin
  if FEnabled<>Value then
  begin
    FEnabled := Value;
    if FEnabled then Initialize else Finalize;
  end;
end;

procedure TGTimer.SetInterval(Value: integer);
begin
  if FInterval<>Value then
  begin
    if Value<1 then Value:=1;
    FInterval:=Value;
  end;
end;

procedure TGTimer.Suspend;
begin
  Application.OnIdle := nil;
end;

end.

