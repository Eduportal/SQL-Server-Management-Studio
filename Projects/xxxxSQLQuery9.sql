
SET NOCOUNT ON
GO

DECLARE		@Source		VarChar(max)
		,@Destination	VarChar(max)
		,@Mask		VarChar(max)
		,@Data		XML

SELECT		@Source		= '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\'
		,@Destination	= [dbo].[dbaudf_GetSharePath]([dbo].[dbaudf_getShareUNC]('backup'))
		,@Mask		= 'dbaperf*'


;WITH		Settings
		AS
		(
		SELECT		32		AS [QueueMax]		-- Max Number of files coppied at once.
				,'false'	AS [ForceOverwrite]	-- true,false
				,1		AS [Verbose]		-- -1 = Silent, 0 = Normal, 1 = Percent Updates
				,300		AS [UpdateInterval]	-- rate of progress updates in Seconds
		)
		,CopyFile -- MoveFile, DeleteFile
		AS
		(
		SELECT		FullPathName			AS [Source]
				,@Destination + '\' + Name	AS [Destination]
		FROM		dbaudf_DirectoryList2(@Source,@Mask,0)
		)
SELECT		@Data =	(
			SELECT		*
					,(SELECT * FROM CopyFile FOR XML RAW ('CopyFile'), TYPE)
			FROM		Settings
			FOR XML RAW ('Settings'),TYPE, ROOT('FileProcess')
			)

PRINT [dbaadmin].[dbo].[dbaudf_FormatXML2String](@Data)





DECLARE	@Data XML
SET	@Data		= 
'<FileProcess>
  <Settings QueueMax="32" ForceOverwrite="false" Verbose="1" UpdateInterval="300">
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\DBAperf_db_20131019030304.cBAK" Destination="d:\MSSQL\Backup\DBAperf_db_20131019030304.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\DBAperf_dfntl_20131021214635.cDIF" Destination="d:\MSSQL\Backup\DBAperf_dfntl_20131021214635.cDIF" />
  </Settings>
</FileProcess>'

exec dbasp_FileHandler @Data
GO

RESTORE DATABASE [XXX] 
FROM    DISK = 'd:\MSSQL\Backup\DBAperf_db_20131019030304.cBAK'
WITH    NORECOVERY, REPLACE
        ,MOVE 'DBAperf' TO 'D:\MSSQL\data\20131022153912_DBAperf.mdf'
        ,MOVE 'DBAperf_log' TO 'D:\MSSQL\data\20131022153912_DBAperf_log.ldf'
        ,STATS=1
 
RESTORE DATABASE [XXX] 
FROM    DISK = 'd:\MSSQL\Backup\DBAperf_dfntl_20131021214635.cDIF'
WITH    NORECOVERY, REPLACE
        ,STATS=1
 
RESTORE DATABASE [XXX] WITH RECOVERY


GO




RESTORE DATABASE [XXX] 
FROM    DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\DBAperf_db_20131019030304.cBAK'
WITH    NORECOVERY, REPLACE
        ,MOVE 'DBAperf' TO 'D:\MSSQL\data\20131022153912_DBAperf.mdf'
        ,MOVE 'DBAperf_log' TO 'D:\MSSQL\data\20131022153912_DBAperf_log.ldf'
        ,STATS=1
 
RESTORE DATABASE [XXX] 
FROM    DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\DBAperf_dfntl_20131021214635.cDIF'
WITH    NORECOVERY, REPLACE
        ,STATS=1
 
RESTORE DATABASE [XXX] WITH RECOVERY


GO



