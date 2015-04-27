  
  
  
  
relog C:\SQLNexus\SQLDiagPerfStats\Output\DIAG$SQLDiag_A.BLG -f CSV -o C:\SQLNexus\SQLDiagPerfStats\Output\DIAG$SQLDiag_Server.csv -cf C:\SQLNexus\SQLDiagPerfStats\Filter_ServerSpecific.txt -y


LogParser "SELECT * INTO SQLDiag_Server FROM C:\SQLNexus\SQLDiagPerfStats\Output\DIAG$SQLDiag_Server.CSV" -i:CSV -iTsFormat:"MM/dd/yyyy hh:mm:ss.ll" -o:SQL -server:SEAFRESQLDBA01 -database:SQLNexus -driver:"SQL Server" -createTable:ON -clearTable:ON -fixColNames:ON




-o SQL:SQLNexus!SQLNexus -f SQL  -cf counterlist_small.txt  