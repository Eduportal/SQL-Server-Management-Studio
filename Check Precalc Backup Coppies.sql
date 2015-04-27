USE [dbaadmin]
GO

DECLARE @S	VarChar(max)	= '\\SEAPSQLRYL0B\SEAPSQLRYL0B_backup'
DECLARE @D	VarChar(max)	= '\\SEAPSQLRYL0B\POST_CALC'

SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_Integration_DB_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_Integration_DFNTL_*.*'	,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_Feeds_DB_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_Feeds_DFNTL_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_Master_DB_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_Master_DFNTL_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_DB_*.*'			,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GINS_DFNTL_*.*'			,0)

ORDER BY 1

GO

DECLARE @S	VarChar(max)	= '\\SEAPSQLRYL0A\SEAPSQLRYL0A_backup'
DECLARE @D	VarChar(max)	= '\\SEAPSQLRYL0A\POST_CALC'

SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'RM_Integration_DB_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'RM_Integration_DFNTL_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GETTY_Master_DB_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'GETTY_Master_DFNTL_*.*'		,0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'ContractMaintenanceControl_DB_*.*',0)
UNION ALL
SELECT * FROM [dbaadmin].[dbo].[dbaudf_DirectoryCompare] (@S,@D,'ContractMaintenanceControl_DFNTL_*.*',0)

ORDER BY 1
