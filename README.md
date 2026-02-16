<div align="center">

# ⚡ VBS Disabler — Ultimate Edition v3.0

### Disable VBS on Windows 11 24H2/25H2 & unleash VMware Workstation CPL0 mode

<br>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Windows 11](https://img.shields.io/badge/Windows%2011-24H2%2F25H2-0078D6?style=for-the-badge&logo=windows11&logoColor=white)](https://www.microsoft.com/windows/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/powershell/)
[![VMware](https://img.shields.io/badge/VMware-Workstation-607078?style=for-the-badge&logo=vmware&logoColor=white)](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)

[![GitHub Stars](https://img.shields.io/github/stars/zainmustafam977/vbs-disabler-windows11?style=for-the-badge&label=Stars&color=orange)](https://github.com/zainmustafam977/vbs-disabler-windows11/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/zainmustafam977/vbs-disabler-windows11?style=for-the-badge&label=Forks&color=blue)](https://github.com/zainmustafam977/vbs-disabler-windows11/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/zainmustafam977/vbs-disabler-windows11?style=for-the-badge&label=Issues&color=red)](https://github.com/zainmustafam977/vbs-disabler-windows11/issues)

<br>

**95%+ Success Rate** · Created by [**ZACODEC**](https://github.com/zainmustafam977)

<br>

<img src="https://user-images.githubusercontent.com/placeholder/demo-screenshot.gif" alt="Demo" width="700">

<sub><i>One command. Full speed VMware. No hypervisor conflicts.</i></sub>

</div>

<br>

---

<br>

## 📖 Table of Contents

<details open>
<summary><b>Click to navigate</b></summary>

- [The Problem](#-the-problem)
- [Quick Start (One-Liner)](#-quick-start)
- [Installation Methods](#-installation-methods)
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
- [Files Created](#-files-created-by-the-script)
- [Contributing](#-contributing)
- [License](#-license)

</details>

<br>

---

## 🔍 The Problem

Starting with **Windows 11 24H2/25H2**, Microsoft made Virtualization-Based Security (VBS) extremely aggressive:

| Symptom | Impact |
|---------|--------|
| 🔴 VMware stuck in **ULM mode** | ~40% slower VM performance |
| 🔴 *"A hypervisor has been detected"* | VMs refuse to start or run crippled |
| 🔴 Standard VBS disable methods fail | Registry tweaks ignored on Build 26200+ |
| 🔴 Even "disabled" VBS stays alive | Hidden Windows Hello dependency |

### 🔑 The Discovery

> The Reddit and Microsoft Q&A communities discovered that **Windows Hello VBS** is a hidden dependency that keeps VBS alive on 24H2/25H2, even when every other VBS setting is turned off.

This script applies that **critical fix** along with everything else needed.

<br>

---

## 🚀 Quick Start

> **Open PowerShell and paste one of these commands. That's it.**

### ⚡ Method 1 — Short URL (Recommended)

```powershell
irm https://bit.ly/vbs-fix | iex
```

### 🔗 Method 2 — Direct GitHub URL

```powershell
irm https://raw.githubusercontent.com/zainmustafam977/vbs-disabler-windows11/main/VBS_Disable.ps1 | iex
```

### 🛡️ Method 3 — Full Command (if `irm` is restricted)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/zainmustafam977/vbs-disabler-windows11/main/VBS_Disable.ps1'))
```

<details>
<summary><b>🔗 Same as above but with the short URL</b></summary>

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/vbs-fix'))
```

</details>

<br>

> [!TIP]
> **Not running as Admin?** No problem — the script auto-elevates itself. Just allow the UAC prompt when it appears.

> [!NOTE]
> The short URL `https://bit.ly/vbs-fix` redirects to the raw GitHub script. You can verify by opening it in a browser first.

<br>

---

## 📥 Installation Methods

<table>
<tr>
<th>Method</th>
<th>Command / Steps</th>
<th>Best For</th>
</tr>
<tr>
<td><b>⚡ One-Liner</b></td>
<td>

```powershell
irm https://bit.ly/vbs-fix | iex
```

</td>
<td>Fastest — just paste & go</td>
</tr>
<tr>
<td><b>📥 Download & Run</b></td>
<td>

1. Download [`VBS_Disable.ps1`](https://github.com/zainmustafam977/vbs-disabler-windows11/raw/main/VBS_Disable.ps1)
2. Right-click → **Run with PowerShell**
3. Allow UAC prompt

</td>
<td>Offline use or if you want to review the script first</td>
</tr>
<tr>
<td><b>🖥️ Manual PowerShell</b></td>
<td>

```powershell
PowerShell -ExecutionPolicy Bypass -File ".\VBS_Disable.ps1"
```

</td>
<td>If right-click doesn't work</td>
</tr>
<tr>
<td><b>🔒 Restricted Environment</b></td>
<td>

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/zainmustafam977/vbs-disabler-windows11/main/VBS_Disable.ps1'))
```

</td>
<td>Corporate/locked-down machines</td>
</tr>
</table>

<br>

---

## 🌟 Key Features

| Feature | Description |
|:-------:|-------------|
| 🔐 | **Auto-Elevation** — Automatically requests Administrator privileges |
| ⚙️ | **Execution Policy Bypass** — No manual policy changes needed |
| 💾 | **System Restore Point** — Creates a safety checkpoint before any changes |
| 🔑 | **Windows Hello VBS Fix** — The critical 24H2/25H2 fix (95%+ success rate) |
| 📦 | **DG Readiness Tool** — Auto-downloads and runs Microsoft's official tool |
| 🗝️ | **12+ Registry Keys** — Comprehensive VBS/HVCI/Device Guard/Credential Guard disable |
| 🥾 | **BCD Configuration** — Boot-level hypervisor disable |
| 🔧 | **Windows Features** — Disables Hyper-V, VM Platform, Sandbox, App Guard |
| ✅ | **Auto-Verification** — Post-reboot script confirms everything worked |
| 🔄 | **Persistent Enforcement** — Optional task to prevent Windows Update from reverting |
| 📝 | **Full Logging** — Timestamped transcript saved to `C:\VMwareFix\` |
| 🎨 | **Professional UI** — Color-coded output, progress bars, step counter |

<br>

---

## ⚙️ How It Works

The script performs **10 steps** in sequence:

```
 STEP  1/10  ▸ Create System Restore Point
 STEP  2/10  ▸ Guide: Disable Tamper Protection (manual)
 STEP  3/10  ▸ Guide: Disable Memory Integrity (manual)
 STEP  4/10  ▸ Download & Run DG Readiness Tool
 STEP  5/10  ▸ Apply Windows Hello VBS Fix    ← THE KEY FIX
 STEP  6/10  ▸ Apply 12+ Registry Modifications
 STEP  7/10  ▸ Configure BCD (hypervisorlaunchtype = Off)
 STEP  8/10  ▸ Disable Windows Features (Hyper-V, etc.)
 STEP  9/10  ▸ Create Auto-Verification Script
 STEP 10/10  ▸ Optional: Persistent Enforcement Task
              → Restart Computer
```

<details>
<summary><b>📋 Registry Keys Modified (click to expand)</b></summary>

| Key | Value | Purpose |
|-----|:-----:|---------|
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
<summary><b>🔧 Windows Features Disabled (click to expand)</b></summary>

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
<summary><b>🥾 BCD Changes (click to expand)</b></summary>

```
bcdedit /set hypervisorlaunchtype off
bcdedit /set {current} hypervisorlaunchtype off
```

</details>

<br>

---

## 📋 Prerequisites

| Requirement | Details |
|:-----------:|---------|
| 🖥️ **OS** | Windows 11 24H2 or 25H2 (Build 26100+) |
| 📦 **VMware** | VMware Workstation Pro / Player (any recent version) |
| 🔑 **Privileges** | Script auto-elevates — just allow the UAC prompt |
| 🌐 **Internet** | Required for DG Readiness Tool download |
| ⏱️ **Time** | ~15 minutes including restart |
| 💻 **PowerShell** | 5.1+ (built into Windows) |

<br>

---

## 📝 Step-by-Step Walkthrough

### Before Running

1. **Close all running VMs** in VMware Workstation
2. **Save your work** — a restart is required at the end
3. Have your **Windows PIN** ready — you'll need to re-create it after restart

### During the Script

| Step | What Happens | Your Action |
|:----:|--------------|:-----------:|
| 1 | System Restore point created | None |
| 2 | Opens Windows Security | Toggle Tamper Protection **OFF** |
| 3 | Opens Core Isolation | Toggle Memory Integrity **OFF** |
| 4 | Downloads & launches DG Tool | Press **F3** to select Disable |
| 5 | Windows Hello VBS fix | None — automatic |
| 6 | Sets 12+ registry keys | None — automatic |
| 7 | BCD hypervisor off | None — automatic |
| 8 | Disables Hyper-V etc. | None — automatic |
| 9 | Creates verification script | None — automatic |
| 10 | Optional boot task | Choose **Y** (recommended) |
| 🔄 | Restart prompt | Press **Y** |

### After Restart

1. **Windows Hello PIN** — Windows will say *"We need to set up your PIN again."* This is **expected and normal**. Create a new PIN.
2. **Verification window** — A PowerShell window auto-opens showing 5 tests. All should show `[PASS]`.
3. **Launch VMware** — Start a VM. Look at the bottom-right corner — it should say **CPL0** (not ULM).

> [!CAUTION]
> **During reboot**, watch for black screens asking *"Press F3 to disable Credential Guard/VBS"*. **Press F3** if prompted!

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
PowerShell -ExecutionPolicy Bypass -File ".\VBS_Disable.ps1"
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

- 🐛 **Found a bug?** [Open an issue](https://github.com/zainmustafam977/vbs-disabler-windows11/issues/new?template=bug_report.md)
- 💡 **Have an idea?** [Request a feature](https://github.com/zainmustafam977/vbs-disabler-windows11/issues/new?template=feature_request.md)
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

<div align="center">

<br>

**If this script saved you hours of debugging, please give it a ⭐**

<br>

[![Star This Repo](https://img.shields.io/badge/⭐_Star_This_Repo-yellow?style=for-the-badge)](https://github.com/zainmustafam977/vbs-disabler-windows11)

<br>

Made with ❤️ by [**ZACODEC**](https://github.com/zainmustafam977)

<sub>© 2025-2026 ZACODEC. All rights reserved.</sub>

</div>
