param(
    $installerURL = "https://go.microsoft.com/fwlink/?LinkID=863265",
    $path = "C:\Softwares",
    $outFilePath = "$path\ndp472-kb4054530-x86-x64-allos-enu.exe"
)


function Install-DotNet472 {
    If(!(test-path $path))
    {
      New-Item -ItemType Directory -Force -Path $path
    }
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $installerURL -OutFile $outFilePath
    & "$outFilePath" /q
    while ($(Get-Process | Where-Object {$_.Name -like "*NDP472*"})) {
        Write-Host "Installing .Net Framework 4.7.2 ..."
        Start-Sleep -Seconds 5
    }

    Write-Host ".Net Framework 4.7.2 was installed successfully!"
}
Install-DotNet472