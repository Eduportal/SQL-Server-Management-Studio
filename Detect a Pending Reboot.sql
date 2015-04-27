DECLARE @PendingReboot	CHAR(1)
DECLARE @Results	TABLE
			(
			KeyValue	NVARCHAR(100),
			Value		NVARCHAR(100),
			Data		NVARCHAR(100)
			)
INSERT INTO @Results
EXEC [sys].[xp_instance_regRead] N'HKEY_LOCAL_MACHINE',N'SYSTEM\CurrentControlSet\Control\Session Manager',N'PendingFileRenameOperations'

IF EXISTS (SELECT * FROM @Results WHERE KeyValue Like 'PendingFileRenameOperations%' AND Value IS NOT NULL)
	SET @PendingReboot = 'Y'
ELSE
	SET @PendingReboot = 'N'

SELECT	@PendingReboot [PendingReboot]	
GO