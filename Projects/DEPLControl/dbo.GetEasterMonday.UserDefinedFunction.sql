USE [DEPLcontrol]
GO
/****** Object:  UserDefinedFunction [dbo].[GetEasterMonday]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetEasterMonday] 
( 
    @Y INT 
) 
RETURNS SMALLDATETIME 
AS 
BEGIN 
    RETURN (SELECT dbo.GetEasterSunday(@Y) + 1) 
END 

GO
