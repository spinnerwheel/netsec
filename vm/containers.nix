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
  containers.attacker = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.100/24";
    ephemeral = true;
    bindMounts."/code" = {
      # hostPath = "/home/toms/Documents/unitn/network-security/lab/vm/code";
      hostPath = "/home/uru/netsec/vm/code";
      isReadOnly = true;
    };
    config =
      { pkgs, ... }:
      {

        imports = [
          ./base.nix
        ];

        networking.hostName = "attacker";

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
          ];
        };

        networking.firewall.allowedTCPPortRanges = [
          {
            from = 5000;
            to = 5050;
          }
        ];
        networking.firewall.allowedTCPPorts = [ ];
      };
  };
  containers.infected = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.2/24";
    ephemeral = true;
    config =
      { pkgs, ... }:
      {

        imports = [
          ./base.nix
        ];

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
            shell = "machinectl shell";
          };
        };
        users.users.frank = {
          password = "evil";
          isNormalUser = true;
          # hashedPassword = "$y$j9T$HsTBWdZaRmJlz/tM5lrWa.$hxIAr6jHHPcJw9S9/6opuVFu7/e3ciaWo7oxMZ6c/bC";
          shell = pkgs.fish;
          extraGroups = [ "wheel" ];
          packages = with pkgs; [
            nmap
            netcat
          ];
        };

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

        imports = [
          ./base.nix
        ];

        networking.hostName = "router";

        users.users.frank = {
          isNormalUser = true;
          password = "evil";
          # hashedPassword = "$y$j9T$HsTBWdZaRmJlz/tM5lrWa.$hxIAr6jHHPcJw9S9/6opuVFu7/e3ciaWo7oxMZ6c/bC";
          shell = pkgs.fish;
          packages = with pkgs; [
            nmap
            netcat
          ];
        };

        services.openssh = {
          enable = true;
          banner = "VulNeRablE RouTeR!";
          ports = [ 22 ];
        };

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
          ./base.nix
        ];

        networking.hostName = "camera";

        users.users.frank = {
          isNormalUser = true;
          password = "evil";
          # initialHashedPassword = "$y$j9T$HsTBWdZaRmJlz/tM5lrWa.$hxIAr6jHHPcJw9S9/6opuVFu7/e3ciaWo7oxMZ6c/bC";
          shell = pkgs.fish;
          packages = with pkgs; [
            nmap
            netcat
          ];
        };

        services.telnet = {
          enable = true;
          openFirewall = true;
        };

      };
  };
}
