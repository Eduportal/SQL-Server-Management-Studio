SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON


-------------------------------------------------------------------------------------------------------------------------------
----	Error Trapping: Check If Procedure Already Exists And Drop If Applicable
-------------------------------------------------------------------------------------------------------------------------------

--IF OBJECT_ID (N'[dbo].[usp_SQL_Server_System_Report]', N'P') IS NOT NULL
--BEGIN

--	DROP PROCEDURE [dbo].[usp_SQL_Server_System_Report]

--END
--GO

------------------------------------------------------------------------------------------------------------------

--CREATE PROCEDURE [dbo].[usp_SQL_Server_System_Report]
DECLARE
	 @v_Output_Mode CHAR (1) 
	,@vUnused_Index_Days INT 

SELECT	 @v_Output_Mode		= 'E'
	,@vUnused_Index_Days	= 7

--AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
SET ARITHABORT OFF
SET ARITHIGNORE ON

DECLARE	@hold		VarChar(max)
	,@PartNumber	INT
	,@Pointer	INT
	,@ComBlkPart	VarChar(max)

DECLARE @vBody AS NVARCHAR (MAX)
DECLARE @vCopy_Recipients AS VARCHAR (MAX)
DECLARE @vDatabase_Name_Loop AS NVARCHAR (500)
DECLARE @vDatabase_Name_Table AS TABLE (database_name SYSNAME PRIMARY KEY CLUSTERED)
DECLARE @vDate_24_Hours_Ago AS DATETIME
DECLARE @vDate_Now AS DATETIME
DECLARE @vFixed_Drives_Free_Space_Table AS TABLE (drive_letter VARCHAR (5) PRIMARY KEY CLUSTERED, free_space_mb BIGINT)
DECLARE @vOnline_Since AS NVARCHAR (19)
DECLARE @vRecipients AS VARCHAR (MAX)
DECLARE @vSQL_String AS NVARCHAR (MAX)
DECLARE @vSubject AS NVARCHAR (255)
DECLARE @vUptime AS VARCHAR (22)
DECLARE @vXML_String AS NVARCHAR (MAX)


SET @vBody = N''
SET @vCopy_Recipients = NULL
SET @vDate_24_Hours_Ago = GETDATE ()-1
SET @vDate_Now = @vDate_24_Hours_Ago+1
SET @vRecipients = 'your@email_address.com'
SET @vSubject = N'SQL Server System Report: '+@@SERVERNAME
SET @vXML_String = N''


SELECT
	 @vOnline_Since = CONVERT (NVARCHAR (19), DB.create_date, 120)
	,@vUptime = (CASE
					WHEN SQ2.total_days = 0 THEN '_'
					ELSE SQ2.total_days
					END)+' Day(s) '+(CASE
										WHEN SQ2.seconds_remaining = 0 THEN '__:__:__'
										WHEN SQ2.seconds_remaining < 60 THEN '__:__:'+RIGHT (SQ2.total_seconds, 2)
										WHEN SQ2.seconds_remaining < 3600 THEN '__:'+RIGHT (SQ2.total_seconds, 5)
										ELSE SQ2.total_seconds
										END)
FROM
	[master].[sys].[databases] DB
	OUTER APPLY

		(
			SELECT
				DATEDIFF (SECOND, DB.create_date, GETDATE ()) AS uptime_seconds
		) SQ1

	OUTER APPLY

		(
			SELECT
				 CONVERT (VARCHAR (5), SQ1.uptime_seconds/86400) AS total_days
				,CONVERT (CHAR (8), DATEADD (SECOND, SQ1.uptime_seconds%86400, 0), 108) AS total_seconds
				,SQ1.uptime_seconds%86400 AS seconds_remaining
		) SQ2

WHERE
	DB.name = N'tempdb'


INSERT INTO @vDatabase_Name_Table

SELECT
	DB.name AS database_name
FROM
	[master].[sys].[databases] DB
WHERE
	DB.[state] = 0
	AND DB.is_read_only = 0
	AND DB.is_in_standby = 0
	AND DB.source_database_id IS NULL


-----------------------------------------------------------------------------------------------------------------------------
--	Error Trapping: Check If Temp Table(s) Already Exist(s) And Drop If Applicable
-----------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_instance_property', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_instance_property

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_database_size_distribution_stats', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_database_size_distribution_stats

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_model_compatibility_size_growth', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_model_compatibility_size_growth

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_last_backup_set', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_last_backup_set

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_agent_jobs', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_agent_jobs

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_unused_indexes', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_unused_indexes

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query I: Server Instance Property Information
-----------------------------------------------------------------------------------------------------------------------------

