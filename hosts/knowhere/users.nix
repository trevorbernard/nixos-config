{ pkgs, ... }:
let
  sshKeys = import ../../modules/shared/ssh-keys.nix;
in
{
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  environment.homeBinInPath = true;

  users.users.tbernard = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Trevor Bernard";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      sshKeys.gmail
      sshKeys.aypa
      sshKeys.pm
    ];
    packages = with pkgs; [
      adw-gtk3
      amazon-q-cli
      awscli2
      brave
      git-filter-repo
      jujutsu
      keepassxc
      ninja
      signal-desktop
      tree
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "tbernard" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
