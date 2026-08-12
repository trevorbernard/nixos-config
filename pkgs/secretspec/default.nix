{
  lib,
  rustPlatform,
  fetchCrate,
  fetchurl,
  cacert,
  jq,
  sops,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "secretspec";
  version = "0.19.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-tpzmzChyyYogebNZZi3LT61MO1HKZW8ln+21CwlqW8M=";
  };

  cargoHash = "sha256-VO05AAjBqNVowY2AsyF2W1k4sXWJxOw1U0krs13JS28=";

  # The crate tarball ships without the repo's test fixtures, so the shim the
  # bitwarden tests exec has to be fetched from the tagged source tree.
  postPatch = ''
    mkdir -p ../tests/fixtures
    cp ${
      fetchurl {
        url = "https://raw.githubusercontent.com/cachix/secretspec/v${finalAttrs.version}/tests/fixtures/bw-shim.sh";
        hash = "sha256-Xg1d8h2DOA6p0Hn9xP9TYzFN1863Wyk3QuQlFk+Y0ME=";
      }
    } ../tests/fixtures/bw-shim.sh
    chmod +x ../tests/fixtures/bw-shim.sh
    patchShebangs ../tests/fixtures/bw-shim.sh
  '';

  nativeCheckInputs = [
    jq
    sops
  ];

  # The sops in nixpkgs 26.05 chokes on this fixture's escaped-newline age
  # armor inside an INI value, so the round-trip can't decrypt.
  checkFlags = [ "--skip=provider::sops::tests::test_sops_single_file_get_ini" ];

  preCheck = ''
    export HOME="$TMPDIR"
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
  '';

  # A test binds to localhost, which requires an explicit Darwin sandbox exception.
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Declarative secrets, every environment, any provider";
    homepage = "https://secretspec.dev";
    license = lib.licenses.asl20;
    mainProgram = "secretspec";
  };
})
