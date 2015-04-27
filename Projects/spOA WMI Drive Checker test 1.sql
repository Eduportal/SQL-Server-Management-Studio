USE [dbaadmin]
GO

SET NOCOUNT ON
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--ALTER FUNCTION [dbo].[dbaudf_ListDrives]()
--RETURNS 
DECLARE @DriveList Table
		(
		[DriveLetter]					CHAR(1)
		,[TotalSize]					BigInt
		,[FreeSpace]					BigInt
		,[DriveType]					VarChar(50)
		,[SerialNumber]					VarChar(50)
		,[FileSystem]					VarChar(10)
		,[Compressed]					BIT
		,[SupportsFileBasedCompression]	BIT
		,[SupportsDiskQuotas]			BIT
		,[QuotasDisabled]				BIT
		,[QuotasIncomplete]				BIT
		,[QuotasRebuilding]				BIT
		,[VolumeDirty]					BIT
		,[SAN]							BIT
		,[Ready]						BIT
		,[VolumeName]					VARCHAR(255)
		)
--AS
--BEGIN

	DECLARE @DriveLoop					INT
	DECLARE @WmiServiceLocator			INT
	DECLARE	@WMISERVICE					INT
	DECLARE	@WMISERVICE2				INT
	DECLARE	@WMISERVICE3				INT
	DECLARE @DriveCount					INT
	DECLARE @PDrives					INT
	DECLARE @PDrive						INT
	DECLARE @LDrives					INT
	DECLARE @LDrive						INT
	DECLARE @LD2Ps						INT
	DECLARE @LD2P						INT
	DECLARE @PD2Ps						INT
	DECLARE @PD2P						INT
	DECLARE @Property					NVARCHAR(500)
	DECLARE @Results					VARCHAR(8000)
	DECLARE @Results_int				BIGINT
	DECLARE @Results_int2				INT
	DECLARE	@Results_bol				BIT
	DECLARE @hr							INT
	DECLARE @RetryCount					INT
	DECLARE	@Query						VarChar(8000)
	DECLARE	@wmiObjectCount				INT
	DECLARE	@loopIdx					INT
	DECLARE	@oleSource                  NVARCHAR(500)
    DECLARE	@oldDesc                    NVARCHAR(500)

	SET	@DriveLoop						= 65

	step0:
	SET	@RetryCount	= 0
	exec	@hr		= sp_OACreate 'WbemScripting.SWbemLocator', @WmiServiceLocator output; 
	IF @hr != 0 
	BEGIN
		SET @RetryCount = @RetryCount + 1
		IF @RetryCount > 5 
		BEGIN
			INSERT INTO @DriveList ([DriveLetter],[SerialNumber],[DriveType]) VALUES('!',@hr,'ERROR CREATING WbemScripting.SWbemLocator')
			goto endfunct
		END
		goto step0
	END
	--PRINT @WmiServiceLocator
	
	
	step1:
	SET	@RetryCount	= 0
	exec	@hr		= sp_OAMethod @WmiServiceLocator, 'ConnectServer', @WmiService output, '.', 'root\cimv2'; 
	IF @hr != 0 
	BEGIN
		SET @RetryCount = @RetryCount + 1
		IF @RetryCount > 5 
		BEGIN
			INSERT INTO @DriveList ([DriveLetter],[SerialNumber],[DriveType]) VALUES('!',@hr,'ERROR CONNECTING TO WMI root\cimv2')
			goto endfunct
		END
		goto step1
	END
	--PRINT @WmiService
	
	
	step2a:
	SET	@RetryCount	= 0
	exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @LDrives output, 'Select * from Win32_LogicalDisk';
	IF @hr != 0 
	BEGIN
		SET @RetryCount = @RetryCount + 1
		IF @RetryCount > 5 
		BEGIN
			INSERT INTO @DriveList ([DriveLetter],[SerialNumber],[DriveType]) VALUES('!',@hr,'ERROR GETTING Logical Drives')
			goto endfunct
		END
		goto step2a
	END
	--PRINT @LDrives
	
	
	step2b:
	SET	@RetryCount	= 0
	exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @PDrives output, 'Select * from Win32_DiskDrive';
	IF @hr != 0 
	BEGIN
		SET @RetryCount = @RetryCount + 1
		IF @RetryCount > 5 
		BEGIN
			INSERT INTO @DriveList ([DriveLetter],[SerialNumber],[DriveType]) VALUES('!',@hr,'ERROR GETTING Physical Drives')
			goto endfunct
		END
		goto step2b
	END
	--PRINT @PDrives
	
	
	--step2c:
	--SET	@RetryCount	= 0
	--exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @LD2Ps output, 'Select * from Win32_LogicalDiskToPartition';
	--IF @hr != 0 
	--BEGIN
	--	SET @RetryCount = @RetryCount + 1
	--	IF @RetryCount > 5 
	--	BEGIN
	--		INSERT INTO @DriveList ([DriveLetter],[SerialNumber],[DriveType]) VALUES('!',@hr,'ERROR GETTING Logical Disk to Partition Lookup')
	--		goto endfunct
	--	END
	--	goto step2c
	--END
	----PRINT @LD2Ps
	
	
	step2d:
	SET	@RetryCount	= 0
	exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @PD2Ps output, 'Select * from Win32_DiskDriveToDiskPartition';
	IF @hr != 0 
	BEGIN
		SET @RetryCount = @RetryCount + 1
		IF @RetryCount > 5 
		BEGIN
			INSERT INTO @DriveList ([DriveLetter],[SerialNumber],[DriveType]) VALUES('!',@hr,'ERROR GETTING Physical Disk to Partition Lookup')
			goto endfunct
		END
		goto step2d
	END
	--PRINT @PD2Ps
	
	
	step3:
	SET	@RetryCount	= 0
	exec	@hr		= sp_OAGetProperty @LDrives,'Count', @DriveCount OUT
	IF @hr != 0 
	BEGIN
		SET @RetryCount = @RetryCount + 1
		IF @RetryCount > 5 
		BEGIN
			INSERT INTO @DriveList ([DriveLetter],[SerialNumber],[DriveType]) VALUES('!',@hr,'ERROR GETTING Drives.Count')
			goto endfunct
		END
		goto step3
	END
	--PRINT @DriveCount
		
	
	WHILE @DriveLoop < 91
	BEGIN
		--SET		@Property = 'Win32_DiskDrive.DeviceID=''\\.\PHYSICALDRIVE'+CAST(@CPULoop AS VarChar)+''''
		SET		@Property = 'Win32_LogicalDisk.DeviceID='''+CHAR(@DriveLoop)+':'''
		exec	sp_OAMethod @LDrives, 'Item', @LDrive output, @Property;
		exec	sp_OAGetProperty @LDrive,'Name', @Results OUT
		--PRINT	@LDrive
		--PRINT	@Results
		SET		@Results = REPLACE(@Results,':','')
		
		IF @Results = CHAR(@DriveLoop)
		BEGIN
			PRINT CHAR(@DriveLoop)
			
			INSERT INTO @DriveList ([DriveLetter]) VALUES(@Results)

			-- LOGICAL DISK PROPERTIES
			exec sp_OAGetProperty @LDrive,'Size'						, @Results_int OUT; UPDATE @DriveList SET [TotalSize]						= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'FreeSpace'					, @Results_int OUT; UPDATE @DriveList SET [FreeSpace]						= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'Description'					, @Results OUT;		UPDATE @DriveList SET [DriveType]						= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'VolumeSerialNumber'			, @Results OUT;		UPDATE @DriveList SET [SerialNumber]					= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'FileSystem'					, @Results OUT;		UPDATE @DriveList SET [FileSystem]						= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'Compressed'					, @Results_bol OUT;	UPDATE @DriveList SET [Compressed]						= @Results_bol WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'SupportsFileBasedCompression', @Results_bol OUT;	UPDATE @DriveList SET [SupportsFileBasedCompression]	= @Results_bol WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'SupportsDiskQuotas'			, @Results_bol OUT;	UPDATE @DriveList SET [SupportsDiskQuotas]				= @Results_bol WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'QuotasDisabled'				, @Results_bol OUT;	UPDATE @DriveList SET [QuotasDisabled]					= @Results_bol WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'QuotasIncomplete'			, @Results_bol OUT;	UPDATE @DriveList SET [QuotasIncomplete]				= @Results_bol WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'QuotasRebuilding'			, @Results_bol OUT;	UPDATE @DriveList SET [QuotasRebuilding]				= @Results_bol WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'VolumeDirty'					, @Results_bol OUT;	UPDATE @DriveList SET [VolumeDirty]						= @Results_bol WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @LDrive,'VolumeName'					, @Results OUT;		UPDATE @DriveList SET [VolumeName]						= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			
			SET		@Query  = 'REFERENCES OF {Win32_LogicalDisk.DeviceID="'+CHAR(@DriveLoop)+':"} WHERE ResultClass = Win32_LogicalDiskToPartition'
			exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @LD2Ps output, @Query
			PRINT	@hr
			PRINT	COALESCE(@LD2Ps,0)

			exec	@hr		= sp_OAGetProperty @LD2Ps,'Count', @Results_int2 OUT
			PRINT	@hr
			PRINT	@Results_int2

			--SET		@Query  = 'Dependent NOT NULL'
			--exec	@hr		= sp_OAMethod @LD2Ps, 'Item', @LD2P output, @Query
			--PRINT	@hr
			--PRINT	COALESCE(@LD2P,0)			


			exec	@hr		= sp_OAGetProperty @LD2Ps,'DeviceID', @Results OUT
			PRINT	@hr
			PRINT	@Results
			





			----SET		@Property	= QUOTENAME('\\'+REPLACE(@@ServerName,'\'+@@SERVICENAME,'')+'\root\cimv2:' + REPLACE(@Property,'''','"'),'''')
			----PRINT	@Property
			--SET		@Property	= 'Win32_LogicalDiskToPartition.Antecedent="\\\\FREPSQLRYLR01\\root\\cimv2:Win32_DiskPartition.DeviceID=\"Disk #2, Partition #0\"",Dependent="\\\\FREPSQLRYLR01\\root\\cimv2:Win32_LogicalDisk.DeviceID=\"F:\""'	
			--PRINT	@Property
			--EXEC	@hr			= sp_OAMethod @WmiService, 'Get', @LD2P OUTPUT, @Property
			--PRINT	@hr
			--PRINT	COALESCE(@LD2P,0)
			--exec	@hr		= sp_OAGetProperty @LD2P,'Antecedent', @Results OUT
			--PRINT	@hr
			--PRINT	@Results	
			
			
			
			--exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @LD2Ps output, 'Select * from Win32_LogicalDiskToPartition WHERE Dependent = \\\\FREPSQLRYLR01\\root\\cimv2:Win32_LogicalDisk.DeviceID=\"F:\"';
			--PRINT	@hr
			--PRINT	COALESCE(@LD2Ps,0)

			
			
			
			
			
			--exec	@hr		= sp_OAGetProperty @LD2P,'Antecedent', @Results OUT
			--PRINT	@hr
			--PRINT	COALESCE(@Results,'?')
						
						
									
			--SET		@Property = QUOTENAME('\\'+REPLACE(@@ServerName,'\'+@@SERVICENAME,'')+'\root\cimv2:' + REPLACE(@Property,'''','"'),'''')
			--PRINT	@Property			

			--SET		@Query	= 'ASSOCIATORS OF {Win32_LogicalDiskToPartition.Dependent='+@Property+'} WHERE AssocClass = Win32_DiskPartition'
			--Print	@Query
			--exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @WmiService2 output, @Query
			--PRINT	@hr
			--Print	@WmiService2

			--SET		@Query	= 'ASSOCIATORS OF {Win32_DiskPartition.DeviceID='+@Property+'} WHERE AssocClass = Win32_DiskPartition'
			--Print	@Query
			--exec	@hr		= sp_OAMethod @WmiService, 'execQuery', @WmiService2 output, @Query
			--PRINT	@hr
			--Print	@WmiService2








			--PRINT	'LD2P'
			--SET		@Property = QUOTENAME('\\'+REPLACE(@@ServerName,'\'+@@SERVICENAME,'')+'\root\cimv2:' + REPLACE(@Property,'''','"'),'''')
			--PRINT	@Property

			--SET		@Property = 'Win32_LogicalDiskToPartition.Dependent=' + @Property
			--PRINT	@Property

			--exec	@hr		= sp_OAMethod @LD2Ps, 'Item', @LD2P output, @Property;
			--PRINT	@hr
			--PRINT	COALESCE(@LD2P,0)
			
			--exec	@hr		= sp_OAGetProperty @LD2P ,'Antecedent', @Results OUT
			--PRINT	@hr
			--PRINT	COALESCE(@Results,'?')


			--PRINT	'PD2P'
			--SET		@Property = 'Win32_DiskDriveToDiskPartition.Dependent='+ QUOTENAME(@Results,'''') 
			--PRINT	@Property
			
			--exec	@hr		= sp_OAMethod @PD2Ps, 'Item', @PD2P output, @Property;
			--PRINT	@hr
			--PRINT	COALESCE(@PD2P,0)
			
			--exec	@hr		= sp_OAGetProperty @PD2P ,'Antecedent', @Results OUT
			--PRINT	@hr
			--PRINT	COALESCE(@Results,'?')

			--SET		@Results = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@Results,'"','|'),'\\','\'),2)
			--PRINT	COALESCE(@Results,'?')

		--SET		@Property = 'Win32_DiskDrive.DeviceID='+QUOTENAME(@Results,'''')
		----PRINT	@Property
		--exec	sp_OAMethod @PDrives, 'Item', @LDrive output, @Property;
		--exec	sp_OAGetProperty @PDrive,'PNPDeviceID', @Results OUT
		----PRINT	@Results


			
		END
		SET @DriveLoop = @DriveLoop +1
	END	

	endfunct:
	-- RETURN
	SELECT * FROM @DriveList
--END


