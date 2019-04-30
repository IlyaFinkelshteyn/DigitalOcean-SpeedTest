Import-Module BitsTransfer

Push-Location $PSScriptRoot

try {
    $DigitalOceanToken = $env:DOTokenSecure
    $DockerMachine = 'Appveyor-SpeedTest'

    $start_time = Get-Date
    Write-Host "Started download of docker image at " $start_time
    Start-BitsTransfer -Source "http://aoa.cczy.my/stuff/postgres-latest.tar" -Destination "$PSScriptRoot/postgres-latest.tar"
    $end_time = Get-Date
    Write-Host "Completed download of docker image at " $end_time
    Write-Host "Time taken: " $end_time.Subtract($start_time)

    docker-machine create --driver digitalocean --digitalocean-access-token $DigitalOceanToken `
        --digitalocean-region='nyc3' --digitalocean-size='c-32' $DockerMachine
	
    docker-machine ls
    docker-machine env --shell powershell $DockerMachine
    docker-machine env --shell powershell $DockerMachine | Invoke-Expression
    #see which is active
    docker-machine active
    
    Write-Host "List remote docker images"
    docker images

    $start_time = Get-Date
    Write-Host "Started loading of docker image to DigitalOcean at " $start_time
    docker load -i "$PSScriptRoot/postgres-latest.tar"
    $end_time = Get-Date	
    Write-Host "Completed loading of docker image to DigitalOcean at " $end_time
    Write-Host "Time taken: " $end_time.Subtract($start_time)

    Write-Host "List remote docker images"
    docker images
}
finally {
    if ($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode) }
    Pop-Location
}
