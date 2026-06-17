{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
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

  time.timeZone = "Europe/Amsterdam";

  programs.zsh.enable = true;

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    home-manager
    sops
  ];

  home-manager.useGlobalPkgs   = true;
  home-manager.useUserPackages = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";

  home-manager.users.xorpio = import ./home.nix;
}
