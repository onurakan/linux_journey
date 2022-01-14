@echo OFF

:: Author Onur Akan
:: 12.05.2021

set bitbucket_user_pass=%~1:%~2

setlocal ENABLEDELAYEDEXPANSION
cd /d %~dp0

title bitbucket repo settings configurer

set SCRIPT_HOME=%~dp0

::BURAYI HER SEFERINDE GUNCELLE

set PROJECT_DIR=D:\Dev\git\Projects_Base
set PROJECT_KEY=Projects_Base
set list_of_modules=project1,project2,project3,project4

::BURAYI HER SEFERINDE GUNCELLE



cd "%PROJECT_DIR%"
set back=%cd%

git config --global credential.helper "cache --timeout=3600"
git config --global credential.helper store


@rem goto :components 

for /d %%j in (%list_of_modules%) do (
	set break=

	@rem rollback calismasi lazim cunku bitbucketSettingsAddWebhooks calisinca duplike ediyor.
	@rem call:bitbucketSettingsAddWebhooksRollback %%j
	@rem 24.11.2020 call:bitbucketSettingsAddWebhooks %%j
	
	@rem branchlere direk commit yapamasin, sadece pull-request-only yapabilsin
	@rem call:bitbucketSettingsBranchPermissionsRollback %%j
	@rem 24.11.2020 call:bitbucketSettingsBranchPermissions %%j
	
	@rem requiredApprovers, requiredAllTasksComplete, unapproveOnUpdate set etsin
	@rem 24.11.2020 call:bitbucketSettingsPullRequestsRollback %%j
	call:bitbucketSettingsPullRequests %%j
	
	@rem pull request default reviewer (yani code reviewer) set etsin
	@rem rollback calismasi lazim cunku bitbucketSettingsDefaultReviewers calisinca duplike ediyor.
	@rem rollback calisiyor ANCAK rollback source=any,target=releasable,reviewer=myusername olani siler reviewer baskasi varsa da siliyor, 
	@rem     dikkat, bunu calistirmadan once tanimi ve asagidaki kodu duzelt. DELETE calisiyor, PUT calismiyor
	@rem call:bitbucketSettingsDefaultReviewersRollback %%j PUT
	@rem 24.11.2020 call:bitbucketSettingsDefaultReviewers %%j
)

:finish
pause
exit /b 0

:: https://docs.atlassian.com/bitbucket-server/rest/7.6.0/bitbucket-rest.html#idp401
:: https://bitbucket.org/atlassian/stash-auto-unapprove-plugin/issues/25/api-documentation
:: https://docs.atlassian.com/bitbucket-server/rest/5.10.1/bitbucket-ref-restriction-rest.html#idm212936655456
:: https://docs.atlassian.com/bitbucket-server/rest/5.1.1/bitbucket-default-reviewers-rest.html#idm46266611271456
:: https://docs.atlassian.com/bitbucket-server/rest/5.1.1/bitbucket-default-reviewers-rest.html#idm46266611288208
:: https://support.cloudbees.com/hc/en-us/articles/115000083932-Generate-webHooks-in-Bitbucket-Server-via-REST-API-for-Pipeline-Multibranch
:: https://moveworkforward.atlassian.net/wiki/spaces/DOCS/pages/867205121/Atlassian+Bitbucket+Post+Webhook+API#Delete-a-post-webhook-by-ID

:bitbucketSettingsAddWebhooksRollback
	set L_REPO=%~1
	set L_DELETE_OR_PUT=%2
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE=/rest/webhook/1.0/projects/%PROJECT_KEY%/repos/%L_REPO%/configurations/
	
	echo bitbucketSettingsAddWebhooksRollback : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsAddWebhooksRollback : %L_REPO%
	echo bitbucketSettingsAddWebhooksRollback basla:
	@echo on
	curl -u %bitbucket_user_pass% "%URL%%PAGE%" -X GET > %SCRIPT_HOME%\dummy.json
	@echo off
	echo.

	@rem https://stackoverflow.com/questions/53460823/how-to-get-data-from-json-file-with-batch-script-and-write-the-data-into-a-text
	powershell -Nop -C "(Get-Content %SCRIPT_HOME%\dummy.json|ConvertFrom-Json | ForEach-Object { $_ | Where-Object {$_.title -eq \"Jenkins hook\"}}).id" > %SCRIPT_HOME%\dummy.txt
	set /p JENKINS_HOOK_ID= < %SCRIPT_HOME%\dummy.txt 
	echo jenkinsHookId=%JENKINS_HOOK_ID%
	
	if NOT "%JENKINS_HOOK_ID%" == "" (
		@echo on
		curl -u %bitbucket_user_pass% "%URL%%PAGE%%JENKINS_HOOK_ID%" -X DELETE
		@echo off
	)
	echo.
		
	echo bitbucketSettingsAddWebhooksRollback bitti : %L_REPO%	
	cd %back%