SELECT
	 SERVERPROPERTY (N'ComputerNamePhysicalNetBIOS') AS netbios_name
	,@@SERVERNAME AS server_name
	,REPLACE (CONVERT (NVARCHAR (128), SERVERPROPERTY (N'Edition')), ' Edition', '') AS edition
	,SERVERPROPERTY (N'ProductVersion') AS [version]
	,SERVERPROPERTY (N'ProductLevel') AS [level]
	,(CASE SERVERPROPERTY (N'IsClustered')
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_clustered
	,@vOnline_Since AS online_since
	,@vUptime AS uptime
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, @@CONNECTIONS), 1)), 4, 23)) AS connections
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, @@TOTAL_READ), 1)), 4, 23)) AS reads
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, @@TOTAL_WRITE), 1)), 4, 23)) AS writes
	,(CASE @@DATEFIRST
		WHEN 1 THEN 'Monday'
		WHEN 2 THEN 'Tuesday'
		WHEN 3 THEN 'Wednesday'
		WHEN 4 THEN 'Thursday'
		WHEN 5 THEN 'Friday'
		WHEN 6 THEN 'Saturday'
		WHEN 7 THEN 'Sunday'
		ELSE 'N/A'
		END) AS first_day_of_week
	,REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (RIGHT (@@VERSION, CHARINDEX (REVERSE (' on Windows '), REVERSE (@@VERSION))-1), 'Service Pack ', 'SP'), '(', ''), ')', ''), '<', '('), '>', ')') AS windows_version
INTO
	dbo.#temp_sssr_instance_property


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Instance_Property

END


IF @v_Output_Mode = 'E'
BEGIN

	SET @vXML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.netbios_name AS 'td'
					,'',X.server_name AS 'td'
					,'',X.edition AS 'td'
					,'',X.[version] AS 'td'
					,'',X.[level] AS 'td'
					,'',X.is_clustered AS 'td'
					,'',X.online_since AS 'td'
					,'',X.uptime AS 'td'
					,'','right_align'+X.connections AS 'td'
					,'','right_align'+X.reads AS 'td'
					,'','right_align'+X.writes AS 'td'
					,'',X.first_day_of_week AS 'td'
					,'',X.windows_version AS 'td'
				FROM
					dbo.#temp_sssr_instance_property X
				FOR
					XML PATH ('tr')
			)
		)


	SET @vBody =

		N'
			<h3><center>Server Instance Property Information</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>NetBIOS Name</th>
						<th>Server Name</th>
						<th>Edition</th>
						<th>Version</th>
						<th>Level</th>
						<th>Clustered</th>
						<th>Online Since</th>
						<th>Uptime</th>
						<th>Connections</th>
						<th>Reads</th>
						<th>Writes</th>
						<th>First Day Of Week</th>
						<th>Windows Version</th>
					</tr>
		 '


	SET @vBody = @vBody+@vXML_String+

		N'
				</table>
			</center>
		 '

SET @hold = '' 

DECLARE DDLPartCursor CURSOR
FOR
SELECT	* 
From	dbaadmin.dbo.dbaudf_SplitSize(@vBody,7000)

OPEN DDLPartCursor
FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
		SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
		SET @Hold = RIGHT(@ComBlkPart,@Pointer)
		SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
		PRINT @ComBlkPart
	END
	FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
END
CLOSE DDLPartCursor
DEALLOCATE DDLPartCursor

END
ELSE BEGIN

	SELECT
		 X.netbios_name
		,X.server_name
		,X.edition
		,X.[version]
		,X.[level]
		,X.is_clustered AS [clustered]
		,X.online_since
		,X.uptime
		,X.connections
		,X.reads
		,X.writes
		,X.first_day_of_week
		,X.windows_version
	FROM
		dbo.#temp_sssr_instance_property X

END


Skip_Instance_Property:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_instance_property', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_instance_property

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query II: Fixed Drives Free Space
-----------------------------------------------------------------------------------------------------------------------------

INSERT INTO @vFixed_Drives_Free_Space_Table

	(
		 drive_letter
		,free_space_mb
	)

EXECUTE [master].[dbo].[xp_fixeddrives]


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Fixed_Drives_Free_Space

END


IF @v_Output_Mode = 'E'
BEGIN

	SET @vXML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.drive_letter+':' AS 'td'
					,'','right_align'+REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, X.free_space_mb), 1)), 4, 23)) AS 'td'
				FROM
					@vFixed_Drives_Free_Space_Table X
				ORDER BY
					X.drive_letter
				FOR
					XML PATH ('tr')
			)
		)


	SET @vBody = 

		N'
			<br><br>
			<h3><center>Fixed Drives Free Space</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Drive Letter</th>
						<th>Free Space (MB)</th>
					</tr>
		 '


	SET @vBody = @vBody+@vXML_String+

		N'
				</table>
			</center>
		 '

SET @hold = '' 

DECLARE DDLPartCursor CURSOR
FOR
SELECT	* 
From	dbaadmin.dbo.dbaudf_SplitSize(@vBody,7000)

OPEN DDLPartCursor
FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
		SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
		SET @Hold = RIGHT(@ComBlkPart,@Pointer)
		SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
		PRINT @ComBlkPart
	END
	FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
END
CLOSE DDLPartCursor
DEALLOCATE DDLPartCursor
	
