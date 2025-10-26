[Setup]
AppId=B9F6E402-0CAE-4045-BDE6-14BD6C39C4EA
AppVersion=1.12.1+26
AppName=Ensound
AppPublisher=kunalbiz18
AppPublisherURL=https://github.com/kunalbiz18/Ensound
AppSupportURL=https://github.com/kunalbiz18/Ensound
AppUpdatesURL=https://github.com/kunalbiz18/Ensound
DefaultDirName={autopf}\Ensound
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=Ensound-1.12.1
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
Source: "..\..\build\windows\x64\runner\Release\Ensound.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Ensound"; Filename: "{app}\Ensound.exe"
Name: "{autodesktop}\Ensound"; Filename: "{app}\Ensound.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Ensound.exe"; Description: "{cm:LaunchProgram,{#StringChange('Ensound', '&', '&&')}}"; Flags: nowait postinstall skipifsilent
