{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  npmDepsFetcherVersion = 2;
  pname = "openspec";
  version = "2.1.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@fission-ai/openspec/-/openspec-${finalAttrs.version}.tgz";
    hash = "sha256-ifINMRyWQIr/jQq9iAoGPfFT9+w6eoq/QY0nr6KYRAw=";
  };

  # The npmjs tarball doesn't ship package-lock.json (npm strips it on
  # publish), so substitute a vendored lockfile.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-Vn23zQX9S1F7agFF/qLuztnrjH/UjP5ItTBzDkCj0Dw=";

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
