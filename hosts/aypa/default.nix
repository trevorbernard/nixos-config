{ pkgs, lib, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
      "claude-code"
      "sonarqube-cli"
      "terraform"
    ];

  environment.systemPackages = with pkgs; [
    _1password-cli
    awscli2
    neovim
    terraform
    (callPackage ../../pkgs/sonarqube-cli { })
  ];

  homebrew = {
    taps = [
      "snowflakedb/snowflake-cli"
      "atlassian-labs/acli"
    ];
    casks = [
      "1password"
      "ghostty"
      "gitbutler"
      "session-manager-plugin"
      "snowflake-cli"
    ];
    brews = [
      "atlassian-labs/acli/acli"
      "glow"
    ];
  };
}
