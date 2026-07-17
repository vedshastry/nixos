# ThinkPad T14 Gen 5 AMD sleep constraints

These hardware and firmware constraints drive the lid-blind dock
suspend/resume design. They were verified on live hardware on 2026-06-16,
with the lid-event update verified after the kernel 7.1.3 bump on 2026-07-09.

- The machine supports only s2idle/S0ix. `/sys/power/mem_sleep` reports
  `[s2idle]`; assumptions about S3 deep sleep and BIOS wake-on-AC/S3 do not
  apply.
- The Type-C dock produces no ACPI `ac_adapter` event when disconnected.
  Power arrives through UCSI, and the reliable trigger is a `power_supply`
  udev `change` event.
- `acpid` lid events became unreliable after kernel 7.1.3. `logind` reliably
  observes the `PNP0C0D` lid switch, so lid handling belongs in logind and
  `services.acpid.enable` should remain false.
- The logind lid branches are intentionally: docked = ignore, external power =
  suspend, and battery = suspend. Its stale dock state after a Thunderbolt
  unplug is handled independently by `power-suspend-guard`.
- Relevant power supplies are `AC`, `BAT0`, and the two
  `ucsi-source-psy-USBC000:*` devices. The UCSI source is authoritative for
  dock power; the ACPI Mains mirror may lag.
- `nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5` sets
  `acpi.ec_no_wakeup=1`. Appending `acpi.ec_no_wakeup=0` would restore EC wake,
  but can cause spurious s2idle wakeups and battery drain.
- One dock connection can emit roughly nine `power_supply` changes in 25
  seconds. `power-suspend-guard` therefore disables the systemd start limiter
  with `unitConfig.StartLimitIntervalSec = "0"`.
- `monitor-hotplug.service` can run before X starts. `xmonitors.sh` must exit
  successfully when `xrandr` cannot reach display `:0`, or the unit appears
  failed on every boot.

The implementation is in `configuration.nix`: logind lid settings,
`power-suspend-guard`, the `power_supply` udev rules, and monitor-hotplug display
routing.
