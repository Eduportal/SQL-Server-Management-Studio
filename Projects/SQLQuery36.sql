/*

TRUNCATE TABLE [DBAadmin].[dbo].[BuildSchemaChanges]
GO
DECLARE		@TSQL		VarChar(max)
			,@TSQL2		VarChar(max)
			,@DBName	sysname

SET			@TSQL	= 'IF NOT EXISTS (SELECT * FROM [$DBName$].[sys].[fn_listextendedproperty](''$Param$'', default, default, default, default, default, default))
							EXEC [$DBName$].[sys].[sp_addextendedproperty] @name = ''$Param$'', @value = ''$Value$''
						ELSE
						BEGIN
							IF NOT EXISTS (SELECT * FROM [$DBName$].[sys].[fn_listextendedproperty](''$Param$'', default, default, default, default, default, default) WHERE COALESCE(CAST(value AS sysname),'''') = ''$Value$'')
								EXEC [$DBName$].[sys].[sp_updateextendedproperty] @name = ''$Param$'', @value = ''$Value$''
						END'
-- GET IT
DECLARE Project_Cursor CURSOR
FOR
SELECT		DISTINCT [Name]
FROM		sysdatabases
			
OPEN Project_Cursor
FETCH NEXT FROM Project_Cursor INTO @DBName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT 'Flushing BuildApplication in ' + @DBName
		SET	@TSQL2 = REPLACE(REPLACE(REPLACE(@TSQL,'$DBName$',@DBName),'$Param$','BuildApplication'),'$Value$',NULL)
		EXEC (@TSQL2)

		PRINT 'Flushing BuildBranch in ' + @DBName			
		SET	@TSQL2 = REPLACE(REPLACE(REPLACE(@TSQL,'$DBName$',@DBName),'$Param$','BuildBranch'),'$Value$',NULL)
		EXEC (@TSQL2)
		
		PRINT 'Flushing BuildNumber in ' + @DBName
		SET	@TSQL2 = REPLACE(REPLACE(REPLACE(@TSQL,'$DBName$',@DBName),'$Param$','BuildNumber'),'$Value$',NULL)
		EXEC (@TSQL2)
	END
	FETCH NEXT FROM Project_Cursor INTO @DBName
END
CLOSE Project_Cursor
DEALLOCATE Project_Cursor

--SET IT
IF NOT EXISTS (SELECT value FROM DEPLinfo.sys.fn_listextendedproperty('DEPLInstanceID', default, default, default, default, default, default))
	EXEC DEPLinfo.sys.sp_addextendedproperty @name = 'DEPLInstanceID', @value = NULL
ELSE
	EXEC DEPLinfo.sys.sp_updateextendedproperty @name = 'DEPLInstanceID', @value = NULL

SELECT dbo.GetDEPLInstanceID()

GO

*/




-- EXEC dbaadmin.dbo.dbasp_UpdateDDLAudit_AllInstance 'SEAFRESQLDBA01'


SELECT		dbo.GetDEPLInstanceID()
			,[LogId]
			,[EventType]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[SqlCommand]
			,[EventDate]
			,[LoginName]
			,[UserName]
			,[VC_DatabaseName]
			,[VC_SchemaName]
			,[VC_ObjectType]
			,[VC_ObjectName]
			,[VC_Version]
			,[VC_CreatedBy]
			,[VC_CreatedOn]
			,[VC_ModifiedBy]
			,[VC_ModifiedOn]
			,[VC_Purpose]
			,[VC_BuildApp]
			,[VC_BuildBrnch]
			,[VC_BuildNum]
			,[DB_BuildApp]
			,[DB_BuildBrnch]
			,[DB_BuildNum]
			,[Status]
			,[DEPLFileName]
			,[DEPLInstanceID]
FROM		[DBAadmin].[dbo].[BuildSchemaChanges] WITH(NOLOCK)
ORDER BY	1 





