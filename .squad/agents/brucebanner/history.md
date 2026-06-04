# Bruce Banner — Project History

## Context (Day 1)

**Owner:** Niek de Gooijer
**Project:** nixos-wsl — Multi-machine reproducible NixOS configuration
**Goal:** Centralize configuration for three WSL instances (Daf work laptop, Centric work laptop, home desktop) using Nix flakes, home-manager, and sops-nix.

**Specifications to Validate:**
- Five capabilities with detailed requirements (already drafted in OpenSpec)
- Each capability has scenarios that define "done"
- Spec files in: `.openspec/changes/setup-multi-machine-nixos-config/specs/*/spec.md`

**Spec Files:**
1. `flake-multi-machine-setup/spec.md` — Multi-machine flake management
2. `home-manager-user-environment/spec.md` — User environment configuration
3. `neovim-config-management/spec.md` — Editor config integration
4. `encrypted-machine-secrets/spec.md` — sops-nix secrets
5. `shared-configuration-modules/spec.md` — Module composition

**My Work:**
- Validate that implementations match spec requirements
- Create test scenarios based on each spec
- Review implementations against acceptance criteria
- Identify edge cases and failure modes

## Learnings

(None yet — awaiting implementation)

## 2026-06-04T09:15:00Z - Deployment Preparation Session
- Deployment artifacts created and documented
- Orchestration log generated
- Session log completed
- Pre-deployment checks passed

## 2026-06-04T10:47:00Z - PACCAR TLS Trust Runbook

**Change:** `configure-paccar-tls-trust`

**What I did:**
- Created manual runbook at `hosts/daf-laptop/PACCAR-CERT-SETUP.md` covering tasks 3.1, 3.2, 4.1, 4.2 (provisioning + bootstrap rebuild) and tasks 5.1–5.4 (acceptance verification)
- Updated `openspec/changes/configure-paccar-tls-trust/tasks.md` to annotate tasks 3.1–5.4 as requiring manual execution inside NixOS WSL — checkboxes left unchecked

**Runbook location:** `hosts/daf-laptop/PACCAR-CERT-SETUP.md`

**Verification criteria (acceptance criteria for the fix):**
1. `grep -i paccar /etc/ssl/certs/ca-bundle.crt` returns output (cert is in system bundle)
2. `curl -sv https://github.com 2>&1 | grep -E "ssl_verify_result|SSL certificate verify"` returns `ssl_verify_result:0` or `SSL certificate verify ok`
3. Both checks pass after `wsl --terminate NixOS` + relaunch (fix survives reboot)
4. `paccar-root.crt` does NOT appear in `git status` or `git diff` (cert not committed)

**Key bootstrap note:** The `nixos-rebuild switch` on first run requires a combined CA bundle (`cat /etc/ssl/certs/ca-bundle.crt /etc/nixos/paccar-root.crt > /root/combined-ca.crt`) and `NIX_SSL_CERT_FILE=/root/combined-ca.crt` prefix to break the chicken-and-egg SSL problem. One-time only.

**Cert rotation reminder:** If PACCAR rotates their root CA, Niek must re-export from `certmgr.msc`, overwrite `/etc/nixos/paccar-root.crt`, and run `nixos-rebuild switch` again. No bootstrap needed for rotation (old cert still trusted during rebuild).

**Rocket Raccoon completed (same session):**
- Task 1.1: `.gitignore` PACCAR cert exclusion block added
- Task 2.1: `security.pki.certificateFiles` configured in `hosts/daf-laptop/system.nix`

