
param($filepath,$process_name)

Try
{
Get-Process -Name $process_name -ErrorAction Stop
write "The process is already running"
}

Catch
{
write "Starting the process"
Start-Process $filepath
}


while($true)
{

Try
{
Get-Process -Name $process_name -ErrorAction Stop
}

Catch
{
Start-Process $filepath
}

Start-Sleep -Seconds 5

}
