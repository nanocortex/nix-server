{config, ...}: let
  host = "localhost:8080";
in {
  services.freshrss = {
    enable = true;
    authType = "none";
    baseUrl = "https://freshrss.exocortex.in";
    dataDir = "/var/lib/freshrss";
    user = "freshrss";

    # config = {
    #   LISTEN_ADDR = host;
    # };
    # adminCredentialsFile = config.sops.secrets.minifluxEnv.path;
  };

  services.nginx.virtualHosts."freshrss.exocortex.in" = {
    useACMEHost = "exocortex.in";
    forceSSL = false;
    # locations."/".proxyPass = "http://${host}";
  };

  # environment.var.lib.private."/freshrss" = {
  #   directories = [
  #     {
  #       directory = "/var/lib/private/freshrss";
  #       mode = "0750";
  #       user = "freshrss";
  #       group = "freshrss";
  #     }
  #   ];
  # };

  users.users.freshrss = {
    isSystemUser = true;
    group = "freshrss";
  };

  users.groups.freshrss = {};

  systemd.tmpfiles.rules = [
    "d /var/lib/freshrss 0770 freshrss freshrss -"
  ];


  # sops.secrets.minifluxEnv = {
  #   sopsFile = ./secrets.yaml;
  # };
}
