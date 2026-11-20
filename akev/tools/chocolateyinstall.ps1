$ErrorActionPreference = 'Stop'

$version = '0.1.1'
$base = "https://github.com/akevdev/akev/releases/download/v$version"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'msi'
  url64bit       = "$base/Akev_${version}_x64_en-US.msi"
  checksum64     = '3551bc88aa4f69b7d1942d327f0f2df11dc1ab76cd8bf7b51f31266b1468526b'
  checksumType64 = 'sha256'
  softwareName   = 'Akev'
  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($env:ChocolateyPackageName).$($env:ChocolateyPackageVersion).MsiInstall.log`""
  validExitCodes = @(0, 3010, 1641)
}

# Windows on Arm gets the native arm64 build.
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') {
  $packageArgs.url64bit   = "$base/Akev_${version}_arm64_en-US.msi"
  $packageArgs.checksum64 = '8f954be0595f203f2dc1d83a45876311f6952928aa22ad0d9db9d51d17712995'
}

Install-ChocolateyPackage @packageArgs
