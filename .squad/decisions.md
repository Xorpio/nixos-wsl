# Squad Decisions

## Active Decisions

### SOPS Secrets Strategy for Taskwarrior (2026-06-07)

**Lead:** Lester (Architecture)

**Decision:** Use Age-based encryption with SOPS to manage per-machine taskwarrior sync credentials.

**Rationale:**
- Each machine has its own encrypted secrets file with machine-specific `client_id` and shared `encryption_secret`.
- Age keys are native to NixOS; simpler than GPG.
- Home Manager decrypts at rebuild time and injects secrets into `~/.taskrc`.
- Age private keys never leave the machine; only public keys are committed.
- Per-machine secrets files allow fine-grained access control.

**Implementation:** See `.squad/decisions/inbox/lester-taskwarrior-sops.md` for full architecture.

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
