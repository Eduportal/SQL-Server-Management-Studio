SELECT	Name,DateModified,[dbaadmin].[dbo].[dbaudf_base64_decode] (LEFT(REPLACE(Name,'$','='),LEN(Name)-4)),*
FROM	dbaadmin.dbo.dbaudf_DirectoryList('\\seapdbasql01\SEAPDBASQL01_dbasql\IndexAnalysis','*.dat')
WHERE IsFolder = 0