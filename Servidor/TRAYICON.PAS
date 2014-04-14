{ TTrayIcon VCL. Version 1.1

  Requires:  Delphi 2.0 32 bit.

  Function: Adds an icon to the Windows 95 Tool Tray and
      has events to respond to mouse clicks.

  This component is based on the TToolIcon VCL that was written by
  Derek Stutsman (dereks@metronet.com).  He based his component on
  TWinControl, so it showed up as a clear, blank, resizable window at
  design time and also had more properties than the component actually
  needed.  This made it really hard to find on a busy form sometimes.

  I changed it so it would be based on TComponent so that it was readily
  visible at design time and also did not cover anything at run-time.
  The additional Top, left, width, etc. properties are also no longer
  necessary.  I added a ShowDesigning property so that you could test
  it at design time, but then turn it off so that TWO icons weren't shown
  on the tool tray when developing and testing.

  One strange anomaly that I worked around but don't know why it happens -
  if a ToolTip is not specified, then at run-time the icon shows up as
  blank.  If a ToolTip is specified, everything works fine.  To fix this,
  I set up another windows message that set the tool tip if it was blank -
  this ensures proper operation at all times, but I don't know why this
  is necessary.  If you can figure it out, send me some mail and let me
  know!

  This is freeware (as was the original).  If you make cool changes to it,
  please send them to me.

  Enjoy!

  Pete Ness
  Compuserve ID: 102347,710
  Internet: 102347.710@compuserve.com
  http:\\ourworld.compuserve.com\homepages\peteness

  Release history:

  3/8/96 - Version 1.0
     Release by Derek Stutsman of TToolIcon version 1.0

  3/12/96 - Version 1.1

     Changed as outlined above by me (Pete Ness) and renamed to TTrayIcon.

  3/29/96 - Version 1.2
     Add default window handling to allow closing when Win95 shutdown.
     Previously, you had to manually close your application before closing
     Windows 95.

  }



unit TrayIcon;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, ShellAPI, Forms;

const WM_TOOLTRAYICON = WM_USER+1;
      WM_RESETTOOLTIP = WM_USER+2;

type

  TTrayIcon = class(TComponent)

  private

  { Field Variables }

    IconData: TNOTIFYICONDATA;
    fIcon : TIcon;
    fToolTip : String;
    fWindowHandle : HWND;
    fActive : boolean;
    fShowDesigning : Boolean;

  { Events }

    fOnClick     : TNotifyEvent;
    fOnDblClick  : TNotifyEvent;
    fOnRightClick : TMouseEvent;

    function AddIcon : boolean;
    function ModifyIcon : boolean;
    function DeleteIcon : boolean;

    procedure SetActive(Value : boolean);
    procedure SetShowDesigning(Value : boolean);
    procedure SetIcon(Value : TIcon);
    procedure SetToolTip(Value : String);
    procedure WndProc(var msg : TMessage);

    procedure FillDataStructure;

  public
    destructor destroy; override;

  public
    constructor create(aOwner : TComponent); override;

  published

    property Active : boolean read fActive write SetActive;
    property ShowDesigning : boolean read fShowDesigning write SetShowDesigning;
    property Icon : TIcon read fIcon write SetIcon;
    property ToolTip : string read fTooltip write SetToolTip;

    property OnClick     : TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick  : TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnRightClick : TMouseEvent  read FOnRightClick write FonRightClick;

  end;

//procedure Register;

implementation

procedure TTrayIcon.SetActive(Value : boolean);
begin
   if value <> fActive then begin
     fActive := Value;
     if not (csdesigning in ComponentState) then begin
        if Value then begin
           AddIcon;
        end else begin
           DeleteIcon;
        end;
     end;
  end;
end;

procedure TTrayIcon.SetShowDesigning(Value : boolean);
begin
  if csdesigning in ComponentState then begin
     if value <> fShowDesigning then begin
        fShowDesigning := Value;
        if Value then begin
           AddIcon;
        end else begin
           DeleteIcon;
        end;
     end;
  end;
end;

procedure TTrayIcon.SetIcon(Value : Ticon);
begin
  if Value <> fIcon then
    begin
      fIcon.Assign(value);
      ModifyIcon;
    end;
end;

procedure TTrayIcon.SetToolTip(Value : string);
begin

   // This routine ALWAYS re-sets the field value and re-loads the
   // icon.  This is so the ToolTip can be set blank when the component
   // is first loaded.  If this is changed, the icon will be blank on
   // the tray when no ToolTip is specified.

   if length( Value ) > 62 then
      Value := copy(Value,1,62);
   fToolTip := value;
   ModifyIcon;

end;

constructor TTrayIcon.create(aOwner : Tcomponent);
begin
  inherited create(aOwner);
  {$WARN SYMBOL_DEPRECATED OFF}
  FWindowHandle := AllocateHWnd( WndProc );
  {$WARN SYMBOL_DEPRECATED ON}
  FIcon := TIcon.Create;
end;

destructor TTrayIcon.destroy;
begin
  if (not (csDesigning in ComponentState) and fActive)
     or ((csDesigning in ComponentState) and fShowDesigning) then
        DeleteIcon;

  FIcon.Free;
  {$WARN SYMBOL_DEPRECATED OFF}
  DeAllocateHWnd( FWindowHandle );
  {$WARN SYMBOL_DEPRECATED ON}
  inherited destroy;
end;

procedure TTrayIcon.FillDataStructure;
begin

  with IconData do begin

     cbSize := sizeof(TNOTIFYICONDATA);
     wnd := FWindowHandle;
     uID := 0; // is not passed in with message so make it 0
     uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
     hIcon := fIcon.Handle;
     StrPCopy(szTip,fToolTip);
     uCallbackMessage := WM_TOOLTRAYICON;
  end;
end;

function TTrayIcon.AddIcon : boolean;
begin
   FillDataStructure;
   result := Shell_NotifyIcon(NIM_ADD,@IconData);

   // For some reason, if there is no tool tip set up, then the icon
   // doesn't display.  This fixes that.
   if fToolTip = '' then
      PostMessage( fWindowHandle, WM_RESETTOOLTIP,0,0 );
end;

function TTrayIcon.ModifyIcon : boolean;
begin
   FillDataStructure;
   if fActive then
      result := Shell_NotifyIcon(NIM_MODIFY,@IconData)
   else
      result := True;
end;

function TTrayIcon.DeleteIcon : boolean;
begin
   result := Shell_NotifyIcon(NIM_DELETE,@IconData);
end;

procedure TTrayIcon.WndProc(var msg : TMessage);
var MouseCo: Tpoint;
begin
   with msg do
     if (msg = WM_RESETTOOLTIP) then
        SetToolTip( fToolTip )
     else if (msg = WM_TOOLTRAYICON) then begin
        case lParam of
           WM_LBUTTONDBLCLK   : if assigned (FOnDblClick) then FOnDblClick(self);
           WM_LBUTTONUP       : if assigned(FOnClick)then FOnClick(self);
           WM_RBUTTONUP       : if assigned (FOnRightClick)then
                                  begin
                                    GetCursorPos(MouseCo);
                                    FOnRightClick(self,mbRight,[],MouseCo.x,MouseCo.y);
                                  end;
        end;
     end
     else // Handle all messages with the default handler
        Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);

end;

{
procedure Register;
begin
  RegisterComponents('Win95', [TTrayIcon]);
end;
}

end.
