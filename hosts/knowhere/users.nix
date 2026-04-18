{ pkgs, ... }:
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXxbj3QvMLNgvuXvt6xHZKb0Jq/Czy71ROzer2UBNB8 trevor.bernard@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGrvzXeZ4upwcTK3K99XeGB0gbQSz+e2loo4iykSSRR tbernard@aypa.com"
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
      stow
      tailscale
      tree
      tumbler
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
