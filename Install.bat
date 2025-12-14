<# : Batch Script Section
@echo off
title Ultimate Control V12 (GHOST PROTOCOL)...
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
cls

echo ===============================================
echo      ULTIMATE CONTROL V12 (GHOST PROTOCOL)
echo      Method: VBScript Wrapper (Zero Window)
echo      Developer: @b4ho4_
echo ===============================================
echo.

:: 1. Temizlik
taskkill /f /im powershell.exe >nul 2>&1
rmdir /s /q "C:\UltimateControl" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "UltimateControl" /f >nul 2>&1

:: 2. Kurulum
set "INSTALL_DIR=C:\UltimateControl"
mkdir "%INSTALL_DIR%"

:: 3. Scripti Çıkar
echo Extracting Ghost Core...
powershell -Noprofile -ExecutionPolicy Bypass -Command "$lines = Get-Content -Path '%~f0'; $start = $lines.IndexOf('# BEGIN_PAYLOAD') + 1; $end = $lines.IndexOf('# END_PAYLOAD') - 1; $lines[$start..$end] | Set-Content -Path '%INSTALL_DIR%\server.ps1' -Encoding UTF8"

:: 4. Başlatıcıyı Hazırla (VBS ile tamamen gizli başlatma)
echo Creating Ghost Launcher...
(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""%INSTALL_DIR%\server.ps1""", 0, False
) > "%INSTALL_DIR%\launcher.vbs"

:: 5. Registry (VBS dosyasını çalıştıracak - Penceresiz)
echo Registering Startup...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "UltimateControl" /t REG_SZ /d "wscript.exe \"%INSTALL_DIR%\launcher.vbs\"" /f

:: 6. Firewall
echo Configuring Network...
powershell -Command "Remove-NetFirewallRule -DisplayName 'UltimateControl' -ErrorAction SilentlyContinue; New-NetFirewallRule -DisplayName 'UltimateControl' -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow" >nul 2>&1

:: 7. Başlat
echo Starting Ghost Server...
start "" wscript.exe "%INSTALL_DIR%\launcher.vbs"

echo.
echo ===============================================
echo      KURULUM TAMAMLANDI.
echo      Hicbir pencere acilmayacak. Garanti.
echo ===============================================
echo.
pause
exit /b
: end batch / begin powershell #>

# BEGIN_PAYLOAD
# --- CONFIG ---
$Port = 8080
$SecretPIN = "000"
# --------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Web
$wsh = New-Object -ComObject WScript.Shell

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$Port/")
$listener.Start()

# Dosya Yolları
$ClipFile = "$env:TEMP\ghost_clip.txt"
$VbsRunner = "$env:TEMP\ghost_runner.vbs"

# --- HELPER: WINDOWS'UN GÖRMEDİĞİ KOMUT ÇALIŞTIRICISI ---
function Run-Ghost($PSCommand) {
    # Komutu Base64'e çevirip VBS'e yediriyoruz ki tırnak işareti sorunu olmasın
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($PSCommand)
    $Encoded = [Convert]::ToBase64String($Bytes)
    
    $VbsCode = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell -NoProfile -EncodedCommand $Encoded", 0, True
"@
    $VbsCode | Set-Content -Path $VbsRunner -Encoding ASCII
    # WScript ile çalıştır (0 = Gizli Pencere, True = Bitmesini Bekle)
    Start-Process wscript.exe -ArgumentList $VbsRunner -Wait -WindowStyle Hidden
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $req = $context.Request
    $res = $context.Response
    $res.Headers.Add("Access-Control-Allow-Origin", "*")
    $res.ContentEncoding = [System.Text.Encoding]::UTF8
    $res.ContentType = "text/html; charset=utf-8"

    $path = $req.Url.LocalPath
    $reply = "OK"

    # --- LOGIN ---
    if ($path -eq "/login") {
        $p = $req.QueryString["p"]
        if ($p -eq $SecretPIN) { $reply = "OK" } else { $reply = "FAIL" }
        $buf = [System.Text.Encoding]::UTF8.GetBytes($reply)
        $res.ContentLength64 = $buf.Length
        $res.OutputStream.Write($buf, 0, $buf.Length)
        $res.Close()
        continue
    }

    # --- GET CLIPBOARD (PC -> PHONE) [VBS WRAPPER] ---
    if ($path -eq "/getclip") {
        $p = $req.QueryString["p"]
        if ($p -eq $SecretPIN) {
            # PowerShell komutunu VBS üzerinden GİZLİ çalıştır
            # Panoyu al -> Dosyaya yaz
            Run-Ghost "Get-Clipboard | Set-Content -Path '$ClipFile' -Encoding UTF8 -Force"
            
            if (Test-Path $ClipFile) {
                $rawText = Get-Content -Path $ClipFile -Raw -Encoding UTF8
                # JSON escape
                $safe = $rawText -replace '\\', '\\\\' -replace '"', '\"' -replace "`r", '' -replace "`n", '\n'
                $reply = "{""text"":""$safe""}"
            } else {
                $reply = "{""text"":""""}"
            }
            $res.ContentType = "application/json"
        } else { $reply = "{""error"":""Auth""}" }
        
        $buf = [System.Text.Encoding]::UTF8.GetBytes($reply)
        $res.ContentLength64 = $buf.Length
        $res.OutputStream.Write($buf, 0, $buf.Length)
        $res.Close()
        continue
    }

    # --- STATUS ---
    if ($path -eq "/status") {
        $p = $req.QueryString["p"]
        if ($p -eq $SecretPIN) {
            try {
                $cpu = (Get-CimInstance Win32_Processor).LoadPercentage
                $os = Get-CimInstance Win32_OperatingSystem
                $ram = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100)
                $uptime = (Get-Date) - $os.LastBootUpTime
                $upStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
                $reply = "{""cpu"":$cpu, ""ram"":$ram, ""uptime"":""$upStr""}"
                $res.ContentType = "application/json"
            } catch { $reply = "{""error"":""Wait""}" }
        }
        $buf = [System.Text.Encoding]::UTF8.GetBytes($reply)
        $res.ContentLength64 = $buf.Length
        $res.OutputStream.Write($buf, 0, $buf.Length)
        $res.Close()
        continue
    }

    # --- COMMANDS ---
    if ($path -eq "/cmd") {
        $c = $req.QueryString["c"]
        $p = $req.QueryString["p"]
        $v = $req.QueryString["v"]

        if ($p -eq $SecretPIN) {
            switch ($c) {
                "play" { $wsh.SendKeys([char]179) }
                "prev" { $wsh.SendKeys([char]177) }
                "next" { $wsh.SendKeys([char]176) }
                "vup"  { $wsh.SendKeys([char]175) }
                "vdw"  { $wsh.SendKeys([char]174) }
                "mute" { $wsh.SendKeys([char]173) }
                "sleep"{ & rundll32.exe powrprof.dll,SetSuspendState 0,1,0 }
                "off"  { & shutdown.exe /s /t 0 }
                "rest" { & shutdown.exe /r /t 0 }
                "calc" { Start-Process calc }
                "notepad" { Start-Process notepad }
                "steam" { Start-Process "steam://open/main" }
                "browser" { Start-Process "https://www.google.com" }
                
                "clip" {
                    # PHONE -> PC: VBS Wrapper ile Sessiz Yazma
                    $txt = [System.Web.HttpUtility]::UrlDecode($v)
                    [System.IO.File]::WriteAllText($ClipFile, $txt, [System.Text.Encoding]::UTF8)
                    # Dosyayı oku -> Panoya set et (GİZLİ)
                    Run-Ghost "Get-Content -Path '$ClipFile' -Encoding UTF8 | Set-Clipboard"
                }
            }
        }
        $buf = [System.Text.Encoding]::UTF8.GetBytes("OK")
        $res.ContentLength64 = $buf.Length
        $res.OutputStream.Write($buf, 0, $buf.Length)
        $res.Close()
        continue
    }

    # --- UI ---
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Ultimate V12</title>
    <style>
        :root { --bg: #050505; --card: #161616; --accent: #2563eb; --text: #ffffff; --success: #10b981; --danger: #ef4444; }
        * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; user-select: none; }
        body { background: var(--bg); color: var(--text); margin: 0; padding: 20px; min-height: 100vh; display: flex; flex-direction: column; align-items: center; }
        
        #login { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: #000; z-index: 99; display: flex; justify-content: center; align-items: center; flex-direction: column; }
        .pin-in { background: #1a1a1a; border: 1px solid #333; color: #fff; font-size: 36px; text-align: center; padding: 15px; border-radius: 18px; width: 240px; margin-bottom: 25px; outline: none; letter-spacing: 10px; font-weight: bold; }
        .btn-go { background: var(--accent); color: #fff; padding: 18px 60px; border-radius: 18px; font-weight: 700; border: none; font-size: 18px; cursor: pointer; box-shadow: 0 4px 15px rgba(37, 99, 235, 0.3); }

        #app { display: none; width: 100%; max-width: 440px; padding-bottom: 60px; }
        .header { display: flex; justify-content: space-between; align-items: center; width: 100%; margin-bottom: 25px; margin-top: 10px; }
        h1 { font-size: 26px; font-weight: 900; margin: 0; background: linear-gradient(135deg, #ffffff 0%, #a5a5a5 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; letter-spacing: -0.5px; }
        .badge { background: #1a1a1a; padding: 6px 14px; border-radius: 20px; font-size: 11px; font-weight: bold; color: #ef4444; border: 1px solid #333; cursor: pointer; }

        .sect { font-size: 11px; color: #666; font-weight: 800; margin: 35px 0 12px 5px; letter-spacing: 1.5px; text-transform: uppercase; }
        .grid { display: grid; gap: 14px; }
        .g4 { grid-template-columns: repeat(4, 1fr); }
        .g3 { grid-template-columns: repeat(3, 1fr); }

        .btn { background: var(--card); border: 1px solid #222; border-radius: 22px; height: 90px; display: flex; flex-direction: column; justify-content: center; align-items: center; cursor: pointer; transition: 0.1s; position: relative; overflow: hidden; }
        .btn:active { background: #262626; transform: scale(0.96); }
        .ico { font-size: 30px; margin-bottom: 8px; }
        .lbl { font-size: 11px; color: #888; font-weight: 600; }

        .clip-area { background: var(--card); border: 1px solid #222; border-radius: 24px; padding: 18px; display: flex; flex-direction: column; gap: 14px; }
        .clip-in { background: #0a0a0a; border: 1px solid #333; color: #fff; padding: 16px; border-radius: 14px; font-size: 15px; outline: none; width: 100%; transition: border 0.3s; }
        .clip-in:focus { border-color: var(--accent); }
        
        .c-btn { width: 100%; padding: 18px 0; border-radius: 14px; font-weight: 800; font-size: 13px; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; transition: transform 0.1s; }
        .c-btn:active { transform: scale(0.98); }
        
        .btn-send { background: var(--accent); color: white; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2); margin-top: 5px; }
        .btn-get { background: #222; color: #aaa; border: 1px solid #333; font-size: 13px; }
        .btn-get:active { background: #333; color: white; }

        .red { color: var(--danger); background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.2); }
        .blue { color: var(--accent); background: rgba(37, 99, 235, 0.1); border-color: rgba(37, 99, 235, 0.2); }
        
        .dash { display: flex; gap: 12px; margin-bottom: 10px; }
        .d-card { flex: 1; background: var(--card); border: 1px solid #222; border-radius: 20px; text-align: center; padding: 18px 5px; }
        .d-val { font-size: 20px; font-weight: 800; margin-bottom: 4px; color: #fff; }
        .d-lbl { font-size: 10px; color: #555; font-weight: 800; letter-spacing: 0.5px; }

        #toast { visibility: hidden; min-width: 200px; background-color: #222; color: #fff; text-align: center; border-radius: 50px; padding: 16px 24px; position: fixed; z-index: 100; left: 50%; transform: translateX(-50%); bottom: 40px; font-size: 14px; font-weight: 600; box-shadow: 0 10px 30px rgba(0,0,0,0.5); opacity: 0; transition: opacity 0.3s, bottom 0.3s; border: 1px solid #333; }
        #toast.show { visibility: visible; opacity: 1; bottom: 60px; }
        .t-success { border-color: var(--success) !important; color: var(--success) !important; }
        .t-error { border-color: var(--danger) !important; color: var(--danger) !important; }

        .footer { margin-top: 50px; text-align: center; }
        .footer a { color: #444; text-decoration: none; font-size: 11px; font-weight: 700; letter-spacing: 1px; transition: color 0.3s; }
        .footer a:hover { color: var(--accent); }
    </style>
</head>
<body>

    <div id="toast">Notification</div>

    <div id="login">
        <input type="tel" id="pin" class="pin-in" maxlength="4" placeholder="••••">
        <button class="btn-go" onclick="auth()">UNLOCK</button>
    </div>

    <div id="app">
        <div class="header">
            <h1>CONTROL V12</h1>
            <div class="badge" onclick="logout()">LOCK</div>
        </div>
        
        <div class="dash">
            <div class="d-card"><div class="d-val" id="cpu">--%</div><div class="d-lbl">CPU</div></div>
            <div class="d-card"><div class="d-val" id="ram">--%</div><div class="d-lbl">RAM</div></div>
            <div class="d-card"><div class="d-val" id="up">--</div><div class="d-lbl">UPTIME</div></div>
        </div>

        <div class="sect">CLIPBOARD SYNC</div>
        <div class="clip-area">
            <input type="text" id="clip" class="clip-in" placeholder="Type here...">
            <button class="c-btn btn-send" onclick="sendClip()">SEND TO PC</button>
            <button class="c-btn btn-get" onclick="getClip()">PULL FROM PC</button>
        </div>

        <div class="sect">APPS</div>
        <div class="grid g4">
            <div class="btn blue" onclick="req('calc', 'Calculator')"><div class="ico">&#128409;</div><div class="lbl">Calc</div></div>
            <div class="btn blue" onclick="req('notepad', 'Notepad')"><div class="ico">&#128221;</div><div class="lbl">Note</div></div>
            <div class="btn blue" onclick="req('browser', 'Chrome')"><div class="ico">&#127760;</div><div class="lbl">Web</div></div>
            <div class="btn blue" onclick="req('steam', 'Steam')"><div class="ico">&#127918;</div><div class="lbl">Steam</div></div>
        </div>

        <div class="sect">MEDIA</div>
        <div class="grid g3">
            <div class="btn" onclick="req('prev')"><div class="ico">&#9194;</div></div>
            <div class="btn" onclick="req('play')"><div class="ico">&#9199;</div></div>
            <div class="btn" onclick="req('next')"><div class="ico">&#9193;</div></div>
            <div class="btn" onclick="req('vdw')"><div class="ico">&#128265;</div></div>
            <div class="btn" onclick="req('mute')"><div class="ico">&#128263;</div></div>
            <div class="btn" onclick="req('vup')"><div class="ico">&#128266;</div></div>
        </div>

        <div class="sect">SYSTEM POWER</div>
        <div class="grid g3">
            <div class="btn" onclick="confirmReq('sleep', 'Sleep Mode')"><div class="ico">&#127769;</div><div class="lbl">Sleep</div></div>
            <div class="btn red" onclick="confirmReq('rest', 'Restart')"><div class="ico">&#8635;</div><div class="lbl">Restart</div></div>
            <div class="btn red" onclick="confirmReq('off', 'Shutdown')"><div class="ico">&#9211;</div><div class="lbl">OFF</div></div>
        </div>
        
        <div class="footer">
            <a href="https://instagram.com/b4ho4_" target="_blank">MADE BY @B4HO4_</a>
        </div>
    </div>

    <script>
        let myPin = localStorage.getItem('pin') || "";
        if(myPin) { document.getElementById('pin').value = myPin; auth(); }

        function showToast(msg, type) {
            let x = document.getElementById("toast");
            x.className = "show " + (type === 'success' ? 't-success' : 't-error');
            x.innerText = msg;
            setTimeout(function(){ x.className = x.className.replace("show", ""); }, 2500);
        }

        function auth() {
            let p = document.getElementById('pin').value;
            fetch('/login?p=' + p).then(r => r.text()).then(res => {
                if(res === 'OK') {
                    localStorage.setItem('pin', p);
                    myPin = p;
                    document.getElementById('login').style.display = 'none';
                    document.getElementById('app').style.display = 'block';
                    startStats();
                } else { showToast('Incorrect PIN', 'error'); }
            });
        }

        function logout() {
            localStorage.removeItem('pin');
            location.reload();
        }
        
        function startStats() {
            setInterval(() => {
                fetch('/status?p=' + myPin).then(r => r.json()).then(d => {
                    if(!d.error) {
                        document.getElementById('cpu').innerText = d.cpu + '%';
                        document.getElementById('ram').innerText = d.ram + '%';
                        document.getElementById('up').innerText = d.uptime;
                    }
                });
            }, 3000);
        }

        function req(c, label='') {
            if(navigator.vibrate) navigator.vibrate(40);
            fetch('/cmd?c=' + c + '&p=' + myPin + '&v=').then(r => r.text()).then(res => {
                if(label && res === 'OK') showToast(label + ' Started', 'success');
            });
        }

        function confirmReq(c, label) {
            if(confirm('Are you sure you want to ' + label + '?')) {
                req(c);
                showToast(label + ' Initiated', 'success');
            }
        }

        function sendClip() {
            let txt = document.getElementById('clip').value;
            if(!txt) { showToast('Type something first!', 'error'); return; }
            if(navigator.vibrate) navigator.vibrate(40);
            
            fetch('/cmd?c=clip&p=' + myPin + '&v=' + encodeURIComponent(txt)).then(r => r.text()).then(res => {
                showToast('Sent to PC Clipboard!', 'success');
                document.getElementById('clip').value = '';
                document.getElementById('clip').blur();
            });
        }

        function getClip() {
            if(navigator.vibrate) navigator.vibrate(40);
            fetch('/getclip?p=' + myPin).then(r => r.json()).then(d => {
                if(d.text) {
                    document.getElementById('clip').value = d.text;
                    showToast('Copied from PC!', 'success');
                } else {
                    showToast('PC Clipboard is empty', 'error');
                }
            });
        }
    </script>
</body>
</html>
"@

    $buf = [System.Text.Encoding]::UTF8.GetBytes($html)
    $res.ContentLength64 = $buf.Length
    $res.OutputStream.Write($buf, 0, $buf.Length)
    $res.Close()
}
# END_PAYLOAD