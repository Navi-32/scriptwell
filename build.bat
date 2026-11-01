@echo off
REM ---------------------------------------------------------------
REM  ScriptWell command-line build (alternative to Eclipse export)
REM  Usage:  build.bat "C:\path\to\apache-tomcat-10.1.x or 11.x"
REM  Output: dist\scriptwell.war  (copy it into Tomcat's webapps folder)
REM ---------------------------------------------------------------
setlocal
set TOMCAT=%~1
if "%TOMCAT%"=="" set TOMCAT=%CATALINA_HOME%
if "%TOMCAT%"=="" (
  echo Please pass the Tomcat folder, e.g. build.bat "C:\apache-tomcat-11.0.4"
  exit /b 1
)

set OUT=build\war
if exist build rmdir /s /q build
mkdir %OUT%\WEB-INF\classes
mkdir dist 2>nul

dir /s /b src\main\java\*.java > build\sources.txt
javac --release 17 -encoding UTF-8 -d %OUT%\WEB-INF\classes ^
  -cp "%TOMCAT%\lib\servlet-api.jar;%TOMCAT%\lib\jsp-api.jar;src\main\webapp\WEB-INF\lib\*" @build\sources.txt
if errorlevel 1 exit /b 1

copy src\main\java\db.properties %OUT%\WEB-INF\classes\ >nul
xcopy /e /i /q src\main\webapp %OUT% >nul
set JAR=
if defined JAVA_HOME if exist "%JAVA_HOME%\bin\jar.exe" set "JAR=%JAVA_HOME%\bin\jar.exe"
if not defined JAR for /f "tokens=2,*" %%A in ('java -XshowSettings:properties -version 2^>^&1 ^| findstr /C:"java.home ="') do set "JAVA_HOME=%%B"
if not defined JAR if exist "%JAVA_HOME%\bin\jar.exe" set "JAR=%JAVA_HOME%\bin\jar.exe"
if not defined JAR (
  for /f "delims=" %%A in ('where jar 2^>nul') do if not defined JAR set "JAR=%%A"
)
if not defined JAR (
  echo Could not find jar.exe. Install a JDK or set JAVA_HOME.
  exit /b 1
)
"%JAR%" -cf dist\scriptwell.war -C %OUT% .
if errorlevel 1 exit /b 1
echo Built dist\scriptwell.war
