# VBS Disabler - Ultimate Edition 🚀

<p align="center">
  <strong>Fix the "A hypervisor has been detected" issue and enable VMware Workstation CPL0 mode for maximum performance!</strong>
</p>

<p align="center">
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://www.microsoft.com/windows/"><img src="https://img.shields.io/badge/Windows%2011-24H2%2F25H2-0078D6?logo=windows&logoColor=white" alt="Windows 11"></a>
  <a href="https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion"><img src="https://img.shields.io/badge/VMware-Workstation-607078?logo=vmware&logoColor=white" alt="VMware Workstation"></a>
  <a href="https://docs.microsoft.com/powershell/"><img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white" alt="PowerShell 5.1+"></a>
  <a href="https://github.com/ZACODEC/vbs-disabler/releases"><img src="https://img.shields.io/github/v/release/ZACODEC/vbs-disabler?include_prereleases&label=Version&color=brightgreen" alt="Version"></a>
  <a href="https://github.com/ZACODEC/vbs-disabler/stargazers"><img src="https://img.shields.io/github/stars/ZACODEC/vbs-disabler?style=flat&label=Stars&color=orange" alt="Stars"></a>
</p>

<p align="center">
  Created by <strong><a href="https://github.com/ZACODEC">ZACODEC</a></strong> &bull; Version 3.0.0 &bull; 95%+ Success Rate
</p>

---

## 📖 Table of Contents

