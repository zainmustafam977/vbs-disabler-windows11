# Security Policy

> **Version 2.0** &bull; Last Updated: February 2026 &bull; Applies to VBS Disabler v3.0+

## 🔐 Security Implications

This script **intentionally disables** Windows security features to enable VMware Workstation CPL0 mode. Please understand the security implications before running this script.

---

## ⚠️ What This Script Disables

### Primary Security Features:
1. **Virtualization-Based Security (VBS)**
   - Purpose: Isolates critical Windows processes
   - Impact: Medium security reduction

2. **Hypervisor-Protected Code Integrity (HVCI / Memory Integrity)**
   - Purpose: Prevents malicious code from running
   - Impact: Medium security reduction

3. **Device Guard**
   - Purpose: Restricts code execution to trusted sources
   - Impact: Low to medium security reduction

4. **Credential Guard**
   - Purpose: Protects credentials from theft
   - Impact: Low security reduction (requires physical access)

5. **DMA Protection** (BIOS setting)
   - Purpose: Prevents DMA attacks via external ports
   - Impact: Low security reduction (requires physical access)

---

## 🎯 Threat Model

### What You're Protected Against (WITH these features enabled):
- ✅ Memory-based malware attacks
- ✅ Kernel-level exploits
- ✅ DMA attacks (via Thunderbolt/USB-C)
- ✅ Credential theft attacks
- ✅ Some zero-day exploits

### What You're Protected Against (WITHOUT these features):
- ✅ Standard malware (Windows Defender still active)
- ✅ Network attacks (Firewall still active)
- ✅ Phishing attacks (SmartScreen still active)
- ✅ Most common threats

### What You're MORE Vulnerable To (with features disabled):
- ⚠️ Advanced persistent threats (APTs)
- ⚠️ Kernel-level malware
- ⚠️ Physical DMA attacks (requires physical access + specialized hardware)
- ⚠️ Memory-based exploits
- ⚠️ Some sophisticated attacks

---

## 📊 Risk Assessment

### Risk Level: **MEDIUM**

| Factor | Risk Level | Notes |
|--------|-----------|-------|
| **Home users in secure environments** | LOW | Physical security is good, low exposure |
| **Laptops in public places** | MEDIUM | Higher exposure to physical attacks |
| **Corporate/managed devices** | HIGH | May violate security policies |
| **High-value targets** | HIGH | APTs and sophisticated attacks more likely |
| **Development/testing machines** | LOW | Acceptable trade-off for functionality |

---

## 🛡️ Compensating Security Controls

### Essential (Implement These):

1. **Strong Passwords**
   - Minimum 15 characters
   - Mix of upper/lower/numbers/symbols
   - Unique (not used elsewhere)
   - Use a password manager

2. **BitLocker Encryption**
   - Encrypt C: drive at minimum
   - Use strong recovery key
   - Store recovery key securely
   ```powershell
   # Enable BitLocker
   Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly
   ```

3. **Physical Security**
   - Lock laptop when away (Win + L)
   - Don't leave unattended in public
   - Use cable lock in public spaces
   - Store in secure location

4. **Windows Defender**
   - Keep real-time protection ON
   - Enable cloud-delivered protection
   - Enable automatic sample submission
   - Keep definitions updated

5. **Windows Firewall**
   - Keep enabled
   - Use default settings minimum
   - Consider custom rules for extra protection

### Recommended (Additional Protection):

6. **BIOS/UEFI Password**
   - Set supervisor password in BIOS
   - Prevents unauthorized BIOS changes
   - Adds boot-time protection

7. **Windows Update**
   - Keep Windows fully updated
   - Enable automatic updates
   - Install security patches promptly

8. **Multi-Factor Authentication (MFA)**
   - Enable on all accounts
   - Use authenticator app
   - Backup codes stored securely

9. **Regular Backups**
   - 3-2-1 backup strategy
   - Cloud backup (OneDrive, Google Drive)
   - External drive backup
   - Test restores periodically

10. **Limited User Accounts**
    - Don't use admin account daily
    - Use standard user for daily tasks
    - Elevate only when needed

---

