
SET NOCOUNT ON

--SELECT 
--    USER_NAME(grantee_principal_id) AS 'User'
--  , state_desc AS 'Permission'
--  , permission_name AS 'Action'
--  , CASE class
--      WHEN 0 THEN 'Database::' + DB_NAME()
--      WHEN 1 THEN OBJECT_NAME(major_id)
--      WHEN 3 THEN 'Schema::' + SCHEMA_NAME(major_id) END AS 'Securable'
--FROM sys.database_permissions dp
--WHERE class IN (0, 1, 3)
--AND minor_id = 0
--AND OBJECT_NAME(major_id) IN
--(
--'Individual' 
--,'ProfileIndividualRel' 
--,'Profile'
--,'SCIDomainAccount'
--)





--/*
--Security Audit Report
--1) List all access provisioned to a sql user or windows user/group directly 
--2) List all access provisioned to a sql user or windows user/group through a database or application role
--3) List all access provisioned to the public role

--Columns Returned:
--UserName        : SQL or Windows/Active Directory user cccount.  This could also be an Active Directory group.
--UserType        : Value will be either 'SQL User' or 'Windows User'.  This reflects the type of user defined for the 
--                  SQL Server user account.
--DatabaseUserName: Name of the associated user as defined in the database user account.  The database user may not be the
--                  same as the server user.
--Role            : The role name.  This will be null if the associated permissions to the object are defined at directly
--                  on the user account, otherwise this will be the name of the role that the user is a member of.
--PermissionType  : Type of permissions the user/role has on an object. Examples could include CONNECT, EXECUTE, SELECT
--                  DELETE, INSERT, ALTER, CONTROL, TAKE OWNERSHIP, VIEW DEFINITION, etc.
--                  This value may not be populated for all roles.  Some built in roles have implicit permission
--                  definitions.
--PermissionState : Reflects the state of the permission type, examples could include GRANT, DENY, etc.
--                  This value may not be populated for all roles.  Some built in roles have implicit permission
--                  definitions.
--ObjectType      : Type of object the user/role is assigned permissions on.  Examples could include USER_TABLE, 
--                  SQL_SCALAR_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION, SQL_STORED_PROCEDURE, VIEW, etc.   
--                  This value may not be populated for all roles.  Some built in roles have implicit permission
--                  definitions.          
--ObjectName      : Name of the object that the user/role is assigned permissions on.  
--                  This value may not be populated for all roles.  Some built in roles have implicit permission
--                  definitions.
--ColumnName      : Name of the column of the object that the user/role is assigned permissions on. This value
--                  is only populated if the object is a table, view or a table value function.                 
--*/

