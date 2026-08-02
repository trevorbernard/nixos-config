{ pkgs, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  my.graphify.withOpenai = true;

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
    sonarqube-cli
  ];

  homebrew = {
    # Homebrew 6 refuses formulae/casks from non-official taps unless the
    # Brewfile marks the tap trusted (HOMEBREW_REQUIRE_TAP_TRUST).
    taps = [
      {
        name = "snowflakedb/snowflake-cli";
        trusted = true;
      }
      {
        name = "atlassian-labs/acli";
        trusted = true;
      }
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
