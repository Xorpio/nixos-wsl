{ config, options, lib, pkgs, ... }:

with lib;

{
  options.modules.git = {
    enable = mkEnableOption "Git configuration with aliases and defaults";

    userName = mkOption {
      type = types.str;
      default = "NixOS User";
      description = "Git user name (can be overridden per-machine)";
    };

    userEmail = mkOption {
      type = types.str;
      default = "user@example.com";
      description = "Git user email (can be overridden per-machine)";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        # Shorthand commands
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --graph --oneline --all";

        # Merge and rebase
        amend = "commit --amend --no-edit";
        rebase-main = "rebase -i main";
        merge-abort = "merge --abort";

        # Diff and log
        diff-cached = "diff --cached";
        log-oneline = "log --oneline";
        log-graph = "log --graph --oneline --all";

        # Useful utilities
        clean-branches = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";
        tags = "tag -l";
        branches = "branch -a";
      };
      description = "Git aliases";
    };

    additionalAliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional git aliases (for machine-specific overrides)";
    };

    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for git init";
    };

    ignoreGlobal = mkOption {
      type = types.lines;
      default = ''
        # IDE and editors
        .vscode/
        .idea/
        *.swp
        *.swo
        *~
        .DS_Store
        
        # Dependencies
        node_modules/
        .npm/
        dist/
        build/
        target/
        
        # Environment
        .env
        .env.local
        .venv/
        venv/
        
        # Misc
        *.log
        .cache/
      '';
      description = "Global gitignore patterns";
    };

    corePager = mkOption {
      type = types.str;
      default = "less -FRX";
      description = "Git core pager";
    };

    pullRebase = mkOption {
      type = types.bool;
      default = true;
      description = "Use rebase for pulls instead of merge";
    };

    fetchPrune = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically prune deleted remote branches";
    };

    rebaseAutoStash = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically stash changes during rebase";
    };

    colorUi = mkOption {
      type = types.enum [ "true" "false" "auto" ];
      default = "auto";
      description = "Enable colored output";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra git configuration (merged with defaults)";
    };
  };

  config = mkIf config.modules.git.enable {
    programs.git = {
      enable = true;

      # User info
      userName = config.modules.git.userName;
      userEmail = config.modules.git.userEmail;

      # Aliases (merge defaults + additional)
      aliases = recursiveUpdate config.modules.git.aliases config.modules.git.additionalAliases;

      # Global gitignore patterns
      ignores = lib.splitString "\n" config.modules.git.ignoreGlobal;

      # Configuration
      extraConfig = recursiveUpdate
        {
          # Core settings
          core = {
            pager = config.modules.git.corePager;
            commentChar = "#";
          };

          # Init defaults
          init = {
            defaultBranch = config.modules.git.defaultBranch;
          };

          # Pull strategy
          pull = mkIf config.modules.git.pullRebase {
            rebase = true;
          };

          # Fetch pruning
          fetch = mkIf config.modules.git.fetchPrune {
            prune = true;
          };

          # Rebase settings
          rebase = mkIf config.modules.git.rebaseAutoStash {
            autoStash = true;
          };

          # Color settings
          color = {
            ui = config.modules.git.colorUi;
          };

          # Diff settings for better readability
          diff = {
            algorithm = "histogram";
            colorMoved = "default";
          };

          # Status settings
          status = {
            showUntrackedFiles = "all";
          };

          # Log settings
          log = {
            decorate = "short";
          };

          # Push settings
          push = {
            default = "current";
            followTags = true;
          };

          # Branch settings
          branch = {
            autosetuprebase = "always";
          };
        }
        config.modules.git.extraConfig;
    };

    # Create global gitignore file
    home.file.".gitignore_global" = {
      text = config.modules.git.ignoreGlobal;
    };
  };
}
