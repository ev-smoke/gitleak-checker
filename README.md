# 🔐 Gitleaks Pre-commit Hook Installer

A cross-platform Git pre-commit hook that integrates [Gitleaks](https://github.com/gitleaks/gitleaks) to automatically scan your staged code for secrets before every commit.

---

## 📌 Purpose

This hook helps you **prevent accidental commits of sensitive data** such as:

- API keys  
- Tokens  
- Passwords  
- Secrets in environment files or source code  

If secrets are detected, the commit is **blocked** and a warning is displayed.

---

## ⚙️ Supported Platforms & Architectures

| Operating System | Supported Architectures     |
|------------------|-----------------------------|
| Linux            | `x86_64`, `arm64`           |
| macOS            | `x86_64`, `arm64` (M1/M2)   |
| Windows          | `x86_64`                    |

---

## 🚀 Installation

You can install the pre-commit hook and `gitleaks` in one command using `curl`:

```bash
curl -sSL https://raw.githubusercontent.com/ev-smoke/gitleak-checker/main/install.sh | bash
```

---

## 🛠 Configuration

during installation script set enable flag for git config, but any time you can set it manually

Enable or disable the hook at any time using Git config:
```bash
# Enable the hook (default)
git config gitleaks.enabled true

# Disable the hook
git config gitleaks.enabled false
```

---

## 🧪 Example Usage

```bash 
# Add a file that accidentally contains a secret
git add config.py

# Attempt to commit
git commit -m "Add config"

# Output:
# [Gitleaks] Secret(s) detected. Commit rejected.
```

---

## 📦 Notes
- If gitleaks is not installed, the script will download it automatically.

- You can add ~/.gitleaks/ to your PATH to use gitleaks globally:
```bash
echo 'export PATH="$HOME/.gitleaks:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
