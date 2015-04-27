USE [DBACentral]
GO

DECLARE		@XML	XML


;WITH		Connection
		AS
		(
		SELECT		DISTINCT
				--top 1
				UPPER([ServerName])							[Name]
				,'Getty Images\MSSQL\'+	UPPER(COALESCE(DomainName,'--'))		[Group]
				--,[FQDN]									[URL]
				,UPPER(COALESCE(DomainName,'--'))					[Domain]
				,UPPER(COALESCE([FQDN]
						,[ServerName] + CASE [DomainName]
								WHEN 'Stage' THEN '.stage.local'
								WHEN 'Production' THEN '.production.local'
								ELSE '.amer.gettywan.com'
								END
						,[ServerName]
						))							[Host]
				,'RDPConfigured'							[ConnectionType]
				,UPPER([SQLEnv])							[GroupTab]
				--,[FQDN]									[FQDN]
				,[SystemModel]								[Hardware]
				,[Memory]								[Memory]
				,[OSname]								[OS]
				,[dbaadmin_Version]							[dbaadmin_Version]
				,[dbaperf_Version]							[dbaperf_Version]
				,[SQLdeploy_Version]							[SQLdeploy_Version]
				,CASE WHEN SQLver LIKE '%X86%' THEN 	'32-bit'
					WHEN SQLver LIKE '%X64%' THEN 	'64-bit'
					END								[Architecture]
				,CPUphysical+','+CPUcore+','+CPUlogical+','+CPUtype			[Cpu]
				,Cluster								[ClusterName]
				--select *														
		FROM		[DBAcentral].[dbo].[DBA_ServerInfo] 
		WHERE		Active != 'N' --AND ServerName Like '%G1SQLA%'
		)
		,SSMS
		AS
		(
		SELECT		DISTINCT
				UPPER([SQLName])							[Name]
				,'SQL Server Management Studio'						[Description]
				,CASE [DomainName]
					WHEN 'AMER' 
					THEN '"C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Ssms.exe" -S $HOST$ -E -nosplash'
					ELSE '"C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Ssms.exe" -S $HOST$ -U $USERNAME$ -P $PASSWORD$ -nosplash'
					END								[CommandLine]
				,'tcp:'
				 +UPPER(COALESCE(REPLACE(SQLName,ServerName,UPPER(COALESCE([FQDN]
						,[ServerName] + CASE [DomainName]
								WHEN 'Stage' THEN '.stage.local'
								WHEN 'Production' THEN '.production.local'
								ELSE '.amer.gettywan.com'
								END
						,[ServerName]
						))),SQLName)
				 +','+ COALESCE([Port],'1433'))						[Host]
				,'CommandLine'								[ConnectionType]
				,UPPER([ServerName])							[ServerName]
				,CASE DomainName WHEN 'AMER' THEN'data source='+'tcp:'
				 +UPPER(COALESCE(REPLACE(SQLName,ServerName,UPPER(COALESCE([FQDN]
						,[ServerName] + CASE [DomainName]
								WHEN 'Stage' THEN '.stage.local'
								WHEN 'Production' THEN '.production.local'
								ELSE '.amer.gettywan.com'
								END
						,[ServerName]
						))),SQLName)
				 +','+ COALESCE([Port],'1433'))+';integrated security=True'
					ELSE 'data source='+'tcp:'
				 +UPPER(COALESCE(REPLACE(SQLName,ServerName,UPPER(COALESCE([FQDN]
						,[ServerName] + CASE [DomainName]
								WHEN 'Stage' THEN '.stage.local'
								WHEN 'Production' THEN '.production.local'
								ELSE '.amer.gettywan.com'
								END
						,[ServerName]
						))),SQLName)
				 +','+ COALESCE([Port],'1433'))+';persist security info=True;user id=dbasledridge;Password=Tigger4U'
					END								[ConnectionString]
				--select *														
		FROM		[DBAcentral].[dbo].[DBA_ServerInfo]
		WHERE		Active != 'N' --AND ServerName Like '%GSYS%'
		)
		,NODE
		AS
		(
		SELECT		DISTINCT
				UPPER([ResourceName])							[Name]
				,'Cluster Node'								[Description]
				,[ClusterName]
				--select *														
		FROM		[DBAcentral].[dbo].[DBA_ClusterInfo]
		WHERE		ResourceType = 'Node'
		)
