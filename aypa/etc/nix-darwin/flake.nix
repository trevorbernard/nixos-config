{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    termcopy.url = "github:trevorbernard/termcopy";
    claude-code.url = "path:../../../nix-common/claude-code";
  };

  outputs = { self, nix-darwin, nixpkgs, termcopy, claude-code, ... }:
  let
    system = "aarch64-darwin";
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        (with pkgs;
          [
            (aspellWithDicts (dicts: with dicts; [ en en-computers]))
            atuin
            clang
            cmake
            direnv
            (emacs-nox.override {
              withNativeCompilation = true;
            })
            eza
            fzf
            git
            gh
            htop
            libtool
            neovim
            nil
            nix-direnv
            starship
            tig
            tmux
            zoxide
          ])
        ++ [
          claude-code.packages.${system}.default
          termcopy.packages.${system}.default
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = system;

      homebrew = {
        enable = true;
        taps = [
          "snowflakedb/snowflake-cli"
        ];
        casks  = [
          "1password"
          "brave-browser"
          "claude"
          "ghostty"
          "snowflake-cli"
          "snowflake-snowsql"
          "spotify"
        ];
        brews = [
          "gnupg"
        ];
      };

      # The user should already exist, but we need to set this up so Nix knows
      # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
      users.users.tbernard = {
        home = "/Users/tbernard";
        shell = pkgs.zsh;
      };
      # Required for some settings like homebrew to know what user to apply to.
      system.primaryUser = "tbernard";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#aypa
    darwinConfigurations."aypa" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
