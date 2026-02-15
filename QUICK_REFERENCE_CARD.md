# 📋 VBS Disabler — Quick Reference Card

> **Print this or keep it open in another window while running the script!**
>
> Full documentation: [README.md](README.md) &bull; Security info: [SECURITY.md](SECURITY.md)

---

## 🎯 HOW TO RUN THE SCRIPT

### Method 1: Right-Click (Easiest)
1. Right-click: Final_VBS_Disabler_Professional_v2.ps1
2. Select: "Run with PowerShell"
3. Script auto-elevates to Administrator
4. Follow on-screen instructions

### Method 2: PowerShell
```powershell
# Just run it - no need for Set-ExecutionPolicy!
.\Final_VBS_Disabler_Professional_v2.ps1

# Script handles:
# - Auto-elevation to Administrator
# - Execution policy bypass
# - System restore point creation
```

---

## WHAT THE SCRIPT DOES AUTOMATICALLY

| Step | What Happens | User Action |
|------|--------------|-------------|
| **Auto-Elevation** | Restarts as Administrator | Allow UAC prompt |
| **System Restore** | Creates restore point | None - automatic |
| **Tamper Protection** | Guides you to disable | Follow instructions |
| **Memory Integrity** | Guides you to disable | Follow instructions |
| **DG Tool** | Downloads & runs automatically | Press F3 in menu |
| **Windows Hello Fix** | Applies critical registry key | None - automatic |
| **Registry** | Sets all VBS/HVCI keys | None - automatic |
| **BCD** | Disables hypervisor | None - automatic |
| **Features** | Disables Hyper-V | None - automatic |
| **Verification** | Creates auto-check script | None - automatic |
| **Restart** | Restarts computer | Confirm with Y |

---

## VISUAL OUTPUT GUIDE

The script uses color-coded output:

- **[SUCCESS]** = Green = Operation completed successfully
- **[INFO]** = Cyan = Information / status update
- **[WARNING]** = Yellow = Important notice
- **[ERROR]** = Red = Something went wrong
- **[ACTION]** = Yellow = User action required
- **[USER INPUT]** = Yellow = Waiting for your response

Progress bars show: `[###########.......] 50%`

---

## AFTER RESTART - WHAT TO EXPECT

### Step 1: Windows Hello PIN Reset (NORMAL!)
```
Windows shows: "We need to set up your PIN again"

ACTION: Click "Set up PIN" and create a new PIN
This is EXPECTED and REQUIRED!
```

### Step 2: Verification Window Opens Automatically
```
A PowerShell window opens showing 5 tests:
  [TEST 1] Hypervisor Status ... [PASS]
  [TEST 2] VBS Status .......... [PASS]
  [TEST 3] BCD Settings ........ [PASS]
  [TEST 4] Registry Keys ....... [PASS]
  [TEST 5] Windows Features .... [PASS]

If all show [PASS] -> SUCCESS!
```

### Step 3: Launch VMware
```
1. Open VMware Workstation
2. Start a virtual machine
3. Look at bottom-right corner
4. Should show: "CPL0" (not "ULM")
```

---

## QUICK VERIFICATION COMMANDS

Run these in PowerShell to check status:

```powershell
# Check if hypervisor is disabled (should show NO "detected")
systeminfo | findstr /i "hyper"

# Check VBS status (should show 0, not 2)
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select VirtualizationBasedSecurityStatus

# Check BCD (should show "Off")
bcdedit /enum | findstr hypervisor

# Check Windows Hello VBS key (should show 0)
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" -Name "Enabled"
```

---

## TROUBLESHOOTING QUICK FIXES

### Problem: Hypervisor still detected after restart

**Quick Fix 1: Check BIOS**
```
1. Restart -> ESC -> F10 (HP BIOS)
2. Advanced -> System Options
3. DMA Protection -> DISABLED
4. Pre-boot DMA protection -> DISABLED
5. SVM CPU Virtualization -> ENABLED (keep!)
6. F10 -> Save
```

**Quick Fix 2: Manual Registry**
```powershell
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" /v "Enabled" /t REG_DWORD /d 0 /f
bcdedit /set hypervisorlaunchtype off
Restart-Computer
```

### Problem: VMware shows "ULM" instead of "CPL0"

**Quick Fix: HVCI still active**
```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -Force
Restart-Computer
```

### Problem: Verification shows "VBS Status = 2"

**Quick Fix: Windows Hello key not applied**
```powershell
# Check if key exists
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" -Name "Enabled"

# If not 0, set it
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" -Name "Enabled" -Value 0 -Force
Restart-Computer
```

### Problem: Changes revert after Windows Update

**Quick Fix: Run persistent enforcement manually**
```powershell
# Navigate to VMwareFix folder
cd C:\VMwareFix

# Run persistent enforcement script
.\Persistent_Enforcement.ps1

# Or re-run main script
.\Final_VBS_Disabler_Professional_v2.ps1
```

---

## FILES CREATED BY SCRIPT

