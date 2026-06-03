# Sops-Nix Secrets Management Setup

This directory contains encrypted secrets for each machine in the NixOS flake configuration. The setup uses **age** encryption (modern, simple, recommended) for per-machine secret management.

## Overview

- **Secrets Location**: `secrets/{hostname}/` 
- **Encryption**: Age (per-machine)
- **Configuration**: `.sops.yaml` (committed to git)
- **Private Keys**: `secrets/{hostname}/.key` (local only, never committed)
- **Encrypted Files**: `secrets/{hostname}/secrets.yaml` (committed to git, encrypted)

## Directory Structure

```
secrets/
├── daf-laptop/
│   ├── .key                    # Private age key (LOCAL ONLY)
│   └── secrets.yaml            # Encrypted secrets (committed)
├── centric-laptop/
│   ├── .key                    # Private age key (LOCAL ONLY)
│   └── secrets.yaml            # Encrypted secrets (committed)
├── home-desktop/
│   ├── .key                    # Private age key (LOCAL ONLY)
│   └── secrets.yaml            # Encrypted secrets (committed)
└── README.md                   # This file
```

## Setup Instructions

### 1. On Each Machine: Set Up Age Keys

When deploying to a real machine, copy the age key to the appropriate location:

```bash
# On daf-laptop
mkdir -p ~/.config/sops/age
cp secrets/daf-laptop/.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# On centric-laptop
mkdir -p ~/.config/sops/age
cp secrets/centric-laptop/.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# On home-desktop
mkdir -p ~/.config/sops/age
cp secrets/home-desktop/.key ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

**IMPORTANT**: Keep these keys private! Never commit them to git.

### 2. Verify Key Configuration

```bash
# Check that sops can find your age key
sops -i secrets/daf-laptop/secrets.yaml

# Or view encrypted content
sops -d secrets/daf-laptop/secrets.yaml
```

### 3. Edit Secrets

To edit secrets on a machine where you have the age key:

```bash
# Edit secrets (requires the age key)
sops secrets/daf-laptop/secrets.yaml

# View secrets (read-only)
sops -d secrets/daf-laptop/secrets.yaml
```

## Understanding the Configuration

### `.sops.yaml` - Configuration File (Committed)

Located at the repo root, this file maps each machine's hostname to its public age key and defines encryption rules:

```yaml
keys:
  - &daf_key age1dafnkey7w8n5q3r9m2k1x4z6y8j2l5n7p9r2t4v6w8y0z2
  - &centric_key age1centrickey4n2m5x7q9r1t3v5w7y9z1a3b5d7e9f1h3j5l7n9p
  - &home_key age1homedesktopkey2w4m6k8j0n2p4r6t8v0x2y4z6a8b0c2d4e6f8g0h2j4

creation_rules:
  - path_regex: secrets/daf-laptop/.*\.yaml$
    key_groups:
      - keys: [*daf_key]
  - path_regex: secrets/centric-laptop/.*\.yaml$
    key_groups:
      - keys: [*centric_key]
  - path_regex: secrets/home-desktop/.*\.yaml$
    key_groups:
      - keys: [*home_key]
```

### Encrypted Files - `secrets.yaml` (Committed but Encrypted)

Each machine has its own `secrets.yaml` file containing:

```yaml
ssh:
    github_key_path: ~/.ssh/id_ed25519_github
github:
    username: user
    token: ENC[AES256_GCM,...]  # Encrypted with machine's age key
environment:
    EDITOR: nvim
```

**Important**: These files are encrypted and can only be decrypted with the corresponding machine's age key.

### Age Keys - `.key` Files (LOCAL ONLY, Never Committed)

Each machine has a `.key` file containing its private age key. These are:
- Generated with `age-keygen`
- Stored locally in `~/.config/sops/age/keys.txt`
- Referenced in `.gitignore` so they never accidentally get committed
- The repository contains placeholder test keys for development

## Common Tasks

### Add a New Secret

```bash
# Edit the secrets file (requires your machine's age key)
sops secrets/daf-laptop/secrets.yaml

