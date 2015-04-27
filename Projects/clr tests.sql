USE dbaadmin
go
SET XACT_ABORT ON
GO
exec sp_configure 'clr enabled', 1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_changedbowner 'sa'
GO
ALTER DATABASE dbaadmin SET TRUSTWORTHY ON
GO
ALTER DATABASE dbaadmin SET ALLOW_SNAPSHOT_ISOLATION ON
GO
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'System.Management' and is_user_defined = 1)
DROP ASSEMBLY [System.Management]
GO
:r \\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ALL_dbaadmin_32_CLR.sql
GO

--CREATE ASSEMBLY [System.Management]
--	AUTHORIZATION [dbo]
--	FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll'
--	WITH PERMISSION_SET = UNSAFE
--GO



/*

IF NOT EXISTS(select * From sys.assemblies WHERE name = 'System.Management')
	exec('CREATE ASSEMBLY [System.Management]
	AUTHORIZATION [dbo]
	FROM ''C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll''
	WITH PERMISSION_SET = UNSAFE')

GO

Assembly 'system.management, version=2.0.0.0, culture=neutral
, publickeytoken=b03f5f7f11d50a3a.' 
was not found in the SQL catalog.


If OBJECT_ID('dbo.dbaudf_FileAccess_Read') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_FileAccess_Read
GO

If OBJECT_ID('dbo.dbaudf_ListDrives') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_ListDrives
GO

If OBJECT_ID('dbo.dbaudf_CPUInfo') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_CPUInfo
GO

If OBJECT_ID('dbo.dbaudf_GetFileProperty') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_GetFileProperty
GO

If OBJECT_ID('dbo.dbasp_FileAccess_Write') IS NOT NULL
	DROP PROCEDURE dbo.dbasp_FileAccess_Write
GO


*/



/*

How can I tell if I need to allocate more memory to MemToLeave?
There are two key indicators that express a need to assign more memory to MemToLeave.

If the above T-SQL script shows that the amount of available memory is small for the requirements of your platform. (For example, your application/development team may be able to advise on the expected memory requirements of the managed code components that have been developed).
A more pressing indicator takes the form of a variety of warning/error messages raised by either SQL Server or the specific managed code component.
For example, if the MemToLeave region is too small for .NET managed code, a common indicator of this will be the appearance of frequent “Application Domain Unload” messages appearing in the SQL Server Error log. An example message is provided below:

AppDomain 8 (DatabaseName.dbo[runtime].7) is marked for unload due to common language runtime (CLR) or security data definition language (DDL) operations.

Another indicator is an error message that occurs when using Linked Server queries, that states:

“There is insufficient system memory to run this query.”

If you encounter any of these indicators then you almost certainly need to evaluate your SQL Server usage of VAS.


-g memory_to_reserve
Specifies an integer number of megabytes (MB) of memory that SQL Server will leave available for memory allocations within the SQL Server process, but outside the SQL Server memory pool. The memory outside of the memory pool is the area used by SQL Server for loading items, such as extended procedure .dll files, the OLE DB providers referenced by distributed queries, and automation objects referenced in Transact-SQL statements. The default is 256 MB.
Use of this option might help tune memory allocation, but only when physical memory exceeds the configured limit set by the operating system on virtual memory available to applications. Use of this option might be appropriate in large memory configurations in which the memory usage requirements of SQL Server are atypical and the virtual address space of the SQL Server process is totally in use. Incorrect use of this option can lead to conditions under which an instance of SQL Server may not start or may encounter run-time errors.
Use the default for the -g parameter unless you see any of the following warnings in the SQL Server error log:
"Failed Virtual Allocate Bytes: FAIL_VIRTUAL_RESERVE <size>"
"Failed Virtual Allocate Bytes: FAIL_VIRTUAL_COMMIT <size>"
These messages might indicate that SQL Server is trying to free parts of the SQL Server memory pool in order to find space for items, such as extended stored procedure .dll files or automation objects. In this case, consider increasing the amount of memory reserved by the -g switch.
Using a value lower than the default will increase the amount of memory available to the memory pool managed by the SQL Server Memory Manager and thread stacks; this may, in turn, provide some performance benefit to memory-intensive workloads in systems that do not use many extended stored procedures, distributed queries, or automation objects.

*/





