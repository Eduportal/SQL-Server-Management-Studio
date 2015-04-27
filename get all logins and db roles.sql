SELECT SP1.[name] AS 'Login', SP2.[name] AS 'ServerRole'
FROM sys.server_principals SP1
JOIN sys.server_role_members SRM
ON SP1.principal_id = SRM.member_principal_id
JOIN sys.server_principals SP2
ON SRM.role_principal_id = SP2.principal_id
ORDER BY SP1.[name], SP2.[name];

select * FROM sys.server_principals 
select * from sysusers





CREATE TABLE #DBROLES 
( 
LoginName sysname not null, 
UserName sysname not null, 
DBName sysname not null, 
DB_Role sysname not null
)
GO
exec sp_msforeachdb ' Insert into #DBROLES select sp.name, b.name,''?'',c.name from sys.server_principals sp join ?.dbo.sysusers b on sp.sid = b.sid join ?.dbo.sysmembers a on a.memberuid = b.uid join ?.dbo.sysusers c on a.groupuid = c.uid' 
GO
Select * from #DBROLES ORDER BY 1,2,3,4
GO
Drop Table #DBROLES
GO