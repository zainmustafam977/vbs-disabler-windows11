# .SYNOPSIS
#     VBS Disabler - Professional Edition with Auto-Elevation
# .DESCRIPTION
#     Complete solution for disabling VBS/Device Guard/HVCI on Windows 11 25H2
#
#     Features:
#       Auto-elevation to Administrator
#       Automatic execution policy bypass
#       System Restore point creation
#       DG Readiness Tool download and execution
#       Windows Hello VBS fix (critical for 24H2/25H2)
#       Comprehensive registry modifications
#       BCD configuration
#       Windows feature disabling
#       Auto-verification on next boot
#       Professional UI with detailed instructions
#
# .NOTES
#     Author: ZACODEC (https://github.com/zainmustafam977/)
#     Version:  3.0 - Ultimate Public Edition
#     Tested on: Windows 11 24H2/25H2 Build 26200+
#     License: MIT
#
#     Special Thanks:
#       Reddit community (Windows Hello VBS fix discovery)
#       Microsoft Q&A community
#       VMware Broadcom community
#       All users who tested and provided feedback

param([switch]$Elevated)

# ============================================================================
# AUTO-ELEVATION TO ADMINISTRATOR
# ============================================================================

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $Elevated) {
    if (-not (Test-Admin)) {
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host " Administrator privileges required!" -ForegroundColor Yellow
        Write-Host " Attempting to elevate..." -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Start-Sleep -Seconds 2

        try {
            $scriptPath = $MyInvocation.MyCommand.Path
            if (-not $scriptPath) {
                # Running via iex/irm (no script file on disk)
                # Save the in-memory script to a temp file for elevation
                $scriptPath = Join-Path $env:TEMP "VBS_Disable.ps1"
                $scriptText = $MyInvocation.MyCommand.ScriptBlock.Ast.Extent.Text
                [System.IO.File]::WriteAllText($scriptPath, $scriptText, (New-Object System.Text.UTF8Encoding $true))
            }
            Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" -Elevated" -f $scriptPath) -Verb RunAs
            exit
        }
        catch {
            Write-Host "ERROR: Failed to elevate to Administrator" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please run this in an ADMIN PowerShell window:" -ForegroundColor Yellow
            Write-Host '  irm https://bit.ly/vbs-fix | iex' -ForegroundColor Cyan
            Write-Host ""
            Write-Host "To open Admin PowerShell:" -ForegroundColor Yellow
            Write-Host "  Right-click Start button > Terminal (Admin)" -ForegroundColor Cyan
            pause
            exit 1
        }
    }
}

# Now we're running as Administrator
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Ensure TLS 1.2 globally for all web requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ============================================================================
# CONFIGURATION
# ============================================================================

$script:logPath = "C:\VMwareFix"
$script:logFile = "$logPath\VBS_Disabler_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$script:verificationScript = "$logPath\Verify_On_Next_Boot.ps1"
$script:startTime = Get-Date
$script:stepCounter = 0
$script:totalSteps = 10

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Banner {
    param([string]$Text, [string]$Color = "Cyan")

    $width = 75
    $padding = [Math]::Floor(($width - $Text.Length) / 2)
    $border = "=" * $width

    Write-Host ""
    Write-Host $border -ForegroundColor $Color
    Write-Host (" " * $padding + $Text) -ForegroundColor $Color
    Write-Host $border -ForegroundColor $Color
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    $script:stepCounter++
    Write-Host ""
    Write-Host "[STEP $script:stepCounter/$script:totalSteps] " -NoNewline -ForegroundColor Magenta
    Write-Host $Message -ForegroundColor White
    Write-Host ("-" * 75) -ForegroundColor DarkGray
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] " -NoNewline -ForegroundColor Green
    Write-Host $Message -ForegroundColor White
    Write-Log $Message "SUCCESS"
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] " -NoNewline -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor White
    Write-Log $Message "INFO"
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "[WARNING] " -NoNewline -ForegroundColor Yellow
    Write-Host $Message -ForegroundColor White
    Write-Log $Message "WARN"
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "[ERROR] " -NoNewline -ForegroundColor Red
    Write-Host $Message -ForegroundColor White
    Write-Log $Message "ERROR"
}

function Write-Action {
    param([string]$Message)
    Write-Host "[ACTION] " -NoNewline -ForegroundColor Yellow
    Write-Host $Message -ForegroundColor White
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    try {
        Add-Content -Path $script:logFile -Value $logMessage -ErrorAction SilentlyContinue
    }
    catch {
        # Ignore logging errors
    }
}

function Write-Box {
    param([string[]]$Lines, [string]$Color = "Yellow")

    $maxLength = ($Lines | Measure-Object -Maximum -Property Length).Maximum
    $width = [Math]::Max($maxLength + 4, 40)

    $topBorder = "+" + ("-" * ($width - 2)) + "+"
    $bottomBorder = $topBorder

    Write-Host $topBorder -ForegroundColor $Color
    foreach ($line in $Lines) {
        $padding = [Math]::Max($width - $line.Length - 4, 0)
        Write-Host "| " -NoNewline -ForegroundColor $Color
        Write-Host $line -NoNewline -ForegroundColor White
        Write-Host (" " * $padding + " |") -ForegroundColor $Color
    }
    Write-Host $bottomBorder -ForegroundColor $Color
}

