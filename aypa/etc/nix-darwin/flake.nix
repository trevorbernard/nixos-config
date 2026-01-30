{
  description = "nix-darwin configuration for aypa (macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    termcopy.url = "github:trevorbernard/termcopy";
    claude-code.url = "path:../../../nix-common/claude-code";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    termcopy,
    claude-code,
    ...
  }: let
    system = "aarch64-darwin";
    supportedSystems = ["aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    configuration = {pkgs, ...}: {
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
          (aspellWithDicts (dicts: with dicts; [en en-computers]))
          htop
          tig
          tmux
        ])
        ++ [
          # External inputs
          claude-code.packages.${system}.default
          termcopy.packages.${system}.default
        ];

      # Nix settings
      nix.settings.experimental-features = "nix-command flakes";

      # System metadata
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
      nixpkgs.hostPlatform = system;

      # Homebrew (GUI apps and packages not in nixpkgs)
      homebrew = {
        enable = true;
        taps = [
          "snowflakedb/snowflake-cli"
        ];
        casks = [
          "1password"
          "brave-browser"
          "claude"
          "ghostty"
          "snowflake-cli"
          "spotify"
        ];
        brews = [
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
