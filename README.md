# NixOS config

A declarative NixOS configuration for a Lenovo ThinkPad T14 Gen 5 (AMD).
It runs a suckless desktop (dwm, st, slstatus, dmenu) under X, built from
personal forks, and lives alongside Windows and Arch Linux in a triple-boot
setup.

## The setup

This machine triple-boots from a single disk:

- **Windows 11** — the primary OEM install, kept on its own partition.
- **Arch Linux** — a LUKS-encrypted btrfs partition. This is the daily driver
  and the source of truth for personal files.
- **NixOS** — this configuration. Rather than duplicating data, NixOS unlocks
  and mounts the Arch partition at `/mnt/arch`, then symlinks shared folders
  (`repos`, `Dropbox`, configs) into the NixOS home. Both systems read and
  write the same files.

GRUB replaces `systemd-boot` as the bootloader. It runs `os-prober` to pick up
Windows, carries an explicit menu entry for the encrypted Arch install, and
unlocks the LUKS volume at boot so the shared partition is available.

## Desktop

A minimal X session started with `startx` — no display manager. The window
manager and tools are suckless builds pulled from personal GitHub forks and
compiled by Nix via an overlay:

| Tool | Role | Source |
| :--- | :--- | :--- |
| dwm | tiling window manager | `github:vedshastry/dwm` |
| st | terminal | `github:vedshastry/st` |
| dmenu | application launcher | `github:vedshastry/dmenu` |
| slstatus | status bar | `github:vedshastry/slstatus` |

These are plain C repositories (`flake = false`); the overlay in
`configuration.nix` overrides each upstream package's `src` to point at the
fork and rebuilds it. Bindings live in each fork's `config.def.h`.

Theming is Dracula across GTK and Qt, Bibata cursors, with JetBrains Mono and
Noto fonts.

## Hardware & services

- Latest mainline kernel, AMD microcode, `fwupd` for firmware updates.
- TLP with ThinkPad battery charge thresholds and AMD P-State power profiles.
- PipeWire (ALSA/PulseAudio/JACK), Bluetooth, `libinput` touchpad, printing.
- Cloudflare WARP, Ollama on ROCm (AMD GPU), QMK/VIA keyboard access.
- Suspend on lid close.

## Repository layout

| File | Description |
| :--- | :--- |
| `flake.nix` | Entry point. Inputs (nixpkgs, home-manager, nixos-hardware, suckless forks, Zen browser) and the `thinkpad` system output. |
| `configuration.nix` | System config: networking, audio, Xorg, power, services, packages, and the suckless overlay. |
| `hardware-configuration.nix` | Boot and storage: GRUB, LUKS unlock, btrfs subvolume mounts, the Arch partition mount. |
| `home.nix` | Home Manager: user packages, zsh, theming, Git, XDG defaults. |
| `symlink/symlink.sh` | First-run script that links shared folders from the mounted Arch home into the NixOS home. |

## Usage

Rebuild and switch:

```bash
sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad
```

Update inputs, then rebuild:

```bash
nix flake update --flake ~/repos/nixos
sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad
```

These are aliased to `update` and `sysup` in the shell.

First run only — link the shared Arch folders:

```bash
./symlink/symlink.sh
```

## Notes

`hardware-configuration.nix` hard-codes the LUKS UUID and the partition layout
of this specific machine. It is not portable as-is — the encrypted device UUID,
filesystem UUIDs, and the `/mnt/arch` mount all need updating for any other
setup. The symlink script assumes the Arch root is mounted at `/mnt/arch` with
its home at `/mnt/arch/home`.
