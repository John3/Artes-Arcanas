//Utilitarios para manejo de dlls de direct sound y direct draw
unit DXCommon;

//Codigo original:
(*==========================================================================;
 *
 *  DirectX 7.0 Delphi adaptation by Erik Unger
 *
 *  Download: http://www.delphi-jedi.org/DelphiGraphics/
 *  E-Mail: DelphiDirectX@next-reality.com
 *
 ***************************************************************************)


interface
uses Windows;

function IsNTandDelphiRunning : boolean;

implementation
function IsNTandDelphiRunning : boolean;
var
  OSVersion  : TOSVersionInfo;
  ProgName   : array[0..255] of char;
begin
  OSVersion.dwOsVersionInfoSize := sizeof(OSVersion);
  GetVersionEx(OSVersion);
  ProgName[0] := #0;
  lstrcat(ProgName, PChar(ParamStr(0)));
  CharLowerBuff(ProgName, SizeOf(ProgName));
  // Not running in NT or program is not Delphi itself ?
  result := ( (OSVersion.dwPlatformID = VER_PLATFORM_WIN32_NT) and
              (Pos('delphi32.exe', string(ProgName)) > 0) );
end;

end.
