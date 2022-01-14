@echo OFF

set bitbucket_user_pass=%~1:%~2

::BURAYI HER SEFERINDE GUNCELLE
set PROJECT_DIR=C:\Dev\Git\Moduler_Project_Base_Folder
set PROJECT_KEY=Moduler_Project_key
::BURAYI HER SEFERINDE GUNCELLE

title git clone all repos in project
setlocal ENABLEDELAYEDEXPANSION
cd /d %~dp0

set SCRIPT_HOME=%~dp0

cd "%PROJECT_DIR%"
set back=%cd%
cd /d %back%

git config --global credential.helper "cache --timeout=3600"
git config --global credential.helper store


call:gitCloneAllReposInProject



:finish
pause
exit /b 0


:gitCloneAllReposInProject
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE="/rest/api/1.0/projects/%PROJECT_KEY%/repos?limit=100000"
	
	@rem https://docs.atlassian.com/bitbucket-server/rest/4.5.1/bitbucket-rest.html#idp2950304

	
	echo gitCloneAllReposInProject
	echo.
	cd %PROJECT_DIR%
	cd
	title gitCloneAllReposInProject
	echo gitCloneAllReposInProject basla:
	@echo off
	@rem tekrar gitmesin simdilik curl -u %bitbucket_user_pass% %URL%%PAGE% -X GET > %SCRIPT_HOME%\dummy.json
	@echo off
	echo.
	powershell -Nop -C "(Get-Content %SCRIPT_HOME%\dummy.json | ConvertFrom-Json | Select -ExpandProperty \"values\").slug" > %SCRIPT_HOME%\dummy.txt
	
	for /F "tokens=*" %%a in (%SCRIPT_HOME%\dummy.txt) do (
		echo value : %%a
		
		git clone %URL%/scm/%PROJECT_KEY%/%%a.git
	)

	echo gitCloneAllReposInProject bitti
	cd %back%
GOTO:EOF
