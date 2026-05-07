{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
    };
  };

  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  environment.systemPackages = with pkgs; [
    btop
    curl
    eza
    fd
    file
    git
    hping
    inetutils
    lsof
    neovim
    python3
    ripgrep
    wget
  ];

  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
