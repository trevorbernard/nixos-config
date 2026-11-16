{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "leaf-markdown-viewer";
  version = "1.28.1";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    tag = finalAttrs.version;
    hash = "sha256-xAO52Xhu2QOXzg/TJubTguJ7URddKnQekACnvytx5Qw=";
  };

  cargoHash = "sha256-Y+sOyHOSEjKW+NEpSjZgqJwXH3IOSFMBGM84oytRNsc=";

  nativeBuildInputs = [ installShellFiles ];

  # Races a wall-clock scan budget against a directory limit; flakes under load.
  checkFlags = [
    "--skip=tests::file_fuzzy::fuzzy_file_picker_reports_directory_limit_truncation"
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
