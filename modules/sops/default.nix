{ config, options, lib, pkgs, ... }:

with lib;

{
  options.modules.sops = {
    enable = mkEnableOption "sops-nix integration for secrets management";

    defaultSopsFormat = mkOption {
      type = types.enum [ "yaml" "json" "xml" "ini" "toml" ];
      default = "yaml";
      description = "Default format for secrets files";
    };

    secretsDir = mkOption {
      type = types.path;
      default = /etc/sops-nix/secrets;
      description = "Directory where secrets are stored (typically per-machine)";
    };

    age = {
      keyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to age key file for decryption (~/.config/sops/age/keys.txt)";
      };

      rules = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
        description = "Age encryption rules for different secret files";
        example = [
          {
            path_regex = "secrets/.*\\.yaml$";
            key_files = [ "/root/.config/sops/age/keys.txt" ];
          }
        ];
      };
    };

    gnupg = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Use GnuPG for encryption instead of age";
      };

      keyId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "GPG key ID for encryption";
      };
    };

    enableManagement = mkOption {
      type = types.bool;
      default = true;
      description = "Enable sops tooling in home environment";
    };

    managedSecrets = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "Managed secrets that should be decrypted and available";
      example = {
        "db_password" = {
          sopsFile = "/etc/sops/secrets.yaml";
          key = "database.password";
          owner = "user";
          mode = "0400";
        };
      };
    };

    additionalSecrets = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "Additional secrets (for machine-specific secrets)";
    };
  };

  config = mkIf config.modules.sops.enable {
    # Install sops if management is enabled
    home.packages = mkIf config.modules.sops.enableManagement [ pkgs.sops ];

    # Set up environment variables for sops
    home.sessionVariables = {
      SOPS_FORMAT = config.modules.sops.defaultSopsFormat;
    };

    # Configure sops-nix if using age encryption
    sops = mkIf (!config.modules.sops.gnupg.enable) {
      age = {
        keyFile = mkIf (config.modules.sops.age.keyFile != null)
          config.modules.sops.age.keyFile;

        generateKey = mkIf (config.modules.sops.age.keyFile == null) true;

        rules = config.modules.sops.age.rules;
      };

      defaultSopsFormat = config.modules.sops.defaultSopsFormat;

      # Merge managed secrets with additional secrets
      secrets = recursiveUpdate
        config.modules.sops.managedSecrets
        config.modules.sops.additionalSecrets;
    };

    # Create a helper script for working with secrets
    home.file.".config/sops/sops-helper.sh" = mkIf config.modules.sops.enableManagement {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        
        # sops helper script for common operations
        
        set -euo pipefail
        
        SOPS_FORMAT="''${SOPS_FORMAT:-yaml}"
        
        show_usage() {
          cat << EOF
        sops-helper - Helper for managing secrets with sops
        
        Usage: sops-helper [COMMAND] [OPTIONS]
        
        Commands:
          edit FILE              Edit a secrets file
          view FILE              View a secrets file (read-only)
          create FILE            Create a new secrets file
          encrypt FILE           Encrypt a plain file
          decrypt FILE           Decrypt a secrets file
          rotate FILE            Rotate keys in a secrets file
          
        Examples:
          sops-helper edit secrets.yaml
          sops-helper view secrets.yaml
          sops-helper create new-secrets.yaml
          
        Environment:
          SOPS_FORMAT            Secret file format (yaml, json, etc.)
        
        EOF
        }
        
        case "''${1:-help}" in
          edit)
            ${pkgs.sops}/bin/sops "''${2:?File path required}" 2>/dev/null || echo "Error: Failed to edit $2"
            ;;
          view)
            ${pkgs.sops}/bin/sops -d "''${2:?File path required}" 2>/dev/null || echo "Error: Failed to view $2"
            ;;
          create)
            touch "''${2:?File path required}" && ${pkgs.sops}/bin/sops "''${2}" 2>/dev/null || echo "Error: Failed to create $2"
            ;;
          encrypt)
            ${pkgs.sops}/bin/sops -e "''${2:?File path required}" > "''${2}.enc" && echo "Encrypted to $2.enc" || echo "Error: Failed to encrypt $2"
            ;;
          decrypt)
            ${pkgs.sops}/bin/sops -d "''${2:?File path required}" > "''${2}.dec" && echo "Decrypted to $2.dec" || echo "Error: Failed to decrypt $2"
            ;;
          rotate)
            ${pkgs.sops}/bin/sops rotate-keys "''${2:?File path required}" 2>/dev/null || echo "Error: Failed to rotate keys in $2"
            ;;
          help|*)
            show_usage
            ;;
        esac
      '';
    };

    # Create documentation about sops setup
    home.file.".config/sops/README.md" = {
      text = ''
        # Sops-Nix Secrets Management
        
        This environment uses sops-nix for managing secrets securely.
        
        ## Quick Start
        
        ### Age Encryption (Default)
        
        If using age (modern encryption):
        
        1. Generate a key if you haven't already:
           ```bash
           mkdir -p ~/.config/sops/age
           age-keygen -o ~/.config/sops/age/keys.txt
           ```
        
        2. Create a secrets file:
           ```bash
           sops-helper create secrets.yaml
           ```
        
        3. Edit secrets:
           ```bash
           sops-helper edit secrets.yaml
           ```
        
        ### GPG Encryption
        
        If configured to use GPG:
        
        1. Set up your GPG key if not already done
        
        2. Create a `.sops.yaml` configuration file in your project:
           ```yaml
           creation_rules:
             - path_regex: secrets/.*\.yaml$
               kms: arn:aws:kms:...
               gcp_kms: ...
               pgp: YOUR_GPG_KEY_ID
           ```
        
        ## Environment Setup
        
        Secrets location: ${config.modules.sops.secretsDir}
        Default format: ${config.modules.sops.defaultSopsFormat}
        
        ## For Machine-Specific Secrets
        
        Each machine can have its own secrets directory. Set this in your machine's
        home.nix configuration:
        
        ```nix
        modules.sops = {
          enable = true;
          secretsDir = /etc/sops-nix/secrets-mylaptop;
        };
        ```
        
        ## Security Best Practices
        
        - Never commit unencrypted secrets to git
        - Keep your age key or GPG key in a secure location
        - Regularly rotate encryption keys
        - Use `.gitignore` to exclude raw secrets files
        - Use sops for all sensitive configuration
        
        ## Common Tasks
        
        ### Edit a secret
        ```bash
        sops-helper edit secrets.yaml
        ```
        
        ### View a secret (read-only)
        ```bash
        sops-helper view secrets.yaml
        ```
        
        ### Rotate encryption keys
        ```bash
        sops-helper rotate secrets.yaml
        ```
        
        ### Create new secrets file
        ```bash
        sops-helper create new-secrets.yaml
        ```
      '';
    };

    # Create a basic sops configuration template
    home.file.".sops.yaml" = mkIf (config.modules.sops.age.rules == [ ]) {
      text = ''
        # Sops configuration for this project
        # Reference: https://github.com/mozilla/sops
        
        creation_rules:
          # Age encryption rule (default)
          - path_regex: secrets/.*\.yaml$
            key_files:
        ${optionalString (config.modules.sops.age.keyFile != null)
          "      - ${toString config.modules.sops.age.keyFile}"}
      '';
    };

    # Set up sops on load if management is enabled
    home.activation.setupSopsDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.bash}/bin/bash << 'EOF'
        mkdir -p ~/.config/sops/age
        mkdir -p ${toString config.modules.sops.secretsDir}
      EOF
    '';
  };
}
