--GO
--ALTER FUNCTION [dbo].[dbaudf_StripPattern]
--(
--    @Input VARCHAR(max),
--    @Pattern VARCHAR(100)
--)
--RETURNS VARCHAR(max)
--AS
--BEGIN
--    WHILE PATINDEX(@Pattern, @Input) != 0
--        BEGIN
--    	    SET @Input = REPLACE(@Input, SUBSTRING(@Input, PATINDEX(@Pattern, @Input), 1), '')
--        END

--    RETURN @Input
--END
--GO
--ALTER FUNCTION [dbo].[dbaudf_FormatPhoneNumber] 
--(
--    @Number money
--)
--RETURNS varchar(25)
--AS
--BEGIN

--    -- Declare the return variable here
--    DECLARE @Formatted varchar(25)  -- Formatted number to return
--    DECLARE @CharNum varchar(18)    -- Character type of phone number
--    DECLARE @Extension int         -- Phone extesion
--    DECLARE @Numerator bigint         -- Working number variable

--    IF @Number IS NULL 
--    BEGIN
--        --Just return NULL if input string is NULL
--        RETURN NULL
--    END

--    -- Just enough room, since max phone number
--    -- digits is 14 + 4 for extension is 18

--    -- Get rid of the decimal
--    SET @Numerator = CAST(@Number * 10000 AS bigint)
--    -- Cast to int to strip off leading zeros
--    SET @Extension = CAST(RIGHT(@Numerator, 4) AS int)
--    -- Strip off the extension
--    SET @CharNum = CAST(LEFT(@Numerator , LEN(@Numerator) - 4) 
--        AS varchar(18))

--    IF LEN(@CharNum) = 10    -- Full phone number, return (905) 555-1212
--      BEGIN
                
--        SET @Formatted = '(' + LEFT(@CharNum, 3) + ') ' + 
--            SUBSTRING(@CharNum,4,3) + '-' + RIGHT(@CharNum, 4)

--        IF @Extension > 0    -- Add Extension
--        BEGIN
--            SET @Formatted = @Formatted +  ' ext '+ 
--                             CAST(@Extension AS varchar(4))
--        END

--        RETURN @Formatted
--      END

--    IF LEN(@CharNum) = 7    -- No Area Code, return 555-1212
--      BEGIN
--        SET @Formatted = LEFT(@CharNum, 3) + '-' + RIGHT(@CharNum, 4)
--        IF @Extension > 0    -- Add Extension
--        BEGIN
--            SET @Formatted = @Formatted +  ' ext '+ 
--                             CAST(@Extension AS varchar(6))
--        END

--        RETURN @Formatted
--      END

--    IF LEN(@CharNum) = 11
--    -- Full phone number with access code,
--    -- return  1 (905) 555-1212  (19055551212)
--      BEGIN
                
--        SET @Formatted = LEFT(@CharNum, 1) + ' (' + SUBSTRING(@CharNum, 2, 3) + ') ' + 
--                         SUBSTRING(@CharNum,4,3) + '-' + RIGHT(@CharNum, 4)

--        IF @Extension > 0    -- Add Extension
--        BEGIN
--            SET @Formatted = @Formatted +  ' ext '+ CAST(@Extension AS varchar(4))
--        END

--        RETURN @Formatted
--      END

    
--    -- Last case, just return the number unformatted (unhandled format)
--    SET @Formatted = @CharNum
--    IF @Extension > 0    -- Just the Extension
--      BEGIN
--        SET @Formatted = @Formatted +  ' ext '+ CAST(@Extension AS varchar(4))
--        RETURN 'ext '+ CAST(@Extension AS varchar(4))
        
--      END

--    RETURN @Formatted

--END
--GO
--ALTER function dbo.dbaudf_formatphone2(@phone_in varchar(50))
--returns varchar(15)
--as
--begin --function
--	declare @i int, @repCount int
--	declare @current_char char(1)
--	declare @phone_new varchar(50)
--	set @phone_new = rtrim(ltrim(@phone_in))

--	if left(@phone_new, 1) = '1'
--		set @phone_new = right(@phone_new, len(@phone_new) -1)
	

