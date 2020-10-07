Write-Host "---------------------------------------------"
Write-Host " Server Launcher - v0.2"
Write-Host "---------------------------------------------"
Write-Host "This script runs the latest snapshot/release."
Write-Host "When the server is shutdown, the script will "
Write-Host "update the server, and start it back up asap."
Write-Host "This script also can be used to install a new"
Write-Host "server instance."
Write-Host "---------------------------------------------"
Write-Host " https://github.com/demon2749"
Write-Host "---------------------------------------------"

while (1 -eq 1)
{
    if (Test-Path server.jar)
    {
        Write-Host "Starting the minecraft server..."
        java -Xmx2G -jar server.jar -nogui
    }else{
        Write-Host "The server will be installed. Press Ctrl+C to Cancel."
        timeout /t 8
    }

    $versions = 
        Invoke-WebRequest https://launchermeta.mojang.com/mc/game/version_manifest.json |
        Select-Object -ExpandProperty Content |
        ConvertFrom-Json | Select-Object -ExpandProperty versions
    
    $newest = $versions[0]
    
    $link = $newest | Select-Object -ExpandProperty url | Out-String
    
    $newVer =
        Invoke-WebRequest $link | Select-Object -ExpandProperty Content |
        ConvertFrom-Json | Select-Object -ExpandProperty downloads | 
        Select-Object -ExpandProperty server
    $sha = $newVer | Select-Object -ExpandProperty sha1 | Out-String 
    $download = $newVer | Select-Object -ExpandProperty url | Out-String
    
    if (Test-Path server.jar)
    {
        $currentSHA = Get-FileHash -Algorithm SHA1 -Path server.jar |
            Select-Object -ExpandProperty Hash | Out-String
    
        $sha = $sha.ToUpper()
    
        if ($sha -eq $currentSHA)
        {
            Write-Host "No need for an update!"
        }else{
            Remove-Item -Path server.jar
            Write-Host "Downloading server update..."
            Invoke-WebRequest $download -OutFile server.jar
        }
    }else{
        Write-Host "Downloading server files..."
        Invoke-WebRequest $download -OutFile server.jar
        Write-Host "Creating Eula.txt..."
        Remove-Item -Path eula.txt
        New-Item -Name eula.txt -Value "eula=true"
    }
    
    Write-Host "Server will start shortly. Press Ctrl+C to stop, or any key to skip the wait."
    timeout /t 5

}