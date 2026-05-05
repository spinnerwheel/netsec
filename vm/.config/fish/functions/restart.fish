function restart
    for machine in $(sudo nixos-container list)
        echo -n "[i] Restarting" $machine " "
        sudo nixos-container restart $machine
        echo ✅
    end
end
