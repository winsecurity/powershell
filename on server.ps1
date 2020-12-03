
# Assuming this script runs as Administrator

Set-ExecutionPolicy Unrestricted

# Desktop Path of user
$desktop = [System.Environment]::GetFolderPath("Desktop")

# Resources to download
$debugger_url = "https://drive.google.com/uc?id=1jnJQ9AADa31O8lohkMuPMzDtq1wfoyJF&export=download"
$python2_url = "https://www.python.org/ftp/python/2.7/python-2.7.msi"
$monapy_url = "https://drive.google.com/u/1/uc?id=1cOSNKiwrc_EqRV92MQzlz8R_8hdMW0NZ&export=download"
$vuln_exe = "https://github.com/Nikhilthegr8/custom_vulnerable_executables/raw/master/custom_vulnerable_executables/Mr.NOPs/mr.nops.exe"
$pattern_generator = "https://drive.google.com/u/1/uc?id=1j2jgtE_okOTOzQIfr7QQm4AwoQ9-6xSK&export=download"
$python3_url = "https://www.python.org/ftp/python/3.9.0/python-3.9.0-amd64.exe"
$essfuncdll = "https://github.com/Nikhilthegr8/custom_vulnerable_executables/raw/master/custom_vulnerable_executables/Mr.NOPs/essfunc.dll"


# Downloading Resources to user's Desktop
mkdir "$desktop\temp"
Invoke-WebRequest -Uri $debugger_url -OutFile "$desktop\temp\immunity_debugger.exe"
Invoke-WebRequest -Uri $python2_url -OutFile "$desktop\temp\python2.msi"
Invoke-WebRequest -Uri $monapy_url -OutFile "$desktop\temp\mona.py"
Invoke-WebRequest -Uri $vuln_exe -outfile "$desktop\pwn.exe"
Invoke-WebRequest -Uri $pattern_generator -OutFile "$desktop\pattern_generator.py"
Invoke-WebRequest -Uri $python3_url -OutFile "$desktop\temp\python3.msi"
Invoke-WebRequest -Uri $essfuncdll -OutFile "$desktop\essfunc.dll"


# Installing Resources
# First we need to install python 2.7 as it is requirement for immunity debugger
# there will be error install python2.7 , its better to execute with msiexec.exe

#Start-Process -Wait "$desktop\temp\python2.exe" -ArgumentList "/S" -PassThru

$arguments = "/i `"$desktop\temp\python2.msi`" /quiet"
Start-Process msiexec.exe -ArgumentList $arguments -Wait

# Setting Python2.7 path to environment variable 

$env:Path += ";C:\Python27\python.exe"

$arguments = "/i `"$desktop\temp\python3.msi`" /quiet"
Start-Process msiexec.exe -ArgumentList $arguments -Wait

#Start-Process -Wait "$desktop\temp\python3.exe" -ArgumentList "/S" -PassThru
Start-Process -Wait "$desktop\temp\immunity_debugger.exe" -ArgumentList "/S" -PassThru

# Copying mona.py to immunity debugger's pycommand folder 
#   C:\Program Files (x86)\Immunity Inc\Immunity Debugger
Copy-Item -Path "$desktop\temp\mona.py" -Destination "C:\Program Files (x86)\Immunity Inc\Immunity Debugger\PyCommands\"


# Setting up Firewall Rules to block all incoming connections except that of pwn binary's

#New-NetFirewallRule -DisplayName "Block other ports" -Direction Inbound -LocalPort 0-9998,10000-65535 -Action Block 
#New-NetFirewallRule -DisplayName "Allowing pwn binary port" -Direction Inbound -LocalPort 9999 -Action Allow

#New-NetFirewallRule -DisplayName "Block other ports" -Direction Inbound -RemotePort 0-9998,10000-65535 -Action Block 
#New-NetFirewallRule -DisplayName "Allowing pwn binary port" -Direction Inbound -RemotePort 9999 -Action Allow

# Allowing our binary to connections

New-NetFirewallRule -DisplayName "Inbound to pwn binary" -Program "$desktop\pwn.exe" -Direction Inbound -Action Allow 
New-NetFirewallRule -DisplayName "Outbound to pwn binary" -Program "$desktop\pwn.exe" -Direction Outbound -Action Allow 


# Almost set
# Let's Monitor our pwn binary


Try
{
$process = Get-Process -Name "pwn" -ErrorAction Stop
#write "The process is already running"
}

Catch
{
#write "Starting the process"
Start-Process "$desktop\pwn.exe"
}

while($true)
{

Try
{
$process = Get-Process -Name "pwn" -ErrorAction Stop
}
Catch
{
Start-Process "$desktop\pwn.exe"
}
Start-Sleep -Seconds 5
}




