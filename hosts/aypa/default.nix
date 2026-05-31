{ pkgs, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  my.unfreePackages = [
    "1password-cli"
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
