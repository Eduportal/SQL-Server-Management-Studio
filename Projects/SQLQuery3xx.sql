USE dbaadmin
GO
IF OBJECT_ID('dbasp_UNC2Path') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_UNC2Path]
GO
CREATE PROCEDURE [dbo].[dbasp_UNC2Path] (@UNC VarChar(max),@Path VarChar(max) OUT)
AS
BEGIN

	--DECLARE	@UNC VarChar(max)
	--			,@Path			VarChar(max)
	--	SET		@UNC =	--'\\SEAPSQLDBA01\C$\Users\s-sledridge\desktop'
	--				'\\seapsqldba01\AppData\WCDS\PartnerCreate_20111004'
	--				--'E:\AppData\WCDS\PartnerCreate_20111004'

	DECLARE @Share			VarChar(1000)
			,@DynString		VarChar(8000)
			,@Returncode	INT
			
	SET		@Returncode = 0		
	DECLARE @regmultistring1 TABLE ([Item] NVARCHAR(1000), [Value] NVARCHAR(1000) )
	DECLARE @regmultistring2 TABLE ([Entry] NVARCHAR(1000), [Item] NVARCHAR(1000), [Value] NVARCHAR(1000) )

	IF LEFT(@UNC,2) != '\\' OR COALESCE(dbaadmin.dbo.dbaudf_GetFileProperty (@UNC,'Folder','Type'),'') != 'File Folder'
	BEGIN
		print 'Not a valid Local Path or UNC' 
		SELECT	@Path = @UNC
				,@Returncode = 1
		GOTO	Done
	END

	IF dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),1) != convert(nvarchar(100), serverproperty('machinename'))
	BEGIN 
		print 'Not a UNC path to the local machine' 
		SELECT	@Path = @UNC
				,@Returncode = 2
		GOTO	Done
	END

	IF dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),2) LIKE '[A-Z]$'
	BEGIN 
		print 'Administrative share' 
		SET		@Path = REPLACE(REPLACE(@UNC
							,'\\' + dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),1)+'\'
							,''
							),dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),2)
							,REPLACE(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),2),'$',':')
							)
		GOTO	Done
	END

	INSERT INTO @regmultistring1
	Exec xp_regenumvalues N'HKEY_LOCAL_MACHINE',N'SYSTEM\CURRENTCONTROLSET\SERVICES\LANMANSERVER\SHARES';

	INSERT INTO		@regmultistring2
	SELECT		[Entry]		= dbaadmin.dbo.dbaudf_ReturnPart(replace([Item],' - ','|'),1)
				,[Item]		= dbaadmin.dbo.dbaudf_ReturnPart(replace([Value],'=','|'),1)
				,[Value]	= dbaadmin.dbo.dbaudf_ReturnPart(replace([Value],'=','|'),2)
	FROM		@regmultistring1
				
	SELECT		@Path = REPLACE(@UNC
						,'\\'	+ dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),1)
						+'\'	+ dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),2)
						,Value) 
	FROM		@regmultistring2 
	WHERE		[Entry] = dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(@UNC,'\\',''),'\','|'),2)
		AND		[Item]	= 'Path'

	Done:
		
	if COALESCE(dbaadmin.dbo.dbaudf_GetFileProperty (@Path,'Folder','Type'),'') != 'File Folder'
	BEGIN 
		PRINT 'Results were invalid'
		SELECT	@Path = @UNC
				,@Returncode = 3
	END

	RETURN @Returncode
END

GO

DECLARE	@UNC			VarChar(max)
		,@Path			VarChar(max)
		,@ReturnCode	INT

SET		@UNC =	'\\SEAPSQLDBA01\C$\Users\s-sledridge\desktop'
				--	'\\seapsqldba01\AppData\WCDS\PartnerCreate_20111004'
				--'E:\AppData\WCDS\PartnerCreate_20111004'
				--'\\seapsqldba01\AppData\WCDS\PartnerCreate_crap'
	
EXEC @ReturnCode = dbaadmin.dbo.dbasp_UNC2Path @UNC, @Path OUT
	
SELECT @ReturnCode, @UNC, @Path
	
--SELECT [dbo].[dbaudf_UNC2Path]('\\seapsqldba01\AppData\WCDS\PartnerCreate_20111004')


select dbaadmin.dbo.dbaudf_GetFileProperty ('\\seapsqldba01\AppData\WCDS','Folder','Type')