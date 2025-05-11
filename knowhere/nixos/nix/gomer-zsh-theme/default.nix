{
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "gomer-zsh-theme";
  version = "2025-05-10";

  src = ./.;
  
  strictDeps = true;
  installPhase = ''
    install -Dm0644 gomer.zsh-theme $out/share/zsh/themes/gomer.zsh-theme
  '';

  meta = with lib; {
    description = "Theme based on amuze.zsh-theme";
    homepage = "";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
