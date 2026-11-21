---
name: update-local-packages
description: Use when asked to update, bump, or check for new versions of a package under pkgs/ in this repo (knip, openspec, cli-microsoft365, pencil-cli, leaf-markdown-viewer, secretspec, graphify, fabric-cli, sonarqube-cli).
---

# Update Local Packages

Each package under `pkgs/` carries a hand-written version and one to three
hashes. `nix-update` rewrites them in place; what differs per package is how
it finds the version and whether a vendored lockfile has to be regenerated.

```bash
NU="nix run --inputs-from . nixpkgs#nix-update --"
```

`--flake <name>` reads `packages.<current system>.<name>`, and works on a
dirty tree. NixOS has no `node` on PATH; where npm is needed, use
`nix shell --inputs-from . nixpkgs#nodejs -c npm …`.

## 1. Find what is behind

Current versions:

```bash
grep -n 'version = "' pkgs/*/*.nix
```

Latest versions:

```bash
npm_latest()  { curl -fsS "https://registry.npmjs.org/$1/latest" | jq -r .version; }
pypi_latest() { curl -fsS "https://pypi.org/pypi/$1/json" | jq -r .info.version; }
```

| Package | Latest version |
|---|---|
| knip | `npm_latest knip` |
| openspec | `npm_latest @fission-ai/openspec` |
| cli-microsoft365 | `npm_latest @pnp/cli-microsoft365` |
| pencil-cli | `npm_latest @pencil.dev/cli` |
| graphify | `pypi_latest graphifyy` |
| fabric-cli | `pypi_latest ms-fabric-cli` |
| leaf-markdown-viewer | `gh api repos/RivoLink/leaf/releases/latest --jq .tag_name` |
| secretspec | `curl -fsS -A nix-update https://crates.io/api/v1/crates/secretspec \| jq -r .crate.max_stable_version` |
| sonarqube-cli | see below |

```bash
# sonarqube-cli
curl -fsS 'https://binaries.sonarsource.com/s3api?delimiter=/&prefix=Distribution/sonarqube-cli/' \
  | grep -oE 'sonarqube-cli/[0-9.]+/' | cut -d/ -f2 | sort -V | tail -1
```

If nothing is behind, report that and stop. Otherwise do one package at a
time through steps 2 to 4.

## 2. Bump

### knip, openspec

The npm tarball ships no lockfile, so one is vendored. This updates the
version, the source hash, the lockfile and `npmDepsHash` together:

```bash
$NU --flake <name> --generate-lockfile
```

### cli-microsoft365

Its tarball ships a stripped `npm-shrinkwrap.json`, which makes
`--generate-lockfile` fail, so regenerate the lockfile by hand between two
nix-update passes:

```bash
repo=$PWD
$NU --flake cli-microsoft365 --src-only
tmp=$(mktemp -d)
tar -xzf "$(nix build --no-link --print-out-paths .#cli-microsoft365.src)" \
  -C "$tmp" --strip-components=1
rm "$tmp/npm-shrinkwrap.json"
(cd "$tmp" && nix shell --inputs-from "$repo" nixpkgs#nodejs -c \
  npm install --package-lock-only --ignore-scripts)
cp "$tmp/package-lock.json" pkgs/cli-microsoft365/package-lock.json
$NU --flake cli-microsoft365 --version=skip --no-src
```

### leaf-markdown-viewer, graphify

```bash
$NU --flake <name>
```

graphify declares every grammar it supports as a hard dependency. When a
release adds one, the build fails in the runtime dependency check naming it;
add it to `pythonRemoveDeps` unless the grammar is wanted. If graphify needs a
newer `tree-sitter-java` or `tree-sitter-typescript`, bump the version in
`pkgs/graphify/tree-sitter-*.nix` and take the hash from:

```bash
nix flake prefetch --json github:tree-sitter/tree-sitter-java/v<version> | jq -r .hash
```

### secretspec, fabric-cli

nix-update cannot detect the latest version for these two (crates.io via
`fetchCrate`, and a wheel-only PyPI source), so pass the one from step 1:

```bash
$NU --flake <name> --version <version>
```

secretspec has a second hash, for the `bw-shim.sh` test fixture fetched from
the tagged source tree. Refresh it by hand:

```bash
nix store prefetch-file --json \
  https://raw.githubusercontent.com/cachix/secretspec/v<version>/tests/fixtures/bw-shim.sh \
  | jq -r .hash
```

A 404 means the fixture moved or was removed upstream (it is gone as of
v0.21.1); look at the upstream `tests/` tree and adjust or drop the
`postPatch` accordingly. Also check whether the skipped sops test in
`checkFlags` still needs skipping.

fabric-cli depends on `fabric-cicd`, packaged next to it in
`pkgs/fabric-cli/fabric-cicd.nix`. Check what the new release requires:

```bash
curl -fsS https://pypi.org/pypi/ms-fabric-cli/<version>/json | jq -r '.info.requires_dist[]'
```

If it needs a newer fabric-cicd, edit the version in `fabric-cicd.nix` and
take the wheel hash from PyPI:

```bash
hex=$(curl -fsS https://pypi.org/pypi/fabric-cicd/<version>/json \
  | jq -r '.urls[] | select(.packagetype=="bdist_wheel") | .digests.sha256')
nix hash convert --hash-algo sha256 --to sri "$hex"
```

Exact pins in `requires_dist` that nixpkgs does not match go in
`pythonRelaxDeps`; remove entries that no longer need relaxing.

### pencil-cli, sonarqube-cli (Macs only)

Both are darwin-only, so `packages.x86_64-linux` does not contain them and
nix-update cannot evaluate them on knowhere. On Linux, skip them and say so.
On a Mac:

```bash
$NU --flake pencil-cli --generate-lockfile
$NU --flake sonarqube-cli --version <version>
```

These two recipes were written from Linux and have not been run. If
nix-update balks, edit the version by hand and take the source hash from
`nix store prefetch-file --json <url> | jq -r .hash`.

## 3. Build and run

```bash
nix fmt
out=$(nix build --no-link --print-out-paths ".#<name>")
"$out/bin/<mainProgram>" --version
```

`mainProgram` is in each package's `meta`. If the build fails:

- A rustc version error means the release needs a newer toolchain than
  nixos-26.05 ships. Do not pull the package from unstable on your own.
  Revert with `git checkout pkgs/<name>`, report the error, and let the user
  decide.
- For anything else, fix the derivation if the cause is clear (a renamed
  test, a new dependency), and say what changed. Otherwise revert and report.

For a major-version bump, read the changelog (`meta.changelog`) and put the
breaking changes in the report; these are CLIs used in scripts and by agents.

## 4. Commit

One commit per package, containing only that package's directory:

```bash
git add pkgs/<name>
git commit -m "chore: update <name> to <version>"
```

No Claude attribution lines in commit messages. Stop after committing and
report each old and new version, plus anything skipped. Push (to main
directly, no PR) only when the user says to; hosts pull from main. Applying
the change (`nixos-rebuild switch` / `darwin-rebuild switch`) is separate, and
only when explicitly asked.
