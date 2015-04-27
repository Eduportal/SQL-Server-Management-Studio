USE dbaadmin
go

CREATE FUNCTION dbaudf_GetFileProperty (@filename varchar(8000),@property VarChar(255))
RETURNS VarChar(2048)
AS BEGIN
    DECLARE @rv int 
    DECLARE @fso int 
    DECLARE @file int 
    DECLARE @Results VarChar(2048) 
    IF @property NOT IN (
			'Path'
			,'ShortPath'
			,'Type'
			,'DateCreated'
			,'DateLastAccessed'
			,'DateLastModified'
			,'Attributes'
			,'size'
			)
    BEGIN
	SET @Results = @property +' is Not A Valid Property Name.'
	RETURN @Results
    END			
    
    EXEC @rv = sp_OACreate 'Scripting.FileSystemObject', @fso OUT 
    IF @rv = 0 BEGIN 
        EXEC @rv = sp_OAMethod @fso, 'GetFile', @file OUT, @filename
        IF @rv = 0 BEGIN
            EXEC @rv = sp_OAGetProperty @file, @Property, @Results OUT
            EXEC @rv = sp_OADestroy @file 
        END 
        EXEC @rv = sp_OADestroy @fso 
    END
    RETURN @Results
END
GO









