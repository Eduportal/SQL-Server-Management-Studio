/*The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages */

--Server level Logins and roles
SELECT sp.name AS LoginName,sp.type_desc AS LoginType, sp.default_database_name AS DefaultDBName,slog.sysadmin AS SysAdmin,slog.securityadmin AS SecurityAdmin,slog.serveradmin AS ServerAdmin, slog.setupadmin AS SetupAdmin, slog.processadmin AS ProcessAdmin, slog.diskadmin AS DiskAdmin, slog.dbcreator AS DBCreator,slog.bulkadmin AS BulkAdmin
FROM sys.server_principals sp  JOIN master..syslogins slog
ON sp.sid=slog.sid 
WHERE sp.type  <> 'R' AND sp.name NOT LIKE '##%'

DECLARE @Obj VARCHAR(4000)
DECLARE @T_Obj TABLE (UserName SYSNAME, ObjectName SYSNAME, Permission NVARCHAR(128))
SET @Obj='
SELECT Us.name AS username, Obj.name AS object,  dp.permission_name AS permission 
FROM sys.database_permissions dp
JOIN sys.sysusers Us 
ON dp.grantee_principal_id = Us.uid 
JOIN sys.sysobjects Obj
ON dp.major_id = Obj.id '
INSERT @T_Obj 
EXEC sp_MSforeachdb @Obj
SELECT * FROM @T_Obj 