END
ELSE BEGIN

	SELECT
		 X.drive_letter+':' AS drive_letter
		,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, X.free_space_mb), 1)), 4, 23)) AS free_space_mb
	FROM
		@vFixed_Drives_Free_Space_Table X
	ORDER BY
		X.drive_letter

END


Skip_Fixed_Drives_Free_Space:


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query III: Database Size (Summary) / Distribution Stats
-----------------------------------------------------------------------------------------------------------------------------

CREATE TABLE dbo.#temp_sssr_database_size_distribution_stats

	(
		 database_name NVARCHAR (500)
		,total_size_mb VARCHAR (15)
		,unallocated_mb VARCHAR (15)
		,reserved_mb VARCHAR (15)
		,data_mb VARCHAR (15)
		,index_mb VARCHAR (15)
		,unused_mb VARCHAR (15)
	)


SET @vDatabase_Name_Loop =

	(
		SELECT TOP (1)
			DBNT.database_name
		FROM
			@vDatabase_Name_Table DBNT
		ORDER BY
			DBNT.database_name
	)


WHILE @vDatabase_Name_Loop IS NOT NULL
BEGIN

	SET @vSQL_String =

		N'
			USE ['+@vDatabase_Name_Loop+N'];


			INSERT INTO dbo.#temp_sssr_database_size_distribution_stats

			SELECT
				 DB_NAME () AS database_name
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((SQ1.total_size*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23)) AS total_size_mb
				,(CASE
					WHEN SQ1.database_size >= SQ2.total_pages THEN REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (((SQ1.database_size-SQ2.total_pages)*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23))
					ELSE ''0''
					END) AS unallocated_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((SQ2.total_pages*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23)) AS reserved_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((SQ2.pages*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23)) AS data_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (((SQ2.used_pages-SQ2.pages)*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23)) AS index_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (((SQ2.total_pages-SQ2.used_pages)*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23)) AS unused_mb
			FROM

				(
					SELECT
						 SUM (CASE
								WHEN DBF.[type] = 0 THEN DBF.size
								ELSE 0
								END) AS database_size
						,SUM (DBF.size) AS total_size
					FROM
						[sys].[database_files] AS DBF
					WHERE
						DBF.[type] IN (0, 1)
				) SQ1

				CROSS JOIN

					(
						SELECT
							 SUM (AU.total_pages) AS total_pages
							,SUM (AU.used_pages) AS used_pages
							,SUM (CASE
									WHEN IT.internal_type IN (202, 204) THEN 0
									WHEN AU.[type] <> 1 THEN AU.used_pages
									WHEN P.index_id <= 1 THEN AU.data_pages
									ELSE 0
									END) AS pages
						FROM
							[sys].[partitions] P
							INNER JOIN [sys].[allocation_units] AU ON AU.container_id = P.partition_id
							LEFT JOIN [sys].[internal_tables] IT ON IT.[object_id] = P.[object_id]
					) SQ2
		 '


	EXECUTE (@vSQL_String)


	SET @vDatabase_Name_Loop =

		(
			SELECT TOP (1)
				DBNT.database_name
			FROM
				@vDatabase_Name_Table DBNT
			WHERE
				DBNT.database_name > @vDatabase_Name_Loop
			ORDER BY
				DBNT.database_name
		)

END


IF NOT EXISTS (SELECT * FROM dbo.#temp_sssr_database_size_distribution_stats)
BEGIN

	GOTO Skip_Database_Size_Distribution_Stats

END


IF @v_Output_Mode = 'E'
BEGIN

	SET @vXML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.database_name AS 'td'
					,'','right_align'+X.total_size_mb AS 'td'
					,'','right_align'+X.unallocated_mb AS 'td'
					,'','right_align'+X.reserved_mb AS 'td'
					,'','right_align'+X.data_mb AS 'td'
					,'','right_align'+X.index_mb AS 'td'
					,'','right_align'+X.unused_mb AS 'td'
				FROM
					dbo.#temp_sssr_database_size_distribution_stats X
				ORDER BY
					X.database_name
				FOR
					XML PATH ('tr')
			)
		)


	SET @vBody = 

		N'
			<br><br>
			<h3><center>Database Size (Summary) / Distribution Stats</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Total Size (MB)</th>
						<th>Unallocated (MB)</th>
						<th>Reserved (MB)</th>
						<th>Data (MB)</th>
						<th>Index (MB)</th>
						<th>Unused (MB)</th>
					</tr>
		 '


	SET @vBody = @vBody+@vXML_String+

		N'
				</table>
			</center>
		 '

SET @hold = '' 

DECLARE DDLPartCursor CURSOR
FOR
SELECT	* 
From	dbaadmin.dbo.dbaudf_SplitSize(@vBody,7000)

OPEN DDLPartCursor
FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
		SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
		SET @Hold = RIGHT(@ComBlkPart,@Pointer)
		SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
		PRINT @ComBlkPart
	END
	FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
END
CLOSE DDLPartCursor
DEALLOCATE DDLPartCursor
	
