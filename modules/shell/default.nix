{ config, options, lib, pkgs, ... }:

with lib;

{
  options.modules.shell = {
    enable = mkEnableOption "shell configuration (zsh with aliases and env vars)";

    defaultShell = mkOption {
      type = types.enum [ "zsh" "bash" ];
      default = "zsh";
      description = "Default shell to use";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        # common shortcuts
        clear = "clear";
        cls = "clear";
      };
      description = "Shell aliases to enable";
      example = {
        ll = "ls -lah";
        ga = "git add";
      };
    };

    additionalAliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional aliases to merge with defaults (for machine-specific overrides)";
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {
        # Disable less history
        LESSHISTFILE = "/dev/null";
        # UTF-8 settings
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };
      description = "Environment variables to set in shell";
    };

    additionalEnvironmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional environment variables to merge with defaults";
    };

    sessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Session variables (only set when shell starts)";
    };

    initExtra = mkOption {
      type = types.lines;
      default = "";
      description = "Extra shell initialization code";
    };

    promptInit = mkOption {
      type = types.str;
      default = "";
      description = "Custom prompt initialization";
    };
  };

  config = mkIf config.modules.shell.enable {
    # Merge aliases (defaults + additional)
    home.shellAliases = recursiveUpdate config.modules.shell.aliases config.modules.shell.additionalAliases;

    # Merge environment variables (merge all three together)
    home.sessionVariables = recursiveUpdate
      (recursiveUpdate
        config.modules.shell.environmentVariables
        config.modules.shell.additionalEnvironmentVariables)
      config.modules.shell.sessionVariables;

    # Configure zsh if it's the default shell
    programs.zsh = mkIf (config.modules.shell.defaultShell == "zsh") {
      enable = true;
      defaultKeymap = "emacs";
      enableCompletion = true;
      dotDir = ".config/zsh";

      # History configuration
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
        extended = true;
      };

      # Extra initialization (includes zsh options and prompt)
      initExtra = ''
        # Set zsh options for better behavior
        setopt APPEND_HISTORY
        setopt AUTO_CD
        setopt AUTO_LIST
        setopt AUTO_MENU
        setopt AUTO_PUSHD
        setopt COMPLETE_IN_WORD
        setopt EXTENDED_HISTORY
        setopt HIST_FIND_NO_DUPS
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_SAVE_NO_DUPS
        setopt INTERACTIVE_COMMENTS
        setopt PUSHD_IGNORE_DUPS
        setopt PUSHD_SILENT
        
        ${config.modules.shell.initExtra}
      '';
    };

    # Configure bash as alternative
    programs.bash = mkIf (config.modules.shell.defaultShell == "bash") {
      enable = true;
      bashrcExtra = config.modules.shell.initExtra;
    };
  };
}
