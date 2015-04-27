--SELECT      so.name, so.[type], SCHEMA_NAME(so.schema_id) AS [Schema],
--            asmbly.name, asmbly.permission_set_desc, am.assembly_class, 
--            am.assembly_method
--FROM        sys.assembly_modules am
--INNER JOIN  sys.assemblies asmbly
--        ON  asmbly.assembly_id = am.assembly_id
--        AND asmbly.name NOT LIKE 'Microsoft%'
--INNER JOIN  sys.objects so
--        ON  so.object_id = am.object_id
--UNION
--SELECT      at.name, 'TYPE' AS [type], SCHEMA_NAME(at.schema_id) AS [Schema], 
--            asmbly.name, asmbly.permission_set_desc, at.assembly_class,
--            NULL AS [assembly_method]
--FROM        sys.assembly_types at
--INNER JOIN  sys.assemblies asmbly
--        ON  asmbly.assembly_id = at.assembly_id
--        AND asmbly.name NOT LIKE 'Microsoft%'
--ORDER BY    4, 2, 1


--GO



--select DISTINCT OBJECT_NAME(id) from syscomments where text like '%sp_OA%'

--GO

--;WITH		AssemblyInfo
--		AS
--		(
--		SELECT      so.name [object_name], so.[type], SCHEMA_NAME(so.schema_id) AS [Schema],
--			    asmbly.name [assembly_name], asmbly.permission_set_desc, am.assembly_class, 
--			    am.assembly_method
--		FROM        sys.assembly_modules am
--		INNER JOIN  sys.assemblies asmbly
--			ON  asmbly.assembly_id = am.assembly_id
--			AND asmbly.name NOT LIKE 'Microsoft%'
--		INNER JOIN  sys.objects so
--			ON  so.object_id = am.object_id
--		UNION
--		SELECT      at.name, 'TYPE' AS [type], SCHEMA_NAME(at.schema_id) AS [Schema], 
--			    asmbly.name, asmbly.permission_set_desc, at.assembly_class,
--			    NULL AS [assembly_method]
--		FROM        sys.assembly_types at
--		INNER JOIN  sys.assemblies asmbly
--			ON  asmbly.assembly_id = at.assembly_id
--			AND asmbly.name NOT LIKE 'Microsoft%'
--		)
				
--SELECT		DISTINCT 
--		OBJECT_NAME(id)
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		syscomments T1
--JOIN		AssemblyInfo T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--ORDER BY	1




--select DISTINCT OBJECT_NAME(id)
--FROM syscomments

--where text like '%dbaudf_Concatenate%'
--   or text like '%dbaudf_ConcatenateUnique%'
--   or text like '%dbaudf_CPUInfo%'
--   or text like '%dbaudf_FileAccess_Write%'
--   or text like '%dbaudf_Filter_Alpha%'
--   or text like '%dbaudf_Filter_AlphaNumeric%'
--   or text like '%dbaudf_Filter_Numeric%'
--   or text like '%dbaudf_Filter_ValidFileName%'
--   or text like '%dbaudf_FormatString%'
--   or text like '%dbaudf_GetEV%'
--   or text like '%dbaudf_GetFileProperty%'
--   or text like '%dbaudf_GetSharePath%'
--   or text like '%dbaudf_SetEV%'
--   or text like '%dbaudf_DirectoryList%'
--   or text like '%dbaudf_FileAccess_Read%'
--   or text like '%dbaudf_GetAllEVs%'
--   or text like '%dbaudf_ListDrives%'
--   or text like '%dbaudf_StringToTable%'
--   or text like '%dbasp_DiskSpace%'
--   or text like '%dbasp_EventLogWrite%'
--   or text like '%dbasp_Export_CsvFile%'
--   or text like '%dbasp_Export_TabFile%'
--   or text like '%dbasp_FileAccess_Read_Blob%'
--   or text like '%dbasp_FileAccess_Read_Table%'
--   or text like '%dbasp_FileAccess_Write%'
--   or text like '%dbasp_FileCompare%'
--   or text like '%dbasp_PivotQuery%'
   
