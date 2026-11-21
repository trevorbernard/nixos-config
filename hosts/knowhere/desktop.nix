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
      # Unlocked: these are defaults, so Settings and Tweaks can still
      # override them per user.
      {
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            # adw-gtk3 itself is installed in users.nix.
            gtk-theme = "adw-gtk3-dark";
            gtk-key-theme = "Emacs";
            monospace-font-name = "Fira Code 12 @wght=400";
            font-antialiasing = "rgba";
            font-hinting = "full";
            clock-format = "12h";
          };
          "org/gnome/desktop/wm/preferences" = {
            button-layout = "appmenu:minimize,maximize,close";
          };
          "org/gnome/desktop/input-sources" = {
            xkb-options = [
              "terminate:ctrl_alt_bksp"
              "caps:ctrl_modifier"
            ];
          };
          "org/gnome/shell" = {
            enabled-extensions = [
              "system-monitor@gnome-shell-extensions.gcampax.github.com"
              "apps-menu@gnome-shell-extensions.gcampax.github.com"
            ];
          };
          # Sleep targets are masked in services.nix; this stops GNOME from
          # trying anyway.
          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-type = "nothing";
          };
        };
      }
    ];
  };

  # Only settings the GDM greeter must also see belong here; it doesn't read
  # the user dconf profile above.
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    # Fractional scales in monitors.xml only apply in logical layout mode,
    # which the greeter doesn't get without scale-monitor-framebuffer.
    [org.gnome.mutter]
    experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
  '';
}
