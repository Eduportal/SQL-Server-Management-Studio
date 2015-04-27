
/*
Run the following script on master database to catalog this stored procedure. 
The SP has 2 input paramaters '@dbname' and @option.

@dbname - Name of the database for which you want to update stats
@option - 	Information - "I" OR Action "A"

Exec sp_dba_ShowMe_TableStats '@dbname','@action'

Example 1: EXEC sp_dba_ShowMe_TableStats 'pubs','I'
Results:
Table Name      	Index Name      		Rows Modified
newTitles		newTitles			18
EMPSTAT_DIM	EMPSTAT_DIM_idx1	1704364
PJR_Sales		PJR_Sales			1704364
PJR_Sales		PJR_Sales			704364

Exmaple 2: Executing the proc with "A" will fetch the below results

EXEC sp_dba_ShowMe_TableStats 'pubs','A'

Results
---------------------------------
UPDATE STATISTICS EMPSTAT_DIM GO
UPDATE STATISTICS newTitles GO
UPDATE STATISTICS PJR_Sales GO


*/

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE sp_dba_ShowMe_TableStats @dbname sysname=NULL, @option char (1) = NULL 
AS
--- Author: Sravan Kasarla
--- Created: 10/01/2003
BEGIN
Declare @what char(1),
@qry varchar(2000)
set @what = @option


IF @what = 'I'
Begin
	set @qry = ' Use ' + @dbName +' SELECT substring(o.name,1,50) AS [table name], substring(o.name,1,50) AS [Index Name], i.rowmodctr AS [Rows Modified] 
	FROM SYSOBJECTS o JOIN SYSINDEXES i 
	ON o.id = i.id 
	WHERE i.rowmodctr > 0  and o.xtype = ''U''
	ORDER BY i.rowmodctr DESC'
	exec (@qry)
End

ELSE IF @what = 'A'
Begin
	Print space(10)+' Run the Update Statistics on the following Tables'
	SET @qry = 'SET NOCOUNT ON'+char(13)+ 'Use ' +  @dbName + ' SELECT Distinct ''UPDATE STATISTICS''+SPACE(1)+O.NAME+CHAR(13)+''GO''  FROM SYSOBJECTS O 
	JOIN SYSINDEXES i ON o.id = i.id 
	WHERE i.rowmodctr > 0 and o.xtype = ''U''
	---ORDER BY O.NAME'
	exec (@qry)
End

ELSE
	Begin	
	Print space(10)+'Please pass in the right parameters : DBName and option "I" for Information or "A" Action"'
	PRINT '-------------------------------------------------------------------------------------------------------------------------------------'
	set @qry = ' Use ' + @dbName +' SELECT substring(o.name,1,50) AS [table name], substring(o.name,1,50) AS [Index Name], i.rowmodctr AS [Rows Modified] 
	FROM SYSOBJECTS o JOIN SYSINDEXES i 
	ON o.id = i.id 
	WHERE i.rowmodctr > 0  and o.xtype = ''U''
	ORDER BY i.rowmodctr DESC'
	exec (@qry)
	End
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
