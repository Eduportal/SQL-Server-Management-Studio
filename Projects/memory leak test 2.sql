IF OBJECT_ID('tempdb..#CLRMemory') IS NOT NULL DROP TABLE #CLRMemory
GO
CREATE TABLE #CLRMemory
	(
	Address_Blocks			INT
	,single_pages_kb		INT
	,multi_pages_kb			INT
	,virtual_memory_committed_kb	INT
	,Total_SQLCLR_Memory		INT
	,SampledWhen			VarChar(50)
	)
GO
INSERT INTO #CLRMemory
select count(*) as Address_Blocks 
, sum(single_pages_kb) as single_pages_kb 
, sum(multi_pages_kb) as multi_pages_kb 
, sum(virtual_memory_committed_kb) as virtual_memory_committed_kb 
, sum(single_pages_kb + multi_pages_kb + virtual_memory_committed_kb) as Total_SQLCLR_Memory
, 'START' 
from sys.dm_os_memory_clerks 
where [type] = 'MEMORYCLERK_SQLCLR'	
GO


--	TESTING dbaudf_CPUInfo
DECLARE @Result INT;SELECT @Result =  dbaadmin.dbo.dbaudf_CPUInfo('Cores') + dbaadmin.dbo.dbaudf_CPUInfo('Processors') + dbaadmin.dbo.dbaudf_CPUInfo('Sockets');

INSERT INTO	#CLRMemory
select		count(*) as Address_Blocks 
		, sum(single_pages_kb) as single_pages_kb 
		, sum(multi_pages_kb) as multi_pages_kb 
		, sum(virtual_memory_committed_kb) as virtual_memory_committed_kb 
		, sum(single_pages_kb + multi_pages_kb + virtual_memory_committed_kb) as Total_SQLCLR_Memory
		, 'TEST dbaudf_CPUInfo ' +CAST(GETDATE()AS VARCHAR(40))
from		sys.dm_os_memory_clerks 
where		[type] = 'MEMORYCLERK_SQLCLR'
GO 100



SELECT * FROM #CLRMemory
GO





----DECLARE @Result VARCHAR(max);
----SELECT @Result = [dbaadmin].[dbo].[dbaudf_GetSharePath] ([dbaadmin].[dbo].[dbaudf_getShareUNC]('backup'));
----;
--DECLARE @Result INT;SELECT @Result = count(*) FROM [dbaadmin].[dbo].[dbaudf_RestoreHeader]((SELECT top 1 FullPathName FROM [dbaadmin].[dbo].[dbaudf_DirectoryList2]([dbaadmin].[dbo].[dbaudf_GetSharePath] ([dbaadmin].[dbo].[dbaudf_getShareUNC]('backup')),'dbaadmin_db*',0)));
----drop table #crap;



--DECLARE @Result INT;SELECT @Result = count(*) FROM [dbaadmin].[dbo].[dbaudf_StringToTable]('aaa,bbb,ccc,ddd,eee',',')



--CREATE TABLE #DS ([Drive/MountPoint] VarChar(500),[Capacity (MB)] FLOAT,[Used Space (MB)] FLOAT,[Free Space (MB)] FLOAT,[Percent Free Space] FLOAT);INSERT INTO #DS exec [dbaadmin].[dbo].[dbasp_DiskSpace] @@SERVERNAME;DROP TABLE #DS;

--exec [dbaadmin].[dbo].[dbasp_EventLogWrite] 'test','test','test',1,1


--exec [dbaadmin].[dbo].[dbasp_Export_TabFile] 'select * From sys.databases','c:\test.txt',1,1,0

--GO
--DECLARE @Result VarChar(max);exec [dbaadmin].[dbo].[dbasp_FileAccess_Read_Blob] @FullFileName = 'c:\test.txt', @FileText = @Result OUT; PRINT @Result;
 	
--CREATE TABLE #Result(line VarChar(max)); INSERT INTO #Result exec [dbaadmin].[dbo].[dbasp_FileAccess_Read_Table] 'c:\test.txt'; DROP TABLE #Result;
--exec [dbaadmin].[dbo].[dbasp_FileAccess_Write] 'abc123','c:\test1.txt',0,1;exec [dbaadmin].[dbo].[dbasp_FileAccess_Write] 'abc123','c:\test2.txt',0,1;exec [dbaadmin].[dbo].[dbasp_FileAccess_Write] '123abc','c:\test3.txt',0,1;

--DECLARE @Result int;exec @Result = [dbaadmin].[dbo].[dbasp_FileCompare] 'c:\test1.txt','c:\test2.txt';exec @Result = [dbaadmin].[dbo].[dbasp_FileCompare] 'c:\test1.txt','c:\test3.txt';

--DECLARE @XML XML;SET @XML = '<FileProcess><Settings QueueMax="32" ForceOverwrite="true" Verbose="0" UpdateInterval="5"><CopyFile Source="C:\Test1.txt" Destination="Test11.txt" /><CopyFile Source="C:\Test2.txt" Destination="Test22.txt" /><CopyFile Source="C:\Test3.txt" Destination="Test33.txt" /></Settings></FileProcess>';exec [dbaadmin].[dbo].[dbasp_FileHandler] @XML;



exec [dbaadmin].[dbo].[dbasp_PivotQuery] 'select * From sys.databases','compatibility_level','name','user_access','name'


DECLARE @Result VarChar(max);
exec [dbaadmin].[dbo].[dbasp_RunQuery] @Name = ''
,@Query = 'select * from sys.databases'
,@ServerName = @@Servername
,@DBName = 'Master'
,@Login = 'dbasledridge'
,@Password = 'Tigger4U'
,@outputfile = 'c:\test.txt'
,@OutputText = null --@Result OUT



exec [dbaadmin].[dbo].[dbasp_SaveAsm] 'GettyImages.Operations.CLRTools','GettyImages.Operations.CLRTools','C:\GettyImages.Operations.CLRTools.dll'
exec [dbaadmin].[dbo].[dbasp_SaveAsm] 'GettyImages.Operations.CLRTools','GettyImages.Operations.CLRTools.pdb','C:\GettyImages.Operations.CLRTools.pdb'
			

select content
	,a.name
	 ,f.name
from sys.assembly_files f
join sys.assemblies a
on f.assembly_id = a.assembly_id
