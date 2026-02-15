# Contributing to VBS Disabler

Thank you for your interest in contributing! This project benefits from community input — the critical Windows Hello VBS fix was itself a community discovery.

## 🐛 Reporting Bugs

1. **Check existing issues** — your problem may already be reported.
2. **Open a new issue** using the [Bug Report template](https://github.com/ZACODEC/vbs-disabler/issues/new?template=bug_report.md).
3. Include:
   - Windows version and build number (`winver`)
   - VMware Workstation version
   - Full log file from `C:\VMwareFix\VBS_Disabler_*.log`
   - Verification log from `C:\VMwareFix\Verification_*.log`
   - Your PC manufacturer and model (for BIOS-related issues)

## 💡 Suggesting Features

1. Open an issue using the [Feature Request template](https://github.com/ZACODEC/vbs-disabler/issues/new?template=feature_request.md).
2. Describe the problem your feature would solve.
3. Propose a solution if you have one.

## 🔧 Submitting Changes

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/vbs-disabler.git
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Guidelines

- **Test on a real Windows 11 24H2/25H2 machine** before submitting (VMs won't work for testing this script)
- Keep the script compatible with **Windows PowerShell 5.1** (not just PowerShell 7+)
- Save files with **UTF-8 with BOM** encoding (required for PowerShell 5.1 Unicode support)
- Follow the existing code style:
  - Use `Write-Info`, `Write-Success`, `Write-Warning2`, `Write-Error2` for output
  - Use `Set-RegistrySafe` for registry modifications
  - Add `Write-Log` calls for important operations
- Update `CHANGELOG.md` with your changes
- Update `README.md` if adding new features or changing behavior

### Pull Request Process

1. Ensure the script parses without errors:
   ```powershell
   $null = [System.Management.Automation.Language.Parser]::ParseFile(
       '.\Final_VBS_Disabler_Professional_v2.ps1', [ref]$null, [ref]$errors
   )
   $errors.Count  # Should be 0
   ```
2. Test the full workflow on a physical machine
3. Open a Pull Request with:
   - Clear description of what changed and why
   - Test results (screenshot of verification passing)
   - Note any breaking changes

## 🔐 Security Vulnerabilities

**Do NOT open a public issue for security vulnerabilities.**

Instead, use [GitHub Security Advisories](https://github.com/ZACODEC/vbs-disabler/security/advisories/new) for private disclosure. See [SECURITY.md](SECURITY.md) for details.

## 📋 Code of Conduct

- Be respectful and constructive
- Help others who are struggling with VBS/VMware issues
- Share your testing results to help the community
- Credit original sources when contributing fixes discovered elsewhere

## 🙏 Thank You

Every contribution makes this tool better for the community. Whether it's a bug report, a BIOS guide for a new manufacturer, or a code improvement — it all matters!

---

**Created by [ZACODEC](https://github.com/ZACODEC)**