--  GO
   

--exec sp_msForEachDB
--';with		changedobjects
--		AS
--		(
--		SELECT ''dbaudf_Concatenate'' [object_name] UNION ALL
--		SELECT ''dbaudf_ConcatenateUnique'' UNION ALL
--		SELECT ''dbaudf_CPUInfo'' UNION ALL
--		SELECT ''dbaudf_FileAccess_Write'' UNION ALL
--		SELECT ''dbaudf_Filter_Alpha'' UNION ALL
--		SELECT ''dbaudf_Filter_AlphaNumeric'' UNION ALL
--		SELECT ''dbaudf_Filter_Numeric'' UNION ALL
--		SELECT ''dbaudf_Filter_ValidFileName'' UNION ALL
--		SELECT ''dbaudf_FormatString'' UNION ALL
--		SELECT ''dbaudf_GetEV'' UNION ALL
--		SELECT ''dbaudf_GetFileProperty'' UNION ALL
--		SELECT ''dbaudf_GetSharePath'' UNION ALL
--		SELECT ''dbaudf_SetEV'' UNION ALL
--		SELECT ''dbaudf_DirectoryList'' UNION ALL
--		SELECT ''dbaudf_FileAccess_Read'' UNION ALL
--		SELECT ''dbaudf_GetAllEVs'' UNION ALL
--		SELECT ''dbaudf_ListDrives'' UNION ALL
--		SELECT ''dbaudf_StringToTable'' UNION ALL
--		SELECT ''dbasp_DiskSpace'' UNION ALL
--		SELECT ''dbasp_EventLogWrite'' UNION ALL
--		SELECT ''dbasp_Export_CsvFile'' UNION ALL
--		SELECT ''dbasp_Export_TabFile'' UNION ALL
--		SELECT ''dbasp_FileAccess_Read_Blob'' UNION ALL
--		SELECT ''dbasp_FileAccess_Read_Table'' UNION ALL
--		SELECT ''dbasp_FileAccess_Write'' UNION ALL
--		SELECT ''dbasp_FileCompare'' UNION ALL
--		SELECT ''dpudf_CheckFileSize'' UNION ALL
--		SELECT ''dpudf_CheckFileType'' UNION ALL
		
--		SELECT ''dbasp_Self_Register_Report'' UNION ALL
--		SELECT ''dbaudf_Dir'' UNION ALL
--		SELECT ''dbaudf_CheckFileStatus'' UNION ALL
--		SELECT ''dbaudf_Files'' UNION ALL
--		SELECT ''dbasp_SpawnAsyncTSQLThread'' UNION ALL
		
--		SELECT ''dbasp_PivotQuery''
--		)   
--SELECT		DISTINCT 
--		''?'' [DBName]
--		,OBJECT_NAME(id)
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		?..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like ''%''+T2.object_name+''%''
--GROUP BY	id	
--ORDER BY	2'
/*

EXEC sp_MsForEachDB 'PRINT ''      
SELECT		''''?'''' [DBName]
		,OBJECT_NAME(id,DB_ID(''''?''''))
		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
FROM		?..syscomments T1
JOIN		changedobjects T2
	ON	T1.text like ''''%''''+T2.object_name+''''%''''
GROUP BY	id	
UNION
'''
*/

GO
/*
-- SYS.ASSEMBLIES
-- Name, Assembly ID, security and “is_visible” flag
SELECT * FROM sys.assemblies
 
-- SYS.ASSEMBLY_FILES
-- Assembly ID, name of each file & assembly contents
SELECT * FROM sys.assembly_files
 
-- SYS.ASSEMBLY_MODULES
-- Sql ObjectID, Assembly ID, name & assembly method
SELECT * FROM sys.assembly_modules
 
-- SYS.ASSEMBLY_REFERENCES
-- Links between assemblies on Assembly ID
SELECT * FROM sys.assembly_references
 
-- SYS.MODULE_ASSEMBLY_USAGES
-- Partial duplicate of SYS.ASSEMBLY_MODULES
-- Links SQL Object ID to an Assembly ID
SELECT * FROM sys.module_assembly_usages
*/

