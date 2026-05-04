{ config, pkgs, ... }:
{
  boot.enableContainers = true;
  virtualisation.containers.enable = true;

  networking = {
    bridges.br0.interfaces = [ ];
    interfaces."br0".useDHCP = false;
    interfaces."br0".ipv4.addresses = [
      {
        address = "10.10.10.1";
        prefixLength = 24;
      }
    ];
  };
  # networking.firewall.trustedInterfaces = [ "br0" ];
  containers.attacker = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.100/24";
    # hostAddress = "10.10.10.1";
    # localAddress = "10.10.10.2";
    ephemeral = true;
    # privateUsers = "pick";
    # Bind local dirs
    bindMounts."/tmp/code" = {
      hostPath = "/home/toms/Documents/unitn/network-security/lab/vm/code";
      isReadOnly = true;
    };
    config =
      { pkgs, ... }:
      {
        networking.hostName = "attacker";

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
        users.users.frank = {
          password = "evil";
          isNormalUser = true;
          # hashedPassword = "$y$j9T$HsTBWdZaRmJlz/tM5lrWa.$hxIAr6jHHPcJw9S9/6opuVFu7/e3ciaWo7oxMZ6c/bC";
          shell = pkgs.fish;
          extraGroups = [ "wheel" ];
          packages = with pkgs; [
            (python3.withPackages (
              python-pkgs: with python-pkgs; [
                requests
                flask
              ]
            ))
            # python313Packages.flask
            # python313Packages.requests

          ];
        };
        environment.systemPackages = with pkgs; [
          neovim
          wget
          curl
          git
          ripgrep
          fd
          btop
          inetutils
          file
          eza
        ];

        networking.firewall.allowedTCPPortRanges = [
          {
            from = 5000;
            to = 5050;
          }
        ];
        networking.firewall.allowedTCPPorts = [ ];

        system.stateVersion = "25.11";
      };
  };
  containers.infected = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.2/24";
    # hostAddress = "10.10.10.1";
    # localAddress = "10.10.10.2";
    ephemeral = true;
    # privateUsers = "pick";
    config =
      { pkgs, ... }:
      {
        networking.hostName = "infected";

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
        users.users.frank = {
          password = "evil";
          isNormalUser = true;
          # hashedPassword = "$y$j9T$HsTBWdZaRmJlz/tM5lrWa.$hxIAr6jHHPcJw9S9/6opuVFu7/e3ciaWo7oxMZ6c/bC";
          shell = pkgs.fish;
          extraGroups = [ "wheel" ];
        };
        environment.systemPackages = with pkgs; [
          neovim
          wget
          curl
          git
          ripgrep
          fd
          btop
          inetutils
          file
          eza
          nmap
          netcat
        ];

        system.stateVersion = "25.11";
      };
  };
  containers.router = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.3/24";
    ephemeral = true;
    config =
      { pkgs, ... }:
      {
        networking.hostName = "router";

        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            set fish_greeting
            function force_prompt_colors --on-event fish_prompt
            set -g fish_color_host brblue
            end
          '';
          shellAliases = {
            ls = "eza";
          };
        };
        users.users.frank = {
          isNormalUser = true;
          password = "evil";
          # hashedPassword = "$y$j9T$HsTBWdZaRmJlz/tM5lrWa.$hxIAr6jHHPcJw9S9/6opuVFu7/e3ciaWo7oxMZ6c/bC";
          shell = pkgs.fish;
        };
        environment.systemPackages = with pkgs; [
          neovim
          wget
          curl
          git
          ripgrep
          fd
          btop
          inetutils
          file
          eza
          nmap
          netcat
        ];

        services.openssh = {
          enable = true;
          banner = "VulNeRablE RouTeR!";
          ports = [ 22 ];
        };

        system.stateVersion = "25.11";
      };
  };
  containers.camera = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.4/24";
    ephemeral = true;
    config =
      { pkgs, ... }:
      {

        imports = [
          ./telnet.nix
        ];
        networking.hostName = "camera";

        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            set fish_greeting
            function force_prompt_colors --on-event fish_prompt
            set -g fish_color_host brblue
            end
          '';
          shellAliases = {
            ls = "eza";
          };
        };

        users.users.frank = {
          isNormalUser = true;
          password = "evil";
          # initialHashedPassword = "$y$j9T$HsTBWdZaRmJlz/tM5lrWa.$hxIAr6jHHPcJw9S9/6opuVFu7/e3ciaWo7oxMZ6c/bC";
          shell = pkgs.fish;
        };
        environment.systemPackages = with pkgs; [
          neovim
          curl
          git
          ripgrep
          fd
          btop
          eza
          netcat
        ];

        # programs.neovim = {
        #   enable = true;
        #   configure = {
        #     # customLuaRc = '''';
        #     packages.myVimPackage = with pkgs.vimPlugins; {
        #         start = [ lualine-nvim gruvbox-nvim ];
        #         opt = [ ];
        #     };
        #   };
        # };

        services.telnet.enable = true;
        services.telnet.openFirewall = true;

        system.stateVersion = "25.11";
      };
  };
}
