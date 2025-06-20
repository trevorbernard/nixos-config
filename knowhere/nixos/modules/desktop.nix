{ config, pkgs, lib, ... }:

{
  # X Server and Display Manager
  services.xserver = {
    enable = true;
    dpi = 144;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    
    # Configure keymap
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # GNOME configuration
  programs.gnome-terminal.enable = true;
  
  # Enable Emacs keybindings in GNOME
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.dconf ];

  programs.dconf = {
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

  # Set GTK applications to use Emacs key bindings
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-key-theme='Emacs'
  '';

  # Font configuration
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    fira-code-symbols
    jetbrains-mono
  ];

  # GNOME-specific packages
  environment.systemPackages = with pkgs; [
    adw-gtk3
    gnome-tweaks
  ];
}