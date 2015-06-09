SET NOCOUNT ON
GO

DECLARE		@ManualPaths	nVarChar(4000) = NULL --'C:\temp|D:\'

DECLARE		@Data		XML
DECLARE		@FilePath	VarChar(max)
DECLARE		@Files		TABLE
		(
		FullPathName	VarChar(max)
		,Extension	VarChar(50)
		)

DECLARE CursorName CURSOR
FOR
SELECT		DISTINCT
		dbaadmin.dbo.dbaudf_GetFileProperty(dbaadmin.dbo.dbaudf_GetFileProperty(physical_name,'file','DirectoryName'),'folder','Root')
FROM		sys.master_files
UNION
SELECT		SplitValue
FROM		dbaadmin.dbo.dbaudf_StringToTable(@ManualPaths,'|')


OPEN CursorName;
FETCH CursorName INTO @FilePath; 
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		MERGE		@Files AS target
			USING	(
				SELECT		FullPathName
						,Extension
				FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,'*.?df',1)
				WHERE		Extension IN ('.mdf','.ndf','.ldf')
					AND	Directory Not like '%\Binn%'
				) AS source (FullPathName, Extension)
			ON	(
				target.FullPathName = source.FullPathName
				)
			WHEN	NOT MATCHED THEN
				INSERT (FullPathName, Extension)
				VALUES (source.FullPathName, source.Extension);
		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM CursorName INTO @FilePath;
END
CLOSE CursorName;
DEALLOCATE CursorName;

;WITH		Settings
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
		SELECT		T1.FullPathName [Source]
		FROM		@Files T1
		LEFT JOIN	sys.master_files T2
			ON	T1.FullPathName = T2.physical_name
		WHERE		T2.physical_name IS NULL
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

--exec dbaadmin.dbo.dbasp_FileHandler @Data


GO