--	set @i = 1
--	while @i <= len(@phone_in)
--	begin
--		set @repCount = 0
--		if @i > len(@phone_new)
--			break

--		set @current_char = substring(@phone_new, @i, 1)

--		if isnumeric(@current_char) <> 1
--		begin
--			set @repCount = len(@phone_new) - len(replace(@phone_new, @current_char, ''))
--			set @phone_new = replace(@phone_new, @current_char, '')
--		end

--		set @i = @i + 1 - @repCount
--	end

--	if isnumeric(@phone_new) = 1 and len(@phone_new) = 10 
--		set @phone_new =
--			substring(@phone_new, 1,3) + '-' + 
--			substring(@phone_new, 4,3) + '-' + 
--			substring(@phone_new, 7,4)
--	else
--		set @phone_new = 'invalid entry'

--	return @phone_new
--end --function
--go
--/*
--Select top 50 
--	[DBValue]	= phonenumber
--	,[formatted] 	= dbo.dbaudf_PhonePart('formatted', phonenumber)
--	,countryPart 	= dbo.dbaudf_PhonePart('country', phonenumber)
--	,areaCodePart	= dbo.dbaudf_PhonePart('area', phonenumber)
--	,localPart 	= dbo.dbaudf_PhonePart('local', phonenumber)
--	,extPart	= dbo.dbaudf_PhonePart('ext', phonenumber)
--	,Stripped	= dbo.dbaudf_PhonePart('stripped', phonenumber)
--from 	PhoneNumber_t
--where	len(phoneNumber) > 10
--*/

--If Object_ID('dbo.dbaudf_PhonePart') > 0
--	Drop Function dbo.dbaudf_PhonePart
--GO

