{
  lib,
  buildPythonPackage,
  fetchPypi,
  azure-identity,
  dpath,
  filetype,
  jsonpath-ng,
  pyyaml,
  requests,
  urllib3,
}:

buildPythonPackage rec {
  pname = "fabric-cicd";
  version = "1.3.0";
  format = "wheel";

  # Only a wheel is published to PyPI; there is no sdist to build from.
  src = fetchPypi {
    inherit version format;
    pname = "fabric_cicd";
    dist = "py3";
    python = "py3";
    hash = "sha256-6cdJcx2YQo8pWm69BgdWYlkfAKmZgxdZVNaa4vdFnQw=";
  };

  # nixpkgs ships jsonpath-ng 1.7.0 against a >=1.8.0 pin. Only the parser
  # entry points this uses are involved, and they are unchanged across that
  # bump.
  pythonRelaxDeps = [ "jsonpath-ng" ];

  dependencies = [
    azure-identity
    dpath
    filetype
    jsonpath-ng
    pyyaml
    requests
    urllib3
  ];

  pythonImportsCheck = [ "fabric_cicd" ];

  meta = {
    description = "Python library for Microsoft Fabric CI/CD deployments";
    homepage = "https://github.com/microsoft/fabric-cicd";
    license = lib.licenses.mit;
  };
}
