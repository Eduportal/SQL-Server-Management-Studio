USE [MASTER]
GO
ALTER DATABASE [dbaadmin] SET TRUSTWORTHY ON
GO
ALTER DATABASE [dbaadmin] SET ALLOW_SNAPSHOT_ISOLATION ON
GO
SET XACT_ABORT ON
GO
exec sp_configure 'clr enabled' , 1
GO
RECONFIGURE WITH OVERRIDE
GO
USE [dbaadmin]
GO
EXEC sp_changedbowner 'sa'
GO
IF @@VERSION LIKE 'Microsoft SQL Server 2012%'
BEGIN
	IF NOT EXISTS(select * From sys.assemblies WHERE name = 'System.Management')
		exec('CREATE ASSEMBLY [System.Management]
		AUTHORIZATION [dbo]
		FROM ''C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\System.Management.dll''
		WITH PERMISSION_SET = UNSAFE')
  ELSE IF (SELECT Value FROM dbaadmin.[dbo].[dbaudf_StringToTable_Pairs]((select clr_name From dbaadmin.sys.assemblies WHERE name = 'System.Management'),',','=') WHERE Label = 'version') = '2.0.0.0'
		exec('ALTER ASSEMBLY [System.Management]
		FROM ''C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\System.Management.dll''')
END
ELSE
BEGIN
	IF NOT EXISTS(select * From sys.assemblies WHERE name = 'System.Management')
		exec('CREATE ASSEMBLY [System.Management]
		AUTHORIZATION [dbo]
		FROM ''C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll''
		WITH PERMISSION_SET = UNSAFE')
END
GO

DECLARE		@CMD		VarChar(max)
		,@CRLF		CHAR(2)

SELECT		@CMD		= ''
		,@CRLF		= CHAR(13)+CHAR(10)

;WITH		CLR_Objects
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
		UNION
		SELECT      at.name, 'TYPE' AS [type], SCHEMA_NAME(at.schema_id) AS [Schema],
			    asmbly.name, asmbly.permission_set_desc, at.assembly_class,
			    NULL AS [assembly_method]
		FROM        sys.assembly_types at
		INNER JOIN  sys.assemblies asmbly
			ON  asmbly.assembly_id = at.assembly_id
			AND asmbly.name NOT LIKE 'Microsoft%'
		)
SELECT		@CMD = @CMD + @CRLF
		+ 'PRINT ''Dropping ['+[object_schema]+'].['+[object_name]+']...'';'+@CRLF
		+ 'IF OBJECT_ID(''['+[object_schema]+'].['+[object_name]+']'') IS NOT NULL' + @CRLF
		+'     DROP '
		+ CASE [object_type]
			WHEN 'AF' THEN 'AGGREGATE'	-- Aggregate function (CLR)
			WHEN 'FS' THEN 'FUNCTION'	-- Assembly (CLR) scalar-function
			WHEN 'FT' THEN 'FUNCTION'	-- Assembly (CLR) table-valued function
			WHEN 'PC' THEN 'PROCEDURE'	-- Assembly (CLR) stored-procedure
			END
		+ ' ['+[object_schema]+'].['+[object_name]+']'
		+ @CRLF+'--GO'+@CRLF+@CRLF
FROM		CLR_Objects
WHERE		[assembly_name] = 'GettyImages.Operations.CLRTools'
EXEC		(@CMD)
GO

PRINT N'Dropping [GettyImages.Operations.CLRTools]...';
GO
PRINT N'';
GO


-------------------------------------------------------------------------------------------------------
--  [].[gettyimages.operations.clrtools]    drop Scripted From seapsqldply01 on 4/2/2014 8:01:27 PM
-------------------------------------------------------------------------------------------------------

USE [dbaadmin]
GO
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'GettyImages.Operations.CLRTools')
DROP ASSEMBLY [GettyImages.Operations.CLRTools]
GO


GO
