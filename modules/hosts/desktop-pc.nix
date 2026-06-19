{ config, inputs, ... }:
let
  homeModules  = config.my.homeModules;
  nixosModules = config.my.nixosModules;
in
{
  flake.nixosConfigurations.desktop-pc = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./hardware/desktop-pc.nix
      inputs.home-manager-unstable.nixosModules.home-manager
      inputs.noctalia.nixosModules.default
      nixosModules.common

      ({ config, pkgs, ... }: {
        boot.loader.systemd-boot.enable      = true;
        boot.loader.efi.canTouchEfiVariables = true;

        users.users.xorpio = {
          isNormalUser = true;
          shell        = pkgs.zsh;
          extraGroups  = [ "wheel" "networkmanager" "video" "audio" ];
        };

        programs.niri.enable = true;

        services.greetd = {
          enable = true;
          settings.default_session = {
            command = "${config.programs.niri.package}/bin/niri-session";
            user    = "xorpio";
          };
        };

        services.xserver.xkb = {
          layout  = "us";
          variant = "";
        };

        services.pulseaudio.enable = false;
        security.rtkit.enable     = true;
        services.pipewire = {
          enable            = true;
          alsa.enable       = true;
          alsa.support32Bit = true;
          pulse.enable      = true;
        };

        networking.hostName            = "desktop-pc";
        networking.networkmanager.enable = true;

        hardware.bluetooth.enable = true;
        services.blueman.enable   = true;

        services.upower.enable                = true;
        services.power-profiles-daemon.enable = true;

        security.polkit.enable = true;

        services.gnome.gnome-keyring.enable       = true;
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

        programs.firefox.enable    = true;
        services.printing.enable   = true;
        services.gvfs.enable       = true;

        nixpkgs.config.allowUnfree = true;

        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia = {
          modesetting.enable = true;
          open               = false;
          nvidiaSettings     = true;
          package            = config.boot.kernelPackages.nvidiaPackages.stable;
        };
        hardware.graphics.enable = true;

        environment.systemPackages = with pkgs; [
          claude-code
          kitty
          fuzzel
          xwayland-satellite
        ];

        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.nvf.homeManagerModules.default
          inputs.noctalia.homeModules.default
        ];

        home-manager.users.xorpio = {
          imports = [
            homeModules.common
            homeModules.git
            homeModules.neovim
            homeModules.taskwarrior
          ];

          home.username      = "xorpio";
          home.homeDirectory = "/home/xorpio";

          my.git = {
            userName  = "Xorpio";
            userEmail = "3060868+Xorpio@users.noreply.github.com";
          };

          sops = {
            age.keyFile              = "/home/xorpio/.config/sops/age/keys.txt";
            defaultSopsFile          = ../../secrets/machines/desktop-pc/taskwarrior.yaml;
            defaultSopsFormat        = "yaml";
            defaultSymlinkPath       = "/run/user/1000/secrets";
            defaultSecretsMountPoint = "/run/user/1000/secrets.d";
            secrets."sync_server_url".path               = "/run/user/1000/secrets/sync_server_url";
            secrets."sync_server_client_id".path         = "/run/user/1000/secrets/sync_server_client_id";
            secrets."sync_server_encryption_secret".path = "/run/user/1000/secrets/sync_server_encryption_secret";
          };

          home.shellAliases = {
            rebuild = "sudo nixos-rebuild switch --flake ~/nixos-wsl#desktop-pc";
            hm      = "sudo nixos-rebuild switch --flake ~/nixos-wsl#desktop-pc";
          };

          xdg.configFile."niri/config.kdl".text = ''
            spawn-at-startup "noctalia-shell"
            spawn-at-startup "xwayland-satellite"

            input {
              keyboard {
                xkb {
                  layout "us"
                }
              }

              touchpad {
                tap
                natural-scroll
              }
            }

            layout {
              gaps 8

              default-column-width { proportion 0.3333; }

              focus-ring {
                width 2
                active-color "#89b4fa"
                inactive-color "#45475a"
              }
            }

            binds {
              // Terminal and launcher
              Mod+Return { spawn "kitty"; }
              Mod+D { spawn "fuzzel"; }
              Mod+Shift+E { quit; }
              Mod+Q { close-window; }

              // Focus movement
              Mod+H { focus-column-left; }
              Mod+J { focus-window-down; }
              Mod+K { focus-window-up; }
              Mod+L { focus-column-right; }
              Mod+Left  { focus-column-left; }
              Mod+Down  { focus-window-down; }
              Mod+Up    { focus-window-up; }
              Mod+Right { focus-column-right; }

              // Move windows
              Mod+Shift+H { move-column-left; }
              Mod+Shift+J { move-window-down; }
              Mod+Shift+K { move-window-up; }
              Mod+Shift+L { move-column-right; }
              Mod+Shift+Left  { move-column-left; }
              Mod+Shift+Down  { move-window-down; }
              Mod+Shift+Up    { move-window-up; }
              Mod+Shift+Right { move-column-right; }

              // Workspaces
              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+Shift+5 { move-column-to-workspace 5; }
              Mod+Shift+6 { move-column-to-workspace 6; }
              Mod+Shift+7 { move-column-to-workspace 7; }
              Mod+Shift+8 { move-column-to-workspace 8; }
              Mod+Shift+9 { move-column-to-workspace 9; }

              Mod+Tab       { focus-workspace-down; }
              Mod+Shift+Tab { focus-workspace-up; }

              // Window sizing
              Mod+R { switch-preset-column-width; }
              Mod+F { maximize-column; }
              Mod+Shift+F { fullscreen-window; }
              Mod+C { center-column; }
              Mod+Minus { set-column-width "-10%"; }
              Mod+Equal { set-column-width "+10%"; }

              // Screenshots
              Print { screenshot; }
              Ctrl+Print { screenshot-screen; }
              Alt+Print { screenshot-window; }

              // Monitor focus
              Mod+Shift+P { power-off-monitors; }
            }
          '';

          home.packages = with pkgs; [
            nautilus
          ];

          programs.noctalia-shell.enable = true;
        };
      })
    ];
  };
}
