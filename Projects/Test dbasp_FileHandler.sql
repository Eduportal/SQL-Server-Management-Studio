
SET NOCOUNT ON
GO

DECLARE		@Source		VarChar(max)
		,@Destination	VarChar(max)
		,@Data		XML

SELECT		@Source		= '\\FREPSQLRYLA01\FREPSQLRYLA01_Backup\'
		,@Destination	= '\\FREPSQLRYLA01\FREPSQLRYLA01_Backup\'

		--\\FREPSQLRYLA01\FREPSQLRYLA01_Backup\


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
		FROM		dbaudf_DirectoryList2(@Source,'dbaadmin*',0)
		)
SELECT		@Data =	(
			SELECT		*
					,(SELECT * FROM CopyFile FOR XML RAW ('CopyFile'), TYPE)
			FROM		Settings
			FOR XML RAW ('Settings'),TYPE, ROOT('FileProcess')
			)


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
		FROM		dbaudf_DirectoryList2(@Source,'dbaadmin*',0)
		)
SELECT		@Data =	
		@Data + (
			SELECT		*
					,(SELECT * FROM CopyFile FOR XML RAW ('CopyFile'), TYPE)
			FROM		Settings
			FOR XML RAW ('Settings'),TYPE, ROOT('FileProcess')
			)

SELECT @Data






exec dbasp_FileHandler @Data




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