SELECT @XML = (
SELECT		CAST(
		COALESCE(CAST((	-------------- CLUSTER
			SELECT	'true' [AllowClipboard]
				,'true' [AllowPasswordVariable]
				,'Host' [ConnectionType]
				,(SELECT NULL FOR XML PATH(''), TYPE) [Events]
				,(SELECT [Host] ,(SELECT '24388d51-ac5e-4ba2-b124-904019a582b6' [guid] FOR XML PATH(''), TYPE) [TemplateIDList] FOR XML PATH(''), TYPE) [HostDetails]
				,'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vLDwG/eE8/vMO7xsAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2tpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo1ZmViODRkMS1iYWQzLTRiNmQtODU3Zi0zYjAyM2E2NWM5NTUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6N0I4RjE1ODM0MDdGMTFFNEIyQkY4RDM5NDgzMTJDQzQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6N0I4RjE1ODI0MDdGMTFFNEIyQkY4RDM5NDgzMTJDQzQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MkY0RTBEREI0MDc3MTFFNEIyQkY4RDM5NDgzMTJDQzQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MkY0RTBEREM0MDc3MTFFNEIyQkY4RDM5NDgzMTJDQzQiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4sGmCIAAAA70lEQVRYR+2VYQ7CIAyFuYmn9YpewR+eQBeDLQItBLJS2DARkq/Qsr69LWEz1tqpuHC5Pu6AbeQGGBwwq/q5gVDc2FpCMBDypv7cwBPXEpgIN9Dcj2tecAIwSyCBzIDf36NuQDISAcp1/Ri6BChfBsYYkJAIkKCunxXewEtIyYCu3xvAr1rcqMAF8Gb8S6jq5wZE4LX59aGmpVg8ExfgSdbPCAvNxwjgBrqPoROAWQIJZAb8/h51A5KRCFCu68fQJUD5MjDGgIREgAR1/azwxz+jmXzDpBENwOsovbLD+SkDWqKQRmeogawuIhqYhzUfVXdb5QAlNsMAAAAASUVORK5CYII=' [Image]
				,'d1b31825ce5fdde8e337ef199534f237' [ImageMD5]
				,(SELECT NULL FOR XML PATH(''), TYPE) [MetaInformation]
				,[Name]
				,'true' [OpenEmbedded]
				,'False' [PinEmbeddedMode]
				,9 [SortPriority]
				,(SELECT 'true' [AllowCredentialsToToolsAddOn], 'MyDefault' [CredentialSource] FOR XML PATH(''), TYPE) [Tools]
				,'DomainBackslashUser' [UserNameFormat]
			FOR XML PATH('Connection'),TYPE

		)AS VarChar(max)),'')
		+
		COALESCE(CAST((	-------------- CLUSTER NODE	
			SELECT	'true' [AllowClipboard]
				,'true' [AllowPasswordVariable]
				,'Host' [ConnectionType]
				,(SELECT NULL FOR XML PATH(''), TYPE) [Events]
				,(SELECT REPLACE([Connection].[Host],[Connection].[Name],[Name]) [Host] ,(SELECT '24388d51-ac5e-4ba2-b124-904019a582b6' [guid] FOR XML PATH(''), TYPE) [TemplateIDList] FOR XML PATH(''), TYPE) [HostDetails]
				,'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T5/+BQOY8/yUGUl9AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyNpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjM4M0RBNkNCNTE3NzExRTQ5MDA5Q0M0OUIzQUY5QzU3IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjM4M0RBNkNDNTE3NzExRTQ5MDA5Q0M0OUIzQUY5QzU3Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzgzREE2Qzk1MTc3MTFFNDkwMDlDQzQ5QjNBRjlDNTciIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MzgzREE2Q0E1MTc3MTFFNDkwMDlDQzQ5QjNBRjlDNTciLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz5wLR6AAAADnElEQVRYR6XXW6gVVRzHcSPJvGWamNFFjIq0ohBv3S92o4upIGIheEkTL2RqUWgUleFDUfQiiRUEooaCSKgImqQvPggiaPpQgRpBQoVU0HX3/e7mf1hnuWafs08PH9h75r/W/GZmrTUzvRqNRocRa86261nswsxkW7fEMXsS4HK8jR/xHT7H7ziLVzEYpXad9CTAGGxGAz9jGQbhKoyAof6A+z/CzSj109ROgCk4DDs+jukYgHFYiKV4FKPg1ZkPr471B/AIzuu3qwD94Rl+Dzvai/HwjO+CB9yHD2H9TXgajoUJGIaHcQS2/wazcRFaBrgCa+C9teF7uA19YYAFsON+WIXF2IKTmIS78STm4FZcgvuwFfb3LRwnQ+oC7K8Ko3g43P4yvK/N9HgTBlgPax0bXo2BcP/F2AiD+P92RL/aXhcg7nXqU9wJL+2LmIHrYP01cLC9hT7Vtqfg2BiL+/EZ8j531QV4PysMjnoHl/f/GczFLbCNXoKzwJrJcN8LiFmRW10XYC1+xTx8ibyhs8B7fAdmwYHlWRrgHXg1puIM8rbe3teq38/XBfgAfyPOzJlwDnln2/AAnIqe9dW4B86MvPZPOGbs78Jq28q6AKurgmsRIa7HJqSdhjfgAlV36wzkLIq+vFpun1UXYFFV4MoWjYKX9ijSA9Rx/XCs5H14y9z/YF0AR7AFjvi8sVxIXCfSg+XWYShK7ZfDmlF1AW6oClzV8sYp7/0epAc+BMdFqT68C2sH1AW4sipYgbxxzhGfBngIpbrUBlg7sC6ADxMLHFx545xTMQ3wOEp1KZftv9C7LoBLqJ25HuSNc677aQAXoFJdygAuah3HzAPoJ+yufrfSbgAfTC5QX/m/VYCdsMMduLTaVpIHcIUs1cml+QSs+8RtrQKMRKxozufHkHYW8gBPoFT3HKLGk/KR3zJAiCmjWEpTXQW4DN7z2O/ju2N/dwLITn022MEXuBGx715E55qG2OdLyym4/Qf4UhL7mrobQBPxC+zMJ2UsUqOrbcEHkttfT7bJK5X219ROAMW7YXgFvqT4pPP/b/AKfFz9D/8gXl46aSdAbxxD2rH8DogALi75fhms+FxoJ4C6egDVcT25AOf12W4Al2gXqNJBWvE2lfprO4AcTH6ClQ5U4gdLqZ+mngSQM+IgSgcMTr8uP1Z7GiD4ZuNr2tdwMJ6GHx9L4NdTqU0n/zdAcIZ4QL+cSvtr/XfMRq9/ATkyadMOMr6aAAAAAElFTkSuQmCC' [Image]
				,'2a2b1d1d0ac4ae2eea971856767f43a3' [ImageMD5]
				,(SELECT NULL FOR XML PATH(''), TYPE) [MetaInformation]
				,[Name]
				,'true' [OpenEmbedded]
				,'False' [PinEmbeddedMode]
				,8 [SortPriority]
				,(SELECT 'true' [AllowCredentialsToToolsAddOn], 'MyDefault' [CredentialSource] FOR XML PATH(''), TYPE) [Tools]
				,'DomainBackslashUser' [UserNameFormat]
			FROM NODE
			WHERE ClusterName = Connection.[ClusterName]
			FOR XML PATH('Connection'),TYPE

		)AS VarChar(max)),'')
		+
		COALESCE(CAST((	-------------- SSMS
			SELECT	'true' [AllowClipboard]
				,'true' [AllowPasswordVariable]
				,(SELECT [Host], 'false' [UseShellExecute] FOR XML PATH(''), TYPE) [Cmd]
				,[CommandLine]
				,[ConnectionType]
				,(SELECT NULL FOR XML PATH(''), TYPE) [Events]
				,'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAANgSURBVFhHtZX9S1NRGMdnRX9AP0QRUb9E9mJFSBFlSPhDQVGQ+ZKIhUSWMWxavpQjzbfpFr7M5kxNQ0WdWLZEmRkapij7wTdC0swyMcKZSqhZ+c3neG+6ebduuvuFB4/n3nO+n/M8zz2T8WqskKO18hpaDNZBcwZ9CLjXpBGZf3z7mMXosAG/pk0sRgbLMNxfwiL+ktsyiKBKP3g/PM3mxYztqjY/EL9nTA5DCIA2PnbVnc2LGdsVAYyb/TA1pMLMeAU7/ex3I6b6Y2Fp9cWgwU0QwGkigFHTAYyZfTD5PgYTvWGwNHpgKEeGvgwZulNdVgwgqgQ1OecZAGVBEEDtgjsBe1YEIKoEFZqzsJjc5zNgDTCsXz2AKBXGnWAAQhno5wAivHdJV4JMxWG7PUAAPfM9EHpmp3QlcATAl2ClAKIkJYDoEnyqPoixdm9BgLbEddKWgJrQrNuIluIjGGybN++R40u9Bzo061ETvQYvItdKWwISQUQGelpFrO929ldy8/9RXGY5UvOMUBfUgMbctOx2SgFsg3skjapM7XhU+doKgpciIQ+a/GrngtgatXcNILf8lSAAiSDm5uZQ19znHAhKOzdkogwkag0gI27KSpmFRny1TDAIY8uYYwgx32pGUR3o1BTVDWYYm7pxV1OMkJgswXUE2PdhhAFYJmYdQ4j5VinVFDHqYkSpnrCTV5la0NE7gPSi2mVrqT8IlszfDU3jTfckWxcgVzn0cSgCCI/X4bIiDeeClfDyv8VOKAQRr86DqbkThVXN0BY3QKV/xgBoHffKokRdlwIiGCEItVKO/PRwFBXeQ6hSj6CIrHnjOJwKjGZfh09oMjwvKBb9RF2XdkRZsYWg35WX2e4IC48CZYJ7VZaiLWXGVA7qIyuI1ehKeNIyiOSw49Bl5SwzINOkrFLWC9lFzxeeLy2BmLGQeIjpHz/tNiYvgkjRli0+X1oCMWNbUc0p7TwEdf6/IJwm3rxZtxf+J3fjemQag+j/PC09BG/epN8Hf69tuK9MZWYXbyRID7HU/JDrZjxISrQykcfppYPgzRsytuKw6wbo0tWCm1O3E0SfMyGeluT+PflRt024KY9wuGlwxEJP1Ju/sUuIm165ero6QRnYv2MLQoKDRW3IX9vcv0skk/0BtO3r5glnu8EAAAAASUVORK5CYII=' [Image]
				,'af6034f639861cc4275021327fe77eba' [ImageMD5]
				,(SELECT NULL FOR XML PATH(''), TYPE) [MetaInformation]
				,[Name]
				,'False' [PinEmbeddedMode]
				,5 [SortPriority]
				,(SELECT 'MyDefault' [CredentialSource] FOR XML PATH(''),TYPE ) [RunAsConnection]
			FROM SSMS
			WHERE ServerName = Connection.[Name]
			FOR XML PATH('Connection'),TYPE
		)AS VarChar(max)),'')
		+
		COALESCE(CAST((	-------------- DATABASE
			SELECT	'true' [AllowClipboard]
				,'true' [AllowPasswordVariable]
				--,'1310CF82-6FAB-4B7A-9EEA-3E2E451CA2CF' [ConnectionStringConnectionID]
				,'Database' [ConnectionType]
				,CASE [Domain] WHEN 'AMER' THEN 'E2CC9029-CA3A-4308-BA54-16D5029BC8ED' END [CredentialConnectionID]
				,CASE [Domain] WHEN 'AMER' THEN
				(SELECT [Host]
					--,[ConnectionString] 
					,[ConnectionString] [SafeConnectionString]
					FOR XML PATH(''),TYPE)
				ELSE
				(SELECT [Host]
					--,[ConnectionString] 
					,[ConnectionString] [SafeConnectionString]
					--,'Tigger4U' [Password]
					,'Mr+WqUvmxa8xxXV3SgLNMQ==' [SafePassword]
					,'dbasledridge' [UserName]
					FOR XML PATH(''),TYPE)
				END [DataReport]
				,'true' [Encrypt]
				,(SELECT NULL FOR XML PATH(''), TYPE) [Events]
				--,'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAANgSURBVFhHtZX9S1NRGMdnRX9AP0QRUb9E9mJFSBFlSPhDQVGQ+ZKIhUSWMWxavpQjzbfpFr7M5kxNQ0WdWLZEmRkapij7wTdC0swyMcKZSqhZ+c3neG+6ebduuvuFB4/n3nO+n/M8zz2T8WqskKO18hpaDNZBcwZ9CLjXpBGZf3z7mMXosAG/pk0sRgbLMNxfwiL+ktsyiKBKP3g/PM3mxYztqjY/EL9nTA5DCIA2PnbVnc2LGdsVAYyb/TA1pMLMeAU7/ex3I6b6Y2Fp9cWgwU0QwGkigFHTAYyZfTD5PgYTvWGwNHpgKEeGvgwZulNdVgwgqgQ1OecZAGVBEEDtgjsBe1YEIKoEFZqzsJjc5zNgDTCsXz2AKBXGnWAAQhno5wAivHdJV4JMxWG7PUAAPfM9EHpmp3QlcATAl2ClAKIkJYDoEnyqPoixdm9BgLbEddKWgJrQrNuIluIjGGybN++R40u9Bzo061ETvQYvItdKWwISQUQGelpFrO929ldy8/9RXGY5UvOMUBfUgMbctOx2SgFsg3skjapM7XhU+doKgpciIQ+a/GrngtgatXcNILf8lSAAiSDm5uZQ19znHAhKOzdkogwkag0gI27KSpmFRny1TDAIY8uYYwgx32pGUR3o1BTVDWYYm7pxV1OMkJgswXUE2PdhhAFYJmYdQ4j5VinVFDHqYkSpnrCTV5la0NE7gPSi2mVrqT8IlszfDU3jTfckWxcgVzn0cSgCCI/X4bIiDeeClfDyv8VOKAQRr86DqbkThVXN0BY3QKV/xgBoHffKokRdlwIiGCEItVKO/PRwFBXeQ6hSj6CIrHnjOJwKjGZfh09oMjwvKBb9RF2XdkRZsYWg35WX2e4IC48CZYJ7VZaiLWXGVA7qIyuI1ehKeNIyiOSw49Bl5SwzINOkrFLWC9lFzxeeLy2BmLGQeIjpHz/tNiYvgkjRli0+X1oCMWNbUc0p7TwEdf6/IJwm3rxZtxf+J3fjemQag+j/PC09BG/epN8Hf69tuK9MZWYXbyRID7HU/JDrZjxISrQykcfppYPgzRsytuKw6wbo0tWCm1O3E0SfMyGeluT+PflRt024KY9wuGlwxEJP1Ju/sUuIm165ero6QRnYv2MLQoKDRW3IX9vcv0skk/0BtO3r5glnu8EAAAAASUVORK5CYII=' [Image]
				--,'af6034f639861cc4275021327fe77eba' [ImageMD5]
				,(SELECT NULL FOR XML PATH(''), TYPE) [MetaInformation]
				,[Name]
				,'true' [OpenEmbedded]
				,'False' [PinEmbeddedMode]
				,4 [SortPriority]
				,CASE [Domain] WHEN 'AMER' THEN
					(SELECT 'true' [AllowCredentialsToToolsAddOn], 'MyDefault' [CredentialSource] FOR XML PATH(''), TYPE)
					END [Tools]
				--,'Default' [UserNameFormat]
			FROM SSMS
			WHERE ServerName = Connection.[Name]
			FOR XML PATH('Connection'),TYPE
		)AS VarChar(max)),'') 		 
		AS XML)  [Children]
 
		,'#FF0000' [Color]
		,[ConnectionType]
		,'9F3C3BCF-068A-4927-B996-CA52154CAE3B' [CredentialConnectionID]
		,'true' [DisableThemes]
		,'true' [DisableWallpaper]
		,(SELECT NULL FOR XML PATH(''), TYPE) [Events]
		--,(SELECT 'ConnectionString' [CredentialType], 'data source='+[Host]+';integrated security=True' [ConnectionString] FOR XML PATH(''),TYPE) [Credentials]
		
		,[Group]
		,[GroupTab]
		,(SELECT	[Architecture]
				,[Cpu]
				,[Domain]
				,[Hardware]
				,CASE WHEN [Hardware] Like '%VMware%' THEN 'true' ELSE 'false' END [IsVirtualMachine]
				,[Memory]
				,[OS]
				,CASE WHEN [NAME] LIKE 'ASH%' THEN 'ASHBURN' ELSE 'SEATTLE' END [Site]
			FOR XML PATH(''),TYPE
			) [MetaInformation]
		,[Name]
		,'true' [OpenEmbedded]
		,'False' [PinEmbeddedMode]
		,(SELECT	'false' [LoadAddOns]
				,'true' [NetworkLevelAuthentication]
				,'false' [RedirectDirectX]
				,'FitToWindow' [ScreenSizingMode]
				,'Disabled' [VideoPlaybackMode]
			FOR XML PATH(''),TYPE
			) [RDP]

		,'C16Bits'	[ScreenColor]
		,'true'		[SmartSizing]
		,'DoNotPlay'	[SoundHook]
		,[Host]		[Url]
		,'false'	[UsesHardDrives]
		,'false'	[UsesSerialPorts]
FROM		[Connection]
FOR XML AUTO, ELEMENTS, type, ROOT('ArrayOfConnection')
)

