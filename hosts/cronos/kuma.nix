# Auto-generated using compose2nix v0.1.9.
{ pkgs, lib, ... }:

{
  # Runtime

  services.caddy.virtualHosts."testkuma.exocortex.in" = {
    useACMEHost = "exocortex.in";
    #forceSSL = true;
    # locations."/".proxyPass = "http://${host}";
    extraConfig = "reverse_proxy http://localhost:3001";
  };

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."kuma" = {
    image = "louislam/uptime-kuma:1";
    environment = {
      TZ = "Europe/Warsaw";
    };
    volumes = [
      "/var/lib/kuma:/app/data:rw"
    ];
    ports = [
      "3001:3001/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--dns=1.1.1.1"
      "--dns=8.8.8.8"
      "--network-alias=kuma"
      "--network=kuma_default"
    ];
  };
  systemd.services."podman-kuma" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-kuma_default.service"
    ];
    requires = [
      "podman-network-kuma_default.service"
    ];
    partOf = [
      "podman-compose-kuma-root.target"
    ];
    wantedBy = [
      "podman-compose-kuma-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-kuma_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f kuma_default";
    };
    script = ''
      podman network inspect kuma_default || podman network create kuma_default
    '';
    partOf = [ "podman-compose-kuma-root.target" ];
    wantedBy = [ "podman-compose-kuma-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-kuma-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}