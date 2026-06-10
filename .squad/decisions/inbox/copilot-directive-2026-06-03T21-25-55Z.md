### 2026-06-03T21:25:55Z: Git config directives

**By:** Xorpio (via Copilot)

**What:**
1. No Nix-specific hooks — keep pre-commit validation-only (YAML/JSON, shell linting, secrets detection). Skip `nixfmt` because devs on non-Nix machines won't have it.
2. Pre-commit is local-only, not a CI gate. Hooks strongly recommended for dev friction but not enforced in CI. CI runs independent checks if needed.
3. Team-specific secrets patterns — defer. Start with defaults; add custom patterns later if needed.

**Why:** User preference — focused scope on pre-commit (local dev tool), no Nix formatter complexity, secrets patterns unknown until dev starts.
