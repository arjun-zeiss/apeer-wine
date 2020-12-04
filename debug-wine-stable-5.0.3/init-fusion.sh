#!/bin/bash

wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v ForceLog /t REG_DWORD /d 1 /f
wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v LogFailures /t REG_DWORD /d 1 /f
wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v LogResourceBinds /t REG_DWORD /d 1 /f
wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v EnableLog /t REG_DWORD /d 1 /f
mkdir /opt/wineprefix/drive_c/FusionLog
wine64 reg add "HKLM\\SOFTWARE\\Microsoft\\Fusion" /v EnableLog /t REG_SZ /d "C:\\FusionLog\\" /f