{ ... }:
{
  imports = [
    ../../modules/shared/nix.nix
    ../../modules/shared/packages.nix
    ../../modules/shared/fonts.nix
    ./hardware/hardware-configuration.nix
    ./hardware/truerng.nix
    ./audio.nix
    ./desktop.nix
    ./git-server.nix
    ./networking.nix
    ./packages.nix
    ./services.nix
    ./users.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/ata-KINGSTON_SA400S37240G_50026B7784FFE11F";
  boot.loader.grub.configurationLimit = 5;

  networking.hostName = "knowhere";

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  system.stateVersion = "24.11";
}
