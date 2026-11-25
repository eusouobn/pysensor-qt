# PySensor Qt

A compact Qt sensor monitor for Linux, inspired by `psensor`. It shows the readings that matter with short names and keeps the window as small as possible.

## Features

- Short sensor names such as `7500F TEMP`, `7500F USAGE` and `9060 XT TEMP`; full descriptive names stay in tooltips.
- Colored hardware tags: `CPU`, `GPU`, `MB`, `SSD`, `RAM`, `SYS`, `OTH`.
- Favorites and hidden sensors managed with a right-click menu; no checkboxes.
- `View → Show All Sensors` toggles between all sensors and favorites.
- Sorting by hardware (CPU → GPU → board → storage → memory → system) or by category.
- `View → Fit to content` resizes the window to the smallest size that fits the visible sensors, and reapplies it when readings arrive. The option is persisted.
- Minimum/maximum tracking and optional CSV logging.
- English interface with short labels (`Temp`, `Usage`, `Volt`, ...).

## Requirements

- Runtime: `python`, `python-pyqt6`, `lm_sensors`, `pciutils`
- Optional: `nvidia-utils` for NVIDIA GPU readings through `nvidia-smi`

Sensor data is read mainly from `/sys/class/hwmon` and `/sys/class/thermal`; no root privileges are needed to run the application.

## Install

### Arch Linux

Once the package is in the AUR:

```bash
yay -S pysensor-qt
```

Or build locally from a source checkout:

```bash
makepkg -si
```

### From source

```bash
install -Dm755 pysensor-qt ~/.local/bin/pysensor-qt
install -Dm644 pysensor-qt.desktop ~/.local/share/applications/pysensor-qt.desktop
export PATH="$HOME/.local/bin:$PATH"
```

`install-arch.sh` is an alternative helper that installs system-wide with `sudo` and configures common sensor modules. `enable-sensor-modules.sh` only configures kernel modules at boot. Both are optional.

## Usage

```bash
pysensor-qt
```

Settings are stored in `~/.config/pysensor-qt/settings.json` (favorites, hidden sensors, category visibility, sort order, window size and the auto-fit preference).

## License

GPL-3.0-only. See [LICENSE](LICENSE).
