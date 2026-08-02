---
name: update-claude-overlay
description: Use when asked to update Claude Code, bump the claude-code overlay, or pick up a new Claude Code release in this repo.
---

# Update Claude Code Overlay

Claude Code comes from the `claude-code-overlay` flake input
(github:ryoppippi/claude-code-overlay), applied in `commonOverlays` in
flake.nix. Updating means bumping that input's entry in flake.lock.

## Steps

1. Capture the current version, then update the input:

   ```bash
   oldrev=$(jq -r '.nodes."claude-code-overlay".locked.rev' flake.lock)
   old=$(nix eval --raw "github:ryoppippi/claude-code-overlay/$oldrev#default.version")
   nix flake update claude-code-overlay
   ```

   If `git diff --quiet flake.lock` reports no change, the input is already
   current — report that and stop.

2. Get the new version:

   ```bash
   rev=$(jq -r '.nodes."claude-code-overlay".locked.rev' flake.lock)
   version=$(nix eval --raw "github:ryoppippi/claude-code-overlay/$rev#default.version")
   ```

   The overlay repo advances more often than claude-code releases. If
   `$version` equals `$old`, there is no new Claude Code — revert with
   `git checkout flake.lock`, report "claude-code is still at $version",
   and stop. Don't commit lock churn.

3. Sanity-build before pushing (hosts pull from main):

   ```bash
   nix build --no-link "github:ryoppippi/claude-code-overlay/$rev#default"
   ```

   First run may fetch ~300 MiB of build deps and compile from source — this
   is the same build `switch` would do, so it isn't wasted.

4. Commit only flake.lock and push to main directly (no PR):

   ```bash
   git add flake.lock
   git commit -m "chore: update claude-code overlay to $version"
   git push
   ```

   No Claude attribution lines in the commit message.

5. Applying it (`darwin-rebuild switch` / `nixos-rebuild switch`) is separate —
   only do it if explicitly asked.