END
ELSE BEGIN

	SELECT
		*
	FROM
		dbo.#temp_sssr_database_size_distribution_stats X
	ORDER BY
		X.database_name

END


Skip_Database_Size_Distribution_Stats:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_database_size_distribution_stats', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_database_size_distribution_stats

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query IV: Database Recovery Model / Compatibility / Size (Detailed) / Growth Stats
-----------------------------------------------------------------------------------------------------------------------------

SELECT
	 DB_NAME (MF.database_id) AS database_name
	,DB.recovery_model_desc
	,DB.[compatibility_level]
	,CONVERT (NVARCHAR (10), LEFT (UPPER (MF.type_desc), 1)+LOWER (SUBSTRING (MF.type_desc, 2, 250))) AS file_type
	,MF.name AS [file_name]
	,CONVERT (NVARCHAR (19), DB.create_date, 120) AS create_date
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((MF.size*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23)) AS file_size_mb
	,RIGHT ((CASE
				WHEN MF.growth = 0 THEN 'Fixed Size'
				WHEN MF.max_size = -1 THEN 'Unrestricted'
				WHEN MF.max_size = 0 THEN 'None'
				WHEN MF.max_size = 268435456 THEN '2 TB'
				ELSE REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((MF.max_size*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23))+' MB'
				END), 15) AS max_size
	,RIGHT ((CASE
				WHEN MF.growth = 0 THEN 'N/A'
				WHEN MF.is_percent_growth = 1 THEN REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, MF.growth), 1)), 4, 23))+' %'
				ELSE REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((MF.growth*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 23))+' MB'
				END), 15) AS growth_increment
	,ROW_NUMBER () OVER
						(
							PARTITION BY
								MF.database_id
							ORDER BY
								 MF.[type]
								,(CASE
									WHEN MF.[file_id] = 1 THEN 10
									ELSE 99
									END)
								,MF.name
						) AS database_filter_id
INTO
	dbo.#temp_sssr_model_compatibility_size_growth
FROM
	[master].[sys].[master_files] MF
	INNER JOIN [master].[sys].[databases] DB ON DB.database_id = MF.database_id


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Model_Compatibility_Size_Growth

END


IF @v_Output_Mode = 'E'
BEGIN

	SET @vXML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',(CASE
							WHEN X.database_filter_id = 1 THEN X.database_name
							ELSE ''
							END) AS 'td'
					,'',(CASE
							WHEN X.database_filter_id = 1 THEN X.recovery_model_desc
							ELSE ''
							END) AS 'td'
					,'',(CASE
							WHEN X.database_filter_id = 1 THEN ISNULL (CONVERT (VARCHAR (5), X.[compatibility_level]), 'N/A')
							ELSE ''
							END) AS 'td'
					,'',X.file_type AS 'td'
					,'',X.[file_name] AS 'td'
					,'',X.create_date AS 'td'
					,'','right_align'+X.file_size_mb AS 'td'
					,'','right_align'+X.max_size AS 'td'
					,'','right_align'+X.growth_increment AS 'td'
				FROM
					dbo.#temp_sssr_model_compatibility_size_growth X
				ORDER BY
					 X.database_name
					,X.database_filter_id
				FOR
					XML PATH ('tr')
			)
		)


	SET @vBody = 

		N'
			<br><br>
			<h3><center>Database Recovery Model / Compatibility / Size (Detailed) / Growth Stats</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Recovery Model</th>
						<th>Compatibility</th>
						<th>File Type</th>
						<th>File Name</th>
						<th>Create Date</th>
						<th>File Size (MB)</th>
						<th>Max Size</th>
						<th>Growth Increment</th>
					</tr>
		 '


	SET @vBody = @vBody+@vXML_String+

		N'
				</table>
			</center>
		 '
SET @hold = '' 

DECLARE DDLPartCursor CURSOR
FOR
SELECT	* 
From	dbaadmin.dbo.dbaudf_SplitSize(@vBody,7000)

OPEN DDLPartCursor
FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
		SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
		SET @Hold = RIGHT(@ComBlkPart,@Pointer)
		SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
		PRINT @ComBlkPart
	END
	FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
END
CLOSE DDLPartCursor
DEALLOCATE DDLPartCursor
	
END
ELSE BEGIN

	SELECT
		 (CASE
			WHEN X.database_filter_id = 1 THEN X.database_name
			ELSE ''
			END) AS database_name
		,(CASE
			WHEN X.database_filter_id = 1 THEN X.recovery_model_desc
			ELSE ''
			END) AS recovery_model
		,(CASE
			WHEN X.database_filter_id = 1 THEN ISNULL (CONVERT (VARCHAR (5), X.[compatibility_level]), 'N/A')
			ELSE ''
			END) AS compatibility
		,X.file_type
		,X.[file_name]
		,X.create_date
		,X.file_size_mb
		,X.max_size
		,X.growth_increment
	FROM
		dbo.#temp_sssr_model_compatibility_size_growth X
	ORDER BY
		 X.database_name
		,X.database_filter_id

END


