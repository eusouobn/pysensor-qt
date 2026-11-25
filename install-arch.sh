#!/usr/bin/env bash
set -euo pipefail

APP_NAME="pysensor-qt"

echo "==> Installing dependencies on Arch..."
sudo pacman -S --needed python python-pyqt6 lm_sensors pciutils

echo "==> Installing ${APP_NAME}..."
sudo install -Dm755 pysensor-qt /usr/local/bin/pysensor-qt
sudo install -Dm644 pysensor-qt.desktop /usr/local/share/applications/pysensor-qt.desktop

echo "==> Updating desktop database, if available..."
if command -v update-desktop-database >/dev/null 2>&1; then
  sudo update-desktop-database /usr/local/share/applications || true
fi

echo "==> Configuring sensor modules automatically..."

candidate_modules=(
  k10temp
  coretemp
  drivetemp
  nct6775
  nct6683
  it87
)

detected_modules=()

for module in "${candidate_modules[@]}"; do
  if modinfo "$module" >/dev/null 2>&1; then
    echo "  - available module: $module"
    detected_modules+=("$module")
  fi
done

if ((${#detected_modules[@]} > 0)); then
  {
    echo "# Created by PySensor Qt"
    echo "# Load common sensor modules at boot."
    for module in "${detected_modules[@]}"; do
      echo "$module"
    done
  } | sudo tee /etc/modules-load.d/pysensor-qt-sensors.conf >/dev/null

  if printf '%s\n' "${detected_modules[@]}" | grep -qx 'nct6683'; then
    sudo install -Dm644 /dev/stdin /etc/modprobe.d/nct6683.conf <<'EOF'
# Created by PySensor Qt
# Needed on many MSI boards with Nuvoton NCT668x.
options nct6683 force=1
EOF
  fi

  echo "==> Trying to load modules now..."
  for module in "${detected_modules[@]}"; do
    case "$module" in
      nct6683)
        sudo modprobe nct6683 force=1 2>/dev/null || true
        ;;
      *)
        sudo modprobe "$module" 2>/dev/null || true
        ;;
    esac
  done
else
  echo "  No candidate module was found via modinfo."
fi

echo
echo "Installed!"
echo
echo "Run from the terminal with:"
echo "  pysensor-qt"
echo
echo "Or look for it in the menu:"
echo "  PySensor Qt"
echo
echo "To check sensors in the terminal:"
echo "  sensors"
echo
echo "Persistent configuration created at:"
echo "  /etc/modules-load.d/pysensor-qt-sensors.conf"
echo "  /etc/modprobe.d/nct6683.conf  (if nct6683 is present)"
