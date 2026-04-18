{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/shared/nix.nix
    ../../modules/shared/packages.nix
    ./hardware/hardware-configuration.nix
    ./hardware/truerng.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "knowhere";

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    GTK_IM_MODULE = "none";
    COLORTERM = "truecolor";
    TERM = "xterm-direct";
    EDITOR = "emacs";
  };

  # Input lag in emacs without this
  i18n.inputMethod.enable = false;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver = {
    enable = true;
    dpi = 144;
    videoDrivers = [ "nvidia" ];
  };
  services.xserver.xkb.layout = "us";

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  services.desktopManager.gnome.enable = true;

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  nixpkgs.config.nvidia.acceptLicense = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "amazon-q-cli"
      "aspell-dict-en-science"
      "brave"
      "claude-code"
      "nvidia-persistenced"
      "nvidia-settings"
      "nvidia-x11"
      "terraform"
    ];

  virtualisation.docker.enable = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    "Wired connection 1" = {
      connection = {
        id = "Wired connection 1";
        type = "ethernet";
        interface-name = "eno1";
        autoconnect = "true";
        permissions = "";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  environment.homeBinInPath = true;

  users.users.tbernard = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Trevor Bernard";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXxbj3QvMLNgvuXvt6xHZKb0Jq/Czy71ROzer2UBNB8 trevor.bernard@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGrvzXeZ4upwcTK3K99XeGB0gbQSz+e2loo4iykSSRR tbernard@aypa.com"
    ];
    packages = with pkgs; [
      adw-gtk3
      amazon-q-cli
      awscli2
      brave
      git-filter-repo
      jujutsu
      keepassxc
      ninja
      signal-desktop
      stow
      tailscale
      tree
      tumbler
    ];
  };

  services.tailscale.enable = true;

  security.sudo.extraRules = [
    {
      users = [ "tbernard" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = with pkgs; [
    (aspellWithDicts (dicts: with dicts; [
      en
      en-computers
      en-science
    ]))
    bat
    ghostty
    gnome-tweaks
    gnumake
    jq
    libvterm
    magic-wormhole
    nh
    nix-output-monitor
    nixfmt-rfc-style
    nvd
    ripgrep
    terraform
    unzip
    vim
    wl-clipboard
    yq
    zip
  ];

  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    jetbrains-mono
  ];

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true;
        settings =
          let
            empty = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          in
          {
            "org/gnome/desktop/wm/keybindings" = {
              activate-window-menu = empty;
            };
          };
      }
    ];
  };

  programs.gnome-terminal.enable = true;

  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-key-theme='Emacs'
  '';

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = 0;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.syncthing = {
    enable = true;
    user = "tbernard";
    dataDir = "/home/tbernard";
    settings = {
      options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
      };
      devices = {
        "macbook-pro" = {
          id = "MD5DF3C-DKWSXWZ-YSJMJ5N-TB2HQWW-L3RYVK2-VIS6JHK-RVHFCHZ-WSA2NQH";
          addresses = [ "tcp://macbook-pro.tailb5107e.ts.net:22000" ];
        };
        # ipad and iphone entries added once Möbius Sync device IDs are known
      };
      folders = {
        "keepass" = {
          path = "/home/tbernard/Sync/keepass";
          devices = [ "macbook-pro" ];
        };
        "documents" = {
          path = "/home/tbernard/Sync/documents";
          devices = [ "macbook-pro" ];
        };
      };
    };
  };

  networking.firewall = {
    interfaces."eno1" = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };
    interfaces."tailscale0" = {
      allowedTCPPorts = [ 22 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };
  };

  system.stateVersion = "24.11";
}
