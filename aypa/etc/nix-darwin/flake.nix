{
  description = "nix-darwin configuration for aypa (macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    termcopy.url = "github:trevorbernard/termcopy";
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    termcopy,
    claude-code-overlay,
    ...
  }: let
    supportedSystems = ["aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    configuration = {pkgs, lib, config, ...}: {
      nixpkgs.overlays = [claude-code-overlay.overlays.default];
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["claude-code" "1password-cli"];
      # Packages
      environment.systemPackages =
        (with pkgs; [
          # Development tools
          clang
          cmake
          git
          gh
          libtool

          # Editors
          (emacs-nox.override {withNativeCompilation = true;})
          neovim

          # Shell utilities
          atuin
          direnv
          eza
          fzf
          starship
          zoxide

          # Nix tooling
          nil
          nix-direnv

          # Other
          _1password-cli
          (aspellWithDicts (dicts: with dicts; [en en-computers]))
          htop
          mosh
          tig
          tmux
        ])
        ++ [
          # External inputs
          pkgs.claude-code
          termcopy.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

      # Nix settings
      nix.settings = {
        experimental-features = "nix-command flakes";
        extra-substituters = ["https://ryoppippi.cachix.org"];
        extra-trusted-public-keys = ["ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="];
      };

      # System metadata
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Homebrew (GUI apps and packages not in nixpkgs)
      homebrew = {
        enable = true;
        taps = [
          "snowflakedb/snowflake-cli"
          "atlassian-labs/acli"
        ];
        casks = [
          "1password"
          "brave-browser"
          "claude"
          "docker-desktop"
          "ghostty"
          "session-manager-plugin"
          "snowflake-cli"
          "spotify"
        ];
        brews = [
          "atlassian-labs/acli/acli"
          "glow"
          "gnupg"
        ];
      };

      # User configuration
      # Needed so nix-darwin knows home directory (https://github.com/LnL7/nix-darwin/issues/423)
      users.users.tbernard = {
        home = "/Users/tbernard";
        shell = pkgs.zsh;
      };
      system.primaryUser = "tbernard";
    };
  in {
    darwinConfigurations."aypa" = nix-darwin.lib.darwinSystem {
      modules = [configuration];
    };

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
