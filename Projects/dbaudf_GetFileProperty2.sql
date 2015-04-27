USE [dbaadmin]
GO


ALTER FUNCTION [dbo].[dbaudf_GetFileProperty] (@filename varchar(8000),@GetAs VarChar(50),@property VarChar(255))
RETURNS VarChar(2048)
AS
BEGIN
    DECLARE @rv int 
    DECLARE @fso int 
    DECLARE @file int 
    DECLARE @Results VarChar(2048) 
    
    IF @GetAs NOT IN (
			'File'
			,'Folder'
			,'Drive'
			)
    BEGIN
	SET @Results = @GetAs +' is Not A Valid @GetAs Value. Use File, Folder, or Drive.'
	RETURN @Results
    END	
        
    IF (@GetAs = 'File' AND @property NOT IN	(
						'Drive'
						,'ParentFolder'
						,'Path'
						,'ShortPath'
						,'Name'
						,'ShortName'						
						,'Type'
						,'DateCreated'
						,'DateLastAccessed'
						,'DateLastModified'
						,'Attributes'
						,'size'
						))
    OR (@GetAs = 'Folder' AND @property NOT IN	(
						'Drive'
						,'ParentFolder'
						,'Path'
						,'ShortPath'
						,'Name'
						,'ShortName'						
						,'Type'
						,'DateCreated'
						,'DateLastAccessed'
						,'DateLastModified'
						,'Attributes'
						,'Size'
						,'Files'
						,'SubFolders'
						,'IsRootFolder'
						))
												
    OR (@GetAs = 'Drive' AND @property NOT IN	(
						'TotalSize'
						,'AvailableSpace'
						,'FreeSpace'
						,'DriveLetter'
						,'DriveType'
						,'SerialNumber'
						,'FileSystem'
						,'IsReady'
						,'ShareName'
						,'VolumeName'
						,'Path'
						,'RootFolder'
						))						
    BEGIN
	SET @Results = '"'+ @property +'" is Not A Valid @Property Name with the "'+@GetAs+'" @GetAs Value.'
	RETURN @Results
    END			
        
    EXEC @rv = sp_OACreate 'Scripting.FileSystemObject', @fso OUT 
    IF @rv = 0
    BEGIN 
	SET @GetAs =	CASE @GetAs
			WHEN 'File'	THEN 'GetFile'
			WHEN 'Folder'	THEN 'GetFolder'
			WHEN 'Drive'	THEN 'GetDrive'
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

GO

DECLARE @ObjectPath VarChar(8000)

SET @ObjectPath = 'C:\Windows\win.ini'
	
SELECT	dbo.[dbaudf_GetFileProperty] (@ObjectPath,'File'	,'Drive')		AS[Drive]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'ParentFolder')	AS[ParentFolder]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'Path')		AS[Path]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'ShortPath')		AS[ShortPath]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'Name')		AS[Name]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'ShortName')		AS[ShortName]					
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'Type')		AS[Type]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'DateCreated')		AS[DateCreated]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'DateLastAccessed')	AS[DateLastAccessed]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'DateLastModified')	AS[DateLastModified]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'Attributes')		AS[Attributes]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'File'	,'size')		AS[size]

SET @ObjectPath = 'e:\AppData\ALLIANT\CC_PA_Addendum_Process_Patch_April2010\CC_ArchiveAndPurge_ProductandProductUDFStageTables\TestResources'

SELECT	dbo.[dbaudf_GetFileProperty] (@ObjectPath,'Folder'	,'Drive')		AS[Drive]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'ParentFolder')	AS[ParentFolder]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'Path')		AS[Path]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'ShortPath')		AS[ShortPath]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'Name')		AS[Name]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'ShortName')		AS[ShortName]					
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'Type')		AS[Type]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'DateCreated')		AS[DateCreated]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'DateLastAccessed')	AS[DateLastAccessed]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'DateLastModified')	AS[DateLastModified]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'Attributes')		AS[Attributes]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'size')		AS[size]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'Files')		AS[Files]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'SubFolders')		AS[SubFolders]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Folder'	,'IsRootFolder')	AS[IsRootFolder]

SET @ObjectPath = 'C:'
	
SELECT	dbo.[dbaudf_GetFileProperty] (@ObjectPath,'Drive'	,'TotalSize')		AS[TotalSize]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'AvailableSpace')	AS[AvailableSpace]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'FreeSpace')		AS[FreeSpace]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'DriveLetter')		AS[DriveLetter]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'DriveType')		AS[DriveType]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'SerialNumber')	AS[SerialNumber]					
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'FileSystem')		AS[FileSystem]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'IsReady')		AS[IsReady]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'ShareName')		AS[ShareName]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'VolumeName')		AS[VolumeName]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'Path')		AS[Path]
	,dbo.[dbaudf_GetFileProperty](@ObjectPath,'Drive'	,'RootFolder')		AS[RootFolder]
	
	
	
EXEC master.dbo.sp_dropserver @server=N'FSO', @droplogins='droplogins'
GO
exec sp_addlinkedserver	@server = 'FSO'
			, @provider = 'Search.CollatorDSO'
			, @datasrc = 'SYSTEMINDEX'
			, @srvproduct = ''
			, @provstr='Application=Windows'

go
SELECT * FROM OPENQUERY(FSO, 'SELECT Top 5 System.ItemPathDisplay, System.ItemName, System.FileName FROM wlsydweb1.SystemIndex')





EXEC master.dbo.sp_dropserver @server=N'FileSystem', @droplogins='droplogins'
GO

exec sp_addlinkedserver	@server = 'FileSystem'
			, @srvproduct = 'Index Server'
			, @provider = 'MSIDXS'
			, @datasrc = 'AppData'

SELECT *
 FROM OPENQUERY	(FileSystem,'
 SELECT		Directory 
		,FileName
		,DocAuthor
		,DocAppName
		,DocLineCount
		,DocWordCount
		,Size
		,Create
		,Write
		,Access
		,ClassId
FROM		SCOPE(''"E:\AppData"'')'
		)
		
		
SELECT * FROM OPENQUERY (FileSystem,'
 SELECT		FileName
		,Directory
		,Create
		,Write
		,ClassId
		,Access
		,DocWordCount
		,DocLineCount
		,DocAppName
FROM		AppData..SCOPE()'
		)		
		
		
		