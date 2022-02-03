function geraLog([string]$hname, [string]$msn){
    $date = Get-Date
    $log = $date.ToString() + " - " + $hname + " - " + $msn
    #$log| Out-File C:\Temp\CommandLog.log -Append
    #$log| Out-File C:\Temp\CommandLogReg.log -Append
    Write-Output $log
}
##########################################################################

$computers = Get-Content "C:\temp\computers.txt"

foreach ($computer in $computers) {
    if (test-Connection $computer -Count 1 -quiet) {
        
        $TestComputer = '\\'+$computer+'\c$'
        
        if (Test-Path $TestComputer -ErrorAction SilentlyContinue){
            
			#1 Script-Executable
            $argumentos = '\\'+$computer+ ' -s -d powershell -noprofile -executionpolicy bypass -file \\<path>\Script_or_Executable'
			
						#2 Script-Executable
			            #$argumentos = '\\'+$computer+ ' -s -d powershell -noprofile -executionpolicy bypass -file \\<path\Script_or_Executable'
						
									#3 Script-Executable
						            #$argumentos = '\\'+$computer+ ' -s -d powershell -noprofile -executionpolicy bypass -file \\<path\Script_or_Executable'
									
												#4 Script-Executable
									            #$argumentos = '\\'+$computer+ ' -s -d powershell -noprofile -executionpolicy bypass -file \\<path\Script_or_Executable'


            
            Start-Process -FilePath C:\Windows\psexec.exe -ArgumentList $argumentos 
            geraLog $computer 'Sucesso - Enviado Comando PSExec'
        }
        else { geraLog $computer 'Falha - Não localizado C$'}
    } 
    else { geraLog $computer 'Falha - Computador Desligado'}
}