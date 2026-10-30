# Rebuilds the WAR and redeploys it to a local Tomcat 10.1
#   .\deploy.ps1 -Tomcat "C:\apache-tomcat-10.1.61"
param([string]$Tomcat = $env:CATALINA_HOME)
if (-not $Tomcat) { Write-Error "Pass -Tomcat <folder> or set CATALINA_HOME"; exit 1 }
& "$PSScriptRoot\build.bat" $Tomcat
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Remove-Item "$Tomcat\webapps\scriptwell" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$PSScriptRoot\dist\scriptwell.war" "$Tomcat\webapps\scriptwell.war" -Force
Write-Host "Deployed. Open http://localhost:8080/scriptwell/"