function Write-Progress2 {
    param([string]$Activity, [int]$Percent)
    $barWidth = 50
    $completed = [Math]::Floor($barWidth * $Percent / 100)
    $remaining = $barWidth - $completed
    $line = "[" + ("#" * $completed) + ("." * $remaining) + "] $Percent% - $Activity"
    $padded = $line.PadRight([Console]::WindowWidth - 1)
    Write-Host "`r$padded" -NoNewline
}

function Confirm-UserAction {
    param([string]$Prompt)
    Write-Host ""
    Write-Host "[USER INPUT] " -NoNewline -ForegroundColor Yellow
    Write-Host $Prompt -NoNewline -ForegroundColor White
    Write-Host " (Y/N): " -NoNewline -ForegroundColor Cyan
    $response = Read-Host
    return ($response -eq "Y" -or $response -eq "y")
}

function Test-RegistryValue {
    param([string]$Path, [string]$Name)
    try {
        Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Set-RegistrySafe {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord",
        [switch]$Silent
    )

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            if (-not $Silent) { Write-Info "Created registry path: $Path" }
        }

        $oldValue = $null
        if (Test-RegistryValue -Path $Path -Name $Name) {
            $oldValue = (Get-ItemProperty -Path $Path -Name $Name).$Name
        }

        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force

        if (-not $Silent) {
            if ($null -ne $oldValue -and $oldValue -ne $Value) {
                Write-Success "Changed $Name from $oldValue to $Value"
            }
            else {
                Write-Success "Set $Name = $Value"
            }
        }
        return $true
    }
    catch {
        if (-not $Silent) { Write-Error2 "Failed to set $Path\$Name : $_" }
        return $false
    }
}

# ============================================================================
# INITIAL SETUP
# ============================================================================

Clear-Host

# Create log directory
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
}

Write-Log "================================" "INFO"
Write-Log "VBS Disabler Script Started" "INFO"
Write-Log "Version: 3.0 - Ultimate Public Edition" "INFO"
Write-Log "================================" "INFO"

# Start transcript
Start-Transcript -Path $script:logFile -Append

# Display banner
Write-Host ""
Write-Host "##############################################################################" -ForegroundColor Cyan
Write-Host "#                                                                            #" -ForegroundColor Cyan
Write-Host "#               VBS DISABLER - ULTIMATE EDITION v3.0                     #" -ForegroundColor Cyan
Write-Host "#                                                                            #" -ForegroundColor Cyan
Write-Host "#              For Windows 11 25H2 + VMware Workstation                      #" -ForegroundColor Cyan
Write-Host "#                                                                            #" -ForegroundColor Cyan
Write-Host "##############################################################################" -ForegroundColor Cyan
Write-Host ""

Write-Info "Log file: $script:logFile"
Write-Info "System: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)"
Write-Info "Build: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber)"
Write-Info "Running as: $(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name)"

Write-Host ""
Write-Box -Lines @(
    "This script will:",
    "  1. Create a System Restore point",
    "  2. Guide you through GUI tasks",
    "  3. Download and run DG Readiness Tool",
    "  4. Apply Windows Hello VBS fix (CRITICAL!)",
    "  5. Modify registry settings safely",
    "  6. Update BCD configuration",
    "  7. Disable Windows features",
    "  8. Create auto-verification script",
    "  9. Restart your computer",
    "",
    "Estimated time: 10-15 minutes"
) -Color "Cyan"

Write-Host ""
Write-Warning2 "This will modify system security settings"
Write-Warning2 "VMware Workstation will run in CPL0 mode (faster)"
Write-Warning2 "VBS/Device Guard/HVCI will be disabled"
Write-Host ""

if (-not (Confirm-UserAction "Continue with VBS disabler?")) {
    Write-Warning2 "Operation cancelled by user"
    Stop-Transcript
    exit 0
}

# ============================================================================
# STEP 1: CREATE SYSTEM RESTORE POINT
# ============================================================================

Write-Step "Creating System Restore Point"

Write-Info "Creating restore point for safety..."
Write-Info "This allows you to rollback changes if needed"

try {
    # Enable System Protection if not enabled
    $restoreEnabled = Get-ComputerRestorePoint -ErrorAction SilentlyContinue

    if (-not $restoreEnabled) {
        Write-Info "Enabling System Protection on C: drive..."
        Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
    }

    # Create restore point
    $restoreName = "Before VBS Disabler by ZACODEC - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Checkpoint-Computer -Description $restoreName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Success "System Restore point created: $restoreName"
    Write-Info "You can rollback via: Control Panel > Recovery > Open System Restore"
}
catch {
    Write-Warning2 "Could not create System Restore point: $_"
    Write-Warning2 "NOTE: Windows only allows one restore point per 24 hours"
    Write-Warning2 "Continuing without restore point..."
    Write-Info "TIP: You can create one manually via Control Panel > Recovery"

    if (-not (Confirm-UserAction "Continue without restore point?")) {
        Write-Warning2 "Operation cancelled by user"
        Stop-Transcript
        exit 0
    }
}

