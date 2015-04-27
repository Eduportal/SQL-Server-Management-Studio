USE DBAADMIN
GO
SET NOCOUNT ON
DECLARE	@Data Table (ServerName sysname,DBName sysname,EnvName sysname)

--SELECT DISTINCT KnownCondition FROM [dbaadmin].[dbo].[Filescan_History] ORDER BY 1
--SELECT Top 1 [FixData] FROM [dbaadmin].[dbo].[Filescan_History] WHERE KnownCondition = 'Backup-NoTranLogExists'
--production
  
Insert Into @Data									
SELECT		DISTINCT
		[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
		,[dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Database')
		,COALESCE(SQLEnv,'Production') SQLEnv
FROM		[dbaadmin].[dbo].[Filescan_History] T1   WITH(NOLOCK)
LEFT JOIN	[dbaadmin].[dbo].[DBA_ServerInfo] T2
	ON T2.SQLName = [dbaadmin].[dbo].[ReturnPairValue] ([FixData],',','=','Server')
WHERE		EventDateTime >= GetDate()-1
	AND	KnownCondition = 'Backup-NoTranLogCurrent'
Order By	1,2	


------------------------------------------------------------------
------------------------------------------------------------------
-- NON PRODUCTION SOLUTION
------------------------------------------------------------------
------------------------------------------------------------------
DECLARE @ServerName sysname
DECLARE	@TSQL VarChar(8000)

DECLARE ServerCursor CURSOR
FOR
SELECT		DISTINCT
		ServerName
FROM		@Data
WHERE		EnvName != 'Production'

OPEN ServerCursor
FETCH NEXT FROM ServerCursor INTO @ServerName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT ':CONNECT ' + @ServerName
		PRINT ''
		SET	@TSQL = ''
		SELECT	@TSQL = @TSQL + 'ALTER DATABASE ['+[DBName]+'] SET RECOVERY SIMPLE WITH NO_WAIT'+ CHAR(13)+CHAR(10)+'GO'+ CHAR(13)+CHAR(10)
		FROM	@Data
		WHERE	[ServerName] = @ServerName
		PRINT 	(@TSQL)
		PRINT ''
	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
END
CLOSE ServerCursor
DEALLOCATE ServerCursor


------------------------------------------------------------------
------------------------------------------------------------------
-- PRODUCTION SOLUTION
------------------------------------------------------------------
------------------------------------------------------------------


DECLARE ServerCursor CURSOR
FOR
SELECT		DISTINCT
		ServerName
FROM		@Data
WHERE		EnvName = 'Production'

OPEN ServerCursor
FETCH NEXT FROM ServerCursor INTO @ServerName
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT ':CONNECT ' + @ServerName
		PRINT ''
		PRINT 'DECLARE @PlanID uniqueidentifier'
		PRINT 'SELECT @PlanID=[plan_id] FROM [msdb].[dbo].[sysdbmaintplans] WHERE [plan_name] = ''Mplan_user_tranlog'''
		SET	@TSQL = ''
		SELECT	@TSQL = @TSQL + 'exec msdb.dbo.sp_add_maintenance_plan_db @PlanID, '''+DBName+'''' +CHAR(13)+CHAR(10)
		FROM	@Data
		WHERE	[ServerName] = @ServerName
		PRINT 	(@TSQL)			
		PRINT 'GO'
		PRINT ''

	END
	FETCH NEXT FROM ServerCursor INTO @ServerName
END
CLOSE ServerCursor
DEALLOCATE ServerCursor
GO




    




