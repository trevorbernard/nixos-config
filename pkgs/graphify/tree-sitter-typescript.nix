{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "tree-sitter-typescript";
  version = "0.23.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-typescript";
    tag = "v${version}";
    hash = "sha256-CU55+YoFJb6zWbJnbd38B7iEGkhukSVpBN7sli6GkGY=";
  };

  build-system = [ setuptools ];

  optional-dependencies.core = [ tree-sitter ];

  doCheck = false;
  pythonImportsCheck = [ "tree_sitter_typescript" ];

  meta = {
    description = "TypeScript and TSX grammars for tree-sitter";
    homepage = "https://github.com/tree-sitter/tree-sitter-typescript";
    license = lib.licenses.mit;
  };
}
