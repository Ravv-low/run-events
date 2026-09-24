# ngrok-manager.ps1
# Script to automate Laravel serve and Ngrok with Windows Firewall configuration

# 1. Require Administrator Privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Script ini memerlukan hak akses Administrator untuk mengonfigurasi Firewall."
    Write-Host "Mencoba menjalankan ulang sebagai Administrator..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   PaceNation - Ngrok & Laravel Manager" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 2. Check for Ngrok
$ngrokPath = Get-Command ngrok -ErrorAction SilentlyContinue
if (-not $ngrokPath) {
    Write-Error "Ngrok tidak ditemukan di sistem (Environment Variables)."
    Write-Host "Silakan download dari https://ngrok.com/download dan tambahkan ngrok.exe ke PATH Windows Anda."
    Write-Host "Atau, letakkan file ngrok.exe di dalam folder project ini: " + (Get-Location).Path
    $ngrokPath = Join-Path (Get-Location).Path "ngrok.exe"
    if (-not (Test-Path $ngrokPath)) {
        Read-Host "Tekan Enter untuk keluar"
        exit
    }
} else {
    $ngrokPath = $ngrokPath.Source
}
Write-Host "[OK] Ngrok ditemukan: $ngrokPath" -ForegroundColor Green

# 3. Configure Windows Firewall
$ruleName = "Allow Ngrok (PaceNation)"
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if (-not $existingRule) {
    Write-Host "[..] Menambahkan rule Firewall untuk Ngrok..." -ForegroundColor Yellow
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Program $ngrokPath -Action Allow -Profile Any | Out-Null
    Write-Host "[OK] Firewall rule ditambahkan." -ForegroundColor Green
} else {
    Write-Host "[OK] Firewall rule sudah ada." -ForegroundColor Green
}

# 4. Stop existing instances
Write-Host "[..] Membersihkan proses lama..." -ForegroundColor Yellow
Stop-Process -Name "php" -ErrorAction SilentlyContinue
Stop-Process -Name "ngrok" -ErrorAction SilentlyContinue

# 5. Start Laravel Server (Port 8080)
Write-Host "[..] Menjalankan Laravel di port 8080..." -ForegroundColor Yellow
$laravelProcess = Start-Process php -ArgumentList "artisan serve --port=8080" -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3 # Tunggu server siap

if ($laravelProcess.HasExited) {
    Write-Error "Gagal menjalankan Laravel. Pastikan port 8080 belum digunakan."
    Read-Host "Tekan Enter untuk keluar"
    exit
}
Write-Host "[OK] Laravel berjalan di http://127.0.0.1:8080" -ForegroundColor Green

# 6. Start Ngrok
Write-Host "[..] Menjalankan Ngrok (port 8080)..." -ForegroundColor Yellow
$ngrokProcess = Start-Process $ngrokPath -ArgumentList "http 8080" -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3 # Tunggu ngrok aktif

if ($ngrokProcess.HasExited) {
    Write-Error "Gagal menjalankan Ngrok. Pastikan Anda sudah login (ngrok config add-authtoken <token>)."
    Stop-Process -Id $laravelProcess.Id -Force
    Read-Host "Tekan Enter untuk keluar"
    exit
}
Write-Host "[OK] Ngrok berjalan di background." -ForegroundColor Green

# 7. Health Check and Display Status Loop
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Mendapatkan URL Publik Ngrok..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = $response.tunnels[0].public_url
    
    Write-Host ""
    Write-Host "  ---> Website Anda Live di: " -NoNewline
    Write-Host "$publicUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "Tekan CTRL+C untuk menghentikan server dan ngrok." -ForegroundColor Cyan
    Write-Host "Status Koneksi:"
} catch {
    Write-Error "Gagal menghubungi API Ngrok. Apakah ngrok benar-benar berjalan?"
}

try {
    while ($true) {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -ErrorAction SilentlyContinue
        if ($response -and $response.tunnels) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Tunnel AKTIF -> $($response.tunnels[0].public_url)" -ForegroundColor Green
        } else {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Tunnel MATI/GANGGUAN" -ForegroundColor Red
        }
        Start-Sleep -Seconds 10
    }
} finally {
    Write-Host "Menghentikan semua proses..." -ForegroundColor Yellow
    Stop-Process -Id $laravelProcess.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $ngrokProcess.Id -Force -ErrorAction SilentlyContinue
    Write-Host "Proses dihentikan." -ForegroundColor Green
}
