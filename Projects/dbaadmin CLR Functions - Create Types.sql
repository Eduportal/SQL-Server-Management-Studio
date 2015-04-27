USE [dbaadmin]
GO

/****** Object:  UserDefinedType [dbo].[SqlTimeSpan]    Script Date: 03/10/2010 10:39:15 ******/
IF  EXISTS (SELECT * FROM sys.assembly_types at INNER JOIN sys.schemas ss on at.schema_id = ss.schema_id WHERE at.name = N'SqlTimeSpan' AND ss.name=N'dbo')
DROP TYPE [dbo].[SqlTimeSpan]

GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedType [dbo].[SqlTimeSpan]    Script Date: 03/10/2010 10:39:16 ******/
IF NOT EXISTS (SELECT * FROM sys.assembly_types at INNER JOIN sys.schemas ss on at.schema_id = ss.schema_id WHERE at.name = N'SqlTimeSpan' AND ss.name=N'dbo')
CREATE TYPE [dbo].[SqlTimeSpan]
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.SqlTimeSpan]

GO


