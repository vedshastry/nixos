# NixOS Configuration (ThinkPad T14 Gen 5 AMD)

This repository contains a declarative **NixOS** configuration for a **Lenovo ThinkPad T14 Gen 5 (AMD)**. It features a fully reproducible system state, a custom **suckless** desktop environment, and seamless integration with an existing **Arch Linux** dual-boot installation.

## 🚀 Key Features

### System
- Uses nix flakes for suckless tools
- Linux kernel (`pkgs.linuxPackages_latest`)
- **GRUB** replacing `systemd-boot` to manage dual-booting.
- Dualboots with Windows 11
- Mount LUKS encrypted btrfs partition at boot

- **Suckless tools**: lightweight workflow with vim bindings:
  - **DWM**: Tiling window manager.
  - **St**: Simple terminal (patched with scrollback, alpha, etc.).
  - **Dmenu**: Application launcher.
  - **Slstatus**: Status bar.
  - *Note: These are fetched directly from personal GitHub repositories during the build.*
- **Theming**:
  - **Dracula Theme**: Consistent dark theme across GTK, Icons, and QT applications.
  - **Volantes Cursors**: Modern cursor theme.
  - **Fonts**: JetBrains Mono Nerd Font (Coding) and Noto Sans (UI).

## Repository Structure

| File | Description |
| :--- | :--- |
| `flake.nix` | **Entry Point**. Defines inputs (Nixpkgs, Home Manager, Zen Browser) and system outputs. |
| `configuration.nix` | **System Config**. Networking, audio (Pipewire), Xorg, system-wide packages, and user accounts. |
| `hardware-configuration.nix` | **Hardware & Boot**. GRUB config, LUKS encryption setup, and filesystem mounts (including Arch partitions). |
| `home.nix` | **User Config**. Home Manager settings: shell aliases, theme settings, and user-specific packages. |

## Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/vedshastry/nixos.git ~/repos/nixos
   cd ~/repos/nixos
   ```

2. **Apply the configuration:**
   ```bash
   # Rebuilds the system and switches to the new generation
   sudo nixos-rebuild switch --flake .#hostname
   ```

3. **Post-Install (First Run):**
   Run the symlink script to connect shared folders from the Arch partition:
   ```bash
   ./symlink/symlink.sh
   ```

## ⚠️ Notes
- The `hardware-configuration.nix` includes specific UUIDs for the encrypted LUKS partitions. **Do not use this directly on another machine** without updating these identifiers.
- The `symlink.sh` script assumes the Arch partition is mounted at `/mnt/arch`.
