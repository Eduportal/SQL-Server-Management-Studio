
BACKUP log [SystemCenterReporting] with truncate_only
GO
USE [SystemCenterReporting]
GO
DBCC SHRINKFILE (N'REPLOG' , 0, TRUNCATEONLY)
GO
DBCC SHRINKFILE (N'REPLOG' , 0, NOTRUNCATE)
GO
DBCC SHRINKFILE (N'REPLOG' , 0, TRUNCATEONLY)
GO

Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_ComputerToComputerRuleFact_Table', 3
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_RelationshipInstanceFact_Table', 3
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_EventFact_Table', 60
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_ClassInstanceFact_Table', 60
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_ComputerRuleToProcessRuleGroupFact_Table', 3
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_ProcessRuleMembershipFact_Table', 3
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_ProcessRuleToScriptFact_Table', 3
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_RelationshipAttributeInstanceFact_Table', 3
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_AlertFact_Table', 60
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_EventParameterFact_Table', 60
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_AlertHistoryFact_Table', 60
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_AlertToEventFact_Table', 60
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_ClassAttributeInstanceFact_Table', 60
Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_SampledNumericDataFact_Table', 60
GO



DROP TABLE #GroomControler
GO
USE [SystemCenterReporting]
GO
SET NOCOUNT ON
GO
DECLARE		@TSQL		VarChar(8000)
DECLARE		@TextLength	INT

CREATE TABLE	#GroomControler
		(
		ViewName	sysname
		,ColumnName	sysname
		,GroomDays	INT
		,CurrentDays	INT
		)
		
INSERT INTO	#GroomControler(ViewName,ColumnName,GroomDays)		
SELECT		GroomTableName = CS.ViewName
		, GroomColumnName = CP.PropertyName
		, GroomDays = WCS.GroomDays 
FROM		dbo.SMC_Meta_WarehouseClassProperty AS WCP with (NOLOCK) 
INNER JOIN	dbo.SMC_Meta_ClassProperties AS CP with (NOLOCK) 
	ON	WCP.ClassPropertyID = CP.ClassPropertyID 
INNER JOIN	dbo.SMC_Meta_WarehouseClassSchema AS WCS with (NOLOCK) 
	ON	WCS.ClassID = CP.ClassID 
INNER JOIN	dbo.SMC_Meta_ClassSchemas AS CS with (NOLOCK) 
	ON	CS.ClassID = CP.ClassID 
WHERE		WCP.IsGroomColumn = 1

SELECT		@TextLength = MAX(LEN(ViewName))
FROM		#GroomControler
Groom_Again:
SELECT		@TSQL = 'DECLARE @OldestDate DateTime'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
SELECT		@TSQL	= @TSQL	
			+ 'SELECT @OldestDate = MIN('+CP.PropertyName+') FROM '+CS.ViewName+CHAR(13)+CHAR(10)
			+ 'UPDATE #GroomControler SET CurrentDays = DATEDIFF(day,@OldestDate,GETUTCDATE()-1) WHERE ViewName = '''+CS.ViewName+'''' + CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

FROM		dbo.SMC_Meta_WarehouseClassProperty AS WCP with (NOLOCK) 
INNER JOIN	dbo.SMC_Meta_ClassProperties AS CP with (NOLOCK) 
	ON	WCP.ClassPropertyID = CP.ClassPropertyID 
INNER JOIN	dbo.SMC_Meta_WarehouseClassSchema AS WCS with (NOLOCK) 
	ON	WCS.ClassID = CP.ClassID 
INNER JOIN	dbo.SMC_Meta_ClassSchemas AS CS with (NOLOCK) 
	ON	CS.ClassID = CP.ClassID 
WHERE		WCP.IsGroomColumn = 1

EXEC		(@TSQL)

PRINT	'------------------------------------------------------------'
PRINT	'--		      STILL NEEDING CLEANING'
PRINT	'------------------------------------------------------------'
PRINT	''
SET		@TSQL = ''
SELECT		@TSQL = 
		@TSQL	+ ViewName 
			+ SPACE(@TextLength - LEN(ViewName))
			+ '	- ' 
			+ CAST(GroomDays AS VarChar(50)) 
			+ '	- ' 
			+ CAST(CurrentDays AS VarChar(50)) 
			+ CHAR(13)+CHAR(10)
FROM		#GroomControler	
WHERE		CurrentDays > GroomDays
PRINT		@TSQL
SET		@TSQL = ''
SELECT		@TSQL = 
		@TSQL + 'Exec SystemCenterReporting.dbo.p_updategroomdays '''+REPLACE(ViewName,'_View','_Table')+''', ' + CAST(CurrentDays AS VarChar(50)) +CHAR(13)+CHAR(10)
FROM		#GroomControler
WHERE		CurrentDays > GroomDays
If @@ROWCOUNT = 0 
BEGIN
	PRINT	'Finished Grooming'
	GOTO	FinishedGrooming
END
EXEC		(@TSQL)
PRINT		'GROOMING 1 DAY'
SET ROWCOUNT 10000
EXEC		SystemCenterReporting.dbo.p_GroomDatawarehouseTables
SET ROWCOUNT 0
GOTO Groom_Again	
FinishedGrooming:
PRINT	''
SET		@TSQL = ''
SELECT		@TSQL = 
		@TSQL	+ ViewName 
			+ SPACE(@TextLength - LEN(ViewName))
			+ '	- ' 
			+ CAST(GroomDays AS VarChar(50)) 
			+ '	- ' 
			+ CAST(CurrentDays AS VarChar(50)) 
			+ CHAR(13)+CHAR(10)
FROM		#GroomControler	
PRINT		@TSQL
SELECT		@TSQL = ''
SELECT		@TSQL = 
		@TSQL + 'Exec SystemCenterReporting.dbo.p_updategroomdays '''+REPLACE(ViewName,'_View','_Table')+''', ' + CAST(GroomDays AS VarChar(50)) +CHAR(13)+CHAR(10)
FROM		#GroomControler
--PRINT		(@TSQL)
EXEC		(@TSQL)





--SELECT MIN(DateTimeAdded) FROM SC_SampledNumericDataFact_Table





--UPDATE #GroomControler SET CurrentDays = DATEDIFF(day,@OldestDate,GETUTCDATE()-1) WHERE ViewName = 'SC_SampledNumericDataFact_View'