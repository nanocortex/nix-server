{
  config,
  inputs,
  pkgs,
  outputs,
  ...
}: {
  imports =
    [
#     inputs.nix-colors.homeManagerModules.default
#     ./atuin.nix
#     ./bat.nix
#     ./bottom.nix
#     ./calendar.nix
#     ./direnv.nix
#     ./eza.nix
     ./sh.nix
#     ./font.nix
     ./fzf.nix
     ./git.nix
#     ./helix.nix
#     ./jq.nix
#     ./kitty.nix
#     ./mime.nix
#     ./nix-index.nix
#     ./nvim
#     ./rclone.nix
#     ./starship.nix
#     ./xdg.nix
#     ./yazi.nix
     ./zoxide.nix
    ];

#  colorScheme = inputs.nix-colors.colorSchemes.selenized-light;

  home = {
    username = "user";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "23.11";

    sessionVariables = {
      EDITOR = "lvim";
    };
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  # systemd.user.startServices = "sd-switch";
}
