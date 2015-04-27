
USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[dbaudf_split]    Script Date: 03/26/2010 11:41:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[dbaudf_split]') IS NULL
BEGIN
execute dbo.sp_executesql @statement = N'

Create function [dbo].[dbaudf_split] ( @String VARCHAR(200), @Delimiter VARCHAR(5))
returns @SplittedValues TABLE
(
    OccurenceId SMALLINT IDENTITY(1,1),
    SplitValue VARCHAR(200)
)
/**************************************************************
 **  User Defined Function dbaudf_split                 
 **  Written by David Spriggs, Getty Images                
 **  May 12, 2009                                     
 **  
 **  This dbaudf is set up parse a delimited string return values
 **  in tabular format.
 **  
 ***************************************************************/
as

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	05/13/2009	David Spriggs		New process
--	
--	======================================================================================

/***
declare @String VARCHAR(200)
declare @Delimiter VARCHAR(5)

set @String = ''abc def ghi''
set @Delimiter = '' ''

--***/

BEGIN

    DECLARE @SplitLength INT

    WHILE LEN(@String) > 0

	BEGIN

	    SELECT @SplitLength = (CASE CHARINDEX(@Delimiter,@String) WHEN 0 THEN
			           LEN(@String) ELSE CHARINDEX(@Delimiter,@String) -1 END)

	    INSERT INTO @SplittedValues
	    SELECT SUBSTRING(@String,1,@SplitLength)

	    SELECT @String = (CASE (LEN(@String) - @SplitLength) WHEN 0 THEN ''''
			      ELSE RIGHT(@String, LEN(@String) - @SplitLength - 1) END)
	END

    RETURN

END

' 
END

GO

