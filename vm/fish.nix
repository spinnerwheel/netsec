{
  # Enable fish
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      shell = "machinectl shell";
      rebuild = "sudo nixos-rebuild switch";
    };
    # interactiveShellInit = ''
    #   function restart
    #     for machine in $(sudo nixos-container list)
    #       echo -n "[i] Restarting" $machine " "; and \
    #       sudo nixos-container restart $machine; and \
    #       echo ✅
    #     end
    #   end
    # '';
  };
  environment.etc = {
    "fish/functions/restart.fish".text = ''
      function restart
        for machine in $(sudo nixos-container list)
          echo -n "[i] Restarting" $machine " "; and \
          sudo nixos-container restart $machine; and \
          echo ✅
        end
      end
    '';
  };
}
