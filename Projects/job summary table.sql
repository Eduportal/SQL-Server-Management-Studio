
DECLARE	@HTML VarChar(max)
DECLARE	@XML XML

SELECT		J.name
		,COALESCE(s.name,'Not Scheduled') Sched
		,j.description
FROM		msdb..sysjobs J
LEFT JOIN	msdb.dbo.sysjobschedules JS
	ON	JS.job_id = J.job_id
LEFT JOIN	msdb.dbo.sysschedules S 
	ON	S.schedule_id = JS.schedule_id



SELECT	@XML = (
		SELECT		'',name AS 'td'
				,'',Sched AS 'td'
				,'',description AS 'td'
				,'',1 AS 'td'
		FROM		(
				SELECT		J.name
						,COALESCE(s.name,'Not Scheduled') Sched
						,j.description
				FROM		msdb..sysjobs J
				LEFT JOIN	msdb.dbo.sysjobschedules JS
					ON	JS.job_id = J.job_id
				LEFT JOIN	msdb.dbo.sysschedules S 
					ON	S.schedule_id = JS.schedule_id
				) J
		WHERE		name NOT LIKE 'APPL%'
		ORDER BY	name	
		FOR XML PATH ('tr')
		)

--SELECT @XML










SELECT		@HTML = N'
<table border=1 cellpadding=2>
<tr>
	<th>Job Name</th>
	<th>Generic Schedule</th>
	<th>Description</th>
	<th>Severity</th>
</tr>
' + CAST(@XML AS VARCHAR(max)) + N'

</table>
'

PRINT @HTML		