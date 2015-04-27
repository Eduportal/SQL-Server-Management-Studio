

;With		Parents
			AS
			(
			SELECT		DB.ConnectionString_B87E82BC_1A85_4DE3_330A_13133CF5F9C3 [SQLName]
						,R.SourceEntityId	[ManagedEntityID]
						,R.TargetEntityId	[ChildEntityID]
			FROM		Relationship R WITH(NOLOCK)
			JOIN		MT_DBEngine DB WITH(NOLOCK)
					ON	DB.BaseManagedEntityId = R.SourceEntityId
			UNION ALL
			SELECT		DB.[SQLName]
						,R.SourceEntityId	[ManagedEntityID]
						,R.TargetEntityId	[ChildEntityID]
			FROM		Relationship R WITH(NOLOCK)
			JOIN		Parents DB
					ON	DB.ChildEntityID = R.SourceEntityId
			)
			,EntityList
			AS
			(
			SELECT		[SQLName]
						,[ManagedEntityID]
			FROM		Parents					
			UNION
			SELECT		[SQLName]
						,[ChildEntityID]
			FROM		Parents							
			)
SELECT		E.SQLName
			,MAX(A.Severity)	[Severity]		
FROM		Alert A
JOIN		EntityList E 
		ON	A.BaseManagedEntityId = E.ManagedEntityId
WHERE		ResolutionState !=255
		AND	Category !='EventCollection'
GROUP BY	SQLName		
ORDER BY	SQLName
			
			
SELECT		E.SQLName
			,CAST(A.Context AS XML).query('//DataItem/EventDescription[1]').value('.','nvarchar(max)')	AS EventDescription
			,A.*
FROM		Alert A
JOIN		EntityList E 
		ON	A.BaseManagedEntityId = E.ManagedEntityId
WHERE		ResolutionState !=255
		AND	Category !='EventCollection'
ORDER BY	SQLName
			,TimeRaised desc	