Skip_Model_Compatibility_Size_Growth:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_model_compatibility_size_growth', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_model_compatibility_size_growth

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query V: Last Backup Set Details
-----------------------------------------------------------------------------------------------------------------------------

SELECT
	 DB.name AS database_name
	,ISNULL (CONVERT (VARCHAR (10), SQ5.backup_set_id), 'NONE') AS backup_set_id
	,(CASE SQ5.[type]
		WHEN 'D' THEN 'Database'
		WHEN 'F' THEN 'File Or Filegroup'
		WHEN 'G' THEN 'Differential File'
		WHEN 'I' THEN 'Differential Database'
		WHEN 'L' THEN 'Log'
		WHEN 'P' THEN 'Partial'
		WHEN 'Q' THEN 'Differential Partial'
		ELSE 'N/A'
		END) AS backup_type
	,ISNULL (CONVERT (VARCHAR (10), SQ5.database_version), 'N/A') AS database_version
	,ISNULL (SQ5.server_name, 'N/A') AS server_name
	,ISNULL (SQ5.machine_name, 'N/A') AS machine_name
	,ISNULL (CONVERT (VARCHAR (34), SQ5.backup_start_date, 120), 'N/A') AS backup_start_date
	,ISNULL (CONVERT (VARCHAR (34), SQ5.backup_finish_date, 120), 'N/A') AS backup_finish_date
	,ISNULL ((CASE
				WHEN SQ5.total_days = 0 THEN REPLICATE ('_', SQ5.day_max_length)
				ELSE REPLICATE ('0', SQ5.day_max_length-LEN (SQ5.total_days))+SQ5.total_days
				END)+' Day(s) '+(CASE
									WHEN SQ5.seconds_remaining = 0 THEN '__:__:__'
									WHEN SQ5.seconds_remaining < 60 THEN '__:__:'+RIGHT (SQ5.total_seconds, 2)
									WHEN SQ5.seconds_remaining < 3600 THEN '__:'+RIGHT (SQ5.total_seconds, 5)
									ELSE SQ5.total_seconds
									END), 'N/A') AS duration
	,ISNULL (REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (SQ5.backup_size/1048576.0, 0)), 1)), 4, 23)), 'N/A') AS backup_size_mb
	,ISNULL (REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DATEDIFF (DAY, SQ5.backup_start_date, GETDATE ())), 1)), 4, 23)), 'N/A') AS days_ago
	,ROW_NUMBER () OVER
						(
							PARTITION BY
								DB.name
							ORDER BY
								SQ5.[type]
						) AS database_filter_id
INTO
	dbo.#temp_sssr_last_backup_set
FROM
	[master].[sys].[databases] DB
	LEFT JOIN

		(
			SELECT
				 BS.database_name
				,BS.backup_set_id
				,BS.[type]
				,BS.database_version
				,BS.server_name
				,BS.machine_name
				,BS.backup_start_date
				,BS.backup_finish_date
				,BS.backup_size
				,SQ2.day_max_length
				,SQ4.seconds_remaining
				,SQ4.total_days
				,SQ4.total_seconds
			FROM
				msdb.dbo.backupset BS
				INNER JOIN

					(
						SELECT
							MAX (XBS.backup_set_id) AS backup_set_id_max
						FROM
							msdb.dbo.backupset XBS
						GROUP BY
							 XBS.database_name
							,XBS.[type]
					) SQ1 ON SQ1.backup_set_id_max = BS.backup_set_id

				CROSS JOIN

					(
						SELECT
							MAX (LEN (DATEDIFF (DAY, YBS.backup_start_date, YBS.backup_finish_date))) AS day_max_length
						FROM
							msdb.dbo.backupset YBS
					) SQ2

				OUTER APPLY

					(
						SELECT
							DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date) AS duration_seconds
					) SQ3

				OUTER APPLY

					(
						SELECT
							 CONVERT (VARCHAR (5), SQ3.duration_seconds/86400) AS total_days
							,CONVERT (CHAR (8), DATEADD (SECOND, SQ3.duration_seconds%86400, 0), 108) AS total_seconds
							,SQ3.duration_seconds%86400 AS seconds_remaining
					) SQ4

		) SQ5 ON SQ5.database_name = DB.name

WHERE
	DB.name <> N'tempdb'


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Last_Backup_Set

END


