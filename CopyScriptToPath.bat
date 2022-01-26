ECHO OFF
Rem Copy all powershell files from source folder to a new path

xcopy %~dp0*.ps1 C:\Windows\<Path>\ /E /H /R /K /Y
