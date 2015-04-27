
IF OBJECT_ID('dbaudf_SplitByLines') IS NOT NULL
DROP FUNCTION [dbo].[dbaudf_SplitByLines]
GO
CREATE function [dbo].[dbaudf_SplitByLines] ( @String VARCHAR(max))
returns @SplittedValues TABLE
(
    OccurenceId INT IDENTITY(1,1),
    SplitValue VARCHAR(max)
)
as
BEGIN

	DECLARE	@SplitLength	INT
		,@SplitValue	VarChar(max)
		,@CRLF		CHAR(2)

	SELECT	@CRLF		= CHAR(13)+CHAR(10)
		,@String	= @String + @CRLF

	WHILE LEN(@String) > 0

	BEGIN
		SELECT		@SplitLength	= COALESCE(NULLIF(CHARINDEX(@CRLF,@String),0)-1,LEN(@String))
				,@SplitValue	= LEFT(@String,@SplitLength)
				,@String	= STUFF(@String,1,@SplitLength+2,'')

		INSERT INTO	@SplittedValues([SplitValue])
		SELECT		@SplitValue
	END

	RETURN

END

GO
DECLARE @TextLine VarChar(MAX)
DECLARE @Text VarChar(max)
DECLARE TextCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		st.text
from		sys.dm_exec_cached_plans cp
cross apply	sys.dm_exec_sql_text(cp.plan_handle) st
--cross apply	sys.dm_exec_query_plan(cp.plan_handle) qp 
WHERE st.Text Like '%DMV_exec_sessions%'
OPEN TextCursor;
FETCH TextCursor INTO @Text;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		RAISERROR ('---------****************************************************************************************-----------',-1,-1) WITH NOWAIT

		DECLARE PrintLargeResults CURSOR
		FOR
		-- SELECT QUERY FOR CURSOR
		SELECT		SplitValue
		FROM		dbaadmin.dbo.dbaudf_SplitByLines(@Text)
		ORDER BY	OccurenceID 

		OPEN PrintLargeResults;
		FETCH PrintLargeResults INTO @TextLine;
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				---------------------------- 
				---------------------------- CURSOR LOOP TOP
	
				RAISERROR (@TextLine,-1,-1) WITH NOWAIT

				---------------------------- CURSOR LOOP BOTTOM
				----------------------------
			END
 			FETCH NEXT FROM PrintLargeResults INTO @TextLine;
		END
		CLOSE PrintLargeResults;
		DEALLOCATE PrintLargeResults;


		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM TextCursor INTO @Text;
END
CLOSE TextCursor;
DEALLOCATE TextCursor;

