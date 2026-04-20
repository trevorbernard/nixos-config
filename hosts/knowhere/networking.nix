{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    "Wired connection 1" = {
      connection = {
        id = "Wired connection 1";
        type = "ethernet";
        interface-name = "eno1";
        autoconnect = "true";
        permissions = "";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };

  services.tailscale.enable = true;

  services.syncthing = {
    enable = true;
    user = "tbernard";
    dataDir = "/home/tbernard";
    settings = {
      options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
      };
      devices = {
        "macbook-pro" = {
          id = "MD5DF3C-DKWSXWZ-YSJMJ5N-TB2HQWW-L3RYVK2-VIS6JHK-RVHFCHZ-WSA2NQH";
          addresses = [ "tcp://macbook-pro.tailb5107e.ts.net:22000" ];
        };
        "iphone-14-pro-max" = {
          id = "U4P5FMV-77L2A5M-YIA6FQX-LWTZZUL-TKHZ5TT-CUATEER-ILOWE3U-YHBS5QB";
          addresses = [ "tcp://iphone-14-pro-max.tailb5107e.ts.net:22000" ];
        };
      };
      folders = {
        "keepass" = {
          path = "/home/tbernard/Sync/keepass";
          devices = [ "macbook-pro" "iphone-14-pro-max" ];
        };
        "documents" = {
          path = "/home/tbernard/Sync/documents";
          devices = [ "macbook-pro" ];
        };
      };
    };
  };

  networking.firewall = {
    interfaces."eno1" = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };
    interfaces."tailscale0" = {
      allowedTCPPorts = [ 22 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };
  };
}