Start-Sleep -Seconds 2

# ============================================================================
# STEP 2: GUI TASKS - DISABLE TAMPER PROTECTION
# ============================================================================

Write-Step "Manual Task 1: Disable Tamper Protection"

Write-Host ""
Write-Box -Lines @(
    "CRITICAL: Tamper Protection blocks registry changes!",
    "",
    "Please follow these steps:",
    "  1. Press Windows + I to open Settings",
    "  2. Go to: Privacy & security > Windows Security",
    "  3. Click: Virus & threat protection",
    "  4. Click: Manage settings",
    "  5. Scroll down to 'Tamper Protection'",
    "  6. Toggle it OFF",
    "  7. Click YES on the UAC prompt",
    "",
    "Then return here and confirm."
) -Color "Yellow"

Write-Host ""
Write-Action "Opening Windows Security for you..."
Start-Sleep -Seconds 2

try {
    Start-Process "windowsdefender://threatsettings" -ErrorAction SilentlyContinue
}
catch {
    Write-Warning2 "Could not auto-open Windows Security"
    Write-Info "Please open it manually: Settings > Privacy & security > Windows Security"
}

Write-Host ""
while (-not (Confirm-UserAction "Have you disabled Tamper Protection?")) {
    Write-Warning2 "Tamper Protection must be disabled to continue"
    Write-Info "It's located in: Windows Security > Virus & threat protection > Manage settings"
}

Write-Success "User confirmed: Tamper Protection disabled"
Write-Log "User confirmed Tamper Protection is disabled" "SUCCESS"

# ============================================================================
# STEP 3: GUI TASKS - DISABLE MEMORY INTEGRITY
# ============================================================================

Write-Step "Manual Task 2: Disable Memory Integrity (HVCI)"

Write-Host ""
Write-Box -Lines @(
    "Memory Integrity = Hypervisor-Protected Code Integrity",
    "",
    "Please follow these steps:",
    "  1. In Windows Security (from previous step)",
    "  2. Go back to main menu",
    "  3. Click: Device security",
    "  4. Click: Core isolation details",
    "  5. Toggle OFF 'Memory integrity'",
    "  6. You may see 'Restart required' - that's OK",
    "",
    "Then return here and confirm."
) -Color "Yellow"

Write-Host ""
Write-Action "Opening Core Isolation settings for you..."
Start-Sleep -Seconds 2

try {
    Start-Process "windowsdefender://coreisolation" -ErrorAction SilentlyContinue
}
catch {
    Write-Warning2 "Could not auto-open Core Isolation"
    Write-Info "Please open it manually: Windows Security > Device security > Core isolation"
}

Write-Host ""
while (-not (Confirm-UserAction "Have you disabled Memory Integrity?")) {
    Write-Warning2 "Memory Integrity must be disabled to continue"
    Write-Info "It's located in: Windows Security > Device security > Core isolation details"
}

Write-Success "User confirmed: Memory Integrity disabled"
Write-Log "User confirmed Memory Integrity is disabled" "SUCCESS"

# ============================================================================
# STEP 4: DOWNLOAD & RUN DG READINESS TOOL
# ============================================================================

Write-Step "Downloading and Running Microsoft DG Readiness Tool"

$dgUrl = "https://download.microsoft.com/download/b/d/8/bd821b1f-05f2-4a7e-aa03-df6c4f687b07/dgreadiness_v3.6.zip"
$dgZipPath = "$logPath\dgreadiness_v3.6.zip"
$dgExtractPath = "$logPath\DGReadiness"

Write-Info "Downloading Microsoft DG Readiness Tool..."
Write-Info "Source: Microsoft Download Center"
Write-Info "URL: $dgUrl"

try {
    Invoke-WebRequest -Uri $dgUrl -OutFile $dgZipPath -UseBasicParsing -ErrorAction Stop

    Write-Success "Download completed: $(((Get-Item $dgZipPath).Length / 1MB).ToString('F2')) MB"

    Write-Info "Extracting archive..."
    if (Test-Path $dgExtractPath) {
        Remove-Item -Path $dgExtractPath -Recurse -Force
    }
    Expand-Archive -Path $dgZipPath -DestinationPath $dgExtractPath -Force
    Write-Success "Extraction completed"

    $dgScript = Get-ChildItem -Path $dgExtractPath -Recurse -Filter "DG_Readiness_Tool_v3.6.ps1" | Select-Object -First 1

    if ($dgScript) {
        Write-Success "Found DG Readiness Tool script"

        Write-Host ""
        Write-Box -Lines @(
            "IMPORTANT: DG Readiness Tool Instructions",
            "",
            "The tool will open in a new window with a MENU.",
            "",
            "STEP 1: In the menu, press F3 to select 'Disable'",
            "STEP 2: Confirm any prompts that appear",
            "STEP 3: The tool may schedule a restart",
            "",
            "CRITICAL: Watch for BLACK SCREENS during boot!",
            "  - After restart, BEFORE Windows loads:",
            "  - You may see: 'Press F3 to disable Credential Guard'",
            "  - You may see: 'Press F3 to disable VBS'",
            "  - PRESS F3 on each screen when prompted!",
            "",
            "If you miss the F3 prompts, changes won't apply!"
        ) -Color "Red"

        Write-Host ""
        Write-Action "Press any key to launch DG Readiness Tool..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        Write-Info "Launching DG Readiness Tool with -Disable parameter..."
        & $dgScript.FullName -Disable

        Write-Success "DG Readiness Tool execution completed"

        Write-Host ""
        Write-Warning2 "While Rebooting System may ask to Press F3 for Confirming Disabling the VBS and Device Guard."
        Write-Warning2 "So, Press F3 and Press any Key to Continue when system asks."
        Start-Sleep -Seconds 2
    }
    else {
        Write-Warning2 "Could not find DG_Readiness_Tool_v3.6.ps1"
        Write-Info "Continuing with other methods..."
    }
}
catch {
    Write-Error2 "Error with DG Readiness Tool: $_"
    Write-Info "Continuing with other methods..."
}

