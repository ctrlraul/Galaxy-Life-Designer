# Accepts path to godot as first parameter, if not present assumes there is a "godot" file in the desktop.

$WinRar = "C:/Program Files/WinRAR/winrar.exe"
$Godot = $args[0]

if (!$Godot) {

    $Desktop = [Environment]::GetFolderPath("Desktop")
    $Godot = Get-Childitem -Path $Desktop -Filter godot*.exe -File | ForEach-Object { $_.FullName }

    if (!$Godot.Count) {
        Throw "Godot path not found"
    }

}


":: Building for windows"
& $Godot[0] --path $PSScriptRoot -q --quit --headless --export-release "Windows Desktop" "windows/build/Galaxy Life Layout Maker.exe" | Out-Null


# ":: Copying over Windows build" # So it gets bundled to web automatically
# Copy-Item "windows/build/gllm.exe" -Destination "web/release_template/gllm.exe" | Out-Null


":: Building Web release_template.zip"
Set-Location web/release_template
& $WinRar a -qo+ -r ../release_template.zip | Out-Null
Set-Location $PSScriptRoot


":: Building for Web"
& $Godot[0] --path $PSScriptRoot -q --quit --headless --export-release Web web/build/index.html | Out-Null


Read-Host -Prompt "Press Enter to exit"