IF EXISTS (SELECT * FROM dbo.#temp_sssr_last_backup_set X WHERE X.backup_set_id = 'NONE')
BEGIN

	UPDATE
		dbo.#temp_sssr_last_backup_set
	SET
		 backup_type = REPLICATE ('.', backup_type_max_length*2)
		,database_version = REPLICATE ('.', database_version_max_length*2)
		,server_name = REPLICATE ('.', server_name_max_length*2)
		,machine_name = REPLICATE ('.', machine_name_max_length*2)
		,backup_start_date = REPLICATE ('.', 34)
		,backup_finish_date = REPLICATE ('.', 34)
		,duration = REPLICATE ('.', (duration_max_length*2)-4)
		,backup_size_mb = REPLICATE ('.', backup_size_mb_max_length*2)
	FROM

		(
			SELECT
				 MAX (LEN (X.backup_type)) AS backup_type_max_length
				,MAX (LEN (X.database_version)) AS database_version_max_length
				,MAX (LEN (X.server_name)) AS server_name_max_length
				,MAX (LEN (X.machine_name)) AS machine_name_max_length
				,MAX (LEN (X.duration)) AS duration_max_length
				,MAX (LEN (X.backup_size_mb)) AS backup_size_mb_max_length
			FROM
				dbo.#temp_sssr_last_backup_set X
		) SQ1

	WHERE
		dbo.#temp_sssr_last_backup_set.backup_set_id = 'NONE'

END


IF @v_Output_Mode = 'E'
BEGIN

	SET @vXML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',(CASE
							WHEN X.database_filter_id = 1 THEN X.database_name
							ELSE ''
							END) AS 'td'
					,'',X.backup_set_id AS 'td'
					,'',X.backup_type AS 'td'
					,'',X.database_version AS 'td'
					,'',X.server_name AS 'td'
					,'',X.machine_name AS 'td'
					,'',X.backup_start_date AS 'td'
					,'',X.backup_finish_date AS 'td'
					,'',X.duration AS 'td'
					,'','right_align'+X.backup_size_mb AS 'td'
					,'','right_align'+X.days_ago AS 'td'
				FROM
					dbo.#temp_sssr_last_backup_set X
				ORDER BY
					 X.database_name
					,X.database_filter_id
				FOR
					XML PATH ('tr')
			)
		)


	SET @vBody = 

		N'
			<br><br>
			<h3><center>Last Backup Set Details</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Backup Set ID</th>
						<th>Backup Type</th>
						<th>Database Version</th>
						<th>Server Name</th>
						<th>Machine Name</th>
						<th>Backup Start Date</th>
						<th>Backup Finish Date</th>
						<th>Duration</th>
						<th>Backup Size (MB)</th>
						<th>Days Ago</th>
					</tr>
		 '


	SET @vBody = @vBody+@vXML_String+

		N'
				</table>
			</center>
		 '
SET @hold = '' 

DECLARE DDLPartCursor CURSOR
FOR
SELECT	* 
From	dbaadmin.dbo.dbaudf_SplitSize(@vBody,7000)

OPEN DDLPartCursor
FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
		SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
		SET @Hold = RIGHT(@ComBlkPart,@Pointer)
		SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
		PRINT @ComBlkPart
	END
	FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
END
CLOSE DDLPartCursor
DEALLOCATE DDLPartCursor
	
END
ELSE BEGIN

	SELECT
		 (CASE
			WHEN X.database_filter_id = 1 THEN X.database_name
			ELSE ''
			END) AS database_name
		,X.backup_set_id
		,X.backup_type
		,X.database_version
		,X.server_name
		,X.machine_name
		,X.backup_start_date
		,X.backup_finish_date
		,X.duration
		,X.backup_size_mb
		,X.days_ago
	FROM
		dbo.#temp_sssr_last_backup_set X
	ORDER BY
		 X.database_name
		,X.database_filter_id

END


Skip_Last_Backup_Set:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_last_backup_set', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_last_backup_set

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query VI: SQL Server Agent Jobs (Last 24 Hours)
-----------------------------------------------------------------------------------------------------------------------------

SELECT
	 SJ.name AS job_name
	,CONVERT (VARCHAR (19), SQ3.last_run_date_time, 120) AS last_run_date_time
	,(CASE SJH.run_status
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Canceled'
		WHEN 4 THEN 'In Progress'
		END) AS last_status
	,(CASE
		WHEN SJH.run_duration = 0 THEN '__:__:__'
		WHEN LEN (SJH.run_duration) <= 2 THEN '__:__:'+RIGHT ('0'+CONVERT (VARCHAR (2), SJH.run_duration), 2)
		WHEN LEN (SJH.run_duration) <= 4 THEN '__:'+STUFF (RIGHT ('0'+CONVERT (VARCHAR (4), SJH.run_duration), 4), 3, 0, ':')
		ELSE STUFF (STUFF (RIGHT ('0'+CONVERT (VARCHAR (6), SJH.run_duration), 6), 5, 0, ':'), 3, 0, ':')
		END) AS duration
	,ISNULL (CONVERT (VARCHAR (19), SQ2.next_run_date_time, 120), '___________________') AS next_run_date_time
	,ISNULL (REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DATEDIFF (DAY, GETDATE (), SQ2.next_run_date_time)), 1)), 4, 23)), 'N/A') AS days_away
INTO
	dbo.#temp_sssr_agent_jobs
