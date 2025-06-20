{ config, pkgs, lib, ... }:

{
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # NVIDIA configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  nixpkgs.config.nvidia.acceptLicense = true;

  # Video driver configuration
  services.xserver.videoDrivers = [ "nvidia" ];

  # Environment variables for video card settings
  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    GTK_IM_MODULE = "none";  # Reduces input lag in emacs
  };

  # Chromium wayland support
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Sound configuration with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Docker virtualization
  virtualisation.docker.enable = true;
}