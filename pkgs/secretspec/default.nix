{
  lib,
  stdenv,
  rustPlatform,
  fetchCrate,
  cacert,
  git,
  jq,
  sops,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "secretspec";
  version = "0.21.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-VCvo+O3IHVUeZG6cxBmWy8/CEDZOwVr8IVcWxroUd00=";
  };

  cargoHash = "sha256-cA7HmOxCrfPiBKI8xxxpRBvGLUgyl4Ts1uhoCt0bBuk=";

  # The bitwarden tests embed this shim with include_str! and exec the copy,
  # so its shebang has to be fixed before compilation.
  postPatch = ''
    patchShebangs tests/fixtures/bw-shim.sh
  '';

  nativeCheckInputs = [
    git
    jq
    sops
  ];

  # Nix runs builders on a pty, so `colored` styles the report output that a
  # test compares against plain text.
  preCheck = ''
    export HOME="$TMPDIR"
    export NO_COLOR=1
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
  '';

  # Fails intermittently on Darwin: the fake gopass shim returns an empty
  # value when reading back a binary entry.
  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--skip=gopass_preserves_generated_whitespace"
  ];

  # A test binds to localhost, which requires an explicit Darwin sandbox exception.
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Declarative secrets, every environment, any provider";
    homepage = "https://secretspec.dev";
    license = lib.licenses.asl20;
    mainProgram = "secretspec";
  };
})