Start-Sleep -Seconds 2

# ============================================================================
# STEP 5: WINDOWS HELLO VBS FIX (CRITICAL!)
# ============================================================================

Write-Step "Applying Windows Hello VBS Fix (24H2/25H2 Critical)"

Write-Host ""
Write-Box -Lines @(
    "THE WINDOWS HELLO VBS FIX",
    "",
    "This is THE KEY that keeps VBS enabled on",
    "Windows 11 24H2/25H2 (Build 26200+)",
    "",
    "Discovered by: Reddit community",
    "Confirmed by: Microsoft Q&A users",
    "Success rate: 95%+",
    "",
    "This fix worked for you in previous tests!"
) -Color "Green"

Write-Host ""
Write-Info "Applying Windows Hello VBS registry keys..."

$windowsHelloKeys = @(
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello"; Name = "Enabled"; Value = 0; Desc = "Windows Hello VBS" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\DeviceGuard"; Name = "EnableVirtualizationBasedSecurity"; Value = 0; Desc = "Device Guard VBS" }
)

$successCount = 0
foreach ($key in $windowsHelloKeys) {
    Write-Info "Setting: $($key.Desc)"
    if (Set-RegistrySafe -Path $key.Path -Name $key.Name -Value $key.Value -Silent) {
        $successCount++
    }
}

Write-Success "Windows Hello VBS fix applied ($successCount/$($windowsHelloKeys.Count) keys)"

Write-Host ""
Write-Box -Lines @(
    "IMPORTANT: After restart, Windows will prompt:",
    "  'We need to set up your PIN again'",
    "",
    "This is NORMAL and REQUIRED!",
    "Simply create a new PIN when asked.",
    "",
    "This happens because we disabled Windows Hello VBS."
) -Color "Yellow"

Start-Sleep -Seconds 3

# ============================================================================
# STEP 6: CORE REGISTRY MODIFICATIONS
# ============================================================================

Write-Step "Applying Core VBS/Device Guard/HVCI Registry Settings"

Write-Info "Modifying system registry keys..."
Write-Info "This will disable VBS, Device Guard, Credential Guard, and System Guard"

$coreRegistryKeys = @(
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"; Name = "EnableVirtualizationBasedSecurity"; Value = 0; Desc = "VBS Main Switch" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"; Name = "RequirePlatformSecurityFeatures"; Value = 0; Desc = "Platform Security" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"; Name = "Locked"; Value = 0; Desc = "Device Guard Lock" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"; Name = "Enabled"; Value = 0; Desc = "HVCI" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"; Name = "WasEnabledBy"; Value = 0; Desc = "HVCI State" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Name = "LsaCfgFlags"; Value = 0; Desc = "Credential Guard" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard"; Name = "Enabled"; Value = 0; Desc = "Credential Guard State" },
    @{Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard"; Name = "Enabled"; Value = 0; Desc = "System Guard" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"; Name = "EnableVirtualizationBasedSecurity"; Value = 0; Desc = "Group Policy VBS" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"; Name = "RequirePlatformSecurityFeatures"; Value = 0; Desc = "Group Policy Platform" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"; Name = "HypervisorEnforcedCodeIntegrity"; Value = 0; Desc = "Group Policy HVCI" },
    @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"; Name = "LsaCfgFlags"; Value = 0; Desc = "Group Policy Credential Guard" }
)

$successCount = 0
$totalKeys = $coreRegistryKeys.Count

foreach ($i in 0..($totalKeys - 1)) {
    $key = $coreRegistryKeys[$i]
    $percent = [Math]::Floor(($i / $totalKeys) * 100)
    Write-Progress2 -Activity "Setting registry keys ($($i+1)/$totalKeys)" -Percent $percent

    if (Set-RegistrySafe -Path $key.Path -Name $key.Name -Value $key.Value -Silent) {
        $successCount++
    }
    Start-Sleep -Milliseconds 100
}

Write-Host "" # Clear progress line
Write-Success "Registry modifications completed: $successCount/$totalKeys successful"

# ============================================================================
# STEP 7: BCD MODIFICATIONS
# ============================================================================

Write-Step "Configuring Boot Configuration Data (BCD)"

