{ outputs, config, ...}:
{
  imports = [
    outputs.nixosModules.tailscale-autoconnect
  ];

  services.tailscaleAutoconnect = {
    enable = true;
    authkeyFile = config.sops.secrets.tailscale_key.path;
    loginServer = "https://login.tailscale.com";
   # exitNode = "some-node-id";
#    exitNodeAllowLanAccess = true;
  };

  sops.secrets.tailscale_key = {
    sopsFile = ../secrets.yaml;
  };

  # environment.persistence = {
  #   "/persist".directories = ["/var/lib/tailscale"];
  # };
}
