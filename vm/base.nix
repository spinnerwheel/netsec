{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      function force_prompt_colors --on-event fish_prompt
      set -g fish_color_host brred
      end
    '';
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
  ];

  networking.firewall.enable  = false;

  system.stateVersion = "25.11";
}

