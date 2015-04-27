USE [dbaadmin]
SET NOCOUNT ON
GO
--DROP AND RECREATE TABLE
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RAW_DBA_DiskInfo]') AND type in (N'U'))
DROP TABLE [dbo].[RAW_DBA_DiskInfo]
GO
CREATE TABLE [dbo].[RAW_DBA_DiskInfo](
	[DateTime] DateTime NULL,
	[DeviceID] [Char](2) NULL,
	[Size] [bigint] NULL,
	[FreeSpace] [bigint] NULL,
	[Description] [varchar](1000) NULL,
	[VolumeSerialNumber] [varchar](1000) NULL,
	[FileSystem] [varchar](10) NULL,
	[Compressed] [varchar](10) NULL,
	[SupportsFileBasedCompression] [varchar](10) NULL,
	[SupportsDiskQuotas] [varchar](10) NULL,
	[QuotasDisabled] [varchar](10) NULL,
	[QuotasIncomplete] [varchar](10) NULL,
	[QuotasRebuilding] [varchar](10) NULL,
	[VolumeDirty] [varchar](10) NULL,
	[VolumeName] [varchar](1000) NULL,
	[PNPDeviceID] [varchar](1000) NULL,
	[Model] [varchar](1000) NULL,
	[Caption] [varchar](1000) NULL
	,[SAN] AS CASE
				WHEN [PNPDeviceID] LIKE '%VEN_EMC%'				THEN 'True'
				WHEN [PNPDeviceID] LIKE '%Multi-Path%'			THEN 'True'
				WHEN LEFT([PNPDeviceID],4) IN ('SCSI','IDE\')	THEN 'False' 
				ELSE 'True' END
) ON [PRIMARY]
GO

 
-- PAIN IN THE ASS !! EXPORTED CSV HAS QUOTES SO FORMAT FILE IS NEEDED TO REMOVE THEM
DECLARE @FileText	VarChar(MAX)
SET		@FileText	=
'9.0
20
1       SQLCHAR       0       1       ""           0     ExtraField          		       ""
2       SQLCHAR       0       1000    "\",\""      1     DateTime                          ""
3       SQLCHAR       0       10      "\",\""      2     DeviceID                          ""
4       SQLCHAR       0       1000    "\",\""      3     Size                              ""
5       SQLCHAR       0       1000    "\",\""      4     FreeSpace                         ""
6       SQLCHAR       0       1000    "\",\""      5     Description                       ""
7       SQLCHAR       0       1000    "\",\""      6     VolumeSerialNumber                ""
8       SQLCHAR       0       10      "\",\""      7     FileSystem                        ""
9       SQLCHAR       0       10      "\",\""      8     Compressed                        ""
10      SQLCHAR       0       10      "\",\""      9     SupportsFileBasedCompression      ""
11      SQLCHAR       0       10      "\",\""      10    SupportsDiskQuotas                ""
12      SQLCHAR       0       10      "\",\""      11    QuotasDisabled                    ""
13      SQLCHAR       0       10      "\",\""      12    QuotasIncomplete                  ""
14      SQLCHAR       0       10      "\",\""      13    QuotasRebuilding                  ""
15      SQLCHAR       0       10      "\",\""      14    VolumeDirty                       ""
16      SQLCHAR       0       1000    "\",\""      15    VolumeName                        ""
17      SQLCHAR       0       1000    "\",\""      16    PNPDeviceID                       ""
18      SQLCHAR       0       1000    "\",\""      17    Model                             ""
19      SQLCHAR       0       1000    "\""         18    Caption                           ""
20      SQLCHAR       0       1       "\r\n"       0     ExtraField                        ""'

EXECUTE [dbaadmin].[dbo].[dbasp_FileAccess_Write] 
   @FileText
  ,'c:\'
  ,'RAW_DBA_DiskInfo.fmt'
  ,0

-- REBUILD PS1 FILE
DECLARE @PowershellScript	VarChar(MAX)
SET		@PowershellScript	= 
'Get-WMIObject Win32_LogicalDisk | Foreach-Object { 
$DeviceID=$_.DeviceID 
$Size=$_.Size 
$FreeSpace=$_.FreeSpace 
$Description=$_.Description
$VolumeSerialNumber=$_.VolumeSerialNumber
$FileSystem=$_.FileSystem
$Compressed=$_.Compressed
$SupportsFileBasedCompression=$_.SupportsFileBasedCompression
$SupportsDiskQuotas=$_.SupportsDiskQuotas
$QuotasDisabled=$_.QuotasDisabled
$QuotasIncomplete=$_.QuotasIncomplete
$QuotasRebuilding=$_.QuotasRebuilding
$VolumeDirty=$_.VolumeDirty
$VolumeName=$_.VolumeName 
$_.GetRelated("Win32_DiskPartition") | Foreach-Object { 
$_.GetRelated("Win32_DiskDrive") 
} 
} | Select-Object @{n="DateTime";e={get-date}},@{n="DeviceID";e={$DeviceID}},@{n="Size";e={$Size}},@{n="FreeSpace";e={$FreeSpace}},@{n="Description";e={$Description}},@{n="VolumeSerialNumber";e={$VolumeSerialNumber}},@{n="FileSystem";e={$FileSystem}},@{n="Compressed";e={$Compressed}},@{n="SupportsFileBasedCompression";e={$SupportsFileBasedCompression}},@{n="SupportsDiskQuotas";e={$SupportsDiskQuotas}},@{n="QuotasDisabled";e={$QuotasDisabled}},@{n="QuotasIncomplete";e={$QuotasIncomplete}},@{n="QuotasRebuilding";e={$QuotasRebuilding}},@{n="VolumeDirty";e={$VolumeDirty}},@{n="VolumeName";e={$VolumeName}},PNPDeviceID,Model,Caption | Export-CSV -Path "c:\RAW_DBA_DiskInfo.csv" -NoTypeInformation'

