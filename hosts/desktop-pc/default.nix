{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../common/nixos.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.xorpio = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Niri wayland compositor
  programs.niri.enable = true;

  # Login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${config.programs.niri.package}/bin/niri-session";
        user = "xorpio";
      };
    };
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Networking
  networking.hostName = "desktop-pc";
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Power management (required for Noctalia battery/power widgets)
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Polkit for privilege escalation in GUI apps
  security.polkit.enable = true;

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

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

  programs.firefox.enable = true;

  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    claude-code
    kitty
    fuzzel
    xwayland-satellite
  ];

  home-manager.useGlobalPkgs   = true;
  home-manager.useUserPackages = true;

  home-manager.users.xorpio = import ./home.nix;
}