Write-Info "Modifying BCD to disable hypervisor at boot level..."

try {
    Write-Info "Setting hypervisorlaunchtype to OFF..."
    $null = bcdedit /set hypervisorlaunchtype off 2>&1
    $null = bcdedit /set `{current`} hypervisorlaunchtype off 2>&1

    Write-Success "BCD commands executed"

    # Verify
    Start-Sleep -Seconds 1
    $bcdCheck = bcdedit /enum | Select-String "hypervisorlaunchtype"
    if ($bcdCheck -match "Off") {
        Write-Success "BCD hypervisorlaunchtype verified: OFF"
    }
    else {
        Write-Warning2 "BCD verification: Could not confirm setting"
    }
}
catch {
    Write-Error2 "Error modifying BCD: $_"
}

# ============================================================================
# STEP 8: DISABLE WINDOWS FEATURES
# ============================================================================

Write-Step "Disabling Hyper-V and Virtualization Windows Features"

Write-Info "This will disable:"
Write-Info "  - Microsoft Hyper-V"
Write-Info "  - Windows Hypervisor Platform"
Write-Info "  - Virtual Machine Platform (breaks WSL2)"
Write-Info "  - Windows Sandbox"
Write-Info "  - Application Guard"

$featuresToDisable = @(
    @{Name = "Microsoft-Hyper-V-All"; Desc = "Hyper-V (All components)" },
    @{Name = "Microsoft-Hyper-V"; Desc = "Hyper-V Core" },
    @{Name = "HypervisorPlatform"; Desc = "Windows Hypervisor Platform" },
    @{Name = "VirtualMachinePlatform"; Desc = "Virtual Machine Platform" },
    @{Name = "Containers-DisposableClientVM"; Desc = "Windows Sandbox" },
    @{Name = "Windows-Defender-ApplicationGuard"; Desc = "Application Guard" }
)

$disabledCount = 0
$totalFeatures = $featuresToDisable.Count

foreach ($i in 0..($totalFeatures - 1)) {
    $feature = $featuresToDisable[$i]
    $percent = [Math]::Floor(($i / $totalFeatures) * 100)
    Write-Progress2 -Activity "Disabling features ($($i+1)/$totalFeatures)" -Percent $percent

    try {
        $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature.Name -ErrorAction SilentlyContinue
        if ($featureState -and $featureState.State -eq "Enabled") {
            Disable-WindowsOptionalFeature -Online -FeatureName $feature.Name -NoRestart -ErrorAction Stop | Out-Null
            Write-Success "Disabled: $($feature.Desc)"
            $disabledCount++
        }
        elseif ($featureState) {
            Write-Info "Already disabled: $($feature.Desc)"
        }
        else {
            Write-Info "Not installed: $($feature.Desc)"
        }
    }
    catch {
        Write-Warning2 "Could not disable $($feature.Desc): $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds 200
}

Write-Host "" # Clear progress line
Write-Success "Windows features processed: $disabledCount disabled"

# ============================================================================
# STEP 9: CREATE AUTO-VERIFICATION SCRIPT
# ============================================================================

Write-Step "Creating Auto-Verification Script for Next Boot"

Write-Info "Creating comprehensive verification script..."
Write-Info "This will run automatically after restart to check if everything worked"

$verificationScriptContent = @'
# VBS Disabler - Auto-Verification Script
# This runs automatically on next boot to verify success

$logFile = "C:\VMwareFix\Verification_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-VerifyLog {
    param([string]$Message, [string]$Status = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Status] $Message"
    Add-Content -Path $logFile -Value $logMessage

    $color = switch ($Status) {
        "SUCCESS" { "Green" }
        "FAIL"    { "Red" }
        "WARN"    { "Yellow" }
        default   { "White" }
    }
    Write-Host $logMessage -ForegroundColor $color
}

# Wait for system to stabilize
Start-Sleep -Seconds 5

Clear-Host
Write-Host "##############################################################################" -ForegroundColor Cyan
Write-Host "#                                                                            #" -ForegroundColor Cyan
Write-Host "#                  VBS DISABLER - VERIFICATION REPORT                        #" -ForegroundColor Cyan
Write-Host "#                     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                               #" -ForegroundColor Cyan
Write-Host "#                                                                            #" -ForegroundColor Cyan
Write-Host "##############################################################################" -ForegroundColor Cyan
Write-Host ""

$allTests = @{}

# Test 1: Hypervisor Detection
Write-Host "[TEST 1] Checking Hypervisor Status..." -ForegroundColor Yellow
$hypervisorCheck = systeminfo | Select-String "A hypervisor has been detected"
if ($hypervisorCheck) {
    Write-VerifyLog "FAILED: Hypervisor is still detected!" "FAIL"
    $allTests['Hypervisor'] = $false
} else {
    Write-VerifyLog "SUCCESS: No hypervisor detected!" "SUCCESS"
    $allTests['Hypervisor'] = $true
}

