

USE [dbaadmin]
GO
ALTER FUNCTION [dbo].[dbaudf_getShareUNC](@ShareName VarChar(255))
returns VarChar(2000)
as
begin
    return '\\' + LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1)) + '\' 
		+ REPLACE	(
				CASE	WHEN @ShareName LIKE '%builds' 
					  THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					WHEN @ShareName LIKE '%dba_mail' 
					  THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					ELSE REPLACE(@@SERVERNAME,'\','$') END	+'_'+@ShareName
				,CASE	WHEN @ShareName LIKE '%builds' 
					  THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					WHEN @ShareName LIKE '%dba_mail' 
					  THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					ELSE REPLACE(@@SERVERNAME,'\','$') END +'_'
				+CASE	WHEN @ShareName LIKE '%builds' 
					THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					WHEN @ShareName LIKE '%dba_mail' 
					THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					ELSE REPLACE(@@SERVERNAME,'\','$') END
				,CASE	WHEN @ShareName LIKE '%builds' 
					THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					WHEN @ShareName LIKE '%dba_mail' 
					THEN LEFT(@@SERVERNAME,(CHARINDEX('\',@@SERVERNAME+'\')-1))
					ELSE REPLACE(@@SERVERNAME,'\','$')END
				)
end
GO