DECLARE	@Data XML
SET	@Data		= 
'<FileProcess>
  <Settings QueueMax="32" ForceOverwrite="false" Verbose="1" UpdateInterval="300">
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_01_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_01_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_02_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_02_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_03_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_03_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_04_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_04_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_05_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_05_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_06_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_06_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_07_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_07_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_08_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_08_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_09_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_09_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_10_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_10_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_11_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_11_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_12_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_12_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_13_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_13_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_14_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_14_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_15_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_15_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_16_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_16_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_17_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_17_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_18_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_18_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_19_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_19_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_20_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_20_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_21_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_21_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_22_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_22_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_23_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_23_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_24_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_24_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_25_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_25_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_26_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_26_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_27_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_27_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_28_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_28_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_29_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_29_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_30_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_30_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_31_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_31_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_32_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_32_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_33_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_33_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_34_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_34_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_35_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_35_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_36_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_36_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_37_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_37_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_38_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_38_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_39_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_39_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_40_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_40_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_41_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_41_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_42_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_42_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_43_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_43_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_44_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_44_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_45_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_45_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_46_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_46_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_47_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_47_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_48_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_48_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_49_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_49_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_50_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_50_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_51_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_51_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_52_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_52_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_53_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_53_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_54_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_54_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_55_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_55_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_56_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_56_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_57_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_57_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_58_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_58_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_59_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_59_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_60_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_60_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_61_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_61_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_62_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_62_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_63_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_63_of_64.cBAK" />
    <CopyFile Source="\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_64_of_64.cBAK" Destination="d:\MSSQL\Backup\dbaperf_db_20131022131227_set_64_of_64.cBAK" />
  </Settings>
</FileProcess>'

exec dbasp_FileHandler @Data
GO



RESTORE DATABASE [XXX] 
FROM    DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_01_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_02_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_03_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_04_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_05_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_06_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_07_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_08_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_09_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_10_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_11_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_12_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_13_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_14_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_15_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_16_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_17_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_18_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_19_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_20_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_21_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_22_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_23_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_24_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_25_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_26_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_27_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_28_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_29_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_30_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_31_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_32_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_33_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_34_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_35_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_36_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_37_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_38_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_39_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_40_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_41_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_42_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_43_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_44_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_45_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_46_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_47_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_48_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_49_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_50_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_51_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_52_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_53_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_54_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_55_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_56_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_57_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_58_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_59_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_60_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_61_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_62_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_63_of_64.cBAK'
, DISK = 'd:\MSSQL\Backup\dbaperf_db_20131022131227_set_64_of_64.cBAK'
WITH    NORECOVERY, REPLACE
        ,MOVE 'DBAperf' TO 'D:\MSSQL\data\20131022145844_DBAperf.mdf'
        ,MOVE 'DBAperf_log' TO 'D:\MSSQL\data\20131022145844_DBAperf_log.ldf'
        ,STATS=1
 
RESTORE DATABASE [XXX] WITH RECOVERY
GO



RESTORE DATABASE [XXX] 
FROM    DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_01_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_02_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_03_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_04_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_05_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_06_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_07_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_08_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_09_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_10_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_11_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_12_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_13_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_14_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_15_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_16_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_17_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_18_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_19_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_20_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_21_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_22_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_23_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_24_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_25_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_26_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_27_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_28_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_29_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_30_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_31_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_32_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_33_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_34_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_35_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_36_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_37_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_38_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_39_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_40_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_41_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_42_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_43_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_44_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_45_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_46_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_47_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_48_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_49_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_50_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_51_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_52_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_53_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_54_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_55_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_56_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_57_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_58_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_59_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_60_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_61_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_62_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_63_of_64.cBAK'
, DISK = '\\SEAPCRMSQL1A\SEAPCRMSQL1A_Backup\dbaperf_db_20131022131227_set_64_of_64.cBAK'
WITH    NORECOVERY, REPLACE
        ,MOVE 'DBAperf' TO 'D:\MSSQL\data\20131022145844_DBAperf.mdf'
        ,MOVE 'DBAperf_log' TO 'D:\MSSQL\data\20131022145844_DBAperf_log.ldf'
        ,STATS=1
 
RESTORE DATABASE [XXX] WITH RECOVERY