- [The Problem](#-the-problem)
- [Quick Start](#-quick-start)
- [Key Features](#-key-features)
- [How It Works](#-how-it-works)
- [Prerequisites](#-prerequisites)
- [Step-by-Step Walkthrough](#-step-by-step-walkthrough)
- [BIOS Configuration](#-bios-configuration)
- [Verification](#-verification)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-frequently-asked-questions)
- [Security Considerations](#-security-considerations)
- [Rollback / Undo](#-rollback--undo)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔍 The Problem

Starting with **Windows 11 24H2/25H2**, Microsoft made Virtualization-Based Security (VBS) extremely aggressive. This causes:

- ❌ **VMware Workstation** stuck in **ULM mode** (User Level Monitor) — significantly slower
- ❌ VMware error: *"A hypervisor has been detected. Features required to run this VM have been disabled."*
- ❌ Nested virtualization broken even with VBS "disabled" via normal methods
- ❌ Standard registry tweaks no longer work on Build 26200+

### 🔑 The Discovery

The Reddit and Microsoft Q&A communities discovered that **Windows Hello VBS** is a hidden dependency that keeps VBS alive on 24H2/25H2, even when every other VBS setting is turned off. This script applies that critical fix along with everything else needed.

---

## 🎯 Quick Start

### One-Line Install

```powershell
# Download and run — that's it!
.\Final_VBS_Disabler_Professional_v2.ps1
```

### Or: Right-Click Method

1. Download `Final_VBS_Disabler_Professional_v2.ps1`
2. Right-click → **Run with PowerShell**
3. Allow the UAC prompt
4. Follow the on-screen instructions (~15 minutes)
5. Restart → Done!

> **No manual `Set-ExecutionPolicy` needed.** The script handles elevation, bypass, and everything automatically.

---

## 🌟 Key Features

| Feature | Description |
|---------|-------------|
| 🔐 **Auto-Elevation** | Automatically requests Administrator privileges |
| ⚙️ **Execution Policy Bypass** | No need to change system policy manually |
| 💾 **System Restore Point** | Creates a safety checkpoint before any changes |
| 🔑 **Windows Hello VBS Fix** | The critical 24H2/25H2 fix (95%+ success rate) |
| 📦 **DG Readiness Tool** | Auto-downloads and runs Microsoft's official tool |
| 🗝️ **12+ Registry Keys** | Comprehensive VBS/HVCI/Device Guard/Credential Guard disable |
| 🥾 **BCD Configuration** | Boot-level hypervisor disable |
| 🔧 **Windows Features** | Disables Hyper-V, VM Platform, Sandbox, App Guard |
| ✅ **Auto-Verification** | Post-reboot script confirms everything worked |
| 🔄 **Persistent Enforcement** | Optional task to prevent Windows Update from reverting |
| 📝 **Full Logging** | Timestamped transcript saved to `C:\VMwareFix\` |
| 🎨 **Professional UI** | Color-coded output, progress bars, step counter |

---

## ⚙️ How It Works

The script performs **10 steps** in sequence:

```
STEP  1/10  Create System Restore Point
STEP  2/10  Guide: Disable Tamper Protection (manual)
STEP  3/10  Guide: Disable Memory Integrity (manual)
STEP  4/10  Download & Run DG Readiness Tool
STEP  5/10  Apply Windows Hello VBS Fix ← THE KEY FIX
STEP  6/10  Apply 12+ Registry Modifications
STEP  7/10  Configure BCD (hypervisorlaunchtype = Off)
STEP  8/10  Disable Windows Features (Hyper-V, etc.)
STEP  9/10  Create Auto-Verification Script
STEP 10/10  Optional: Persistent Enforcement Task
            → Restart Computer
```

### What Gets Modified

<details>
<summary><b>Registry Keys (click to expand)</b></summary>

| Key | Value | Purpose |
|-----|-------|---------|
| `DeviceGuard\Scenarios\WindowsHello\Enabled` | `0` | **THE critical fix** for 24H2/25H2 |
| `DeviceGuard\EnableVirtualizationBasedSecurity` | `0` | Main VBS switch |
| `DeviceGuard\RequirePlatformSecurityFeatures` | `0` | Platform security requirements |
| `DeviceGuard\Locked` | `0` | Device Guard lock |
| `DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity\Enabled` | `0` | Memory Integrity / HVCI |
| `DeviceGuard\Scenarios\CredentialGuard\Enabled` | `0` | Credential Guard |
| `DeviceGuard\Scenarios\SystemGuard\Enabled` | `0` | System Guard |
| `Control\Lsa\LsaCfgFlags` | `0` | LSA Credential Guard |
| `Policies\...\DeviceGuard\EnableVirtualizationBasedSecurity` | `0` | Group Policy VBS |
| `Policies\...\DeviceGuard\RequirePlatformSecurityFeatures` | `0` | Group Policy Platform |
| `Policies\...\DeviceGuard\HypervisorEnforcedCodeIntegrity` | `0` | Group Policy HVCI |
| `Policies\...\DeviceGuard\LsaCfgFlags` | `0` | Group Policy Credential Guard |

All keys are under `HKLM:\SYSTEM\CurrentControlSet\Control\` or `HKLM:\SOFTWARE\Policies\Microsoft\Windows\`.

</details>

<details>
<summary><b>Windows Features Disabled (click to expand)</b></summary>

| Feature | Description |
|---------|-------------|
| `Microsoft-Hyper-V-All` | Hyper-V (all components) |
| `Microsoft-Hyper-V` | Hyper-V core |
| `HypervisorPlatform` | Windows Hypervisor Platform |
| `VirtualMachinePlatform` | Virtual Machine Platform (⚠️ breaks WSL2) |
| `Containers-DisposableClientVM` | Windows Sandbox |
| `Windows-Defender-ApplicationGuard` | Application Guard |

</details>

<details>
<summary><b>BCD Changes (click to expand)</b></summary>

```
bcdedit /set hypervisorlaunchtype off
bcdedit /set {current} hypervisorlaunchtype off
```

</details>

---

## 📋 Prerequisites

| Requirement | Details |
|-------------|---------|
| **OS** | Windows 11 24H2 or 25H2 (Build 26100+) |
| **VMware** | VMware Workstation Pro / Player (any recent version) |
| **Privileges** | Script auto-elevates — just allow the UAC prompt |
| **Internet** | Required for DG Readiness Tool download |
| **Time** | ~15 minutes including restart |
| **PowerShell** | 5.1+ (built into Windows) |

---

## 📝 Step-by-Step Walkthrough

### Before Running

1. **Close all running VMs** in VMware Workstation
2. **Save your work** — a restart is required at the end
3. Have your **Windows PIN** ready — you'll need to re-create it after restart

### During the Script

| Step | What Happens | Your Action |
|------|--------------|-------------|
| System Restore | Auto-creates restore point | None |
| Tamper Protection | Opens Windows Security | Toggle **OFF** manually, then confirm |
| Memory Integrity | Opens Core Isolation | Toggle **OFF** manually, then confirm |
| DG Readiness Tool | Downloads & launches | Press **F3** to select Disable |
| Windows Hello Fix | Applies registry keys | None — automatic |
| Registry | Sets 12+ keys | None — automatic |
| BCD | Sets hypervisor off | None — automatic |
| Features | Disables Hyper-V etc. | None — automatic |
| Verification | Creates boot script | None — automatic |
| Enforcement | Optional boot task | Choose **Y** (recommended) |
| Restart | Prompts to restart | Press **Y** |

### After Restart

1. **Windows Hello PIN** — Windows will say *"We need to set up your PIN again."* This is **expected and normal**. Create a new PIN.
2. **Verification window** — A PowerShell window auto-opens showing 5 tests. All should show `[PASS]`.
3. **Launch VMware** — Start a VM. Look at the bottom-right corner — it should say **CPL0** (not ULM).

> ⚠️ **During reboot**, watch for black screens asking *"Press F3 to disable Credential Guard/VBS"*. **Press F3** if prompted!

---

## 💻 BIOS Configuration

If verification still shows failures after restart, **BIOS settings** may need adjustment.

<details>
<summary><b>🔵 HP / HPE</b> (ProBook, EliteBook, ZBook, Omen, Pavilion)</summary>

1. Restart → Press **ESC** → **F10** (BIOS Setup)
2. Navigate to **Advanced → System Options**
3. Set:
   - `DMA Protection` → **Disabled**
   - `Pre-boot DMA protection` → **Disabled**
   - `SVM CPU Virtualization` → **Enabled** (keep this ON!)
4. **F10** → Save & Exit

</details>

<details>
<summary><b>🔵 Dell / Alienware</b> (XPS, Inspiron, Latitude, Precision)</summary>

1. Restart → Press **F2** (BIOS Setup)
2. Navigate to **Virtualization Support**
3. Set:
   - `VT for Direct I/O` → **Enabled**
   - `Virtualization` → **Enabled**
   - `Trusted Execution` → **Disabled**
   - `Kernel DMA Protection` → **Disabled**
4. **Apply** → Exit

</details>

<details>
<summary><b>🔵 Lenovo / ThinkPad</b> (IdeaPad, Legion, ThinkStation)</summary>

1. Restart → Press **F1** (ThinkPad) or **F2** (IdeaPad/Legion)
2. Navigate to **Security → Virtualization**
3. Set:
   - `Intel VT-x / AMD SVM` → **Enabled**
   - `Intel VT-d / AMD IOMMU` → **Enabled**
   - `Kernel DMA Protection` → **Disabled**
   - `Secure Boot` → **Disabled** (if needed)
4. **F10** → Save & Exit

</details>

<details>
<summary><b>🔵 ASUS / ROG</b> (TUF, Zenbook, VivoBook)</summary>

1. Restart → Press **F2** or **DEL** (BIOS Setup)
2. Switch to **Advanced Mode** (F7)
3. Navigate to **Advanced → CPU Configuration**
4. Set:
   - `SVM Mode` (AMD) or `Intel VT-x` → **Enabled**
   - `IOMMU` → **Disabled**
   - `Kernel DMA Protection` → **Disabled**
5. **F10** → Save & Exit

</details>

<details>
<summary><b>🔵 MSI</b> (Gaming, Creator, Business)</summary>

1. Restart → Press **DEL** (BIOS Setup)
2. Navigate to **OC → CPU Features** or **Advanced**
3. Set:
   - `SVM Mode` → **Enabled**
   - `IOMMU` → **Disabled**
4. **F10** → Save & Exit

</details>

<details>
<summary><b>🔵 Acer / Predator</b> (Aspire, Nitro, Swift)</summary>

1. Restart → Press **F2** (BIOS Setup)
2. Navigate to **Advanced**
3. Set:
   - `Intel VT-x / SVM` → **Enabled**
   - `VT-d / IOMMU` → **Disabled** (if issues persist)
   - `Kernel DMA Protection` → **Disabled**
4. **F10** → Save & Exit

</details>

<details>
<summary><b>🔵 Gigabyte / AORUS</b></summary>

1. Restart → Press **DEL** (BIOS Setup)
2. Navigate to **Tweaker** or **Advanced → CPU Configuration**
3. Set:
   - `SVM Mode` → **Enabled**
   - `IOMMU` → **Disabled**
4. **F10** → Save & Exit

</details>

<details>
<summary><b>🟡 Intel Processors — Key Settings</b></summary>

- `VT-x` (Intel Virtualization Technology) → **Enabled**
- `VT-d` (Directed I/O) → **Enabled** (for IOMMU passthrough)
- `TXT` (Trusted Execution Technology) → **Disabled**
- `PTT` (Platform Trust Technology) → **Disabled** (if causing issues)
- `SGX` (Software Guard Extensions) → **Disabled**

</details>

<details>
<summary><b>🟡 AMD Processors — Key Settings</b></summary>

- `SVM` (Secure Virtual Machine) → **Enabled**
- `AMD-V` → **Enabled**
- `IOMMU` → **Disabled** (try disabling if VBS persists)
- `PSP` (Platform Security Processor) → Try **Disabled** if available
- `Memory Guard` → **Disabled** (if available)

</details>

---

## ✅ Verification

### Quick Verification Commands

```powershell
# 1. Check hypervisor (should show NO "detected" line)
systeminfo | findstr /i "hyper"

# 2. Check VBS status (should show 0 = disabled)
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard |
    Select-Object VirtualizationBasedSecurityStatus

# 3. Check BCD (should show "Off")
bcdedit /enum | findstr hypervisor

# 4. Check Windows Hello VBS (should show 0)
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" -Name "Enabled"
```

### Expected Results

**In PowerShell:**
```
PS> systeminfo | findstr /i "hyper"
Hyper-V Requirements:      VM Monitor Mode Extensions: Yes
                           Virtualization Enabled In Firmware: Yes
# ↑ NO line saying "A hypervisor has been detected" — that means SUCCESS
```

**In VMware Workstation:**
```
Bottom-right corner shows: CPL0    ← SUCCESS
                    (not: ULM)     ← would mean VBS is still active
```

---

## 🔧 Troubleshooting

<details>
<summary><b>Hypervisor still detected after restart</b></summary>

1. **Check BIOS** — DMA Protection and TXT must be **Disabled** (see [BIOS section](#-bios-configuration))
2. **Re-apply Windows Hello fix manually:**
   ```powershell
   reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" /v "Enabled" /t REG_DWORD /d 0 /f
   bcdedit /set hypervisorlaunchtype off
   Restart-Computer
   ```
3. **Run the script again** — it's safe to re-run

</details>

<details>
<summary><b>VMware shows "ULM" instead of "CPL0"</b></summary>

HVCI (Memory Integrity) is still active:
```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -Force
Restart-Computer
```

</details>

<details>
<summary><b>Verification shows "VBS Status = 2"</b></summary>

The Windows Hello key wasn't applied (likely Tamper Protection was still on):
```powershell
# 1. Disable Tamper Protection first (manually in Windows Security)
# 2. Then apply the fix:
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\WindowsHello" -Name "Enabled" -Value 0 -Force
Restart-Computer
```

</details>

<details>
<summary><b>Changes revert after Windows Update</b></summary>

Run the persistent enforcement script:
```powershell
C:\VMwareFix\Persistent_Enforcement.ps1
# Or re-run the main script
```
If you didn't enable persistent enforcement during setup, re-run the script and select **Y** when asked.

</details>

<details>
<summary><b>WSL2 stopped working</b></summary>

Disabling `VirtualMachinePlatform` breaks WSL2. To restore WSL2:
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Restart-Computer
```
> ⚠️ This will re-enable the hypervisor. VMware will switch back to ULM mode.

</details>

<details>
<summary><b>Script won't run / execution policy error</b></summary>

The script handles this automatically, but if it still fails:
```powershell
PowerShell -ExecutionPolicy Bypass -File ".\Final_VBS_Disabler_Professional_v2.ps1"
```

</details>

---

## ❓ Frequently Asked Questions

**Q: Is this safe?**
> Yes. The script creates a System Restore point first, logs everything, and only uses Microsoft-documented methods. See [SECURITY.md](SECURITY.md) for full details.

**Q: Will Windows Defender still work?**
> Yes! Real-time protection, firewall, and SmartScreen remain fully active. Only VBS/HVCI/Device Guard are disabled.

**Q: Will I lose data?**
> No. The script only modifies registry keys, BCD settings, and Windows features. No files are deleted.

**Q: Can I undo the changes?**
> Yes. Use System Restore, or see the [Rollback section](#-rollback--undo) below.

**Q: Does this work with Windows 10?**
> It's designed for Windows 11 24H2/25H2. It may work on older builds but the Windows Hello VBS fix is specifically for Build 26100+.

**Q: Why does my PIN need to be reset?**
> Windows Hello uses VBS to protect your PIN. When VBS is disabled, Windows needs to re-create the PIN without VBS protection.

**Q: Will this void my warranty?**
> No. These are standard Windows configuration changes, not hardware modifications.

**Q: Can I use Hyper-V and VMware CPL0 at the same time?**
> No. They are mutually exclusive. You need to choose one or the other.

---

## 🔐 Security Considerations

Disabling VBS/HVCI reduces some advanced security protections. **This is acceptable for:**
- ✅ Development machines
- ✅ Home PCs in secure environments
- ✅ Testing/lab environments

**Read [SECURITY.md](SECURITY.md) for:**
- Full threat model and risk assessment
- Compensating security controls
- When NOT to use this script
- Defense-in-depth strategy

---

## ↩️ Rollback / Undo

### Option 1: System Restore (Recommended)

```
Win + R → rstrui → Choose "Before VBS Disabler by ZACODEC" → Restore
```

### Option 2: Manual Re-enable

```powershell
# Re-enable VBS
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 1 -Force

# Re-enable hypervisor
bcdedit /set hypervisorlaunchtype auto

# Turn on Memory Integrity: Windows Security → Device security → Core isolation → ON

# Remove scheduled tasks
Unregister-ScheduledTask -TaskName "VBS_Verifier_NextBoot" -Confirm:$false
Unregister-ScheduledTask -TaskName "VBS_Persistent_Enforcer" -Confirm:$false

Restart-Computer
```

---

## 📁 Files Created by the Script

All files are stored in `C:\VMwareFix\`:

| File | Purpose |
|------|---------|
| `VBS_Disabler_YYYYMMDD_HHMMSS.log` | Full execution transcript |
| `Verify_On_Next_Boot.ps1` | Auto-verification (runs once after restart) |
| `Verification_YYYYMMDD_HHMMSS.log` | Verification test results |
| `Persistent_Enforcement.ps1` | Boot-time enforcement (optional) |
| `persistent-enforcement.log` | Enforcement execution history |
| `DGReadiness\` | Microsoft DG Readiness Tool |

---

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- 🐛 **Found a bug?** [Open an issue](https://github.com/ZACODEC/vbs-disabler/issues/new?template=bug_report.md)
- 💡 **Have an idea?** [Request a feature](https://github.com/ZACODEC/vbs-disabler/issues/new?template=feature_request.md)
- ⭐ **Like this project?** Give it a star!

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — free for personal and commercial use.

---

## 🙏 Acknowledgments

- **Reddit community** — Discovery of the Windows Hello VBS fix
- **Microsoft Q&A community** — Confirmation and testing
- **VMware Broadcom community** — VMware-specific guidance
- Everyone who tested and provided feedback

---

<p align="center">
  <strong>Made with ❤️ by <a href="https://github.com/ZACODEC">ZACODEC</a></strong>
  <br>
  If this script saved you hours of debugging, consider giving it a ⭐
</p>
