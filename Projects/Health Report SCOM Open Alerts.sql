DECLARE		@SQLName		SYSNAME
SET			@SQLName		= 'SEADCPCSQLA\A'

;With		Parents
			AS
			(
			SELECT		UPPER(DB.ConnectionString_B87E82BC_1A85_4DE3_330A_13133CF5F9C3) [SQLName]
						,DB.BaseManagedEntityId
						,BME.TopLevelHostEntityId
			FROM		MT_DBEngine DB WITH(NOLOCK)
			JOIN		dbo.[BaseManagedEntity] BME WITH(NOLOCK)
					ON	BME.BaseManagedEntityId = DB.BaseManagedEntityId	
			--WHERE		DB.ConnectionString_B87E82BC_1A85_4DE3_330A_13133CF5F9C3 = @SQLName							
			)
			,Entities
			AS
			(
			SELECT		P.SQLName
						,E.BaseManagedEntityId AS ManagedEntityID
			FROM		Parents P
			CROSS APPLY	dbo.fn_AllContainedBaseEntities(P.[BaseManagedEntityId]) E			
			UNION
			SELECT		P.SQLName
						,E.BaseManagedEntityId
			FROM		Parents P
			CROSS APPLY	dbo.fn_AllContainedBaseEntities(P.[TopLevelHostEntityId]) E	
			)
			,A
			AS
			(	
			SELECT		DISTINCT
						E.SQLName
						,A.AlertName
						,A.AlertDescription
						,(	SELECT	(	
									select	p.value('.', 'nvarchar(max)')+CHAR(13)+CHAR(10) 
									from	APs.nodes('*') p(p) 
									for xml path('')
									) as Parameters
							FROM	(
									SELECT CAST(A.AlertParams AS XML).query('//AlertParameters[1]/*') APs
									) Data 
							) AS AlertParams
						,CAST(A.Context AS XML).query('//DataItem/EventDescription[1]').value('.','nvarchar(max)')	AS EventDescription
						,A.BaseManagedEntityId
						,A.ResolutionState
						,A.Priority
						,A.Severity
						,A.TimeRaised
						,A.TicketID
						--,A.*
			FROM		Entities E 
			LEFT JOIN	dbo.Alert A WITH(NOLOCK)
					ON	A.BaseManagedEntityId = E.ManagedEntityID
					AND	A.TimeRaised IS NOT NULL
					AND	A.Category !='EventCollection'					
			)

					
