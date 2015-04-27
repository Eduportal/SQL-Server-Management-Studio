GO
USE [dbaadmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--IF OBJECT_ID('dbaudf_DiskInfo') IS NOT NULL
--	DROP FUNCTION [dbo].[dbaudf_DiskInfo]
--GO
--CREATE FUNCTION [dbo].[dbaudf_DiskInfo](@Attribute sysname)
--RETURNS INT
--AS
--BEGIN

DECLARE		@DriveList Table
		(
		[DriveLetter]		CHAR(1)
		,[TotalSize]		BigInt
		,[AvailableSpace]	BigInt
		,[FreeSpace]		BigInt
		,[DriveType]		VarChar(50)
		,[SerialNumber]		VarChar(50)
		,[FileSystem]		VarChar(50)
		,[IsReady]			VarChar(50)
		,[IsSAN]			VarChar(50)
		,[ShareName]		VarChar(255)
		,[VolumeName]		VarChar(255)
		,[Path]				VarChar(2048)
		,[RootFolder]		VarChar(2048)
		)


	DECLARE		@WmiServiceLocator			int
				,@WmiService				int
				,@CounterCollection			int
				,@CounterObject				int
				,@Freespace					float
				,@Value						INT
				,@NumberOfCores				INT
				,@NumberOfLogicalProcessors	INT
				,@Count						int
				,@CPULoop					INT
				,@Property					nVarChar(200)
				,@Value2					sysname
				,@ProcessorID				CHAR(16)
				,@CPUID						BINARY(2)
				,@HT						INT
				,@Results					
	DECLARE		@SocketList					TABLE (SocketDesignation sysname)
				
	SELECT		@CPULoop					= 0
				,@NumberOfCores				= 0
				,@NumberOfLogicalProcessors	= 0
				 
	exec sp_OACreate 'WbemScripting.SWbemLocator', @WmiServiceLocator output; 
	exec sp_OAMethod @WmiServiceLocator, 'ConnectServer', @WmiService output, '.', 'root\cimv2'; 
	exec sp_OAMethod @WmiService, 'execQuery', @CounterCollection output, 'Select * from Win32_DiskDrive';
	 
	exec sp_OAGetProperty @CounterCollection,'Count', @Count OUT

	WHILE @CPULoop < @Count
	BEGIN
		SET		@Property = 'Win32_DiskDrive.DeviceID=''\\.\PHYSICALDRIVE'+CAST(@CPULoop AS VarChar)+''''
		exec sp_OAMethod @CounterCollection, 'Item', @CounterObject output, @Property;
		exec sp_OAGetProperty @Drive,'DriveLetter', @Results OUT

		BEGIN
			INSERT INTO @DriveList ([DriveLetter]) VALUES(@Results)

			exec sp_OAGetProperty @Drive,'TotalSize'		, @Results_int OUT; UPDATE @DriveList SET [TotalSize]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'AvailableSpace'	, @Results_int OUT; UPDATE @DriveList SET [AvailableSpace]	= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'FreeSpace'		, @Results_int OUT; UPDATE @DriveList SET [FreeSpace]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'DriveType'		, @Results OUT;		UPDATE @DriveList SET [DriveType]		= CASE @Results
																															  WHEN '0' THEN 'Unknown'
																															  WHEN '1' THEN 'Removable'
																															  WHEN '2' THEN 'Fixed'
																															  WHEN '3' THEN 'Network'
																															  WHEN '4' THEN 'CD-ROM'
																															  WHEN '5' THEN 'RAM Disk'
																															  ELSE 'Other' END WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'SerialNumber'		, @Results OUT;		UPDATE @DriveList SET [SerialNumber]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'FileSystem'		, @Results OUT;		UPDATE @DriveList SET [FileSystem]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'IsReady'			, @Results OUT;		UPDATE @DriveList SET [IsReady]			= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'ShareName'		, @Results OUT;		UPDATE @DriveList SET [ShareName]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'VolumeName'		, @Results OUT;		UPDATE @DriveList SET [VolumeName]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'Path'				, @Results OUT;		UPDATE @DriveList SET [Path]			= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'RootFolder'		, @Results OUT;		UPDATE @DriveList SET [RootFolder]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			
		END










		SET		@Value = 0
		exec	sp_OAGetProperty @CounterObject, 'NumberOfCores', @Value output;
		SET		@NumberOfCores = @NumberOfCores + @Value
		
		SET		@Value = 0
		exec	sp_OAGetProperty @CounterObject, 'NumberOfLogicalProcessors', @Value output; 
		SET		@NumberOfLogicalProcessors = @NumberOfLogicalProcessors + @Value
	
		SET		@Value2 = ''
		exec	sp_OAGetProperty @CounterObject, 'SocketDesignation', @Value2 output;
		 
		IF @Value2 NOT IN (SELECT SocketDesignation FROM @SocketList)
				INSERT INTO @SocketList(SocketDesignation) VALUES(@Value2)
				
				
		SET		@Value2 = ''
		exec	sp_OAGetProperty @CounterObject, 'ProcessorId', @ProcessorID output;				
		SET		@CPUID = [msdb].[MS_PerfDashboard].[fn_hexstrtovarbin]('0x'+LEFT(@ProcessorID,4))
		SET		@HT = ISNULL(@HT,0)|CASE WHEN @CPUID&[dbaadmin].[dbo].[dbaudf_BitToInt](13)>0 THEN 1 ELSE 0 END

		SET		@CPULoop = @CPULoop + 1
	END
	
	IF @Count > 0 AND @NumberOfLogicalProcessors = 0
		SELECT	@NumberOfLogicalProcessors	= @Count
				,@Count						= COUNT(*)
				,@NumberOfCores				= @NumberOfLogicalProcessors / (@HT+1)
		FROM	@SocketList		 
	
	IF @NumberOfCores < @Count
		SET @NumberOfCores = @Count
	
	IF @Attribute = 'Sockets'
		SET @Value = @Count
	ELSE IF @Attribute = 'Cores'
		SET @Value = @NumberOfCores
	ELSE
		SET @Value = @NumberOfLogicalProcessors




--	RETURN @Value
--END
--GO




--SELECT		*
--FROM		(
--			SELECT	 @@ServerName [SQLName]
--					,[dbaadmin].[dbo].[dbaudf_DiskInfo]('Sockets')	[Sockets]
--					,[dbaadmin].[dbo].[dbaudf_DiskInfo]('Cores')		[Cores]
--					,[dbaadmin].[dbo].[dbaudf_DiskInfo]('Threads')	[Threads]
--					,CPUphysical
--					,CPUcore
--					,CPUlogical
--			From	dbaadmin.dbo.DBA_ServerInfo
--			) Data
--WHERE		CPUphysical != CAST([Sockets] AS VarChar) + ' physical'
--	OR		CPUcore		!= CAST([Cores] AS VarChar) + ' cores'
--	OR		CPUlogical	!= CAST([Threads] AS VarChar) + ' logical'
--GO
		
