Push-Location $PSScriptRoot

try {
    $DigitalOceanToken = $env:DOTokenSecure
    $DockerMachine = 'Appveyor-SpeedTest'

    Write-Host "List local docker images"
    docker images
    
    Write-Host "Pulling postgres:latest"
    docker pull postgres:latest

    Write-Host "List local docker images"
    docker images

    Write-Host "Save postgres:latest to file"
    docker save -o "$PSScriptRoot/postgres-latest.tar" "postgres:latest"

    docker-machine create --driver digitalocean --digitalocean-access-token $DigitalOceanToken `
        --digitalocean-region='nyc3' --digitalocean-size='c-32' $DockerMachine
	
    docker-machine ls
    docker-machine env --shell powershell $DockerMachine
    docker-machine env --shell powershell $DockerMachine | Invoke-Expression
    #see which is active
    docker-machine active
    
    Write-Host "List remote docker images"
    docker images

    Write-Host "Start loading of docker image to DigitalOcean: " Get-Date
    docker load -i "$PSScriptRoot/postgres-latest.tar"	
    Write-Host "Completed loading of docker image to DigitalOcean: " Get-Date

    Write-Host "List remote docker images"
    docker images
}
finally {
    if ($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode) }
    Pop-Location
}
