DBCC FREEPROCCACHE

EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','DataLogDB',NULL,NULL,0,1,1;	
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','DeliveryDB',NULL,NULL,0,1,1;	
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','FeedsDB',NULL,NULL,0,1,1;		
EXEC [dbaadmin].[dbo].[dbasp_Mirror_Database] 'SEAPSQLDIST0A','IngestionDB',NULL,NULL,0,1,1;