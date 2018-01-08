# SetVersion.ps1
#
# Set the version in all the AssemblyInfo.cs or AssemblyInfo.vb files in any subdirectory.
#
# usage:
#  from cmd.exe:
#     powershell.exe Set-Version.ps1  2.8.3.0
#
#  from powershell.exe prompt:
#     .\Set-Version.ps1  2.8.3.0

function Update-SourceVersion
{
  Param ([string]$Version)
  $NewVersion = 'AssemblyVersion("' + $Version + '")';
  $NewFileVersion = 'AssemblyFileVersion("' + $Version + '")';
  $NewInformationalVersion = 'AssemblyInformationalVersion("' + $Version + '")';

  foreach ($o in $input)
  {
    $p = $o.FullName
    Write-output "Updating Version in $p"
    $TmpFile = $o.FullName + ".tmp"

     get-content $o.FullName |
        %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewFileVersion } |
        %{$_ -replace 'AssemblyInformationalVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewInformationalVersion } |
        Out-File -Encoding utf8 $TmpFile

     move-item $TmpFile $o.FullName -force
  }
}

function Update-AllAssemblyInfoFiles ( $version )
{
  foreach ($file in "AssemblyInfo.cs", "AssemblyInfo.vb" )
  {
    get-childitem -recurse |? {$_.Name -eq $file} | Update-SourceVersion $version ;
  }
}


Update-AllAssemblyInfoFiles $args[0];
