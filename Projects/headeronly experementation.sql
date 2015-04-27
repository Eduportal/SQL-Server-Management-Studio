
--RESTORE LABELONLY FROM DISK = '\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\Gestalt.SQB'

--Exec master.dbo.sqlbackup '-SQL "RESTORE LABELONLY FROM DISK = ''\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\Gestalt.SQB''"'

Exec master.dbo.sqlbackup '-SQL "RESTORE HEADERONLY FROM DISK = ''\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\Gestalt.SQB''"'




--Exec master.dbo.sqlbackup '-SQL "RESTORE FILELISTONLY FROM DISK = ''\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\Gestalt.SQB''"'


--SELECT top 10 * FROM [dbaadmin].[dbo].[dbaudf_FileAccess_Read] ('\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup','Gestalt.SQB')
--GO

DECLARE	@File		Varbinary(max)
DECLARE @Text1		nVarChar(max)
DECLARE @Text2		nVarChar(max)
DECLARE @Text3		nVarChar(max)
DECLARE @Text4		nVarChar(max)
DECLARE	@Loop		INT
DECLARE	@Ascii1		INT
DECLARE	@Ascii2		INT
DECLARE	@Unicode	INT
DECLARE @Flop		BIT
DECLARE @DYN		nVarChar(4000)

SELECT @File=BulkColumn FROM
OPENROWSET(BULK N'\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\tal_integration_db_20110727234723.BKP', SINGLE_BLOB) data
PRINT @File
PRINT CAST(@File AS VarChar(max))

SELECT @File=BulkColumn FROM
OPENROWSET(BULK N'\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\tal_integration_dfntl_20110728025743.DFL', SINGLE_BLOB) data
PRINT @File
PRINT CAST(@File AS VarChar(max))

SELECT @File=BulkColumn FROM
OPENROWSET(BULK N'\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\tal_integration_tlog_20110728031801.TNL', SINGLE_BLOB) data
PRINT @File
PRINT CAST(@File AS VarChar(max))

SELECT @File=BulkColumn FROM
OPENROWSET(BULK N'\\ASPSQLTEST01-N\ASPSQLTEST01-N$A_backup\dbaperf.SQB', SINGLE_BLOB) data
PRINT @File
PRINT CAST(@File AS VarChar(max))


PRINT Datalength(@File)
SET	@FLOP = 0
SET	@Text1 = ''
SET	@Text2 = ''
SET	@Text3 = ''
SET	@Text4 = ''
SET @Loop = 1
WHILE @Loop < 100000 --Datalength(@File)+1/10
BEGIN
	SET @Text4 = @Loop
	IF @Loop % 1000 = 0
		raiserror(@Text4,-1,-1)WITH NOWAIT
	SELECT	@Flop		= @Flop ^ 1
			,@Text1		= @Text1 + sys.fn_varbintohexsubstring(0,@File,@Loop,1)
			,@DYN		= 'SELECT @Unicode = CAST('+sys.fn_varbintohexsubstring(1,@File,@Loop,1)+' AS INT)'
			,@Loop		= @Loop + 1

	EXEC sp_executesql @DYN, N'@Unicode INT OUT',@Unicode OUT
	
	SELECT	@Unicode	= CASE WHEN @Unicode < 32 THEN 0 WHEN  @Unicode > 126 THEN 0 ELSE @Unicode END
			,@Text2		= @Text2 + NCHAR(@Unicode)
END

PRINT @File
PRINT @Text1
PRINT @Text2
PRINT @Text3
