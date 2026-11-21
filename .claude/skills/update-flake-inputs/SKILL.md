---
name: update-flake-inputs
description: Use when asked to update, bump, or check for new releases of a tag-pinned flake input (termcopy, tumbler, hunk, herdr, tuicr) or of rex in this repo.
---

# Update Flake Inputs

Covers the inputs a bare `nix flake update` cannot move, plus rex.

| Input | Source | Pinned by |
|---|---|---|
| termcopy, tumbler | github:trevorbernard/… | release tag in the flake.nix URL |
| hunk | github:modem-dev/hunk | release tag in the flake.nix URL |
| herdr | github:ogulcancelik/herdr | release tag in the flake.nix URL |
| tuicr | github:agavra/tuicr | release tag in the flake.nix URL |
| rex | pkgs.superlogical.com | `preview` channel tarball |

Not covered here:

- `claude-code-overlay`: use the update-claude-overlay skill.
- `nixpkgs`, `nixpkgs-unstable`, `nix-darwin`: whole-system updates. Only on an
  explicit ask, with `nix flake update <name>`.
- Packages under `pkgs/`: use the update-local-packages skill.

## Tag-pinned inputs

1. List what is behind:

   ```bash
   for i in termcopy tumbler hunk herdr tuicr; do
     cur=$(grep -oE "github:[^/]+/$i/v[0-9.]+" flake.nix)
     repo=${cur#github:}; repo=${repo%/v*}
     new=$(gh api "repos/$repo/releases/latest" --jq .tag_name)
     echo "$i ${cur##*/} -> $new"
   done
   ```

   `releases/latest` skips drafts and pre-releases. If `gh` is not
   authenticated, use
   `git ls-remote --tags --refs --sort=-v:refname https://github.com/$repo | head -1`
   and ignore pre-release tags by eye.

   If nothing is behind, report that and stop.

2. Do one input at a time. Edit its tag in the flake.nix URL, then refresh the
   lock entry:

   ```bash
   nix flake update <input>
   ```

3. Build it through the host config, so the `follows = "nixpkgs"` wiring is
   what gets tested, then run it once:

   ```bash
   # knowhere; on a Mac use .#darwinConfigurations.<aypa|macbook>.pkgs.<input>
   out=$(nix build --no-link --print-out-paths ".#nixosConfigurations.knowhere.pkgs.<input>")
   ls "$out/bin"
   ```

   Every one of these inputs follows this flake's nixpkgs. If the new release
   needs a newer toolchain than nixos-26.05 ships (typically a rustc version
   error), do not drop the `follows` or pull from unstable on your own. Revert
   with `git checkout flake.nix flake.lock`, report the error, and let the
   user decide. The atuin comment in flake.nix is the precedent.

4. Commit flake.nix and flake.lock, one commit per input, version without the
   leading `v`:

   ```bash
   git add flake.nix flake.lock
   git commit -m "chore: update <input> to <version>"
   ```

## rex

rex has no tag to edit; the channel tarball redirects to the newest preview.
Fetching it needs the token in `/etc/nix/netrc` (README, "Prerequisites").

1. Update and compare:

   ```bash
   old=$(jq -r '.nodes.rex.locked.url' flake.lock)
   nix flake update rex
   new=$(jq -r '.nodes.rex.locked.url' flake.lock)
   ```

   The version is the file name in the URL
   (`…/preview/0.1.0-preview.22.tar.gz`). If `$new` equals `$old`, report
   "rex is still at <version>" and stop; there is nothing to commit.

2. rex is a NixOS module used only by knowhere, so build that system. On a
   Mac, evaluate it instead (append `.drvPath` and use `nix eval --raw`).

   ```bash
   nix build --no-link '.#nixosConfigurations.knowhere.config.system.build.toplevel'
   ```

3. Commit only flake.lock:

   ```bash
   git add flake.lock
   git commit -m "chore: update rex to <version>"
   ```

   If the superlogical MCP server is available, its "Server & CLI" changelog
   says what changed; include a one-line summary in the report.

## Finishing

No Claude attribution lines in commit messages. Stop after committing and
report each old and new version. Push (to main directly, no PR) only when the
user says to; hosts pull from main. Applying the change
(`nixos-rebuild switch` / `darwin-rebuild switch`) is separate, and only when
explicitly asked.
