{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  npmDepsFetcherVersion = 2;
  pname = "knip";
  version = "6.40.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/knip/-/knip-${finalAttrs.version}.tgz";
    hash = "sha256-SdQZvlapIuuviUQ4gW3fzZyC/g0P6OeY23nNwyBRCv4=";
  };

  # The npmjs tarball doesn't ship package-lock.json (npm strips it on
  # publish), so substitute a vendored lockfile.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-Gq32fFfSxqA17Lzr6DZ/rOZtOKSLIjIJQiJ83wNwLVY=";

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
