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
      type = types.str;
      default = "$HOME/.config/sops-nix";
      description = "Directory where secrets are accessed (per-machine defaults)";
    };

    managedSecrets = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "Managed secrets that should be decrypted and available";
    };

    additionalSecrets = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "Additional machine-specific secrets";
    };
  };

  config = mkIf config.modules.sops.enable {
    # sops-nix is enabled via module import already
    # Additional setup can go here if needed
    
    # Set up environment variables for sops
    home.sessionVariables = {
      SOPS_FORMAT = config.modules.sops.defaultSopsFormat;
      SOPS_SECRETS_DIR = config.modules.sops.secretsDir;
    };

    # Merge managed secrets with additional ones
    sops.secrets = recursiveUpdate 
      config.modules.sops.managedSecrets 
      config.modules.sops.additionalSecrets;

    # Install sops tool
    home.packages = [ pkgs.sops ];

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
           sops secrets.yaml
           ```
        
        3. Edit secrets:
           ```bash
           sops secrets.yaml
           ```
        
        ## Environment Setup
        
        Secrets location: ${config.modules.sops.secretsDir}
        Default format: ${config.modules.sops.defaultSopsFormat}
        
        ## Security Best Practices
        
        - Never commit unencrypted secrets to git
        - Keep your age key in a secure location
        - Regularly rotate encryption keys
        - Use `.gitignore` to exclude raw secrets files
      '';
    };
  };
}
