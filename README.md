# Akev Windows packages

Windows packages for [Akev](https://akev.dev), the open-source HTTP(S) debugging proxy.

| Package manager | Install | Source here |
|---|---|---|
| Chocolatey | `choco install akev` | [`akev/`](akev) |
| winget | `winget install Akev.Akev` | [`winget/`](winget) (a copy of what's submitted to [microsoft/winget-pkgs](https://github.com/microsoft/winget-pkgs), used for testing) |
| Scoop | `scoop bucket add akev https://github.com/akevdev/scoop-bucket` then `scoop install akev/akev` | [akevdev/scoop-bucket](https://github.com/akevdev/scoop-bucket) |

The Chocolatey package installs the desktop app from the release's MSI (all users); winget
installs it from the NSIS installer (current user). Both use the native arm64 build on Windows
on Arm.

## How updates work

`sync` checks for a new Akev release every 6 hours, verifies the release's `SHA256SUMS` with
Sigstore, rewrites the version and checksums (`scripts/update.sh`), runs `test` (Chocolatey and
winget install and uninstall on x64 and arm64 Windows) and `publish`, which pushes to the
Chocolatey Community Repository when the `CHOCO_API_KEY` secret is set.

Issues with Akev itself: <https://github.com/akevdev/akev/issues>
