{ ... }:
{
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # module-x11-bell segfaults in its X IO-error handler whenever Xwayland
    # exits, so every logout and greeter teardown left a pipewire coredump.
    extraConfig.pipewire."10-no-x11-bell"."context.properties"."module.x11.bell" = false;
  };
}
