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
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="19f5", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # Power up the default controller on boot
  services.blueman.enable = true; # Enables the Blueman service, Polkit rules, and D-Bus integration

  # Services

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

    # Audio (pipewire)
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true; # ALSA Legacy
        pulse.enable = true; # Pipewire - pulse
        jack.enable = true;
        wireplumber.enable = true;
      };

  # Cloudflare WARP (Systemd Service)
  systemd.packages = [ pkgs.cloudflare-warp ];
  systemd.services.warp-svc.wantedBy = [ "multi-user.target" ];

  # Allow Unfree Software
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "pulsar-1.129.0"  # permit Pulsar editor
  ];

  # Package opts
  programs.nix-ld.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [

    # Suckless tools
    xorg.libX11 xorg.libXft xorg.libXinerama # dependencies
      st
      dmenu
      dwm
      slstatus

      # Tools
      git
      arandr
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

  # Cloudflare WARP
  cloudflare-warp

  # XFCE
  xfce4-power-manager

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
  xorg.libX11
  xorg.libXcursor
  xorg.libXrandr
  xorg.libXinerama
  xorg.libXi
  xorg.libXrender
  xorg.libXtst
  xorg.libxcb
  xorg.libSM
  xorg.libICE
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
        buildInputs = (old.buildInputs or []) ++ [ prev.xorg.libxcb prev.xorg.xcbutil prev.xorg.xcbutilwm ];

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


  # Leave at the release version of first install (25.11)
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";
}
