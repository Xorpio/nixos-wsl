{ ... }:
{
  my.homeModules.vscode = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          vscodevim.vim
        ];
        userSettings = {
          "editor.fontSize"    = 11;
          "editor.fontFamily"  = "fira code";
          "nix.enableLanguageServer" = true;
        };
      };
    };
  };
}
