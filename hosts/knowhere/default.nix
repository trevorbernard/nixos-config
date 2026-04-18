{ ... }:
{
  imports = [
    ../../modules/shared/nix.nix
    ../../modules/shared/packages.nix
    ./hardware/hardware-configuration.nix
    ./hardware/truerng.nix
    ./audio.nix
    ./desktop.nix
    ./networking.nix
    ./packages.nix
    ./services.nix
    ./users.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 5;

  networking.hostName = "knowhere";

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  system.stateVersion = "24.11";
}
