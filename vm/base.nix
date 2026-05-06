{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
    };
  };

  environment.systemPackages = with pkgs; [
    btop
    curl
    eza
    fd
    file
    git
    inetutils
    python3
    neovim
    ripgrep
    wget
  ];

  networking.firewall.enable  = false;

  system.stateVersion = "25.11";
}

