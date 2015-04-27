USE dbaadmin
GO
IF OBJECT_ID('dbo.dbaudf_GetServerClass') IS NOT NULL
	DROP FUNCTION dbo.dbaudf_GetServerClass
GO	
CREATE FUNCTION dbo.dbaudf_GetServerClass
			(
			@SQLName sysname = NULL
			)
Returns		SYSNAME
AS
BEGIN
	DECLARE	@ServerClass SYSNAME
	
	SET	@SQLName = ISNULL(NULLIF(@SQLName,''),@@SERVERNAME)
	
	IF @SQLName IN 
		(SELECT DISTINCT SQLName FROM dbo.DBA_DBInfo 
		WHERE [SQLName] IN ('SQLDEPLOYER01','SQLDEPLOYER02','SQLDEPLOYER04','SQLDEPLOYER05','')
		OR	(([status]='ONLINE' OR [Mirroring]='y') --AND [ENVname]='Production'
		AND ([SQLName] NOT IN ('SEAPSQLRPT01','','','','') 
		AND (([DEPLstatus]='y' AND Appl_Desc IN	('Barbarian/Moodstream'
												,'Bundle'
												,'Channel Feeds'
												,'CRM'
												,'ED'
												,'EF'
												,'Gestalt'
												,'Legacy Commerce Service'
												,'Legacy Creative'
												,'Legacy Delivery'
												,'Legacy HardGoods'
												,'PumpAudio'
												,'Search Data Tools (AKS, MRT)'
												,'Search Data Tools (VMT)'
												,'SSL Tool Manager'
												,'Transcoder (Rhozet)'
												,'UNAdatabases'
												,'Varicent'
												,'WebVision Newsmaker'))
			OR Appl_Desc IN	('DEWDS (Picture Desk)','OpsCentral')))))
		SET	@ServerClass = 'High'
	ELSE
		SET	@ServerClass = 'Normal'
	
	RETURN @ServerClass																			 
END
GO

PRINT 'Current Server Class is ' + dbo.dbaudf_GetServerClass(DEFAULT)
GO