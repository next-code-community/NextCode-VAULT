@echo off
title Installazione NextCode VAULT

:: Richiedi privilegi amministrativi
echo Verifica privilegi amministrativi...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Richiesta privilegi amministrativi...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Esecuzione come amministratore
echo Installazione in corso...

:: Percorso dell'eseguibile
set APP_NAME=NextCode VAULT
set EXE_NAME=NextCode VAULT.exe
set DOWNLOAD_URL=https://www.mediafire.com/file/ep88d4kusfurgxr/NextCode_VAULT.exe/file
set TEMP_DOWNLOAD=%TEMP%\%EXE_NAME%

:: Scarica l'eseguibile
echo Scaricamento dell'eseguibile in corso...
echo Questo potrebbe richiedere alcuni istanti...

powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('MediaFire richiede di seguire una pagina web per scaricare il file. Dopo aver cliccato OK, si aprirà una pagina web. Clicca sul pulsante di download e salva il file come ''NextCode VAULT.exe'' nella cartella dei download. Quando il download è completato, torna a questa finestra e premi un tasto per continuare.', 'Scaricamento file', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information);}"

start "" "%DOWNLOAD_URL%"
echo.
echo Attendi il completamento del download e poi premi un tasto per continuare...
pause >nul

echo.
echo Seleziona il file scaricato:
echo --------------------------

powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog; $OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath('UserProfile') + '\Downloads'; $OpenFileDialog.Filter = 'Executable Files (*.exe)|*.exe'; $OpenFileDialog.Title = 'Seleziona NextCode VAULT.exe scaricato'; $null = $OpenFileDialog.ShowDialog(); $OpenFileDialog.FileName}" > "%TEMP%\selected_file.txt"

set /p DOWNLOADED_FILE=<"%TEMP%\selected_file.txt"
del "%TEMP%\selected_file.txt"

if not exist "%DOWNLOADED_FILE%" (
    echo File non trovato o non selezionato. Installazione annullata.
    pause
    exit /b
)

:: Trova il percorso di Program Files
if exist "%ProgramFiles(x86)%" (
    set PROGRAM_FILES=%ProgramFiles(x86)%
) else (
    set PROGRAM_FILES=%ProgramFiles%
)

:: Crea la directory di installazione
set INSTALL_DIR=%PROGRAM_FILES%\%APP_NAME%
echo Creazione directory: %INSTALL_DIR%
if exist "%INSTALL_DIR%" (
    echo Rimozione installazione precedente...
    rmdir /s /q "%INSTALL_DIR%"
)
mkdir "%INSTALL_DIR%"

:: Copia l'eseguibile
echo Copia dell'eseguibile...
copy "%DOWNLOADED_FILE%" "%INSTALL_DIR%\%EXE_NAME%" /y

:: Crea directory per i dati dell'utente
set USER_DATA_DIR=%USERPROFILE%\Documents\%APP_NAME%
echo Creazione directory per i dati: %USER_DATA_DIR%
if not exist "%USER_DATA_DIR%" (
    mkdir "%USER_DATA_DIR%"
)

:: Crea collegamento sul desktop
echo Creazione collegamento sul desktop...
set SHORTCUT_PATH=%USERPROFILE%\Desktop\%APP_NAME%.lnk

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%SHORTCUT_PATH%" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%INSTALL_DIR%\%EXE_NAME%" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%USER_DATA_DIR%" >> CreateShortcut.vbs
echo oLink.Description = "%APP_NAME% - Password Manager" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript //nologo CreateShortcut.vbs
del CreateShortcut.vbs

:: Crea collegamento nel menu Start
set STARTMENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%
echo Creazione collegamento nel menu Start...
if not exist "%STARTMENU_DIR%" (
    mkdir "%STARTMENU_DIR%"
)
set STARTMENU_LINK=%STARTMENU_DIR%\%APP_NAME%.lnk

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateStartMenu.vbs
echo sLinkFile = "%STARTMENU_LINK%" >> CreateStartMenu.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateStartMenu.vbs
echo oLink.TargetPath = "%INSTALL_DIR%\%EXE_NAME%" >> CreateStartMenu.vbs
echo oLink.WorkingDirectory = "%USER_DATA_DIR%" >> CreateStartMenu.vbs
echo oLink.Description = "%APP_NAME% - Password Manager" >> CreateStartMenu.vbs
echo oLink.Save >> CreateStartMenu.vbs
cscript //nologo CreateStartMenu.vbs
del CreateStartMenu.vbs

:: Crea file di disinstallazione
echo @echo off > "%INSTALL_DIR%\uninstall.bat"
echo title Disinstallazione %APP_NAME% >> "%INSTALL_DIR%\uninstall.bat"
echo echo Disinstallazione di %APP_NAME% in corso... >> "%INSTALL_DIR%\uninstall.bat"
echo if exist "%SHORTCUT_PATH%" del "%SHORTCUT_PATH%" >> "%INSTALL_DIR%\uninstall.bat"
echo if exist "%STARTMENU_LINK%" del "%STARTMENU_LINK%" >> "%INSTALL_DIR%\uninstall.bat"
echo if exist "%STARTMENU_DIR%" rmdir "%STARTMENU_DIR%" >> "%INSTALL_DIR%\uninstall.bat"
echo cd /d "%%~dp0" >> "%INSTALL_DIR%\uninstall.bat"
echo cd .. >> "%INSTALL_DIR%\uninstall.bat"
echo rmdir /s /q "%INSTALL_DIR%" >> "%INSTALL_DIR%\uninstall.bat"
echo echo. >> "%INSTALL_DIR%\uninstall.bat"
echo echo Disinstallazione completata! >> "%INSTALL_DIR%\uninstall.bat"
echo echo Nota: I tuoi dati e password rimangono nella cartella: %USER_DATA_DIR% >> "%INSTALL_DIR%\uninstall.bat"
echo echo Puoi eliminarli manualmente se non ti servono più. >> "%INSTALL_DIR%\uninstall.bat"
echo pause >> "%INSTALL_DIR%\uninstall.bat"

:: Crea collegamento di disinstallazione nel menu Start
set UNINSTALL_LINK=%STARTMENU_DIR%\Disinstalla %APP_NAME%.lnk

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateUninstall.vbs
echo sLinkFile = "%UNINSTALL_LINK%" >> CreateUninstall.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateUninstall.vbs
echo oLink.TargetPath = "%%windir%%\system32\cmd.exe" >> CreateUninstall.vbs
echo oLink.Arguments = "/c ""%INSTALL_DIR%\uninstall.bat""" >> CreateUninstall.vbs
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> CreateUninstall.vbs
echo oLink.Description = "Disinstalla %APP_NAME%" >> CreateUninstall.vbs
echo oLink.Save >> CreateUninstall.vbs
cscript //nologo CreateUninstall.vbs
del CreateUninstall.vbs

echo.
echo Installazione completata con successo!
echo.
echo  * Applicazione installata in: %INSTALL_DIR%
echo  * Dati dell'applicazione salvati in: %USER_DATA_DIR%
echo  * Collegamento sul desktop creato
echo  * Collegamento nel menu Start creato
echo.
echo Nota importante: L'applicazione è stata configurata per salvare 
echo i tuoi dati nella cartella Documenti, così non avrai problemi di permessi.
echo.

pause