{ config, pkgs, lib, ... }:
{
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
    xkb.layout = "us";
  };

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
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  nixpkgs.config.nvidia.acceptLicense = true;

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
}
