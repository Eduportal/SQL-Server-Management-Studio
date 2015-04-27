USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetFileProperty]    Script Date: 06/04/2010 17:41:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetFileProperty]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [dbo].[dbaudf_GetFileProperty] (@filename varchar(8000),@GetAs VarChar(50),@property VarChar(255))
RETURNS VarChar(2048)
AS
BEGIN
    DECLARE @rv int 
    DECLARE @fso int 
    DECLARE @file int 
    DECLARE @Results VarChar(2048) 
    
    IF @GetAs NOT IN (
			''File''
			,''Folder''
			,''Drive''
			)
    BEGIN
	SET @Results = @GetAs +'' is Not A Valid @GetAs Value. Use File, Folder, or Drive.''
	RETURN @Results
    END	
        
    IF (@GetAs = ''File'' AND @property NOT IN	(
						''Drive''
						,''ParentFolder''
						,''Path''
						,''ShortPath''
						,''Name''
						,''ShortName''						
						,''Type''
						,''DateCreated''
						,''DateLastAccessed''
						,''DateLastModified''
						,''Attributes''
						,''size''
						))
    OR (@GetAs = ''Folder'' AND @property NOT IN	(
						''Drive''
						,''ParentFolder''
						,''Path''
						,''ShortPath''
						,''Name''
						,''ShortName''						
						,''Type''
						,''DateCreated''
						,''DateLastAccessed''
						,''DateLastModified''
						,''Attributes''
						,''Size''
						,''Files''
						,''SubFolders''
						,''IsRootFolder''
						))
												
    OR (@GetAs = ''Drive'' AND @property NOT IN	(
						''TotalSize''
						,''AvailableSpace''
						,''FreeSpace''
						,''DriveLetter''
						,''DriveType''
						,''SerialNumber''
						,''FileSystem''
						,''IsReady''
						,''ShareName''
						,''VolumeName''
						,''Path''
						,''RootFolder''
						))						
    BEGIN
	SET @Results = ''"''+ @property +''" is Not A Valid @Property Name with the "''+@GetAs+''" @GetAs Value.''
	RETURN @Results
    END			
        
    EXEC @rv = sp_OACreate ''Scripting.FileSystemObject'', @fso OUT 
    IF @rv = 0
    BEGIN 
	SET @GetAs =	CASE @GetAs
			WHEN ''File''	THEN ''GetFile''
			WHEN ''Folder''	THEN ''GetFolder''
			WHEN ''Drive''	THEN ''GetDrive''
			END
			
	EXEC @rv = sp_OAMethod @fso, @GetAs, @file OUT, @filename
	IF @rv = 0
	BEGIN
		EXEC @rv = sp_OAGetProperty @file, @Property, @Results OUT
		EXEC @rv = sp_OADestroy @file 
	END 
        EXEC @rv = sp_OADestroy @fso 
    END
    RETURN @Results
END

' 
END

GO


CREATE FUNCTION [dbo].[dbaudf_ListDrives]()
RETURNS @DriveList Table
		(
		[DriveLetter]		CHAR(1)
		,[TotalSize]		BigInt
		,[AvailableSpace]	BigInt
		,[FreeSpace]		BigInt
		,[DriveType]		VarChar(50)
		,[SerialNumber]		VarChar(50)
		,[FileSystem]		VarChar(50)
		,[IsReady]		VarChar(50)
		,[ShareName]		VarChar(255)
		,[VolumeName]		VarChar(255)
		,[Path]			VarChar(2048)
		,[RootFolder]		VarChar(2048)
		)
AS
BEGIN

	DECLARE @DriveLoop	INT
	DECLARE @fso		Int
	DECLARE @DriveCount	INT
	DECLARE @Drives		Int
	DECLARE @Drive		Int
	DECLARE @Property	nVarChar(100)
	DECLARE @Results	VarChar(8000)
	DECLARE @Results_int	bigint

	SET @DriveLoop = 65

	exec sp_OACreate 'Scripting.FileSystemObject', @fso OUT
	exec sp_OAGetProperty @fso,'Drives', @Drives OUT
	exec sp_OAGetProperty @Drives,'Count', @DriveCount OUT

	WHILE @DriveLoop < 91
	BEGIN
		SET @Property = 'item("'+CHAR(@DriveLoop)+'")'
		--SET @Property = 'Drives.item("A").DriveLetter'
		--exec sp_OAGetProperty @fso,@Property, @Results OUT
		exec sp_OAGetProperty @Drives,@Property, @Drive OUT
		exec sp_OAGetProperty @Drive,'DriveLetter', @Results OUT
		IF @Results = CHAR(@DriveLoop)
		BEGIN
			INSERT INTO @DriveList ([DriveLetter]) VALUES(@Results)

			exec sp_OAGetProperty @Drive,'TotalSize'	, @Results_int OUT; UPDATE @DriveList SET [TotalSize]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'AvailableSpace'	, @Results_int OUT; UPDATE @DriveList SET [AvailableSpace]	= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'FreeSpace'	, @Results_int OUT; UPDATE @DriveList SET [FreeSpace]		= @Results_int WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'DriveType'	, @Results OUT; UPDATE @DriveList SET [DriveType]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'SerialNumber'	, @Results OUT; UPDATE @DriveList SET [SerialNumber]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'FileSystem'	, @Results OUT; UPDATE @DriveList SET [FileSystem]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'IsReady'		, @Results OUT; UPDATE @DriveList SET [IsReady]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'ShareName'	, @Results OUT; UPDATE @DriveList SET [ShareName]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'VolumeName'	, @Results OUT; UPDATE @DriveList SET [VolumeName]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'Path'		, @Results OUT; UPDATE @DriveList SET [Path]		= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			exec sp_OAGetProperty @Drive,'RootFolder'	, @Results OUT; UPDATE @DriveList SET [RootFolder]	= @Results WHERE [DriveLetter] = CHAR(@DriveLoop)
			
		END
		SET @DriveLoop = @DriveLoop +1
	END	

	RETURN
END
GO


SELECT * FROM [dbo].[dbaudf_ListDrives]()