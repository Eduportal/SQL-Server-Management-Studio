
DECLARE @Results TABLE
                 (
                    Value   NVARCHAR (100),
                    Data    NVARCHAR (100)
                 )

-- THIS MAKES SURE THAT THE Software\GettyImages\Script\DiskMonitor BRANCH EXISTS
EXEC[sys].[xp_instance_regwrite] N'HKEY_LOCAL_MACHINE',N'Software\GettyImages\Script\DiskMonitor','XX','reg_sz','0'
EXEC[sys].[xp_instance_regdeletevalue] N'HKEY_LOCAL_MACHINE',N'Software\GettyImages\Script\DiskMonitor','XX'

-- GET DISK ALERT OVERRIDES AT Software\GettyImages\Script\DiskMonitor
INSERT INTO @Results 
EXEC [sys].[xp_instance_regenumvalues] N'HKEY_LOCAL_MACHINE',N'Software\GettyImages\Script\DiskMonitor'

-- MAIN QUERY
SELECT		COALESCE(DriveLetter, LEFT(RootFolder,2)) DriveLetter
		,RootFolder
		,VolumeName
		,CASE	WHEN T2.Data = 0 THEN 0
			WHEN PercentUsed >= COALESCE (T2.Data, 90) THEN 1
			ELSE 0
			END [Alert]	
		,dbaadmin.dbo.dbaudf_FormatBytes(TotalSize,'Bytes') TotalSize
		,dbaadmin.dbo.dbaudf_FormatBytes(TotalSize-FreeSpace,'Bytes') UsedSpace
		,dbaadmin.dbo.dbaudf_FormatBytes(FreeSpace,'Bytes') FreeSpace
		,CAST(PercentUsed AS NUMERIC(10,2)) PercentUsed
		,UseChart
		,T2.Data PercentFullOverride
		,DriveType	
		,FileSystem	
		,IsReady	
FROM		dbaadmin.dbo.dbaudf_ListDrives() T1
LEFT JOIN	@Results T2
       ON	CAST (T1.DriveLetter AS CHAR (1)) = CAST (T2.Value AS CHAR (1))
       AND	isnumeric(T2.Data) = 1	-- Try to exclude other registry entries that are not simply the override value
       AND	LEN(T2.Value) <= 2	-- ALLOW FOR "X" or "X:"
order by	RootFolder




select * From dbaadmin.dbo.dbaudf_ListShares() 

select * From dbaadmin.dbo.dbaudf_ListClusterResource() 
UNION ALL
select * From dbaadmin.dbo.dbaudf_ListClusterNode()
UNION ALL
select * From dbaadmin.dbo.dbaudf_ListClusterNetwork()
UNION ALL
select * From dbaadmin.dbo.dbaudf_ListClusterNetworkInterface()

ORDER BY	1,5,2,3



SELECT	[dbaadmin].[dbo].[dbaudf_GetFileProperty]('C:\Temp\test2\test.txt','file','RootFolder')
	,[dbaadmin].[dbo].[dbaudf_GetFileProperty]('C:\testmp\test2\test.txt','file','RootFolder')


SELECT		*
FROM		dbaadmin.dbo.dbaudf_DirectoryList2('c:\',NULL,1)

SELECT		[dbaadmin].[dbo].[dbaudf_GetFileProperty](FullPathName,'file','RootFolder')
		,COUNT(*)
		,SUM(Size)
FROM		dbaadmin.dbo.dbaudf_DirectoryList2('c:\',NULL,1)
GROUP BY	[dbaadmin].[dbo].[dbaudf_GetFileProperty](FullPathName,'file','RootFolder')



SELECT	[dbaadmin].[dbo].[dbaudf_GetFileProperty]('C:\MSSQL\data\20140819142304_Getty_Images_US_Inc__MSCRM.mdf','file','RootFolder')
SELECT	[dbaadmin].[dbo].[dbaudf_GetFileProperty]('C:\MSSQL\Log\20140819142304_Getty_Images_US_Inc__MSCRM_log.LDF','file','RootFolder')
SELECT	[dbaadmin].[dbo].[dbaudf_GetFileProperty]('C:\testmp\MSSQL\data\20140819142304_Getty_Images_US_Inc__MSCRM3.ndf','file','RootFolder')
SELECT	[dbaadmin].[dbo].[dbaudf_GetFileProperty]('D:\MSSQL\data\20140819142304_Getty_Images_US_Inc__MSCRM5.ndf','file','RootFolder')
SELECT	[dbaadmin].[dbo].[dbaudf_GetFileProperty]('D:\MSSQL\data\20140819142304_Getty_Images_US_Inc__MSCRM6.ndf','file','RootFolder')




SELECT		FreeSpace
FROM		dbaadmin.dbo.dbaudf_ListDrives()
WHERE		RootFolder = [dbaadmin].[dbo].[dbaudf_GetFileProperty]('C:\testmp\test2\test2.txt','file','RootFolder')


SELECT		FreeSpace
FROM		dbaadmin.dbo.dbaudf_ListDrives()
WHERE		RootFolder = [dbaadmin].[dbo].[dbaudf_GetFileProperty]('C:\Temp\test2\test2.txt','file','RootFolder')