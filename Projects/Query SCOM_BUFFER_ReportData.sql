DECLARE		@ServerName		SYSNAME		='G1SQLA'

SELECT		*
FROM		dbaperf.dbo.SCOM_BUFFER_ReportData WITH(NOLOCK)
WHERE		ServerName = @ServerName
ORDER BY	1,2,3