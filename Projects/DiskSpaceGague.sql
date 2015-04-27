select		DriveLetter
			,VolumeName	
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] (TotalSize/1024.00/1024.00/1024.00,10,2)				TotalSize_GB
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] ((TotalSize-FreeSpace)/1024.00/1024.00/1024.00,10,2)	UsedSpace_GB
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] (FreeSpace/1024.00/1024.00/1024.00,10,2)				FreeSpace_GB
			,[dbaadmin].[dbo].[dbaudf_FormatNumber] ((FreeSpace * 100.00)/(TotalSize+1),10,2)				PercentFree
			, RIGHT(REPLICATE('H',10)+REPLICATE('O',((FreeSpace * 100)/(TotalSize+1))/10),10)					GAGUE
			,DriveType	
			,SerialNumber	
			,FileSystem	
From dbaadmin.dbo.dbaudf_ListDrives()
WHERE IsReady = 'true'


SELECT *
From dbaadmin.dbo.dbaudf_ListDrives()

