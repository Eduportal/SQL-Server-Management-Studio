select	sj.name
	,CASE 
	WHEN freq_type & 4 > 0 THEN 'Daily' + CASE 
						WHEN freq_subday_type & 2 > 0 THEN ' Every ' + CAST(freq_subday_interval AS VarChar(50)) + ' Seconds'
						WHEN freq_subday_type & 4 > 0 THEN ' Every ' + CAST(freq_subday_interval AS VarChar(50)) + ' Minutes'
						WHEN freq_subday_type & 8 > 0 THEN ' Every ' + CAST(freq_subday_interval AS VarChar(50)) + ' Hours'
						ELSE ''
						END
	
	WHEN freq_type & 8 > 0 THEN 'Weekly' + CASE
						WHEN freq_subday_type > 0 THEN ' Every' 
						+ REPLACE(CASE WHEN freq_subday_type & 1 > 0 THEN ' Sunday,' ELSE '' END
						+ CASE WHEN freq_subday_type & 2 > 0 THEN ' Monday,' ELSE '' END
						+ CASE WHEN freq_subday_type & 4 > 0 THEN ' Tuesday,' ELSE '' END
						+ CASE WHEN freq_subday_type & 8 > 0 THEN ' Wednesday,' ELSE '' END
						+ CASE WHEN freq_subday_type & 16 > 0 THEN ' Thursday,' ELSE '' END
						+ CASE WHEN freq_subday_type & 32 > 0 THEN ' Friday,' ELSE '' END
						+ CASE WHEN freq_subday_type & 64 > 0 THEN ' Saturday,' ELSE '' END
						+ '|',',|','')
						ELSE ''
						END
	WHEN freq_type & 16 > 0 THEN 'Monthly On The ' + CASE	WHEN RIGHT(CAST(freq_interval AS VarChar(2)),1) = 1 THEN CAST(freq_interval AS VarChar(2)) + 'st'
								WHEN RIGHT(CAST(freq_interval AS VarChar(2)),1) = 2 THEN CAST(freq_interval AS VarChar(2)) + 'nd'
								WHEN RIGHT(CAST(freq_interval AS VarChar(2)),1) = 3 THEN CAST(freq_interval AS VarChar(2)) + 'rd'
								ELSE CAST(freq_interval AS VarChar(2)) + 'th'
								END
	ELSE 'Other' 
	END AS Interval
	,ss.name
From sysjobs sj
join sysjobschedules sjs
 on sj.job_id = sjs.job_id
join sysschedules ss
 on ss.schedule_id = sjs.schedule_id
 ORDER BY 2
 