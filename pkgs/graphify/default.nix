{
  lib,
  python3Packages,
  fetchPypi,
  withOpenai ? false,
}:

let
  tree-sitter-java = python3Packages.callPackage ./tree-sitter-java.nix { };
  tree-sitter-typescript = python3Packages.callPackage ./tree-sitter-typescript.nix { };
in
python3Packages.buildPythonApplication rec {
  pname = "graphifyy";
  version = "0.9.114";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aetctgYZg/fIrSyG3aCg5H4wX41WWk+C50TzOuv7UzM=";
  };

  # nixos-26.05 ships setuptools 80; the >=83 floor is not needed to build
  # (the PEP 639 license fields it uses work from 77).
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools>=83.0.0"' '"setuptools"'
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies =
    (with python3Packages; [
      networkx
      numpy
      pyyaml
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
    ]
    # graphify[openai]: the OpenAI backend imports these lazily, so they are
    # only pulled in when the host opts into the extra.
    ++ lib.optionals withOpenai (
      with python3Packages;
      [
        openai
        tiktoken
      ]
    );

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
    homepage = "https://github.com/Graphify-Labs/graphify";
    license = lib.licenses.asl20;
    mainProgram = "graphify";
  };
}
