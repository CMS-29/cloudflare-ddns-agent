param(
    [switch]$NoService,
    [switch]$Silent
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "C:\CF-DDNS\Install and Update\cf-ddns-updater $timestamp log.txt"

$serviceInstall = 1

if ($NoService) {
    Write-Host "[INFO] NoService has been specified, services will not be touched." -ForegroundColor Cyan
    $serviceInstall = 0
    if (Get-Service -Name "CF-DDNS" -ErrorAction SilentlyContinue) {
        if ((Get-Service -Name "CF-DDNS").Status -eq "Running") {
            if ($Silent) {
                Write-Host "[WARN] A pre-existing service was found and is running, it's a good idea to stop this before proceeding." -ForegroundColor Yellow
                Write-Host "[INFO] Silent tag used, will proceed automatically"
            }
            else {
                Write-Warning -Message "A pre-existing service was found and is running, it's a good idea to stop this before proceeding." -WarningAction Inquire
            }
        }
    }
}
else {
    Write-Host "[INFO] Will also install new service." -ForegroundColor Cyan
}

# Installation Location
$installLocation = "C:\CF-DDNS\"

# Service Check
if ($serviceInstall -eq 1) {
    if (Get-Service -Name "CF-DDNS" -ErrorAction SilentlyContinue) {
        Write-Host "[INFO] Service CF-DDNS Exists already, will stop and remove" -ForegroundColor Cyan
        if ((Get-Service -Name "CF-DDNS").Status -eq "Running") {
            Stop-Service -Name "CF-DDNS" -Force
        }
        if (Get-Command "nssm.exe" -ErrorAction SilentlyContinue) {
            nssm.exe remove CF-DDNS confirm
        }
    }
    else {
        Write-Host "[INFO] Service CF-DDNS does not exist, will proceed" -ForegroundColor Cyan
    }
}

# Github Retrieval
$githubrepo = "https://github.com/CMS-29/cloudflare-ddns-agent"
Write-Host "[INFO] Downloading latest release from Github"  -ForegroundColor Cyan
Invoke-RestMethod -Uri "$githubRepo/releases/latest/download/cf-ddns.exe" -OutFile "$installLocation\cf-ddns.exe"

if ($serviceInstall -eq 1) {

    $serviceInstallState = 0

    # Check NSSM Status
    if (Get-Command "nssm.exe" -ErrorAction SilentlyContinue) {
        # NSSM Installed, proceed
        Write-Host "[SUCCESS] NSSM was found" -ForegroundColor Green
        $serviceInstallState = 1
    }
    else {
        # NSSM not installed, try to install
        Write-Host "[WARN] NSSM was not found"  -ForegroundColor Yellow
        Write-Host "[INFO] Attempting Installation of NSSM"  -ForegroundColor Cyan

        Write-Host "[INFO] Checking Winget Status" -ForegroundColor Cyan
        if (Get-Command "winget.exe" -ErrorAction SilentlyContinue) {
            # Winget Install
            Write-Host "[INFO] Winget was found, will use to install" -ForegroundColor Green
            winget install NSSM.NSSM --silent --accept-package-agreements --accept-source-agreements
            if (Get-Command "nssm.exe" -ErrorAction SilentlyContinue) {
                $serviceInstallState = 1
            }
        }
        else {
            Write-Host "[WARN] Winget not installed, will try Chocolatey"  -ForegroundColor Yellow
            Write-Host "[INFO] Checking Chocolatey Status" -ForegroundColor Cyan
            $chocopath = "C:\ProgramData\chocolatey"
            $chocoapp = "$chocopath\choco.exe"
            if (Test-Path -Path $chocoapp -PathType Leaf) {
                # Chocolately Install
                Write-Error "[INFO] Chocolatey was found, will use to install" -ForegroundColor Green
                Set-Location $chocopath
                .\choco.exe install nssm -y --force
                if (Get-Command "nssm.exe" -ErrorAction SilentlyContinue) {
                    $serviceInstallState = 1
                }
            }
            else {
                # Install failed
                Write-Host "[WARN] Chocolatey not installed"  -ForegroundColor Yellow
                Write-Host "[FATAL] Cannot proceed with service, cannot install NSSM"  -ForegroundColor Red
                $serviceInstallState = 0
            }
        }
    }

    if ($serviceInstallState -eq 1) {
        nssm.exe install "CF-DDNS" "$installLocation\cf-ddns.exe"
        nssm.exe set "CF-DDNS" DisplayName "Cloudflare DDNS Agent"
        nssm.exe start "CF-DDNS"
    }

}

Write-Host "[INFO] COMPLETED" -ForegroundColor Green

Stop-Transcript
exit 0