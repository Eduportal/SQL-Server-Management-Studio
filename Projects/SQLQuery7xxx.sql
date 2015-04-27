SELECT TOP 1 Detail01 FROM dbo.no_check WHERE NoCheck_type = 'OSmemory'

exec dbo.dbasp_add_nocheck


exec dbaadmin.dbo.dbasp_add_nocheck @nocheck_type = 'OSmemory'               -- OSmemory
                                   ,@detail01 = '6144'                       -- Memory for OS (in MB)
                                   
                                   
                                   
EXEC DBAADMIN.[dbo].[dbasp_check_SQLhealth] @verbose = 0