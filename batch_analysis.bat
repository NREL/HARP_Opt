@ECHO OFF
cls
@ECHO.

ECHO "==========================================================="
ECHO "  _   _   ___  ______ ______            _____         _    "
ECHO " | | | | / _ \ | ___ \| ___ \          |  _  |       | |   "
ECHO " | |_| |/ /_\ \| |_/ /| |_/ /          | | | | _ __  | |_  "
ECHO " |  _  ||  _  ||    / |  __/           | | | || '_ \ | __| "
ECHO " | | | || | | || |\ \ | |              \ \_/ /| |_) || |_  "
ECHO " \_| |_/\_| |_/\_| \_|\_|               \___/ | .__/  \__| "
ECHO "                               ______         | |          "
ECHO "                              |______|        |_|          "
ECHO "                                                           "
ECHO "==========================================================="
REM run all the HARP_Opt test cases
ECHO running test cases...

HARP_Opt_windows.exe Input\test_FSFP.inp
HARP_Opt_windows.exe Input\test_VSFP.inp
HARP_Opt_windows.exe Input\test_VSFP_fixedTSR.inp
HARP_Opt_windows.exe Input\test_FSVP-F.inp
HARP_Opt_windows.exe Input\test_VSVP-F.inp
HARP_Opt_windows.exe Input\test_VSVP-S.inp
REM HARP_Opt_windows.exe Input\test_FSFP_MOGA.inp
REM HARP_Opt_windows.exe Input\test_VSVP-F_MOGA.inp