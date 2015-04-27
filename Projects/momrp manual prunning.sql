SELECT MIN(SMC_InstanceID) 
FROM SC_SampledNumericDataFact_Table WITH (NOLOCK) 
WHERE DateTimeAdded < DATEADD(DAY, -90, GETUTCDATE())



SELECT		YEAR(DateTimeAdded)
		,MONTH(DateTimeAdded)
		,count(*)
FROM		SC_SampledNumericDataFact_Table WITH (NOLOCK) 	
GROUP BY	YEAR(DateTimeAdded)
		,MONTH(DateTimeAdded)


select MIN(SMC_InstanceID) From SC_SampledNumericDataFact_Table WITH (NOLOCK) WHERE MONTH(DateTimeAdded) = 9



SELECT 165883381 + 454361041

SELECT * FROM SC_SampledNumericDataFact_Table WHERE SMC_InstanceID = 620244422

SELECT MIN(SMC_InstanceID) 
FROM SC_SampledNumericDataFact_Table WITH (NOLOCK) 
WHERE DateTimeAdded >= DATEADD(DAY, -90, GETUTCDATE())


SELECT MIN(DateTimeAdded)
FROM SC_SampledNumericDataFact_Table WITH (NOLOCK) 
WHERE DateTimeAdded >= DATEADD(DAY, -90, GETUTCDATE())


SELECT SMC_InstanceID
FROM SC_SampledNumericDataFact_Table WITH (NOLOCK) 
WHERE DateTimeAdded = '2010-09-29 20:11:52.553'

SELECT MAX(DateTimeAdded) 
FROM SC_SampledNumericDataFact_Table WITH (NOLOCK) 
WHERE SMC_InstanceID BETWEEN 313914681 AND 411082625




SET NOCOUNT ON

DECLARE @DateTime	DateTime
	,@RowCnt	INT
	,@Dur		INT
	,@msg		VarChar(8000)

SET ROWCOUNT 1000000
ReDelete:
	SET @DateTime = GetDate()
	DELETE	SC_SampledNumericDataFact_Table
	WHERE	SMC_InstanceID < 411082625
	Set	@RowCnt	= @@rowcount
	SET	@Dur	= DateDiff(second,@DateTime,getdate())
	SET	@Msg	= CAST(@RowCnt AS VarChar(10)) + ' Records Deleted in ' +CAST(@Dur AS VarChar(10)) + ' seconds.'
	RAISERROR (@Msg,-1,-1) WITH NOWAIT
IF @RowCnt = 1000000 GOTO ReDelete
SET ROWCOUNT 0
PRINT 'Done.'





