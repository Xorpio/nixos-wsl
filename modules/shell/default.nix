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
        # ls aliases
        ls = "ls --color=auto";
        ll = "ls -lah";
        la = "ls -la";
        l = "ls -CF";

        # grep aliases
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";

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

    # Merge environment variables
    home.sessionVariables = recursiveUpdate
      config.modules.shell.environmentVariables
      config.modules.shell.additionalEnvironmentVariables;

    # Also set session-specific variables
    home.sessionVariables = recursiveUpdate
      (home.sessionVariables or { })
      config.modules.shell.sessionVariables;

    # Configure zsh if it's the default shell
    programs.zsh = mkIf (config.modules.shell.defaultShell == "zsh") {
      enable = true;
      defaultKeymap = "emacs";
      enableCompletion = true;
      enableVteIntegration = true;
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

      # Zsh options for better behavior
      setOptions = [
        "APPEND_HISTORY"
        "AUTO_CD"
        "AUTO_LIST"
        "AUTO_MENU"
        "AUTO_PUSHD"
        "COMPLETE_IN_WORD"
        "EXTENDED_HISTORY"
        "HIST_FIND_NO_DUPS"
        "HIST_IGNORE_ALL_DUPS"
        "HIST_SAVE_NO_DUPS"
        "INTERACTIVE_COMMENTS"
        "PUSHD_IGNORE_DUPS"
        "PUSHD_SILENT"
      ];

      # Prompt setup
      prompt.enable = true;
      prompt.theme = "walters";

      # Extra initialization
      initExtra = config.modules.shell.initExtra;
    };

    # Configure bash as alternative
    programs.bash = mkIf (config.modules.shell.defaultShell == "bash") {
      enable = true;
      bashrcExtra = config.modules.shell.initExtra;
    };
  };
}
