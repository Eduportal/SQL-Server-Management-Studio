USE [dbaadmin]
GO

SELECT * FROM [dbo].[headers] ('\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup\StackFactors_db_20130920170143.cBAK')
GO				


RESTORE HEADERONLY FROM DISK = N'\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup\StackFactors_db_20130920170143.cBAK'





	SELECT		*
	FROM		dbaadmin.dbo.dbaudf_DirectoryList2(N'\\SEAPSDTSQLB\SEAPSDTSQLB$B_backup\','StackFactors_*',0) T1
	CROSS APPLY	dbaadmin.[dbo].[headers](T1.FullPathName) T2
	ORDER BY	T2.BackupStartDate



	StackFactors_db_%
StackFactors_dfntl_%
StackFactors_tlog_%