;WITH		SQLInstances				-- BASE GROUP OF SQL Instances In SCOM
			AS
			(
			SELECT		DISTINCT
						UPPER(TargetMonitoringObjectPath) as [FQDN]
						,REVERSE(UPPER(PARSENAME(REVERSE(TargetMonitoringObjectPath),1))) [ServerName]
						,REVERSE(UPPER(PARSENAME(REVERSE(TargetMonitoringObjectPath),1)))
						 + REPLACE('\'+TargetMonitoringObjectDisplayName,'\MSSQLSERVER','') [SQLName]
						,TargetMonitoringObjectId [BaseManagedEntityId]
						,BME.TopLevelHostEntityId
			FROM		dbo.RelationshipGenericView RGV WITH(NOLOCK)
			JOIN		dbo.[BaseManagedEntity] BME WITH(NOLOCK)
					ON	BME.BaseManagedEntityId = RGV.TargetMonitoringObjectId
			WHERE		BME.isDeleted=0 
					AND	SourceMonitoringObjectDisplayName =	'SQL Instances'
					AND	REVERSE(UPPER(PARSENAME(REVERSE(TargetMonitoringObjectPath),1)))
						 + REPLACE('\'+TargetMonitoringObjectDisplayName,'\MSSQLSERVER','') = @SQLName
			)
			,InstancesAndChildren
			AS
			(
			SELECT		T1.FQDN
						,T1.ServerName
						,T1.SQLName
						,T1.TopLevelHostEntityId
						,T2.BaseManagedEntityId
						,R.SourceEntityId [SourceMonitoringObjectId]
			FROM		SQLInstances T1
			CROSS APPLY	dbo.fn_AllContainedBaseEntities(T1.[BaseManagedEntityId]) T2
			LEFT JOIN	dbo.[Relationship] R WITH(NOLOCK)
					ON	R.[TargetEntityId] = T2.BaseManagedEntityId
					OR	R.[TargetEntityId] = T1.TopLevelHostEntityId		
			)
			,Nodes			
			AS
			(
			SELECT		IAC.FQDN
						,IAC.ServerName
						,IAC.SQLName
						,IAC.TopLevelHostEntityId AS [MonitoringObjectId]
			FROM		InstancesAndChildren IAC
			UNION
			SELECT		IAC.FQDN
						,IAC.ServerName
						,IAC.SQLName
						,IAC.SourceMonitoringObjectId
			FROM		InstancesAndChildren IAC
			UNION
			SELECT		IAC.FQDN
						,IAC.ServerName
						,IAC.SQLName
						,IAC.BaseManagedEntityId
			FROM		InstancesAndChildren IAC
			)
			,A
			AS
			(				
			SELECT		DISTINCT
						E.FQDN
						,E.ServerName
						,E.SQLName
						,CAST(A.Context AS XML).query('//DataItem/EventDescription[1]').value('.','nvarchar(max)')	AS EventDescription
						,A.BaseManagedEntityId
						,A.ResolutionState
						,A.Priority
						,A.Severity
						,A.TimeRaised
			FROM		dbo.Alert A WITH(NOLOCK)
			JOIN		Nodes E
					ON	A.BaseManagedEntityId = E.MonitoringObjectID
					AND	A.TimeRaised IS NOT NULL
			)
					
SELECT		ServerName
			,SQLName
			,COUNT(CASE Severity WHEN 0 THEN 1 END) AS Message
			,COUNT(CASE Severity WHEN 1 THEN 1 END) AS Warning
			,COUNT(CASE Severity WHEN 2 THEN 1 END) AS Error

			,COUNT(CASE Priority WHEN 0 THEN 1 END) AS Low
			,COUNT(CASE Priority WHEN 1 THEN 1 END) AS Med
			,COUNT(CASE Priority WHEN 2 THEN 1 END) AS High			
			
			,COUNT(*)																				AS NumAlerts
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END)										AS OpenAlerts 
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END * CASE Severity WHEN 2 THEN 1 END)	AS OpenErrors
			,(
				SELECT '<span style=''color:red''><B>ERROR:</B></span> '+ EventDescription + '<br/><br/>' + CHAR(13)+CHAR(10)
					FROM A
					WHERE Severity=2 
					AND ResolutionState!=255 
					AND SQLName = A1.SQLName
					ORDER BY TimeRaised 
					FOR XML PATH(''), TYPE
			).value('.[1]', 'NVARCHAR(MAX)')+'<span style=''color:red''>--------------------------------------------------------------<br/><br/></span>'	AS OpenErrors_Text
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END * CASE Severity WHEN 1 THEN 1 END)	AS OpenWarnings
			,(
				SELECT '<span style=''color:red''><B>WARNING:</B></span> '+ EventDescription + '<br/><br/>' + CHAR(13)+CHAR(10)
					FROM A
					WHERE Severity=1 
					AND ResolutionState!=255 
					AND SQLName = A1.SQLName
					ORDER BY TimeRaised 
					FOR XML PATH(''), TYPE
			).value('.[1]', 'NVARCHAR(MAX)')+'<span style=''color:red''>--------------------------------------------------------------<br/><br/></span>'	AS OpenWanings_Text
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END * CASE Severity WHEN 0 THEN 1 END)	AS OpenMessages
			,(
				SELECT '<span style=''color:red''><B>INFO:</B></span> '+ EventDescription + '<br/><br/>' + CHAR(13)+CHAR(10)
					FROM A
					WHERE Severity=0 
					AND ResolutionState!=255 
					AND SQLName = A1.SQLName
					ORDER BY TimeRaised 
					FOR XML PATH(''), TYPE
			).value('.[1]', 'NVARCHAR(MAX)')+'<span style=''color:red''>--------------------------------------------------------------<br/><br/></span>'	AS OpenMessages_Text

FROM		A A1

GROUP BY	ServerName
			,SQLName
ORDER BY	1,2