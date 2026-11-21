{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  npmDepsFetcherVersion = 2;
  pname = "openspec";
  version = "1.6.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@fission-ai/openspec/-/openspec-${finalAttrs.version}.tgz";
    hash = "sha256-qAR3dn6Ypi6VZGStCaRLKMrMT8v94jdl97S6WY7hOFk=";
  };

  # The npmjs tarball doesn't ship package-lock.json (npm strips it on
  # publish), so substitute a vendored lockfile.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-tMBlolxvW0gvivlMy6kOJ2QdEdPCmR6C787zc8oWmlA=";

  npmFlags = [ "--omit=dev" ];

  # The published tarball ships a prebuilt dist/; we only install + wrap.
  dontNpmBuild = true;

  meta = {
    description = "Spec-driven development workflow for AI coding assistants";
    homepage = "https://github.com/Fission-AI/OpenSpec";
    changelog = "https://github.com/Fission-AI/OpenSpec/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://www.npmjs.com/package/@fission-ai/openspec";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "openspec";
  };
})