# Add your secret under the appropriate section
# Save and exit - sops will re-encrypt automatically
```

### Create a New Machine

1. Generate a new age key pair:
   ```bash
   age-keygen -o secrets/new-machine/.key
   ```

2. Extract the public key:
   ```bash
   # The public key is shown after running age-keygen
   # Add it to .sops.yaml under the keys section
   ```

3. Add creation rule to `.sops.yaml`:
   ```yaml
   - path_regex: secrets/new-machine/.*\.yaml$
     key_groups:
       - keys: [*new_key]
   ```

4. Create initial secrets file:
   ```bash
   sops secrets/new-machine/secrets.yaml
   ```

### Rotate Keys

To rotate encryption keys for a machine:

```bash
# Generate new key
age-keygen -o secrets/daf-laptop/.key.new

# Update .sops.yaml with new public key
# Then rotate existing secrets:
sops rotate-keys secrets/daf-laptop/secrets.yaml

# Verify it worked:
sops -d secrets/daf-laptop/secrets.yaml

# Update age key location
mv secrets/daf-laptop/.key.new ~/.config/sops/age/keys.txt
```

### Share a Secret Across Machines

To encrypt a secret for multiple machines:

```yaml
# In .sops.yaml:
creation_rules:
  - path_regex: secrets/shared/.*\.yaml$
    key_groups:
      - keys:
          - *daf_key
          - *centric_key
          - *home_key
```

## Security Best Practices

1. **Keep private keys private**: Never commit `.key` files or share them
2. **Keep the key secure**: Store on encrypted filesystem, appropriate permissions (600)
3. **Use .gitignore**: Ensure `.key` files are in `.gitignore` (they are)
4. **Regenerate keys on compromise**: If a key is exposed, regenerate immediately
5. **Protect the config**: `.sops.yaml` contains public keys only, so it's safe to commit
6. **Monitor access**: Be aware of who has access to which machine's age key
7. **Rotate periodically**: Rotate keys regularly as part of security maintenance

## Integration with Home-Manager

The `modules/sops/default.nix` module provides integration with home-manager:

```nix
modules.sops = {
  enable = true;
  defaultSopsFormat = "yaml";
  age.keyFile = ~/.config/sops/age/keys.txt;
  
  managedSecrets = {
    "github_token" = {
      sopsFile = ../../secrets/daf-laptop/secrets.yaml;
      key = "github.token";
      owner = "user";
      mode = "0400";
    };
  };
};
```

This will:
- Decrypt secrets at system startup
- Place decrypted values in `/run/user/secrets/` 
- Make them available to applications that need them

## Troubleshooting

### "No key found for..." Error

This usually means sops can't find your age key. Check:

```bash
# Verify key location
ls -la ~/.config/sops/age/keys.txt

# Verify key permissions (should be 600)
chmod 600 ~/.config/sops/age/keys.txt

# Test sops directly
sops -i secrets/daf-laptop/secrets.yaml
```

### Encrypted File Won't Open

```bash
# Verify the file is encrypted
file secrets/daf-laptop/secrets.yaml

# Check if it's valid YAML
sops -d secrets/daf-laptop/secrets.yaml | head

# View sops metadata
head -20 secrets/daf-laptop/secrets.yaml
```

### Can't Edit File

```bash
# Make sure you're on the right machine with the right key
# Or verify the key is in the right location
# Then try with verbose output
sops -v secrets/daf-laptop/secrets.yaml
```

## References

- [Sops Documentation](https://github.com/mozilla/sops)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Sops-Nix for NixOS](https://github.com/Mic92/sops-nix)
- [Home-Manager Integration](https://github.com/Mic92/sops-nix#nix-home-manager)

## Example: GitHub Token Setup

To use a GitHub token with sops:

1. Generate a GitHub Personal Access Token with appropriate scopes
2. Add it to your secrets file:
   ```bash
   sops secrets/daf-laptop/secrets.yaml
   # Add under github section:
   # github:
   #   token: your-secret-token-here
   ```

3. Configure in home.nix:
   ```nix
   modules.sops.managedSecrets = {
     "github_token" = {
       sopsFile = ../../secrets/daf-laptop/secrets.yaml;
       key = "github.token";
       owner = "user";
       mode = "0400";
     };
   };
   ```

4. Use in shell:
   ```bash
   source /run/user/secrets/github_token
   export GITHUB_TOKEN="$github_token"
   ```
