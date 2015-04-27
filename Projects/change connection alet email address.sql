

SELECT		COUNT(*) 
FROM		msdb.dbo.sysjobsteps
WHERE		step_name = 'Check SQL Agent Log'
	and	command like '%@recipients = ''jim.wilson@gettyimages.com''%'
	and	command like '%--@recipients = ''tssqldba@gettyimages.com''%'



UPDATE		msdb.dbo.sysjobsteps
	SET	command = REPLACE(REPLACE(command,'@recipients = ''jim.wilson@gettyimages.com''','--@recipients = ''jim.wilson@gettyimages.com'''),'--@recipients = ''tssqldba@gettyimages.com''','@recipients = ''tssqldba@gettyimages.com''')
WHERE		step_name = 'Check SQL Agent Log'
	and	command like '%@recipients = ''jim.wilson@gettyimages.com''%'
	and	command like '%--@recipients = ''tssqldba@gettyimages.com''%'
	
	
	

SELECT		COUNT(*) 
FROM		msdb.dbo.sysjobsteps
WHERE		step_name = 'Check SQL Agent Log'
	and	command like '%@recipients = ''jim.wilson@gettyimages.com''%'
	and	command like '%--@recipients = ''tssqldba@gettyimages.com''%'
	
SELECT		COUNT(*) 
FROM		msdb.dbo.sysjobsteps
WHERE		step_name = 'Check SQL Agent Log'
	and	command like '%--@recipients = ''jim.wilson@gettyimages.com''%'
	and	command like '%@recipients = ''tssqldba@gettyimages.com''%'	