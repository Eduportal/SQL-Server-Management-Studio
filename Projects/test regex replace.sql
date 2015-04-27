


DECLARE	@FilePath	VarChar(max)
	,@FileName	VarChar(max)
	,@IncludeSubDir	BIT
	,@CRLF		CHAR(2)
	,@DBName	SYSNAME
	,@Replace1	VarChar(max)
	,@Replace2	VarChar(max)
	,@WorkDir	VarChar(max)
	,@FileNameSET	VarChar(max)

SELECT	@FilePath	= '\\seapcrmsql1a\seapcrmsql1a_backup\'
	,@FileName	= 'Getty_Images_US_Inc__MSCRM_FG$PRIMARY_20140117210827_SET_[0-9][0-9]_OF_[0-9][0-9].cBAK'
	,@IncludeSubDir	= 0
	,@CRLF		= CHAR(13)+CHAR(10)
	,@DBName	= 'Getty_Images_US_Inc__MSCRM'
	
	,@Replace1	= REPLACE(REPLACE(REPLACE(@FileName,'$','\$'),'_SET_[0-9][0-9]','_SET_(?<set>[0-9][0-9])'),'_OF_[0-9][0-9]','_OF_(?<size>[0-9][0-9])')
	,@Replace2	= REPLACE(REPLACE(REPLACE(@FileName,'$','\$'),'_SET_[0-9][0-9]','_SET_${set}'),'_OF_[0-9][0-9]','_OF_${size}')


SELECT	@Replace1
	,@Replace2
					


					IF @WorkDir IS NOT NULL

						SELECT		@FileNameSET =	REPLACE	(
											dbaadmin.[dbo].[dbaudf_RegexReplace]	(
																dbaadmin.dbo.dbaudf_ConcatenateUnique	(
																					'DISK = '''
																					+ dbaadmin.[dbo].[dbaudf_RegexReplace]	(
																										'$WD$'+ T1.Name
																										,@Replace1
																										,'${set}x${size}'
																										)
																					+ ''''+ @CRLF
																					)
																,'(?<set>[0-9][0-9])x(?<size>[0-9][0-9])'
																,@Replace2
																)
											,'$WD$'
											,@WorkDir
											)

						FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,NULL,@IncludeSubDir) T1
						WHERE		T1.Name LIKE @FileName
					ELSE
						SELECT		--@FileNameSET = 
										--REPLACE	(
											--dbaadmin.[dbo].[dbaudf_RegexReplace]	(
																--dbaadmin.dbo.dbaudf_ConcatenateUnique	(
																					'DISK = '''
																					+ dbaadmin.[dbo].[dbaudf_RegexReplace]	(
																										REPLACE(T1.FullPathName,@FilePath,'$FP$')
																										,@Replace1
																										,'${set}x${size}'
																										)
																					+ ''''+ @CRLF
																					--)
																--,'(?<set>[0-9][0-9])x(?<size>[0-9][0-9])'
																--,@Replace2
																--)
											--,'$FP$'
											--,@FilePath
											--)

						FROM		dbaadmin.dbo.dbaudf_DirectoryList2(@FilePath,NULL,@IncludeSubDir) T1
						WHERE		T1.Name LIKE @FileName

EXEC dbaadmin.dbo.dbasp_PrintLarge @FileNameSET