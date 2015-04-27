USE [dbaadmin]
GO

IF OBJECT_ID('dbaudf_TimeTable') IS NOT NULL
DROP FUNCTION [dbo].[dbaudf_TimeTable]
GO

/****** Object:  UserDefinedFunction [dbo].[TimeTable]    Script Date: 6/26/2013 10:52:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[dbaudf_TimeTable]  
    ( 
    @StartDateTime	DateTime
    ,@EndDateTime	DateTime
    ,@Interval		sysname
    ,@IntervalCount	Int 
    ) 
RETURNS @TimeTable TABLE(DateTimeValue DATETIME NOT NULL)
AS 
BEGIN 
    DECLARE @DateTime	DateTime
    SELECT	@DateTime	= @StartDateTime
    WHILE	@DateTime  <= @EndDateTime 
    BEGIN 
        INSERT INTO @TimeTable (DateTimeValue)
        SELECT		@DateTime
        
        SET @DateTime = CASE @Interval
							WHEN 'year'			THEN Dateadd(year			,@IntervalCount, @DateTime)
							WHEN 'quarter'		THEN Dateadd(quarter		,@IntervalCount, @DateTime)
							WHEN 'month'		THEN Dateadd(month			,@IntervalCount, @DateTime)
							WHEN 'dayofyear'	THEN Dateadd(dayofyear		,@IntervalCount, @DateTime)
							WHEN 'day'			THEN Dateadd(day			,@IntervalCount, @DateTime)
							WHEN 'week'			THEN Dateadd(week			,@IntervalCount, @DateTime)
							WHEN 'weekday'		THEN Dateadd(weekday		,@IntervalCount, @DateTime)
							WHEN 'hour'			THEN Dateadd(hour			,@IntervalCount, @DateTime)
							WHEN 'minute'		THEN Dateadd(minute			,@IntervalCount, @DateTime)
							WHEN 'second'		THEN Dateadd(second			,@IntervalCount, @DateTime)
							WHEN 'millisecond'	THEN Dateadd(millisecond	,@IntervalCount, @DateTime)
							WHEN 'microsecond'	THEN Dateadd(microsecond	,@IntervalCount, @DateTime)
							WHEN 'nanosecond'	THEN Dateadd(nanosecond		,@IntervalCount, @DateTime)
							ELSE @DateTime + @IntervalCount
							END
    END 
    RETURN  
END 


GO

ALTER AUTHORIZATION ON [dbo].[dbaudf_TimeTable] TO  SCHEMA OWNER 
GO

USE [dbaadmin]
GO

IF OBJECT_ID('dbaudf_TimeDimension') IS NOT NULL
DROP FUNCTION [dbo].[dbaudf_TimeDimension]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[dbaudf_TimeDimension]
    ( 
    @StartDateTime	DateTime
    ,@EndDateTime	DateTime
    ,@Interval		sysname
    ,@IntervalCount	Int 
    ) 
RETURNS TABLE
AS RETURN
(
	SELECT		CONVERT(bigint,REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VarChar(50),[DateTimeValue],121),' ',''),':',''),'-',''),'.',''))	AS TimeKey
				,[DateTimeValue]
				,DATEPART(year,[DateTimeValue])					AS DatePart_year			
				,DATEPART(quarter,[DateTimeValue])				AS DatePart_quarter		
				,DATEPART(month,[DateTimeValue])				AS DatePart_month			
				,DATEPART(dayofyear,[DateTimeValue])			AS DatePart_dayofyear		
				,DATEPART(day,[DateTimeValue])					AS DatePart_day			
				,DATEPART(week,[DateTimeValue])					AS DatePart_week			
				,DATEPART(weekday,[DateTimeValue])				AS DatePart_weekday		
				,DATEPART(hour,[DateTimeValue])					AS DatePart_hour			
				,DATEPART(minute,[DateTimeValue])				AS DatePart_minute			
				,DATEPART(second,[DateTimeValue])				AS DatePart_second			
				,DATEPART(millisecond,[DateTimeValue])			AS DatePart_millisecond	
				,DATEPART(microsecond,[DateTimeValue])			AS DatePart_microsecond	
				,DATEPART(nanosecond,[DateTimeValue])			AS DatePart_nanosecond		
				,DATEPART(ISO_WEEK,[DateTimeValue])				AS DatePart_ISO_WEEK		
				,DATENAME(year,[DateTimeValue])					AS DateName_year			
				,DATENAME(quarter,[DateTimeValue])				AS DateName_quarter		
				,DATENAME(month,[DateTimeValue])				AS DateName_month			
				,DATENAME(dayofyear,[DateTimeValue])			AS DateName_dayofyear		
				,DATENAME(day,[DateTimeValue])					AS DateName_day			
				,DATENAME(week,[DateTimeValue])					AS DateName_week			
				,DATENAME(weekday,[DateTimeValue])				AS DateName_weekday		
				,DATENAME(hour,[DateTimeValue])					AS DateName_hour			
				,DATENAME(minute,[DateTimeValue])				AS DateName_minute			
				,DATENAME(second,[DateTimeValue])				AS DateName_second			
				,DATENAME(millisecond,[DateTimeValue])			AS DateName_millisecond	
				,DATENAME(microsecond,[DateTimeValue])			AS DateName_microsecond	
				,DATENAME(nanosecond,[DateTimeValue])			AS DateName_nanosecond		
	FROM		dbaadmin.dbo.dbaudf_TimeTable(@StartDateTime,@EndDateTime,@Interval,@IntervalCount)
)


GO

ALTER AUTHORIZATION ON [dbo].[dbaudf_TimeDimension] TO  SCHEMA OWNER 
GO


USE [dbaadmin]
GO

IF OBJECT_ID('dbaudf_NumberTable') IS NOT NULL
	DROP FUNCTION [dbo].[dbaudf_NumberTable]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[dbaudf_NumberTable]  
    ( 
    @StartNumber Int,  
    @EndNumber Int, 
    @Interval Int 
    ) 
RETURNS @dbaudf_NumberTable TABLE (Number int) 
AS 
BEGIN 
    DECLARE @Number TinyInt 
    Set    @Number = @StartNumber 
    WHILE @Number <= @EndNumber 
    BEGIN 
        INSERT INTO @dbaudf_NumberTable SELECT @Number 
        SET @Number = @Number + @Interval 
    END 
    RETURN  
END 

GO

ALTER AUTHORIZATION ON [dbo].[dbaudf_NumberTable] TO  SCHEMA OWNER 
GO