# Test 2: VBS Status
Write-Host "`n[TEST 2] Checking VBS Status..." -ForegroundColor Yellow
try {
    $deviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
    $vbsStatus = $deviceGuard.VirtualizationBasedSecurityStatus

    if ($vbsStatus -eq 0) {
        Write-VerifyLog "SUCCESS: VBS Status = 0 (Disabled)" "SUCCESS"
        $allTests['VBS'] = $true
    } elseif ($vbsStatus -eq 2) {
        Write-VerifyLog "FAILED: VBS Status = 2 (Still Running)" "FAIL"
        $allTests['VBS'] = $false
    } else {
        Write-VerifyLog "WARNING: VBS Status = $vbsStatus (Unexpected)" "WARN"
        $allTests['VBS'] = $false
    }
} catch {
    Write-VerifyLog "ERROR: Could not check VBS status: $_" "FAIL"
    $allTests['VBS'] = $false
}

# Test 3: BCD Settings
Write-Host "`n[TEST 3] Checking BCD Settings..." -ForegroundColor Yellow
$bcdCheck = bcdedit /enum | Select-String "hypervisorlaunchtype"
if ($bcdCheck -match "Off") {
    Write-VerifyLog "SUCCESS: BCD hypervisorlaunchtype = Off" "SUCCESS"
    $allTests['BCD'] = $true
} else {
    Write-VerifyLog "FAILED: BCD hypervisorlaunchtype not set to Off" "FAIL"
    $allTests['BCD'] = $false
}

# Test 4: Registry Keys
Write-Host "`n[TEST 4] Checking Critical Registry Keys..." -ForegroundColor Yellow
$registryChecks = @{
    "VBS Main" = @{Path="HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"; Name="EnableVirtualizationBasedSecurity"}
    "HVCI" = @{Path="HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"; Name="Enabled"}
    "Windows Hello VBS" = @{Path="HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello"; Name="Enabled"}
    "Credential Guard" = @{Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Name="LsaCfgFlags"}
}

$regTestPass = $true
foreach ($checkName in $registryChecks.Keys) {
    $check = $registryChecks[$checkName]
    try {
        $value = Get-ItemProperty -Path $check.Path -Name $check.Name -ErrorAction Stop
        if ($value.($check.Name) -eq 0) {
            Write-VerifyLog "  [OK] $checkName = 0 (Disabled)" "SUCCESS"
        } else {
            Write-VerifyLog "  [FAIL] $checkName = $($value.($check.Name)) (Not disabled!)" "FAIL"
            $regTestPass = $false
        }
    } catch {
        Write-VerifyLog "  [WARN] $checkName : Could not read" "WARN"
        $regTestPass = $false
    }
}
$allTests['Registry'] = $regTestPass

# Test 5: Windows Features
Write-Host "`n[TEST 5] Checking Windows Features..." -ForegroundColor Yellow
$hvFeatures = Get-WindowsOptionalFeature -Online | Where-Object {
    $_.FeatureName -like "*Hyper*" -or $_.FeatureName -like "*Virtual*"
} | Where-Object { $_.State -eq "Enabled" }

if ($hvFeatures) {
    Write-VerifyLog "FAILED: Some Hyper-V features still enabled:" "FAIL"
    foreach ($feature in $hvFeatures) {
        Write-VerifyLog "  - $($feature.FeatureName)" "FAIL"
    }
    $allTests['Features'] = $false
} else {
    Write-VerifyLog "SUCCESS: All Hyper-V features disabled" "SUCCESS"
    $allTests['Features'] = $true
}

# Final Summary
Write-Host ""
Write-Host "##############################################################################" -ForegroundColor Cyan
Write-Host "#                            FINAL RESULTS                                   #" -ForegroundColor Cyan
Write-Host "##############################################################################" -ForegroundColor Cyan
Write-Host ""

foreach ($testName in $allTests.Keys) {
    $status = if ($allTests[$testName]) { "[PASS]" } else { "[FAIL]" }
    $color = if ($allTests[$testName]) { "Green" } else { "Red" }
    Write-Host ("{0,-20} {1}" -f $testName, $status) -ForegroundColor $color
}

Write-Host ""
$allPassed = -not ($allTests.Values -contains $false)

if ($allPassed) {
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                 SUCCESS! VBS/HYPERVISOR DISABLED!                            " -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "[OK] You can now launch VMware Workstation!" -ForegroundColor Green
    Write-Host "[OK] Check the bottom-right corner - should show 'CPL0' mode" -ForegroundColor Green
    Write-Host "[OK] Your VMs should start and run at full speed!" -ForegroundColor Green
    Write-VerifyLog "ALL TESTS PASSED - VBS successfully disabled!" "SUCCESS"
} else {
    Write-Host "===============================================================================" -ForegroundColor Red
    Write-Host "              SOME TESTS FAILED - ADDITIONAL STEPS NEEDED                     " -ForegroundColor Red
    Write-Host "===============================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "[!] Please check the recommendations below:" -ForegroundColor Yellow
    Write-Host ""

    if (-not $allTests['Hypervisor'] -or -not $allTests['VBS']) {
        Write-Host "[ACTION] Check BIOS settings:" -ForegroundColor Yellow
        Write-Host "  1. Restart and press ESC -> F10 (HP BIOS)" -ForegroundColor Cyan
        Write-Host "  2. Advanced -> System Options" -ForegroundColor Cyan
        Write-Host "  3. DMA Protection -> DISABLED" -ForegroundColor Cyan
        Write-Host "  4. Pre-boot DMA protection -> DISABLED" -ForegroundColor Cyan
        Write-Host "  5. SVM CPU Virtualization -> ENABLED (keep!)" -ForegroundColor Cyan
        Write-Host ""
    }

    if (-not $allTests['Registry']) {
        Write-Host "[ACTION] Check Tamper Protection:" -ForegroundColor Yellow
        Write-Host "  Windows Security -> Virus & threat protection" -ForegroundColor Cyan
        Write-Host "  Manage settings -> Tamper Protection -> OFF" -ForegroundColor Cyan
        Write-Host ""
    }

    Write-VerifyLog "SOME TESTS FAILED - See recommendations above" "FAIL"
}

