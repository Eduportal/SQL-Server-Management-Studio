USE [dbaadmin]
GO

DECLARE @FileText	VarChar(max)
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
  ,'DBA_Diskinfo_RAW.fmt'
  ,0
GO
waitfor delay '00:00:15'
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DBA_DiskInfo_RAW]') AND type in (N'U'))
DROP TABLE [dbo].[DBA_DiskInfo_RAW]
GO
CREATE TABLE [dbo].[DBA_DiskInfo_RAW](
	[DateTime] DateTime NULL,
	[DeviceID] [char](2) NULL,
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
	,[SAN] AS CASE WHEN LEFT([PNPDeviceID],4) != 'SCSI' THEN 'True' ELSE 'False' END
) ON [PRIMARY]
GO
BULK INSERT dbaadmin.dbo.DBA_DiskInfo_RAW
FROM 'c:\DBA_DiskInfo_RAW.csv'
WITH
(
FORMATFILE = 'c:\DBA_DiskInfo_RAW.fmt',
FIRSTROW = 2
)
GO
SELECT * FROM [dbo].[DBA_DiskInfo_RAW]
GO
