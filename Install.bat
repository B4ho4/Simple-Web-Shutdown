<# : Batch Script Section
@echo off
title Installing Simple Web Shutdown...
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
cls

:: --- CONFIGURATION ---
set "INSTALL_DIR=C:\SimpleWebShutdown"
:: ---------------------

echo ===============================================
echo      INSTALLING SIMPLE WEB SHUTDOWN...
echo      Target: %INSTALL_DIR%
echo      Created by @b4ho4_
echo ===============================================
echo.

:: 1. Create Directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: 2. Extract Script
echo Extracting server script...
powershell -Noprofile -ExecutionPolicy Bypass -Command "$lines = Get-Content -Path '%~f0'; $start = $lines.IndexOf('# BEGIN_PAYLOAD') + 1; $end = $lines.IndexOf('# END_PAYLOAD') - 1; $lines[$start..$end] | Set-Content -Path '%INSTALL_DIR%\server.ps1' -Encoding UTF8"

:: 3. Configure Task
echo Configuring Ghost Mode...
schtasks /delete /tn "SimpleWebShutdown" /f >nul 2>&1
powershell -Command "Register-ScheduledTask -TaskName 'SimpleWebShutdown' -Action (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -ExecutionPolicy Bypass -File ""%INSTALL_DIR%\server.ps1""') -Trigger (New-ScheduledTaskTrigger -AtStartup) -User 'SYSTEM' -RunLevel Highest -Force" >nul 2>&1

:: 4. Configure Firewall
echo Configuring Firewall...
powershell -Command "Remove-NetFirewallRule -DisplayName 'Simple Web Shutdown' -ErrorAction SilentlyContinue; New-NetFirewallRule -DisplayName 'Simple Web Shutdown' -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow" >nul 2>&1

echo.
echo ===============================================
echo      INSTALLATION COMPLETE!
echo      Please restart your computer.
echo ===============================================
echo.
pause
exit /b
: end batch / begin powershell #>

# BEGIN_PAYLOAD
# --- SETTINGS ---
$Port = 8080
$SecretPIN = "000"
# ----------------

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$Port/")
$listener.Start()

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    $response.ContentType = "text/html; charset=utf-8"
    $response.ContentEncoding = [System.Text.Encoding]::UTF8

    $html = @"
    <!DOCTYPE html>
    <html lang='en'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no'>
        <title>PC Control</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
            body { background: linear-gradient(135deg, #1e3c72, #2a5298); height: 100vh; display: flex; justify-content: center; align-items: center; color: white; overflow: hidden; flex-direction: column; }
            .glass-panel { background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.2); padding: 40px 30px; border-radius: 24px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4); text-align: center; width: 85%; max-width: 350px; animation: float 6s ease-in-out infinite; }
            h2 { margin-bottom: 25px; font-weight: 600; letter-spacing: 1px; font-size: 20px; text-transform: uppercase; color: #ffffff; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }
            .pin-display { width: 100%; padding: 15px; font-size: 26px; text-align: center; background: rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 12px; color: #fff; outline: none; letter-spacing: 8px; margin-bottom: 25px; transition: 0.3s; }
            .pin-display:focus { background: rgba(0, 0, 0, 0.4); border-color: #4facfe; box-shadow: 0 0 15px rgba(79, 172, 254, 0.4); }
            .btn-shutdown { width: 100%; padding: 18px; border: none; border-radius: 12px; background: linear-gradient(45deg, #ff416c, #ff4b2b); color: white; font-size: 16px; font-weight: 700; cursor: pointer; transition: transform 0.2s; text-transform: uppercase; letter-spacing: 1px; box-shadow: 0 5px 15px rgba(255, 65, 108, 0.4); }
            .btn-shutdown:active { transform: scale(0.95); }
            .status-icon { font-size: 50px; margin-bottom: 10px; display: block; text-shadow: 0 5px 15px rgba(0,0,0,0.3); }
            .footer { margin-top: 20px; font-size: 12px; color: rgba(255,255,255,0.4); text-decoration: none; position: absolute; bottom: 20px; }
            .footer a { color: rgba(255,255,255,0.6); text-decoration: none; font-weight: bold; transition: 0.3s; }
            .footer a:hover { color: #fff; text-shadow: 0 0 10px rgba(255,255,255,0.5); }
            @keyframes float { 0% { transform: translateY(0px); } 50% { transform: translateY(-10px); } 100% { transform: translateY(0px); } }
        </style>
    </head>
    <body>
        <div class='glass-panel'>
            <span class="status-icon">&#128421;</span>
            <h2>SYSTEM CONTROL</h2>
            <form method='GET' action='/shutdown'>
                <input type='tel' name='pin' class='pin-display' placeholder='&bull; &bull; &bull;' required maxlength='4' autocomplete='off'>
                <button type='submit' class='btn-shutdown'>SHUTDOWN</button>
            </form>
        </div>
        <div class="footer">Made by <a href="https://instagram.com/b4ho4_" target="_blank">@b4ho4_</a></div>
    </body>
    </html>
"@

    if ($request.Url.LocalPath -eq "/shutdown") {
        $incomingPin = $request.QueryString["pin"]
        if ($incomingPin -eq $SecretPIN) {
            $html = "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><style>body { margin:0; height:100vh; display:flex; justify-content:center; align-items:center; background:#121212; color:#00e676; font-family:sans-serif; text-align:center; }</style></head><body><div><div style='font-size:80px;'>&#10003;</div><h2 style='margin-top:20px;'>Good Bye!</h2><p style='color:#888;'>Shutting down...</p></div></body></html>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
            Start-Sleep -Seconds 1
            & shutdown.exe /s /t 0
            continue 
        } else {
            $html = "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><style>body { margin:0; height:100vh; display:flex; justify-content:center; align-items:center; background:#1a0505; color:#ff5252; font-family:sans-serif; text-align:center; }</style></head><body><div><div style='font-size:60px;'>&#10005;</div><h2>Wrong PIN</h2><script>setTimeout(function(){history.back()}, 1000);</script></div></body></html>"
        }
    }
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.Close()
}
# END_PAYLOAD
