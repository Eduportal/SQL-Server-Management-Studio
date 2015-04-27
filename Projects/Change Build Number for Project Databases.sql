
SELECT	*
FROM	gears.dbo.AUTO_Request
WHERE	active = 'y'

UPDATE	gears.dbo.AUTO_Request
SET	Project_num = '16.1'
	,start_date = '2010-07-19 12:00:00.000'
WHERE	Project_name = 'Databases'
	AND Project_num = '16.0'