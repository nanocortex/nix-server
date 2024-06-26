{
  # virtualisation.docker = {
  #   enable = true;
  # };
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

}
