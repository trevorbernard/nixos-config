{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  npmDepsFetcherVersion = 2;
  pname = "cli-microsoft365";
  version = "11.10.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@pnp/cli-microsoft365/-/cli-microsoft365-${finalAttrs.version}.tgz";
    hash = "sha256-RPRW8NefSol1WfjIsce7KtqyoZEZdeaSo5yVfLLf2Oo=";
  };

  # The published npm-shrinkwrap.json has `resolved`/`integrity` stripped from
  # most of its 670 entries, so the deps fetcher can't use it. Drop it and
  # substitute a vendored lockfile regenerated from package.json.
  postPatch = ''
    rm npm-shrinkwrap.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-pCLadT8ffP6i4XM1/oVZiOYZzIf4uMAKtCfqqXE+tfE=";

  npmFlags = [ "--omit=dev" ];

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
