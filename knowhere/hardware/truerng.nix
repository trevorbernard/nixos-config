{ pkgs, ... }:

{
  environment.systemPackages = [pkgs.rng-tools];

  # Rules for mounting TrueRNG. https://ubld.it/truerng_v3
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{product}=="TrueRNG", SYMLINK+="hwrandom", MODE="0660", GROUP="users", RUN+="${pkgs.coreutils}/bin/stty raw -echo -ixoff -F /dev/%k speed 3000000"
    ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="f5fe", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  systemd.services.rngd = {
    # Clean shutdown without DefaultDependencies
    conflicts = ["shutdown.target"];
    wantedBy = ["multi-user.target"];
    before = [
      "sysinit.target"
      "shutdown.target"
    ];

    description = "Hardware RNG Entropy Gatherer Daemon";

    # rngd may have to start early to avoid entropy starvation during boot with encrypted swap
    unitConfig.DefaultDependencies = false;

    serviceConfig = {
      ExecStart = "${pkgs.rng-tools}/sbin/rngd --foreground --rng-device=/dev/hwrandom --random-device=/dev/random";
      # PrivateTmp would introduce a circular dependency if /tmp is on tmpfs and swap is encrypted,
      # thus depending on rngd before swap, while swap depends on rngd to avoid entropy starvation.
      NoNewPrivileges = true;
      PrivateNetwork = true;
      ProtectSystem = "full";
      ProtectHome = true;
    };
  };
}
