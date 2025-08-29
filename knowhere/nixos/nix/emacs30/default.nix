{ pkgs }:

pkgs.emacs-nox.overrideAttrs (oldAttrs: {
  version = "30.2-git";

  src = pkgs.fetchgit {
    url = "https://git.savannah.gnu.org/git/emacs.git";
    rev = "emacs-30.2";
    sha256 = "sha256-3Lfb3HqdlXqSnwJfxe7npa4GGR9djldy8bKRpkQCdSA=";
  };

  preConfigure = ''
    ./autogen.sh
  '' + (oldAttrs.preConfigure or "");

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
    pkgs.autoconf
    pkgs.automake
  ];
})
