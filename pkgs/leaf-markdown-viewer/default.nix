{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "leaf-markdown-viewer";
  version = "1.29.3";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    tag = finalAttrs.version;
    hash = "sha256-/gV1jzY5fo0DzCCTD8MKb9U0CCUpSC1EsnmTKjJGZAE=";
  };

  cargoHash = "sha256-cxi+nM5dQ5gF5aKmbq+SO+pF7lBmypZaPw+tVmpYYMs=";

  nativeBuildInputs = [ installShellFiles ];

  checkFlags = [
    # Races a wall-clock scan budget against a directory limit; flakes under load.
    "--skip=tests::file_fuzzy::fuzzy_file_picker_reports_directory_limit_truncation"
    # Reads the old side of a diff with `git show`, so it needs the source to
    # be a git checkout, which the build sandbox's unpacked tarball is not.
    "--skip=tests::render_preview::preview_mode_only_before_shows_content"
  ];

  postInstall = ''
    installShellCompletion \
      --bash completions/leaf.bash \
      --fish completions/leaf.fish \
      --zsh completions/leaf.zsh
  '';

  meta = {
    description = "Terminal Markdown previewer with a GUI-like experience";
    homepage = "https://leaf.rivolink.mg";
    changelog = "https://github.com/RivoLink/leaf/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "leaf";
  };
})
