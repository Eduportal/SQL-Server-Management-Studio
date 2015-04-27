--DECLARE @cmd nVarChar(4000)

----  Capture SAN flag
----delete from #temp_tbl1
--Select @cmd = 'iscsicli ListTargets'
----insert #temp_tbl1(text01) 
--exec master.sys.xp_cmdshell @cmd
----Delete from #temp_tbl1 where text01 is null or text01 = ''''
----select * from #temp_tbl1

----If exists (select 1 from #temp_tbl1 where text01 like ''%Powerpath%'' or text01 like ''%RDAC%'' or text01 like ''%HSV110%'' or text01 like ''%FAStT%'' or text01 like ''%Multi-Path%'')
----   begin
----	Select @save_SAN_flag = ''y''
----   end 
   
   
----GO

----SELECT * FROM [dbaadmin].[dbo].[dbaudf_ListDrives]() WHERE IsReady = 'True'

----GO

----DECLARE @object int 
----DECLARE @Service int 
----DECLARE @ServiceName varchar(40) 
----DECLARE @command varchar(255) 
----DECLARE @hr int 
----DECLARE @property varchar(255) 
----DECLARE @return varchar(255) 
----DECLARE @src varchar(255), @desc varchar(255) 
----DECLARE @output varchar(255) 
----DECLARE @source varchar(255) 
----DECLARE @description varchar(255) 
----DECLARE @Computer varchar(50) 
----EXEC @hr = sp_OACreate 'wbemScripting.SwbemLocator', @object OUT 
----IF @hr <> 0 
----BEGIN 
----  EXEC @hr = sp_OAGetErrorInfo @object, @source OUT, @description OUT 
----  IF @hr = 0 
----  BEGIN 
----     SELECT @output = ' Description: ' + @description 
----     PRINT @output 
----  END 
----END 
----EXEC @hr = sp_OASetProperty @object, 'Security_.ImpersonationLevel', 1 
----IF @hr <> 0 
----BEGIN 
----  EXEC @hr = sp_OAGetErrorInfo @object, @source OUT, @description OUT 
----  IF @hr = 0 
----  BEGIN 
----     SELECT @output = 'Security Error: ' + @description 
----     PRINT @output 
----  END 
----END 
----EXEC @hr = sp_OAMethod @object, 'ConnectServer', @Service OUT, '.', 
----'root\cimv2' 


----IF @hr <> 0 
----BEGIN 
----  EXEC @hr = sp_OAGetErrorInfo @object, @source OUT, @description OUT 
----  IF @hr = 0 
----  BEGIN 
----     SELECT @output = 'Service Error: ' + @description 
----     PRINT @output 
----  END 
----END 


----select @command = '"SELECT DriveType from Win32_LogicalDisk"'
----CREATE TABLE #tmpServicesList (ServiceName VARCHAR(255)) 
----INSERT INTO #tmpServicesList 
----EXEC @hr = sp_OAMethod @object, @Command 


----IF @hr <> 0 
----BEGIN 
----  EXEC @hr = sp_OAGetErrorInfo @object, @source OUT, @description OUT 
----  IF @hr = 0 
----  BEGIN 
----     SELECT @output = 'SQL Error: ' + @description 
----     PRINT @output 
----  END 
----END 


----select * from #tmpServicesList 
----drop table #tmpServicesList 






----GO


--exec xp_cmdshell 'echo delim = chr(9) >  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'echo Set objWMIService = GetObject(^"winmgmts:\\.^") >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'echo Set colItems = objWMIService.ExecQuery(^"SELECT * FROM CIM_LogicalDiskBasedOnPartition ^",,48) >>  %tmp%\wmi_disks.vbs', no_output 
--exec xp_cmdshell 'echo For Each objItem in colItems >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'echo WScript.Echo objItem.Antecedent   >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'echo Next >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'cscript  %tmp%\wmi_disks.vbs //nologo'
--exec xp_cmdshell 'del  %tmp%\wmi_disks.vbs', no_output


--GO

--SELECT * FROM dbaadmin.[dbo].[dbaudf_ListDrives]()


--exec xp_cmdshell 'echo delim = chr(9) >  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'echo Set objWMIService = GetObject(^"winmgmts:\\.^") >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'echo Set DriveItems = objWMIService.ExecQuery(^"SELECT * FROM win32_diskdrive ^",,48) >>  %tmp%\wmi_disks.vbs', no_output 
--exec xp_cmdshell 'echo For Each DriveItem in DriveItems >>  %tmp%\wmi_disks.vbs', no_output

--exec xp_cmdshell ' echo Set PartItems = DriveItem.GetRelated(^"win32_DiskPartition^") >>  %tmp%\wmi_disks.vbs', no_output 
--exec xp_cmdshell ' echo For Each PartItem in PartItems >>  %tmp%\wmi_disks.vbs', no_output

--exec xp_cmdshell '  echo Set DiskItems = PartItem.GetRelated(^"win32_LogicalDisk^") >>  %tmp%\wmi_disks.vbs', no_output 
--exec xp_cmdshell '  echo For Each DiskItem in DiskItems >>  %tmp%\wmi_disks.vbs', no_output




--exec xp_cmdshell '   echo WScript.Echo DriveItem.Name   >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell '   echo WScript.Echo DiskItem.Name   >>  %tmp%\wmi_disks.vbs', no_output

--exec xp_cmdshell '  echo Next >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell ' echo Next >>  %tmp%\wmi_disks.vbs', no_output
--exec xp_cmdshell 'echo Next >>  %tmp%\wmi_disks.vbs', no_output

--exec xp_cmdshell 'cscript  %tmp%\wmi_disks.vbs //nologo'
--exec xp_cmdshell 'del  %tmp%\wmi_disks.vbs', no_output

GO
USE [dbaadmin]
GO

/****** Object:  UserDefinedFunction [dbo].[ReturnPart]    Script Date: 09/21/2010 10:29:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReturnPart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE   FUNCTION [dbo].[ReturnPart]  
    (@String VarChar(8000),  
     @WordNumber int) 
RETURNS VarChar(50) 
AS 
BEGIN 
If    @WordNumber < 1 
    Return '''' 
IF CHARINDEX(''|'', @String, 1) = 0  
    BEGIN 
        IF @WordNumber = 1 
            RETURN @String 
        ELSE 
            Return '''' 
    END 
SET    @String = LTRIM(RTRIM(@String)) 
IF      @String = '''' 
        RETURN '''' 
IF @WordNumber = 1 
        RETURN SUBSTRING(@String, 1, CHARINDEX(''|'', @String, 1) - 1) 
WHILE @WordNumber > 1 
    BEGIN 
        IF CHARINDEX(''|'', @String, 1) = 0 
            Return '''' 
          SET @String = SUBSTRING(@String,  CHARINDEX(''|'', @String, 1) + 1, LEN(@String) - CHARINDEX(''|'', @String, 1)) 
        SET @WordNumber = @WordNumber - 1     
    END 
IF CHARINDEX(''|'', @String, 1) = 0  
    RETURN @String 
RETURN SUBSTRING(@String, 1, CHARINDEX(''|'', @String, 1) - 1) 
END 

' 
END

GO































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
					WHEN DriveInfo Like '%PowerPath%'	THEN 1
					--WHEN DriveInfo Like '%PowerPath%'	THEN 1
					--WHEN DriveInfo Like '%PowerPath%'	THEN 1
					--WHEN DriveInfo Like '%PowerPath%'	THEN 1
					--WHEN DriveInfo Like '%PowerPath%'	THEN 1
					ELSE 0 
				END

SELECT		*
FROM		#DiskInfo2


GO
DROP TABLE	#DiskInfo1
GO
DROP TABLE	#DiskInfo2
GO