## 🚨 When NOT to Use This Script

### Do NOT use if:
- ❌ You work for government/defense/intelligence
- ❌ You handle classified information
- ❌ You're a high-value target (executive, celebrity, politician)
- ❌ Your company has strict security policies
- ❌ You frequently work in hostile/public environments
- ❌ You handle sensitive customer/client data
- ❌ Your device is managed by corporate IT
- ❌ You're required to maintain compliance (HIPAA, PCI-DSS, etc.)

### Consider alternatives:
1. **Use Hyper-V instead of VMware** (Microsoft's native hypervisor)
2. **Accept ULM mode** (slower but secure)
3. **Use a separate physical machine** for VMs
4. **Dual-boot configuration** (VBS enabled/disabled boot entries)

---

## 🔍 Real-World Attack Scenarios

### Scenario 1: DMA Attack (Physical Access Required)
**What it is:** Attacker plugs malicious device into Thunderbolt/USB-C port

**Requirements:**
- Physical access to your unlocked laptop
- 2-5 minutes unsupervised
- Specialized hardware ($100-500)

**Protection with DMA Protection:** ✅ Blocked
**Protection without DMA Protection:** ❌ Vulnerable
**Compensating control:** Physical security, BitLocker

**Reality:** Extremely rare for home users

---

### Scenario 2: Memory-Based Malware
**What it is:** Malware that operates entirely in RAM

**Requirements:**
- Malware execution (phishing, exploit, etc.)
- Sophisticated attack code

**Protection with HVCI:** ✅ Blocks most attempts
**Protection without HVCI:** ⚠️ Depends on Windows Defender
**Compensating control:** Keep Defender updated, don't click suspicious links

**Reality:** Uncommon, but increasing

---

### Scenario 3: Credential Theft
**What it is:** Stealing Windows login credentials

**Requirements:**
- Physical access OR sophisticated malware

**Protection with Credential Guard:** ✅ Credentials isolated
**Protection without Credential Guard:** ⚠️ Standard protection
**Compensating control:** Strong passwords, MFA, BitLocker

**Reality:** Rare without physical access

---

## 📝 Responsible Use Guidelines

### DO:
- ✅ Use for legitimate development/testing purposes
- ✅ Implement compensating security controls
- ✅ Understand what you're disabling
- ✅ Accept the security trade-off consciously
- ✅ Keep a System Restore point
- ✅ Monitor your system for unusual activity

### DON'T:
- ❌ Use to bypass corporate security policies
- ❌ Use on devices with sensitive data
- ❌ Use without implementing compensating controls
- ❌ Share your password after disabling protections
- ❌ Leave laptop unattended in public
- ❌ Ignore Windows Defender warnings

---

## 🔒 Security Best Practices After Running Script

1. **Monitor System Activity**
   ```powershell
   # Check for unusual processes
   Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

   # Check network connections
   Get-NetTCPConnection | Where-Object {$_.State -eq "Established"}

   # Check startup items
   Get-CimInstance Win32_StartupCommand | Select-Object Name, Command
   ```

2. **Regular Security Audits**
   - Review installed programs monthly
   - Check browser extensions
   - Audit user accounts
   - Review firewall rules

3. **Incident Response Plan**
   - Know how to restore from System Restore
   - Have backup of important files
   - Know how to re-enable VBS if needed
   - Have recovery media ready

4. **Stay Informed**
   - Follow security news
   - Subscribe to Microsoft Security Response Center
   - Join r/sysadmin or r/netsec communities
   - Watch for new vulnerabilities

---

## 🚨 Reporting Security Issues

If you discover a security vulnerability in this script:

### DO NOT:
- ❌ Open a public GitHub issue
- ❌ Discuss publicly on social media
- ❌ Share exploit code publicly

### DO:
1. ✅ Email: [Your security email if you want]
2. ✅ Use GitHub Security Advisory (private disclosure)
3. ✅ Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if you have one)

### Response Timeline:
- **24 hours:** Acknowledgment of report
- **7 days:** Initial assessment
- **30 days:** Fix developed and tested
- **60 days:** Public disclosure (coordinated)

---

