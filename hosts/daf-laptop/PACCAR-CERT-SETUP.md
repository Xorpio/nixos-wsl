# PACCAR TLS Trust — Manual Setup Runbook

Run all commands inside the **NixOS WSL instance** unless stated otherwise.

---

## Prerequisites

**Already done by Rocket Raccoon (in the repo):**
- `hosts/daf-laptop/system.nix` contains `security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];`
- `.gitignore` protects `paccar-root.crt` from ever being committed

**What you need:**
- The PACCAR root certificate exported as a Base-64 encoded X.509 file (`.crt` or `.cer`) from the Windows Certificate Store

---

## Step 1: Export the PACCAR cert from Windows

The cert is installed in Windows by PACCAR IT. You need to export it manually.

1. Open **Run** (`Win+R`) → type `certmgr.msc` → press Enter
2. Navigate to **Trusted Root Certification Authorities → Certificates**
3. Find **PACCARTrustRoot** (search with `Ctrl+F` or scroll)
4. Right-click → **All Tasks → Export…**
5. Choose **Base-64 encoded X.509 (.CER)** format
6. Save to a known path, e.g. `C:\ProgramData\PACCARTrustRoot.crt`

> **Alternative:** It may already exist at a path like `C:\ProgramData\...` or in your user profile. Check with PowerShell (run from Windows):
> ```powershell
> Get-ChildItem -Recurse C:\ProgramData -Filter "*PACCAR*" -ErrorAction SilentlyContinue
> ```

---

## Step 2: Copy the cert into NixOS WSL

Inside your NixOS WSL terminal, substitute the actual Windows path (Windows drives are mounted at `/mnt/c/`, `/mnt/d/`, etc.):

```bash
cp /mnt/c/ProgramData/PACCARTrustRoot.crt /etc/nixos/paccar-root.crt
```

> Adjust the source path to wherever you saved the file in Step 1.

---

## Step 3: Verify the cert is a valid PEM certificate

```bash
openssl x509 -in /etc/nixos/paccar-root.crt -noout -subject -issuer
```

**Expected output** should contain `PACCAR` in both subject and issuer lines, e.g.:
```
subject=CN=PACCARTrustRoot, O=PACCAR Inc, C=US
issuer=CN=PACCARTrustRoot, O=PACCAR Inc, C=US
```

If you see a parse error, the cert was not exported in Base-64/PEM format — re-export from Step 1 choosing the correct format.

---

## Step 4: Bootstrap rebuild (chicken-and-egg fix)

> **⚠️ Why `--impure` is required on daf-laptop**
>
> `security.pki.certificateFiles` references `/etc/nixos/paccar-root.crt` — an absolute path on the host filesystem. NixOS flakes run in **pure evaluation mode** by default, which forbids access to paths outside the Nix store (including `/etc`). Passing `--impure` lifts this restriction for daf-laptop rebuilds. **All `nixos-rebuild` invocations on this machine must include `--impure`.**

On first run, `nixos-rebuild` itself needs HTTPS to fetch packages, but NixOS doesn't trust the PACCAR CA yet. Use a combined CA bundle for this one-time bootstrap:

```bash
# Create combined bundle (existing system CAs + PACCAR cert)
cat /etc/ssl/certs/ca-bundle.crt /etc/nixos/paccar-root.crt > /root/combined-ca.crt

# Run nixos-rebuild using the combined bundle
cd /etc/nixos
NIX_SSL_CERT_FILE=/root/combined-ca.crt nixos-rebuild switch --impure --flake .#daf-laptop
```

> The `combined-ca.crt` file at `/root/combined-ca.crt` is temporary — you can delete it after a successful rebuild.

After a successful rebuild, the PACCAR cert is permanently in the NixOS trust store and no `NIX_SSL_CERT_FILE` override is needed.

---

## Step 5: Verification (Acceptance Criteria)

Run these checks to confirm the fix is working correctly.

### 5.1 — Cert is in the system CA bundle

```bash
grep -i paccar /etc/ssl/certs/ca-bundle.crt
```

✅ **Pass:** Output contains lines with `PACCAR` (subject/issuer from the cert)  
❌ **Fail:** No output — the rebuild may not have completed successfully

### 5.2 — HTTPS connections succeed without any override

```bash
curl -sv https://github.com 2>&1 | grep -E "ssl_verify_result|SSL certificate verify"
```

✅ **Pass:** `ssl_verify_result:0` or `SSL certificate verify ok`  
❌ **Fail:** `ssl_verify_result:19` or `certificate verify failed` — cert is not trusted

### 5.3 — Fix survives WSL restart

From **Windows PowerShell**:
```powershell
wsl --terminate NixOS
```

Then relaunch NixOS WSL and re-run checks 5.1 and 5.2.

✅ **Pass:** Both checks still pass after restart  
❌ **Fail:** Cert missing after restart — indicates it was only in a transient location

### 5.4 — Cert file is NOT tracked by git

Inside NixOS WSL, from the repo directory:
```bash
git status
git diff
```

✅ **Pass:** `paccar-root.crt` does **not** appear in either output  
❌ **Fail:** File appears as untracked or staged — check that `.gitignore` is in place

---

## Cert Rotation

If PACCAR rotates their root CA in the future:

1. Export the new cert from `certmgr.msc` (Step 1)
2. Overwrite `/etc/nixos/paccar-root.crt` with the new file
3. Run `nixos-rebuild switch --impure --flake .#daf-laptop` (no bootstrap needed — the old cert is still trusted during rebuild)
4. Re-run verification checks 5.1 and 5.2
