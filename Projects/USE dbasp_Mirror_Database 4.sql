DBCC FREEPROCCACHE

EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPEDSQL0A','ContourDb',NULL,NULL,0,1,1;
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPEDSQL0A','DataLogDB',NULL,NULL,0,1,1;		
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPEDSQL0A','DenaliDB',NULL,NULL,0,1,1;		
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPEDSQL0A','EditorialSiteDB',NULL,NULL,0,1,1;	
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPEDSQL0A','EventServiceDb',NULL,NULL,0,1,1;	
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPEDSQL0A','NotificationDB',NULL,NULL,0,1,1;	

