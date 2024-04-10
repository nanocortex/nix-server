{
  # ...
  services.caddy = {
    enable = true;
    virtualHosts."freshrss.exocortex.in".extraConfig = ''
      respond "Hello, world!"
    '';
    virtualHosts."freshrss.exocortex.in".useACMEHost = "exocortex.in";
  };

  networking.firewall.allowedTCPPorts = [80 443];

}
