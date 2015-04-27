SET NOCOUNT ON
GO
USE [msdb]
GO
IF object_id('dbo.RDCM_extract_group_and_members') IS NOT NULL
	DROP FUNCTION dbo.RDCM_extract_group_and_members
GO
CREATE FUNCTION dbo.RDCM_extract_group_and_members(@key AS INT,@password sysname)
RETURNS XML
BEGIN
    RETURN	(
		SELECT	(
			SELECT		(
					SELECT		g.name
							,g.expanded
							,g.comment
							,(SELECT g.logonCredentials AS "@inherit" FOR XML PATH('logonCredentials'), type)
							,(SELECT g.connectionSettings AS "@inherit" FOR XML PATH('connectionSettings'), type)
							,(SELECT g.gatewaySettings AS "@inherit" FOR XML PATH('gatewaySettings'), type)
							,(SELECT g.remoteDesktop AS "@inherit" FOR XML PATH('remoteDesktop'), type)
							,(SELECT g.localResources AS "@inherit" FOR XML PATH('localResources'), type)
							,(SELECT g.securitySettings AS "@inherit" FOR XML PATH('securitySettings'), type)
							,(SELECT g.displaySettings AS "@inherit" FOR XML PATH('displaySettings'), type)
					FROM		(
							SELECT		server_group_id
									,parent_id
									,name
									,'False' AS 'expanded'
									,description AS 'comment'
									,'FromParent' AS 'logonCredentials'
									,'FromParent' AS 'connectionSettings'
									,'FromParent' AS 'gatewaySettings'
									,'FromParent' AS 'remoteDesktop'
									,'FromParent' AS 'localResources'
									,'FromParent' AS 'securitySettings'
									,'FromParent' AS 'displaySettings'
							FROM		msdb.dbo.sysmanagement_shared_server_groups_internal
							--WHERE		is_system_object = 0
							) g 
					WHERE		g.server_group_id = @key
					FOR XML PATH('properties'),type
					)
					,(
					SELECT		dbo.RDCM_extract_group_and_members(server_group_id,@password)
					FROM		msdb.dbo.sysmanagement_shared_server_groups_internal
					WHERE		parent_id = @key
					FOR XML PATH(''),type
					)
					,(
					SELECT		s.name
							,s.displayName
							,s.comment
							,(
							SELECT		s.logonCredentials AS "@inherit"
									,(
									SELECT		case s.domain WHEN 'PRODUCTION' THEN 'p-' ELSE 's-' END + REPLACE(REPLACE(sUser_sName(),'AMER\',''),'s-','') AS [userName]
											,s.domain
											,(SELECT 'True' AS "@storeAsClearText",@password FOR XML PATH('password'), type)
									FOR XML PATH(''), type 
									)
							FOR XML PATH('logonCredentials'), type
							)
							,(SELECT s.connectionSettings AS "@inherit" FOR XML PATH('connectionSettings'), type)
							,(SELECT s.gatewaySettings AS "@inherit" FOR XML PATH('gatewaySettings'), type)
							,(SELECT s.remoteDesktop AS "@inherit" FOR XML PATH('remoteDesktop'), type)
							,(SELECT s.localResources AS "@inherit" FOR XML PATH('localResources'), type)
							,(SELECT s.securitySettings AS "@inherit" FOR XML PATH('securitySettings'), type)
							,(SELECT s.displaySettings AS "@inherit" FOR XML PATH('displaySettings'), type)
					FROM		(
							SELECT		DISTINCT 
									server_group_id
									,CASE
										WHEN PATINDEX('%\%',name) > 0 THEN
											SUBSTRING(name,1, (PATINDEX('%\%',name) -1 ))
										WHEN PATINDEX('%,%',name) > 0  THEN
											SUBSTRING(name,1, (PATINDEX('%,%',name) -1 ))
										ELSE
											name
									END AS name
									,CASE
										WHEN PATINDEX('%\%',name) > 0 THEN
											SUBSTRING(name,1, (PATINDEX('%\%',name) -1 ))
										WHEN PATINDEX('%,%',name) > 0  THEN
											SUBSTRING(name,1, (PATINDEX('%,%',name) -1 ))
										ELSE
											name
									END AS 'displayName'
									,LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(description,CHARINDEX('[Env-Dom]',description)+9,CHARINDEX('[',description,CHARINDEX('[Env-Dom]',description)+9)-(CHARINDEX('[Env-Dom]',description)+10)),CHAR(13),''),CHAR(10),''))) AS [domain]
									,description AS 'comment'
									,'None' AS 'logonCredentials'
									,'FromParent' AS 'connectionSettings'
									,'FromParent' AS 'gatewaySettings'
									,'FromParent' AS 'remoteDesktop'
									,'FromParent' AS 'localResources'
									,'FromParent' AS 'securitySettings'
									,'FromParent' AS 'displaySettings'
							FROM		msdb.dbo.sysmanagement_shared_registered_servers_internal
							) s 
					WHERE		s.server_group_id = @key
					FOR XML PATH('server'),type
					)					
			FOR XML PATH('group'),type
			) 
		)
END

GO







DECLARE @xml XML
 
;WITH		[file] 
		AS
		(
		SELECT		1 AS 'RDCMan'
				,2.2 AS 'version'
				,'CMS' AS 'name'
				,'False' AS 'expanded'
				,'Generated from CMS' AS 'comment'
				,'FromParent' AS 'logonCredentials'
				,'FromParent' AS 'connectionSettings'
				,'FromParent' AS 'gatewaySettings'
				,'None' AS 'remoteDesktop'
				,'FromParent' AS 'localResources'
				,'FromParent' AS 'securitySettings'
				,'FromParent' AS 'displaySettings'
		)

SELECT		@XML = 
		(
		SELECT		(
				SELECT		name
						,expanded
						,comment
						,(SELECT logonCredentials AS "@inherit" FOR XML PATH('logonCredentials'), type)
						,(SELECT connectionSettings AS "@inherit" FOR XML PATH('connectionSettings'), type)
						,(SELECT gatewaySettings AS "@inherit" FOR XML PATH('gatewaySettings'), type)
						,(SELECT remoteDesktop AS "@inherit",(SELECT '1024 x 768' [size], 'True' [sameSizeAsClientArea], 'False' [fullScreen], '32' [colorDepth] FOR XML PATH(''), type) FOR XML PATH('remoteDesktop'), type)
						,(SELECT localResources AS "@inherit" FOR XML PATH('localResources'), type)
						,(SELECT securitySettings AS "@inherit" FOR XML PATH('securitySettings'), type)
						,(SELECT displaySettings AS "@inherit" FOR XML PATH('displaySettings'), type)
				FROM		[file]
				FOR XML PATH('properties'),type
				)
				,dbo.RDCM_extract_group_and_members(1,'Tigger4U3')
		FROM		[file]
		FOR XML AUTO, ELEMENTS, ROOT('RDCMan')
		)

SET @XML.modify('
insert <version>2.2</version> 
as first
into (/RDCMan)[1]') 
 
SET @xml.modify('insert attribute schemaVersion{"1"} as last into (RDCMan)[1]')
 
SELECT @XML

GO





