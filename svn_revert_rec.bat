@echo off

REM -------------------------------------------------------------------------------------------
REM Tortoise SVN sometimes has trouble reverting externals recursively,
REM giving errors like 'cannot revert XX without reverting children'
REM and forcing to manually revert each external one by one
REM
REM This script will recursively revert everything from %1 folder handling externals properly
REM then finishes with a cleanup.
REM
REM Additionally you can ask the script to delete unversioned/ignored files
REM -------------------------------------------------------------------------------------------

echo '%1'

IF "%1"=="/?" GOTO showhelp
IF "%1"=="" GOTO showhelp

GOTO run

:showhelp
echo svn_revert_rec path [/delunversioned] [/delignored]
exit /B

:run

REM --- check that svn & TortoiseSVN are installed
where /q svn.exe
IF ERRORLEVEL 1 (
echo svn.exe not in path !
exit /B
)

where /q TortoiseProc.exe
IF ERRORLEVEL 1 (
echo TortoiseProc.exe not in path !
exit /B
)

REM --- first, let's revert all subfolders, one by one
set SVN_REVERT_REC=svn revert -R
for /d %%d in (*) do (
 	echo Reverting %%d
 	cd %%d
 	%SVN_REVERT_REC% .
	IF ERRORLEVEL 1 (
		echo Svn error. Stopping
		exit /B
	)
 	cd ..	
)

REM --- then revert target folder
echo Reverting .
%SVN_REVERT_REC% .
IF ERRORLEVEL 1 (
	echo Svn error. Stopping
	exit /B
)

REM --- do a final cleanup, with optional /delunversioned /delignored
echo Cleanup (extra options: %2 %3)
TortoiseProc.exe /command:cleanup /path:. /noui /externals %2 %3
