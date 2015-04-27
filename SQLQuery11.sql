DECLARE @DDL VarBINary(max)
DECLARE @DDL2 VarChar(max)

SELECT @DDL = [dbaadmin].[dbo].[dbaudf_GetFile]('\\SEAPSQLDBA01\DBA_Docs\SourceCode\DBAADMIN\dbaadmin_source\ScriptSQLObject.exe')

SELECT	@DDL2 = CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+'SELECT [dbaadmin].[dbo].[dbaudf_PutFile](''C:\ScriptSQLObject.exe'','+CONVERT(VarChar(max),@DDL,1)+')'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

SELECT	[dbaadmin].[dbo].[dbaudf_FileAccess_Write](@DDL2,'C:\ScriptSQLObject.sql',1,1)

SELECT		*
FROM		[dbaadmin].[dbo].[dbaudf_SplitSize](@DDL2,1000)
order by 1
--SELECT	 [dbaadmin].[dbo].[dbaudf_PutFile]('C:\ScriptSQLObject.exe',@DDL)

----declare @source varbinary(max);
----set @source = 0x21232F297A57A5A743894A0E4A801FC3;
----select cast('' as xml).value('xs:hexBinary(sql:variable("@source"))', 'varchar(max)');

--DECLARE @Results INT
--exec @Results = [dbaadmin].[dbo].[dbasp_FileCompare] 'C:\Windows\System32\ScriptSQLObject.exe','C:\ScriptSQLObject.exe'
--PRINT @Results