CREATE Function dbo.dbaudf_PhonePart( @part varchar(10), @phone varChar(500) )
returns varChar(50)
as
Begin
	/*
	possible phone parts are:
		international	(anything that begins with 'i' or 'c')
		areaCode		(anything that begins with 'a')
		local			(anything that begins with 'l')
		Extension		(anything that begins with 'e' or 'x')
		FullyFormated	(anything that begins with 'f')
		Stripped		(anything that begins with 's' Only numbers - no extension, no formatting)
	*/ 
	declare @retVal		varchar(50)			,@number	varchar(500)
			,@country	varchar(50)			,@area		varchar(50)
			,@local		varchar(50)			,@ext		varchar(50)
			
			,@Parts		INT
			,@Part1		VarChar(50)			,@Part2		VarChar(50)
			,@Part3		VarChar(50)			,@Part4		VarChar(50)
			,@Part5		VarChar(50)			,@Part6		VarChar(50)
			,@Part7		VarChar(50)			,@Part8		VarChar(50)
			,@Part9		VarChar(50)			,@Part10	VarChar(50)
						
	SELECT	@number		= CASE OccurenceId WHEN 1 THEN SplitValue ELSE @number END
			,@ext		= CASE OccurenceId WHEN 2 THEN REPLACE(SplitValue,' ','') ELSE @ext END
	FROM	dbaudf_split(dbaadmin.dbo.[dbaudf_StripPattern](LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						@phone,'.',' '),'-',' '),'(',' '),')',' '),'  ',' '),'  ',' '))),'%[^0-9x +]%'),'x')

	WHILE	LEFT(@number,1) IN ('0','1')
	BEGIN
		SET @number =  STUFF(@number,1,1,'')
	END
	
	SELECT	@Part1		= CASE OccurenceId WHEN 1 THEN SplitValue ELSE @Part1	END
			,@Part2		= CASE OccurenceId WHEN 2 THEN SplitValue ELSE @Part2	END
			,@Part3		= CASE OccurenceId WHEN 3 THEN SplitValue ELSE @Part3	END
			,@Part4		= CASE OccurenceId WHEN 4 THEN SplitValue ELSE @Part4	END
			,@Part5		= CASE OccurenceId WHEN 5 THEN SplitValue ELSE @Part5	END
			,@Part6		= CASE OccurenceId WHEN 6 THEN SplitValue ELSE @Part6	END
			,@Part7		= CASE OccurenceId WHEN 7 THEN SplitValue ELSE @Part7	END
			,@Part8		= CASE OccurenceId WHEN 8 THEN SplitValue ELSE @Part8	END
			,@Part9		= CASE OccurenceId WHEN 9 THEN SplitValue ELSE @Part9	END
			,@Part10	= CASE WHEN OccurenceId > 9 THEN isnull(@Part10+' ','') + SplitValue ELSE @Part10 END
	FROM	dbaudf_split(@number,' ')
	SELECT	@Parts		= @@ROWCOUNT
			,@number	= REPLACE(@number,' ','')

	IF		LEFT(LTRIM(RTRIM(@Part1)),1) = '+'
	BEGIN 
		SELECT	@country	= REPLACE(@Part1,'+','')
				,@number	= STUFF(@number,1,len(@Part1),'')
	END
	ELSE If	Len(@Part1) = 3 AND Len(@Part2) = 3 AND Len(@Part3) = 4 and @Parts > 3
	BEGIN
		--assume xxx-xxx-xxxx
		SELECT	@ext		= REPLACE(IsNull(@Part4,'')+IsNull(@Part5,'')+IsNull(@Part6,'')+IsNull(@Part7,'')
							+ IsNull(@Part8,'')+IsNull(@Part9,'')+IsNull(@Part10,''),' ','')
				,@number	= @Part1+@Part2+@Part3
	END				

	SELECT	@country	= CASE	WHEN LEFT(@Part1,1) = '+'			THEN @Country
								WHEN len(@number) = 10				THEN NULL
								WHEN len(@number) Between 11 AND 13	THEN LEFT(@number,len(@number)-10)
								WHEN len(@number) = 14				THEN left(@number, 3)
								WHEN len(@number) > 14				THEN subString(@number, 1, len(@number) - 12)
								END 
			,@area		= CASE	WHEN len(@number) = 10				THEN SubString(@number,1,3)
								WHEN len(@number) Between 11 AND 13	THEN left(right(@number, 10),3)
								WHEN len(@number) = 14				THEN left(right(@number, 11),3)
								WHEN len(@number) > 14				THEN left(right(@number, 12),4)
								WHEN len(@number) > 7				THEN left(@number, len(@number)-7)
								END
			,@local		= CASE	WHEN len(@number) = 10				THEN SubString(@number,4,7)
								WHEN len(@number) Between 11 AND 13	THEN right(@number, 7)
								WHEN len(@number) = 14				THEN right(@number, 8)
								WHEN len(@number) > 14				THEN right(@number, 8)
								WHEN len(@number) > 7				THEN right(@number, 7)
								WHEN len(@number) > 0				THEN @number
								END
			,@local		= REVERSE(STUFF(REVERSE(@local),5,0,'-'))					
			,@retVal	= CASE LEFT(@part,1)
								WHEN 'c'	THEN @country
								WHEN 'i'	THEN @country
								WHEN 'a'	THEN @area
								WHEN 'l'	THEN @local
								WHEN 'e'	THEN @ext
								WHEN 'x'	THEN @ext
								WHEN 'f'	THEN ISNULL(NULLIF(@country,'')+' ','')
													+ ISNULL('('+NULLIF(@area,'')+') ','')
													+ @local
													+ ISNULL(' x'+NULLIF(@ext,''),'')
								ELSE @number
								END

	return nullif(@retVal,'')

End
GO
	--DECLARE	@number varchar(20),@ext varchar(20)

	--SELECT	@number		= CASE OccurenceId WHEN 1 THEN SplitValue ELSE @number END
	--		,@ext		= CASE OccurenceId WHEN 2 THEN SplitValue ELSE @ext END
	--FROM	dbaudf_split(dbaadmin.dbo.[dbaudf_StripPattern]('(212)763-3600x3635','%[^0-9x]%'),'x')

	--SELECT	@number	
	--		,@ext	
	


--Go
--CREATE Function dbo.dbaudf_formatPhone_US(@phone varchar(30))
--Returns varchar(30) As
--Begin
--	Declare @rtnValue varchar(30)