GOTO:EOF

:bitbucketSettingsAddWebhooks
	set URL_HOOK=http://jenkins.onurkan.com.tr:8080/bitbucket-scmsource-hook/notify
	@rem set DATA="{\"title\": \"Jenkins hook\",\"url\": \"%URL_HOOK%\",\"enabled\": true,\"repoPush\": true,\"branchCreated\": true,\"branchDeleted\": true,\"prCreated\": true,\"prUpdated\": true,\"prMerged\": true,\"prDeclined\": true,\"prReopened\": true,\"prRescoped\": true}"
	set DATA="{\"title\": \"Jenkins hook\",\"url\": \"%URL_HOOK%\",\"enabled\": true}"

	set L_REPO=%~1
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE=/rest/webhook/1.0/projects/%PROJECT_KEY%/repos/%L_REPO%/configurations

	echo bitbucketSettingsAddWebhooks : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsAddWebhooks : %L_REPO%
	echo bitbucketSettingsAddWebhooks basla:
	@echo on
	curl -u %bitbucket_user_pass% -H "Content-Type: application/json" %URL%%PAGE% -X PUT --data %DATA%
	@echo off
	echo.
	echo bitbucketSettingsAddWebhooks bitti : %L_REPO%	
	cd %back%
GOTO:EOF

:bitbucketSettingsDefaultReviewersRollback
	set L_REPO=%~1
	set L_DELETE_OR_PUT=%2
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE1=/rest/default-reviewers/1.0/projects/%PROJECT_KEY%/repos/%L_REPO%/conditions
	set PAGE2=/rest/default-reviewers/latest/projects/%PROJECT_KEY%/repos/%L_REPO%/condition/
	
	echo bitbucketSettingsDefaultReviewersRollback : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsDefaultReviewersRollback : %L_REPO%
	echo bitbucketSettingsDefaultReviewersRollback basla:
	@echo on
	curl -u %bitbucket_user_pass% "%URL%%PAGE1%" -X GET > %SCRIPT_HOME%\dummy.json
	@echo off
	echo.

	@rem https://stackoverflow.com/questions/53460823/how-to-get-data-from-json-file-with-batch-script-and-write-the-data-into-a-text
	powershell -Nop -C "(Get-Content %SCRIPT_HOME%\dummy.json |ConvertFrom-Json | ForEach-Object { $_ | Where-Object {$_.targetRefMatcher.displayId -eq \"ANY_REF_MATCHER_ID\"}}).id" > %SCRIPT_HOME%\dummy.txt
	set /p CONDITION_ID_ANY= < %SCRIPT_HOME%\dummy.txt 
	echo any conditionIdAny=%CONDITION_ID_ANY%
	
	powershell -Nop -C "(Get-Content %SCRIPT_HOME%\dummy.json |ConvertFrom-Json | ForEach-Object { $_ | Where-Object {$_.targetRefMatcher.displayId -eq \"releasable\" -and $_.reviewers.name -eq \"MY_USER_NAME\"}}).id" > %SCRIPT_HOME%\dummy.txt
	set /p CONDITION_ID_ONUR_AKAN= < %SCRIPT_HOME%\dummy.txt 
	echo conditionIdReleasableOnurAkan=%CONDITION_ID_ONUR_AKAN%
	
	GOTO:EOF
	@rem TODO PUT calismiyor. Calismasi icin --data olarak as-is json'i gondermek lazim
	
	@echo on
	if "%L_DELETE_OR_PUT%"=="DELETE" (
		curl -u %bitbucket_user_pass% "%URL%%PAGE2%%CONDITION_ID_ONUR_AKAN%" -X DELETE
	)
	if "%L_DELETE_OR_PUT%"=="PUT" (
		curl -u %bitbucket_user_pass% "%URL%%PAGE2%%CONDITION_ID_ONUR_AKAN%" -X PUT
	)
	@echo off
	echo.
	
	echo bitbucketSettingsDefaultReviewersRollback bitti : %L_REPO%	
	cd %back%
