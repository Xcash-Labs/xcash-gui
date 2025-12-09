; X-Cash GUI Wallet Installer for Windows
; Forked from the Monero Fluorine Fermi GUI Wallet Installer
; Copyright (c) 2017-2024, The Monero Project
; X-Cash modifications (c) 2025, X-Cash contributors
; See LICENSE

#define GuiVersion GetFileVersion("bin\xcash-wallet-gui.exe")

[Setup]
AppName=xCash GUI Wallet
; For InnoSetup this is the property that uniquely identifies the application as such
; Thus it's important to keep this stable over releases

AppVersion={#GuiVersion}
VersionInfoVersion={#GuiVersion}
DefaultDirName={commonpf}\xCash GUI Wallet
DefaultGroupName=xCash GUI Wallet
UninstallDisplayIcon={app}\xcash-wallet-gui.exe
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64 arm64
WizardSmallImageFile=WizardSmallImage.bmp
WizardImageFile=WelcomeImage.bmp
DisableWelcomePage=no
LicenseFile=LICENSE
AppPublisher=The X-Cash Developer Community
AppPublisherURL=https://xcashlabs.org
TimeStampsInUTC=yes
CompressionThreads=1

UsedUserAreasWarning=no

[Messages]
SetupWindowTitle=%1 {#GuiVersion} Installer

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"

[Dirs]
Name: "{app}";
Name: "{app}\p2pool"; Permissions: users-full

[Files]
; The use of the flag "ignoreversion" for the following entries leads to the following behaviour:
; When updating / upgrading an existing installation ALL existing files are replaced with the files in this
; installer, regardless of file dates, version info within the files, or type of file.

Source: {#file AddBackslash(SourcePath) + "ReadMe.htm"}; DestDir: "{app}"; DestName: "ReadMe.htm"; Flags: ignoreversion
Source: "FinishImage.bmp"; Flags: dontcopy
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion

; xCash GUI wallet exe and guide
Source: "bin\xcash-wallet-gui.exe"; DestDir: "{app}"; Flags: ignoreversion
; Source: "bin\xcash-gui-wallet-guide.pdf"; DestDir: "{app}"; DestName: "xcash-gui-wallet-guide.pdf"; Flags: ignoreversion

; xCash CLI wallet
Source: "bin\extras\xcash-wallet-cli.exe"; DestDir: "{app}"; DestName: "xcash-wallet-cli.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-gen-trusted-multisig.exe"; DestDir: "{app}"; DestName: "xcash-gen-trusted-multisig.exe"; Flags: ignoreversion

; xCash wallet RPC interface implementation
Source: "bin\extras\xcash-wallet-rpc.exe"; DestDir: "{app}"; DestName: "xcash-wallet-rpc.exe"; Flags: ignoreversion

; xCash daemon (not shipped in remote-node-only builds)
;Source: "bin\xcashd.exe"; DestDir: "{app}"; Flags: ignoreversion

; xCash daemon wrapped in a batch file that stops before the text window closes (not shipped)
;Source: "xcash-daemon.bat"; DestDir: "{app}"; Flags: ignoreversion

; xCash blockchain utilities
Source: "bin\extras\xcash-blockchain-export.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-export.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-import.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-import.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-mark-spent-outputs.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-mark-spent-outputs.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-usage.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-usage.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-ancestry.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-ancestry.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-depth.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-depth.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-prune-known-spent-data.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-prune-known-spent-data.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-prune.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-prune.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-blockchain-stats.exe"; DestDir: "{app}"; DestName: "xcash-blockchain-stats.exe"; Flags: ignoreversion
Source: "bin\extras\xcash-gen-ssl-cert.exe"; DestDir: "{app}"; DestName: "xcash-gen-ssl-cert.exe"; Flags: ignoreversion

; Qt Quick 2D Renderer fallback for systems / environments with "low-level graphics"
Source: "bin\start-low-graphics-mode.bat"; DestDir: "{app}"; Flags: ignoreversion

; Mesa, open-source OpenGL implementation; part of "low-level graphics" support
Source: "bin\opengl32sw.dll"; DestDir: "{app}"; Flags: ignoreversion

[InstallDelete]
Type: filesandordirs; Name: "{app}\translations"
Type: files; Name: "{app}\Qt5*.dll"
Type: filesandordirs; Name: "{app}\Qt"
Type: filesandordirs; Name: "{app}\audio"
Type: filesandordirs; Name: "{app}\bearer"
Type: filesandordirs; Name: "{app}\platforms"
Type: filesandordirs; Name: "{app}\platforminputcontexts"
Type: filesandordirs; Name: "{app}\iconengines"
Type: filesandordirs; Name: "{app}\imageformats"
Type: filesandordirs; Name: "{app}\QtMultimedia"
Type: filesandordirs; Name: "{app}\mediaservice"
Type: filesandordirs; Name: "{app}\playlistformats"
Type: filesandordirs; Name: "{app}\QtGraphicalEffects"
Type: filesandordirs; Name: "{app}\private"
Type: filesandordirs; Name: "{app}\QtQml"
Type: filesandordirs; Name: "{app}\QtQuick"
Type: filesandordirs; Name: "{app}\QtQuick.2"
Type: filesandordirs; Name: "{app}\Material"
Type: filesandordirs; Name: "{app}\Universal"
Type: filesandordirs; Name: "{app}\scenegraph"
Type: filesandordirs; Name: "{app}\p2pool"
Type: files; Name: "{app}\D3Dcompiler_47.dll"
Type: files; Name: "{app}\libbz2-1.dll"
Type: files; Name: "{app}\libEGL.dll"
Type: files; Name: "{app}\libGLESV2.dll"
Type: files; Name: "{app}\libfreetype-6.dll"
Type: files; Name: "{app}\libgcc_s_seh-1.dll"
Type: files; Name: "{app}\libglib-2.0-0.dll"
Type: files; Name: "{app}\libgraphite2.dll"
Type: files; Name: "{app}\libharfbuzz-0.dll"
Type: files; Name: "{app}\libiconv-2.dll"
Type: files; Name: "{app}\libicudt??.dll"
Type: files; Name: "{app}\libicuin??.dll"
Type: files; Name: "{app}\libicuio??.dll"
Type: files; Name: "{app}\libicutu??.dll"
Type: files; Name: "{app}\libicuuc??.dll"
Type: files; Name: "{app}\libintl-8.dll"
Type: files; Name: "{app}\libjpeg-8.dll"
Type: files; Name: "{app}\liblcms2-2.dll"
Type: files; Name: "{app}\liblzma-5.dll"
Type: files; Name: "{app}\libmng-2.dll"
Type: files; Name: "{app}\libpcre-1.dll"
Type: files; Name: "{app}\libpcre16-0.dll"
Type: files; Name: "{app}\libpcre2-16-0.dll"
Type: files; Name: "{app}\libpng16-16.dll"
Type: files; Name: "{app}\libstdc++-6.dll"
Type: files; Name: "{app}\libtiff-5.dll"
Type: files; Name: "{app}\libwinpthread-1.dll"
Type: files; Name: "{app}\zlib1.dll"
Type: files; Name: "{app}\libhidapi-0.dll"
Type: files; Name: "{app}\libeay32.dll"
Type: files; Name: "{app}\ssleay32.dll"
Type: files; Name: "{app}\start-high-dpi.bat"

[Tasks]
Name: desktopicon; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:";

[Run]
Filename: "{app}\ReadMe.htm"; Description: "Show ReadMe"; Flags: postinstall shellexec skipifsilent

; DON'T offer to run the wallet right away, let the people read about initial blockchain download first in the ReadMe

[Code]
function InitializeUninstall(): Boolean;
var s: String;
begin
  s := 'Please note: Uninstall will not delete any wallets that you created.';
  s := s + #13#10#13#10 + 'If you do not need them anymore you have to delete them manually.';
  MsgBox(s, mbInformation, MB_OK);
  Result := true;
end;

[Icons]
; Icons in the "xCash GUI Wallet" program group
Name: "{group}\GUI Wallet"; Filename: "{app}\xcash-wallet-gui.exe";
; Name: "{group}\GUI Wallet Guide"; Filename: "{app}\xcash-gui-wallet-guide.pdf"; IconFilename: "{app}\xcash-wallet-gui.exe"
Name: "{group}\Uninstall GUI Wallet"; Filename: "{uninstallexe}"

; Sub-folder "Utilities" (Windows 10+ usually flattens this)
Name: "{group}\Utilities\Read Me"; Filename: "{app}\ReadMe.htm"

; CLI wallet: Needs a working directory ("Start in:") set in the icon
Name: "{group}\Utilities\Textual (CLI) Wallet"; Filename: "{app}\xcash-wallet-cli.exe"; WorkingDir: "{userdocs}\xCash\wallets"

; Icons for troubleshooting / testing / debugging
Name: "{group}\Utilities\x (Check Default Wallet Folder)"; Filename: "{win}\Explorer.exe"; Parameters: """{userdocs}\xCash\wallets"""
Name: "{group}\Utilities\x (Check GUI Wallet Log)"; Filename: "Notepad"; Parameters: """{userappdata}\xcash-wallet-gui\xcash-wallet-gui.log"""
Name: "{group}\Utilities\x (Try GUI Wallet Low Graphics Mode)"; Filename: "{app}\start-low-graphics-mode.bat"

; Desktop icon, optional
Name: "{commondesktop}\xCash GUI Wallet"; Filename: "{app}\xcash-wallet-gui.exe"; Tasks: desktopicon

[Registry]
; Optional: clean up old Monero keys (can be kept or removed)
Root: HKCU; Subkey: "Software\monero-project"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\monero-project\monero-core"; Flags: uninsdeletekey

; Configure a custom URI scheme: Links starting with "xcash:" will start the GUI wallet exe
; Used to easily start payments; example URI: "xcash://<address>?tx_amount=5.0"
Root: HKCR; Subkey: "xcash"; ValueType: "string"; ValueData: "URL:xCash Payment Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "xcash"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""
Root: HKCR; Subkey: "xcash\DefaultIcon"; ValueType: "string"; ValueData: "{app}\xcash-wallet-gui.exe,0"
Root: HKCR; Subkey: "xcash\shell\open\command"; ValueType: "string"; ValueData: """{app}\xcash-wallet-gui.exe"" ""%1"""

; Configure a custom URI scheme: Links starting with "xcashseed:" will start the GUI wallet exe
; Used to easily hand over custom seed node info to the wallet, with an URI of the form "xcashseed://a.b.c.d:port"
Root: HKCR; Subkey: "xcashseed"; ValueType: "string"; ValueData: "URL:xCash Seed Node Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "xcashseed"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""
Root: HKCR; Subkey: "xcashseed\DefaultIcon"; ValueType: "string"; ValueData: "{app}\xcash-wallet-gui.exe,0"
Root: HKCR; Subkey: "xcashseed\shell\open\command"; ValueType: "string"; ValueData: """{app}\xcash-wallet-gui.exe"" ""%1"""
