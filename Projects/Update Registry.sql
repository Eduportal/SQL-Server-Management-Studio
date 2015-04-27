SET NOCOUNT ON;

DECLARE		@vchName			VarChar(40)
			,@vchLabel			VarChar(100)
			,@dtBuildDate		DateTime
			,@Key				nVarChar(4000)
			,@ValueName			nVarChar(1000)
			,@Value				nVarChar(max)

DECLARE		@Results			TABLE
			(
			Results				VarChar(max)
			)
			
DECLARE		@Values			TABLE
			(
			Value				nVarChar(1000)
			,Data				nVarChar(max)
			)
			
DECLARE		@RegValues			TABLE
			(
			Registry_Key		VarChar(max)
			,Value_Name			VarChar(max)
			,Current_Value		VarChar(max)
			,New_Value			VarChar(max)
			,Notes				VarChar(max)
			,Expected			bit
			)

---------------------------------------
---------------------------------------
--	BUILD LIST OF EXPECTED KEY VALUES
---------------------------------------
---------------------------------------
	-- GET CURRENT DB BUILD NUMBERS
	IF OBJECT_ID('dbaadmin.dbo.DBA_DBInfo') IS NOT NULL
		INSERT INTO @RegValues
		SELECT 'InstanceKey',[DBName],NULL,[Build],[modDate],1
		FROM dbaadmin.dbo.DBA_DBInfo
		WHERE NULLIF([Build],'') IS NOT NULL
	
	-- GET CURRENT SERVER INFO VALUES
	IF OBJECT_ID('dbaadmin.dbo.DBA_ServerInfo') IS NOT NULL
		INSERT INTO @RegValues
		SELECT 'ServerKey','Environment'	,NULL,UPPER([SQLEnv])		,[modDate],1	FROM dbaadmin.dbo.DBA_ServerInfo UNION ALL
		SELECT 'ServerKey','Active'			,NULL,UPPER([Active])		,[modDate],1	FROM dbaadmin.dbo.DBA_ServerInfo UNION ALL
		SELECT 'ServerKey','Deployable'		,NULL,UPPER([DEPLstatus])	,[modDate],1	FROM dbaadmin.dbo.DBA_ServerInfo 
		
	-- SERVER LEVEL VALUES
	INSERT INTO	@RegValues
				SELECT		'ServerKey','Class'					,NULL,NULL,NULL,1
	UNION ALL	SELECT		'ServerKey','CollectionInterval'	,NULL,NULL,NULL,1
	--UNION ALL	SELECT		'ServerKey','',NULL,NULL,NULL,1
	--UNION ALL	SELECT		'ServerKey','',NULL,NULL,NULL,1

-- CHECK VALUES
SELECT * FROM @RegValues

---------------------------------------
---------------------------------------
--	READ LIST OF CURRENT KEY VALUES
---------------------------------------
---------------------------------------
	--	GET INSTANCE VALUES
	SET	@key	= N'SOFTWARE\Microsoft\Microsoft SQL Server\' + @@servicename + '\TSSQLDBA'
	INSERT INTO @Values
	exec sys.xp_instance_regenumvalues 'HKEY_LOCAL_MACHINE', @Key;

	UPDATE	T1	
		SET	Current_Value = T2.Data
	FROM	@RegValues T1
	JOIN	@Values T2
		ON	T1.Value_Name = T2.Value
		AND	T1.Registry_Key = 'InstanceKey'

	INSERT INTO	@RegValues
	SELECT		'InstanceKey',Value,Data,NULL,NULL,0
	FROM		@Values
	WHERE		Value NOT IN (SELECT Value_Name FROM @RegValues WHERE Registry_Key = 'InstanceKey')

	--DELETE @Values
	----	GET SERVER VALUES
	--SET	@key	=N'SOFTWARE\Gettyimages\SQL'
	--INSERT INTO @Values
	--exec sys.xp_instance_regenumvalues 'HKEY_LOCAL_MACHINE', @Key;

	--UPDATE	T1	
	--	SET	Current_Value = T2.Data
	--FROM	@RegValues T1
	--JOIN	@Values T2
	--	ON	T1.Value_Name = T2.Value
	--	AND	T1.Registry_Key = 'ServerKey'

	--INSERT INTO	@RegValues
	--SELECT		'ServerKey',Value,Data,NULL,NULL,0
	--FROM		@Values
	--WHERE		Value NOT IN (SELECT Value_Name FROM @RegValues WHERE Registry_Key = 'ServerKey')


SELECT * FROM @RegValues



	DECLARE KeyCursor 
	CURSOR
	FOR
	SELECT * FROM @Values

	OPEN KeyCursor
	FETCH NEXT FROM KeyCursor INTO @Key, @ValueName, @Value
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN






		END
		FETCH NEXT FROM KeyCursor INTO @Key, @ValueName, @Value
	END

	CLOSE KeyCursor
	DEALLOCATE KeyCursor






--SET	@key	= N'SOFTWARE\Gettyimages\SQL'


		
	EXECUTE [master]..[xp_instance_regwrite]
			  @rootkey = N'HKEY_LOCAL_MACHINE'
			 ,@key = @key
			 ,@value_name = @vchName
			 ,@type = N'REG_SZ'
			 ,@value = @vchLabel










--exec master.dbo.xp_instance_regdeletekey 
--	'HKEY_LOCAL_MACHINE'
--	,@key


DECLARE KeyCursor 
CURSOR
FOR
SELECT * FROM #BUILD

OPEN KeyCursor
FETCH NEXT FROM KeyCursor INTO @vchName,@vchLabel,@dtBuildDate
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
	FETCH NEXT FROM KeyCursor INTO @vchName,@vchLabel,@dtBuildDate
END

CLOSE KeyCursor
DEALLOCATE KeyCursor
GO
DROP TABLE #BUILD
GO







-----------------------------------------------------------------------
-----------------------------------------------------------------------
--					READ VALUES FROM REGISTRY
-----------------------------------------------------------------------
-----------------------------------------------------------------------
CREATE TABLE [dbo].[#Build]
	(
	[DBName]		VarChar(40)		NULL
	,[DBBuild]		varchar(100)	NULL
	)

DECLARE	@vchName	VarChar(40)
	,@vchLabel		VarChar(100)
	,@dtBuildDate	DateTime
	,@Key			nVarChar(4000)


IF CHARINDEX('Microsoft SQL Server  2000', @@Version) > 0
BEGIN
	SET	@key	= N'SOFTWARE\Microsoft\Microsoft SQL Server\'+@@servicename+'\TSSQLDBA'

		INSERT INTO [#Build]([DBName],[DBBuild])
		EXECUTE [master]..[xp_regenumvalues]
		  @rootkey = N'HKEY_LOCAL_MACHINE'
		 ,@key = @key
END
ELSE
BEGIN
	SET	@key	= N'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'
		
			EXECUTE [master]..[xp_regread]
			  @rootkey = N'HKEY_LOCAL_MACHINE'
			 ,@key = @key
			 ,@value_name = @@servicename
			 ,@value = @vchLabel OUT
			 	
	SET	@key	= N'SOFTWARE\Microsoft\Microsoft SQL Server\' + @vchLabel + '\' + @@servicename + '\TSSQLDBA'
	PRINT @key

			INSERT INTO [#Build]([DBName],[DBBuild])
			EXECUTE [master]..[xp_regenumvalues]
			  @rootkey = N'HKEY_LOCAL_MACHINE'
			 ,@key = @key
END

SELECT * FROM #BUILD

GO
DROP TABLE #BUILD
GO
