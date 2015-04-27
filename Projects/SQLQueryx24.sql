SET NOCOUNT ON

Declare		@cmd 			VarChar(8000)
			,@Path_Backup	VarChar(8000)
			,@File_Backup	VarChar(8000)
			,@File_Log		VarChar(8000)
			,@DBName		sysname
			,@SizeTotal		bigint
			,@SizeDone		bigint
			,@PercentDone	Float
			,@LastPctDone	Float
			,@Delay			INT
			,@DelayTemp		DateTime

SELECT		@Path_Backup	= '\\GINSSQLDEV04-N\GINSSQLDEV04-N$A_backup'
			,@File_Backup	= 'GSsearch.SQB'
			,@DBName		= 'GSsearch'
			,@File_Log		= @DBName + '_Restore_Status.log'
			,@Delay			= 5
			,@DelayTemp		= 0	
										
DECLARE @filelist		TABLE
							(
							LogicalName nvarchar(128) null, 
							PhysicalName nvarchar(260) null, 
							Type char(1) null, 
							FileGroupName nvarchar(128) null, 
							Size numeric(20,0) null, 
							MaxSize numeric(20,0) null,
							FileId bigint null,
							CreateLSN numeric(25,0) null,
							DropLSN numeric(25,0) null,
							UniqueId uniqueidentifier null,
							ReadOnlyLSN numeric(25,0) null,
							ReadWriteLSN numeric(25,0) null,
							BackupSizeInBytes bigint null,
							SourceBlockSize int null,
							FileGroupId int null,
							LogGroupGUID sysname null,
							DifferentialBaseLSN numeric(25,0) null,
							DifferentialBaseGUID uniqueidentifier null,
							IsReadOnly bit null,
							IsPresent bit null,
							TDEThumbprint varbinary(32) null
							)

DECLARE @status		TABLE
							(
							[Database]		sysname null,
							[Login]			sysname null,
							[Processed]		bigint null,
							[Compressed]	bigint null,
							[process]		VarChar(10) null,
							[type]			VarChar(10) null,
							[compression]	VarChar(10) null,
							[encryption]	VarChar(10) null,
							[start_date]	DateTime null
							)

checkpercentdone:

DELETE FROM @status
DELETE FROM @filelist
							
SET @cmd = 'Exec master.dbo.sqlbackup ''-SQL "RESTORE FILELISTONLY FROM DISK = '''''+@Path_Backup+'\'+@File_Backup+'''''"'''
	insert into @filelist(LogicalName,PhysicalName,Type,FileGroupName,Size,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,IsPresent)
	EXEC (@cmd)

SET @cmd = 'Exec master.dbo.sqbstatus 1'
	insert into @status([Database],[Login],[Processed],[Compressed],[process],[type],[compression],[encryption],[start_date])
	EXEC (@cmd)

SELECT @SizeTotal = SUM([Size]) FROM @filelist
SELECT @SizeDone = [Processed] FROM @status WHERE [Database] = @DBName
SELECT @PercentDone = (@SizeDone * 100.0)/@SizeTotal

SELECT @CMD	= 'Restore of ' + @DBName + ' ('+ dbaadmin.dbo.dbaudf_FormatNumber(@SizeTotal,16,0)+' bytes ): Processed ' + dbaadmin.dbo.dbaudf_FormatNumber(@SizeDone,16,0) +' bytes : Percent Done = '+ dbaadmin.dbo.dbaudf_FormatNumber(@PercentDone,5,2) + '    ' + CAST(GetDate() AS VarChar(50))
RAISERROR (@CMD,-1,-1) WITH NOWAIT

EXEC	dbaadmin.dbo.dbasp_FileAccess_Write @CMD,@Path_Backup,@File_Log,1

IF EXISTS (SELECT * FROM @status)
BEGIN
	IF COALESCE(@LastPctDone,@PercentDone) = @PercentDone
		SET @Delay = @Delay * 2
		
	SET @CMD = 'WAITFOR DELAY '''+CONVERT(VarChar(8),DATEADD(second,@Delay,@DelayTemp),8)+''''
	PRINT @CMD
	EXEC (@CMD)
	GOTO checkpercentdone
END

PRINT 'Restore of ' + @DBName + ' is Done...    ' + CAST(GetDate() AS VarChar(50))

--SELECT @SizeTotal [Total Size],@SizeDone [Processed],(@SizeDone * 100.0)/@SizeTotal [Percent Done]

go