## 🛡️ Defense in Depth Strategy

Even with VBS/HVCI disabled, you still have multiple security layers:

### Layer 1: Physical Security
- Laptop locked when away
- Secure storage location
- Cable lock in public

### Layer 2: Authentication
- Strong passwords
- Windows Hello (still works!)
- MFA on online accounts

### Layer 3: Encryption
- BitLocker (full disk encryption)
- Encrypted backups
- HTTPS for websites

### Layer 4: Endpoint Protection
- Windows Defender (still active!)
- Firewall (still active!)
- SmartScreen (still active!)

### Layer 5: Network Security
- VPN for public WiFi
- Router firewall
- DNS filtering

### Layer 6: User Awareness
- Don't click suspicious links
- Verify email senders
- Check website URLs
- Use safe browsing habits

---

## 📚 Additional Resources

### Microsoft Documentation:
- [Virtualization-based Security (VBS)](https://docs.microsoft.com/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control)
- [HVCI (Memory Integrity)](https://docs.microsoft.com/windows/security/threat-protection/device-guard/memory-integrity)
- [Credential Guard](https://docs.microsoft.com/windows/security/identity-protection/credential-guard/credential-guard)

### Security Research:
- [DMA Attacks Research](https://www.usenix.org/conference/woot18/presentation/markettos)
- [Kernel-level Exploits](https://www.microsoft.com/security/blog/)

### Community:
- [r/cybersecurity](https://reddit.com/r/cybersecurity)
- [r/netsec](https://reddit.com/r/netsec)

---

## ⚖️ Legal Disclaimer

**Use of this script is at your own risk.**

The author (ZACODEC) and contributors:
- ❌ Are NOT responsible for security breaches
- ❌ Are NOT responsible for data loss
- ❌ Are NOT responsible for system instability
- ❌ Are NOT responsible for policy violations
- ❌ Do NOT provide warranty of any kind

**This script is provided "AS IS" without warranty.**

By using this script, you acknowledge:
- ✅ You understand the security implications
- ✅ You accept the risks involved
- ✅ You will implement compensating controls
- ✅ You are using it for legitimate purposes
- ✅ You comply with applicable laws and policies

---

## 📞 Emergency Response

### If You Suspect a Security Breach:

1. **Immediate Actions:**
   ```powershell
   # Disconnect from internet
   Disable-NetAdapter -Name "*"

   # Lock your account
   # Win + L immediately
   ```

2. **Assessment:**
   - Check for unusual processes
   - Check network connections
   - Review recent file changes
   - Check Event Viewer for anomalies

3. **Response:**
   - Change all passwords
   - Re-enable VBS if needed
   - Run full antivirus scan
   - Restore from clean backup if necessary

4. **Report:**
   - Contact your IT department (if corporate)
   - Report to relevant authorities if serious
   - Document everything

---

## 🔄 Reverting Security Changes

To restore full security features:

```powershell
# Re-enable VBS
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" `
    -Name "EnableVirtualizationBasedSecurity" -Value 1 -Force

# Re-enable HVCI
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" `
    -Name "Enabled" -Value 1 -Force

# Re-enable hypervisor
bcdedit /set hypervisorlaunchtype auto

# Enable Memory Integrity via GUI
# Windows Security → Device security → Core isolation → Memory integrity: ON

# Restart
Restart-Computer
```

Also re-enable in BIOS:
- Secure Boot: Enabled
- DMA Protection: Enabled (if available)

---

## 📊 Security Checklist

Before running this script, verify:

- [ ] I understand what VBS/HVCI/Device Guard do
- [ ] I accept the security trade-off
- [ ] I will implement compensating controls
- [ ] I have BitLocker enabled or will enable it
- [ ] I use strong, unique passwords
- [ ] I will maintain physical security
- [ ] I keep Windows Defender enabled
- [ ] I keep my system updated
- [ ] I have a backup strategy
- [ ] I understand how to revert changes
- [ ] My use case justifies the risk
- [ ] I'm not violating any policies

---

**Created by: [ZACODEC](https://github.com/zainmustafam977)**
**Last Updated: February 2026**
**Version: 2.0**
