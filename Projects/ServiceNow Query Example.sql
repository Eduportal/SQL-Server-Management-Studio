--SELECT * FROM OPENQUERY(SERVICENOW, 'select Cast(sys_mod_count as Decimal(38,0)), number, short_description from incident')
--GO

SELECT		*
FROM		(
		SELECT		*
				,CASE
					WHEN short_description LIKE '%space%'			THEN 'SPACE'
					WHEN short_description LIKE '%Disk Volume Usage%'	THEN 'SPACE'
					WHEN short_description LIKE '%Full%'			THEN 'SPACE'
					WHEN short_description LIKE '%access%'			THEN 'ACCESS'
					WHEN short_description LIKE '%read only%'		THEN 'ACCESS'
					WHEN short_description LIKE '%link server%'		THEN 'LINKED SERVER' 
					WHEN short_description LIKE '%linked server%'		THEN 'LINKED SERVER'
					WHEN short_description LIKE '%Job failure%'		THEN 'JOB FAILURE'
					WHEN short_description LIKE '%Job step failure%'	THEN 'JOB FAILURE'
					WHEN short_description LIKE '%backup%'			THEN 'BACKUP'
					WHEN short_description LIKE '%restore%'			THEN 'RESTORE'
					
					END [CLASS]  
		FROM		OPENQUERY(SERVICENOW, 
'
SELECT		incident.description
		, Cast(incident.sys_mod_count as Decimal(38,0))
		, incident.number
		, incident.short_description
FROM		incident
WHERE		incident.assignment_group = ''c21364100a0a3cc800f3d58acd0365dd''
')
		) DATA
--WHERE		[CLASS] IS NOT NULL
ORDER BY	ISNULL([CLASS],'zzzzzzz')
GO

		--, sys_journal_field.value
		--, sys_journal_field.sys_created_on

--LEFT JOIN	sys_journal_field
--	ON	incident.sys_id = sys_journal_field.element_id


SELECT		*
FROM		OPENQUERY(SERVICENOW, 
'SELECT "sys_journal_field"."value", "incident"."number", "sys_journal_field"."sys_created_on"
FROM "SCHEMA"."OAUSER"."incident" "incident" INNER JOIN "SCHEMA"."OAUSER"."sys_journal_field" "sys_journal_field" ON "incident"."sys_id"="sys_journal_field"."element_id"
ORDER BY "sys_journal_field"."sys_created_on"') Data
