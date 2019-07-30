#Confirm if HyperV is enabled/Installed:

    $Hypervstate = (Get-WindowsOptionalFeature -online | Where {$_.FeatureName -eq "Microsoft-Hyper-V"}).state

            IF(!($Hypervstate)){
    Write-Host "HyperV not installed or enabled on this machine"
    $Choice = Read-Host "Install now? Y/y or N/n"

        IF($Choice -match "y"){
        
        Write-Host "Installing Hyper-V......" -ForegroundColor Yellow
        Write-Host ".......Reboot will be needed" -ForegroundColor Yellow
        Write-Host "Once rebooted, re-run this script......" -ForegroundColor Yellow
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
        restart-computer -Confirm

                              }

        IF($Choice -match "n"){
        
        Write-Host "HyperV needed for this script to run" -ForegroundColor Yellow
        break;
        
                              }

                                }


#Download and Install Minikube Stable version to C:\WINDOWS\System32\:

    $stableversion = ((Invoke-WebRequest https://storage.googleapis.com/kubernetes-release/release/stable.txt).Content).trim()
    $link = "https://storage.googleapis.com/kubernetes-release/release/$stableversion/bin/windows/amd64/kubectl.exe"
    $newlink = $link
    $name = 'kubectl.exe'
    $filepath = "C:\WINDOWS\System32\"
    $filename = $filepath+$name

    Invoke-WebRequest -Uri $newlink -OutFile $filename

        $kubeinstall = Test-Path "$env:windir\System32\kubectl.exe"

            IF($kubeinstall){

            "Kubectl.exe installed on $env:windir\System32"

                            }


#Download and Install Chocholatey Package manager then install minikube/ kubernetes-cli:
#YOUR RESPONSIBILITY TO VALIDATE LINK to 'install.ps1' is correct :)

    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install minikube -y --force
    choco install kubernetes-cli -y --force


#Finds local active adapter:

    $liveadapter = Get-NetAdapter -Name "*" -Physical | where {$_.status -eq 'up'}
    $adapter = $liveadapter.Name
    $minikubeswitchname = "mk_external"

#create External HyperV switch if not found and attaches to local active adapter:
 
    New-VMSwitch -name $minikubeswitchname  -NetAdapterName $adapter -AllowManagementOS $true


#start minikube locally with HyperV driver:

    minikube start --vm-driver "hyperv" --hyperv-virtual-switch "mk_external"

    
#get minikube nodes:
    
    kubectl get nodes


#get minikube status:

    minikube status


#start minikube dashboard:
#Takes a bit to start if run for the 1st time, patience :)

    minikube dashboard