Location: `C:\VMwareFix\`

| File | Purpose |
|------|---------|
| `VBS_Disabler_YYYYMMDD_HHMMSS.log` | Full execution log |
| `dgreadiness_v3.6.zip` | Downloaded Microsoft tool |
| `DGReadiness\` | Extracted tool folder |
| `Verify_On_Next_Boot.ps1` | Auto-verification script |
| `Verification_YYYYMMDD_HHMMSS.log` | Verification results |
| `Persistent_Enforcement.ps1` | Optional startup task |
| `persistent-enforcement.log` | Enforcement execution log |

---

## EXPECTED SUCCESS INDICATORS

### In PowerShell:
```
PS> systeminfo | findstr /i "hyper"
Hyper-V Requirements:      VM Monitor Mode Extensions: Yes
                          Virtualization Enabled In Firmware: Yes

(NO "A hypervisor has been detected" line!)
```

### In Verification Window:
```
===============================================================================
                 SUCCESS! VBS/HYPERVISOR DISABLED!
===============================================================================
```

### In VMware Workstation:
```
Bottom-right corner shows: "CPL0"
(Not "ULM")
```

---

## ROLLBACK (IF NEEDED)

### Option 1: System Restore
```
1. Win + R -> rstrui
2. Choose restore point: "Before VBS Disabler"
3. Complete restoration
```

### Option 2: Re-enable Manually
```powershell
# Re-enable VBS
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 1 -Force

# Re-enable hypervisor
bcdedit /set hypervisorlaunchtype auto

# Turn on Memory Integrity
# Windows Security -> Device security -> Core isolation -> ON

# Restart
Restart-Computer
```

### Option 3: Remove Scheduled Tasks
```powershell
Unregister-ScheduledTask -TaskName "VBS_Verifier_NextBoot" -Confirm:$false
Unregister-ScheduledTask -TaskName "VBS_Persistent_Enforcer" -Confirm:$false
```

---

## KEY REGISTRY PATHS (FOR REFERENCE)

```
Critical Keys:
  HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard
    - EnableVirtualizationBasedSecurity = 0

  HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello
    - Enabled = 0  (THE CRITICAL ONE!)

  HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity
    - Enabled = 0

  HKLM:\SYSTEM\CurrentControlSet\Control\Lsa
    - LsaCfgFlags = 0
```

---

## SCRIPT FEATURES

### Safety Features:
- [x] Auto-elevation to Administrator
- [x] Execution policy auto-bypass
- [x] System Restore point creation
- [x] Comprehensive logging
- [x] Safe methods only (no system crashes)
- [x] User confirmation at critical steps

### User-Friendly Features:
- [x] Color-coded output
- [x] Progress indicators
- [x] Clear instructions for GUI tasks
- [x] Auto-opens Windows Security
- [x] Waits for user confirmation
- [x] Detailed error messages
- [x] Professional formatting

### Reliability Features:
- [x] Windows Hello VBS fix (24H2/25H2 critical!)
- [x] Auto-verification on next boot
- [x] Optional persistent enforcement
- [x] Comprehensive test suite
- [x] Multiple fallback methods

---

## SUPPORT RESOURCES

### Log Files:
- Main log: `C:\VMwareFix\VBS_Disabler_*.log`
- Verification: `C:\VMwareFix\Verification_*.log`

### Manual Verification:
```powershell
# Run verification script manually
C:\VMwareFix\Verify_On_Next_Boot.ps1
```

### Check Scheduled Tasks:
```powershell
Get-ScheduledTask | Where-Object {$_.TaskName -like "*VBS*"}
```

---

## TIMELINE

| Time | Step |
|------|------|
| 0:00 | Script starts, creates restore point |
| 0:02 | Guides through Tamper Protection disable |
| 0:03 | Guides through Memory Integrity disable |
| 0:05 | Downloads and runs DG Readiness Tool |
| 0:08 | Applies all registry/BCD changes |
| 0:10 | Computer restarts |
| 0:12 | Reset Windows Hello PIN |
| 0:13 | Verification completes (all tests pass) |
| 0:15 | Launch VMware, check CPL0 mode |

**TOTAL: ~15 minutes**

---

## SUCCESS CHECKLIST

- [ ] Script ran without errors
- [ ] System Restore point created
- [ ] Tamper Protection disabled
- [ ] Memory Integrity disabled
- [ ] DG Tool ran (pressed F3)
- [ ] Computer restarted
- [ ] Windows Hello PIN reset
- [ ] Verification showed all [PASS]
- [ ] `systeminfo` shows NO hypervisor
- [ ] VMware shows "CPL0" mode
- [ ] VMs start and run successfully

---

## QUICK COMMAND REFERENCE

```powershell
# Run script
.\Final_VBS_Disabler_Professional_v2.ps1

# Check status
systeminfo | findstr /i "hyper"

# View logs
notepad C:\VMwareFix\VBS_Disabler_*.log

# Manual verification
C:\VMwareFix\Verify_On_Next_Boot.ps1

# Remove tasks
Unregister-ScheduledTask -TaskName "VBS_Verifier_NextBoot" -Confirm:$false
Unregister-ScheduledTask -TaskName "VBS_Persistent_Enforcer" -Confirm:$false
```

---

<p align="center"><strong>Created by <a href="https://github.com/ZACODEC">ZACODEC</a></strong> &bull; <a href="https://github.com/ZACODEC/vbs-disabler">GitHub</a> &bull; Give it a ⭐ if it helped!</p>
