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
      let
        pythonEnv = pkgs.python3.withPackages (
          ps: with ps; [
            requests
            flask
          ]
        );
      in
      {

        imports = [
          ./base.nix
        ];

        networking.hostName = "attacker";

        programs.fish = {
          interactiveShellInit = ''
            set fish_greeting
            function force_prompt_colors --on-event fish_prompt
              set -g fish_color_host brred
            end
            function cnc
              python3 /code/cnc/cnc.py
            end
          '';
        };

        users.users.frank = {
          isNormalUser = true;
          hashedPassword = "$y$j9T$2LuJsKeJt2Ry6JNPCxC8f.$p8a1vBbeJmnBP9A5ApGpfM2F9kP5WmGTaJPTfiMOdY0";
          shell = pkgs.fish;
          extraGroups = [ "wheel" ];
          packages = [ pythonEnv ];
        };

        systemd.services = {
          loader = {
            enable = true;
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            description = "Loader service.";
            serviceConfig = {
              Type = "simple";
              User = "frank";
              ExecStart = "${pythonEnv}/bin/python3 /code/loader/loader.py";
            };
          };
          report = {
            enable = true;
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            description = "Report service.";
            serviceConfig = {
              Type = "simple";
              User = "frank";
              ExecStart = "${pythonEnv}/bin/python3 /code/report/report_server.py";
            };
          };

          cnc = {
            enable = true;
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            description = "CNC service.";
            serviceConfig = {
              Type = "simple";
              User = "frank";
              ExecStart = "${pythonEnv}/bin/python3 /code/cnc/cnc.py";
            };
          };

        };
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
          interactiveShellInit = ''
            set fish_greeting
            function force_prompt_colors --on-event fish_prompt
              set -g fish_color_host brblue
            end
          '';
        };
        users.users.admin = {
          isSystemUser = true;
          hashedPassword = "$y$j9T$UnZRcyB4EucC1MNswXVQ5.$PWu3XmGm5LCCTGWXnUjFAO9FojKGJ8KKmXxNwICjwq.";
          shell = pkgs.fish;
          packages = with pkgs; [
            nmap
            netcat
          ];
        };
        users.users.admin.group = "admin";
        users.groups.admin = {};

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

        programs.fish = {
          interactiveShellInit = ''
            set fish_greeting
            function force_prompt_colors --on-event fish_prompt
              set -g fish_color_host brmagenta
            end
          '';
        };

        users.users.bruno = {
          isSystemUser = true;
          hashedPassword = "$y$j9T$BuuG47SDFub.WAPjFOtPD0$SUoyu8RXy4Gc.vtGTiwqP8AQfCBOKySckGP6qFPMbf9";
          shell = pkgs.fish;
          packages = with pkgs; [
            netcat
          ];
        };
        users.users.bruno.group = "bruno";
        users.groups.bruno = {};

        services.openssh = {
          enable = true;
          banner = "VulNeRablE RouTeR!";
          ports = [ 22 ];
          settings.PermitRootLogin = "yes";
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

        programs.fish = {
          interactiveShellInit = ''
            set fish_greeting
            function force_prompt_colors --on-event fish_prompt
              set -g fish_color_host brcyan
            end
          '';
        };

        users.users.root = {
          isSystemUser = true;
          hashedPassword = "$y$j9T$bhnv9Zsbzmd2WDd5p.87J0$FPeSvvnm2DN1CY2j8k2jCSPhtf43mlUNP9OKRvJ56PD";
          shell = pkgs.fish;
          packages = with pkgs; [
            netcat
          ];
        };

        services.telnet.enable = true;
      };
  };

  containers.ecografo = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.5/24";
    ephemeral = true;
    config =
      { pkgs, ... }:
      {
        imports = [
          ./base.nix
        ];

        networking.hostName = "ecografo";

        users.users.root = {
          isSystemUser = true;
          hashedPassword = "$y$j9T$fMnbXS/xwmo5lpn.C3aiE0$xBIWGTQLqbN/GYe2b/yutc1/cFAaRtffZkRaSiTMqT.";
          shell = pkgs.fish;
          packages = with pkgs; [
            netcat
          ];
        };

        services.openssh = {
          enable = true;
          banner = "VulNeRablE EcogRaFo!";
          ports = [ 22 ];
          settings.PermitRootLogin = "yes";
        };
      };
  };

  containers.temperature-sensor = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.6/24";
    ephemeral = true;
    config =
      { pkgs, ... }:
      {

        imports = [
          ./telnet.nix
          ./base.nix
        ];

        networking.hostName = "temperature-sensor";

        users.users.mother = {
          isSystemUser = true;
          hashedPassword = "$y$j9T$AMU56y5A/.QBLGQf7kxzv/$8rYj48hXuKvvRi7xseu/6L4RDCCJaxPG3K27l1Dl3p9";
          shell = pkgs.fish;
          packages = with pkgs; [
            netcat
          ];
        };
        users.users.mother.group = "mother";
        users.groups.mother = {};

        services.telnet.enable = true;
      };
  };
  containers.victim = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.20/24";
    ephemeral = true;
    config =
      { pkgs, ... }:
      {

        imports = [
          ./base.nix
        ];

        networking.hostName = "victim";

        users.users.rosmary = {
          isNormalUser = true;
          hashedPassword = "$y$j9T$WR4q//1AaZ.ZKFvapfqZq1$wp8WgR18qPGaucCjZS2HWL/5OGnCRmyv2rP/9nV8T.2";
          shell = pkgs.fish;
          packages = with pkgs; [
            netcat
            tcpdump
          ];
        };

        # we have to listen on port 80 with a simple website
        # also log all the IPs that come to that port
        services.nginx.enable = true;
      };
  };
}
