@ECHO OFF

SET prefix=%USERPROFILE%
SET neo4j_version=1.9.M05

SET dist_dir=%~dp0
SET release=neo4j-community-%neo4j_version%
SET installer=%release%-windows.zip
SET package="%dist_dir%\NEO4J\%installer%"


if not "%JAVA_HOME%" == "" (
  goto INSTALL
)

rem Attempt to find the JVM via the registry
set keyName=HKLM\SOFTWARE\JavaSoft\Java Runtime Environment
set valueName=CurrentVersion

FOR /F "usebackq skip=2 tokens=3" %%a IN (`REG QUERY "%keyName%" /v %valueName% 2^>nul`) DO (
  set javaVersion=%%a
)

if "%javaVersion%" == "" (
  FOR /F "usebackq skip=2 tokens=3" %%a IN (`REG QUERY "%keyName%" /v %valueName% /reg:32 2^>nul`) DO (
    set javaVersion=%%a
  )
)

if "%javaVersion%" == "" (
  echo java is not installed - Install the Java Runtime Environment
  start %dist_dir%\JRE
  pause
  exit
)


:INSTALL
if exist "%prefix%\%release%" (
  echo Directory %prefix%\%release% already exists! Not re-installing
  goto DONE
)

echo Unpacking %package%
cd /D "%prefix%"
"%dist_dir%\TOOLS\7za.exe" x "%package%" > NUL

echo Modifying default configuration
copy /Y "%dist_dir%\CONFIG\neo4j.properties" "%prefix%\%release%\conf" > NUL

echo Copying sample datasets
mkdir "%prefix%\%release%\sampledata" > NUL
copy "%dist_dir%\SAMPLE\*.cyp" "%prefix%\%release%\sampledata" > NUL

echo Copying tools
copy "%dist_dir%\TOOLS\gumdrop.jar" "%prefix%\%release%" > NUL

echo.
echo Neo4j %neo4j_version% installed to %prefix%\%release%


:DONE
start notepad %dist_dir%\README.txt
cd /D "%prefix%\%release%"
echo.
echo.
echo.
cmd