;WITH VAS_Summary AS
(
    SELECT Size = VAS_Dump.Size,
    Reserved = SUM(CASE(CONVERT(INT, VAS_Dump.Base) ^ 0) WHEN 0 THEN 0 ELSE 1 END),
    Free = SUM(CASE(CONVERT(INT, VAS_Dump.Base) ^ 0) WHEN 0 THEN 1 ELSE 0 END)
    FROM
    (
        SELECT CONVERT(VARBINARY, SUM(region_size_in_bytes)) [Size],
            region_allocation_base_address [Base]
            FROM sys.dm_os_virtual_address_dump
        WHERE region_allocation_base_address <> 0
        GROUP BY region_allocation_base_address
        UNION
        SELECT
            CONVERT(VARBINARY, region_size_in_bytes) [Size],
            region_allocation_base_address [Base]
        FROM sys.dm_os_virtual_address_dump
        WHERE region_allocation_base_address = 0x0 ) AS VAS_Dump
        GROUP BY Size
    )
SELECT
    SUM(CONVERT(BIGINT, Size) * Free) / 1024 AS [Total avail mem, KB],
    CAST(MAX(Size) AS BIGINT) / 1024 AS [Max free size, KB]
FROM VAS_Summary WHERE FREE <> 0























-- TESTING NEW CLR CODE


------------------------

SELECT [job_id]
      ,dbaadmin.dbo.dbaudf_Concatenate([run_status])
  FROM [msdb].[dbo].[sysjobhistory]
  WHERE step_id = 0
  GROUP BY [job_id]
  
  
SELECT [job_id]
      ,dbaadmin.dbo.dbaudf_ConcatenateUnique([run_status])
  FROM [msdb].[dbo].[sysjobhistory]
  WHERE step_id = 0
  GROUP BY [job_id]  


-- Check Local Machine
DECLARE @MachineName SYSNAME
SELECT	@MachineName = CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS SYSNAME)
EXEC [dbo].[dbasp_DiskSpace] @MachineName

-- Check Other Machine
EXEC [dbo].[dbasp_DiskSpace] 'SEAPSQLDBA01'





DECLARE @EvtSource nvarchar(4000)
DECLARE @EvtMessage nvarchar(4000)
DECLARE @EvtType nvarchar(4000)
DECLARE @EvtID int
DECLARE @EvtCat smallint

-- TODO: Set parameter values here.

EXECUTE [dbaadmin].[dbo].[dbasp_EventLogWrite] 
   @EvtSource	= 'TSSQLDBA'
  ,@EvtMessage	= 'This is a test'
  ,@EvtType	= 'Information' -- 'SuccessAudit','FailureAudit','Information','Warning','Error'
  ,@EvtID	= 1234
  ,@EvtCat	= 100
GO
















-- OLD
select * From dbaudf_Dir('C:\windows\system32\drivers')

-- NEW
-- RETURN ALL
select * From dbo.dbaudf_DirectoryList('C:\windows\system32',null)

-- RETURN FILTERED
select * From dbo.dbaudf_DirectoryList('C:\windows\system32','*.exe')




-- OLD
select * From dbaudf_FileAccess_Dir('C:\Program Files',1,1)

-- NEW
select * From dbaudf_FileAccess_Dir2('C:\Program Files',1,1)
Select * From dbaudf_FileAccess_Dir3('C:\Program Files',1)


