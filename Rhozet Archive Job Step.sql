


RAISERROR('Identify [WFSDB].[dbo].[TableJob] Records to Prune',-1,-1) WITH NOWAIT

SELECT		[guid]
INTO		#PruneIDs -- SELECT COUNT(*)
FROM		[WFSDB].[dbo].[TableJob]
WHERE		[lastUpdate] < DATEDIFF(d,Cast('0001-01-01' As DATE),GetDate()-30) * 864000000000

RAISERROR('',-1,-1) WITH NOWAIT
RAISERROR('',-1,-1) WITH NOWAIT

DelTaskPropertyEx:

RAISERROR('Delete [WFSDB].[dbo].[TableTaskPropertyEx]',-1,-1) WITH NOWAIT


	DELETE	TOP(100) -- SELECT COUNT(*)
	FROM	[WFSDB].[dbo].[TableTaskPropertyEx]
	WHERE	[referenceId] IN	(
					SELECT	guid
					FROM	[WFSDB].[dbo].[TableTask]
					WHERE	[JobID] IN	(
								SELECT	[guid] 
								FROM	#PruneIDs
								)
					)

IF @@ROWCOUNT = 100
	GOTO DelTaskPropertyEx

RAISERROR('',-1,-1) WITH NOWAIT
RAISERROR('',-1,-1) WITH NOWAIT


DelTableTask:

RAISERROR('Delete [WFSDB].[dbo].[TableTask]',-1,-1) WITH NOWAIT

	DELETE	TOP(100) -- SELECT COUNT(*)
	FROM	[WFSDB].[dbo].[TableTask]
	WHERE	[JobID] IN	(
				SELECT	[guid] 
				FROM	#PruneIDs
				)

IF @@ROWCOUNT = 100
	GOTO DelTableTask

RAISERROR('',-1,-1) WITH NOWAIT
RAISERROR('',-1,-1) WITH NOWAIT

DelTableJob:

RAISERROR('Delete [WFSDB].[dbo].[TableJob]',-1,-1) WITH NOWAIT

	DELETE	TOP (100) -- SELECT COUNT(*)
	FROM	[WFSDB].[dbo].[TableJob]
	WHERE	[guid] IN	(
				SELECT	[guid] 
				FROM	#PruneIDs
				)

IF @@ROWCOUNT = 100
	GOTO DelTableJob

DROP TABLE #PruneIDs




