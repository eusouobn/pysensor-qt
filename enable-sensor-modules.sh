#!/usr/bin/env bash
set -euo pipefail

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

if ((${#detected_modules[@]} == 0)); then
  echo "No candidate module was found via modinfo."
  exit 0
fi

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

echo
echo "Done. Check with:"
echo "  sensors"
echo "  pysensor-qt"