--	Set @Phone = dbo.dbaudf_GetCharacters(@Phone,'0-9')
--	Set @rtnValue = replace(case 
--			when len(@phone) > 10 
--				then stuff(stuff(stuff(stuff(@phone,11,0,' x'),7,0,'-'),4,0,') '),1,0,'(')
--			when len(@phone) = 10 
--				then stuff(stuff(stuff(@phone,7,0,'-'),4,0,') '),1,0,'(')
--			else @phone end,'(000) ','')

--	Return @rtnValue
--End
--Go
--CREATE Function dbo.dbaudf_GetCharacters(@myString varchar(500), @validChars varchar(100))
--Returns varchar(500) AS
--Begin
 
--	While @myString like '%[^' + @validChars + ']%'
--		Select @myString = replace(@myString,substring(@myString,patindex('%[^' + @validChars + ']%',@myString),1),'')

--	Return @myString
--End
--Go

-- +ccc (aaa) lll-lll xeeee
-- c=country
-- a=area
-- l=local
-- e=extension

DECLARE	@Numbers	Table	(PhoneNumber sysname)

INSERT INTO @Numbers
SELECT	'886 2 27072141' UNION ALL
SELECT	'02-381-6633-4' UNION ALL
SELECT	'(+34) 93 413 32 00' UNION ALL
SELECT	'0148879595' UNION ALL
SELECT	'31442380005312' UNION ALL
SELECT	'000000000' UNION ALL
SELECT	'000000' UNION ALL
SELECT	'(212)763-3600x3635' UNION ALL
SELECT	'Phone Requested' UNION ALL
SELECT	'2527 2244' UNION ALL
SELECT	'00498932607410' UNION ALL
SELECT	'(66-2) 249-1193' UNION ALL
SELECT	'353 (0) 705 5333' UNION ALL
SELECT	'00 32 2 70 60 540' UNION ALL
SELECT	'886 2 27118833*221' UNION ALL
SELECT	'1-610-676-0400' UNION ALL
SELECT	'+358 3 63151' UNION ALL
SELECT	'0225141' UNION ALL
SELECT	'886-2-2311-3678 ext 52' UNION ALL
SELECT	'407.415.5375' UNION ALL
SELECT	'[Phone Missing]' UNION ALL
SELECT	'020 7395 4460' UNION ALL
Select '(785) 555-3100' UNION ALL
Select '(785)555-3100' UNION ALL
Select '785.555.3100' UNION ALL
Select '(785) 555-3100 ext. 1474' UNION ALL
Select '(785)555-3100 x 1474' UNION ALL
Select '785.555.3100 1474' UNION ALL
Select '785.555.3100.1474' UNION ALL
Select '(800) 948-9543' UNION ALL
Select '(800)646-5287' UNION ALL
Select '800-985-5698' UNION ALL
Select '800 763-6521x654' UNION ALL
Select '(800) 726-9871 x3654' UNION ALL
Select '8009489543' UNION ALL
Select '800 687 4906' UNION ALL
Select '800 354 6871 24569' UNION ALL
Select '(000) 948-9543' UNION ALL
Select '(000)646-5287' UNION ALL
Select '000-985-5698' UNION ALL
Select '000 763-6521x654' UNION ALL
Select '(000) 726-9871 x3654' UNION ALL
Select '0009489543' UNION ALL
Select '000 687 4906' UNION ALL
Select '000 354 6871 24569'



			SELECT	PhoneNumber
					,[Stripped]			= dbo.dbaudf_PhonePart('stripped', phonenumber)
					,[formatted] 		= dbo.dbaudf_PhonePart('formatted', phonenumber)
					,[countryPart] 		= dbo.dbaudf_PhonePart('country', phonenumber)
					,[areaCodePart]		= dbo.dbaudf_PhonePart('area', phonenumber)
					,[localPart] 		= dbo.dbaudf_PhonePart('local', phonenumber)
					,[extPart]			= dbo.dbaudf_PhonePart('ext', phonenumber)
			FROM	@Numbers




