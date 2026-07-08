{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../modules/darwin
  ];

  # graphify ships from modules/shared with no LLM backend; aypa enables its
  # OpenAI extra so the shared systemPackages entry resolves to that variant.
  # mkAfter is required so this runs after the flake's commonOverlays defines
  # graphify; otherwise commonOverlays' plain definition clobbers the override.
  nixpkgs.overlays = lib.mkAfter [
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
