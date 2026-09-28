#include "package.iss"

[Setup]
AppId={{09D880ED-C897-4B9A-85AC-4CF338EE1F6E}
AppName=Cake It!
AppVersion={#ReleaseTag}
AppPublisher=Cake It!
AppPublisherURL=https://cakeit.ez.run
DefaultDirName={localappdata}\Programs\CakeIt
DefaultGroupName=Cake It!
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
OutputDir=output
OutputBaseFilename=CakeIt-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\CakeIt.exe
CloseApplications=yes
RestartApplications=no
ExtraDiskSpaceRequired=11000000000
SetupLogging=yes
DisableProgramGroupPage=yes

[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"

[Files]
Source: "{tmp}\payload\CakeIt\*"; DestDir: "{app}"; Flags: external ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Cake It!"; Filename: "{app}\CakeIt.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\Cake It!"; Filename: "{app}\CakeIt.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\Engine\Extras\Redist\en-us\vc_redist.x64.exe"; Parameters: "/install /passive /norestart"; StatusMsg: "Installing Microsoft Visual C++ runtime..."; Flags: shellexec waituntilterminated; Verb: "runas"; Check: NeedsVCRuntime
Filename: "{app}\CakeIt.exe"; Description: "Launch Cake It!"; Flags: nowait postinstall skipifsilent unchecked

[Code]
var
  DownloadPage: TDownloadWizardPage;
  Prepared: Boolean;

function NeedsVCRuntime: Boolean;
var Installed: Cardinal;
begin
  Result := not RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed);
  if not Result then Result := Installed <> 1;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage('Downloading Cake It!',
    'Setup downloads and verifies the game automatically. Please keep your internet connection active.', nil);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var Code: Integer;
begin
  Result := '';
  if Prepared then exit;
  DownloadPage.Clear;
  {#Downloads}
  DownloadPage.Show;
  try
    try
      DownloadPage.Download;
      WizardForm.StatusLabel.Caption := 'Preparing game files. This can take a few minutes...';
      if not Exec(ExpandConstant('{cmd}'), ExpandConstant('{#JoinCommand}'), '', SW_HIDE, ewWaitUntilTerminated, Code) then
        RaiseException('Could not prepare the downloaded files.');
      if Code <> 0 then RaiseException('Could not prepare the downloaded files. Check available disk space and try again.');
      if CompareText(GetSHA256OfFile(ExpandConstant('{tmp}\{#PackageName}')), '{#PackageSHA}') <> 0 then
        RaiseException('Game verification failed. Please try again.');
      {#CleanupParts}
      ForceDirectories(ExpandConstant('{tmp}\payload'));
      if not Exec(ExpandConstant('{sys}\tar.exe'), ExpandConstant('-xf "{tmp}\{#PackageName}" -C "{tmp}\payload"'), '', SW_HIDE, ewWaitUntilTerminated, Code) then
        RaiseException('Could not extract the game.');
      if (Code <> 0) or not FileExists(ExpandConstant('{tmp}\payload\CakeIt\CakeIt.exe')) then
        RaiseException('Game extraction failed. Check available disk space and try again.');
      DeleteFile(ExpandConstant('{tmp}\{#PackageName}'));
      Prepared := True;
    except
      Result := GetExceptionMessage;
    end;
  finally
    DownloadPage.Hide;
  end;
end;
