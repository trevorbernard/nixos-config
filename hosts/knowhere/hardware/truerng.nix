{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.rng-tools ];

  # Rules for mounting TrueRNG. https://ubld.it/truerng_v3
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{product}=="TrueRNG", SYMLINK+="hwrandom", MODE="0660", GROUP="users", RUN+="${lib.getExe' pkgs.coreutils "stty"} raw -echo -ixoff -F /dev/%k speed 3000000"
    ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="f5fe", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  systemd.services.rngd = {
    # DefaultDependencies is off below so the unit can start before sysinit,
    # which also drops the implicit shutdown ordering; restore it by hand.
    conflicts = [ "shutdown.target" ];
    wantedBy = [ "multi-user.target" ];
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
