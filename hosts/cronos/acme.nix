{config, ...}: {
  # Enable acme for usage with nginx vhosts
  security.acme = {
    defaults.email = "ex0cortex@pm.me";
    acceptTerms = true;


    certs."exocortex.in" = {
      domain = "*.exocortex.in";
      dnsProvider = "njalla";
      dnsPropagationCheck = true;
      credentialsFile = config.sops.secrets.njallaDns.path;
    };
  };

  # environment.persistence = {
  #   "/persist".directories = ["/var/lib/acme"];
  # };

  sops.secrets.njallaDns = {
    sopsFile = ./secrets.yaml;
  };

  #users.users.nginx.extraGroups = ["acme"];
  users.users.caddy.extraGroups = ["acme"];

}
