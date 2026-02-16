---
name: Bug Report
about: Report a problem with the VBS Disabler script
title: "[BUG] "
labels: bug
assignees: ZACODEC
---

## Describe the Bug

A clear description of what went wrong.

## System Information

- **Windows Version:** (e.g., Windows 11 25H2)
- **Build Number:** (run `winver`)
- **PC Manufacturer / Model:** (e.g., HP ProBook 450 G9)
- **Processor:** (e.g., Intel i7-1265U / AMD Ryzen 7 7840HS)
- **VMware Version:** (e.g., Workstation 17.6.2 Pro)
- **Script Version:** (e.g., 3.0)

## Steps to Reproduce

1. ...
2. ...
3. ...

## Expected Behavior

What should have happened.

## Actual Behavior

What actually happened.

## Verification Results

Paste the output of the verification script or these commands:

```powershell
systeminfo | findstr /i "hyper"
bcdedit /enum | findstr hypervisor
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select VirtualizationBasedSecurityStatus
```

## Log Files

Attach or paste relevant sections from:
- `C:\VMwareFix\VBS_Disabler_*.log`
- `C:\VMwareFix\Verification_*.log`

## Additional Context

Any other information (screenshots, BIOS settings, etc.)
