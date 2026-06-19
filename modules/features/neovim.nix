{ ... }:
{
  my.homeModules.neovim = { pkgs, ... }: {
    programs.nvf = {
      enable        = true;
      defaultEditor = true;

      settings.vim = {
        vimAlias = true;
        viAlias  = true;

        startPlugins = with pkgs.vimPlugins; [
          plenary-nvim
          vim-nix
        ];

        options = {
          number         = true;
          relativenumber = false;
          tabstop        = 2;
          shiftwidth     = 2;
          expandtab      = true;
          smartindent    = true;
          ignorecase     = true;
          smartcase      = true;
          hlsearch       = true;
          incsearch      = true;
          termguicolors  = true;
          scrolloff      = 8;
          wrap           = true;
          linebreak      = true;
          signcolumn     = "yes";
          clipboard      = "unnamedplus";
          swapfile       = false;
          backup         = false;
          updatetime     = 250;
          mouse          = "";
          list           = true;
          listchars      = "tab:→ ,space:·,trail:·,extends:>,precedes:<";
        };
      };
    };
  };
}
