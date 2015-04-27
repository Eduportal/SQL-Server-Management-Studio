USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_AdjustDate]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_dbaudf_dbaAdjustDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_dbaudf_AdjustDate]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_CeilingDate]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_CeilingDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_CeilingDate]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FloorDate]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FloorDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FloorDate]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FormatStringFromDataSet]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FormatStringFromDataSet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_FormatStringFromDataSet]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetLocalDateFromUtc]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetLocalDateFromUtc]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetLocalDateFromUtc]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetTimeSpan]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetTimeSpan]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetTimeSpan]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetUtcDateFromLocal]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetUtcDateFromLocal]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_GetUtcDateFromLocal]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsDaylightSavingTime]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsDaylightSavingTime]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_IsDaylightSavingTime]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsDuringPeriod]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsDuringPeriod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_IsDuringPeriod]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsWeekday]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsWeekday]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_IsWeekday]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsWeekend]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsWeekend]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_IsWeekend]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_RoundDate]    Script Date: 03/10/2010 10:35:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_RoundDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_RoundDate]
GO


/****** Object:  UserDefinedFunction [dbo].[dbaudf_Split]    Script Date: 03/10/2010 10:37:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_CLR_Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_CLR_Split]
GO


/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Concatenate]    Script Date: 03/10/2010 10:26:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Concatenate]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_Concatenate]

GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_ConcatenateUnique]    Script Date: 03/10/2010 10:26:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ConcatenateUnique]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_ConcatenateUnique]

GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_First]    Script Date: 03/10/2010 10:26:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_First]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_First]

GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Last]    Script Date: 03/10/2010 10:26:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Last]') AND type = N'AF')
DROP AGGREGATE [dbo].[dbaudf_Last]

GO

USE [dbaadmin]
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Concatenate]    Script Date: 03/10/2010 10:26:21 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Concatenate]') AND type = N'AF')
EXEC dbo.sp_executesql @statement =
N'CREATE AGGREGATE [dbo].[dbaudf_Concatenate]
(@Value [nvarchar](4000))
RETURNS[nvarchar](4000)
EXTERNAL NAME [Functions.String].[Microsoft.Sql.InternalTools.Sql.Functions.String.Concatenate]
'
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_ConcatenateUnique]    Script Date: 03/10/2010 10:26:21 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_ConcatenateUnique]') AND type = N'AF')
EXEC dbo.sp_executesql @statement =
N'CREATE AGGREGATE [dbo].[dbaudf_ConcatenateUnique]
(@Value [nvarchar](4000))
RETURNS[nvarchar](4000)
EXTERNAL NAME [Functions.String].[Microsoft.Sql.InternalTools.Sql.Functions.String.ConcatenateUnique]
'
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_First]    Script Date: 03/10/2010 10:26:21 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_First]') AND type = N'AF')
EXEC dbo.sp_executesql @statement =
N'CREATE AGGREGATE [dbo].[dbaudf_First]
(@Value [nvarchar](4000))
RETURNS[nvarchar](4000)
EXTERNAL NAME [Functions.String].[Microsoft.Sql.InternalTools.Sql.Functions.String.First]
'
GO

/****** Object:  UserDefinedAggregate [dbo].[dbaudf_Last]    Script Date: 03/10/2010 10:26:21 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Last]') AND type = N'AF')
EXEC dbo.sp_executesql @statement =
N'CREATE AGGREGATE [dbo].[dbaudf_Last]
(@Value [nvarchar](4000))
RETURNS[nvarchar](4000)
EXTERNAL NAME [Functions.String].[Microsoft.Sql.InternalTools.Sql.Functions.String.Last]
'
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_Split]    Script Date: 03/10/2010 10:37:37 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_CLR_Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_CLR_Split](@input [nvarchar](4000), @separator [nvarchar](4000))
RETURNS  TABLE (
	[Ordinal] [int] NULL,
	[Value] [nvarchar](max) NULL
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.String].[Microsoft.Sql.InternalTools.Sql.Functions.String.UserDefinedFunctions].[Split]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_AdjustDate]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_AdjustDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_AdjustDate](@Period [nvarchar](4000), @AdjustmentAmount [int], @Date [datetime])
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[AdjustDate]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_CeilingDate]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_CeilingDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_CeilingDate](@date [datetime], @datePrecision [nvarchar](4000))
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[CeilingDate]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FloorDate]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FloorDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_FloorDate](@date [datetime], @datePrecision [nvarchar](4000))
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[FloorDate]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_FormatStringFromDataSet]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_FormatStringFromDataSet]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_FormatStringFromDataSet](@format [nvarchar](4000), @query [nvarchar](4000), @mode [nvarchar](4000))
RETURNS [nvarchar](4000) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.String].[Microsoft.Sql.InternalTools.Sql.Functions.String.UserDefinedFunctions].[FormatStringFromDataSet]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetLocalDateFromUtc]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetLocalDateFromUtc]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_GetLocalDateFromUtc](@UtcDateTime [datetime])
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[GetLocalDateFromUtc]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetTimeSpan]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetTimeSpan]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_GetTimeSpan](@t1 [datetime], @t2 [datetime])
RETURNS [dbo].[SqlTimeSpan] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[GetTimeSpan]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_GetUtcDateFromLocal]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_GetUtcDateFromLocal]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_GetUtcDateFromLocal](@LocalDateTime [datetime])
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[GetUtcDateFromLocal]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsDaylightSavingTime]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsDaylightSavingTime]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_IsDaylightSavingTime](@LocalDateTime [datetime])
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[IsDaylightSavingTime]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsDuringPeriod]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsDuringPeriod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_IsDuringPeriod](@TestDateTime [datetime], @Period [nvarchar](4000), @DateTimeInPeriod [datetime])
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[IsDuringPeriod]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsWeekday]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsWeekday]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_IsWeekday](@TestDateTime [datetime])
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[IsWeekday]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_IsWeekend]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_IsWeekend]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_IsWeekend](@TestDateTime [datetime])
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[IsWeekend]' 
END

GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_RoundDate]    Script Date: 03/10/2010 10:35:49 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_RoundDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[dbaudf_RoundDate](@date [datetime], @datePrecision [nvarchar](4000))
RETURNS [datetime] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [Functions.DateTime].[Microsoft.Sql.InternalTools.Sql.Functions.DateTime.UserDefinedFunctions].[RoundDate]' 
END

GO


