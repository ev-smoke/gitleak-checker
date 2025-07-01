#!/bin/bash

set -e

# === CONFIG ===
INSTALL_DIR="$HOME/.gitleaks"
GITLEAKS_BIN="$INSTALL_DIR/gitleaks"
GITLEAKS_VERSION="8.27.0"


# === Detect OS/ARCH ===
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64 | amd64) ARCH="x64" ;;
  arm64 | aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armv6" ;; # not officially supported
  *) echo "[Gitleaks] Unsupported architecture: $ARCH" && exit 1 ;;
esac

# === Resolve URL ===
get_download_url() {
  case "$OS" in
    linux)
      echo "https://github.com/gitleaks/gitleaks/releases/download/v$GITLEAKS_VERSION/gitleaks_${GITLEAKS_VERSION}_linux_${ARCH}.tar.gz"
      ;;
    darwin)
      echo "https://github.com/gitleaks/gitleaks/releases/download/v$GITLEAKS_VERSION/gitleaks_${GITLEAKS_VERSION}_darwin_${ARCH}.tar.gz"
      ;;
    msys*|mingw*|cygwin*|windows)
      echo "https://github.com/gitleaks/gitleaks/releases/download/v$GITLEAKS_VERSION/gitleaks_${GITLEAKS_VERSION}_windows_${ARCH}.zip"
      ;;
    *)
      echo "[Gitleaks] Unsupported OS: $OS" && exit 1
      ;;
  esac
}

# === Install gitleaks ===
install_gitleaks() {
  echo "[Gitleaks] Installing to $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"
  cd "$INSTALL_DIR"

  url=$(get_download_url)

  case "$url" in
    *.tar.gz)
      curl -sSL -L "$url" | tar -xzf - || {
        echo "[Gitleaks] Failed to extract .tar.gz archive"
        exit 1
      }
      ;;
    *.zip)
      curl -sSL -o gitleaks.zip "$url"
      unzip -o gitleaks.zip
      rm -f gitleaks.zip
      ;;
  esac

  bin_file=$(find . -maxdepth 1 -type f -name "gitleaks*" -executable | head -n1)
  if [ -z "$bin_file" ]; then
    echo "[Gitleaks] Could not find extracted gitleaks binary"
    exit 1
  fi

  chmod +x gitleaks
  cd - > /dev/null
}

# === Add to PATH (optional notice) ===
add_to_path_notice() {
  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "[Gitleaks] Note: Add '$INSTALL_DIR' to your PATH to use gitleaks globally"
  fi
}

# === Create Git pre-commit hook ===
install_git_hook() {
  HOOK_FILE=".git/hooks/pre-commit"
  echo "[Gitleaks] Installing git pre-commit hook..."

  cat > "$HOOK_FILE" <<EOF
#!/bin/bash
ENABLED=\$(git config --bool gitleaks.enabled || echo "true")
if [ "\$ENABLED" != "true" ]; then
  exit 0
fi
echo "[Gitleaks] Running secret scan..."
"$GITLEAKS_BIN" protect --staged --verbose --redact --no-banner
EOF

  chmod +x "$HOOK_FILE"
}

# === Run installer ===
if [ ! -x "$GITLEAKS_BIN" ]; then
  install_gitleaks
fi

# === Git hook setup ===
install_git_hook

# === Enable via git config ===
git config gitleaks.enabled true

# === Final info ===
echo "[Gitleaks] Installed successfully"
add_to_path_notice

