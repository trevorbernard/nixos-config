{ pkgs, ... }:
let
  buildkitePreBootstrap = pkgs.writeScript "buildkite-pre-bootstrap" ''
    #! /bin/sh
    set -e
    if [ -z $BUILDKITE_ENV_FILE ]; then
      echo "No BUILDKITE_ENV_FILE variable set. Env:"
      env
    fi
  '';

  buildkiteLaunch = pkgs.writeScript "buildkite-agent-launch" ''
    #!/bin/sh
    set -eu
    export BUILDKITE_AGENT_TOKEN="$(cat /run/keys/buildkite-agent-token)"
    buildkite-agent start --config "$HOME"/buildkite-agent.cfg
  '';

  hooksPath = pkgs.runCommandLocal "buildkite-agent-hooks" { } ''
    mkdir $out

    ln -s ${buildkitePreBootstrap} $out/pre-bootstrap

    cat > $out/pre-checkout << EOF
    BUILDKITE_GIT_CLEAN_FLAGS='-ffdx'
    export BUILDKITE_GIT_CLEAN_FLAGS
    EOF
  '';

in
{
  systemd.services.buildkite-agent = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      HOME = "/home/bk";
    };
    path = [
      pkgs.buildkite-agent
      "/etc/profiles/per-user/bk"
      "/run/current-system/sw"
    ];
    preStart = ''
      set -u
      cat > "$HOME/buildkite-agent.cfg" <<EOF
      name="knowhere-agent-%spawn"
      spawn=5
      priority=50
      tags="production=false,nix=true,docker=true,os-kernel=linux,os-family=nixos,os-variant=nixos,xwindows=false"
      build-path="$HOME/builds"
      plugins-path="$HOME/plugins"
      hooks-path="${hooksPath}"
      EOF
    '';
    serviceConfig = {
      User = "bk";
      Group = "keys";
      SupplementaryGroups = "docker";
      ExecStart = buildkiteLaunch;
      RestartSec = 5;
      Restart = "on-failure";
      TimeoutSec = 10;
      TimeoutStopSec = "2 min";
      KillMode = "mixed";
    };
  };

  users.users.bk = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      "docker"
      "keys"
    ];
    shell = pkgs.bash;
    packages = [ pkgs.buildkite-agent ];
  };
}
