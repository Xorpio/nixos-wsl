#!/usr/bin/env bash
# Sops verification script
# Tests the encryption/decryption workflow for each machine's secrets

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOPS_CONFIG="${REPO_ROOT}/.sops.yaml"
MACHINES=("daf-laptop" "centric-laptop" "home-desktop")

echo "🔐 Sops-Nix Secrets Verification"
echo "=================================="
echo ""

# Check if sops is installed
if ! command -v sops &> /dev/null; then
    echo "❌ sops is not installed"
    echo "   Install with: nix-shell -p sops --run 'sops --version'"
    exit 1
fi

echo "✅ sops is installed: $(sops --version)"
echo ""

# Check if .sops.yaml exists
if [ ! -f "$SOPS_CONFIG" ]; then
    echo "❌ .sops.yaml not found at $SOPS_CONFIG"
    exit 1
fi

echo "✅ .sops.yaml found"
echo ""

# Verify each machine's setup
for machine in "${MACHINES[@]}"; do
    echo "Checking $machine..."
    
    secrets_dir="${REPO_ROOT}/secrets/${machine}"
    key_file="${secrets_dir}/.key"
    secrets_yaml="${secrets_dir}/secrets.yaml"
    
    # Check directory
    if [ ! -d "$secrets_dir" ]; then
        echo "  ❌ Directory missing: $secrets_dir"
        continue
    fi
    echo "  ✅ Directory exists"
    
    # Check key file
    if [ ! -f "$key_file" ]; then
        echo "  ⚠️  Key file missing: $key_file (local keys are not in git)"
        echo "     This is expected - keys should be placed locally at ~/.config/sops/age/keys.txt"
    else
        echo "  ✅ Key file exists"
        if [ -r "$key_file" ]; then
            echo "  ✅ Key file is readable"
        else
            echo "  ❌ Key file is not readable (permissions issue?)"
        fi
    fi
    
    # Check secrets file
    if [ ! -f "$secrets_yaml" ]; then
        echo "  ❌ Secrets file missing: $secrets_yaml"
        continue
    fi
    echo "  ✅ Secrets file exists"
    
    # Check if it's encrypted (contains "sops" section)
    if grep -q "^sops:" "$secrets_yaml" 2>/dev/null; then
        echo "  ✅ Secrets file appears to be encrypted"
    else
        echo "  ⚠️  Secrets file may not be encrypted"
    fi
    
    # Try to view with sops (will fail if key not available, which is OK)
    if [ -f "$key_file" ]; then
        echo "  Attempting to decrypt..."
        export SOPS_AGE_KEY_FILE="$key_file"
        if sops -d "$secrets_yaml" > /dev/null 2>&1; then
            echo "  ✅ Successfully decrypted with local key"
            
            # Show structure
            echo "  Structure:"
            sops -d "$secrets_yaml" | grep "^[a-z]" | sed 's/^/    /'
        else
            echo "  ⚠️  Could not decrypt (this is OK if key doesn't match)"
        fi
        unset SOPS_AGE_KEY_FILE
    else
        echo "  ⚠️  Key file not available locally - cannot test decryption"
        echo "     This is expected in CI/test environments"
    fi
    
    echo ""
done

# Check .sops.yaml configuration
echo "Checking .sops.yaml configuration..."
echo ""

if grep -q "^keys:" "$SOPS_CONFIG"; then
    echo "✅ Keys section found in .sops.yaml"
    echo "   Keys configured:"
    grep "age1" "$SOPS_CONFIG" | sed 's/^/   /'
else
    echo "❌ Keys section not found in .sops.yaml"
fi

echo ""

if grep -q "^creation_rules:" "$SOPS_CONFIG"; then
    echo "✅ Creation rules found in .sops.yaml"
    echo "   Rules configured for:"
    grep "path_regex:" "$SOPS_CONFIG" | sed 's/.*secrets\///; s/.yaml.*//; s/^\s*/   /'
else
    echo "❌ Creation rules not found in .sops.yaml"
fi

echo ""
echo "🔐 Verification Complete"
echo ""

# Print next steps
echo "Next Steps:"
echo "==========="
echo ""
echo "1. Copy age keys to each machine:"
echo "   cp secrets/daf-laptop/.key ~/.config/sops/age/keys.txt"
echo "   chmod 600 ~/.config/sops/age/keys.txt"
echo ""
echo "2. Test decryption on each machine:"
echo "   sops -d secrets/daf-laptop/secrets.yaml"
echo ""
echo "3. Edit secrets on each machine:"
echo "   sops secrets/daf-laptop/secrets.yaml"
echo ""
echo "4. When ready, remove placeholder keys:"
echo "   rm secrets/*/. key"
echo "   (Replace with real keys from age-keygen on each machine)"
