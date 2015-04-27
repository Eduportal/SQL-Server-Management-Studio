USE [dbaadmin]
GO
DECLARE @ProjectRoot VarChar(8000)


SELECT	@ProjectRoot	= '\\SEAW005850\Users\sledridge\Documents\SQL Server Management Studio\Projects\CLR\CLR\'


-- ADD OS ASSEMBLIES

IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'system.web')
CREATE ASSEMBLY [system.web]
AUTHORIZATION [dbo]
FROM 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\system.web.dll'
WITH PERMISSION_SET = UNSAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'system.net')
CREATE ASSEMBLY [system.net]
AUTHORIZATION [dbo]
FROM 'C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v3.5\Profile\Client\system.net.dll'
WITH PERMISSION_SET = UNSAFE



-- ADD PROJECT ASSEMBLIES

IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Yedda.Twitter')
CREATE ASSEMBLY [Yedda.Twitter]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Yedda.Twitter.dll'
WITH PERMISSION_SET = UNSAFE

IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.DateTime')
CREATE ASSEMBLY [Functions.DateTime]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Functions.DateTime.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.Globalization')
CREATE ASSEMBLY [Functions.Globalization]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Functions.Globalization.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.Mail')
CREATE ASSEMBLY [Functions.Mail]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Functions.Mail.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.ProductStudio')
CREATE ASSEMBLY [Functions.ProductStudio]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Functions.ProductStudio.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.ReportingServices')
CREATE ASSEMBLY [Functions.ReportingServices]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Functions.ReportingServices.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.ReportingServices.XmlSerializers')
CREATE ASSEMBLY [Functions.ReportingServices.XmlSerializers]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Functions.ReportingServices.XmlSerializers.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Functions.String')
CREATE ASSEMBLY [Functions.String]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Functions.String.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Microsoft.SQLAuto.RSHelper')
CREATE ASSEMBLY [Microsoft.SQLAuto.RSHelper]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Microsoft.SQLAuto.RSHelper.dll'
WITH PERMISSION_SET = SAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Microsoft.SQLAuto.Utility')
CREATE ASSEMBLY [Microsoft.SQLAuto.Utility]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Microsoft.SQLAuto.Utility.dll'
WITH PERMISSION_SET = UNSAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Microsoft.Sql.InternalTools')
CREATE ASSEMBLY [Microsoft.Sql.InternalTools]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Microsoft.Sql.InternalTools.dll'
WITH PERMISSION_SET = UNSAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Microsoft.Sql.InternalTools.Data')
CREATE ASSEMBLY [Microsoft.Sql.InternalTools.Data]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Microsoft.Sql.InternalTools.Data.dll'
WITH PERMISSION_SET = UNSAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Microsoft.Sql.InternalTools.IO')
CREATE ASSEMBLY [Microsoft.Sql.InternalTools.IO]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Microsoft.Sql.InternalTools.IO.dll'
WITH PERMISSION_SET = UNSAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Interop.SourceDepotClient')
CREATE ASSEMBLY [Interop.SourceDepotClient]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Interop.SourceDepotClient.dll'
WITH PERMISSION_SET = UNSAFE


IF NOT EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'Microsoft.Sql.InternalTools.SourceDepot')
CREATE ASSEMBLY [Microsoft.Sql.InternalTools.SourceDepot]
AUTHORIZATION [dbo]
FROM @ProjectRoot + 'Microsoft.Sql.InternalTools.SourceDepot.dll'
WITH PERMISSION_SET = UNSAFE



















--xp_cmdshell 'dir "C:\Users\Steve\Desktop\CLR Assemblies\Debug\*.dll" /b'