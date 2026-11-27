{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.rng-tools ];

  # https://ubld.it/truerng_v3
  # SYSTEMD_WANTS starts rngd whenever the dongle appears, at boot or on
  # hotplug, instead of unconditionally at boot.
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{product}=="TrueRNG", SYMLINK+="hwrandom", MODE="0660", GROUP="users", TAG+="systemd", ENV{SYSTEMD_WANTS}+="rngd.service", RUN+="${lib.getExe' pkgs.coreutils "stty"} raw -echo -ixoff -F /dev/%k speed 3000000"
    ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="f5fe", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  systemd.services.rngd = {
    # DefaultDependencies is off below so the unit can start before sysinit,
    # which also drops the implicit shutdown ordering; restore it by hand.
    conflicts = [ "shutdown.target" ];
    # Tied to the dongle: stops when it is unplugged, and a boot without it
    # skips the unit rather than failing it.
    bindsTo = [ "dev-hwrandom.device" ];
    after = [ "dev-hwrandom.device" ];
    before = [
      "sysinit.target"
      "shutdown.target"
    ];

    description = "Hardware RNG Entropy Gatherer Daemon";

    # Feed the pool as early in boot as possible.
    unitConfig.DefaultDependencies = false;

    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.rng-tools "rngd"} --foreground --rng-device=/dev/hwrandom --random-device=/dev/random";
      NoNewPrivileges = true;
      PrivateNetwork = true;
      ProtectSystem = "full";
      ProtectHome = true;
    };
  };
}
