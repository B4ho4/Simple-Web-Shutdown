@echo off
title ULTIMATE CLEANER (V1-V12 COMPLETE WIPE)
color 4f

:: --- YONETICI IZNI KONTROLU ---
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :start
) else (
    echo Yonetici izni isteniyor...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit
)

:start
cls
echo ===============================================
echo      TUM ULTIMATE CONTROL SISTEMI SILINIYOR...
echo      V1'den V12'ye her sey yok edilecek.
echo      Dikkat: Bu islem geri alinamaz.
echo ===============================================
echo.
timeout /t 3 >nul

echo [1/7] Hayalet islemler durduruluyor...
:: V12'nin gizli ajani (WScript) ve sunucu (PowerShell) kapatiliyor
taskkill /f /im wscript.exe >nul 2>&1
taskkill /f /im powershell.exe >nul 2>&1

echo [2/7] Baslangic ayarlari (Registry) siliniyor...
:: V6, V7, V8, V9, V10, V11, V12 Kayit Defteri girdileri
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "UltimateControl" /f >nul 2>&1

echo [3/7] Eski Baslangic dosyalari siliniyor...
:: V5 Startup klasoru kalintisi
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\UltimateControl.vbs" del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\UltimateControl.vbs" >nul 2>&1

echo [4/7] Zamanlanmis Gorevler siliniyor...
:: V1, V2, V3, V4 gorevleri
schtasks /delete /tn "SimpleWebShutdown" /f >nul 2>&1
schtasks /delete /tn "UltimateControlPanel" /f >nul 2>&1

echo [5/7] Guvenlik Duvari (Firewall) temizleniyor...
:: Port 8080 izinleri iptal ediliyor
powershell -Command "Remove-NetFirewallRule -DisplayName 'Simple Web Shutdown' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Remove-NetFirewallRule -DisplayName 'Ultimate Control Panel' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Remove-NetFirewallRule -DisplayName 'UltimateControl' -ErrorAction SilentlyContinue" >nul 2>&1

echo [6/7] Proje klasorleri yok ediliyor...
:: C diskindeki tum versiyon klasorleri
if exist "C:\SimpleWebShutdown" rmdir /s /q "C:\SimpleWebShutdown"
if exist "C:\UltimateControlPanel" rmdir /s /q "C:\UltimateControlPanel"
if exist "C:\UltimateV5" rmdir /s /q "C:\UltimateV5"
if exist "C:\UltimateControl" rmdir /s /q "C:\UltimateControl"

echo [7/7] Gecici dosyalar ve copler temizleniyor...
:: Pano kopru dosyalari
if exist "%temp%\clip_data.txt" del "%temp%\clip_data.txt" >nul 2>&1
if exist "%temp%\ultimate_clip_bridge.txt" del "%temp%\ultimate_clip_bridge.txt" >nul 2>&1
if exist "%temp%\ghost_clip.txt" del "%temp%\ghost_clip.txt" >nul 2>&1
if exist "%temp%\ghost_runner.vbs" del "%temp%\ghost_runner.vbs" >nul 2>&1
if exist "%temp%\server.ps1" del "%temp%\server.ps1" >nul 2>&1
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" >nul 2>&1

echo.
echo ===============================================
echo      TEMIZLIK BASARIYLA TAMAMLANDI!
echo      Bilgisayarin tertemiz oldu.
echo ===============================================
echo.
pause