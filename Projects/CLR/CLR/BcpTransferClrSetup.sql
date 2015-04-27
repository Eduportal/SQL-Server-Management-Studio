EXEC sp_configure 'clr enabled', 1
GO

reconfigure
go

DECLARE @alterCmd nvarchar(4000)

SET @alterCmd = 'ALTER DATABASE ' + db_name() + ' SET Trustworthy ON'

EXEC (@alterCmd)
