# run.ps1
$simulator = "C:\Program Files (x86)\Corona Labs\Corona\Corona Simulator.exe"
$project = Get-Location
& $simulator $project
