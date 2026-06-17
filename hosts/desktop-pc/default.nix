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

  # GNOME desktop
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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
  ];

  home-manager.useGlobalPkgs   = true;
  home-manager.useUserPackages = true;

  home-manager.users.xorpio = import ./home.nix;
}