----List all access provisioned to a sql user or windows user/group directly 
--SELECT		*
--FROM		(
--		SELECT  
--		    [UserName] = CASE princ.[type] 
--				    WHEN 'S' THEN princ.[name]
--				    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
--				 END,
--		    [UserType] = CASE princ.[type]
--				    WHEN 'S' THEN 'SQL User'
--				    WHEN 'U' THEN 'Windows User'
--				 END,  
--		    [DatabaseUserName] = princ.[name],       
--		    [Role] = null,      
--		    [PermissionType] = perm.[permission_name],       
--		    [PermissionState] = perm.[state_desc],       
--		    [ObjectType] = obj.type_desc,--perm.[class_desc],       
--		    [ObjectName] = OBJECT_NAME(perm.major_id),
--		    [ColumnName] = col.[name]
--		FROM    
--		    --database user
--		    sys.database_principals princ  
--		LEFT JOIN
--		    --Login accounts
--		    sys.login_token ulogin on princ.[sid] = ulogin.[sid]
--		LEFT JOIN        
--		    --Permissions
--		    sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
--		LEFT JOIN
--		    --Table columns
--		    sys.columns col ON col.[object_id] = perm.major_id 
--				    AND col.[column_id] = perm.[minor_id]
--		LEFT JOIN
--		    sys.objects obj ON perm.[major_id] = obj.[object_id]
--		WHERE 
--		    princ.[type] in ('S','U')
--		UNION
--		--List all access provisioned to a sql user or windows user/group through a database or application role
--		SELECT  
--		    [UserName] = CASE memberprinc.[type] 
--				    WHEN 'S' THEN memberprinc.[name]
--				    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
--				 END,
--		    [UserType] = CASE memberprinc.[type]
--				    WHEN 'S' THEN 'SQL User'
--				    WHEN 'U' THEN 'Windows User'
--				 END, 
--		    [DatabaseUserName] = memberprinc.[name],   
--		    [Role] = roleprinc.[name],      
--		    [PermissionType] = perm.[permission_name],       
--		    [PermissionState] = perm.[state_desc],       
--		    [ObjectType] = obj.type_desc,--perm.[class_desc],   
--		    [ObjectName] = OBJECT_NAME(perm.major_id),
--		    [ColumnName] = col.[name]
--		FROM    
--		    --Role/member associations
--		    sys.database_role_members members
--		JOIN
--		    --Roles
--		    sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
--		JOIN
--		    --Role members (database users)
--		    sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
--		LEFT JOIN
--		    --Login accounts
--		    sys.login_token ulogin on memberprinc.[sid] = ulogin.[sid]
--		LEFT JOIN        
--		    --Permissions
--		    sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
--		LEFT JOIN
--		    --Table columns
--		    sys.columns col on col.[object_id] = perm.major_id 
--				    AND col.[column_id] = perm.[minor_id]
--		LEFT JOIN
--		    sys.objects obj ON perm.[major_id] = obj.[object_id]
--		UNION
--		--List all access provisioned to the public role, which everyone gets by default
--		SELECT  
--		    [UserName] = '{All Users}',
--		    [UserType] = '{All Users}', 
--		    [DatabaseUserName] = '{All Users}',       
--		    [Role] = roleprinc.[name],      
--		    [PermissionType] = perm.[permission_name],       
--		    [PermissionState] = perm.[state_desc],       
--		    [ObjectType] = obj.type_desc,--perm.[class_desc],  
--		    [ObjectName] = OBJECT_NAME(perm.major_id),
--		    [ColumnName] = col.[name]
--		FROM    
--		    --Roles
--		    sys.database_principals roleprinc
--		LEFT JOIN        
--		    --Role permissions
--		    sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
--		LEFT JOIN
--		    --Table columns
--		    sys.columns col on col.[object_id] = perm.major_id 
--				    AND col.[column_id] = perm.[minor_id]                   
--		JOIN 
--		    --All objects   
--		    sys.objects obj ON obj.[object_id] = perm.[major_id]
--		WHERE
--		    --Only roles
--		    roleprinc.[type] = 'R' AND
--		    --Only public role
--		    roleprinc.[name] = 'public' AND
--		    --Only objects of ours, not the MS objects
--		    obj.is_ms_shipped = 0

--		) Data
--WHERE		[ObjectName] IN	(
--				'Individual' 
--				,'ProfileIndividualRel' 
--				,'Profile'
--				,'SCIDomainAccount'
--				)    
--	OR	[Role] IN	(
--				'db_datareader'
--				,'db_datawriter'
--				,'db_owner'
--				)
    
--ORDER BY
--    [ObjectType], 
--    [ObjectName],
--    [ColumnName],
--    [UserName],
--    [PermissionType],
--    [PermissionState]


--GO

--GRANT IMPERSONATE ON ALL TO dbasledridge;


--select * From sys.server_principals WHERE TYPE IN ('S','U','G') AND is_disabled = 0

REVERT
GO
DROP TABLE #Permissions
GO
CREATE TABLE #Permissions
	(
	[LoginName]		SYSNAME
	,LoginType		CHAR(1)
	,entity_name		SYSNAME
	,subentity_name		SYSNAME
	,permission_name	SYSNAME
	)



