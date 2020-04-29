@echo off
chcp 65001 >nul

powershell.exe -ExecutionPolicy RemoteSigned -NoProfile -NoLogo -WindowStyle Hidden -File ".\Scripts\AlterID.ps1"