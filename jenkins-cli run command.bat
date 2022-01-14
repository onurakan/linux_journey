@echo off
title "jenkins build : %1"
setlocal enabledelayedexpansion

:: Author Onur Akan
:: 09.07.2020
:: Sample call:
:: "jenkins-cli run command.bat" "project1 project2 project3 project4" build develop DEPENDENCY_CHECK_TRUE


if [%1] == [] GOTO notSetParameter1
if [%2] == [] GOTO notSetParameter2
if [%3] == [] GOTO notSetParameter3
if [%4] == [] GOTO notSetParameter4

cls

echo 1.Input Parameter : %~1

set MODULE_NAMES=%~1
set JENKINS_COMMAND=%~2
set BRANCH=%~3
set DEPENDENCY_CHECK_YES_NO_NON=%~4

set startTime=%time%

set JAVA_HOME=D:\Dev\tools\Maya_JDK8\jdk8\bin
set Path=%JAVA_HOME%;%Path%

set JENKINS_URL=http://jenkins.onurakan.com.tr

set command="build"
@rem set command="who-am-i"
set password=""

@rem %JENKINS_URL%/cli/command/build
@rem	java -jar jenkins-cli.jar -s %JENKINS_URL% build JOB [-c] [-f] [-p] [-r N] [-s] [-v] [-w]
@rem	Starts a build, and optionally waits for a completion.
@rem	Aside from general scripting use, this command can be
@rem	used to invoke another job from within a build of one job.
@rem	With the -s option, this command changes the exit code based on
@rem	the outcome of the build (exit code 0 indicates a success)
@rem	and interrupting the command will interrupt the job.
@rem	With the -f option, this command changes the exit code based on
@rem	the outcome of the build (exit code 0 indicates a success)
@rem	however, unlike -s, interrupting the command will not interrupt
@rem	the job (exit code 125 indicates the command was interrupted).
@rem	With the -c option, a build will only run if there has been
@rem	an SCM change.
@rem	
@rem	 JOB : Name of the job to build
@rem	 -c  : Check for SCM changes before starting the build, and if there's no
@rem	       change, exit without doing a build
@rem	 -f  : Follow the build progress. Like -s only interrupts are not passed
@rem	       through to the build.
@rem	 -p  : Specify the build parameters in the key=value format.
@rem	 -s  : Wait until the completion/abortion of the command. Interrupts are passed
@rem	       through to the build.
@rem	 -v  : Prints out the console output of the build. Use with -s
@rem	 -w  : Wait until the start of the command

@rem	%JENKINS_URL%/cli/ jenkins-cli.jar komutları burada
@rem	bunu git bash ile calistir. C:\Users\ttoakan\.ssh buraya pub ve private key yaratacak
@rem		ssh-keygen -t rsa -b 4096 -C "onur.akan@onurakan.com.tr"
@rem	%JENKINS_URL%/me/configure sitesine git ve oradada ssh keys kısmına pub dosyasini yükle.

echo MODULE_NAMES : %MODULE_NAMES%
echo JENKINS_COMMAND: %JENKINS_COMMAND%
echo BRANCH : %BRANCH%
echo.

java -version
echo.
echo.

if "%DEPENDENCY_CHECK_YES_NO_NON%" == "DEPENDENCY_CHECK_TRUE" (
	set PARAMETERS=-p dependencyCheck=true
)
if "%DEPENDENCY_CHECK_YES_NO_NON%" == "DEPENDENCY_CHECK_FALSE" (
	set PARAMETERS=-p dependencyCheck=false
)

if "%DEPENDENCY_CHECK_YES_NO_NON%" == "DEPENDENCY_CHECK_NON" (
	set PARAMETERS=-p dependencyCheck=false
)

for /d %%j in (%MODULE_NAMES%) do (
	set MODULE_NAME=%%j
	set JOB=some_jenkins_folder/!MODULE_NAME!/%BRANCH%
	echo.
	echo.
	title "jenkins job : !JOB!"
	echo ################################################## Starting for MODULE_NAME : !MODULE_NAME! ###########################################################
	echo Running for MODULE_NAME : !MODULE_NAME!
	echo Running for JOB : !JOB!
	echo.
	echo.
	if "%JENKINS_COMMAND%"=="build" (
		java -jar C:\Users\ttoakan\Documents\devops\jenkins-cli.jar -s %JENKINS_URL% -auth myusername:%password% %command% !JOB! -s -v %PARAMETERS%
	)
	if "%JENKINS_COMMAND%"=="validate" (
		java -jar C:\Users\ttoakan\Documents\devops\jenkins-cli.jar -s %JENKINS_URL% -auth myusername:%password% declarative-linter < D:\Dev\git\some_jenkins_folder\%MODULE_NAME%\Jenkinsfile 
	)
	echo ################################################## Running for MODULE_NAME : !MODULE_NAME! ended! #####################################################
)



:finish
echo.
echo.
echo "Start Time:" %startTime%
echo "Finish Time:" %time%
echo.
echo.
pause
exit /b 0

:notSetParameter1
echo 1. parameter of batch not set. JOB name (project1, project2, project3) is expected.
pause
exit /b 1

:notSetParameter2
echo 2. parameter of batch not set. JENKINS_COMMAND (build, validate) is expected.
pause
exit /b 2

:notSetParameter3
echo 3. parameter of batch not set. BRANCH (develop, feature) is expected.
pause
exit /b 3

:notSetParameter4
echo 4. parameter of batch not set. DEPENDENCY_CHECK_YES_NO_NON (DEPENDENCY_CHECK_TRUE, DEPENDENCY_CHECK_FALSE, DEPENDENCY_CHECK_NON) is expected.
pause
exit /b 4