DECLARE		@XML2Add	XML
SET		@XML2Add	=
'  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>a34b6048-e761-463f-a710-6e2132e03c2c</ID>
    <Image>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</Image>
    <ImageMD5>2cf91c060829d768fa807faef44b851d</ImageMD5>
    <Name>Get Drive Data</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>af328751-fdba-4bf7-8141-e751ae87cd6e</Stamp>
    <Tools>
      <AllowRunViaAgent>true</AllowRunViaAgent>
      <ConnectionType>DatabaseQuery</ConnectionType>
      <DatabaseQuery>exec dbaadmin.dbo.dbasp_FixedDrives</DatabaseQuery>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>Group</ConnectionType>
    <Events />
    <Group>Getty Images</Group>
    <GroupDetails>
      <GroupType>Company</GroupType>
    </GroupDetails>
    <ID>e705375a-f611-4937-a7a4-b88cd7ff123a</ID>
    <MetaInformation />
    <Name>Getty Images</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>8894f057-bff8-438b-aab9-629cd33b8058</Stamp>
  </Connection>
  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>56ecb791-8760-4518-96be-071550703292</ID>
    <Name>Index Health Check</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>2a8de26b-b00e-48d9-b602-2345395cedb8</Stamp>
    <Tools>
      <ConnectionType>Template</ConnectionType>
      <KeepTemplateHost>true</KeepTemplateHost>
      <TemplateID>9d374d9f-9a9a-4507-8f49-9e3995ff95c6</TemplateID>
      <TemplateName>Index Health Check</TemplateName>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>99eea480-d2c7-4a43-bac7-8fbecba366b7</ID>
    <Image>iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGOfPtRkwAAACBjSFJNAACHDwAAjA8AAP1SAACBQAAAfXkAAOmLAAA85QAAGcxzPIV3AAAKL2lDQ1BJQ0MgcHJvZmlsZQAASMedlndUVNcWh8+9d3qhzTDSGXqTLjCA9C4gHQRRGGYGGMoAwwxNbIioQEQREQFFkKCAAaOhSKyIYiEoqGAPSBBQYjCKqKhkRtZKfHl57+Xl98e939pn73P32XuftS4AJE8fLi8FlgIgmSfgB3o401eFR9Cx/QAGeIABpgAwWempvkHuwUAkLzcXerrICfyL3gwBSPy+ZejpT6eD/0/SrFS+AADIX8TmbE46S8T5Ik7KFKSK7TMipsYkihlGiZkvSlDEcmKOW+Sln30W2VHM7GQeW8TinFPZyWwx94h4e4aQI2LER8QFGVxOpohvi1gzSZjMFfFbcWwyh5kOAIoktgs4rHgRm4iYxA8OdBHxcgBwpLgvOOYLFnCyBOJDuaSkZvO5cfECui5Lj25qbc2ge3IykzgCgaE/k5XI5LPpLinJqUxeNgCLZ/4sGXFt6aIiW5paW1oamhmZflGo/7r4NyXu7SK9CvjcM4jW94ftr/xS6gBgzIpqs+sPW8x+ADq2AiB3/w+b5iEAJEV9a7/xxXlo4nmJFwhSbYyNMzMzjbgclpG4oL/rfzr8DX3xPSPxdr+Xh+7KiWUKkwR0cd1YKUkpQj49PZXJ4tAN/zzE/zjwr/NYGsiJ5fA5PFFEqGjKuLw4Ubt5bK6Am8Kjc3n/qYn/MOxPWpxrkSj1nwA1yghI3aAC5Oc+gKIQARJ5UNz13/vmgw8F4psXpjqxOPefBf37rnCJ+JHOjfsc5xIYTGcJ+RmLa+JrCdCAACQBFcgDFaABdIEhMANWwBY4AjewAviBYBAO1gIWiAfJgA8yQS7YDApAEdgF9oJKUAPqQSNoASdABzgNLoDL4Dq4Ce6AB2AEjIPnYAa8AfMQBGEhMkSB5CFVSAsygMwgBmQPuUE+UCAUDkVDcRAPEkK50BaoCCqFKqFaqBH6FjoFXYCuQgPQPWgUmoJ+hd7DCEyCqbAyrA0bwwzYCfaGg+E1cBycBufA+fBOuAKug4/B7fAF+Dp8Bx6Bn8OzCECICA1RQwwRBuKC+CERSCzCRzYghUg5Uoe0IF1IL3ILGUGmkXcoDIqCoqMMUbYoT1QIioVKQ21AFaMqUUdR7age1C3UKGoG9QlNRiuhDdA2aC/0KnQcOhNdgC5HN6Db0JfQd9Dj6DcYDIaG0cFYYTwx4ZgEzDpMMeYAphVzHjOAGcPMYrFYeawB1g7rh2ViBdgC7H7sMew57CB2HPsWR8Sp4sxw7rgIHA+XhyvHNeHO4gZxE7h5vBReC2+D98Oz8dn4Enw9vgt/Az+OnydIE3QIdoRgQgJhM6GC0EK4RHhIeEUkEtWJ1sQAIpe4iVhBPE68QhwlviPJkPRJLqRIkpC0k3SEdJ50j/SKTCZrkx3JEWQBeSe5kXyR/Jj8VoIiYSThJcGW2ChRJdEuMSjxQhIvqSXpJLlWMkeyXPKk5A3JaSm8lLaUixRTaoNUldQpqWGpWWmKtKm0n3SydLF0k/RV6UkZrIy2jJsMWyZf5rDMRZkxCkLRoLhQWJQtlHrKJco4FUPVoXpRE6hF1G+o/dQZWRnZZbKhslmyVbJnZEdoCE2b5kVLopXQTtCGaO+XKC9xWsJZsmNJy5LBJXNyinKOchy5QrlWuTty7+Xp8m7yifK75TvkHymgFPQVAhQyFQ4qXFKYVqQq2iqyFAsVTyjeV4KV9JUCldYpHVbqU5pVVlH2UE5V3q98UXlahabiqJKgUqZyVmVKlaJqr8pVLVM9p/qMLkt3oifRK+g99Bk1JTVPNaFarVq/2ry6jnqIep56q/ojDYIGQyNWo0yjW2NGU1XTVzNXs1nzvhZei6EVr7VPq1drTltHO0x7m3aH9qSOnI6XTo5Os85DXbKug26abp3ubT2MHkMvUe+A3k19WN9CP16/Sv+GAWxgacA1OGAwsBS91Hopb2nd0mFDkqGTYYZhs+GoEc3IxyjPqMPohbGmcYTxbuNe408mFiZJJvUmD0xlTFeY5pl2mf5qpm/GMqsyu21ONnc332jeaf5ymcEyzrKDy+5aUCx8LbZZdFt8tLSy5Fu2WE5ZaVpFW1VbDTOoDH9GMeOKNdra2Xqj9WnrdzaWNgKbEza/2BraJto22U4u11nOWV6/fMxO3Y5pV2s3Yk+3j7Y/ZD/ioObAdKhzeOKo4ch2bHCccNJzSnA65vTC2cSZ79zmPOdi47Le5bwr4urhWuja7ybjFuJW6fbYXd09zr3ZfcbDwmOdx3lPtKe3527PYS9lL5ZXo9fMCqsV61f0eJO8g7wrvZ/46Pvwfbp8Yd8Vvnt8H67UWslb2eEH/Lz89vg98tfxT/P/PgAT4B9QFfA00DQwN7A3iBIUFdQU9CbYObgk+EGIbogwpDtUMjQytDF0Lsw1rDRsZJXxqvWrrocrhHPDOyOwEaERDRGzq91W7109HmkRWRA5tEZnTdaaq2sV1iatPRMlGcWMOhmNjg6Lbor+wPRj1jFnY7xiqmNmWC6sfaznbEd2GXuKY8cp5UzE2sWWxk7G2cXtiZuKd4gvj5/munAruS8TPBNqEuYS/RKPJC4khSW1JuOSo5NP8WR4ibyeFJWUrJSBVIPUgtSRNJu0vWkzfG9+QzqUvia9U0AV/Uz1CXWFW4WjGfYZVRlvM0MzT2ZJZ/Gy+rL1s3dkT+S453y9DrWOta47Vy13c+7oeqf1tRugDTEbujdqbMzfOL7JY9PRzYTNiZt/yDPJK817vSVsS1e+cv6m/LGtHlubCyQK+AXD22y31WxHbedu799hvmP/jk+F7MJrRSZF5UUfilnF174y/ariq4WdsTv7SyxLDu7C7OLtGtrtsPtoqXRpTunYHt897WX0ssKy13uj9l4tX1Zes4+wT7hvpMKnonO/5v5d+z9UxlfeqXKuaq1Wqt5RPXeAfWDwoOPBlhrlmqKa94e4h+7WetS212nXlR/GHM44/LQ+tL73a8bXjQ0KDUUNH4/wjowcDTza02jV2Nik1FTSDDcLm6eORR67+Y3rN50thi21rbTWouPguPD4s2+jvx064X2i+yTjZMt3Wt9Vt1HaCtuh9uz2mY74jpHO8M6BUytOdXfZdrV9b/T9kdNqp6vOyJ4pOUs4m3924VzOudnzqeenL8RdGOuO6n5wcdXF2z0BPf2XvC9duex++WKvU++5K3ZXTl+1uXrqGuNax3XL6+19Fn1tP1j80NZv2d9+w+pG503rm10DywfODjoMXrjleuvyba/b1++svDMwFDJ0dzhyeOQu++7kvaR7L+9n3J9/sOkh+mHhI6lH5Y+VHtf9qPdj64jlyJlR19G+J0FPHoyxxp7/lP7Th/H8p+Sn5ROqE42TZpOnp9ynbj5b/Wz8eerz+emCn6V/rn6h++K7Xxx/6ZtZNTP+kv9y4dfiV/Kvjrxe9rp71n/28ZvkN/NzhW/l3x59x3jX+z7s/cR85gfsh4qPeh+7Pnl/eriQvLDwG/eE8/vMO7xsAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA29pVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo1ZmViODRkMS1iYWQzLTRiNmQtODU3Zi0zYjAyM2E2NWM5NTUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NTYzMDIwMTEzMUI4MTFFNEIxMTNFM0E5RUVEODk2OTIiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NTYzMDIwMTAzMUI4MTFFNEIxMTNFM0E5RUVEODk2OTIiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NTNjZWFiMmUtNzZjYi00ODlmLWFjMzktM2JjNTNiY2Y2NGNlIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjMxMDNBRjQ1MjQyQjExRTQ4QUFDOEFEOEYxOEE2N0NEIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+AxfLHgAAA7lJREFUWEfFl0mIlEcYhh11FteLOkTcGEaG4IIX0eQSt5ugXjSuCCqiB0/jjiIokSQQIypGQRA1KiLxIHpJRlEQPKggwZOKG7ih0bjGnc7z/vNWW/13T/c/CegLD9P1ft9XVVNdf/3VHXK53GclkwZtfFgNk2E7XIAnkDMv4RLshhnQ3WX/X3TWE9bCAwgDVuI5bIZ6d/PfRAdT4A6kB7gLLbAfDsFpuA/pvGew0N1lF0VV8JM7CTyC72Go04qkGGyA9GodhBqnlReJGvxXF4oP8DP0cEpFkdsFNsI7CP1oxSpPgqT4P9dGm+BQu0XtSIi/woMOlRYJ2uUh+W8Y7lBmUaMVbHRT7cGgPRP6XeRQoQhot4fZatnHOZRZ1GjwHfAURtuWr5V4A+pbsS8c+ihMPWphlj/azixqwuChj4eQPw/4rM0ZYptttwpDh0zYuX9Buw4S8tODv4XJDiei3Q3uOa5z4uOmpjHJAbHediaRX3HwIPx4FWbaTgI6XkOgyXZFkZt5cIlYA5yAf2Cv7SRwHtTBHVtFIjYelrmZiPZo0IYNE/jNobIirwdMcjMx9MipgxZbBcLX4Jq1clbZTkR7NsSTGONQItqdQCvVxVaxXCgO2yoQ/rIoR7Q1iSW25HUH1a2BTTAd9GR0FE5rFUbo+IitIhFbFeWVmsQIfywQfh84BzphX8FYOAArnJIkvQB1esZWSREvOwkJ7zvo56baY+A1TATdGcJYojkk/WnjUWKUETmrnRtY6ZBi39g7ClW25X8FWvqVENfqdGxSgm4ywRzmuiIRSz92+t5nO6z471GsoB/aWon4nRD4RUFdo4KxzjUFwq80eB3Er98tkGw2/g6A+AoXc0MJXUHHo4zbUJf0atEuO7hEuzGKB36AbaDLTDqWJ3QQ3wPy36tEWxsrxIoGl/D6Rjkxp2ArnIVS98p3oYN6CAeSdm3+O+Sz3ulamZKDS/idIdSnuew05c2CeCJXHEqC86PATejvUJjENDdLivg+CPUxj6HWacqLr3ybbLcKY08UvA5tPhVpkTsE3rs2zVLnjALdluXpYBqYFAdh1MBxJwi9A5oh062WvOWuSzMXeoPuG8Fb4LJCEdAk4pUQ10ATyZ9ybYmcpaBXc1z/NZz0Z/1T853etkiaB/r+4o7EVTgGmqR+mPwBt+Bbl6r2S9hpXzVagSug86HBaZVFci/Q86zLZHoiafRfL3ZpXni1UHC2tFt0oB8bU2EXXISwkYSWVC+avTAHql2WTaV+Mn86ch3+BRRWO3jNtdA2AAAAAElFTkSuQmCC</Image>
    <ImageMD5>9c0ec9ce7c131da83a167dddae729933</ImageMD5>
    <Name>Remote Desktop</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>0dc51386-cac8-47e9-8487-3a8a617a6308</Stamp>
    <Tools>
      <AllowRunViaAgent>true</AllowRunViaAgent>
      <ConnectionType>Template</ConnectionType>
      <TemplateID>24388d51-ac5e-4ba2-b124-904019a582b6</TemplateID>
      <TemplateName>Remote Desktop</TemplateName>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>572e46bc-8dbd-42d6-b8d7-60ae955a63ba</ID>
    <Image>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vLDwG/eE8/vMO7xsAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA29pVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo1ZmViODRkMS1iYWQzLTRiNmQtODU3Zi0zYjAyM2E2NWM5NTUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QjU4MTY5OUQ0QUVGMTFFNEEwNEQ4NDU2NEM1QkQ2M0MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QjU4MTY5OUM0QUVGMTFFNEEwNEQ4NDU2NEM1QkQ2M0MiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6OThmNWNjMDQtNDRlMC00NzUxLTg3M2UtOWY3MDQwZWE1Y2IxIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjFFMkVCMUE3MjNFNzExRTQ4QUFDOEFEOEYxOEE2N0NEIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+faJYugAAAppJREFUWEfFlr1LVmEYxjURIhSiQWwKdNF/QJyiIRxqeUWhNdBFwrCgVacgCIdyjKAxAsGhqUGcpC0nbaimoET6IIoordP1e9/rOT6e9zl1ED1d8AOf677u+znn9Xx1ZFn2X0madZI06yRp1knSrJNKOnd7p0ucEafFCXNXfBU/xCNxSuCTIdvl9sNJA4bEPfFS/BaZeSBmo3XgvqAW1vTQy4whj60mNcyLPRFvEPgl3hY8+CKoFX1g1rzH/10KTkeNR820t0lLAX72b1HDUcPs8n+HiqtR+LhY9XYHpcJkIXicTHrblmR0ihdRoAqfxA3BHfHBXlXYq9PbNw9gLCpW5arb6b9SqFVhzO3NAcuFYhUuup3+84VaFZZDc4/4HhWqsi7Oin5xmIuXPXs4gEZkwnNxSXBgJ8UF8UzEmSrQQy8zmMVMZseZBgfAIzQYT0R386eJJI+LNM7Bjrhs+Duukd2/yCx53YI98hzmmhfvRK+zbVKNF9KmszDjErWZyCdT+iJSrVewF9k1jG0vFp0plTJzzsKAbfyByJ+zXSplFp3dZhEap1wvlTLhdt2zlQvPtf3bq0TKTDmbsdj1Ytb1UikTLtjPtnLhudawVSplwut8l8WGFyuul0qZJWff2MqF59qSrVIps+LsBosFL/iAGHGmTaoNivC8eGg7F55rZAZtt0m1ERE+cBYw+sRHG+/FqLO55A2LV87wCTbsUi5nqJEhm8qMCvYgw559oTAuwtcMR/dU3BI3xWPxU1CD682mhKhFOXroZQazmBnOnL3G3daSjAnBZ1UYUISzu+Z4qcg4m5oB7DHh+EGpwHP9jtgSnAFH/Fpw8eX3/b9E1j30MoNZzGR2v2Mtpb7V6yRp1knSrJOkWR9Zxx8IIvYRxEjnCQAAAABJRU5ErkJggg==</Image>
    <ImageMD5>54421fe69ca71820dd9831a94c28b569</ImageMD5>
    <Name>ServiceNow Search KB</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>de835e7e-765c-426e-ae51-65bb563996bb</Stamp>
    <Tools>
      <ConnectionType>Template</ConnectionType>
      <KeepTemplateHost>true</KeepTemplateHost>
      <TemplateID>3836133a-1368-4af9-8014-6237ee83387c</TemplateID>
      <TemplateName>ServiceNow Search KB</TemplateName>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>c49e80c8-dcc0-4b37-b3f0-3038fa975737</ID>
    <Image>iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAZYSURBVFhHrZcJUFNXFIZv2JKgBBUBQQtxYwsBBIGgiHbRFk1ArUutrYDgQseKy9TamXbs2GldhlpFQauMdaXuCGKwTlGoWIW6okhAwo7K5orSGJK/9yUgCYJJkTPzz3v3vbt877/nHggB0CN9tWqViZ+f34qoqKjj40NCorvqY4y6fDjb19I2dhzPfb6I6xo9hucaM9aaqo/rXAFxmeRi5SYOD/9gx86dCbGxscUSiSRh5YoVBT/8uG7dhPHjxoY4mrp+4kZcooOtXOeJ+lLxXCODeG4RgVy34KGsAZ3X0mv0MWexJrpauH82mnMydoxFeYzIXL4gyEK+gF4jfU3kX4a6yXfEry2Tnjnz6PRpKTIzM5GTk9OckZEBaeYZpKelNa7/eok8auwg+adeLHmEv7k8IoBNZVE2P8C8LMiZtYttRvi6a+oB8NgmVmFCzqFIf4snC/0JZg0nmDmUYI4rQfRoG6xbtQi/7kjEscO/4/Hjx3RIRzx6+AgpB/Zh25ZNWL1gFma6cPHxMALxO1ROBJHeBDETbDDcecgG2r1rAGtLs0HTfbg3FvkSzOCbIlI0BjEhExAxzh8/rV6CpISfsX3rZhxKSUFGxmmkpqZqlJaWhlOnMnDgwF4kbd2ERArx/bKFmCPyQ1TwBHw+ZizEfI5qdoAN3EY4bdZdUw/AimtqH+bF/ocBkNiaQaVS0cfAKWr3osWLEbd0KZYtW061rHstX464uDgspfo7L18znolpQnelyMFaJXBx+oU2uwWwC/di52kBTKBqbaWPgYaGRhTJZCguLtaopIRRSbdi+hQVydDY1KQZz8TMUUJlkCEAawowtR3AzhRKpRagN2K6t0AZNNgAAE/jAOcVwP2HzbhZUf/WYuaZ7u2hDHI0yoEOgJ468KJFgavyOpQ/eIjWtjya7mUMgKWZ3TRv7ls5UHKvCWmXZBAnnMfc5Iv481qJ1gEfgTLQ0Ba8rQMqtRpXiqsQuu0CXBIK4bslH/FHz2nezRjlafgUMDlAj2GPHLhV2YA75fcRuTcPPrtKELznLlYfyMEdeZVmnql0CwINngLLnjvQ0vIv1py8Co/kUvik3Mfc3RdRXVXd9hZaAEM50NNTUFhZj2P5pRDsqYDz0WaM21uEc3kFkNU0at5rHBB6KP0HGZEDugDGOlBd/xAhhyvgkK6Cd2oDtksvQa182fZWG+EMgL0RAF3lQAH9wttVDXpf3a6iyjp8k1UK/tmXEGQpEHciH/LyKjqmoz8zTzjdAn9jklDSqRKqaWY3PWmGvLoeCoWCdusIJS3VR69XwuuPR3DPBaacKMK167c0YzpHmFEO0DogEWq3QGyrdaCgog5xZ8swLaMMu+n5vlv14NWXXS+tgURai6HZgM/xeiRLL6OmrunV+3Yx80gowGhDOcDjmtmJdQBaqQNnrt4F/2AV+mWpIZQ24MdzMjxvboaafn38hXLwMxTgn3iO6P2X8aypkU7TdYR5UgBDDvDoMRR7cvIWjiKYMlDrQEltIxKzCyFKf4ChtKaMSG/Gxqxi5BbIEXyiDnaHniEwuQA5+Tchq33969sdYAB87YzIAbGAnbeQOjCZArSfgpctL7AvuwCBR2rhmKqEx8FavL/vDpx/q4FDkgxrDmdD0fJc07e7kFAAP4MOUIApAq0DoTb6deAe3dv952/CnVa5vkkVGJAgQ7+NN/Du5izclhWjsFp75rtSew74Gc4BBoCdF+ND8BEF6FwHFC+eIzHzCvqv+QuslVnot0qK5PRsqNv+4r0pxMZuwWQKEE0BPhzweiVk6kHVgyasPXIRtl8cwZz4k/R43tfr05WYeaYIPJSjjAEI9WDnzW8D6K4SPnnajD3SXNySlbU9MRwMgI+tAQArjhYgyotgUv/XHeip/pcDzBZEUoCJFICpA70VYqFQ6U0d8HyjA/Tf8smenMIIxgEb8151INRDQAH6wcuNv013TT0ASwuTASHDzaTzhARTR9hofhv0lt4bbK0W8a2eOg+x/1Z3TT0Ajhnp425LvgsZxsoNciBwYhG1EyEqZ5ZWtK1i2kPoVSOde0dGtM3IoU3MvT1zb0LUAfYEI23ISVNChLpr6gHQH44mjjzibtuXTOWak3VsU7KRan1nWbTLRHt99Yxpd5I5czUlG+h88dYcsnSgJRnZsSbIfwMWuJPii8buAAAAAElFTkSuQmCC</Image>
    <ImageMD5>027e60a16e01f544dd12906eb5e8b6f2</ImageMD5>
    <Name>ServiceNow Search Tasks</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>b68f7717-1ad0-4524-9452-8ea4cf764b77</Stamp>
    <Tools>
      <ConnectionType>Template</ConnectionType>
      <KeepTemplateHost>true</KeepTemplateHost>
      <TemplateID>8969001a-3c7b-4277-8962-895a105ba9d7</TemplateID>
      <TemplateName>ServiceNow Search Tasks</TemplateName>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>1b6ea412-ed2c-4fe7-be0f-ee67820ee362</ID>
    <Name>SQL Server Manager</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>2bcb8f0d-72b3-4119-b08a-95717b37b99b</Stamp>
    <Tools>
      <ConnectionType>Template</ConnectionType>
      <TemplateID>c62d3f7e-b9ff-4593-94e3-bf91989fe67e</TemplateID>
      <TemplateName>SQL Server Manager</TemplateName>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>722027e7-0163-4bdb-b48b-789cffe03081</ID>
    <Image>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vLDwG/eE8/vMO7xsAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2tpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo1ZmViODRkMS1iYWQzLTRiNmQtODU3Zi0zYjAyM2E2NWM5NTUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RDhFODZDNDU0MTU4MTFFNEIyQkY4RDM5NDgzMTJDQzQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RDhFODZDNDQ0MTU4MTFFNEIyQkY4RDM5NDgzMTJDQzQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MDA4NThDMkQ0MTU3MTFFNEIyQkY4RDM5NDgzMTJDQzQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MDA4NThDMkU0MTU3MTFFNEIyQkY4RDM5NDgzMTJDQzQiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz5ItEFeAAAAtUlEQVRYR+2QQQpEMQhDe5M57Zz2H8KpiwyVSOhCbBe/8EDiA0OHmY3P97ET+O23wB0FTr17fiBbdnBfAZ8VlQ48ChSVDrwQdEMFfFbsOpN0B9Z7FCh2nUm6A+u9EHRDBXxW7DqTdAfWexQodp1JugPrvRB0QwV8VlQ68ChQVDrwQtANFfBZUenAo0BR6cALQTdUwGdFpQOPAkWlAy8E3VABnxWVDjwKFJUOvBB08xb4FziHjR+CN6CtivW0egAAAABJRU5ErkJggg==</Image>
    <ImageMD5>dabc3d52b2e46bd44a77b6c19e8d9791</ImageMD5>
    <Name>TempDB Usage History</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>b06165fd-57ef-4b05-a7d2-305061123064</Stamp>
    <Tools>
      <ConnectionType>DatabaseQuery</ConnectionType>
      <DatabaseQuery>SELECT		[rundate]
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM(([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])*8),''kb'') TotalDB
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([unallocated_extent_page_count]*8),''kb'') Unalocated
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([version_store_reserved_page_count]*8),''kb'') VersionStore
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([user_object_reserved_page_count]*8),''kb'') UserObjects
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([internal_object_reserved_page_count]*8),''kb'') InternalObjects
		,dbaadmin.dbo.dbaudf_FormatBytes(SUM([mixed_extent_page_count]*8),''kb'') MixedExtents

		,REPLICATE(NCHAR(9751),(SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5)
		--+''|''
		+COALESCE(REPLICATE(NCHAR(9750),20-	(
					 (SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					)),'''')
		AS [Version|User|Internal|Mixed|Empty]

		,COALESCE(REPLICATE(NCHAR(9419),(SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'''')
		--+''|''
		+COALESCE(REPLICATE(NCHAR(9418),(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'''')
		--+''|''
		+COALESCE(REPLICATE(NCHAR(9406),(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'''')
		--+''|''
		+COALESCE(REPLICATE(NCHAR(9410),(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5),'''')
		--+''|''
		+COALESCE(REPLICATE(NCHAR(9675),20-	(
					 (SUM([version_store_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([user_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([internal_object_reserved_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					+(SUM([mixed_extent_page_count])*100.)/SUM([unallocated_extent_page_count]+[version_store_reserved_page_count]+[user_object_reserved_page_count]+[internal_object_reserved_page_count]+[mixed_extent_page_count])/5
					)),'''')
		AS [Version|User|Internal|Mixed|Empty]	

		
FROM		[DBAperf].[dbo].[tempdb_pagestats_log]
GROUP BY	[rundate]
order by	[rundate] desc
</DatabaseQuery>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>SessionTool</ConnectionType>
    <Encrypt>true</Encrypt>
    <Group>Getty Images</Group>
    <ID>d4b931bc-e039-486f-af49-4e738ba5a513</ID>
    <Image>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</Image>
    <ImageMD5>b2d6ddf24d7797e4e2ada899be5dae0d</ImageMD5>
    <Name>WhoAmI</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <ShowInTrayIcon>false</ShowInTrayIcon>
    <Stamp>277b2df9-a490-4154-b028-51430853a7a5</Stamp>
    <Tools>
      <ConnectionType>DatabaseQuery</ConnectionType>
      <DatabaseQuery>select ORIGINAL_LOGIN(),@@ServerName</DatabaseQuery>
    </Tools>
  </Connection>
  <Connection>
    <ConnectionType>Group</ConnectionType>
    <Events />
    <Group>Getty Images\MSSQL</Group>
    <GroupDetails>
      <GroupType>Software</GroupType>
    </GroupDetails>
    <ID>a054d822-2af4-4e8f-87f7-a3e2d759a355</ID>
    <MetaInformation />
    <Name>MSSQL</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>c1668ed8-1611-4ae0-983c-7e4a1b09ffd2</Stamp>
  </Connection>
  <Connection>
    <ActiveDirectoryConsole>
      <SafePassword>vGo7eu0EIRD5auStWjSmmg==</SafePassword>
      <ShowComputersOnDashboard>true</ShowComputersOnDashboard>
      <ShowGroupsOnDashboard>true</ShowGroupsOnDashboard>
      <ShowUsersOnDashboard>true</ShowUsersOnDashboard>
      <UserName>s-sledridge</UserName>
    </ActiveDirectoryConsole>
    <ConnectionType>Group</ConnectionType>
    <Events />
    <Group>Getty Images\MSSQL\AMER</Group>
    <GroupDetails>
      <Domain>AMER</Domain>
      <GroupType>Domain</GroupType>
    </GroupDetails>
    <ID>1c94f0ed-8129-4ebe-9cb4-def4b3c7f101</ID>
    <MetaInformation />
    <Name>AMER</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>b3c3fa89-5b07-4192-94b5-c63db867dbe7</Stamp>
  </Connection>
  <Connection>
    <ActiveDirectoryConsole>
      <ShowComputersOnDashboard>true</ShowComputersOnDashboard>
      <ShowGroupsOnDashboard>true</ShowGroupsOnDashboard>
      <ShowUsersOnDashboard>true</ShowUsersOnDashboard>
    </ActiveDirectoryConsole>
    <AllowClipboard>true</AllowClipboard>
    <ConnectionType>Group</ConnectionType>
    <Events />
    <Group>Getty Images\MSSQL\PRODUCTION</Group>
    <GroupDetails>
      <Domain>PRODUCTION</Domain>
      <GroupType>Domain</GroupType>
    </GroupDetails>
    <ID>0b07a666-2ea4-4467-99fa-3257dff5f344</ID>
    <MetaInformation />
    <Name>PRODUCTION</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>512f008a-ffa4-416d-962a-4469d1fa4ecf</Stamp>
  </Connection>
  <Connection>
    <ActiveDirectoryConsole>
      <ShowComputersOnDashboard>true</ShowComputersOnDashboard>
      <ShowGroupsOnDashboard>true</ShowGroupsOnDashboard>
      <ShowUsersOnDashboard>true</ShowUsersOnDashboard>
    </ActiveDirectoryConsole>
    <ConnectionType>Group</ConnectionType>
    <Events />
    <Group>Getty Images\MSSQL\STAGE</Group>
    <GroupDetails>
      <Domain>STAGE</Domain>
      <GroupType>Domain</GroupType>
    </GroupDetails>
    <ID>2b99c73d-680a-4ebf-abbb-15339b724c64</ID>
    <MetaInformation />
    <Name>STAGE</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>99a5ddf2-49a0-4aef-9be3-8f881f9d3b07</Stamp>
  </Connection>
  <Connection>
    <ConnectionType>Group</ConnectionType>
    <Events />
    <Group>Getty Images\MySQL</Group>
    <GroupDetails>
      <GroupType>Software</GroupType>
    </GroupDetails>
    <ID>607f9e6a-e7f6-46af-8995-f05bc9d0928c</ID>
    <MetaInformation />
    <Name>MySQL</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>90462baf-0c2b-472a-a62f-89b952fcbf59</Stamp>
  </Connection>
  <Connection>
    <AddOn>
      <AddOnDescription>Windows Explorer AddOn</AddOnDescription>
      <AddOnVersion>10.0.7.0</AddOnVersion>
      <Properties>&lt;?xml version="1.0"?&gt;
&lt;WindowsExplorerConfiguration xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&gt;
  &lt;Folder&gt;\\seapdbasql01\SEAPDBASQL01_dbasql\DiskSpaceChecks&lt;/Folder&gt;
  &lt;HideNavigationPane&gt;true&lt;/HideNavigationPane&gt;
&lt;/WindowsExplorerConfiguration&gt;</Properties>
    </AddOn>
    <ConnectionSubType>2b657353-30dc-411a-891d-8874e457f35f</ConnectionSubType>
    <ConnectionType>AddOn</ConnectionType>
    <Events />
    <Group>Getty Images\Tools</Group>
    <ID>f3abb60f-accb-448a-96c4-808fe37f26e5</ID>
    <MetaInformation />
    <Name>Disk Space Check Reports</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <PinEmbeddedMode>False</PinEmbeddedMode>
    <Stamp>d73878b3-ad89-45ee-b1a4-e535c9f43280</Stamp>
  </Connection>
  <Connection>
    <ConnectionSubType>IE</ConnectionSubType>
    <ConnectionType>WebBrowser</ConnectionType>
    <DataEntry>
      <ConnectionTypeInfos />
    </DataEntry>
    <Events />
    <Group>Getty Images\Tools</Group>
    <ID>31821a44-40b2-403e-8445-6831e8099579</ID>
    <MetaInformation />
    <Name>Disk Space Forecasts</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <PinEmbeddedMode>False</PinEmbeddedMode>
    <Stamp>dd7fc4ae-454b-4493-916a-0f922da494a0</Stamp>
    <Web />
    <WebBrowserApplication>IE</WebBrowserApplication>
    <WebBrowserUrl>http://seapsqlorrpt01/ReportServer/Pages/ReportViewer.aspx?%2fTSSQLDBA%2fDiskSpaceChecks%2fDisk+Space+Forecast&amp;rs:Command=Render</WebBrowserUrl>
  </Connection>
  <Connection>
    <ConnectionSubType>IE</ConnectionSubType>
    <ConnectionType>WebBrowser</ConnectionType>
    <DataEntry>
      <ConnectionTypeInfos />
    </DataEntry>
    <Events />
    <Group>Getty Images\Tools</Group>
    <ID>e98b8ae2-57d5-4684-9392-e023e6bbab5e</ID>
    <MetaInformation />
    <Name>Index Health Checks</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <PinEmbeddedMode>False</PinEmbeddedMode>
    <Stamp>2e22ff26-dc99-47d1-aaa0-596ad94eef6f</Stamp>
    <Web />
    <WebBrowserApplication>IE</WebBrowserApplication>
    <WebBrowserUrl>http://seapsqlorrpt01/ReportServer/Pages/ReportViewer.aspx?%2fTSSQLDBA%2fIndexAnalysis%2fIndexHealthCheck&amp;rs:Command=Render</WebBrowserUrl>
  </Connection>
  <Connection>
    <ConnectionSubType>IE</ConnectionSubType>
    <ConnectionType>WebBrowser</ConnectionType>
    <DataEntry>
      <ConnectionTypeInfos />
    </DataEntry>
    <Events />
    <Group>Getty Images\Tools</Group>
    <ID>6538315b-95e1-4de9-96bd-fd2b10b540c5</ID>
    <MetaInformation />
    <Name>Production High Priority Health Report</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <PinEmbeddedMode>False</PinEmbeddedMode>
    <Stamp>754dd90e-c059-458c-b7ea-2066226ac99c</Stamp>
    <Web />
    <WebBrowserApplication>IE</WebBrowserApplication>
    <WebBrowserUrl>http://seapsqlorrpt01/ReportServer/Pages/ReportViewer.aspx?%2fTSSQLDBA%2fHealth+Checks%2fProduction+High+Priority+Health+Report&amp;rs:Command=Render</WebBrowserUrl>
  </Connection>
  <Connection>
    <ConnectionSubType>IE</ConnectionSubType>
    <ConnectionType>WebBrowser</ConnectionType>
    <DataEntry>
      <ConnectionTypeInfos />
    </DataEntry>
    <Events />
    <Group>Getty Images\Tools</Group>
    <ID>fc687699-78fc-471f-ba63-6041dd013bd0</ID>
    <MetaInformation />
    <Name>Server &amp; Database Lookup</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <PinEmbeddedMode>False</PinEmbeddedMode>
    <Stamp>81cbe1b8-9cf1-4d6d-9171-987fbaa60822</Stamp>
    <Web />
    <WebBrowserApplication>IE</WebBrowserApplication>
    <WebBrowserUrl>http://seapsqlorrpt01/ReportServer/Pages/ReportViewer.aspx?%2fTSSQLDBA%2fServer_Database_Lookup&amp;rs:Command=Render</WebBrowserUrl>
  </Connection>
  <Connection>
    <Children>
      <Connection>
        <ConnectionSubType>IE</ConnectionSubType>
        <ConnectionType>WebBrowser</ConnectionType>
        <DataEntry>
          <ConnectionTypeInfos />
        </DataEntry>
        <Events />
        <ID>ef2b42f1-9043-4760-92b9-4f125f8aaed2</ID>
        <MetaInformation />
        <Name>Knowledge Base</Name>
        <OpenEmbedded>true</OpenEmbedded>
        <PinEmbeddedMode>False</PinEmbeddedMode>
        <Stamp>a6c3cec5-92c5-428d-8581-1c34ebe2cce8</Stamp>
        <Web />
        <WebBrowserApplication>IE</WebBrowserApplication>
        <WebBrowserUrl>https://gettyimages.service-now.com/kb_home.do</WebBrowserUrl>
      </Connection>
    </Children>
    <ConnectionSubType>IE</ConnectionSubType>
    <ConnectionType>WebBrowser</ConnectionType>
    <DataEntry>
      <ConnectionTypeInfos />
    </DataEntry>
    <Events />
    <Group>Getty Images\Tools</Group>
    <ID>f081c252-b579-44b5-8a03-319c9e76788a</ID>
    <MetaInformation />
    <Name>Service Now</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <PinEmbeddedMode>False</PinEmbeddedMode>
    <Stamp>14f113d9-5405-4641-87a3-ae947247475e</Stamp>
    <Web />
    <WebBrowserApplication>IE</WebBrowserApplication>
    <WebBrowserUrl>https://gettyimages.service-now.com</WebBrowserUrl>
  </Connection>
  <Connection>
    <ConnectionType>Group</ConnectionType>
    <Events />
    <Group>Getty Images\Tools</Group>
    <GroupDetails />
    <ID>937a9b75-9d69-4a3a-95ad-c62617f6af1d</ID>
    <Image>iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAoNSURBVFhH1ZcJUBRnFsd7N5vEZCsxmmOjcUUkSBSMeAWMSdTdbAo30YpuDtEcqAmYhMOAksQjG1CMRNSICghiuJlhUG68uWYY7nMEuU/llJu5u/u/r2c6MZvKVmXPqv1X/auZpr/v99773vdND/P/qN+I139GUxwcHJ49ePDgtpqams3l5eX3ivd/kWatJ/n7+wfGx8crKioqWiYmJlaL//tHeuztt99eHRQU5CuVSi8UFBS01dfXQ6/Xw2g0gjRHfO5n9YSzs/Nfvg4IOC6RSIoVCsVEX1+fMOgH0URl4rMmTZ06dY6Xu/vrYWFhgVlZWbllZWWDPT094tN3xbEs+np6dKH7dlvbMozVEfcPLMUpzLK2tp6bnJzcMzw8LA65K57nwdIEHMeZPhcWFh6NjIw8nZOTU6NSqbTj4+Om+z+WgTLu7+2FqqoS1y5mQxofh/DIc8bAszFFh9OuN4WoespFtFmenp5e4tgfgD+1UELh+nMyGPSU4W3UVFbgcnYWJAkJiIyJwxlZKiKuF+E7VRciOrXcri6+2rmdL3i1js8R0WYFBwenCRMJWf4U/L1/LL1Oh9u3ulFRVoqLWQSUSBGVKEV0xiXEK6shaepHfB+H8DtAEK2ifxewq4k1vlLJKl4s4+QrS3mZiGaYTZs2/YkaRSdM/D1MqMKPpVGr0dXZgZLiImRlZkKSlISE86k4n6vAxfp25A0ZkEc9lkWOHQGCbwOH2jl82cLCt5GFTyOPHSqj3lHJye3yuSLbPC5cxDNMREREjgARu9SksbExNDc1QSGXIy0tjYAyyNLSkS0vRGFjO1QTRlRpgfzeCaTXtOBEymUEJmXjuPwGTnYZ8XUHj73NLHbeZOGmYrFdxWNThVFnc5UrsLjIlc3K5A+JeIaJi4srEKAcZT04OIjz589DKpMhNfsSckvKUdN5Cx2TBlBSoEqiiYqT194HpaoRt7r7EH7iJNw+cIX7Th9s3bodLl/4Y0+TEZ4NPLbXsHCuYPFmOQ+nQqP2yTSuYHoyVzlNynqLeIaJiYnJNQVA6x+fmIi8yloMsjyokhgk36Ll7zAALeQbGhay3EJIE5LQ1tgKeW4B9gSdRJCyAccaxrCvuAs7UkrhUavHtloOb5WzeE3JwknB44VrRs1D8Wz+lGi2akqk/j0RfzeA4Tt3EC2RYUCA6sk6Ht3kLj2PujvjUNbeRPqla/D/yh+x0fEoVZYiwM8fARkKxE0Cx7sBvw7ApxWUOcHLWLxayGJNLosXr/OwzzSo7zljLPhViLH6nlPGP4t40xKYAmhva0XshXT0098C2ATX0pW2f251PaLPRuD4N0dwSpIKaU0Tkq7KERUSikPnr+IUDTrQzGHXTQ6ulPkmgq8j+B8I7njZiGUXedgkGyaZYKOcOWYsZ4IMz4v4uwFUVZQjMeuKKYBOAgtu1/Boo/1RPTCJ/QcCcDRaAuUENR/dO3ejHzLZBURdyEIANdwe6vSPCf5OOYfXqex/JPgKgi9ON+LZVB5WcfoJJkBXyBzQF9N1gYi/G4C8oIDWV4luarJWNY8WchP55gSP2nEeed2jKKJDL4cOy8wBnvY5BXGtBPIrl7Envw3eVPpt1HBvFLNYm89iFcGfSzNgkdSAhYksLMN148xebRHzhVrO+Kpnifi7AWRmZiGtRIUW2o0CtJ5cR64hePkojxKC5w4B2QRP7uURQ80SVNoNH09PLFrthO3Fk3CpBDbkG/EKwV8k+HKpHgujtbCLMsDipHqM8Z4oZXwmLjOfjk4X8QwTGxubJwQgS05GSmUjVFTeqjHe5ApyKcELh3nkDPG4SPALBI+7xeEs7Uu/yhHMsLLB3Cem4TnXv8KlGlh/xYCX0/V4PkmLJTEa2EaosSBCi9lHx0cZz9EKxnMkjfFoul/Em3aB6RyIkyQhpf42immNlQQUrCDnE/jaII/sfh4pBE+krjxHp9zJFg5HqOsd33LFsoXzYWVlhZcjqrH+OrA6WQOHODUWRU5ifug45odN4qlvRkcYj6FqxuNOoog2iyogFwI4ExWHpKZhXKc1FoCCr1LGlwic2csh5TYHSReHqHYWIU0sguqNONQGrPs6HvMsZ2PJAmtYr92KtVeAFySTWBY1DrszY7A5NYJnQsYx8/DQMPPJoIrxHIwQ0WZRBRRCAMHh5xDbPI502gYZlGlGD4d0gqZSuWVdLBI6WHzXyiK00YhjdUb4Vxuwp4bH++kdsLSxxfPLl8JyzhwsPVqKlTIO9mdHseD0CGyCh+g6ilmBg8O/9hmsv/fzwWMi2iyqgCmAo2HfIbJJA8ktQNrJkVlICJpAGUe3GnGWjtfTDQYcvaHHgWo9vijXwbNYB9cS4Bmnd2D/jDUWzZsDi7VucJQB9hEjsAsbxsLwYSyJnsDTocNDDx4eaZx6bMRPRJtlCoBncSg01gSIbOUQSVvhHDmSoOGNBrqvx/E6PQJVevhV6fB5mRZeRRp8mK/GViX1wf5EzH1qBlYsX47ZFnNhf7wGK5L1WJ4wBgfpGF5IUcMubmxweshY8+NhI7tFtFnC+x6v12DfqVgE1vP4ltb2RL2BrgYTNIgyPlyro6x12FeuhW+JBl5KDdwK1HDJmcSWXD3WpfTh9/MXY5n9IthazITlBg+suQq8lDaBl1LHsSptEvYxwyOPBAy2Pby310NEmyUEYJgcg29wNPbX8vCj8voTTLAffed+WaHF3nINPi/VYFexBjsp80+UargqKHu5Gu9SIO9UALabvTHvyemwnvkYLNZ/hFX0crBSMgqHqFEsPTMJ229GMMW5eugep9J1ItosIQDt6BC8TsTCq4LHrhItdhPMl/yZaN8ygpO9yTup/O7kHaVaOnw0eK9Qg82lPFaHyPGopS2st30Lh3MaLA2hA+hgP6w8q1iL93PqZmxMinxgycENhPz7V/OEhATF2EAPdnwrhWsRB3eaUMjSW8iYSr6bKrCb1n0X+VOyZ6UWH1Eg24vU2JI/iY2XJrE2RYdVsXospvcv26+6YOWm7Jj1hkz2+JpjHg/OfnMpYR4w035GiYmJioHudmw9kYIPy4BPKDMv6vBPK3XwoWXwrtYSWAsPCsSNMt5KJXe+psOGDDpy4zRwPNIJO5/iASuXzMuz1p/b91ub7cJvh2nm2X+BKADl7dYmvBeSAVcVBUBgd8rUnTL9mDJ1pfV2oa+/LVdZbEwlaMQAVhyomljkeU359KboI79z/ExY05nm2f4FCT9COhrqsDk0E1urABdqrnfztNh81Yg3M+mNJnYUq47UGRz3KGqe/VB2xtLp0Jb7H178tDj839aj0dHRDf2dzdhw/BJeywacYmjrHGmAw/7i5sXuGfE2b5xye8R6wyJ69j7zkP+s7vPx3hkfEX4GDm5RvXYeORnzNp72fdzeRXhjecj8yH9fjzBTpq1kmAdniJ//B2KYvwFpifGGmZtrdQAAAABJRU5ErkJggg==</Image>
    <ImageMD5>169bf5e2990792fdd45f0d7a26fdf599</ImageMD5>
    <MetaInformation />
    <Name>Tools</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>cd0d4809-a0e7-4d47-b22f-672a0cf22e1e</Stamp>
  </Connection>
  <Connection>
    <ConnectionSubType>IE</ConnectionSubType>
    <ConnectionType>WebBrowser</ConnectionType>
    <DataEntry>
      <ConnectionTypeInfos />
    </DataEntry>
    <Events />
    <Group>Getty Images\Tools</Group>
    <ID>04ee369d-c16a-4401-b46d-feab651083d0</ID>
    <MetaInformation />
    <Name>VM Lookup</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <PinEmbeddedMode>False</PinEmbeddedMode>
    <Stamp>f30b3d06-f305-4084-af78-7764ea21a7ac</Stamp>
    <Web />
    <WebBrowserApplication>IE</WebBrowserApplication>
    <WebBrowserUrl>http://seapsqlorrpt01/ReportServer/Pages/ReportViewer.aspx?%2fTSSQLDBA%2fVMLookup&amp;rs:Command=Render</WebBrowserUrl>
  </Connection>
  <Connection>
    <AllowClipboard>true</AllowClipboard>
    <AllowPasswordVariable>true</AllowPasswordVariable>
    <ConnectionType>Credential</ConnectionType>
    <Credentials>
      <CredentialType>LastPass</CredentialType>
      <DefaultAction>CopyPassword</DefaultAction>
      <LastPassAccountName>steve.ledridge@gmail.com</LastPassAccountName>
      <LastPassMode>Integrated</LastPassMode>
      <LastPassName>Getty Domain (AMER S-)</LastPassName>
      <LastPassSafePassword>SSK9t005G+QagyE2coYqug==</LastPassSafePassword>
      <LastPassUuid>3894405556</LastPassUuid>
    </Credentials>
    <Encrypt>true</Encrypt>
    <Events />
    <ID>094fe164-7c69-4dd0-bd7a-15d84c6f7327</ID>
    <MetaInformation />
    <Name>AMER\S-sledridge</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>9a55e1ab-1b3f-4351-9562-063e5bb72c99</Stamp>
  </Connection>
  <Connection>
    <ConnectionType>Credential</ConnectionType>
    <Credentials>
      <CredentialType>ConnectionString</CredentialType>
      <SafeConnectionString>kjfXL/d1biI4ria5nHRYoURHNBfaZzwPlpEwA9TlXw3MUjLV+SgikZt3u+OcYw2ZAjEIdFY+1ZJ1YGjuuYOMs3hNZ62ISZdX4w4yrhylx8C31eytgeM00Ey2NWT/U3/s5SVc7bNL5e1LytfxIJGy0yimw+fuzAvm</SafeConnectionString>
    </Credentials>
    <Encrypt>true</Encrypt>
    <Events />
    <ID>ef1f8090-0d07-4847-9c52-1faa55105217</ID>
    <MetaInformation />
    <Name>DBACentral</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>fe821af1-d465-4f2b-a52f-38c4180bcb9b</Stamp>
  </Connection>
  <Connection>
    <ConnectionType>Credential</ConnectionType>
    <Credentials>
      <CredentialType>LastPass</CredentialType>
      <LastPassAccountName>steve.ledridge@gmail.com</LastPassAccountName>
      <LastPassMode>Integrated</LastPassMode>
      <LastPassName>Getty Domain (PROD P-)</LastPassName>
      <LastPassSafePassword>SSK9t005G+QagyE2coYqug==</LastPassSafePassword>
      <LastPassUuid>3894127506</LastPassUuid>
    </Credentials>
    <Encrypt>true</Encrypt>
    <Events />
    <ID>ce373f46-6203-4205-8a7d-3e80fad7f604</ID>
    <MetaInformation />
    <Name>PRODUCTION\P-sledridge</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>49d79aa3-6575-40b2-bc19-bdaaad4b2281</Stamp>
  </Connection>
  <Connection>
    <AllowClipboard>true</AllowClipboard>
    <AllowPasswordVariable>true</AllowPasswordVariable>
    <ConnectionType>Credential</ConnectionType>
    <Credentials>
      <CredentialType>LastPass</CredentialType>
      <DefaultAction>CopyPassword</DefaultAction>
      <LastPassAccountName>steve.ledridge@gmail.com</LastPassAccountName>
      <LastPassMode>Integrated</LastPassMode>
      <LastPassName>Getty Domain (STAGE S-)</LastPassName>
      <LastPassSafePassword>SSK9t005G+QagyE2coYqug==</LastPassSafePassword>
      <LastPassUuid>3891102876</LastPassUuid>
    </Credentials>
    <Encrypt>true</Encrypt>
    <Events />
    <ID>9fdbd0ae-4b50-462d-a0c1-277f759c9501</ID>
    <MetaInformation />
    <Name>STAGE\S-sledridge</Name>
    <OpenEmbedded>true</OpenEmbedded>
    <Stamp>80de83be-bfe9-475c-ba98-93d5448ec3e2</Stamp>
  </Connection>'

SET @XML.modify('
    insert      
        (
            sql:variable("@XML2Add")
        )
    as first into
        (/ArrayOfConnection[1])
')




DECLARE		@XMLData	VarChar(max)
	SET	@XMLData	= CAST(@XML AS VarChar(max))

--SET @XMLData = dbaadmin.dbo.dbaudf_FormatXML2String(@XML)
--exec dbaadmin.dbo.dbasp_PrintLarge @XMLData

exec DBAADMIN.dbo.dbasp_FileAccess_Write @XMLData, 'C:\RemoteDesktopManager_Full_Import.xml',0,1

