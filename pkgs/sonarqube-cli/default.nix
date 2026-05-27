{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sonarqube-cli";
  version = "0.13.0.1692";

  src = fetchurl {
    url = "https://binaries.sonarsource.com/Distribution/sonarqube-cli/${finalAttrs.version}/macos/sonarqube-cli-${finalAttrs.version}-macos-arm64.exe";
    hash = "sha256-2fBws09tHfwQQP9WkTQiPJaV/bjQG9DS0wVBDrJVKxM=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/sonar
    runHook postInstall
  '';

  meta = {
    description = "Command-line interface for SonarQube with AI agent integration";
    homepage = "https://cli.sonarqube.com/";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "sonar";
  };
})
