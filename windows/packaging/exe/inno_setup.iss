[Setup]
AppId=B9F6E402-0CAE-4045-BDE6-14BD6C39C4EA
AppVersion=1.12.1+26
AppName=ensound
AppPublisher=kunalbiz18
AppPublisherURL=https://github.com/kunalbiz18/ensound
AppSupportURL=https://github.com/kunalbiz18/ensound
AppUpdatesURL=https://github.com/kunalbiz18/ensound
DefaultDirName={autopf}\ensound
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=ensound-1.12.1
Compression=lzma
SolidCompression=yes
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
WizardStyle=modern
PrivilegesRequired=lowest
LicenseFile=..\..\LICENSE
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\ensound.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\ensound"; Filename: "{app}\ensound.exe"
Name: "{autodesktop}\ensound"; Filename: "{app}\ensound.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\ensound.exe"; Description: "{cm:LaunchProgram,{#StringChange('ensound', '&', '&&')}}"; Flags: nowait postinstall skipifsilent