-- OLD
Select sum(size), count(*) 
    from dbaadmin.dbo.dbaudf_Files ('C:\Program Files\', 1,1)

-- NEW
Select sum(size), count(*) 
 From dbaudf_FileAccess_Dir2('C:\Program Files',1,1)

Select sum(size), count(*) 
 From dbaudf_FileAccess_Dir3('C:\Program Files',1)



-- OLD
SELECT * FROM dbaudf_ListDrives()

-- NEW
SELECT * FROM dbaudf_ListDrives2()


-- OLD
SELECT dbo.dbaudf_GetFileProperty('C:\Program Files\desktop.ini','File','Attributes')
SELECT dbo.dbaudf_GetFileProperty('C:\Program Files\desktop.ini','File','size')

-- NEW
SELECT dbo.dbaudf_GetFileProperty2('C:\Program Files\desktop.ini','File','Attributes')
SELECT dbo.dbaudf_GetFileProperty2('C:\Program Files\desktop.ini','File','Length')

SELECT dbo.dbaudf_GetFileProperty('C:\Program Files\desktop.ini','File','FullName')

SELECT dbo.dbaudf_GetFileProperty2('C:\ProgramFiles\desktop.ini','File','Length')
SELECT dbo.dbaudf_GetFileProperty2('C:\Program Files\desktop.ini','XXX','Length')
SELECT dbo.dbaudf_GetFileProperty2('C:\Program Files\desktop.ini','File','XXX')

SELECT dbo.dbaudf_GetFileProperty2('C:\Program Files','Folder','name')
SELECT dbo.dbaudf_GetFileProperty2('C:\','Drive','AvailableFreeSpace')



-- RETURN FILE FORMAT UNICODE,WINDOWS,...
select	* 
	,dbo.dbaudf_GetFileProperty(FullPathName,'File','format')
From	dbo.dbaudf_DirectoryList('C:\windows\system32',null)
WHERE	IsFolder = 0

SELECT dbo.dbaudf_GetFileProperty('C:\Program Files\desktop.ini','File','format')




-- OLD
SELECT	[dbo].[dbaudf_CPUInfo]('Cores')
	,[dbo].[dbaudf_CPUInfo]('Sockets')

-- NEW
SELECT	[dbo].[dbaudf_CPUInfo2]('Cores')
	,[dbo].[dbaudf_CPUInfo2]('Sockets')	
	,[dbo].[dbaudf_CPUInfo2]('Processors')	
	


-- OLD 
SELECT * FROM dbo.dbaudf_FileAccess_Read('C:\','msinfo_SEAPSQLDPLY01.txt')

-- NEW
SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS [LineNo],* FROM dbo.dbaudf_FileAccess_Read('C:\QueryTabFile.txt')

exec dbo.dbasp_FileAccess_Read 'C:\QueryTabFile.txt'

DECLARE @FileText nVarChar(max)
exec dbasp_FileAccess_Read2 'C:\msinfo_SEAPSQLDPLY01.txt',@FileText = @FileText OUT
PRINT @FileText

GO
-- OLD
DECLARE @FileText nVarChar(max)

EXEC dbo.dbasp_FileAccess_Write 'This Is Line 1 ','C:\','TestFileWrite.txt',0,1
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 2 ','C:\','TestFileWrite.txt',1,1
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 3 ','C:\','TestFileWrite.txt',1,1
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 4 ','C:\','TestFileWrite.txt',1,1
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 5 ','C:\','TestFileWrite.txt',1,1

exec dbasp_FileAccess_Read2 'C:\TestFileWrite.txt',@FileText = @FileText OUT;PRINT @FileText;

EXEC dbo.dbasp_FileAccess_Write 'This Is Line 1 ','C:\','TestFileWrite.txt',0,0
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 2 ','C:\','TestFileWrite.txt',1,0
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 3 ','C:\','TestFileWrite.txt',1,0
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 4 ','C:\','TestFileWrite.txt',1,0
EXEC dbo.dbasp_FileAccess_Write 'This Is Line 5 ','C:\','TestFileWrite.txt',1,0

exec dbasp_FileAccess_Read2 'C:\TestFileWrite.txt',@FileText = @FileText OUT;PRINT @FileText;

GO
-- NEW
DECLARE @FileText nVarChar(max)

EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 1 ','C:\TestFileWrite.txt',0,1
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 2 ','C:\TestFileWrite.txt',1,1
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 3 ','C:\TestFileWrite.txt',1,1
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 4 ','C:\TestFileWrite.txt',1,1
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 5 ','C:\TestFileWrite.txt',1,1

exec dbasp_FileAccess_Read2 'C:\TestFileWrite.txt',@FileText = @FileText OUT;PRINT @FileText;

EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 1 ','C:\TestFileWrite.txt',0,0
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 2 ','C:\TestFileWrite.txt',1,0
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 3 ','C:\TestFileWrite.txt',1,0
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 4 ','C:\TestFileWrite.txt',1,0
EXEC dbo.dbasp_FileAccess_Write2 'This Is Line 5 ','C:\TestFileWrite.txt',1,0

exec dbasp_FileAccess_Read2 'C:\TestFileWrite.txt',@FileText = @FileText OUT;PRINT @FileText;
GO



EXEC dbo.dbasp_FileAccess_Write2 '','C:\TestFileWrite.txt',0,0

select dbo.dbaudf_FileAccess_Write(text,'C:\TestFileWrite.txt',1,1)
From sys.messages

exec dbo.dbasp_FileAccess_Read 'C:\TestFileWrite.txt'

GO

EXEC dbo.dbasp_FileAccess_Write2 '','C:\TestFileWrite.txt',0,0

select dbo.dbaudf_FileAccess_Write(text,'C:\TestFileWrite.txt',1,0)
From sys.messages

exec dbo.dbasp_FileAccess_Read 'C:\TestFileWrite.txt'




EXEC dbo.dbasp_PivotQuery 
	'SELECT db_name(dbid) [DBName],object_name(objectid,dbid) [ObjectName],cast(convert(varchar(12),rundate,102)AS DateTime) [RunDay],datepart(hour,rundate) [RunHr], isnull(execution_count,0) [execution_count],isnull(Avg_Elapsed_Time_MS,0) [Avg_Elapsed_Time_MS] INTO #temp FROM [dbaperf].[dbo].[DMV_QueryStats_log] WHERE object_name(objectid,dbid) is not null AND db_name(dbid) IS NOT NULL'
	,'RunHr'
	,'DBName,ObjectName,RunDay,RunHr,Avg_Elapsed_Time_MS'
	,'Avg(Avg_Elapsed_Time_MS)'
	,'ORDER BY DBName,ObjectName,RunDay'



exec dbo.dbasp_Export_TabFile

'SELECT top 100 [rundate]
      ,[intrvl_time_S]
      ,[dbid]
      ,[objectid]
      ,[delta_worker_time]
      ,[Avg_CPU_Time_MS]
      ,[delta_elapsed_time]
      ,[Avg_Elapsed_Time_MS]
      ,[delta_physical_reads]
      ,[delta_logical_reads]
      ,[Avg_Logical_Reads]
      ,[delta_logical_writes]
      ,[Avg_Logical_Writes]
      ,[execution_count]
      ,[QueryText]
  FROM [dbaperf].[dbo].[DMV_QueryStats_log]','C:\QueryTabFile.txt',1,1,1
  
  exec dbo.dbasp_Export_CsvFile

'SELECT top 100 [rundate]
      ,[intrvl_time_S]
      ,[dbid]
      ,[objectid]
      ,[delta_worker_time]
      ,[Avg_CPU_Time_MS]
      ,[delta_elapsed_time]
      ,[Avg_Elapsed_Time_MS]
      ,[delta_physical_reads]
      ,[delta_logical_reads]
      ,[Avg_Logical_Reads]
      ,[delta_logical_writes]
      ,[Avg_Logical_Writes]
      ,[execution_count]
      ,[QueryText]
  FROM [dbaperf].[dbo].[DMV_QueryStats_log]','C:\QueryCsvFile.txt',1,1,1
  
GO

DECLARE @Ret INT
EXECUTE @Ret = [dbaadmin].[dbo].[dbasp_FileCompare] 
		   @file1 = 'C:\QueryTabFile.txt'
		  ,@file2 = 'C:\QueryTabFile.txt'
SELECT @Ret

EXECUTE @Ret = [dbaadmin].[dbo].[dbasp_FileCompare] 
		   @file1 = 'C:\QueryTabFile.txt'
		  ,@file2 = 'C:\QueryCsvFile.txt'
SELECT @Ret
GO

DECLARE @Text VarChar(50) 
SET	@Text = '\/:*?"''<>advsasdv4123545!@#$%.dk1'


SELECT dbo.dbaudf_Filter_Alpha(@Text,'_'),@Text

SELECT dbo.dbaudf_Filter_AlphaNumeric(@Text,'_'),@Text

SELECT dbo.dbaudf_Filter_Numeric(@Text,'_'),@Text

SELECT dbo.dbaudf_Filter_ValidFileName(@Text,'_'),@Text


SELECT [dbo].[dbaudf_FormatString] ('At {0} on {1}, the temperature was {2} degrees.'
  ,getdate()
  ,@@ServerName
  ,87.4
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL)
GO

SELECT dbo.dbaudf_GetEV('Path') 

SELECT * FROM dbo.dbaudf_GetAllEVs()




SELECT REPLACE(@@SERVERNAME,'\','$')+'_'+'SQLjob_logs'

CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS SYSNAME)



DECLARE @ShareName VarChar(50)
-- SPECIFIC SHARE NAME
SET @ShareName = 'SEAVMSQLMSDEV01_builds'
Select dbo.dbaudf_GetSharePath(@ShareName)

-- FULL SHARE UNC
SET @ShareName = '\\SEAVMSQLMSDEV01\SEAVMSQLMSDEV01_builds'
Select dbo.dbaudf_GetSharePath(@ShareName)

-- DYNAMIC INSTANCE SPECIFIC SHARE
SET @ShareName = 'SQLjob_logs'
Select dbo.dbaudf_GetSharePath(REPLACE(@@SERVERNAME,'\','$')+'_'+@ShareName)

-- DYNAMIC SERVER SPECIFIC SHARE
SET @ShareName = 'dba_mail'
Select dbo.dbaudf_GetSharePath(CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS SYSNAME)+'_'+@ShareName)


SELECT dbo.dbaudf_GetEV('TestParameter') 

SELECT dbo.dbaudf_SetEV ('TestParameter','True')

SELECT dbo.dbaudf_GetEV('TestParameter') 

SELECT dbo.dbaudf_SetEV ('TestParameter','False')

SELECT dbo.dbaudf_GetEV('TestParameter') 

SELECT dbo.dbaudf_SetEV ('TestParameter',NULL)

SELECT dbo.dbaudf_GetEV('TestParameter') 

SELECT * FROM dbo.dbaudf_GetAllEVs()

GO

DECLARE @String VarChar(max)
SET @String = ''

--SELECT	@String = @String + T1.Name+','+dbaadmin.dbo.dbaudf_Concatenate(T2.[step_name])+'|'
--FROM [msdb].[dbo].[sysjobs] T1
--JOIN [msdb].[dbo].[sysjobsteps] T2
--	ON T1.Job_id = T2.Job_id
--GROUP BY T1.Name	

SELECT @String = 'fname,lname,city,state
steve,ledridge,kent,wa
jim,wilson,seattle,wa'


SELECT	T1.OccurenceId [RowId],T2.OccurenceId [ColId],T2.SplitValue [Value]
--INTO #Temp
FROM		dbo.dbaudf_StringToTable(@String,CHAR(13)+CHAR(10)) T1
CROSS APPLY	dbo.dbaudf_StringToTable(T1.SplitValue,',') T2


SET @String = 
'
SELECT		T1.OccurenceId [RowId],T2.OccurenceId [ColId],T2.SplitValue [Value]
INTO		#Temp
FROM		dbo.dbaudf_StringToTable('''+@String+''',CHAR(13)+CHAR(10)) T1
CROSS APPLY	dbo.dbaudf_StringToTable(T1.SplitValue,'','') T2'

EXEC dbo.dbasp_PivotQuery 
	@String
	,'[ColId]'
	,'[RowId],[ColId],[Value]'
	,'max([Value])'
	,'ORDER BY [RowId]'




DECLARE @FileText nVarChar(max)
exec dbasp_FileAccess_Read2 'C:\QueryCsvFile.txt',@FileText = @FileText OUT
PRINT @FileText


GO


-----------------------------------------------------------------
-----------------------------------------------------------------
--	EXAMPLE READ CSV OR TAB DELIMITED FILE AS TABLE
-----------------------------------------------------------------
-----------------------------------------------------------------

DECLARE @FileName	VarChar(max)
SET	@FileName	= 'C:\QueryTabFile.txt'

DECLARE @String VarChar(max)
SET @String = 
'select		T1.[LineNo],T2.OccurenceId [ColId],T2.SplitValue [Value]
INTO		#Temp
From		(
		SELECT	ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS [LineNo]
			,Line
		FROM	dbaudf_FileAccess_Read2('''+@FileName+''')
		) T1
Cross Apply	dbo.dbaudf_StringToTable(T1.Line,CHAR(9)) T2
ORDER BY	1,2'

EXEC dbo.dbasp_PivotQuery 
	@String
	,'[ColId]'
	,'[LineNo],[ColId],[Value]'
	,'max([Value])'
	,'ORDER BY [LineNo]'
	
	

