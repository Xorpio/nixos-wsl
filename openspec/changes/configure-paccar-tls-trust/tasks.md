## 1. Protect cert from git

- [x] 1.1 Add `paccar-root.crt` (and any `.crt` in `/etc/nixos/`) to `.gitignore` so it can never accidentally be committed

## 2. NixOS host configuration

- [x] 2.1 Add `security.pki.certificateFiles = [ /etc/nixos/paccar-root.crt ];` to `hosts/daf-laptop/configuration.nix`

## 3. Manual provisioning (inside NixOS WSL — not automated)

- [x] 3.1 Copy the PACCAR root certificate from Windows into the NixOS instance: `cp /mnt/c/path/to/PACCARTrustRoot.crt /etc/nixos/paccar-root.crt`
- [x] 3.2 Verify the file is a valid PEM certificate: `openssl x509 -in /etc/nixos/paccar-root.crt -noout -subject`

## 4. Bootstrap rebuild

- [x] 4.1 Create a combined CA bundle (system certs + PACCAR cert): `cat /etc/ssl/certs/ca-bundle.crt /etc/nixos/paccar-root.crt > /root/combined-ca.crt`
- [x] 4.2 Run `nixos-rebuild switch` with the combined bundle to break the chicken-and-egg problem: `NIX_SSL_CERT_FILE=/root/combined-ca.crt nixos-rebuild switch --flake .#daf-laptop`

## 5. Verification

- [x] 5.1 Confirm `PACCARTrustRoot` appears in the system CA bundle: `grep -i paccar /etc/ssl/certs/ca-bundle.crt`
- [x] 5.2 Verify HTTPS succeeds without overriding `NIX_SSL_CERT_FILE`: `curl -sv https://github.com 2>&1 | grep -E "ssl_verify_result|SSL certificate verify"`
- [x] 5.3 Restart the WSL instance (`wsl --terminate NixOS` from Windows, then relaunch) and re-run 5.1 and 5.2 to confirm the fix survives reboot
- [x] 5.4 Confirm the cert file does not appear in `git status` or `git diff`
