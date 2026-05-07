{
  # Enable fish
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      shell = "machinectl shell";
      rebuild = "sudo nixos-rebuild switch";
    };
    interactiveShellInit = ''
      set fish_greeting
      function restart
        for machine in $(sudo nixos-container list)
          echo -n "[i] Restarting" $machine " "; and \
          sudo nixos-container restart $machine; and \
          echo ✅
        end
      end
      function build
          echo "Building lemon pound cake recipe..."; and \
          sleep 5; and \
          ffplay -loop 0 -nodisp -volume 80 '/home/uru/netsec/vm/.input' 2&>/dev/null &
          kitten icat '/home/uru/netsec/vm/.config.gif'
      end
    '';
  };
}
