{
  lib,
  buildNpmPackage,
  fetchzip,
}:

buildNpmPackage rec {
  pname = "claude-code";
  version = "2.1.22";

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-vy7osk3UAOEgsJx9jdcGe2wICOk5Urzxh1WLAHyHM+U=";
  };

  npmDepsHash = "sha256-3C0HYsrX4haqkR+6PCWvC7dRfeRn6eO0d9Gf0wfl7Sg=";

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
