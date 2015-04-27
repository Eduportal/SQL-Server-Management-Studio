SET		NOCOUNT ON


DECLARE		@ServerName	SYSNAME
		,@SQLName	SYSNAME
		,@IPNUM		SYSNAME
		,@CMD		VarChar(8000)
		,@Domain	SYSNAME

DECLARE ServerCursor CURSOR
FOR
SELECT		ServerName
		,SQLName
		,IPnum
		,CASE DomainName
			WHEN 'AMER' THEN '.amer.gettywan.com'
			WHEN 'GYINET' THEN '.gettyimages.net'
			WHEN 'STAGE' THEN '.stage.local'
			WHEN 'PRODUCTION' THEN '.production.local'

			ELSE DomainName END [Domain]
FROM		ServerInfo
WHERE		Active = 'Y'
ORDER BY	4,1,2

-- CREATE TABLE #Results (row VarChar(max)) 

OPEN ServerCursor;
FETCH ServerCursor INTO @ServerName,@SQLName,@IPNUM,@Domain;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		RAISERROR('Checking Server %s',-1,-1,@ServerName) WITH NOWAIT


		SET	@CMD = 'PING ' + @ServerName

		TRUNCATE TABLE #Results
		INSERT INTO #Results
		EXEC xp_CMDShell @CMD

		IF EXISTS(SELECT * FROM #Results WHERE [Row] Like '%could not find host%')			RAISERROR('  ** Server %s Unable to be Pinged By Name **',-1,-1,@ServerName) WITH NOWAIT
		ELSE
			RAISERROR('  Server %s is able to be Pinged By Name',-1,-1,@ServerName) WITH NOWAIT


		SET	@CMD = 'PING ' + @ServerName + @Domain

		TRUNCATE TABLE #Results
		INSERT INTO #Results
		EXEC xp_CMDShell @CMD

		IF EXISTS(SELECT * FROM #Results WHERE [Row] Like '%could not find host%')			RAISERROR('  ** Server %s Unable to be Pinged By FQDN %s **',-1,-1,@ServerName,@Domain) WITH NOWAIT
		ELSE
			RAISERROR('  Server %s is able to be Pinged By FQDN %s',-1,-1,@ServerName,@Domain) WITH NOWAIT



		SET	@CMD = 'PING ' + @IPNUM

		TRUNCATE TABLE #Results
		INSERT INTO #Results
		EXEC xp_CMDShell @CMD

		IF EXISTS(SELECT * FROM #Results WHERE [Row] Like '%could not find host%')			RAISERROR('  ** Server %s Unable to be Pinged By IP %s **',-1,-1,@ServerName,@IPNUM) WITH NOWAIT
		ELSE
			RAISERROR('  Server %s is able to be Pinged By IP %s',-1,-1,@ServerName,@IPNUM) WITH NOWAIT



		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM ServerCursor INTO @ServerName,@SQLName,@IPNUM,@Domain;
END
CLOSE ServerCursor;
DEALLOCATE ServerCursor;