FROM
	msdb.dbo.sysjobs SJ
	INNER JOIN msdb.dbo.sysjobhistory SJH ON SJH.job_id = SJ.job_id
	INNER JOIN

		(
			SELECT
				MAX (XSJ.instance_id) AS instance_id_max
			FROM
				msdb.dbo.sysjobhistory XSJ
			GROUP BY
				XSJ.job_id
		) SQ1 ON SQ1.instance_id_max = SJH.instance_id

	LEFT JOIN

		(
			SELECT
				 SJS.job_id
				,MIN (CONVERT (DATETIME, CONVERT (VARCHAR (8), SJS.next_run_date)+' '+STUFF (STUFF (RIGHT ('000000'+CONVERT (VARCHAR (6), SJS.next_run_time), 6), 5, 0, ':'), 3, 0, ':'))) AS next_run_date_time
			FROM
				msdb.dbo.sysjobschedules SJS
			WHERE
				SJS.next_run_date > 0
			GROUP BY
				SJS.job_id
		) SQ2 ON SQ2.job_id = SJ.job_id

	CROSS APPLY

		(
			SELECT
				CONVERT (DATETIME, CONVERT (VARCHAR (8), SJH.run_date)+' '+STUFF (STUFF (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_time), 6), 5, 0, ':'), 3, 0, ':')) AS last_run_date_time
		) SQ3

WHERE
	SQ3.last_run_date_time >= @vDate_24_Hours_Ago


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Agent_Jobs

END


IF @v_Output_Mode = 'E'
BEGIN

	SET @vXML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.job_name AS 'td'
					,'',X.last_run_date_time AS 'td'
					,'',X.last_status AS 'td'
					,'',X.duration AS 'td'
					,'',X.next_run_date_time AS 'td'
					,'','right_align'+X.days_away AS 'td'
				FROM
					dbo.#temp_sssr_agent_jobs X
				ORDER BY
					X.job_name
				FOR
					XML PATH ('tr')
			)
		)


	SET @vBody =

		N'
			<br><br>
			<h3><center>SQL Server Agent Jobs (Last 24 Hours)</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Job Name</th>
						<th>Last Run Date / Time</th>
						<th>Last Status</th>
						<th>Duration</th>
						<th>Next Run Date / Time</th>
						<th>Days Away</th>
					</tr>
		 '


	SET @vBody = @vBody+@vXML_String+

		N'
				</table>
			</center>
		 '
SET @hold = '' 

DECLARE DDLPartCursor CURSOR
FOR
SELECT	* 
From	dbaadmin.dbo.dbaudf_SplitSize(@vBody,7000)

OPEN DDLPartCursor
FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
		SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
		SET @Hold = RIGHT(@ComBlkPart,@Pointer)
		SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
		PRINT @ComBlkPart
	END
	FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
END
CLOSE DDLPartCursor
DEALLOCATE DDLPartCursor
	
END
ELSE BEGIN

	SELECT
		X.*
	FROM
		dbo.#temp_sssr_agent_jobs X
	ORDER BY
		X.job_name

END


Skip_Agent_Jobs:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_agent_jobs', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_agent_jobs

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query VII: Unused Indexes
-----------------------------------------------------------------------------------------------------------------------------

IF DATEDIFF (SECOND, @vOnline_Since, GETDATE ()) < (@vUnused_Index_Days*86400)
BEGIN

	GOTO Skip_Unused_Indexes

END


CREATE TABLE dbo.#temp_sssr_unused_indexes

	(
		 database_name NVARCHAR (512)
		,[schema_name] SYSNAME
		,[object_name] SYSNAME
		,column_name SYSNAME
		,index_name SYSNAME
		,[disabled] VARCHAR (3)
		,hypothetical VARCHAR (3)
		,drop_index_statement NVARCHAR (4000)
	)


SET @vDatabase_Name_Loop =

	(
		SELECT TOP (1)
			DBNT.database_name
		FROM
			@vDatabase_Name_Table DBNT
		ORDER BY
			DBNT.database_name
	)