/*

-- Loaded Assemblies (run in each database)
SELECT sa.[name]
      , ad.[appdomain_name]
      , clr.[load_time]
FROM sys.dm_clr_loaded_assemblies AS clr
      INNER JOIN sys.assemblies AS sa
            ON clr.assembly_id = sa.assembly_id
      INNER JOIN sys.dm_clr_appdomains AS ad
            ON clr.appdomain_address = ad.appdomain_address
            
-- SQL CLR Memory Usage
SELECT mo.[type]
      , sum(mo.pages_allocated_count * mo.page_size_in_bytes/1024) 
            AS N'Current KB'
      , sum(mo.max_pages_allocated_count * mo.page_size_in_bytes/1024) 
            AS N'Max KB'
FROM sys.dm_os_memory_objects AS mo
WHERE mo.[type] LIKE '%clr%'
GROUP BY mo.[type]
ORDER BY mo.[type]
 
-- SQL CLR Wait Statistics
SELECT ws.* 
FROM sys.dm_os_wait_stats AS ws
WHERE ws.wait_type LIKE '%clr%'
 
-- Requests that are currently in SQL CLR
SELECT session_id, request_id, start_time, status, command, database_id,
wait_type, wait_time, last_wait_type, wait_resource, cpu_time,
total_elapsed_time, nest_level, executing_managed_code
FROM sys.dm_exec_requests
WHERE executing_managed_code = 1
 
-- Query performance and time spent in SQL CLR.
SELECT 
(SELECT text FROM sys.dm_exec_sql_text(qs.sql_handle)) AS query_text, qs.*
FROM sys.dm_exec_query_stats AS qs
WHERE qs.total_clr_time > 0 
ORDER BY qs.total_clr_time desc
 
-- Obtaining CLR Execution performance counter values.
SELECT object_name, counter_name, cntr_value, cntr_type
FROM sys.dm_os_performance_counters
WHERE counter_name LIKE '%CLR%'            
            

-- Will return the version if the .NET Framework has been used
SELECT p.[value]
FROM sys.dm_clr_properties AS p
WHERE p.[name] = N'version'
 
-- Will return the version even if the .NET Framework is unused
-- Test the version of the Microsoft .NET Runtime Execution Engine
SELECT lm.product_version
FROM sys.dm_os_loaded_modules AS lm
WHERE lm.[name] LIKE N'%\MSCOREE.DLL'


*/


/*

-- LIST ALL CLR OBJECTS

SELECT sp.type_desc
      , schema_name(sp.schema_id) + '.' + sp.[name] AS [Name]
      , sp.create_date
      , sp.modify_date
      , sa.permission_set_desc AS [Access]
      , sp.is_auto_executed
FROM sys.procedures AS sp
      INNER JOIN sys.module_assembly_usages AS sau
            ON sp.object_id = sau.object_id
      INNER JOIN sys.assemblies AS sa
            ON sau.assembly_id = sa.assembly_id



UNION

SELECT so.type_desc
      , schema_name(so.schema_id) + N'.' + so.[name] AS [Name]
      , so.create_date
      , so.modify_date
      , sa.permission_set_desc AS [Access]
      , NULL
FROM sys.objects AS so
      INNER JOIN sys.module_assembly_usages AS sau
            ON so.object_id = sau.object_id
      INNER JOIN sys.assemblies AS sa
            ON sau.assembly_id = sa.assembly_id

ORDER BY 1,2


*/


--sp_help 'dbo.dbaudf_ListDrives'

--select * From syscolumns where id = OBJECT_ID('dbo.dbaudf_ListDrives')



--DECLARE @Text nVarChar(max)
--SET	@Text = 
--'select	* 
--	,dbo.dbaudf_GetFileProperty(FullPathName,''File'',''format'')
--From	dbo.dbaudf_DirectoryList(''C:\windows\system32'',null)
--WHERE	IsFolder = 0'



