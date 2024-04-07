
{pkgs, ...}: {
  imports = [
  ];

  services.openssh = {
    enable = true;
    allowSFTP = false; # Don't set this if you need sftp
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;

    };
  };

  networking.firewall = {
    allowedTCPPorts = [22];
  };

}
