{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    config.init.defaultBranch = "main";
  };

  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/srv/git";
    createHome = false;
    shell = "${pkgs.git}/bin/git-shell";
    description = "Git repository host";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXxbj3QvMLNgvuXvt6xHZKb0Jq/Czy71ROzer2UBNB8 trevor.bernard@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt+TYVbgsasgfQFlMonpqw5YBHozhKAvyO4oFrwEimt trevor.bernard@pm.me"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINynFxuCMhLXTiFvmo5OvEK6RzN9c898pRGlTaWaz2Xj trevor@bernard.gg"
    ];
  };
  users.groups.git = { };

  systemd.tmpfiles.rules = [
    "d /srv/git 0750 git git -"
  ];

  services.openssh.extraConfig = ''
    Match User git Address *,!100.64.0.0/10,!fd7a:115c:a1e0::/48
      DenyUsers git
    Match User git
      AllowTcpForwarding no
      X11Forwarding no
      PermitTTY no
  '';
}