DECLARE LoginCursor CURSOR
FOR
SELECT name,type From sys.server_principals WHERE TYPE IN ('S','U','G') AND is_disabled = 0 
AND name NOT IN ('NT AUTHORITY\SYSTEM','NT SERVICE\MSSQL$A','NT SERVICE\ClusSvc','NT SERVICE\SQLAgent$A','','','','')

DECLARE @name sysname,@type CHAR(1)

OPEN LoginCursor
FETCH NEXT FROM LoginCursor INTO @name,@Type
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		
		if exists(select * From wcds.sys.sysusers where name = @name) or IS_SRVROLEMEMBER('sysadmin',@name) = 1
		BEGIN
			IF @name NOT IN ('BUILTIN\Administrators')
			BEGIN
				EXECUTE AS LOGIN = @name;
				
				INSERT INTO	#Permissions
				SELECT		@name
						,@Type
						,* 
				FROM		fn_my_permissions('wcds.dbo.Individual', 'OBJECT') 
				UNION
				SELECT		@name
						,@Type
						,* 
				FROM		fn_my_permissions('wcds.dbo.ProfileIndividualRel', 'OBJECT') 
				UNION
				SELECT		@name
						,@Type
						,* 
				FROM		fn_my_permissions('wcds.dbo.Profile', 'OBJECT') 
				UNION
				SELECT		@name
						,@Type
						,* 
				FROM		fn_my_permissions('wcds.dbo.SCIDomainAccount', 'OBJECT') 
				ORDER BY	subentity_name, permission_name

		
				REVERT;
			END
			ELSE

				INSERT INTO	#Permissions
				SELECT		@name
						,@Type
						,'SYSADMIN'
						,''
						,'ALL' 

		END
		ELSE
		BEGIN
			PRINT @Name + ' Does Not Have Access to WCDS.'  
			--select * From wcds.sys.sysusers 
		END
	END
	FETCH NEXT FROM LoginCursor INTO @name,@Type
END

CLOSE LoginCursor
DEALLOCATE LoginCursor
GO
SELECT	DISTINCT 
	[LoginName] 
	,LoginType
	,entity_name
FROM	#Permissions

--;WITH		ServerRollMembers
--		AS
--		(
--		SELECT		SUSER_NAME(srm.member_principal_id)	AS [Member]
--				,SUSER_NAME(srm.role_principal_id)	AS [Role]
--				,sp.Type_desc
--		FROM		sys.server_role_members srm
--		JOIN		sys.server_principals sp
--			ON	srm.member_principal_id = sp.principal_id
--		)
		
--
DROP TABLE #AccountMembers
GO
CREATE TABLE #AccountMembers
	(
	[Parent Account]	SYSNAME NULL
	,[account name]		SYSNAME NULL
	,[type]			SYSNAME NULL
	,[privilege]		SYSNAME NULL
	,[mapped login name]	SYSNAME NULL
	,[permission path]	SYSNAME NULL
	)
	
DECLARE @GroupName	SYSNAME	
SET	@GroupName	= 'BUILTIN\Administrators'	

CheckGroup:

PRINT @GroupName	

INSERT INTO #AccountMembers ([account name],[type],[privilege],[mapped login name],[permission path])
EXEC xp_logininfo @GroupName, 'members'

UPDATE #AccountMembers SET [Parent Account] = @GroupName WHERE [Parent Account] IS NULL

IF NOT EXISTS(SELECT * FROM #AccountMembers WHERE [Parent Account] = @GroupName)
	INSERT INTO #AccountMembers ([Parent Account]) VALUES (@GroupName)

SET @GroupName = NULL

SELECT TOP(1) @GroupName = [account name] FROM #AccountMembers WHERE [type] = 'group' AND [account name] NOT IN (SELECT [Parent Account] FROM #AccountMembers)

IF @GroupName IS NOT NULL GOTO CheckGroup

SELECT * FROM #AccountMembers

EXEC xp_logininfo 'PRODUCTION\Domain Admins','members'
SELECT @@ROWCOUNT