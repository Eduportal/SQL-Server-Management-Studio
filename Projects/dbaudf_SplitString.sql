USE [dbaadmin]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbaudf_SplitString') IS NOT NULL
DROP FUNCTION [dbo].[dbaudf_SplitString]
GO


CREATE function [dbo].[dbaudf_SplitString] ( @String VARCHAR(max), @Delimiter VARCHAR(50))
returns @SplittedValues TABLE
(
    OccurenceId INT IDENTITY(1,1),
    SplitValue VARCHAR(max)
)
as
BEGIN

    DECLARE	@SplitLength	INT
		,@SplitValue	VarChar(max)

    WHILE LEN(@String) > 0

	BEGIN
		SELECT		@SplitLength	= COALESCE(NULLIF(CHARINDEX(@Delimiter,@String),0)-1,LEN(@String))
				,@SplitValue	= SUBSTRING(@String,1,@SplitLength)
				,@String	= STUFF(@String,1,@SplitLength+LEN(@Delimiter),'')

		INSERT INTO	@SplittedValues([SplitValue])
		SELECT		@SplitValue
	END

    RETURN

END

GO


