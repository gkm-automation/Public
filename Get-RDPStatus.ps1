[cmdletBinding()]
param(
[string]$RemoteComputer = $env:COMPUTERNAME
)

#RDP Service arrary
$RDPServices =@("TermService","UmRdpService")

$ParamHash = [ordered]@{
              Ping = "Failed."
              FQDN = "Failed."
              RDPPort = "Failed."
              RDPServices = "Failed."
              RDPSettings = "Disabled."
              RDPwithNLA = "Enabled."
              }

     Write-Host "Checking the status for $RemoteComputer.........." -ForegroundColor Yellow
    
     try {

            if((Test-Connection -ComputerName $RemoteComputer -Count 1 -Quiet -ErrorAction SilentlyContinue -ErrorVariable ErrVar1) -and ([System.Net.Dns]::GetHostEntry($RemoteComputer))) {

                        $ParamHash["Ping"] = "Ok."
                        $ParamHash["FQDN"] = "Ok."
            
                        #Check the Firewall            
                        if(New-Object Net.sockets.TcpClient($RemoteComputer,3389)){ 
                        $ParamHash["RDPPort"] = "Ok." 
                        }
                        else{ 
                        $ParamHash["RDPPort"] = "Failed." 
                        }
            
                        #Check the Services            
                        if($RDPServices|ForEach-Object{ Get-WmiObject Win32_Service -ComputerName $RemoteComputer -Filter "Name = '$($_)' and state = 'Stopped'"}){
                        $ParamHash["RDPServices"] = "Failed."
                        }
                        else{
                        $ParamHash["RDPServices"] = "Ok." 
                        }
                       
                        #Check the RDP Settings(Enabled\Disabled)
                        if((Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -ComputerName $RemoteComputer -Authentication 6).AllowTSConnections -eq 1) {
                        $ParamHash["RDPSettings"] = "Enabled."          
                        }
                         
                        #Check the RDP NLA Settings	
                        if((Get-WmiObject -class Win32_TSGeneralSetting -Namespace root\cimv2\terminalservices -ComputerName $RemoteComputer -Filter "TerminalName='RDP-tcp'" -Authentication 6).UserAuthenticationRequired -eq 0 ){
                        $ParamHash["RDPwithNLA"] = "Disabled."          
                        }
                        
            }
            else{
                      if(!($ErrVar1)){$ParamHash["Ping"] = "Ok."}
                      $ParamHash["RDPSettings"] = "Failed.."
                      $ParamHash["RDPwithNLA"] = "Failed."

                 }
                              

    }
    catch{
    Write-Host "$_Exception.Message" -ForegroundColor Red
    }

    $ParamHash.Keys | ForEach-Object {  "{0}`t`t`t{1}" -f $_,$($ParamHash[$_]) }
