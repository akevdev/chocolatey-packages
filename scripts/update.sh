#!/usr/bin/env bash
# Point the Chocolatey package (and the winget manifests kept here for testing) at an Akev
# release: version, download URLs and SHA-256 sums, taken from the release's SHA256SUMS.
#
#   scripts/update.sh <version> <SHA256SUMS file> [release date, YYYY-MM-DD]
#
# Verify SHA256SUMS (cosign verify-blob, see the sync workflow) before calling this.
set -euo pipefail
version=${1:?usage: scripts/update.sh <version> <SHA256SUMS>}
sums=${2:?SHA256SUMS file}
root=$(cd "$(dirname "$0")/.." && pwd)
date=${3:-$(date -u +%Y-%m-%d)}

sha() {
  local s
  s=$(awk -v f="$1" '$2 == f || $2 == "*" f { print $1 }' "$sums")
  if [ -z "$s" ]; then echo "missing $1 in SHA256SUMS" >&2; exit 1; fi
  echo "$s"
}

msi_x64=$(sha "Akev_${version}_x64_en-US.msi")
msi_arm64=$(sha "Akev_${version}_arm64_en-US.msi")
nsis_x64=$(sha "Akev_${version}_x64-setup.exe")
nsis_arm64=$(sha "Akev_${version}_arm64-setup.exe")

# Chocolatey
nuspec="$root/akev/akev.nuspec"
install="$root/akev/tools/chocolateyinstall.ps1"
sed -i -E \
  -e "s|<version>[^<]*</version>|<version>$version</version>|" \
  -e "s|akevdev/akev@v[^/]*/|akevdev/akev@v$version/|" \
  -e "s|releases/tag/v[^<]*</releaseNotes>|releases/tag/v$version</releaseNotes>|" \
  "$nuspec"
sed -i -E \
  -e "s|^\\\$version = '[^']*'|\$version = '$version'|" \
  -e "0,/checksum64 +=/s|(checksum64 +=) '[0-9a-f]{64}'|\\1 '$msi_x64'|" \
  -e "s|(\\\$packageArgs.checksum64 =) '[0-9a-f]{64}'|\\1 '$msi_arm64'|" \
  "$install"

# winget (kept in sync for testing; the submitted copy lives in microsoft/winget-pkgs)
old=$(ls "$root/winget/manifests/a/Akev/Akev")
if [ "$old" != "$version" ]; then
  git -C "$root" mv "winget/manifests/a/Akev/Akev/$old" "winget/manifests/a/Akev/Akev/$version" 2>/dev/null \
    || mv "$root/winget/manifests/a/Akev/Akev/$old" "$root/winget/manifests/a/Akev/Akev/$version"
fi
w="$root/winget/manifests/a/Akev/Akev/$version"
up=$(echo "$nsis_x64" | tr a-f A-F)
up_arm=$(echo "$nsis_arm64" | tr a-f A-F)
sed -i -E "s|^PackageVersion: .*|PackageVersion: $version|" "$w"/*.yaml
sed -i -E \
  -e "s|^ReleaseDate: .*|ReleaseDate: $date|" \
  -e "s|download/v[^/]*/Akev_[^_]*_x64-setup.exe|download/v$version/Akev_${version}_x64-setup.exe|" \
  -e "s|download/v[^/]*/Akev_[^_]*_arm64-setup.exe|download/v$version/Akev_${version}_arm64-setup.exe|" \
  "$w/Akev.Akev.installer.yaml"
awk -v x="$up" -v a="$up_arm" '
  /InstallerUrl:.*_x64-setup.exe/   { arch = "x64" }
  /InstallerUrl:.*_arm64-setup.exe/ { arch = "arm64" }
  /InstallerSha256:/ { sub(/InstallerSha256: .*/, "InstallerSha256: " (arch == "x64" ? x : a)) }
  { print }' "$w/Akev.Akev.installer.yaml" > "$w/.tmp" && mv "$w/.tmp" "$w/Akev.Akev.installer.yaml"
sed -i -E "s|releases/tag/v.*$|releases/tag/v$version|" "$w/Akev.Akev.locale.en-US.yaml"

echo "Updated to $version."
