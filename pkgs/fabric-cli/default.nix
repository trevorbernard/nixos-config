{
  lib,
  python3,
  fetchPypi,
}:

let
  fabric-cicd = python3.pkgs.callPackage ./fabric-cicd.nix { };
in
python3.pkgs.buildPythonApplication rec {
  pname = "ms-fabric-cli";
  version = "1.9.0";
  format = "wheel";

  # Only a wheel is published to PyPI; there is no sdist to build from.
  src = fetchPypi {
    inherit version format;
    pname = "ms_fabric_cli";
    dist = "py3";
    python = "py3";
    hash = "sha256-XLIN4yY7Rwih8nb+EgPYZK8Aqyc/3dvFpEcOiItfxzE=";
  };

  # pyyaml and psutil are pinned to exact versions upstream; nixpkgs carries
  # newer patch releases of both. msal[broker] pulls pymsalruntime, a
  # closed-source Windows/macOS wheel that isn't packaged and that msal only
  # imports when brokered auth is explicitly enabled.
  pythonRelaxDeps = [
    "pyyaml"
    "psutil"
    "msal"
  ];

  dependencies =
    (with python3.pkgs; [
      argcomplete
      azure-core
      cachetools
      cryptography
      jmespath
      msal
      msal-extensions
      prompt-toolkit
      psutil
      pyyaml
      questionary
      requests
    ])
    ++ [ fabric-cicd ];

  pythonImportsCheck = [ "fabric_cli" ];

  meta = {
    description = "Command-line interface for Microsoft Fabric";
    homepage = "https://microsoft.github.io/fabric-cli/";
    changelog = "https://github.com/microsoft/fabric-cli/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "fab";
  };
}
