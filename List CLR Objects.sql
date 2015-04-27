USE [dbaadmin]
GO


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
SELECT		'[[MSSQL Servers/DB Objects/DBAADMIN/CLR/'+[object_name]+'|'+[object_name]+']]' [Object Name]
		, CASE [object_type]
			WHEN 'AF' THEN '(CLR) Aggregate Function'
			WHEN 'FS' THEN '(CLR) Scalar Function'
			WHEN 'FT' THEN '(CLR) Table-Valued Function'
			WHEN 'PC' THEN '(CLR) Stored Procedure'
			END [Object Type]
		,permission_set_desc		[Permission Set]
		,assembly_class			[Assembly Class]
		,assembly_method		[Assembly Method]

FROM		CLR_Objects
WHERE		[assembly_name] = 'GettyImages.Operations.CLRTools'
ORDER BY	2,1
GO

