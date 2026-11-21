{ lib, ... }:
{
  services.printing.enable = true;

  # Rootless: the daemon runs as the invoking user, so there is no
  # root-equivalent docker group and published ports stay behind the firewall.
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  # The unit is installed for every user, so it also starts in the GDM
  # greeter's session, where it has no subuid range and crash-loops. mkForce
  # because the module already sets "!root", which this implies.
  systemd.user.services.docker.unitConfig.ConditionUser = lib.mkForce "tbernard";

  # The login server rather than services.rex.enable: the shared server runs
  # every terminal as the rex system user, while this runs a server per
  # account as that account.
  services.rex.loginServer = {
    enable = true;
    accounts.tbernard.principals = [ "tailscale:trevor.bernard@gmail.com" ];
    tailscaleServe.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # GNOME enables its own SSH agent by default, and both export
  # SSH_AUTH_SOCK; without this, which one wins depends on init order.
  services.gnome.gcr-ssh-agent.enable = false;

  services.openssh = {
    enable = true;
    # Port 22 is opened per interface in networking.nix instead.
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      # With UsePAM, keyboard-interactive is a second route to password login
      # that PasswordAuthentication alone leaves open.
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
