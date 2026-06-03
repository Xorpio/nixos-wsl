{ config, options, lib, pkgs, ... }:

with lib;

{
  options.modules.dev-tools = {
    enable = mkEnableOption "Development tools (git, curl, wget, jq, ripgrep, fd, eza, bat, etc.)";

    includeCore = mkOption {
      type = types.bool;
      default = true;
      description = "Include core tools (git, curl, wget)";
    };

    includeSearch = mkOption {
      type = types.bool;
      default = true;
      description = "Include search tools (ripgrep, fd, jq)";
    };

    includeLs = mkOption {
      type = types.bool;
      default = true;
      description = "Include modern ls replacement (eza or exa)";
    };

    includeViewers = mkOption {
      type = types.bool;
      default = true;
      description = "Include file viewers (bat, less, man-pages)";
    };

    tools = mkOption {
      type = types.listOf types.package;
      default = with pkgs;
        optionals config.modules.dev-tools.includeCore [
          git
          curl
          wget
        ]
        ++ optionals config.modules.dev-tools.includeSearch [
          ripgrep
          fd
          jq
        ]
        ++ optionals config.modules.dev-tools.includeLs [
          eza # Modern replacement for ls/exa
        ]
        ++ optionals config.modules.dev-tools.includeViewers [
          bat
          less
          man-pages
        ];
      description = "List of development tools to install";
    };

    additionalTools = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional tools to include (for machine-specific additions)";
    };

    enableAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable convenient aliases for dev tools";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = mkIf config.modules.dev-tools.enableAliases {
        # eza aliases (modern ls replacement)
        ls = "eza";
        la = "eza -la";
        ll = "eza -lah";
        tree = "eza --tree";

        # Useful shortcuts
        cat = "bat";
        grep = "rg";
      };
      description = "Aliases for dev tools";
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {
        # Make bat use colors for piped output
        BAT_THEME = "gruvbox-dark";
        BAT_STYLE = "auto";

        # Use less as pager for various tools
        PAGER = "less -R";

        # ripgrep settings
        RIPGREP_CONFIG_PATH = "~/.ripgreprc";
      };
      description = "Environment variables for dev tools";
    };

    batTheme = mkOption {
      type = types.str;
      default = "gruvbox-dark";
      description = "Theme to use for bat (syntax highlighting)";
    };
  };

  config = mkIf config.modules.dev-tools.enable {
    # Install all tools and additional tools
    home.packages = config.modules.dev-tools.tools ++ config.modules.dev-tools.additionalTools;

    # Set up aliases if enabled
    home.shellAliases = mkIf config.modules.dev-tools.enableAliases config.modules.dev-tools.aliases;

    # Set up environment variables
    home.sessionVariables = config.modules.dev-tools.environmentVariables;

    # Configure bat if it's included
    programs.bat = mkIf (elem pkgs.bat config.modules.dev-tools.tools) {
      enable = true;
      config = {
        theme = config.modules.dev-tools.batTheme;
        style = "auto";
      };
    };

    # Configure ripgrep if it's included
    # Note: home-manager ripgrep module only supports enable/disable and package
    # Configuration is done via RIPGREP_CONFIG_PATH and .ripgreprc file instead

    # Set up ripgrep config file for environment variable
    home.file.".ripgreprc" = mkIf (elem pkgs.ripgrep config.modules.dev-tools.tools) {
      text = ''
        # ripgrep configuration
        --max-columns=200
        --colors=line:fg:yellow
        --smart-case
        --follow
      '';
    };

    # Configure fd if it's included
    home.file.".fdrc" = mkIf (elem pkgs.fd config.modules.dev-tools.tools) {
      text = ''
        # fd configuration
        --hidden
        --follow
        --exclude .git
        --exclude target
        --exclude node_modules
      '';
    };

    # Create a helpful note about these tools
    home.file.".config/dev-tools-installed.txt" = {
      text = ''
        Development Tools Installed
        ============================
        
        Core Tools:
        - git: version control
        - curl: command-line HTTP client
        - wget: file downloader
        
        Search & Query:
        - ripgrep (rg): fast recursive grep
        - fd: fast find alternative
        - jq: JSON query tool
        
        File Operations:
        - eza: modern ls replacement
        - bat: fancy cat with syntax highlighting
        - less: file pager
        - man-pages: manual documentation
        
        Tips:
        - Use 'bat --help' to see syntax highlighting themes
        - Use 'rg --type-list' to see available file types for ripgrep
        - Use 'fd --help' for fd options
        - Use 'ls' alias (mapped to eza) for better output
      '';
    };
  };
}
