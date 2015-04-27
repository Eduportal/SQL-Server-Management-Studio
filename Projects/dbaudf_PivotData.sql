USE dbaadmin
GO


IF OBJECT_ID (N'dbo.dbaudf_PivotData') IS NOT NULL
   DROP FUNCTION dbo.dbaudf_PivotData
GO

CREATE FUNCTION dbo.dbaudf_PivotData(@XML XML)
RETURNS @PivotData TABLE 
			(
			[Rn]		int				NOT NULL
			,[Property]	SYSNAME			NOT NULL
			,[Value]	nvarchar(max)	NULL
			)
AS
BEGIN

		;WITH		XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' AS xsi),RC 
					AS
					(
					SELECT		COUNT(Row.value('.', 'nvarchar(MAX)')) [RowCount]
					FROM		@xml.nodes('Root/Row') AS WTable(Row)
					)
					,c 
					AS
					(
					SELECT		b.value('local-name(.)','nvarchar(max)') ColumnName
								,b.value('.[not(@xsi:nil = "true")]','nvarchar(max)') Value
								,b.value('../Rn[1]','nvarchar(max)') Rn
								,ROW_NUMBER() OVER (PARTITION BY b.value('../Rn[1]','nvarchar(max)') ORDER BY (SELECT 1)) Cell
					FROM		@xml.nodes('//Root/Row/*[local-name(.)!="Rn"]') a(b)
					)
					,Cols 
					AS 
					(
					SELECT		DISTINCT 
								c.ColumnName
								,c.Cell
					FROM		c
					)
		INSERT INTO @PivotData
		SELECT		Rn
					,REPLACE(REPLACE(c.ColumnName,'_x0023_','#'),'_x0020_',' ') AS [Property]
					,Value
		 FROM		c

   RETURN
END
GO

