{
  # ...
  services.caddy = {
    enable = true;
    virtualHosts."localhost".extraConfig = ''
      respond "Hello, world!"
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];

}
