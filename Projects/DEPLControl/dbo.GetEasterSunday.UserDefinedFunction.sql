USE [DEPLcontrol]
GO
/****** Object:  UserDefinedFunction [dbo].[GetEasterSunday]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetEasterSunday] 
( 
    @Y INT 
) 
RETURNS SMALLDATETIME 
AS 
BEGIN 
    DECLARE     @EpactCalc INT,  
        @PaschalDaysCalc INT, 
        @NumOfDaysToSunday INT, 
        @EasterMonth INT, 
        @EasterDay INT 
 
    SET @EpactCalc = (24 + 19 * (@Y % 19)) % 30 
 
    SET @PaschalDaysCalc = @EpactCalc - (@EpactCalc / 28) 
 
    SET @NumOfDaysToSunday = @PaschalDaysCalc - ( 
        (@Y + @Y / 4 + @PaschalDaysCalc - 13) % 7 
    ) 
 
    SET @EasterMonth = 3 + (@NumOfDaysToSunday + 40) / 44 
 
    SET @EasterDay = @NumOfDaysToSunday + 28 - ( 
        31 * (@EasterMonth / 4) 
    ) 
 
    RETURN 
    ( 
        SELECT CONVERT 
        ( 
            SMALLDATETIME, 
 
            RTRIM(@Y)  
            + RIGHT('0'+RTRIM(@EasterMonth), 2)  
            + RIGHT('0'+RTRIM(@EasterDay), 2) 
        ) 
    ) 
END 

GO
