SET NOCOUNT ON;

IF (OBJECT_ID('tempdb..#ExecOutput'))	IS NOT NULL	DROP TABLE #ExecOutput
CREATE	TABLE	#ExecOutput			([rownum] int identity primary key,[TextOutput] VARCHAR(8000));


INSERT INTO #ExecOutput([TextOutput])
exec xp_cmdshell 'netsh int tcp show global'

SELECT		CASE	LTRIM(RTRIM(parsename(REPLACE([TextOutput],':','.'),1)))
				WHEN 'disabled' THEN 0
				WHEN 'enabled' THEN 1
				WHEN 'automatic' THEN 2
				ELSE -1 END
FROM		#ExecOutput
WHERE		LTRIM(RTRIM(parsename(REPLACE([TextOutput],':','.'),2)))	 = 'Chimney Offload State'	

DROP TABLE	#ExecOutput	
