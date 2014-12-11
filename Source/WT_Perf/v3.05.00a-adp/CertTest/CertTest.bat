@ECHO OFF
@ECHO.

REM *****************************************************
REM **  Test batch file for WT_Perf v3.05, 08-Nov-2012 **
REM *****************************************************


REM  Set up environment variables.  You will probably have to change these.

@SET Compare=FC
@SET CRUNCH=Call Crunch
@SET WT_Perf=..\WT_Perf
@SET WT_Perf=..\WT_Perf%1.exe
@SET DateTime=DateTime.exe
@SET Editor=NotePad.exe
@SET OutDev=NUL


REM  WT_Perf test sequence definition:

@SET  TEST01=Test #01: UAE Phase 3 turbine (Non-dimen, English, Space).
@SET  TEST02=Test #02: AWT-27CR2 (Dimen, Metric, Space).
@SET  TEST03=Test #03: 3-bladed CART turbine (Dimen, Metric, Tab).
@SET  TEST04=Test #04: WindPACT 50m turbine using PROPGA design (Non-dimen, Metric, Tab).
@SET  TEST05=Test #05: WindLite 8kW (Dimen, Metric, Space, Old AF).
@SET  TEST06=Test #06: 3-bladed CART turbine (Dimen, Metric, Tab, combined case).
@SET  TEST07=Test #07: Marine Hydrokinetic Reference Model (Dimen, Metric, Tab, combined case).

@SET  DASHES=---------------------------------------------------------------------------------------------
@SET  POUNDS=#############################################################################################

@IF EXIST CertTest.out  DEL CertTest.out

ECHO.                                                  >> CertTest.out
ECHO           *************************************** >> CertTest.out
ECHO           **  WT_Perf Acceptance Test Results  ** >> CertTest.out
ECHO           *************************************** >> CertTest.out

ECHO.                                                                             >> CertTest.out
ECHO ############################################################################ >> CertTest.out
ECHO # Inspect this file for any differences between your results and the saved # >> CertTest.out
ECHO # results.  Any differing lines and the two lines surrounding them will be # >> CertTest.out
ECHO # listed.  The only differences should be the time stamps at the start of  # >> CertTest.out
ECHO # each file.                                                               # >> CertTest.out
ECHO #                                                                          # >> CertTest.out
ECHO # If you are running on something other than a PC, you may see differences # >> CertTest.out
ECHO # in the last significant digit of many of the numbers.                    # >> CertTest.out
ECHO ############################################################################ >> CertTest.out

ECHO.                                            >> CertTest.out
ECHO Date and time this acceptance test was run: >> CertTest.out
%DateTime%                                       >> CertTest.out
ECHO.                                            >> CertTest.out


rem *******************************************************

@echo WT_Perf %TEST01%

@SET TEST=01_UAE

rem Run WT_Perf.

%WT_Perf% Test%TEST%.wtp > %OutDev%

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.oup  GOTO ERROR

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.bed  GOTO ERROR

echo.                                             >> CertTest.out
echo %POUNDS%                                     >> CertTest.out
echo.                                             >> CertTest.out
echo %TEST01%                                     >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.oup TestFiles\Test%TEST%.oup >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.bed TestFiles\Test%TEST%.bed >> CertTest.out


rem *******************************************************

@echo WT_Perf %TEST02%

@SET TEST=02_AWT27

rem Run WT_Perf.

%WT_Perf% Test%TEST%.wtp > %OutDev%

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.oup  GOTO ERROR

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.bed  GOTO ERROR

echo.                                             >> CertTest.out
echo %POUNDS%                                     >> CertTest.out
echo.                                             >> CertTest.out
echo %TEST02%                                     >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.oup TestFiles\Test%TEST%.oup >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.bed TestFiles\Test%TEST%.bed >> CertTest.out


rem *******************************************************

@echo WT_Perf %TEST03%

@SET TEST=03_CART3

rem Run WT_Perf.

%WT_Perf% Test%TEST%.wtp > %OutDev%

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.oup  GOTO ERROR

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.bed  GOTO ERROR

echo.                                             >> CertTest.out
echo %POUNDS%                                     >> CertTest.out
echo.                                             >> CertTest.out
echo %TEST03%                                     >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.oup TestFiles\Test%TEST%.oup >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.bed TestFiles\Test%TEST%.bed >> CertTest.out


rem *******************************************************

@echo WT_Perf %TEST04%

@SET TEST=04_WP15

rem Run WT_Perf.

%WT_Perf% Test%TEST%.wtp > %OutDev%

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.oup  GOTO ERROR

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.bed  GOTO ERROR

echo.                                             >> CertTest.out
echo %POUNDS%                                     >> CertTest.out
echo.                                             >> CertTest.out
echo %TEST04%                                     >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.oup TestFiles\Test%TEST%.oup >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.bed TestFiles\Test%TEST%.bed >> CertTest.out


rem *******************************************************

@echo WT_Perf %TEST05%

@SET TEST=05_WL8

rem Run WT_Perf.

%WT_Perf% Test%TEST%.wtp > %OutDev%

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.oup  GOTO ERROR

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.bed  GOTO ERROR

echo.                                             >> CertTest.out
echo %POUNDS%                                     >> CertTest.out
echo.                                             >> CertTest.out
echo %TEST05%                                     >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.oup TestFiles\Test%TEST%.oup >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.bed TestFiles\Test%TEST%.bed >> CertTest.out


rem *******************************************************

@echo WT_Perf %TEST06%

@SET TEST=06_CART3

rem Run WT_Perf.

%WT_Perf% Test%TEST%.wtp > %OutDev%

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.oup  GOTO ERROR

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.bed  GOTO ERROR

echo.                                             >> CertTest.out
echo %POUNDS%                                     >> CertTest.out
echo.                                             >> CertTest.out
echo %TEST06%                                     >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.oup TestFiles\Test%TEST%.oup >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.bed TestFiles\Test%TEST%.bed >> CertTest.out

rem *******************************************************

@echo WT_Perf %TEST07%

@SET TEST=07_MHK_RefModel

rem Run WT_Perf.

%WT_Perf% Test%TEST%.wtp > %OutDev%

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.oup  GOTO ERROR

IF ERRORLEVEL 1  GOTO ERROR

@IF NOT EXIST Test%TEST%.bed  GOTO ERROR

echo.                                             >> CertTest.out
echo %POUNDS%                                     >> CertTest.out
echo.                                             >> CertTest.out
echo %TEST07%                                     >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.oup TestFiles\Test%TEST%.oup >> CertTest.out
echo %DASHES%                                     >> CertTest.out
%Compare% Test%TEST%.bed TestFiles\Test%TEST%.bed >> CertTest.out


rem ******************************************************
rem  Let's look at the comparisons.

%Editor% CertTest.out
goto END

:ERROR
@echo ** An error has occured in Test #%TEST% **

:END

@SET Compare=
@SET DASHES=
@SET DateTime=
@SET Editor=
@SET WT_Perf=
@SET POUNDS=
@SET TEST=
@SET TEST01=
@SET TEST02=
@SET TEST03=
@SET TEST04=
@SET TEST05=
@SET TEST06=
@SET TEST07=

@echo 
@echo Processing complete.