--SELECT REPLACE(REPLACE(@Text,char(9),'&lt;tab&gt;'),CHAR(13)+char(10),'&lt;br&gt;')



--;with		changedobjects
--		AS
--		(
--		SELECT 'dbaudf_Concatenate' [object_name] UNION ALL
--		SELECT 'dbaudf_ConcatenateUnique' UNION ALL
--		SELECT 'dbaudf_CPUInfo' UNION ALL
--		SELECT 'dbaudf_FileAccess_Write' UNION ALL
--		SELECT 'dbaudf_Filter_Alpha' UNION ALL
--		SELECT 'dbaudf_Filter_AlphaNumeric' UNION ALL
--		SELECT 'dbaudf_Filter_Numeric' UNION ALL
--		SELECT 'dbaudf_Filter_ValidFileName' UNION ALL
--		SELECT 'dbaudf_FormatString' UNION ALL
--		SELECT 'dbaudf_GetEV' UNION ALL
--		SELECT 'dbaudf_GetFileProperty' UNION ALL
--		SELECT 'dbaudf_GetSharePath' UNION ALL
--		SELECT 'dbaudf_SetEV' UNION ALL
--		SELECT 'dbaudf_DirectoryList' UNION ALL
--		SELECT 'dbaudf_FileAccess_Read' UNION ALL
--		SELECT 'dbaudf_GetAllEVs' UNION ALL
--		SELECT 'dbaudf_ListDrives' UNION ALL
--		SELECT 'dbaudf_StringToTable' UNION ALL
--		SELECT 'dbasp_DiskSpace' UNION ALL
--		SELECT 'dbasp_EventLogWrite' UNION ALL
--		SELECT 'dbasp_Export_CsvFile' UNION ALL
--		SELECT 'dbasp_Export_TabFile' UNION ALL
--		SELECT 'dbasp_FileAccess_Read_Blob' UNION ALL
--		SELECT 'dbasp_FileAccess_Read_Table' UNION ALL
--		SELECT 'dbasp_FileAccess_Write' UNION ALL
--		SELECT 'dbasp_FileCompare' UNION ALL
--		SELECT 'dpudf_CheckFileSize' UNION ALL
--		SELECT 'dpudf_CheckFileType' UNION ALL
		
--		SELECT 'dbasp_Self_Register_Report' [object_name] UNION ALL
--		SELECT 'dbaudf_Dir' UNION ALL
--		SELECT 'dbaudf_CheckFileStatus' UNION ALL
--		SELECT 'dbaudf_Files' UNION ALL
--		SELECT 'dbasp_SpawnAsyncTSQLThread' UNION ALL
		
--		SELECT 'dbasp_PivotQuery'
--		) 
      
      
--SELECT		'master' [DBName]
--		,OBJECT_NAME(id,DB_ID('master'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		master..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'tempdb' [DBName]
--		,OBJECT_NAME(id,DB_ID('tempdb'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		tempdb..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'model' [DBName]
--		,OBJECT_NAME(id,DB_ID('model'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		model..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'msdb' [DBName]
--		,OBJECT_NAME(id,DB_ID('msdb'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		msdb..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'dbaadmin' [DBName]
--		,OBJECT_NAME(id,DB_ID('dbaadmin'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		dbaadmin..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'deplinfo' [DBName]
--		,OBJECT_NAME(id,DB_ID('deplinfo'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		deplinfo..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'dbaperf' [DBName]
--		,OBJECT_NAME(id,DB_ID('dbaperf'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		dbaperf..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'ProductCatalogAssetList' [DBName]
--		,OBJECT_NAME(id,DB_ID('ProductCatalogAssetList'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		ProductCatalogAssetList..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	
--UNION
      
--SELECT		'SQLdeploy' [DBName]
--		,OBJECT_NAME(id,DB_ID('SQLdeploy'))
--		,dbaadmin.dbo.dbaudf_ConcatenateUnique(T2.object_name)
--FROM		SQLdeploy..syscomments T1
--JOIN		changedobjects T2
--	ON	T1.text like '%'+T2.object_name+'%'
--GROUP BY	id	


