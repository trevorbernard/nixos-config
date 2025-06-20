{ config, pkgs, lib, ... }:

{
  # User account configuration
  users.users.tbernard = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Trevor Bernard";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXxbj3QvMLNgvuXvt6xHZKb0Jq/Czy71ROzer2UBNB8 trevor.bernard@gmail.com"
    ];
    packages = with pkgs; [
      # Desktop applications
      brave
      discord
      keepassxc
      signal-desktop
      slack
      
      # Utilities
      direnv
      stow
    ];
  };

  # Sudo configuration
  security.sudo.extraRules = [
    {
      users = [ "tbernard" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Shell configuration
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];

  programs.zsh = {
    enable = true;

    interactiveShellInit = ''
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';

    ohMyZsh = {
      enable = true;
      plugins = [
        "direnv"
        "fzf"
        "git"
        "sudo"
      ];
      customPkgs = with pkgs; [
        nix-zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-nix-shell
      ];
    };
    enableCompletion = false;
    autosuggestions = {
      enable = true;
      extraConfig = {
        "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" = "fg=#5b6078";
      };
    };
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  # GPG configuration
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}