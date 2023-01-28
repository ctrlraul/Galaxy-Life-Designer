# Accepts path to godot as first parameter, if not present assumes there is a "godot" file in the desktop.

$WinRar = "C:/Program Files/WinRAR/winrar.exe"
$Godot = $args[0]

if (!$Godot) {

    $Desktop = [Environment]::GetFolderPath("Desktop")
    $Godot = Get-Childitem -Path $Desktop -Filter godot*.exe -File | ForEach-Object { $_.FullName }

    if (!$Godot.Count) {
        Throw "Godot path not found and not passed as argument"
    }

}

$ProjectSourceDir = Join-Path $PSScriptRoot "src"


":: Building Release Template for Web"
Set-Location web/release_template_src
& $WinRar a -qo+ -r ../release_template.zip | Out-Null
Set-Location $PSScriptRoot
""

":: Building for Windows"
& $Godot[0] --path $ProjectSourceDir -q --quit --headless --export-release "Windows Desktop" "../windows/build/Galaxy Life Layout Maker.exe" | Out-Null
""


":: Building for Web"
& $Godot[0] --path $ProjectSourceDir -q --quit --headless --export-release Web ../web/build/index.html | Out-Null
""


Read-Host -Prompt "Finished! [Enter to exit]"
