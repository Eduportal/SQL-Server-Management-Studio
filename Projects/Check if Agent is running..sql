IF NOT EXISTS (SELECT * FROM master.dbo.sysprocesses WITH (nolock) WHERE Program_Name LIKE 'SQLAgent%')
BEGIN
	PRINT 'AGENT NOT RUNNING'
	RAISERROR('DBA ERROR: SQL Agent Service is not Running.',16,1)
END	
GO