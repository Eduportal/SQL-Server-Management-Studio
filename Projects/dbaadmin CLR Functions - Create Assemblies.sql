USE [dbaadmin]
GO

/****** Object:  SqlAssembly [Functions.DateTime]    Script Date: 03/10/2010 10:28:56 ******/
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.DateTime')
DROP ASSEMBLY [Functions.DateTime]

GO

/****** Object:  SqlAssembly [Functions.String]    Script Date: 03/10/2010 10:28:56 ******/
IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.String')
DROP ASSEMBLY [Functions.String]

GO


USE [dbaadmin]
GO

/****** Object:  SqlAssembly [Functions.DateTime]    Script Date: 03/10/2010 10:28:56 ******/
IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.DateTime')
CREATE ASSEMBLY [Functions.DateTime]
AUTHORIZATION [dbo]
FROM 'C:\Windows\System32\Functions.DateTime.dll'
WITH PERMISSION_SET = SAFE

GO

/****** Object:  SqlAssembly [Functions.String]    Script Date: 03/10/2010 10:28:56 ******/
IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.String')
CREATE ASSEMBLY [Functions.String]
AUTHORIZATION [dbo]
FROM 'C:\Windows\System32\Functions.String.dll'
WITH PERMISSION_SET = SAFE

GO
