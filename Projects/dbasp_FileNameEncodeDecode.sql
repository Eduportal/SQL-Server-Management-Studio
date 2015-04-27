


create PROC dbasp_FileNameEncodeDecode
			(
			@OriginalFileName	nvarchar(4000) = NULL OUT
			,@Data			nvarChar(4000) = NULL OUT
			,@EncodedFileName	nvarChar(4000) = NULL OUT
			)
AS
BEGIN
	DECLARE @FileAndData XML	
	IF @Data IS NULL
	BEGIN
		PRINT '@Data is Null : DECODE MODE'		

		SELECT @FileAndData = [dbaadmin].[dbo].[dbasp_base64_decode] (@EncodedFileName)
		
		
		SELECT	@OriginalFileName = a.b.value('FileName[1]','nVarChar(4000)')
			, @Data = a.b.value('Data[1]','nVarChar(4000)')
		FROM @FileAndData.nodes('/root') a(b)
		
	END
	ELSE
	BEGIN
		PRINT '@Data is NOT Null : ENCODE MODE'
		SELECT @EncodedFileName = [dbaadmin].[dbo].[dbasp_base64_encode] ('<root><FileName>'+@OriginalFileName+'</FileName><Data>'+@Data+'</Data></root>') 
	END

END




DECLARE	@OriginalFileName	nvarchar(4000)
	,@Data			nvarChar(4000)
	,@EncodedFileName	nvarChar(4000)
			
SELECT	@OriginalFileName	='TestFileName.txt'
	,@Data			='A=1,B=2,C=3,d=4'
	,@EncodedFileName	= NULL		
			
exec dbasp_FileNameEncodeDecode @OriginalFileName,@Data,@EncodedFileName OUT

PRINT @EncodedFileName

SELECT	@OriginalFileName	=NULL
	,@Data			=NULL
			
exec dbasp_FileNameEncodeDecode @OriginalFileName OUT,@Data OUT,@EncodedFileName

PRINT @EncodedFileName
PRINT @OriginalFileName
PRINT @Data