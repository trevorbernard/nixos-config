{
  lib,
  python3,
  fetchPypi,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = _: prev: {
      # fabric-cicd requires urllib3 >= 2.7.0, which is where several
      # high-severity advisories were fixed; nixos-26.05 still carries 2.6.3.
      # Relaxing the pin instead would ship the vulnerable release.
      urllib3 = prev.urllib3.overridePythonAttrs (old: rec {
        version = "2.7.0";
        src = fetchPypi {
          inherit (old) pname;
          inherit version;
          hash = "sha256-Ix4Ow7Y86xRmfGe+YPLyxApRjLOLA69gq8gT2iZQX0w=";
        };
        # nixpkgs strips the setuptools-scm build requirement, whose upper
        # bound moved from <10 to <11 in this release.
        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail ', "setuptools-scm>=8,<11"' ""
        '';
      });
    };
  };

  fabric-cicd = python.pkgs.callPackage ./fabric-cicd.nix { };
in
python.pkgs.buildPythonApplication rec {
  pname = "ms-fabric-cli";
  version = "1.7.0";
  format = "wheel";

  # Only a wheel is published to PyPI; there is no sdist to build from.
  src = fetchPypi {
    inherit version format;
    pname = "ms_fabric_cli";
    dist = "py3";
    python = "py3";
    hash = "sha256-lS7UnUbgAQfnVWh0avYsCimZJsFJkOphfnuDtanYupk=";
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
    (with python.pkgs; [
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
