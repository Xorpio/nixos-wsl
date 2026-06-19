{ ... }:
{
  my.nixosModules.niri = { config, ... }: {
    programs.niri.enable = true;

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${config.programs.niri.package}/bin/niri-session";
        user    = "xorpio";
      };
    };

    # Unlock gnome-keyring on greetd login
    security.pam.services.greetd.enableGnomeKeyring = true;
  };

  my.homeModules.niri = { ... }: {
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
        Mod+Shift+Slash { show-hotkey-overlay; }

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

        //View offset
        Mod+Ctrl+Left { view-offset-left; }
        Mod+Ctrl+Right { view-offset-right; }
      }
    '';
  };
}
