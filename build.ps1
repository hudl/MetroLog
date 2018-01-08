param (
   [Parameter(Mandatory=$true)][int]$buildNumber = 1,
   [string]$nugetApiKey,
   [string]$nugetPushSource
)

$target = "Release"
$branch = git rev-parse --abbrev-ref HEAD
$branch = $branch -replace '[-]',''

if ($branch.Length+($buildNumber.ToString().Length) -gt 20) {
  $branch = $branch.SubString(0, 20 - ($buildNumber.ToString().Length + 1))
}

$version = "1.1.0-$branch$buildNumber"

$dotNetVersion = "14.0"
$regKey = "HKLM:\software\Microsoft\MSBuild\ToolsVersions\$dotNetVersion"
$regProperty = "MSBuildToolsPath"
$msbuildExe = join-path -path (Get-ItemProperty $regKey).$regProperty -childpath "msbuild.exe"

Write-Host "TARGET: $target"
Write-Host "VERSION: $version"
Write-Host "MSBUILD: $msbuildExe"

./.nuget/nuget.exe restore

./set-version.ps1 $version

&$msbuildExe HudlMetroLog.sln /m /p:platform=Hudl /p:Configuration=Release /nologo

./.nuget/nuget.exe pack HudlMetroLog.nuspec -version $version -prop "target=$target" -NoPackageAnalysis

if ([string]::IsNullOrEmpty($nugetApiKey) -ne $true) {
  ./.nuget/nuget.exe push "HudlMetroLog.$version.nupkg" -ApiKey $nugetApiKey -Source $nugetPushSource
} else {
  write-host "NuGet API key not supplied. will not publish."
}
