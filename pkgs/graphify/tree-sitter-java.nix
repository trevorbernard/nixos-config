{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "tree-sitter-java";
  version = "0.23.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-java";
    tag = "v${version}";
    hash = "sha256-OvEO1BLZLjP3jt4gar18kiXderksFKO0WFXDQqGLRIY=";
  };

  build-system = [ setuptools ];

  optional-dependencies.core = [ tree-sitter ];

  doCheck = false;
  pythonImportsCheck = [ "tree_sitter_java" ];

  meta = {
    description = "Java grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter/tree-sitter-java";
    license = lib.licenses.mit;
  };
}
