{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "pencil-cli";
  version = "0.2.6";

  src = fetchurl {
    url = "https://registry.npmjs.org/@pencil.dev/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-ToedCKlqIfRKG7eb6ONiLSAjlx8cCIUR+sO7lZH2lF4=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-U2hFc9EoCz3Ce3ctzZLsEdPF2tnXb27PrJJZ//ZLMY0=";

  npmFlags = [ "--omit=dev" ];
  dontNpmBuild = true;

  inherit nodejs;

  postInstall = ''
    chmod +x "$out/lib/node_modules/@pencil.dev/cli/dist/out"/mcp-server-darwin-* || true
  '';

  meta = {
    description = "CLI tool for running the Pencil AI agent manipulating .pen design files";
    homepage = "https://pencil.dev";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    mainProgram = "pencil";
  };
})
