SET NOCOUNT ON; 

CREATE TABLE [dbo].[#Build]
	(
	[vchName]	VarChar(40)	NOT NULL PRIMARY KEY CLUSTERED
	,[vchLabel]	varchar(100)	NOT NULL
	,[dtBuildDate]	datetime	NOT NULL
	)

DECLARE	@vchName	VarChar(40)
	,@vchLabel	VarChar(100)
	,@dtBuildDate	DateTime
	,@Key		nVarChar(4000)

SET	@key	= N'SOFTWARE\Microsoft\Microsoft SQL Server\' + @@servicename + '\TSSQLDBA'

exec sp_MSForEachDB

'USE ?;
IF EXISTS (SELECT * From syscolumns where OBJECT_NAME(id) = ''Build'' AND Name = ''dtBuildDate'')
INSERT INTO [#BUILD]
SELECT TOP 1 [vchName],[vchLabel],[dtBuildDate] FROM [dbo].[Build] ORDER BY [dtBuildDate] DESC'



exec master.dbo.xp_instance_regdeletekey 
	'HKEY_LOCAL_MACHINE'
	,@key


DECLARE DBCursor 
CURSOR
FOR
SELECT * FROM #BUILD

OPEN DBCursor
FETCH NEXT FROM DBCursor INTO @vchName,@vchLabel,@dtBuildDate
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		EXECUTE [master]..[xp_instance_regwrite]
		  @rootkey = N'HKEY_LOCAL_MACHINE'
		 ,@key = @key
		 ,@value_name = @vchName
		 ,@type = N'REG_SZ'
		 ,@value = @vchLabel

	END
	FETCH NEXT FROM DBCursor INTO @vchName,@vchLabel,@dtBuildDate
END

CLOSE DBCursor
DEALLOCATE DBCursor
GO
DROP TABLE #BUILD
GO
