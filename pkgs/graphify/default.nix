{
  lib,
  python3Packages,
  fetchPypi,
}:

let
  tree-sitter-java = python3Packages.callPackage ./tree-sitter-java.nix { };
  tree-sitter-typescript = python3Packages.callPackage ./tree-sitter-typescript.nix { };
in
python3Packages.buildPythonApplication rec {
  pname = "graphifyy";
  version = "0.8.35";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pKzZLH27mT0bBv40hoDywrtrjlDuc2ENuHqS6zviYc4=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies =
    (with python3Packages; [
      networkx
      datasketch
      rapidfuzz
      tree-sitter
      tree-sitter-python
      tree-sitter-javascript
      tree-sitter-rust
      tree-sitter-bash
      tree-sitter-json
    ])
    ++ [
      tree-sitter-java
      tree-sitter-typescript
    ];

  # graphify declares every supported grammar as a hard dependency but imports
  # each lazily in try/except, so we ship only the grammars we want and strip
  # the rest from the metadata to satisfy the runtime dependency check.
  pythonRemoveDeps = [
    "tree-sitter-go"
    "tree-sitter-groovy"
    "tree-sitter-c"
    "tree-sitter-cpp"
    "tree-sitter-ruby"
    "tree-sitter-c-sharp"
    "tree-sitter-kotlin"
    "tree-sitter-scala"
    "tree-sitter-php"
    "tree-sitter-swift"
    "tree-sitter-lua"
    "tree-sitter-zig"
    "tree-sitter-powershell"
    "tree-sitter-elixir"
    "tree-sitter-objc"
    "tree-sitter-julia"
    "tree-sitter-verilog"
    "tree-sitter-fortran"
  ];

  pythonImportsCheck = [ "graphify" ];

  meta = {
    description = "Turn any folder of code, docs, papers, and images into a queryable knowledge graph";
    homepage = "https://github.com/safishamsi/graphify";
    license = lib.licenses.mit;
    mainProgram = "graphify";
  };
}
