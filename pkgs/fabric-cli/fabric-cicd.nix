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
  version = "1.4.0";
  format = "wheel";

  # Only a wheel is published to PyPI; there is no sdist to build from.
  src = fetchPypi {
    inherit version format;
    pname = "fabric_cicd";
    dist = "py3";
    python = "py3";
    hash = "sha256-tOYRy2U/OWBWmrpShOHwz73jVO6/oluo9dgUINR6OgE=";
  };

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
