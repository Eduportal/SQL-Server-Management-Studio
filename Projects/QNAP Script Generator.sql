SET NOCOUNT ON

Declare		@QnapRoot		VarChar(max)
			,@Path			VarChar(max)

SET			@QnapRoot		= '\\10.207.131.20\sqldata' --sql\admin
--SET			@QnapRoot		= '\\10.206.48.21\sqldata' --sql\admin

DECLARE		@DriveData		TABLE
	(
	[MachineName] [nvarchar](100) NULL,
	[InstanceName] [nvarchar](4000) NOT NULL,
	[DriveLetter] [char](1) NULL,
	[ClusterDependancy] [varchar](1) NOT NULL,
	[VolumeName] [varchar](255) NULL,
	[TotalSize_GB] [varchar](50) NULL,
	[UsedSpace_GB] [varchar](50) NULL,
	[FreeSpace_GB] [varchar](50) NULL,
	[PercentFree] [varchar](50) NULL,
	[GAGUE] [varchar](10) NULL,
	[DriveType] [varchar](50) NULL,
	[SerialNumber] [varchar](50) NULL,
	[FileSystem] [varchar](50) NULL
	)

INSERT INTO	@DriveData
select      convert(nvarchar(100), serverproperty('machinename')) [MachineName]
			,isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'') [InstanceName]
			,DriveLetter
			, CASE WHEN T2.DriveName Is Null Then 'N' ELSE 'Y' END [ClusterDependancy] 
			,VolumeName 
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] (TotalSize/1024.00/1024.00/1024.00,10,2)              [TotalSize_GB]
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] ((TotalSize-FreeSpace)/1024.00/1024.00/1024.00,10,2)  [UsedSpace_GB]
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] (FreeSpace/1024.00/1024.00/1024.00,10,2)              [FreeSpace_GB]
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] ((FreeSpace * 100.00)/(TotalSize+1),10,2)             [PercentFree]
			, RIGHT(REPLICATE('H',10)+REPLICATE('O',((FreeSpace * 100)/(TotalSize+1))/10),10)             [GAGUE]
			,DriveType  
			,SerialNumber     
			,FileSystem
From		dbaadmin.dbo.dbaudf_ListDrives() T1
LEFT JOIN	sys.dm_io_cluster_shared_drives T2
	ON		T1.DriveLetter = T2.DriveName
WHERE IsReady = 'true'

PRINT	'REM  START OF BACKUP CODE'
PRINT	''
SET		@Path	= @QnapRoot 
				+ '\' 
				+ convert(nvarchar(100), serverproperty('machinename'))
				+ isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')

SELECT		'MD ' + @Path + '\' + DriveLetter
FROM		@DriveData
WHERE		DriveLetter NOT IN ('C')


SELECT		'start robocopy ' + DriveLetter + ': ' + @Path + '\' + DriveLetter + ' /Z /FFT /E /R:0 /XD "system volume information"'
FROM		@DriveData
WHERE		DriveLetter NOT IN ('C')

PRINT	''
PRINT	'REM  END OF BACKUP CODE'
PRINT	''

PRINT	''
PRINT	'REM  START OF RESTORE CODE'
PRINT	''

SELECT		'start robocopy ' + @Path + '\' + DriveLetter + ' ' + DriveLetter + ': /Z /FFT /E /R:0 /XD "system volume information"'
FROM		@DriveData
WHERE		DriveLetter NOT IN ('C')