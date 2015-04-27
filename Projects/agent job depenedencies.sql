
DECLARE		@JobName	VarChar(max)
		,@StepName	VarChar(max)
		,@Command	VarChar(max)
		,@CMD		VarChar(max)
		,@rcnt		INT
		
CREATE TABLE	#Results
		(
		Lev1		VarChar(max)
		,Lev2		VarChar(max)
		,Lev3		VarChar(max)
		,Ref_Lev1	VarChar(max)
		,Ref_Lev2	VarChar(max)
		,Ref_Lev3	VarChar(max)
		)		
		
DECLARE JobStepCursor CURSOR
FOR
select		sj.name
		,sjs.step_name
		,sjs.command
From		msdb..sysjobs sj
JOIN		msdb..sysjobsteps sjs
	ON	sj.job_id = sjs.job_id
where		sjs.subsystem = 'TSQL'	



DECLARE @name varchar(40)

OPEN JobStepCursor

FETCH NEXT FROM JobStepCursor INTO @JobName,@StepName,@Command
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		RAISERROR('Checking Job:%s, Step:%s',-1,-1, @JobName,@StepName) WITH NOWAIT
		
		SET @CMD = 'CREATE PROC DYNTEST AS ' + @Command
		EXEC (@CMD)

		INSERT INTO	#Results
		SELECT		@JobName
				,@StepName
				,@Command
				,referenced_database_name
				,referenced_schema_name
				, referenced_entity_name
		FROM		sys.sql_expression_dependencies
		WHERE		OBJECT_NAME (referencing_id) = 'DYNTEST'

		EXEC('DROP PROC DYNTEST')

	END
	FETCH NEXT FROM JobStepCursor INTO @JobName,@StepName,@Command
END

CLOSE JobStepCursor
DEALLOCATE JobStepCursor



CheckNextLevel:
SELECT @rcnt = COUNT(*) FROM #Results
PRINT @rcnt

exec sp_MSforeachdb 
'USE ?
;WITH		NewObjects
		AS
		(
		SELECT		DISTINCT
				T1.Ref_Lev1
				,T1.Ref_Lev2
				,T1.Ref_Lev3
		FROM		#Results T1
		LEFT JOIN	#Results T2
			ON	T1.Ref_Lev1 = T2.Lev1
			AND	T1.Ref_Lev2 = T2.Lev2
			AND	T1.Ref_Lev3 = T2.Lev3
		WHERE		T2.Lev1 IS NULL
			AND	T1.Ref_Lev1 = DB_NAME()
		)
INSERT INTO	#Results	
SELECT		DISTINCT
		n.*
		,d.referenced_database_name	
		,d.referenced_schema_name	
		,d.referenced_entity_name
FROM		NewObjects n		
JOIN		sys.sql_expression_dependencies d
	ON	OBJECT_NAME (d.referencing_id) = n.Ref_Lev3'

IF (SELECT COUNT(*) FROM #Results) > @rcnt
	GOTO CheckNextLevel


SELECT		*
FROM		#Results

GO
DROP TABLE #Results





--DROP procedure dyn_test as exec dbaadmin.dbo.dbasp_check_errorlog


--SELECT referencing_schema_name, referencing_entity_name,
--referencing_id, referencing_class_desc, is_caller_dependent
--FROM sys.dm_sql_referencing_entities ('dyn_test', 'OBJECT');
--GO

--SELECT OBJECT_NAME (referencing_id),referenced_database_name, 
--    referenced_schema_name, referenced_entity_name
-- FROM sys.sql_expression_dependencies
