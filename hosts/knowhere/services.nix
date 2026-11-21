{ ... }:
{
  services.printing.enable = true;

  virtualisation.docker.enable = true;

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

  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = 0;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
