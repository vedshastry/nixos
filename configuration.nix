{ config, pkgs, inputs, ... }:

{

  # Hardware config
  imports = [ ./hardware-configuration.nix ];

  # Networking
  networking.hostName = "thinkpad";
  networking.networkmanager.enable = true; # Enable networkmanager

  # Time & Locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MONETARY = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # User Account
  users.users.ved = {
    isNormalUser = true;
    uid = 1000;
    description = "Ved Shastry";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "audio" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # Graphics & Hardware
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # for legacy support
  };
  # Enable non-root access to QMK/VIA keyboards
  hardware.keyboard.qmk.enable = true;
  # If the standard QMK rule doesn't catch the NuPhy V2
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="32f5", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl",
    ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl start --no-block monitor-hotplug.service"
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", RUN+="${pkgs.systemd}/bin/systemctl start --no-block power-suspend-guard.service"
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="USB", RUN+="${pkgs.systemd}/bin/systemctl start --no-block power-suspend-guard.service"
  '';

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # Power up the default controller on boot
  services.blueman.enable = true; # Enables the Blueman service, Polkit rules, and D-Bus integration

  # Services
  services.mullvad-vpn.enable = true; # Mullvad
  services.mullvad-vpn.package = pkgs.mullvad-vpn; # Mullvad GUI
  services.resolved.enable = true;  # Resolve DNS systemd

# Power Management (TLP)
  services.power-profiles-daemon.enable = false; # Conflict with TLP
  services.tlp = {
    enable = true;
    settings = {
      # --- General Settings ---
      TLP_ENABLE = 1;

      # --- Battery Care (ThinkPad Specific) ---
      # Start charging at 75%, stop at 80%. 
      # For "Always on AC" usage to extend battery lifespan.
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # --- CPU / Platform Profiles
      # "performance" on AC allows the CPU to boost high for Stata
      # "balanced" or "low-power" on BAT keeps it cool
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # AMD P-State EPP (Energy Performance Preference)
      # This is the modern replacement for "governors" on Zen 3/4
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Scaling Governor (Fallback, but good to set)
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # --- Boost Logic ---
      # Allow Turbo Boost on AC
      # Disable on Battery
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # --- Radio Devices ---
      # Don't touch bluetooth on boot
      # RESTORE_DEVICE_STATE_ON_STARTUP = 1;
    };
  };

    # Xorg server
      services.xserver = {
        enable = true;
        windowManager.dwm.enable = true;
        displayManager.startx.enable = true; # Keep it simple, or use a DM like sddm
      };

      services.libinput.enable = true; # Enable touchpad support
      services.printing.enable = true; # Printing
      security.rtkit.enable = true; # Scheduling
      security.polkit.enable = true; # access for GUI apps
      services.pulseaudio.enable = false; # Disable pulse for pipewire
      services.gvfs.enable = true; # Mount, trash, and remote filesystem support
      services.tumbler.enable = true; # Thumbnail support for Thunar

  # Libinput opts
  services.libinput = {
      touchpad = {
        naturalScrolling = false;
        tapping = true;
        tappingDragLock = true;
        disableWhileTyping = false;
        middleEmulation = true;
        scrollMethod = "twofinger";
      };
    };

  # Resume on dock/AC attach: this T14 Gen5 AMD only supports s2idle (no S3).
  # The nixos-hardware lenovo-thinkpad-t14-amd-gen5 module sets
  # acpi.ec_no_wakeup=1, which disables the embedded controller as a wake
  # source -- but the EC is exactly what detects "power attached". Appending
  # =0 overrides it (last value on the cmdline wins) so plugging the dock wakes
  # the machine from s2idle. Trade-off: the EC may also raise spurious wakes;
  # revert if the battery drains while bagged.
  boot.kernelParams = [ "acpi.ec_no_wakeup=0" ];

  # Power Management & Lid Switch Behavior
  # logind's lid handling is fully disabled; acpid owns all suspend decisions
  # (logind's DRM display-counting is buggy across Thunderbolt disconnects).
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Monitor hotplugging
  systemd.services.monitor-hotplug = {
    description = "Trigger monitor hotplug";
    # Ensure it only runs after the graphics stack is up
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "ved";
      Environment = [
        "DISPLAY=:0"
        "XAUTHORITY=/home/ved/.Xauthority"
        "PATH=/run/current-system/sw/bin:/run/wrappers/bin:/bin"
      ];
      ExecStart = "/home/ved/scripts/xmonitors.sh";
    };
  };

  # --- SUSPEND MANAGEMENT ---
  #
  # The machine suspends only via the power-suspend-guard service below.
  # Display routing is owned entirely by udev -> monitor-hotplug.service; the
  # suspend path never touches xrandr.
  #
  # Why not acpid for power? On this Type-C/Thunderbolt dock, yanking the cable
  # does NOT emit a classic ACPI `ac_adapter` event (verified: acpid logs zero
  # power events during a dock disconnect). Power is delivered through the UCSI
  # USB-C controller, whose driver reliably fires a `power_supply` udev `change`
  # event instead. So the suspend trigger lives on the power_supply subsystem.
  #
  # acpid is retained ONLY for the lid button, which does emit ACPI events.
  services.acpid = {
    enable = true;

    # Coffee-shop case: undocked, close lid -> suspend. The poll still rides out
    # any momentary power flicker. `grep -qx 1` matches a line that is exactly
    # "1", so values like "10" can never false-positive.
    handlers.lidEvent = {
      event = "button/lid.*";
      action = ''
        LID_STATE=$(${pkgs.coreutils}/bin/cat /proc/acpi/button/lid/*/state | ${pkgs.gawk}/bin/awk '{print $2}')
        if [ "$LID_STATE" != "closed" ]; then
           exit 0
        fi

        for _ in $(${pkgs.coreutils}/bin/seq 1 8); do
           if ${pkgs.gnugrep}/bin/grep -qx 1 /sys/class/power_supply/*/online 2>/dev/null; then
              exit 0
           fi
           ${pkgs.coreutils}/bin/sleep 1
        done

        ${pkgs.systemd}/bin/systemctl suspend
      '';
    };
  };

  # Suspend guard: fired by the power_supply udev rule on AC/USB-C power change.
  # Polls up to 8s to ride out the 5-7s 0V drop during a Thunderbolt PD
  # handshake. If power comes back -> docking/charging, stay awake. If power
  # stays gone and the lid is shut -> the cable was yanked, suspend.
  systemd.services.power-suspend-guard = {
    description = "Suspend when external power is lost and lid is closed (Type-C aware)";
    path = [ pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.systemd ];
    serviceConfig.Type = "oneshot";
    # A single dock connect emits a STORM of power_supply changes (PD
    # renegotiation), each starting this unit. The default limiter
    # (5 starts / 10s) would then refuse the *next* real event — e.g. the
    # unplug — with "start request repeated too quickly", so the machine would
    # never suspend. Disable the limiter; the 8s poll + oneshot job coalescing
    # already keep concurrency bounded.
    unitConfig.StartLimitIntervalSec = "0";
    script = ''
      LOG=/tmp/power-suspend-guard.log

      # Count supplies reporting exactly online=1, across the canonical AC
      # (Mains) line plus every UCSI USB-C source (the dock's real path).
      # `|| true` keeps grep's exit-1-on-zero-matches from failing the unit.
      online_count() {
        cat /sys/class/power_supply/AC/online \
            /sys/class/power_supply/ucsi-source-psy-*/online 2>/dev/null \
          | grep -cx 1 || true
      }

      echo "=== $(date) power_supply change (start online=$(online_count)) ===" >> "$LOG"

      # Poll up to 8s to ride out the 5-7s 0V drop during a Thunderbolt PD
      # handshake. If power ever shows up -> docking/charging, stay awake.
      for _ in $(seq 1 8); do
        N=$(online_count)
        if [ "$N" -gt 0 ]; then
          echo "power present (online sources=$N) -> stay awake" >> "$LOG"
          exit 0
        fi
        sleep 1
      done

      LID_STATE=$(cat /proc/acpi/button/lid/*/state | awk '{print $2}')
      echo "no power after 8s; lid=$LID_STATE" >> "$LOG"
      if [ "$LID_STATE" = "closed" ]; then
        echo "suspending" >> "$LOG"
        systemctl suspend
      fi
      exit 0
    '';
  };

  # Audio (pipewire)
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # ALSA Legacy
    pulse.enable = true; # Pipewire - pulse
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Cloudflare WARP (Systemd Service)
  systemd.packages = [ pkgs.cloudflare-warp ];
  systemd.services.warp-svc.wantedBy = [ "multi-user.target" ];

  # Ollama 
  services.ollama = {
    enable = true;
    
    # Use the rocm-specific package from the flake directly
    #package = inputs.ollama-flake.packages.${pkgs.system}.rocm;
    package = pkgs.ollama-rocm;

    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.2"; 
      OLLAMA_INTEL_GPU = "0"; 
      OLLAMA_KEEP_ALIVE = "1h"; 
      # This helps Ollama's internal discovery know to use the ROCm path
      OLLAMA_LLM_LIBRARY = "rocm";
    };
  };

  # Allow Unfree Software
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "pulsar-1.132.1"  # permit Pulsar editor
  ];

  # Package opts
  programs.nix-ld.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [

      # Suckless tools
      libX11 libXft libXinerama # dependencies
      st
      dmenu
      dwm
      slstatus

      # Tools
      git
      arandr
      srandrd
      stow
      wget
      vim
      neovim
      ranger
      ripgrep
      fd
      cryptsetup
      brightnessctl
      xdotool
      xclip
      via
      alsa-utils
      openconnect

  # Networking
  cloudflare-warp

  # GNOME
  gtk3
  gsettings-desktop-schemas
  gnomeExtensions.appindicator
  libappindicator
  polkit_gnome

  # Progs
  nodejs
  pyright ## for neovim Mason loading LSP config

    # System Management
    pavucontrol  # Audio GUI
    htop

  ];

# Libraries for nix-ld
programs.nix-ld.libraries = with pkgs; [
  gtk2
  atk
  pango
  gdk-pixbuf
  cairo
  glibc
  glib
  gcc.cc
  libx11
  libxcursor
  libxrandr
  libxinerama
  libxi
  libxrender
  libxtst
  libxcb
  libsm
  libice
  libxcrypt
  libuuid
  ncurses5
  zlib
  stdenv.cc.cc
  freetype
  fontconfig
];

# Enable dconf
  programs.dconf.enable = true;

  # Enable XDG Portals
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "gtk";
    };

  # suckless tools
  nixpkgs.overlays = [
    (final: prev: {

      dwm = prev.dwm.overrideAttrs (old: {
        src = inputs.my-dwm;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git prev.pkg-config ];
        buildInputs = (old.buildInputs or []) ++ [ prev.libxcb prev.libxcb-util prev.libxcb-wm ];

        # Clean old binaries
        preBuild = ''
          make clean
        '';

        # --- FIX compile ---
        # Instead of relying on 'make install' and 'makeFlags', we manually copy the binary.
        # This guarantees it ends up in $out/bin/dwm where NixOS expects it.
        installPhase = ''
          mkdir -p $out/bin
          cp dwm $out/bin/

          # Optional: Copy man pages if you want 'man dwm' to work
          mkdir -p $out/share/man/man1
          cp dwm.1 $out/share/man/man1/
        '';
      });

      st = prev.st.overrideAttrs (old: {
        src = inputs.my-st;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git prev.pkg-config ];
          buildInputs = (old.buildInputs or []) ++ [ prev.harfbuzz ];

        # Clean old binaries
        preBuild = ''
          make clean
        '';

        postPatch = ''
        ${old.postPatch or ""}
        sed -i '/git submodule/d' Makefile
        '';
      });

      dmenu = prev.dmenu.overrideAttrs (old: {
        src = inputs.my-dmenu;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git ];

        # Clean old binaries
        preBuild = ''
          make clean
        '';

      });

      slstatus = prev.slstatus.overrideAttrs (old: {
        src = inputs.my-slstatus;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git ];

        # Clean old binaries
        preBuild = ''
          make clean
        '';

      });
    })
  ];

  # Fonts
  fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        font-awesome
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "NotoMono Nerd Font" ];
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
        };
      };
  };


  # Other nix settings
  nix.settings.experimental-features = ["nix-command" "flakes"];

# Allow pulling cached pre-built binaries for Claude Code
  nix.settings = {
    substituters = [ "https://claude-code.cachix.org" ];
    trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
  };

  # Leave at the release version of first install (25.11)
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";
}
