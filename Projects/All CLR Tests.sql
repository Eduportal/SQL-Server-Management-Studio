USE [dbaadmin]
GO
SET NOCOUNT ON
GO

PRINT
'USE [dbaadmin]
GO

IF OBJECT_ID(''tempdb..#CLRMemory'') IS NOT NULL DROP TABLE #CLRMemory
GO
CREATE TABLE #CLRMemory
	(
	Address_Blocks			INT
	,single_pages_kb		INT
	,multi_pages_kb			INT
	,virtual_memory_committed_kb	INT
	,Total_SQLCLR_Memory		INT
	,SampledWhen			VarChar(150)
	)
GO
INSERT INTO #CLRMemory
select count(*) as Address_Blocks 
, sum(single_pages_kb) as single_pages_kb 
, sum(multi_pages_kb) as multi_pages_kb 
, sum(virtual_memory_committed_kb) as virtual_memory_committed_kb 
, sum(single_pages_kb + multi_pages_kb + virtual_memory_committed_kb) as Total_SQLCLR_Memory
, ''START'' 
from sys.dm_os_memory_clerks 
where [type] = ''MEMORYCLERK_SQLCLR''	
GO

'


;WITH		CLRTests([object_name],[object_type],[TestCode])
		AS
		(
		SELECT 'dbaudf_Concatenate'		,'AF','DECLARE @Result VARCHAR(max);SELECT @Result = dbaadmin.dbo.dbaudf_Concatenate(DBName) From dbaadmin.dbo.DBA_DBInfo' UNION ALL
		SELECT 'dbaudf_ConcatenateUnique'	,'AF','DECLARE @Result VARCHAR(max);SELECT @Result = dbaadmin.dbo.dbaudf_ConcatenateUnique(DBName) From dbaadmin.dbo.DBA_DBInfo' UNION ALL
		SELECT 'dbaudf_Intercept'		,'AF','DECLARE @Result INT;with testdata as (select ''1''+CHAR(0)+''10'' as value union select ''2''+CHAR(0)+''12'' union select ''3''+CHAR(0)+''14'' union select ''4''+CHAR(0)+''16'' union select ''5''+CHAR(0)+''18'') SELECT @Result = dbaadmin.dbo.dbaudf_Intercept(value) From testdata' UNION ALL
		SELECT 'dbaudf_RSquared'		,'AF','DECLARE @Result INT;with testdata as (select ''1''+CHAR(0)+''10'' as value union select ''2''+CHAR(0)+''12'' union select ''3''+CHAR(0)+''14'' union select ''4''+CHAR(0)+''16'' union select ''5''+CHAR(0)+''18'') SELECT @Result = dbaadmin.dbo.dbaudf_RSquared(value) From testdata' UNION ALL
		SELECT 'dbaudf_Slope'			,'AF','DECLARE @Result INT;with testdata as (select ''1''+CHAR(0)+''10'' as value union select ''2''+CHAR(0)+''12'' union select ''3''+CHAR(0)+''14'' union select ''4''+CHAR(0)+''16'' union select ''5''+CHAR(0)+''18'') SELECT @Result = dbaadmin.dbo.dbaudf_Slope(value) From testdata' UNION ALL
		SELECT 'dbaudf_CPUInfo'			,'FS','DECLARE @Result INT;SELECT @Result =  [dbaadmin].[dbo].[dbaudf_CPUInfo](''Cores'') + dbaadmin.dbo.dbaudf_CPUInfo(''Processors'') + dbaadmin.dbo.dbaudf_CPUInfo(''Sockets'');' UNION ALL
		SELECT 'dbaudf_FileAccess_Write'	,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_FileAccess_Write] (''abc123'',''c:\test.txt'',0,0)' UNION ALL
		SELECT 'dbaudf_Filter_Alpha'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_Filter_Alpha] (''abc123@#$'',''_'')' UNION ALL
		SELECT 'dbaudf_Filter_AlphaNumeric'	,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_Filter_AlphaNumeric] (''abc123@#$'',''_'')' UNION ALL
		SELECT 'dbaudf_Filter_Numeric'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_Filter_Numeric] (''abc123@#$'',''_'')' UNION ALL
		SELECT 'dbaudf_Filter_ValidFileName'	,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_Filter_ValidFileName] (''abc\123/@#$'',''_'')' UNION ALL
		SELECT 'dbaudf_FormatString'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_FormatString] (''a{0}_b{1}_c{2}_d{3}_e{4}_f{5}_g{6}_h{7}_i{8}_j{9}'',''a'',''b'',''c'',''d'',''e'',''f'',''g'',''h'',''i'',''j'')' UNION ALL
		SELECT 'dbaudf_FormatTableToHTML'	,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_FormatTableToHTML](''dbaadmin.dbo.DBA_DiskInfo'',''TableName '',''TableTitle'',''TableSummary'',1,1)' UNION ALL
		SELECT 'dbaudf_FormatXML2String'	,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_FormatXML2String] (''<FileProcess><Settings QueueMax="32" ForceOverwrite="false" Verbose="1" UpdateInterval="300"><CopyFile Source="\\SEAPSQLCSO01\g$\safe\Backup\dba_archive\SEAPCSOSQL01_BASE_archive.txt" Destination="\\SEAPSQLCSO01\SEAPSQLCSO01_dba_archive\BeforeClone\SEAPCSOSQL01_BASE_archive.txt" /><CopyFile Source="\\SEAPSQLCSO01\g$\safe\Backup\dba_archive\SEAPCSOSQL01_RestoreFull_AssetPS.gsql" Destination="\\SEAPSQLCSO01\SEAPSQLCSO01_dba_archive\BeforeClone\SEAPCSOSQL01_RestoreFull_AssetPS.gsql" /></Settings></FileProcess>'')' UNION ALL
		SELECT 'dbaudf_GetEV'			,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_GetEV] (''COMPUTERNAME'')' UNION ALL
		SELECT 'dbaudf_GetExtensionFromFile'	,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_GetExtensionFromFile] (''C:\test.txt'')' UNION ALL
		SELECT 'dbaudf_GetFile'			,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_GetFile](''C:\test.txt'')' UNION ALL
		SELECT 'dbaudf_GetFileFromPath'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_GetFileFromPath](''C:\test.txt'')' UNION ALL
		SELECT 'dbaudf_GetFileProperty'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_GetFileProperty] (''C:\test.txt'',''file'',''CreationTime'')' UNION ALL
		SELECT 'dbaudf_GetSharePath'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_GetSharePath] ([dbaadmin].[dbo].[dbaudf_getShareUNC](''backup''))' UNION ALL
		SELECT 'dbaudf_HtmlDecode'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_HtmlDecode] (''123/(abc).&lt;456&gt;,[def]'')' UNION ALL
		SELECT 'dbaudf_HtmlEncode'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_HtmlEncode] (''123/(abc).<456>,[def]'')' UNION ALL
		SELECT 'dbaudf_isXML'			,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_isXML] (''123/(abc).<456>,[def]''),@Result = [dbaadmin].[dbo].[dbaudf_isXML] (''<FileProcess><Settings QueueMax="32" ForceOverwrite="false" Verbose="1" UpdateInterval="300"><CopyFile Source="\\SEAPSQLCSO01\g$\safe\Backup\dba_archive\SEAPCSOSQL01_BASE_archive.txt" Destination="\\SEAPSQLCSO01\SEAPSQLCSO01_dba_archive\BeforeClone\SEAPCSOSQL01_BASE_archive.txt" /><CopyFile Source="\\SEAPSQLCSO01\g$\safe\Backup\dba_archive\SEAPCSOSQL01_RestoreFull_AssetPS.gsql" Destination="\\SEAPSQLCSO01\SEAPSQLCSO01_dba_archive\BeforeClone\SEAPCSOSQL01_RestoreFull_AssetPS.gsql" /></Settings></FileProcess>'')' UNION ALL
		SELECT 'dbaudf_LoadFile'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_LoadFile] (''C:\test.txt'')' UNION ALL
		SELECT 'dbaudf_PutFile'			,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_PutFile](''C:\test2.txt'',0x616263313233)' UNION ALL
		SELECT 'dbaudf_RegexGroup'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_RegexGroup](''212-555-6666 906-932-1111 415-222-3333 425-888-9999'',''(\d{3})-(\d{3}-\d{4})'',''2'')' UNION ALL
		SELECT 'dbaudf_RegexMatch'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_RegexMatch](''SSN: 123-45-6789'',''\d{3}-\d{2}-\d{4}'')' UNION ALL
		SELECT 'dbaudf_RegexReplace'		,'FS','DECLARE @Result VARCHAR(max);SELECT @Result = [dbaadmin].[dbo].[dbaudf_RegExReplace] (N''This is   text with   far  too   much    whitespace.'',N''\s+'',N'' '')' UNION ALL
		--SELECT 'dbaudf_RunProcess'		,'FS',' ' UNION ALL
		--SELECT 'dbaudf_ScriptObject'		,'FS',' ' UNION ALL
		SELECT 'dbaudf_SetEV'			,'FS','declare @results varchar(max);IF dbaadmin.dbo.dbaudf_SetEV(''testvariable'',''12345'') = dbaadmin.dbo.dbaudf_GetEV(''testvariable'') BEGIN select @Results = dbaadmin.dbo.dbaudf_SetEV(''testvariable'',''''); IF dbaadmin.dbo.dbaudf_GetEV(''testvariable'') IS NULL print ''yes''; ELSE print ''no''; END else Print ''no'';' UNION ALL
		SELECT 'dbaudf_DirectoryList'		,'FT','SELECT * into #crap FROM [dbaadmin].[dbo].[dbaudf_DirectoryList](''c:\'',null); drop table #crap;' UNION ALL
		SELECT 'dbaudf_DirectoryList2'		,'FT','SELECT * into #crap FROM [dbaadmin].[dbo].[dbaudf_DirectoryList2](''c:\'',null,0); drop table #crap;' UNION ALL
		SELECT 'dbaudf_FileAccess_Read'		,'FT','SELECT * into #crap FROM [dbaadmin].[dbo].[dbaudf_FileAccess_Read](''c:\test.txt''); drop table #crap;' UNION ALL
		SELECT 'dbaudf_GetAllEVs'		,'FT','SELECT * into #crap FROM [dbaadmin].[dbo].[dbaudf_GetAllEVs](); drop table #crap;' UNION ALL
		SELECT 'dbaudf_ListDrives'		,'FT','select * INTO #crap FROM dbaadmin.dbo.dbaudf_ListDrives();IF OBJECT_ID(''tempdb..#Crap'') IS NOT NULL DROP TABLE #Crap' UNION ALL
		--SELECT 'dbaudf_Query'			,'FT',' ' UNION ALL
		SELECT 'dbaudf_RegexGroups'		,'FT','select * INTO #crap from [dbaadmin].[dbo].[dbaudf_RegexGroups](''212-555-6666 906-932-1111 415-222-3333 425-888-9999'',''\d{3}-\d{3}-\d{4}'');IF OBJECT_ID(''tempdb..#Crap'') IS NOT NULL DROP TABLE #Crap' UNION ALL
		SELECT 'dbaudf_RegexMatches'		,'FT','select * INTO #crap From [dbaadmin].[dbo].[dbaudf_RegexMatches]('' SSN: 123-45-6789'', ''\d{3}-\d{2}-\d{4}'');IF OBJECT_ID(''tempdb..#Crap'') IS NOT NULL DROP TABLE #Crap' UNION ALL
		SELECT 'dbaudf_RestoreFileList'		,'FT','DECLARE @Result INT;SELECT @Result = count(*) FROM [dbaadmin].[dbo].[dbaudf_RestoreFileList]((SELECT top 1 FullPathName FROM [dbaadmin].[dbo].[dbaudf_DirectoryList2]([dbaadmin].[dbo].[dbaudf_GetSharePath] ([dbaadmin].[dbo].[dbaudf_getShareUNC](''backup'')),''dbaadmin_db*'',0)));' UNION ALL
		SELECT 'dbaudf_RestoreHeader'		,'FT','DECLARE @Result INT;SELECT @Result = count(*) FROM [dbaadmin].[dbo].[dbaudf_RestoreHeader]((SELECT top 1 FullPathName FROM [dbaadmin].[dbo].[dbaudf_DirectoryList2]([dbaadmin].[dbo].[dbaudf_GetSharePath] ([dbaadmin].[dbo].[dbaudf_getShareUNC](''backup'')),''dbaadmin_db*'',0)));' UNION ALL
		SELECT 'dbaudf_StringToTable'		,'FT','DECLARE @Result INT;SELECT @Result = count(*) FROM [dbaadmin].[dbo].[dbaudf_StringToTable](''aaa,bbb,ccc,ddd,eee'','','')' UNION ALL
		SELECT 'dbasp_DiskSpace'		,'PC','CREATE TABLE #DS ([Drive/MountPoint] VarChar(500),[Capacity (MB)] FLOAT,[Used Space (MB)] FLOAT,[Free Space (MB)] FLOAT,[Percent Free Space] FLOAT);INSERT INTO #DS exec [dbaadmin].[dbo].[dbasp_DiskSpace] @@SERVERNAME;DROP TABLE #DS;' UNION ALL
		SELECT 'dbasp_EventLogWrite'		,'PC','exec [dbaadmin].[dbo].[dbasp_EventLogWrite] ''test'',''test'',''test'',1,1' UNION ALL
		SELECT 'dbasp_Export_CsvFile'		,'PC','exec [dbaadmin].[dbo].[dbasp_Export_CsvFile] ''select * From sys.databases'',''c:\test.txt'',1,1,0' UNION ALL
		SELECT 'dbasp_Export_TabFile'		,'PC','exec [dbaadmin].[dbo].[dbasp_Export_TabFile] ''select * From sys.databases'',''c:\test.txt'',1,1,0' UNION ALL
		SELECT 'dbasp_FileAccess_Read_Blob'	,'PC','DECLARE @Result VarChar(max);exec [dbaadmin].[dbo].[dbasp_FileAccess_Read_Blob] @FullFileName = ''c:\test.txt'', @FileText = @Result OUT;' UNION ALL
		SELECT 'dbasp_FileAccess_Read_Table'	,'PC','CREATE TABLE #Result(line VarChar(max)); INSERT INTO #Result exec [dbaadmin].[dbo].[dbasp_FileAccess_Read_Table] ''c:\test.txt''; DROP TABLE #Result;' UNION ALL
		SELECT 'dbasp_FileAccess_Write'		,'PC','exec [dbaadmin].[dbo].[dbasp_FileAccess_Write] ''abc123'',''c:\test1.txt'',0,1;exec [dbaadmin].[dbo].[dbasp_FileAccess_Write] ''abc123'',''c:\test2.txt'',0,1;exec [dbaadmin].[dbo].[dbasp_FileAccess_Write] ''123abc'',''c:\test3.txt'',0,1;' UNION ALL
		SELECT 'dbasp_FileCompare'		,'PC','DECLARE @Result int;exec @Result = [dbaadmin].[dbo].[dbasp_FileCompare] ''c:\test1.txt'',''c:\test2.txt'';exec @Result = [dbaadmin].[dbo].[dbasp_FileCompare] ''c:\test1.txt'',''c:\test3.txt'';' UNION ALL
		SELECT 'dbasp_FileHandler'		,'PC','DECLARE @XML XML;SET @XML = ''<FileProcess><Settings QueueMax="32" ForceOverwrite="true" Verbose="0" UpdateInterval="5"><CopyFile Source="C:\Test1.txt" Destination="Test11.txt" /><CopyFile Source="C:\Test2.txt" Destination="Test22.txt" /><CopyFile Source="C:\Test3.txt" Destination="Test33.txt" /></Settings></FileProcess>'';exec [dbaadmin].[dbo].[dbasp_FileHandler] @XML;' UNION ALL
		--SELECT 'dbasp_PivotQuery'		,'PC',' ' UNION ALL
		--SELECT 'dbasp_RunQuery'			,'PC',' ' UNION ALL
		SELECT 'dbasp_SaveAsm'			,'PC','exec [dbaadmin].[dbo].[dbasp_SaveAsm] ''GettyImages.Operations.CLRTools'',''GettyImages.Operations.CLRTools'',''C:\GettyImages.Operations.CLRTools.dll''' UNION ALL
		SELECT '','','' 
		)
		,CLRObjects
		AS
		(
		SELECT      so.name [object_name]
				,so.[type] [object_type]
				,SCHEMA_NAME(so.schema_id) AS [object_schema]
				,asmbly.name [assembly_name]
				,asmbly.permission_set_desc
				,am.assembly_class
				,am.assembly_method
		FROM        sys.assembly_modules am
		INNER JOIN  sys.assemblies asmbly
			ON  asmbly.assembly_id = am.assembly_id
			AND asmbly.name NOT LIKE 'Microsoft%'
		INNER JOIN  sys.objects so
			ON  so.object_id = am.object_id
		WHERE		asmbly.name = 'GettyImages.Operations.CLRTools'
		UNION
		SELECT      at.name, 'TYPE' AS [type], SCHEMA_NAME(at.schema_id) AS [Schema],
				asmbly.name, asmbly.permission_set_desc, at.assembly_class,
				NULL AS [assembly_method]
		FROM        sys.assembly_types at
		INNER JOIN  sys.assemblies asmbly
			ON  asmbly.assembly_id = at.assembly_id
			AND asmbly.name NOT LIKE 'Microsoft%'
		WHERE		asmbly.name = 'GettyImages.Operations.CLRTools'
		)
