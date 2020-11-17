

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$downloadURL = "http://www.python.org/ftp/python/3.8.6/python-3.8.6-amd64.exe"
$downloadPath = "D:\templary"
$downloadFile = "python-3.8.6-amd64.exe"

function downloads {
    if ( Test-Path -Path $downloadPath\$downloadFile ) {
       Write-Host "Exist file : $downloadFile "
    }
    else { 
        if ( !( Test-Path -Path $downloadPath ) ) {
         Write-Host " $downloadPath is Not exist. Create directory."
         mkdir -Path $downloadPath
        }
        Invoke-WebRequest -Uri ${URL} -OutFile $downloadPath\$downloadFile
    }
}

function install_python {
    Write-Host "Install..... $downloadPath/$downloadFile"
    Start-Process $downloadPath\$downloadFile
}

function install_package {
    Write-Host "Install..... required package"
    pip.exe install pip --upgrade
    pip.exe install boto3 paramiko typing 
}

# Main
downloads
install_python
install_package

