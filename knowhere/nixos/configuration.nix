{ config, pkgs, lib, ... }:

let
  claude-code = pkgs.callPackage ./nix/claude-code/default.nix {};
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware/truerng.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # This is my video card settings
  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };

  environment.variables = {
    # QT_SCALE_FACTOR = "1.25";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };

  # There is an input lag when working in emacs. This is in attempted to improve it
  environment.variables = {
    GTK_IM_MODULE = "none";
  };

  # For chromium wayland support
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  services.xserver = {
    enable = true;
    dpi = 144;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  nixpkgs.config.nvidia.acceptLicense = true;

  networking.hostName = "knowhere"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tbernard = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Trevor Bernard";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXxbj3QvMLNgvuXvt6xHZKb0Jq/Czy71ROzer2UBNB8 trevor.bernard@gmail.com"
    ];
    packages = with pkgs; [
      adw-gtk3
      brave
      chezmoi
      clang
      claude-code
      cmake
      direnv
      discord
      emacs-nox
      gnumake
      keepassxc
      jq
      libtool
      libvterm
      ninja
      nix-direnv
      ripgrep
      signal-desktop
      slack
      starship
      stow
      tig
    ];
  };

  environment.variables.COLORTERM = "truecolor";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    bat
    fzf
    ghostty
    git
    gnome-tweaks
    htop
    jujutsu
    mosh
    nh
    nil
    nix-output-monitor
    nixfmt-rfc-style
    nvd
    oh-my-zsh
    tmux
    vim
    wl-clipboard
    zoxide
    zsh
  ];

  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];

  environment.sessionVariables = {
    PATH="$HOME/bin:$PATH";
  };

  programs.zsh = {
    enable = true;

    interactiveShellInit = ''
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';

    ohMyZsh = {
      enable = true;
      plugins = [
        "direnv"
        "fzf"
        "git"
        "sudo"
      ];
      customPkgs = with pkgs; [
        nix-zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-nix-shell
      ];
    };
    enableCompletion = false;
    autosuggestions = {
      enable = true;
      extraConfig = {
        "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" = "fg=#5b6078";
      };
    };
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  environment.variables.TERM = "xterm-direct";
  environment.variables.EDITOR = "emacs";

  fonts.packages = with pkgs; [
    fira-code
    fira-code-nerdfont
    fira-code-symbols
  ];

  # Enable Emacs keybindings in GNOME
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.dconf ];

  programs.dconf = {
    profiles.user.databases = [
      {
        lockAll = true; # prevents overriding
        settings =
          let
            empty = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
          in
            {
              "org/gnome/desktop/wm/keybindings" = {
                activate-window-menu=empty;
              };
            };
      }
    ];
  };

  # Configure GNOME to use Emacs keybindings
  programs.gnome-terminal.enable = true;

  # Set GTK applications to use Emacs key bindings
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-key-theme='Emacs'
  '';

  # environment.etc."xdg/gtk-3.0/settings.ini" = {
  #   text = ''
  #     [Settings]
  #     gtk-key-theme-name=Emacs
  #   '';
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs.mosh.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 22 5173 ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # Default mosh port range
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
