{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    # (modulesPath + "/profiles/minimal.nix")
    # (modulesPath + "/virtualisation/virtualbox-image.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
    ./gnome.nix
    ./containers.nix
  ];

  networking.networkmanager.enable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };
  console.keyMap = "it2";

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, user) {
            if (action.id == "org.freedesktop.machine1.shell" &&
                    user.isInGroup("wheel")) {
            return polkit.Result.YES;
            }
            });
  '';

  nixpkgs.config.allowUnfree = true;

  # Fonts.
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

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
  ];

  # Enable fish
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
    };
  };

  # Users
  users.users.uru = {
    isNormalUser = true;
    description = "uru";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPassword = "$y$j9T$VMGR9TgGlMD8iL5lcJQdT.$fAO6tp2McJA328.Bf9ttnqONp.GJYl/VZhvSh3P8A./";
    packages = with pkgs; [
      kitty
      eza
      tmux
    ];
    shell = pkgs.fish;
  };

  # VirtualBox configurations
  virtualisation.virtualbox.guest.enable = true;

  virtualisation.vmVariant = {
    # the following configuration is added only when building VM with `build-vm`
    virtualisation = {
      memorySize = 2048; # use 2048MiB memory
      cores = 4; # use 4 cpu cores
    };
  };

  # Detects files in the store that have identical contents,
  # and replaces them with hard links to a single copy.
  nix.settings.auto-optimise-store = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
