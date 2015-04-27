

PRINT'Windows Registry Editor Version 5.00'
PRINT''

DECLARE	@SQLName sysname, @Port sysname
DECLARE InstanceCursor 
CURSOR
FOR
select SQLName,Port
FROM	dbacentral.dbo.serverinfo
WHERE	Active = 'Y'
AND	Port != '1433'

OPEN InstanceCursor
FETCH NEXT FROM InstanceCursor INTO @SQLName,@Port
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		PRINT '[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]'+CHAR(13)+CHAR(10)+'"'+REPLACE(@SQLName,'\','\\')+'"="DBMSSOCN,'+REPLACE(@SQLName,'\','\\')+','+@Port+'"'
		PRINT ''
		PRINT '[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\MSSQLServer\Client\ConnectTo]'+CHAR(13)+CHAR(10)+'"'+REPLACE(@SQLName,'\','\\')+'"="DBMSSOCN,'+REPLACE(@SQLName,'\','\\')+','+@Port+'"'
		PRINT ''
	END
	FETCH NEXT FROM InstanceCursor INTO @SQLName,@Port
END

CLOSE InstanceCursor
DEALLOCATE InstanceCursor






