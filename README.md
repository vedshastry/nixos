# NixOS configuration

Declarative configuration for a Lenovo ThinkPad T14 Gen 5 AMD. The system uses
NixOS, Home Manager, Xorg, and a custom suckless desktop.

## Layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | Inputs and the `thinkpad` NixOS output |
| `configuration.nix` | System services, hardware, networking, power, and desktop configuration |
| `hardware-configuration.nix` | Boot, storage, filesystems, and machine-specific hardware settings |
| `home.nix` | User packages, zsh, theming, Git, and XDG defaults |
| `pkgs/` | Local package definitions |
| `symlink/` | Initial setup for shared files from the Arch installation |
| `docs/agent-context/` | Notes on verified hardware behavior and constraints |

## Desktop

The graphical session is started with `startx` and uses personal builds of:

- `dwm`
- `st`
- `dmenu`
- `slstatus`

Their repositories are flake inputs and are compiled through Nix. The desktop
uses Dracula themes, Bibata cursors, and JetBrains Mono and Noto fonts.

## System

- NixOS unstable with selected packages pinned to stable
- Home Manager as a NixOS module
- GRUB with Windows and Arch Linux boot entries
- TLP with ThinkPad charge thresholds and AMD P-State settings
- Custom dock, monitor-hotplug, lid, and suspend handling
- PipeWire, Bluetooth, printing, Tailscale, SSH, and Mullvad
- Local and hosted coding-agent CLIs managed declaratively
- CPU-only `llama.cpp` service for local inference

## Commands

Apply the configuration:

```bash
sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad
```

Update inputs and apply:

```bash
nix flake update --flake ~/repos/nixos
sudo nixos-rebuild switch --flake ~/repos/nixos#thinkpad
```

Shell aliases:

- `update` — apply the current configuration
- `sysup` — update flake inputs and apply

## Portability

This configuration is specific to one machine. Storage UUIDs, boot entries,
user paths, hardware settings, and shared-file setup must be changed before use
elsewhere.
