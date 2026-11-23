{
  lib,
  buildNpmPackage,
  fetchurl,
  pkg-config,
  libsecret,
  stdenv,
}:

buildNpmPackage (finalAttrs: {
  npmDepsFetcherVersion = 2;
  pname = "cli-microsoft365";
  version = "12.0.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@pnp/cli-microsoft365/-/cli-microsoft365-${finalAttrs.version}.tgz";
    hash = "sha256-j5bVytavBeuMD1vIW3+cQ6jN5aCRLxP0W2uafyH7iNQ=";
  };

  # The published npm-shrinkwrap.json has `resolved`/`integrity` stripped from
  # most of its 670 entries, so the deps fetcher can't use it. Drop it and
  # substitute a vendored lockfile regenerated from package.json.
  postPatch = ''
    rm npm-shrinkwrap.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-yZF+T3/88dEcaQ2olILAqx2pzhxGPsU5poB0c17wN7I=";

  npmFlags = [ "--omit=dev" ];

  # 12.0.0 added @azure/msal-node-extensions as an optional dependency, to keep
  # the token cache in the OS keychain. It pulls in keytar, a native addon
  # that has no network to fetch a prebuilt binary and so compiles here:
  # against libsecret on Linux, and the system Security framework on macOS.
  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libsecret ];

  # keytar is archived and pins node-addon-api 4.3.0, whose napi.h casts -1 to
  # an enum in a constant expression. clang >= 20 (the Darwin stdenv) makes
  # that a hard error with no flag to downgrade it; gcc accepts it. Hold the
  # install scripts back so the header can be patched first, then run them.
  # 15 is the top of the enum's valid range and not a real array type, so it
  # still works as the "unknown" sentinel; keytar never touches TypedArray.
  npmRebuildFlags = [ "--ignore-scripts" ];

  preBuild = ''
    substituteInPlace node_modules/node-addon-api/napi.h \
      --replace-fail 'unknown_array_type = static_cast<napi_typedarray_type>(-1);' \
                     'unknown_array_type = static_cast<napi_typedarray_type>(15);'
    npm rebuild $npmFlags
    patchShebangs node_modules
  '';

  # The published tarball ships a prebuilt dist/; we only install + wrap.
  dontNpmBuild = true;

  meta = {
    description = "Manage Microsoft 365 and SharePoint Framework projects from the command line";
    homepage = "https://pnp.github.io/cli-microsoft365/";
    changelog = "https://github.com/pnp/cli-microsoft365/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://www.npmjs.com/package/@pnp/cli-microsoft365";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "m365";
  };
})
