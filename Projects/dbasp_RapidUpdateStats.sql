USE [dbaadmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbasp_RapidUpdateStats') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_RapidUpdateStats]
GO
CREATE PROCEDURE [dbo].[dbasp_RapidUpdateStats]
		(
		@RowModCounterThreshold			BIGINT		= 1000	-- change if 1K rows have changed
		,@RowModPercentageThreshold		DECIMAL(3,2)	= 0.01	-- change to a 5% threshold
		,@StatsSamplingPercentage		TINYINT		= 0	-- use resample mode
		,@DatabaseName				SYSNAME		= NULL  -- Update specific DB or leave NULL for all
		)
AS
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
/* 
	PARAMETERS:
		@RowModCounterThreshold		if a table gets more than this many rows inserted/updated/deleted, update its statistics
		@RowModPercentageThreshold	if a table gets more than this percentage of rows inserted/updated/deleted, update its statistics
		@StatsSamplingPercentage	set to 0 to update stats in RESAMPLE mode. 
						  set to null to update statistics in their default configuration
						  set to a value between 1 and 100 to update statistics by scanning that percentage of the table's rows
		@DatabaseName			NULL = ALL DATABASES, 
						  NOT NULL = SPECIFIC DATABASE
*/
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

BEGIN
	SET	TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET	NOCOUNT		ON
	SET	ANSI_WARNINGS	ON
	
	DECLARE	@Msg					NVARCHAR(MAX)
		,@Cmd					NVARCHAR(MAX)
		,@QualifiedTableName			NVARCHAR(256)
		,@DoUpdateStats				BIT
		,@Description				NVARCHAR(MAX)
		,@CurrentRowModCounter			BIGINT
	
	DECLARE	@TableList				TABLE
		(
		DatabaseName				SYSNAME		NOT NULL
		,SchemaName				sysname		NOT NULL
		,TableName				sysname 	NOT NULL
		,ObjectID				BIGINT		NOT NULL
		,EstimatedTableRowcount			BIGINT		NOT NULL
		)

	DECLARE	@IndexList				TABLE
		(
		DatabaseName				SYSNAME		NOT NULL
		,SchemaName 				sysname		NOT NULL
		,TableName 				sysname		NOT NULL
		,IndexName 				sysname		NOT NULL
		,IndexPercentageOfTable			DECIMAL(5,4)	NOT NULL
		,IndexRowModCounter			BIGINT		NOT NULL
		)

	DECLARE	@StatsList				TABLE
		(
		DatabaseName				SYSNAME		NOT NULL
		,TableObjectID				BIGINT		NOT NULL
		,QualifiedTableName			NVARCHAR(MAX)	NOT NULL 
		,DoUpdateStats				BIT		NOT NULL
		,Description				NVARCHAR(MAX)	--This should be above the maximum description size
		)


	/*
		First, create the temporary tables we'll be using to query the system DMVs
		Querying them directly in the cursor will not scale in systems with large numbers of tables & indexes
	*/

	-- Get the list of tables & indexed views and their estimated rowcounts
	INSERT INTO	@TableList
	SELECT		s.database_name
			,s.name
			,t.name
			,t.object_id
			,SUM(p.rows)
	FROM		dbaadmin.dbo.vw_AllDB_objects t WITH(NOLOCK)
	INNER JOIN	dbaadmin.dbo.vw_AllDB_schemas s WITH(NOLOCK)
		ON	s.schema_id = t.schema_id
		AND	s.database_name = t.database_name
	INNER JOIN	dbaadmin.dbo.vw_AllDB_partitions p WITH(NOLOCK)
		ON	t.object_id = p.object_id
		AND	t.database_name = P.database_name
	WHERE		p.index_id IN (0,1)		-- look at the base table only
		AND	t.type IN ('U','V')		-- only look at tables and views
		AND	s.database_name = COALESCE(@DatabaseName,s.database_name)
	GROUP BY	s.database_name
			,s.name
			,t.name
			,t.object_id

	/*
	Get the list of indexes for each table or indexed view, the rowmodcounter for each index,
	and the percentage of the table's rows the index covers (to account for filtered indexes)
	 */
	 
	INSERT INTO	@IndexList
	SELECT		s.database_name
			,s.name
			,t.name
			,si.name
			,CAST(SUM(p.rows)*1.0 /(SUM(p.rows)+1)*1.0 AS DECIMAL(5,4))
			,MAX(si.rowmodctr)
	FROM		dbaadmin.dbo.vw_AllDB_sysindexes si WITH(NOLOCK)
	JOIN		dbaadmin.dbo.vw_AllDB_objects t WITH(NOLOCK)
		ON	si.id = t.object_id
		AND	si.database_name = t.database_name
	JOIN		dbaadmin.dbo.vw_AllDB_schemas s
		ON	t.schema_id = s.schema_id
		AND	t.database_name = s.database_name
	JOIN		dbaadmin.dbo.vw_AllDB_partitions p WITH(NOLOCK)
		ON	p.object_id = t.object_id
		AND	p.index_id = si.indid
		AND	p.database_name = t.database_name
	WHERE		si.name IS NOT NULL
		AND	s.database_name = COALESCE(@DatabaseName,s.database_name)
	GROUP BY	s.database_name
			,s.name
			,t.name
			,si.name

	/* 
	This big query has all of the logic.
	It takes index information, table information, and compares
	it to the parameters passed in above to determine whether
	each index is valid for having its stats updated.

	This is a little tricky because indexes are checked
	to see whether they are out of date. However, statistics are updated
	at the table level. 
	*/
	;WITH		SRC
			AS
			(
			SELECT		t.DatabaseName
					,t.ObjectID																TableObjectID				
					,N'['+t.SchemaName+N'].['+t.TableName+N']'												QualifiedTableName			
					,CASE WHEN i.IndexRowModCounter > @RowModCounterThreshold THEN 1 ELSE 0 END								IsRowModCounterAboveThreshold		
					,CASE WHEN i.IndexRowModCounter / (t.EstimatedTableRowcount * i.IndexPercentageOfTable) > @RowModPercentageThreshold THEN 1 ELSE 0 END	IsPercentageChangedAboveThreshold	
					,i.IndexRowModCounter / (t.EstimatedTableRowcount * i.IndexPercentageOfTable)								AdjustedPercentageChanged		
					,i.IndexRowModCounter
					,t.EstimatedTableRowcount
					,i.IndexName
					,i.IndexPercentageOfTable
			FROM		@TableList t
			INNER JOIN	@IndexList i
				ON	t.SchemaName			= i.SchemaName
				AND	t.TableName			= i.TableName
				AND	t.DatabaseName			= i.DatabaseName
			WHERE		t.EstimatedTableRowcount	> 0
				AND	i.IndexPercentageOfTable	> 0
			)
	INSERT INTO	@StatsList
	SELECT		src.DatabaseName
			,src.TableObjectID
			,src.QualifiedTableName
			,CASE WHEN src.IsRowModCounterAboveThreshold=1 OR src.IsPercentageChangedAboveThreshold=1 THEN 1 ELSE 0 END
			,'Index ['+src.IndexName+N']: ' 
				+	CASE 
					WHEN src.IsRowModCounterAboveThreshold=1 
					THEN 'Rowmodcounter (' + CONVERT(NVARCHAR(50),src.IndexRowModCounter) +') is greater than the threshold (' +CONVERT(NVARCHAR,@RowModCounterThreshold)+N') '
					ELSE N'' 
					END
				+	CASE 
					WHEN src.IndexRowModCounter / (src.EstimatedTableRowcount * src.IndexPercentageOfTable) > @RowModPercentageThreshold
					THEN N'Percentage changed (' +CONVERT(NVARCHAR(50),CONVERT(FLOAT,src.AdjustedPercentageChanged*100.0)) +N'%) is above threshold (' +CONVERT(NVARCHAR(50),CONVERT(FLOAT,@RowModPercentageThreshold*100.0)) +N'%) '
					ELSE N'' 
					END
				+	CASE 
					WHEN src.IsRowModCounterAboveThreshold=0 AND src.IsPercentageChangedAboveThreshold=0
					THEN 'Neither rowmodcounter or percentage changed is above threshold for index '+src.IndexName
					ELSE N'' 
					END
				+N' '
	FROM		SRC	


	/* Use the cursor to get information at a table level
	This includes aggregating the descriptions up from the various indexes
	to the table
	*/
	DECLARE	 Csr CURSOR
	LOCAL READ_ONLY 
	FOR 
	SELECT		s.DatabaseName
			,s.QualifiedTableName
			,MAX(CASE WHEN s.DoUpdateStats=1 THEN 1 ELSE 0 END) AS DoUpdateStats
			,(
			  SELECT	+N', '+s2.Description
			  FROM		@StatsList s2
			  WHERE		s2.TableObjectID = s.TableObjectID
			  FOR XML PATH ('')
			  ) AS DescriptionList
	FROM		@StatsList s
	GROUP BY	s.DatabaseName
			,s.QualifiedTableName
			,s.TableObjectID
	ORDER BY	s.DatabaseName
			,s.QualifiedTableName
			,s.TableObjectID

	OPEN Csr
	FETCH NEXT FROM Csr INTO @DatabaseName,@QualifiedTableName,@DoUpdateStats,@Description
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF (@@FETCH_STATUS <> -2)
		BEGIN
			-- print the message regardless of whether we update stats
			SET @Msg	= CASE @DoUpdateStats WHEN 1 THEN N'--Updating stats on ' ELSE N'--Do not update stats on ' END
					+ @QualifiedTableName
					+ ' because '
					+ @Description
			
			PRINT @Msg
			-- if the table is valid to have its stats updated, update the statistics
			IF @DoUpdateStats=1
			BEGIN
				SET @cmd	= 'USE ' + @DatabaseName + '; '
						+ 'update statistics '
						+ @QualifiedTableName
						+ CASE	WHEN @StatsSamplingPercentage = 0 THEN ' with resample'
							WHEN @StatsSamplingPercentage IS NOT NULL THEN ' with sample ' + CONVERT(NVARCHAR,@StatsSamplingPercentage) + ' percent'
							ELSE N'' 
							END
					
				PRINT	(@cmd) --print the command to execute
				EXEC	(@Cmd) --execute the command
			END
		END
		FETCH NEXT FROM Csr INTO @DatabaseName,@QualifiedTableName,@DoUpdateStats,@Description
	END
	CLOSE Csr
	DEALLOCATE Csr
END
GO