GOTO:EOF

:bitbucketSettingsBranchPermissionsRollback
	set L_REPO=%~1
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE1=/rest/branch-permissions/latest/projects/%PROJECT_KEY%/repos/%L_REPO%/restrictions
	set PAGE2=/rest/branch-permissions/latest/projects/%PROJECT_KEY%/repos/%L_REPO%/restrictions/
	
	echo bitbucketSettingsBranchPermissionsRollback : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsBranchPermissionsRollback : %L_REPO%
	echo bitbucketSettingsBranchPermissionsRollback basla:
	@echo on
	curl -u %bitbucket_user_pass% "%URL%%PAGE1%" -X GET > %SCRIPT_HOME%\dummy.json
	@echo off
	echo.
	
	@rem https://stackoverflow.com/questions/53460823/how-to-get-data-from-json-file-with-batch-script-and-write-the-data-into-a-text
	powershell -Nop -C "(Get-Content %SCRIPT_HOME%\dummy.json |ConvertFrom-Json | Select -ExpandProperty \"values\" | Where-Object {$_.matcher.displayId -eq \"master\"}).id" > %SCRIPT_HOME%\dummy.txt
	set /p CONDITION_ID_MASTER= < %SCRIPT_HOME%\dummy.txt
	echo master conditionIdMaster=%CONDITION_ID_MASTER%
	
	powershell -Nop -C "(Get-Content %SCRIPT_HOME%\dummy.json |ConvertFrom-Json | Select -ExpandProperty \"values\" | Where-Object {$_.matcher.displayId -eq \"releasable\"}).id" > %SCRIPT_HOME%\dummy.txt
	set /p CONDITION_ID_RELEASABLE= < %SCRIPT_HOME%\dummy.txt 
	echo releasable conditionIdReleasable=%CONDITION_ID_RELEASABLE%
	
	powershell -Nop -C "(Get-Content %SCRIPT_HOME%\dummy.json |ConvertFrom-Json | Select -ExpandProperty \"values\" | Where-Object {$_.matcher.displayId -eq \"integration\"}).id" > %SCRIPT_HOME%\dummy.txt
	set /p CONDITION_ID_INTEGRATION= < %SCRIPT_HOME%\dummy.txt 
	echo integration conditionIdIntegration=%CONDITION_ID_INTEGRATION%
	
	
	if NOT "%CONDITION_ID_MASTER%" == "" (
		@echo on 
		curl -u %bitbucket_user_pass% %URL%%PAGE2%%CONDITION_ID_MASTER% -X DELETE
		@echo off
	)
	if NOT "%CONDITION_ID_RELEASABLE%" == "" (
		@echo on
		curl -u %bitbucket_user_pass% %URL%%PAGE2%%CONDITION_ID_RELEASABLE% -X DELETE
		@echo off
	)
	if NOT "%CONDITION_ID_INTEGRATION%" == "" (
		@echo on
		curl -u %bitbucket_user_pass% %URL%%PAGE2%%CONDITION_ID_INTEGRATION% -X DELETE
		@echo off
	)
	@echo off
	echo.
	
	echo bitbucketSettingsBranchPermissionsRollback bitti : %L_REPO%	
	cd %back%
GOTO:EOF

:bitbucketSettingsDefaultReviewers
	set DATA="{\"reviewers\":[{\"name\":\"MY_USER_NAME\",\"emailAddress\":\"onur.akan@onurakan.com.tr\",\"id\":12255,\"displayName\":\"ONUR AKAN\",\"active\":true,\"slug\":\"myusername\",\"type\":\"NORMAL\"}],\"sourceMatcher\":{\"active\":true,\"id\":\"ANY_REF_MATCHER_ID\",\"displayId\":\"ANY_REF_MATCHER_ID\",\"type\":{\"id\":\"ANY_REF\",\"name\":\"ANY_REF\"}},\"targetMatcher\":{\"active\":true,\"id\":\"refs/heads/releasable\",\"displayId\":\"refs/heads/releasable\",\"type\":{\"id\":\"BRANCH\",\"name\":\"releasable\"}},\"requiredApprovals\": 1}"

	set L_REPO=%~1
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE=/rest/default-reviewers/1.0/projects/%PROJECT_KEY%/repos/%L_REPO%/condition
	
	echo bitbucketSettingsDefaultReviewers : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsDefaultReviewers : %L_REPO%
	echo bitbucketSettingsDefaultReviewers basla:
	@echo on
	curl -u %bitbucket_user_pass% -H "Content-Type: application/json" %URL%%PAGE% -X POST --data %DATA%;
	@echo off
	echo.
	echo bitbucketSettingsDefaultReviewers bitti : %L_REPO%	
	cd %back%
