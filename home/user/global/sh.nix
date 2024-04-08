{ pkgs, ... }:
let
  # My shell aliases
  myAliases = {
    # reload system
    rs = "sudo nixos-rebuild switch --flake /home/dave/.dotfiles#system";

    # reload home
    rh = "home-manager switch --flake ~/.dotfiles#user";
    vim="lvim";

# SSH
    ssh="kitten ssh";
    s="ssh";
    exocortex="ssh exocortex";
    exo="exocortex";

# TaskWarrior
    t="task";
    td="task due:eod or +OVERDUE";
    ta="t add";
# tt="t add due:eod";
# tt="taskwarrior-tui";
    tt="vit";
    nm="neomutt";
    rg="rg -i";

# Configs
    zrc="vim ~/.dotfiles/user/shell/sh.nix";
    #	'10rc'="vim ~/.p10k.zsh; source ~/.zshrc";
    als="vim ~/.dotfiles/user/shell/sh.nix";
    #rrc="vim ~/.config/ranger/rc.conf";
    krc="vim ~/.dotfiles/user/app/terminal/kitty/kitty.nix";
    vrc="vim ~/.config/nvim";
    # trc="vim ~/.taskrc";
    src="vim ~/.dotfiles/user/wm/bspwm/sxhkd.nix";
    brc="vim ~/.dotfiles/user/wm/bspwm/bspwm.nix";
    bbrc="vim ~/.dotfiles/user/wm/bspwm/bspwmrc";
    sshc="vim $HOME/.ssh/config";


    lg="lazygit";
    v="vim";
    brclr="git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D";
    m="mpv --no-video";
    y="youtube-dl";
    jrnl=" jrnl";
    mv="mv -vi";
    cp="cp -vir";
    mkdir="mkdir -pv";
    sql="psql -U postgres";
    n="nfunc -e";
    wtf="COLORTERM=xterm-256color /Users/dave/src/programs/wtf/main --config='~/.config/wtf/config.yml'";
    r="ranger_cd";
    yt="ytfzf -ii=anontube.lvkaszus.pl -t --thumb-viewer=kitty -s ";
    ytm="ytfzf -t -m --thumb-viewer=kitty -s";
    ytd="ytfzf -t -d --thumb-viewer=kitty -s";
    nb="newsboat";

# Dotnet
    dn="dotnet new";
    dr="dotnet run";
    dt="dotnet test";
    dw="dotnet watch";
    dwr="dotnet watch run";
    ds="dotnet sln";
    da="dotnet add";
    dp="dotnet pack";
    dng="dotnet nuget";

# ls="gls -lah --color=auto --group-directories-first";
    ls="ls -lah --color=auto";
    l="ls";

    f="flutter";
    fr="flutter run";
    frr="flutter run --release";
    fw="flutter pub run build_runner watch --delete-conflicting-outputs";
    fb="flutter pub run build_runner build --delete-conflicting-outputs";

    blog="cd ~/src/blog && hugo server -D";


    skyrim="mpv --no-video ~/Music/skyrim_winter.webm";
# 1="ping 1.1.1.1";

    k="khal list -o";
    ki="khal interactive";
# c="chatblade";

# TMUX
    tma="tmux attach || tmux new-session";
    tmn="tmux new-session";
    tmd="tmux detach";
    tml="tmux attach-session -t $(tmux list-sessions -F '#S' | fzf --height 50% --reverse)";
    df="duf";
    iscg="jira |  jtbl -n";
    grep="grep --color=always -B 5 -A 5";
    diff="diff --color=always -b";



    nixos-rebuild = "systemd-run --no-ask-password --uid=0 --system --scope -p MemoryLimit=16000M -p CPUQuota=60% nixos-rebuild";
    home-manager = "systemd-run --no-ask-password --uid=1000 --user --scope -p MemoryLimit=16000M -p CPUQuota=60% home-manager";
  };

in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = myAliases;
    zplug = {
	    enable = true;
	    plugins = [
	     { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
	     { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
	    ];
     };

     history.size = 10000000000;
     history.path = "$HOME/.local/share/history";
    initExtra = ''
	[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

         bindkey -e
	bindkey '^ ' autosuggest-accept
	nfunc ()
	{
	   # Block nesting of nnn in subshells
	   if [ -n $NNNLVL ] && [ ''${NNNLVL:-0} -ge 1 ]; then
		echo "nnn is already running"
		return
	   fi

	   export NNN_TMPFILE="$\{XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
	   nnn "$@"
	   # -P p

	   if [ -f "$NNN_TMPFILE" ]; then
		   . "$NNN_TMPFILE"
		   rm -f "$NNN_TMPFILE" > /dev/null
	   fi
	}
	export NNN_PLUG='f:fzcd;o:fzopen;p:preview-tui;z:autojump;c:cbcopy-mac;P:cbpaste-mac;1:ipinfo;b:nbak;C:!cp -rv "$nnn" "$nnn".cp;e:-!sudo -E vim "$nnn"*'
	export NNN_BMS='d:~/Downloads;s:~/src;.:~/.config;b:~/sync;f:~/sync/company;p:/Volumes/23mCTqKq9DMp'
	export NNN_FIFO='/tmp/nnn.fifo'

  export PATH="$PATH:/home/dave/.local/share/JetBrains/Toolbox/scripts:/home/dave/.dotnet/tools"
'';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = myAliases;
  };

  home.packages = with pkgs; [
    bash
  ];

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

   #  programs.fzf = {
   #   enable = true;
   #   enableZshIntegration = true;
   # };

   programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

   programs.git = {
    enable = true;
    userName = "nanocortex";
    userEmail = "nb.dnio6@aleeas.com";
    extraConfig = {
      # credential.helper = "${
      #     pkgs.git.override { withLibsecret = true; }
      #   }/bin/git-credential-libsecret";
      credential.helper = "store";
    };
  };
}
