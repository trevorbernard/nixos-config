{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.variables = {
    # Wayland first, falling back to XWayland for apps that only speak X11.
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11";
    GTK_IM_MODULE = "none";
    COLORTERM = "truecolor";
  };

  # Input lag in emacs without this
  i18n.inputMethod.enable = false;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us";
  };

  services.displayManager.gdm = {
    enable = true;
  };

  # GDM's greeter can't see ~/.config/monitors.xml; without this it picks its own scale.
  environment.etc."xdg/monitors.xml".source = ./monitors.xml;

  services.desktopManager.gnome.enable = true;

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  nixpkgs.config.nvidia.acceptLicense = true;

  # jetbrains-mono comes from modules/shared/fonts.nix; these are desktop-only.
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
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

  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-key-theme='Emacs'

    # Fractional scales in monitors.xml only apply in logical layout mode,
    # which the greeter doesn't get without scale-monitor-framebuffer.
    [org.gnome.mutter]
    experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
  '';
}