/*
SELECT		T1.[ServerNames]
			,T1.[InstanceID]			
			,T1.[Started]			
			,T1.[Finished]			
			,T2.[Build]			
			,T2.[Application]			
			,T2.[Branch]			
			,T2.[Version]			

			,CASE	WHEN DATEDIFF(minute,T1.[Started],T1.[Finished])	> 60 THEN CAST(DATEDIFF(minute,T1.[Started],T1.[Finished]) AS FLOAT)/60
					WHEN DATEDIFF(second,T1.[Started],T1.[Finished])	> 60 THEN CAST(DATEDIFF(second,T1.[Started],T1.[Finished]) AS FLOAT)/60
					ELSE DATEDIFF(second,T1.[Started],T1.[Finished]) END [Duration]

			,CASE	WHEN DATEDIFF(minute,T1.[Started],T1.[Finished])	> 60 THEN 'Hours'
					WHEN DATEDIFF(second,T1.[Started],T1.[Finished])	> 60 THEN 'Minutes'
					ELSE 'Seconds' END [Increment]

			, CONVERT(VarChar(50),T1.[Started],20) + ' - ' + T2.[Application] + ' ' + T2.[Version] + ' ' + T2.[Branch] + ' ' + T2.[Build] [Prompt]
FROM		(
			SELECT		[InstanceID]		
						,[Build]			
						,MIN([Started])		[Started]
						,MAX([Finished])	[Finished]
						,dbaadmin.dbo.dbaudf_Concatenate(CAST([ServerName] AS VarChar(50))) [ServerNames]			
			FROM		(
						SELECT		[ServerName]
									,DEPLInstanceID		[InstanceID]
									,MAX(DB_BuildNum)	[Build]
									,MIN(EventDate)		[Started]
									,MAX(EventDate)		[Finished]
						FROM		[DBAadmin].[dbo].[BuildSchemaChanges_Agg]
						WHERE		COALESCE(CAST(DEPLInstanceID AS sysname),'') != ''
						GROUP BY	[ServerName]
									,[DEPLInstanceID]
						) T1
			GROUP BY	[InstanceID]		
						,[Build]			
			) T1
LEFT JOIN	(
			SELECT		[DB_BuildNum]		[Build]
						,MAX(DB_BuildApp)	[Application]
						,MAX(DB_BuildBrnch)	[Branch]
						,MAX(VC_Version)	[Version]
			FROM		[DBAadmin].[dbo].[BuildSchemaChanges_Agg]
			GROUP BY	[DB_BuildNum]
			)T2
		ON	T1.BUILD = T2.BUILD

*/

SELECT		[ServerName]
			,[LogId]
			,[EventType]
			,[DatabaseName]
			,[SchemaName]
			,[ObjectName]
			,[ObjectType]
			,[SqlCommand]
			,[EventDate]
			,[LoginName]
			,[UserName]
			,[VC_DatabaseName]
			,[VC_SchemaName]
			,[VC_ObjectType]
			,[VC_ObjectName]
			,[VC_Version]
			,[VC_CreatedBy]
			,[VC_CreatedOn]
			,[VC_ModifiedBy]
			,[VC_ModifiedOn]
			,[VC_Purpose]
			,[VC_BuildApp]
			,[VC_BuildBrnch]
			,[VC_BuildNum]
			,[DB_BuildApp]
			,[DB_BuildBrnch]
			,[DB_BuildNum]
			,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE([Status],''),'CommentHeader Not Found',''),'Current Object is a Newer Version.',''),'*** ROLLBACK ALLOWED ***',''),CHAR(13),''),CHAR(10),''))) [Status]
			,CASE	WHEN LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE([Status],''),'CommentHeader Not Found',''),'Current Object is a Newer Version.',''),'*** ROLLBACK ALLOWED ***',''),CHAR(13),''),CHAR(10),''))) LIKE '' THEN 0 -- SOMETHING EXISTS CONSIDER IT A SUCCESS
				WHEN [Status] Like '%error%' THEN 2 -- CONSIDER IT A SUCCESS
				WHEN [Status] Like '%object not deployed%' THEN 2 -- CONSIDER IT A SUCCESS
				WHEN [Status] Like '%DEP FAIL:%' THEN 2 -- CONSIDER IT A SUCCESS
				ELSE 1 END [StatusMarker] -- SOMETHING EXISTS CONSIDER IT A WARNING
			,[DEPLFileName]
			,[DEPLInstanceID]
FROM		[DBAadmin].[dbo].[BuildSchemaChanges_Agg] WITH(NOLOCK)
WHERE		[DEPLInstanceID] = @DeploymentInstance