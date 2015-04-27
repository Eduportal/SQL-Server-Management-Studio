----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
--						DELETE FILES EXAMPLE
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
GO

DECLARE		@Data		XML


;WITH		BF
		AS
		(
		SELECT		*
		FROM		dbaadmin.dbo.dbaudf_BackupScripter_GetBackupFiles('RightsPrice','\\seapsqlrpt01\seapsqlrpt01_restore\',0)
		)
		,Settings
		AS
		(
		SELECT		32		AS [QueueMax]		-- Max Number of files coppied at once.
				,'false'	AS [ForceOverwrite]	-- true,false
				,1		AS [Verbose]		-- -1 = Silent, 0 = Normal, 1 = Percent Updates
				,300		AS [UpdateInterval]	-- rate of progress updates in Seconds
		)
		,DeleteFile
		AS
		(
		------------------------------------------------------------
		------------------------------------------------------------
		--		START OF FILE SELECTION QUERY
		------------------------------------------------------------
		------------------------------------------------------------
		SELECT		BF1.FullPathName [Source]
		FROM		BF BF1
		LEFT JOIN	(
				SELECT	DBName
					,BackupType
					,MAX(BackupTimeStamp) [BackupTimeStamp]
				FROM	BF
				GROUP BY DBName
					,BackupType
				) BF2
			ON	BF1.DBName = BF2.DBName
			AND	BF1.BackupType = BF2.BackupType
			AND	BF1.[BackupTimeStamp] = BF2.[BackupTimeStamp]
		WHERE		BF2.[BackupTimeStamp] IS NULL
		------------------------------------------------------------
		------------------------------------------------------------
		--		END OF FILE SELECTION QUERY
		------------------------------------------------------------
		------------------------------------------------------------
		)
SELECT		@Data =	(
			SELECT		*
					,(SELECT * FROM DeleteFile FOR XML RAW ('DeleteFile'), TYPE)
			FROM		Settings
			FOR XML RAW ('Settings'),TYPE, ROOT('FileProcess')
			)


SELECT @Data

exec dbasp_FileHandler @Data

GO


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
--						COPY FILES EXAMPLE
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
GO

DECLARE		@Source		VarChar(max)
		,@Destination	VarChar(max)
		,@Mask		VarChar(max)
		,@Data		XML

SELECT		@Source		= '\\SEAPSQLRYL0A\post_calc'
		,@Destination	= 'H:\PostCalcBackups'
		,@Mask		= '*'

--RETURN TOTAL FILE SIZE
SELECT	dbaadmin.dbo.dbaudf_FormatBytes(SUM(Size),'byte')
FROM	dbaadmin.dbo.dbaudf_DirectoryList2(@Source,@Mask,0)

--BUILD COPY COMMAND
;WITH		Settings
		AS
		(
		SELECT		32		AS [QueueMax]		-- Max Number of files coppied at once.
				,'false'	AS [ForceOverwrite]	-- true,false
				,1		AS [Verbose]		-- -1 = Silent, 0 = Normal, 1 = Percent Updates
				,300		AS [UpdateInterval]	-- rate of progress updates in Seconds
		)
		,CopyFile -- MoveFile, DeleteFile
		AS
		(
		SELECT		FullPathName			AS [Source]
				,@Destination + '\' + Name	AS [Destination] 
		FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@Source,@Mask,0)
		)
SELECT		@Data =	(
			SELECT		*
					,(SELECT * FROM CopyFile FOR XML RAW ('CopyFile'), TYPE)
			FROM		Settings
			FOR XML RAW ('Settings'),TYPE, ROOT('FileProcess')
			)
SELECT @Data

exec dbaadmin.dbo.dbasp_FileHandler @Data
GO






----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
--						OTHER
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------


declare @retcode int
exec @retcode = dbasp_FileCompare 'd:\MSSQL\Backup\VocabularyTool_db_20130816210035.cBAK','d:\MSSQL\Backup\test_destination\VocabularyTool_db_20130816210035.cBAK'
select @retcode




---- MOVE FILES
--------------------------------------------------------------------------
--SELECT		@Data = 
--		(
--		SELECT		FullPathName [Source]
--				,@Destination + '\Done\' + Name [Destination]
--		FROM		dbaudf_DirectoryList2(@Destination,NULL,0)
--		FOR XML RAW ('MoveFile'), TYPE, ROOT('FileProcess')
--		)

--SELECT @Data

--exec dbasp_FileHandler @Data






---- DELETE FILES
--------------------------------------------------------------------------
--SELECT		@Data = 
--		(
--		SELECT		FullPathName [Source]
--		FROM		dbaudf_DirectoryList2(@Destination + '\Done\','*.old',0)
--		FOR XML RAW ('DeleteFile'), TYPE, ROOT('FileProcess')
--		)

--SELECT @Data

--exec dbasp_FileHandler @Data









-- DELETE FILES
------------------------------------------------------------------------
SELECT		@Data = 
		(
		SELECT		FullPathName [Source]
				,@Destination + '\' + Name [Destination]
		FROM		dbaudf_DirectoryList2('\\FREPSQLRYLA01\FREPSQLRYLA01_Backup\','Getty_Master_db_20130822163737*',0)
		FOR XML RAW ('CopyFile'), TYPE, ROOT('FileProcess')
		)

SELECT @Data

--exec dbasp_FileHandler @Data