GOTO:EOF

:bitbucketSettingsBranchPermissions
	set DATA1="{\"type\":\"pull-request-only\",\"matcher\":{\"id\":\"refs/heads/master\",\"displayId\":\"refs/heads/master\",\"type\":{\"id\":\"BRANCH\",\"name\":\"master\"},\"active\":true}}"
	set DATA2="{\"type\":\"pull-request-only\",\"matcher\":{\"id\":\"refs/heads/releasable\",\"displayId\":\"refs/heads/releasable\",\"type\":{\"id\":\"BRANCH\",\"name\":\"releasable\"},\"active\":true}}"
	set DATA3="{\"type\":\"pull-request-only\",\"matcher\":{\"id\":\"refs/heads/integration\",\"displayId\":\"refs/heads/integration\",\"type\":{\"id\":\"BRANCH\",\"name\":\"integration\"},\"active\":true}}"

	set L_REPO=%~1
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE=/rest/branch-permissions/2.0/projects/%PROJECT_KEY%/repos/%L_REPO%/restrictions

	echo bitbucketSettingsBranchPermissions : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsBranchPermissions : %L_REPO%
	echo bitbucketSettingsBranchPermissions basla:
	@echo on
	curl -u %bitbucket_user_pass% -H "Content-Type: application/json" %URL%%PAGE% -X POST --data %DATA1%;
	curl -u %bitbucket_user_pass% -H "Content-Type: application/json" %URL%%PAGE% -X POST --data %DATA2%;
	curl -u %bitbucket_user_pass% -H "Content-Type: application/json" %URL%%PAGE% -X POST --data %DATA3%;
	@echo off
	echo.
	echo bitbucketSettingsBranchPermissions bitti : %L_REPO%	
	cd %back%
GOTO:EOF

:bitbucketSettingsPullRequestsRollback
	set DATA="{\"requiredApprovers\":0, \"requiredAllTasksComplete\":false, \"unapproveOnUpdate\":false}"
	
	set L_REPO=%~1
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE=/rest/api/1.0/projects/%PROJECT_KEY%/repos/%L_REPO%/settings/pull-requests
	
	echo bitbucketSettingsPullRequestsRollback : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsPullRequestsRollback : %L_REPO%
	echo bitbucketSettingsPullRequestsRollback basla:
	@echo on
	curl -u %bitbucket_user_pass% -H "Content-Type: application/json" %URL%%PAGE% -X POST --data %DATA%;
	@echo off
	echo.
	echo bitbucketSettingsPullRequestsRollback bitti : %L_REPO%	
	cd %back%
GOTO:EOF

:bitbucketSettingsPullRequests
	set DATA="{\"requiredApprovers\":1, \"requiredAllTasksComplete\":true, \"unapproveOnUpdate\":true}"
	
	set L_REPO=%~1
	set URL=https://bitbucket.onurakan.com.tr/git
	set PAGE=/rest/api/1.0/projects/%PROJECT_KEY%/repos/%L_REPO%/settings/pull-requests
	
	echo bitbucketSettingsPullRequests : %L_REPO%
	echo.
	cd %PROJECT_DIR%\%L_REPO%
	cd
	title bitbucketSettingsPullRequests : %L_REPO%
	echo bitbucketSettingsPullRequests basla:
	@echo on
	curl -u %bitbucket_user_pass% -H "Content-Type: application/json" %URL%%PAGE% -X POST --data %DATA%;
	@echo off
	echo.
	echo bitbucketSettingsPullRequests bitti : %L_REPO%	
	cd %back%
GOTO:EOF