--SELECT		'SELECT '''+[object_name] COLLATE DATABASE_DEFAULT+''','''+[object_type] COLLATE DATABASE_DEFAULT+''','' '' UNION ALL'
--FROM		CLRObjects
--ORDER BY	[object_type],[object_name]

SELECT		'--	TESTING ' + CLRObjects.[object_name] +CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
		+ CASE WHEN nullif(nullif(CLRTests.TestCode,''),' ') IS NULL THEN ' ----- TEST NEEDS TO BE CREATED  ----- ' ELSE  CLRTests.TestCode END +CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
		+'
INSERT INTO	#CLRMemory
select		count(*) as Address_Blocks 
		, sum(single_pages_kb) as single_pages_kb 
		, sum(multi_pages_kb) as multi_pages_kb 
		, sum(virtual_memory_committed_kb) as virtual_memory_committed_kb 
		, sum(single_pages_kb + multi_pages_kb + virtual_memory_committed_kb) as Total_SQLCLR_Memory
		, ''TEST '+CLRObjects.object_name+' '' +CAST(GETDATE()AS VARCHAR(40))
from		sys.dm_os_memory_clerks 
where		[type] = ''MEMORYCLERK_SQLCLR''
GO 10 '+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

FROM		CLRObjects
LEFT JOIN	CLRTests
	ON	CLRObjects.object_name = CLRTests.object_name

GO

PRINT
'

SELECT * FROM #CLRMemory
GO

'