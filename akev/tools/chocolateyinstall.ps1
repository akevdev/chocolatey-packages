$ErrorActionPreference = 'Stop'

$version = '0.1.0'
$base = "https://github.com/akevdev/akev/releases/download/v$version"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'msi'
  url64bit       = "$base/Akev_${version}_x64_en-US.msi"
  checksum64     = '279c3f941a9c62c5e80ec58a78be33d0d5fcc7ef213e84bcb01e6adaf36a1a44'
  checksumType64 = 'sha256'
  softwareName   = 'Akev'
  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($env:ChocolateyPackageName).$($env:ChocolateyPackageVersion).MsiInstall.log`""
  validExitCodes = @(0, 3010, 1641)
}

# Windows on Arm gets the native arm64 build.
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') {
  $packageArgs.url64bit   = "$base/Akev_${version}_arm64_en-US.msi"
  $packageArgs.checksum64 = '8f480b318622c1b60d431f71ff563daff2b992054243e096b10d66f1b70b5990'
}

Install-ChocolateyPackage @packageArgs
