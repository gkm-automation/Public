[cmdletBinding()]
param(
[string]$RemoteComputer = $env:COMPUTERNAME
)

$ParamHash = [ordered]@{
              Ping = $false
              FQDNCheck = $false
              RDPPortCheck = $false
              RDPServicecheck = $false
              }

Write-Host "Checking RDP Status for the Server $RemoteComputer.........." -ForegroundColor Yellow


try {

            if((Test-Connection -ComputerName $RemoteComputer -Count 1 -Quiet -ErrorAction SilentlyContinue -ErrorVariable test) -and ([System.Net.Dns]::GetHostEntry($RemoteComputer))) {

            $ParamHash.Ping = $true
            $ParamHash.FQDNCheck = $true
            if(New-Object Net.sockets.TcpClient($RemoteComputer,3389)) { $ParamHash.RDPPortCheck = $true }
           
            }

}
catch{
Write-Host " $_Exception.Message"
}

$ParamHash

