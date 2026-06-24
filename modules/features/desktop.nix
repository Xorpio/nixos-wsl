{ ... }:
{
  my.nixosModules.desktop = { pkgs, ... }: {
    hardware.bluetooth.enable = true;
    services.blueman.enable   = true;

    services.upower.enable                = true;
    services.power-profiles-daemon.enable = true;

    security.polkit.enable              = true;
    services.gnome.gnome-keyring.enable = true;

    programs.firefox.enable  = true;
    services.printing.enable = true;
    services.gvfs.enable     = true;

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS        = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
      LC_MEASUREMENT    = "nl_NL.UTF-8";
      LC_MONETARY       = "nl_NL.UTF-8";
      LC_NAME           = "nl_NL.UTF-8";
      LC_NUMERIC        = "nl_NL.UTF-8";
      LC_PAPER          = "nl_NL.UTF-8";
      LC_TELEPHONE      = "nl_NL.UTF-8";
      LC_TIME           = "nl_NL.UTF-8";
    };

  };

  my.homeModules.desktop = { pkgs, ... }: {
    programs.noctalia-shell.enable = true;

    home.packages = with pkgs; [
      nautilus
      dropbox
      obsidian
      slack
      keepassxc
      thunderbird
      prusa-slicer
      playerctl
      spotify
      k9s
      flux9s
      kubectl
      btop
      fluxcd
    ];
  };
}