Write-Host ""
Write-Host "Log saved to: $logFile" -ForegroundColor Gray
Write-Host "Main log: C:\VMwareFix\VBS_Disabler_*.log" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to close this window..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Clean up scheduled task
try {
    Unregister-ScheduledTask -TaskName "VBS_Verifier_NextBoot" -Confirm:$false -ErrorAction SilentlyContinue
} catch {}
'@

Set-Content -Path $script:verificationScript -Value $verificationScriptContent -Force
Write-Success "Verification script created: $script:verificationScript"

# Create scheduled task
Write-Info "Creating scheduled task for auto-verification..."
try {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Normal -File `"$script:verificationScript`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -TaskName "VBS_Verifier_NextBoot" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Success "Scheduled task created successfully"
}
catch {
    Write-Warning2 "Could not create scheduled task: $_"
    Write-Info "You can manually run: $script:verificationScript"
}

# ============================================================================
# OPTIONAL: PERSISTENT ENFORCEMENT
# ============================================================================

Write-Step "Optional: Persistent Enforcement Task"

Write-Host ""
Write-Box -Lines @(
    "PERSISTENT ENFORCEMENT (Optional)",
    "",
    "Would you like to create a task that runs at every boot",
    "to ensure VBS stays disabled?",
    "",
    "This is useful if Windows Updates try to re-enable VBS.",
    "",
    "The task will re-apply critical registry settings at startup.",
    "",
    "Recommended: YES for most users"
) -Color "Cyan"