EXECUTE [dbaadmin].[dbo].[dbasp_FileAccess_Write] 
   @PowershellScript
  ,'c:\'
  ,'RAW_DBA_DiskInfo.ps1'
  ,0


--EXECUTE POWERSHELL SCRIPT
EXEC master..xp_CmdShell 'Powershell -Command "Set-ExecutionPolicy RemoteSigned"'--, no_output 


--EXECUTE POWERSHELL SCRIPT
EXEC master..xp_CmdShell 'Powershell -File "c:\RAW_DBA_DiskInfo.ps1"'--, no_output 


--MAKE SURE FILE HANDLES HAVE BEEN RELEASED
waitfor delay '00:00:05'


--IMPORT DATA
BULK INSERT dbaadmin.dbo.RAW_DBA_DiskInfo
FROM 'c:\RAW_DBA_DiskInfo.csv'
WITH
(
FORMATFILE = 'c:\RAW_DBA_DiskInfo.fmt',
FIRSTROW = 2
)


----SHOW DATA
--SELECT * FROM [dbo].[RAW_DBA_DiskInfo]
--GO


SELECT		DISTINCT
			P1.[DeviceID]
			--,CASE P1.[SAN] When 'true' then Replace(P1.[Description],'Local','SAN') ELSE P1.[Description] END [Description]
			--,P1.[SAN]
			--,CASE WHEN P3.DriveName IS NOT NULL THEN 'True' ELSE 'False' END [ClusterShared]
			,CAST(p1.Size AS FLOAT)/1024/1024/1000			GB_DiskSize
			,CAST(p1.FreeSpace AS FLOAT)/1024/1024/1000		GB_DiskFreeSpace
			,((CAST(p1.Size AS FLOAT)/1024/1024)
			 -(CAST(p1.FreeSpace AS FLOAT)/1024/1024))/1000	GB_DiskUsed
			 
			,COALESCE(SIZ.DBUsed,0)/1000					GB_DBSpaceUsed
			,(((CAST(p1.Size AS FLOAT)
				-CAST(p1.FreeSpace AS FLOAT))							
				/1024/1024)-COALESCE(SIZ.DBUsed,0))/1000	GB_OtherSpaceUsed




			--,(CAST(p1.FreeSpace AS FLOAT)*100)
			--	/(CAST(p1.Size AS FLOAT)+.00001)	PCT_DiskFreeSpace
			--,DTA.DBNames							DBsData
			--,LOG.DBNames							DBsLog
			--,FTX.DBNames							DBsFullText
			--,p1.*
FROM		[dbaadmin].[dbo].[RAW_DBA_DiskInfo] p1
LEFT JOIN	fn_servershareddrives() p3
		ON	LEFT(P1.DeviceID COLLATE SQL_Latin1_General_CP1_CI_AS ,1) = P3.DriveName COLLATE SQL_Latin1_General_CP1_CI_AS
CROSS APPLY (
			SELECT			DISTINCT DB_NAME(p2.database_id) + ',' 
			FROM			[master].[sys].[master_files] p2
			WHERE			UPPER(LEFT(P2.physical_name,1))+':' = P1.DeviceID
					AND		p2.type_desc = 'LOG'
			ORDER BY		1 
			FOR XML PATH('') 
			)LOG(DBNames)
CROSS APPLY (
			SELECT			DISTINCT DB_NAME(p2.database_id) + ',' 
			FROM			[master].[sys].[master_files] p2
			WHERE			UPPER(LEFT(P2.physical_name,1))+':' = P1.DeviceID
					AND		p2.type_desc = 'ROWS'
			ORDER BY		1 
			FOR XML PATH('') 
			)DTA(DBNames)
CROSS APPLY (
			SELECT			DISTINCT DB_NAME(p2.database_id) + ',' 
			FROM			[master].[sys].[master_files] p2
			WHERE			UPPER(LEFT(P2.physical_name,1))+':' = P1.DeviceID
					AND		p2.type_desc = 'FULLTEXT'
			ORDER BY		1 
			FOR XML PATH('') 
			)FTX(DBNames)			

CROSS APPLY	(
			select			SUM((CAST(p2.Size AS FLOAT)*(8*1024))/1024/1024)
			FROM			[master].[sys].[master_files] p2
			WHERE			UPPER(LEFT(P2.physical_name,1))+':' = P1.DeviceID
			) SIZ(DBUsed)

WHERE		P1.[SAN] = 'True'
ORDER BY	1

GO

 