WHILE @vDatabase_Name_Loop IS NOT NULL
BEGIN

	SET @vSQL_String =

		N'
			USE ['+@vDatabase_Name_Loop+N'];


			INSERT INTO dbo.#temp_sssr_unused_indexes

			SELECT
				 DB_NAME () AS database_name
				,S.name AS [schema_name]
				,O.name AS [object_name]
				,C.name AS column_name
				,I.name AS index_name
				,(CASE
					WHEN I.is_disabled = 1 THEN ''Yes''
					ELSE ''No''
					END) AS [disabled]
				,(CASE
					WHEN I.is_hypothetical = 1 THEN ''Yes''
					ELSE ''No''
					END) AS hypothetical
				,N''USE ''+DB_NAME ()+N''; DROP INDEX ''+S.name+N''.''+O.name+N''.''+I.name+N'';'' AS drop_index_statement
			FROM
				[sys].[indexes] I
				INNER JOIN [sys].[objects] O ON O.[object_id] = I.[object_id]
					AND O.[type] = ''U''
					AND O.is_ms_shipped = 0
					AND O.name <> ''sysdiagrams''
				INNER JOIN [sys].[tables] T ON T.[object_id] = I.[object_id]
				INNER JOIN [sys].[schemas] S ON S.[schema_id] = T.[schema_id]
				INNER JOIN [sys].[index_columns] IC ON IC.[object_id] = I.[object_id]
					AND IC.index_id = I.index_id
				INNER JOIN [sys].[columns] C ON C.[object_id] = IC.[object_id]
					AND C.column_id = IC.column_id
			WHERE
				I.[type] > 0
				AND I.is_primary_key = 0
				AND I.is_unique_constraint = 0
				AND NOT EXISTS

					(
						SELECT
							*
						FROM
							[sys].[index_columns] XIC
							INNER JOIN [sys].[foreign_key_columns] FKC ON FKC.parent_object_id = XIC.[object_id]
								AND FKC.parent_column_id = XIC.column_id
						WHERE
							XIC.[object_id] = I.[object_id]
							AND XIC.index_id = I.index_id
					)

				AND NOT EXISTS

					(
						SELECT
							*
						FROM
							[master].[sys].[dm_db_index_usage_stats] IUS
						WHERE
							IUS.database_id = DB_ID (DB_NAME ())
							AND IUS.[object_id] = I.[object_id]
							AND IUS.index_id = I.index_id
					)
		 '


	EXECUTE (@vSQL_String)


	SET @vDatabase_Name_Loop =

		(
			SELECT TOP (1)
				DBNT.database_name
			FROM
				@vDatabase_Name_Table DBNT
			WHERE
				DBNT.database_name > @vDatabase_Name_Loop
			ORDER BY
				DBNT.database_name
		)

END


IF NOT EXISTS (SELECT * FROM dbo.#temp_sssr_unused_indexes)
BEGIN

	GOTO Skip_Unused_Indexes

END


IF @v_Output_Mode = 'E'
BEGIN

	SET @vXML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.database_name AS 'td'
					,'',X.[schema_name] AS 'td'
					,'',X.[object_name] AS 'td'
					,'',X.column_name AS 'td'
					,'',X.index_name AS 'td'
					,'',X.[disabled] AS 'td'
					,'',X.hypothetical AS 'td'
					,'',X.drop_index_statement AS 'td'
				FROM
					dbo.#temp_sssr_unused_indexes X
				ORDER BY
					 X.database_name
					,X.[schema_name]
					,X.[object_name]
					,X.column_name
					,X.index_name
				FOR
					XML PATH ('tr')
			)
		)


	SET @vBody = 

		N'
			<br><br>
			<h3><center>Unused Indexes</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Schema Name</th>
						<th>Object Name</th>
						<th>Column Name</th>
						<th>Index Name</th>
						<th>Disabled</th>
						<th>Hypothetical</th>
						<th>Drop Index Statement</th>
					</tr>
		 '


	SET @vBody = @vBody+@vXML_String+

		N'
				</table>
			</center>
		 '
SET @hold = '' 

DECLARE DDLPartCursor CURSOR
FOR
SELECT	* 
From	dbaadmin.dbo.dbaudf_SplitSize(@vBody,7000)

OPEN DDLPartCursor
FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @ComBlkPart = REPLACE(@Hold,CHAR(13)+CHAR(10),'') + @ComBlkPart
		SET @Pointer = CHARINDEX(CHAR(13),REVERSE(@ComBlkPart))
		SET @Hold = RIGHT(@ComBlkPart,@Pointer)
		SET @ComBlkPart = LEFT(@ComBlkPart,LEN(@ComBlkPart)-@Pointer)
		PRINT @ComBlkPart
	END
	FETCH NEXT FROM DDLPartCursor INTO @PartNumber,@ComBlkPart
END
CLOSE DDLPartCursor
DEALLOCATE DDLPartCursor
	
END
ELSE BEGIN

	SELECT
		X.*
	FROM
		dbo.#temp_sssr_unused_indexes X
	ORDER BY
		 X.database_name
		,X.[schema_name]
		,X.[object_name]
		,X.column_name
		,X.index_name

END


Skip_Unused_Indexes:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_unused_indexes', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_unused_indexes

END


-----------------------------------------------------------------------------------------------------------------------------
--	Variable Update: Finalize @vBody Variable Contents
-----------------------------------------------------------------------------------------------------------------------------

IF @v_Output_Mode = 'E'
BEGIN

	SET @vBody =

		N'
			<html>
				<body>
				<style type="text/css">
					table {font-size:8.0pt;font-family:Arial;text-align:left;}
					tr {text-align:left;}
				</style>
		 '

		+@vBody+

		N'
				</body>
			</html>
		 '


	SET @vBody = REPLACE (@vBody, N'<td>right_align', N'<td align="right">')

END


-----------------------------------------------------------------------------------------------------------------------------
--	sp_send_dbmail: Deliver Results / Notification To End User(s)
-----------------------------------------------------------------------------------------------------------------------------

--IF @v_Output_Mode = 'E'
--BEGIN

--	EXECUTE [msdb].[dbo].[sp_send_dbmail]

--		 @recipients = @vRecipients
--		,@copy_recipients = @vCopy_Recipients
--		,@subject = @vSubject
--		,@body = @vBody
--		,@body_format = 'HTML'

--END





GO