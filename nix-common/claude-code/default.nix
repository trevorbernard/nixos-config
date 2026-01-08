{
  lib,
  buildNpmPackage,
  fetchzip,
}:

buildNpmPackage rec {
  pname = "claude-code";
  version = "2.1.1";

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-GZIh20GyhsXaAm13veg2WErT4rF9a1x8Dzr9q5Al0io=";
  };

  npmDepsHash = "sha256-LhPlgnQiGwOrZo4IOKuMHCIeyAVxmmjjfZiMvfZDMEI=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  AUTHORIZED = "1";

  # `claude-code` tries to auto-update by default, this disables that functionality.
  # https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview#environment-variables
  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "An agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    maintainers = [ lib.maintainers.malo ];
    mainProgram = "claude";
  };
}
