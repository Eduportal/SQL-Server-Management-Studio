SET NOCOUNT ON

select		QUOTENAME([Name],'"')+';'
		+QUOTENAME([computername],'"')+';'
		+QUOTENAME([macaddress],'"')+';'
		+QUOTENAME([weburl],'"')+';'
		+QUOTENAME([connectionprotocol],'"')+';'
		+QUOTENAME([port],'"')+';'
		+QUOTENAME([FolderStructure],'"')

FROM		(
		SELECT			DISTINCT
					UPPER(SI.[SQLName])								[Name]
					,UPPER(SI.[ServerName])								[computername]
					,''										[macaddress]
					,'tcp:'+UPPER(SI.[SQLName])+','+COALESCE(SI.[Port],'1433')			[weburl]
					,'RDP'										[connectionprotocol]
					,'3389'										[port]
					,ISNULL(NULLIF(UPPER(COALESCE(SI.DomainName,'--')),'--'),'')
						+ISNULL('\'+NULLIF(UPPER(COALESCE(SI.SQLEnv,'--')),'--'),'')		[FolderStructure]
		FROM		[DBAcentral].[dbo].[DBA_ServerInfo] SI
		WHERE		SI.Active != 'N'
		) Data
ORDER BY	[Name] --[FolderStructure]