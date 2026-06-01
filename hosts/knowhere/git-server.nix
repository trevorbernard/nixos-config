{ pkgs, ... }:
let
  sshKeys = import ../../modules/shared/ssh-keys.nix;
in
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
      sshKeys.gmail
      sshKeys.pm
      sshKeys.bernard-gg
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
