{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  npmDepsFetcherVersion = 2;
  pname = "knip";
  version = "6.47.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/knip/-/knip-${finalAttrs.version}.tgz";
    hash = "sha256-BmL6O/XxE9napKwx6gYsX51Jo5zd+FF98X4jlBL2u6g=";
  };

  # The npmjs tarball doesn't ship package-lock.json (npm strips it on
  # publish), so substitute a vendored lockfile.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-Oj1hPoW6KCifFMoPQ98Cb43OLtDeQgYeKt+mUR80Gg0=";

  npmFlags = [ "--omit=dev" ];

  # The published tarball ships a prebuilt dist/; we only install + wrap.
  dontNpmBuild = true;

  meta = {
    description = "Find unused files, dependencies and exports in JavaScript and TypeScript projects";
    homepage = "https://knip.dev";
    changelog = "https://github.com/webpro-nl/knip/releases/tag/knip@${finalAttrs.version}";
    downloadPage = "https://www.npmjs.com/package/knip";
    license = lib.licenses.isc;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "knip";
  };
})
