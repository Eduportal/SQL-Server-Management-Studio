

UPDATE dbacentral.dbo.DBA_DBInfo
SET DEPLstatus = 'N'
where dbname = 'dataextract' 
and envnum <> 'production'


DELETE deplcontrol.dbo.Base_Appl_Info 
where dbname = 'dataextract' 
and envnum <> 'production'
