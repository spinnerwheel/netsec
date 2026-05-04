{ pkgs, ... }:
{

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # services.gnome.core-apps.enable = true;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    geary
    baobab
    decibels
    epiphany
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-console
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-system-monitor
    gnome-weather
    loupe
    # nautilus
    papers
    gnome-connections
    showtime
    simple-scan
    snapshot
    yelp
  ];
}
