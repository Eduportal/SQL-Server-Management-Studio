CREATE	TABLE		#DiskInfo1(DiskEntry VarChar(8000))
CREATE	TABLE		#DiskInfo2(DriveLetter VarChar(2), DriveInfo VarChar(8000), IsSAN bit default (0))


DECLARE @RC		int
DECLARE @Path		varchar(1024)
DECLARE @Filename	varchar(1024)
DECLARE	@Script		VarChar(8000)
SET	@Path		= 'c:'
SET	@Filename	= 'wmi_disks.vbs'
SET	@Script		= 
'ComputerName = "."
Set wmiServices = GetObject _
    ("winmgmts:{impersonationLevel=Impersonate}!//" & ComputerName)
Set wmiDiskDrives = wmiServices.ExecQuery _
    ("SELECT Caption, DeviceID FROM Win32_DiskDrive")
 
For Each wmiDiskDrive In wmiDiskDrives
    ''WScript.Echo wmiDiskDrive.Caption & " (" & wmiDiskDrive.DeviceID & ")"
    strEscapedDeviceID = _
        Replace(wmiDiskDrive.DeviceID, "\", "\\", 1, -1, vbTextCompare)
    Set wmiDiskPartitions = wmiServices.ExecQuery _
        ("ASSOCIATORS OF {Win32_DiskDrive.DeviceID=""" & _
            strEscapedDeviceID & """} WHERE " & _
                "AssocClass = Win32_DiskDriveToDiskPartition")
    For Each wmiDiskPartition In wmiDiskPartitions
        ''WScript.Echo vbTab & wmiDiskPartition.DeviceID
        Set wmiLogicalDisks = wmiServices.ExecQuery _
            ("ASSOCIATORS OF {Win32_DiskPartition.DeviceID=""" & _
                wmiDiskPartition.DeviceID & """} WHERE " & _
                    "AssocClass = Win32_LogicalDiskToPartition")
        For Each wmiLogicalDisk In wmiLogicalDisks
            WScript.Echo wmiLogicalDisk.Caption & "|" & wmiDiskDrive.Caption
        Next
    Next
Next'

EXECUTE @RC = [dbaadmin].[dbo].[dbasp_FileAccess_Write] 
   @Script
  ,@Path
  ,@Filename

SET	@Script		= 'cscript  ' + @Path + '\' + @Filename + ' //nologo'
INSERT INTO #DiskInfo1(DiskEntry)
exec xp_cmdshell @Script

SET	@Script		= 'del  ' + @Path + '\' + @Filename
exec xp_cmdshell @Script, no_output

DELETE		#DiskInfo1
WHERE		DiskEntry IS NULL

SELECT		*
FROM		#DiskInfo1

INSERT INTO	#DiskInfo2(DriveLetter,DriveInfo)
SELECT		[dbaadmin].[dbo].[ReturnPart] (DiskEntry,1)
		,[dbaadmin].[dbo].[ReturnPart] (DiskEntry,2)
FROM		#DiskInfo1


UPDATE		#DiskInfo2
	SET	DriveLetter	= LEFT(DriveLetter,1)
		,IsSAN		= CASE
					WHEN DriveInfo Like '%SCSI%'	THEN 0
					WHEN DriveInfo Like '%SATA%'	THEN 0
					WHEN DriveInfo Like '%IDE%'	THEN 0
					ELSE 1
				END

SELECT		*
FROM		#DiskInfo2


GO
DROP TABLE	#DiskInfo1
GO
DROP TABLE	#DiskInfo2
GO