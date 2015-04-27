
--CREATE TABLE #IndexHealth_Results(
--	[Finding] [nvarchar](4000) NOT NULL,
--	[URL] [varchar](200) NOT NULL,
--	[Details: schema.table.index(indexid)] [nvarchar](4000) NOT NULL,
--	[Definition: [Property]] ColumnName {datatype maxbytes}] [nvarchar](max) NOT NULL,
--	[Secret Columns] [nvarchar](max) NOT NULL,
--	[Usage] [nvarchar](max) NULL,
--	[Size] [nvarchar](max) NULL,
--	[More Info] [nvarchar](max) NULL,
--	[Create TSQL] [nvarchar](max) NULL
--)


--INSERT INTO #IndexHealth_Results


exec sp_msforEachDB 'IF DB_ID(''?'') > 4 AND ''?'' NOT IN (''dbaadmin'',''dbaperf'',''sqldeploy'',''dbacentral'',''dbaperf_reports'') BEGIN PRINT ''PROCESSING ?'';EXEC dbaperf.dbo.dbasp_Diaper_Check @DatabaseName=''?'',@LogToCentral = 2; END'


SELECT * FROM dbaperf.dbo.IndexHealth_Results




EXEC dbo.dbasp_Diaper_Check @DatabaseName='WCDS', @SchemaName='Subscription', @TableName='SubscriptionBillingInfo';



