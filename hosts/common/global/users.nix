{
  pkgs,
  config,
  ...
}: {
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  users = {
    mutableUsers = false;
    users = {

      #users.mutableUsers = false;
      user = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" ];

        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIED8axnZzZk5P39CEbMeJZy42o/4T0iHgr1pefNDsnU5 ex0cortex@pm.me" ];
        # hashedPasswordFile = "/persist/passwords/user";
        initialHashedPassword = "$y$j9T$rNk8TYxg0R8LfzTXgxQBO.$tWP7r0wCIAnL9dAGLWeO4/eCEfONkAGTKmYJ7sRVYv9";
      };

    };
  };

  # home-manager.users.user = import ../../../home/user/home/${config.networking.hostName}.nix;
  home-manager.users.user = import ../../../home/user/cronos.nix;

}
