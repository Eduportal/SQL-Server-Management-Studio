
USE Tfs_Configuration

DECLARE @TSQL VarChar(max)

SET	@TSQL = 'use [?];if object_id(''Tbl_TransactionLogMark'') IS NOT NULL DROP Table [?].[dbo].[Tbl_TransactionLogMark];'
exec	sp_msforeachdb @TSQL

SET	@TSQL = 'Create Table [?].[dbo].[Tbl_TransactionLogMark](logmark int)'
exec	sp_msforeachdb @TSQL

SET	@TSQL = 'Insert into [?].[dbo].[Tbl_TransactionLogMark] (logmark) Values (1)'
exec	sp_msforeachdb @TSQL

SET	@TSQL = 'USE ?;if object_id(''sp_SetTransactionLogMark'') IS NOT NULL AND ''?'' != ''master'' DROP Procedure dbo.sp_SetTransactionLogMark'
exec	sp_msforeachdb @TSQL

SET	@TSQL = 
'USE ?;
exec(''Create PROCEDURE dbo.sp_SetTransactionLogMark
(@name nvarchar (128))
AS
BEGIN TRANSACTION @name WITH MARK;
UPDATE TFS_Configuration.dbo.Tbl_TransactionLogMark SET logmark = 1;
COMMIT TRANSACTION @name;'')
'
exec	sp_msforeachdb @TSQL


SET	@TSQL = 'USE Tfs_Configuration;if object_id(''sp_SetTransactionLogMarkAll'') IS NOT NULL DROP Procedure dbo.sp_SetTransactionLogMarkAll'
EXEC	(@TSQL)


SET	@TSQL = 
'USE Tfs_Configuration;
EXEC(''
CREATE PROCEDURE dbo.sp_SetTransactionLogMarkAll
@name nvarchar (128)
AS
BEGIN TRANSACTION
'

SELECT	@TSQL = @TSQL + 'EXEC '+QUOTENAME(@@SERVERNAME)+'.'+QUOTENAME(name)+'.[dbo].[sp_SetTransactionLogMark] @name' + CHAR(13)+CHAR(10)
FROM master.sys.databases where database_id > 4 and name not in ('dbaadmin','dbaperf','deplinfo')

SELECT @TSQL = @TSQL +
'COMMIT TRANSACTION'')'

EXEC (@TSQL)

GO




--CODE ADDED TO EACH BACKUP STEP.


exec Tfs_Configuration.dbo.sp_SetTransactionLogMarkAll 'TFSMark'

WAITFOR DELAY '00:01:00'

--DO BACKUP

