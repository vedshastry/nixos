{ config, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- Boot & Hardware ---
  # Override nixos-hardware's acpi.ec_no_wakeup=1 so dock/AC attach wakes from s2idle.
  # See docs/agent-context/t14-gen5-amd-sleep-constraints.md.
  boot.kernelParams = [ "acpi.ec_no_wakeup=0" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.keyboard.qmk.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.udev.extraRules = ''
    # Non-root access for NuPhy V2 keyboard
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="19f5", ATTRS{idProduct}=="32f5", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl",
    ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl restart --no-block monitor-hotplug.service"
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", RUN+="${pkgs.systemd}/bin/systemctl start --no-block power-suspend-guard.service"
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="USB", RUN+="${pkgs.systemd}/bin/systemctl start --no-block power-suspend-guard.service"
  '';

  # --- Networking & Firewall ---
  networking.hostName = "thinkpad";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  # Tailscale mesh VPN; trust tailscale0 so SSH (22) and VNC (5900) work over
  # the tailnet without exposing VNC on the LAN.
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;
  };
  services.resolved.enable = true;

  # Cloudflare WARP
  systemd.packages = [ pkgs.cloudflare-warp ];
  systemd.services.warp-svc.wantedBy = [ "multi-user.target" ];

  # --- Time, Locale & Users ---
  # Dynamic timezone via GeoClue2 (time.timeZone must stay unset).
  services.automatic-timezoned.enable = true;
  services.geoclue2.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MONETARY = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users.users.ved = {
    isNormalUser = true;
    uid = 1000;
    description = "Ved Shastry";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "audio" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # --- Power & Sleep ---
  # See docs/agent-context/t14-gen5-amd-sleep-constraints.md for ThinkPad T14 Gen 5 sleep behavior.
  services.power-profiles-daemon.enable = false; # conflicts with TLP
  services.tlp = {
    enable = true;
    settings = {
      TLP_ENABLE = 1;

      # Battery charge thresholds (always-on-AC longevity)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # CPU / platform profiles
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
  };

  # Clamshell: ignore lid close only when docked with an external display.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Retired: logind handles lid close and power-suspend-guard handles USB-C dock unplug.
  services.acpid.enable = false;

  systemd.services.monitor-hotplug = {
    description = "Trigger monitor hotplug";
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

  # Fired by udev on power_supply change; polls 8s to ride out Thunderbolt PD drops
  # and suspends if external power stays gone with the lid closed.
  systemd.services.power-suspend-guard = {
    description = "Suspend when external power is lost and lid is closed (Type-C aware)";
    path = [ pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.systemd ];
    serviceConfig.Type = "oneshot";
    unitConfig.StartLimitIntervalSec = "0"; # avoid rate-limiting during PD renegotiation bursts
    script = ''
      LOG=/tmp/power-suspend-guard.log

      online_count() {
        cat /sys/class/power_supply/AC/online \
            /sys/class/power_supply/ucsi-source-psy-*/online 2>/dev/null \
          | grep -cx 1 || true
      }

      echo "=== $(date) power_supply change (start online=$(online_count)) ===" >> "$LOG"

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

  # --- Desktop, Xorg & Audio ---
  services.xserver = {
    enable = true;
    windowManager.dwm.enable = true;
    displayManager.startx.enable = true;
  };

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      tapping = true;
      tappingDragLock = true;
      disableWhileTyping = false;
      middleEmulation = true;
      scrollMethod = "twofinger";
    };
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.printing.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # --- Services ---
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
      OLLAMA_INTEL_GPU = "0";
      OLLAMA_KEEP_ALIVE = "1h";
      OLLAMA_LLM_LIBRARY = "rocm";
    };
  };

  # --- Nixpkgs & Overlays ---
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "zoom-7.1.5.4332"
      "pulsar-1.133.1"
      "librewolf-151.0.2-1"
      "librewolf-unwrapped-151.0.2-1"
    ];
    # gtk2 is flagged broken in nixpkgs; keep as warning for xstata/murrine/nix-ld.
    problems.handlers."gtk+".broken = "warn";
  };

  nixpkgs.overlays = [
    (final: prev: {
      dwm = prev.dwm.overrideAttrs (old: {
        src = inputs.my-dwm;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git prev.pkg-config ];
        buildInputs = (old.buildInputs or []) ++ [ prev.libxcb prev.libxcb-util prev.libxcb-wm ];
        preBuild = "make clean";
        installPhase = ''
          mkdir -p $out/bin $out/share/man/man1
          cp dwm $out/bin/
          cp dwm.1 $out/share/man/man1/
        '';
      });

      st = prev.st.overrideAttrs (old: {
        src = inputs.my-st;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git prev.pkg-config ];
        buildInputs = (old.buildInputs or []) ++ [ prev.harfbuzz ];
        preBuild = "make clean";
        postPatch = ''
          ${old.postPatch or ""}
          sed -i '/git submodule/d' Makefile
        '';
      });

      dmenu = prev.dmenu.overrideAttrs (old: {
        src = inputs.my-dmenu;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git ];
        preBuild = "make clean";
      });

      slstatus = prev.slstatus.overrideAttrs (old: {
        src = inputs.my-slstatus;
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.git ];
        preBuild = "make clean";
      });
    })
  ];

  # --- Packages & nix-ld ---
  environment.systemPackages = with pkgs; [
    # Suckless
    libX11 libXft libXinerama
    st
    dmenu
    dwm
    slstatus

    # CLI & System Tools
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
    htop
    pavucontrol

    # Networking
    cloudflare-warp
    x11vnc

    # GTK / GNOME integration
    gtk3
    gsettings-desktop-schemas
    gnomeExtensions.appindicator
    libappindicator
    polkit_gnome

    # Dev
    nodejs
    pyright # for neovim Mason LSP
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      gtk2
      atk
      pango
      gdk-pixbuf
      cairo
      glibc
      glib
      stdenv.cc.cc
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
      freetype
      fontconfig
    ];
  };

  # --- Fonts ---
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

  # --- Nix Settings ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [ "https://claude-code.cachix.org" ];
    trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "25.11";
}