SELECT		SQLName
			,COUNT(TicketID) AS Tickets
			,COUNT(CASE WHEN ResolutionState != 255 THEN TicketID END) AS OpenTickets
			,COUNT(CASE Severity WHEN 0 THEN 1 END) AS Message
			,COUNT(CASE Severity WHEN 1 THEN 1 END) AS Warning
			,COUNT(CASE Severity WHEN 2 THEN 1 END) AS Error

			,COUNT(CASE Priority WHEN 0 THEN 1 END) AS Low
			,COUNT(CASE Priority WHEN 1 THEN 1 END) AS Med
			,COUNT(CASE Priority WHEN 2 THEN 1 END) AS High			
			
			,COUNT(Priority)																		AS NumAlerts
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END)										AS OpenAlerts 
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END * CASE Severity WHEN 2 THEN 1 END)	AS OpenErrors
			,COALESCE((
				SELECT '<span style=''color:red''><B>ERROR:</B></span> '+ COALESCE(NULLIF(EventDescription,'') 
										,'<span style=''color:red''><B>ALERT NAME:</B></span> ' + ISNULL(AlertName,'') + '<br/>'+ CHAR(13)+CHAR(10)
										+'<span style=''color:red''><B>ALERT DESC:</B></span> ' + ISNULL(AlertDescription,'') + '<br/>'+ CHAR(13)+CHAR(10)
										+'<span style=''color:red''><B>ALERT PARM:</B></span> ' + ISNULL(AlertParams,'')
										)+ '<br/><br/>' + CHAR(13)+CHAR(10)
					FROM A
					WHERE Severity=2 
					AND ResolutionState!=255 
					AND SQLName = A1.SQLName
					ORDER BY TimeRaised 
					FOR XML PATH(''), TYPE
			).value('.[1]', 'NVARCHAR(MAX)')+'<span style=''color:red''>--------------------------------------------------------------<br/><br/></span>','')	AS OpenErrors_Text
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END * CASE Severity WHEN 1 THEN 1 END)	AS OpenWarnings
			,COALESCE((
				SELECT '<span style=''color:red''><B>WARNING:</B></span> '+ COALESCE(NULLIF(EventDescription,'') 
										,'<span style=''color:red''><B>ALERT NAME:</B></span> ' + ISNULL(AlertName,'') + '<br/>'+ CHAR(13)+CHAR(10)
										+'<span style=''color:red''><B>ALERT DESC:</B></span> ' + ISNULL(AlertDescription,'') + '<br/>'+ CHAR(13)+CHAR(10)
										+'<span style=''color:red''><B>ALERT PARM:</B></span> ' + ISNULL(AlertParams,'')
										)+ '<br/><br/>' + CHAR(13)+CHAR(10)
					FROM A
					WHERE Severity=1 
					AND ResolutionState!=255 
					AND SQLName = A1.SQLName
					ORDER BY TimeRaised 
					FOR XML PATH(''), TYPE
			).value('.[1]', 'NVARCHAR(MAX)')+'<span style=''color:red''>--------------------------------------------------------------<br/><br/></span>','')	AS OpenWanings_Text
			,COUNT(CASE WHEN ResolutionState != 255 THEN 1 END * CASE Severity WHEN 0 THEN 1 END)	AS OpenMessages
			,COALESCE((
				SELECT '<span style=''color:red''><B>INFO:</B></span> '+ COALESCE(NULLIF(EventDescription,'') 
										,'<span style=''color:red''><B>ALERT NAME:</B></span> ' + ISNULL(AlertName,'') + '<br/>'+ CHAR(13)+CHAR(10)
										+'<span style=''color:red''><B>ALERT DESC:</B></span> ' + ISNULL(AlertDescription,'') + '<br/>'+ CHAR(13)+CHAR(10)
										+'<span style=''color:red''><B>ALERT PARM:</B></span> ' + ISNULL(AlertParams,'')
										)+ '<br/><br/>' + CHAR(13)+CHAR(10)
					FROM A
					WHERE Severity=0 
					AND ResolutionState!=255 
					AND SQLName = A1.SQLName
					ORDER BY TimeRaised 
					FOR XML PATH(''), TYPE
			).value('.[1]', 'NVARCHAR(MAX)')+'<span style=''color:red''>--------------------------------------------------------------<br/><br/></span>','')	AS OpenMessages_Text


FROM		A A1
GROUP BY	SQLName
ORDER BY	1,2


--SELECT		E.SQLName
--			,MAX(A.Severity)	[Severity]
--			,COUNT(*)			[OpenAlerts]		
--FROM		Alert A
--JOIN		Entities E 
--		ON	A.BaseManagedEntityId = E.ManagedEntityId
--WHERE		ResolutionState !=255
--		AND	Category !='EventCollection'
--GROUP BY	SQLName		
--ORDER BY	SQLName
			
			
--SELECT		E.SQLName
--			,CAST(A.Context AS XML).query('//DataItem/EventDescription[1]').value('.','nvarchar(max)')	AS EventDescription
--			,A.*
--FROM		Alert A
--JOIN		Entities E 
--		ON	A.BaseManagedEntityId = E.ManagedEntityId
--WHERE		ResolutionState !=255
--		AND	Category !='EventCollection'
--ORDER BY	SQLName
--			,TimeRaised desc	



--http://intranet.seattle.gettyimages.com/forms/ScomAlertsView.asp?TID=1672874
