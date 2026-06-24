{ pkgs, ... }:
{
  imports = [
    ../../modules/darwin
  ];

  # graphify ships from modules/shared with no LLM backend; aypa enables its
  # OpenAI extra so the shared systemPackages entry resolves to that variant.
  nixpkgs.overlays = [
    (_: prev: {
      graphify = prev.graphify.override { withOpenai = true; };
    })
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