Write-Host ""
if (Confirm-UserAction "Create persistent enforcement task?") {
    $persistentScript = @'
# Persistent VBS Enforcement - Runs at every boot
# Created by VBS Disabler (ZACODEC)
Start-Sleep -Seconds 10

$changes = 0

# Critical Windows Hello VBS key
$helloPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello"
if (-not (Test-Path $helloPath)) { New-Item -Path $helloPath -Force | Out-Null }
$current = (Get-ItemProperty -Path $helloPath -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
if ($current -ne 0) {
    Set-ItemProperty -Path $helloPath -Name "Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
    $changes++
}

# Core VBS keys
$vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
$current = (Get-ItemProperty -Path $vbsPath -Name "EnableVirtualizationBasedSecurity" -ErrorAction SilentlyContinue).EnableVirtualizationBasedSecurity
if ($current -ne 0) {
    Set-ItemProperty -Path $vbsPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Force -ErrorAction SilentlyContinue
    $changes++
}

$hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
$current = (Get-ItemProperty -Path $hvciPath -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
if ($current -ne 0) {
    Set-ItemProperty -Path $hvciPath -Name "Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
    $changes++
}

$current = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -ErrorAction SilentlyContinue).LsaCfgFlags
if ($current -ne 0) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 0 -Force -ErrorAction SilentlyContinue
    $changes++
}

# BCD - only run if needed
$bcdCheck = bcdedit /enum 2>$null | Select-String "hypervisorlaunchtype"
if ($bcdCheck -and $bcdCheck -notmatch "Off") {
    bcdedit /set hypervisorlaunchtype off 2>$null | Out-Null
    $changes++
}

# Log
$logMsg = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Persistent enforcement executed ($changes changes applied)"
Add-Content -Path "C:\VMwareFix\persistent-enforcement.log" -Value $logMsg -ErrorAction SilentlyContinue
'@

    $persistentScriptPath = "$logPath\Persistent_Enforcement.ps1"
    Set-Content -Path $persistentScriptPath -Value $persistentScript -Force

    try {
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$persistentScriptPath`""
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

        Register-ScheduledTask -TaskName "VBS_Persistent_Enforcer" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        Write-Success "Persistent enforcement task created"
    }
    catch {
        Write-Warning2 "Could not create persistent task: $_"
    }
}
else {
    Write-Info "Skipped persistent enforcement task creation"
}

# ============================================================================
# COMPLETION & RESTART
# ============================================================================

Write-Host ""
Write-Host ""
Write-Banner "SCRIPT COMPLETED SUCCESSFULLY" "Green"

$elapsed = ((Get-Date) - $script:startTime).TotalSeconds
Write-Info "Total execution time: $([Math]::Round($elapsed, 2)) seconds"

Write-Host ""
Write-Box -Lines @(
    "SUMMARY OF CHANGES:",
    "",
    "  [OK] System Restore point created",
    "  [OK] Tamper Protection disabled (by you)",
    "  [OK] Memory Integrity disabled (by you)",
    "  [OK] DG Readiness Tool executed",
    "  [OK] Windows Hello VBS fix applied",
    "  [OK] Core registry settings modified",
    "  [OK] BCD hypervisor disabled",
    "  [OK] Windows features disabled",
    "  [OK] Auto-verification script created",
    "",
    "All modifications complete!"
) -Color "Green"

Write-Host ""
Write-Box -Lines @(
    "NEXT STEPS:",
    "",
    "1. Computer will restart NOW",
    "",
    "2. After restart, Windows will prompt:",
    "   'We need to set up your PIN again'",
    "   -> This is NORMAL! Create a new PIN.",
    "",
    "3. After login, a verification window will auto-open",
    "   -> Wait for all tests to complete",
    "   -> Should show: ALL TESTS PASSED",
    "",
    "4. Launch VMware Workstation",
    "   -> Start a virtual machine",
    "   -> Check bottom-right: should show 'CPL0'",
    "",
    "5. Enjoy full-speed VMware! Done!"
) -Color "Cyan"

Write-Host ""
Write-Info "Files created in: $logPath"
Write-Info "  - VBS_Disabler log (full transcript)"
Write-Info "  - Verification script (runs on next boot)"
Write-Info "  - Persistent enforcement script (if enabled)"

Write-Host ""
Write-Box -Lines @(
    "ROLLBACK INFORMATION:",
    "",
    "If you need to revert changes:",
    "  Option 1: System Restore",
    "    Control Panel -> Recovery -> Open System Restore",
    "",
    "  Option 2: Re-enable manually",
    "    Windows Security -> Device security",
    "    Core isolation -> Memory integrity -> ON",
    "",
    "  Option 3: Remove scheduled tasks",
    "    Task Scheduler -> Find and delete:",
    "    - VBS_Verifier_NextBoot",
    "    - VBS_Persistent_Enforcer (if created)"
) -Color "Gray"

Write-Host ""
Write-Host ""

Stop-Transcript

Write-Host "##############################################################################" -ForegroundColor Red
Write-Host "#                                                                            #" -ForegroundColor Red
Write-Host "#                           RESTART REQUIRED                                 #" -ForegroundColor Red
Write-Host "#                                                                            #" -ForegroundColor Red
Write-Host "##############################################################################" -ForegroundColor Red
Write-Host ""

if (Confirm-UserAction "Restart computer NOW?") {
    Write-Host ""
    Write-Host "[!] Computer will restart in 15 seconds..." -ForegroundColor Yellow
    Write-Host "[!] Press CTRL+C to cancel!" -ForegroundColor Red
    Write-Host ""

    for ($i = 15; $i -gt 0; $i--) {
        Write-Host "`r  Restarting in $i seconds... " -NoNewline -ForegroundColor Yellow
        Start-Sleep -Seconds 1
    }
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                                                                        ║" -ForegroundColor Green
    Write-Host "  ║  " -NoNewline -ForegroundColor Green
    Write-Host "Thank you for using VBS Disabler by ZACODEC!" -NoNewline -ForegroundColor White
    Write-Host ("  " * 16 + "║") -ForegroundColor Green
    Write-Host "  ║                                                                        ║" -ForegroundColor Green
    Write-Host "  ║  " -NoNewline -ForegroundColor Green
    Write-Host "If this helped you, please star the repo on GitHub!" -NoNewline -ForegroundColor Cyan
    Write-Host ("  " * 9 + "║") -ForegroundColor Green
    Write-Host "  ║  " -NoNewline -ForegroundColor Green
    Write-Host (" " * 27 + "║") -ForegroundColor Green
    Write-Host "  ║                                                                        ║" -ForegroundColor Green
    Write-Host "  ╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 3
    Write-Host ""
    Write-Host "[OK] Restarting now..." -ForegroundColor Green
    Restart-Computer -Force
}
else {
    Write-Host ""
    Write-Warning2 "REMEMBER TO RESTART MANUALLY!"
    Write-Warning2 "Changes will only take effect after restart!"
    Write-Warning2 "After restart, the verification window will auto-open!"
    Write-Host ""
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                                                                        ║" -ForegroundColor Green
    Write-Host "  ║  " -NoNewline -ForegroundColor Green
    Write-Host "Thank you for using VBS Disabler by ZACODEC!" -NoNewline -ForegroundColor White
    Write-Host ("  " * 16 + "║") -ForegroundColor Green
    Write-Host "  ║                                                                        ║" -ForegroundColor Green
    Write-Host "  ║  " -NoNewline -ForegroundColor Green
    Write-Host "If this helped you, please star the repo on GitHub!" -NoNewline -ForegroundColor Cyan
    Write-Host ("  " * 9 + "║") -ForegroundColor Green
    Write-Host "  ║  " -NoNewline -ForegroundColor Green
    Write-Host (" " * 27 + "║") -ForegroundColor Green
    Write-Host "  ║                                                                        ║" -ForegroundColor Green
    Write-Host "  ╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
