{ pkgs, lib, ... }:

pkgs.callPackage (pkgs.fetchFromGitHub {
  owner = "trevorbernard";
  repo = "termcopy";
  rev = "v0.1.0";
  sha256 = "sha256-P6Nk6uOG9xC9HhIfdjQ+A4E2GbrQicdC+a/wwJ++6sA=";
} + "/default.nix") { }