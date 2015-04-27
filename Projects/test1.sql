USE [DBAADMIN]
GO



--DROP TYPE [dbo].[LookupTable_C1_VCM_NN]
--GO

--CREATE TYPE [dbo].[LookupTable_C1_VCM_NN] AS TABLE 
--(
--	C1 VarChar(MAX) NOT NULL
--)
--GO


CREATE FUNCTION		dbaudf_BackupScripter_GetBackupFiles
				(
				@DBName			SYSNAME
				,@FilePath		VarChar(max)
				,@NameMatches		[LookupTable_C1_VCM_NN] READONLY
				)
RETURNS TABLE AS RETURN
(
	SELECT		T1.Mask
			,@DBName [DBName]
			,CAST(STUFF(STUFF(STUFF(STUFF(STUFF(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(T1.Name,'DB_FG_','FG_'),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),[MaxParts]-1),13,0,':'),11,0,':'),9,0,' '),7,0,'-'),5,0,'-') AS DATETIME) AS [BackupTimeStamp]

			,CASE WHEN [FileGroup] IS NOT NULL
				THEN 'FG_' + [FileGroup]
				ELSE dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(T1.Name,'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),2) END AS [BackupType]

			,CASE T1.Extension 
				WHEN '.sqb' THEN 'RedGate'
				WHEN '.sqd' THEN 'RedGate'
				WHEN '.sqt' THEN 'RedGate'
				ELSE 'Microsoft' END [BackupEngine]
			,CASE WHEN CHARINDEX('_set_',T1.Name) > 0 THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(T1.Name,'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),7) ELSE 1 END AS [BackupSetSize]
			,COUNT(*) [Files]
			,REPLACE(dbaadmin.dbo.dbaudf_RegexReplace(T1.Name,'set_[0-9][0-9]_of_[0-9][0-9]','set_**'),'**','*') [Name]
			,REPLACE(dbaadmin.dbo.dbaudf_RegexReplace(T1.FullPathName,'set_[0-9][0-9]_of_[0-9][0-9]','set_**'),'**','*') [FullPathName]
			,T1.Directory	
			,T1.Extension	
			,MAX(T1.DateCreated)	[DateCreated]
			,MAX(T1.DateAccessed)	[DateAccessed]
			,MAX(T1.DateModified)	[DateModified]
			,MAX(T1.Attributes)	[Attributes]
			,SUM(T1.Size)/POWER(1024.,3) [Size_GB]
	FROM		(			
			SELECT		T2.C1 Mask
					,T1.[Name]	
					,T1.FullPathName	
					,T1.Directory	
					,T1.Extension	
					,T1.DateCreated	
					,T1.DateAccessed	
					,T1.DateModified	
					,T1.Attributes	
					,T1.Size
					,(SELECT MAX(OccurenceID) FROM [dbaadmin].[dbo].[dbaudf_StringToTable](REPLACE(REPLACE(REPLACE(REPLACE(T1.Name,'DB_FG_','FG_'),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),'|')) [MaxParts]
					,CASE WHEN T1.Name LIKE @DBName+'_DB_FG_%' THEN
						(SELECT	REPLACE([dbaadmin].[dbo].[dbaudf_Concatenate]([SplitValue]),',','_')
							FROM	[dbaadmin].[dbo].[dbaudf_StringToTable](REPLACE(REPLACE(REPLACE(REPLACE(T1.Name,'DB_FG_','FG_'),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),'|')
							WHERE	OccurenceID Between 3 AND ((SELECT MAX(OccurenceID) FROM [dbaadmin].[dbo].[dbaudf_StringToTable](REPLACE(REPLACE(REPLACE(REPLACE(T1.Name,'DB_FG_','FG_'),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),'|'))-2)) END [FileGroup]
			FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,NULL,0) T1
			JOIN		@NameMatches T2
				ON	T1.NAME LIKE T2.C1
			) T1
	GROUP BY	T1.Mask
			,CAST(STUFF(STUFF(STUFF(STUFF(STUFF(dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(REPLACE(T1.Name,'DB_FG_','FG_'),'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),[MaxParts]-1),13,0,':'),11,0,':'),9,0,' '),7,0,'-'),5,0,'-') AS DATETIME)

			,CASE WHEN [FileGroup] IS NOT NULL
				THEN 'FG_' + [FileGroup]
				ELSE dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(T1.Name,'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),2) END

			,CASE WHEN CHARINDEX('_set_',T1.Name) > 0 THEN dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(REPLACE(REPLACE(T1.Name,'_','|'),'.','|'),REPLACE(@DBName,'_','|'),@DBName),7) ELSE 1 END
			,REPLACE(dbaadmin.dbo.dbaudf_RegexReplace(T1.Name,'set_[0-9][0-9]_of_[0-9][0-9]','set_**'),'**','*')
			,REPLACE(dbaadmin.dbo.dbaudf_RegexReplace(T1.FullPathName,'set_[0-9][0-9]_of_[0-9][0-9]','set_**'),'**','*')	
			,T1.Directory	
			,T1.Extension
)
GO
