

--select spid, kpid, status, hostname, dbid, cpu, cmd, program_name,sql_handle from master..sysprocesses WHERE kpid > 0   ORDER BY KPID


DECLARE test_cursor CURSOR
KEYSET
FOR
select spid, kpid, status, hostname, dbid, cpu, cmd, program_name,sql_handle from master..sysprocesses WHERE kpid > 0   ORDER BY CPU DESC --KPID

DECLARE @Results TABLE
				(
				[SPID] int
				, [KPID] int
				, [STATUS]   varchar(50)
				, [HOSTNAME] varchar(50)
				, [DBID] smallint
				, [CPU] int
				, [CMD]  nvarchar(16)
				, [PROGRAM_NAME] varchar(50)
				, [DBID2] smallint
				, [ObjectID] int
				, [Number] int
				, [Encrypted] bit 
				, [Text] varchar(max)
				)
				
DECLARE @spid int
	, @kpid smallint
	, @status varchar(50)
	, @hostname varchar(50)
	, @dbid smallint
	, @cpu int
	, @cmd nvarchar(50)
	, @program_name varchar(50)
	, @sql_handle binary(50)

OPEN test_cursor

FETCH NEXT FROM test_cursor INTO	@spid
					, @kpid
					, @status 
					, @hostname 
					, @dbid 
					, @cpu 
					, @cmd 
					, @program_name 
					, @sql_handle 
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		INSERT INTO @Results
		SELECT		@spid SPID
					, @kpid KPID
					, @status STATUS
					, @hostname HOSTNAME
					, @dbid DBID
					, @cpu CPU
					, @cmd CMD
					, @program_name PROGRAM_NAME
					, * 
		FROM		::fn_get_sql(@sql_handle)

	END
	FETCH NEXT FROM test_cursor INTO	@spid
						, @kpid
						, @status 
						, @hostname 
						, @dbid 
						, @cpu 
						, @cmd 
						, @program_name 
						, @sql_handle 
END

CLOSE test_cursor
DEALLOCATE test_cursor

SELECT * FROM @Results
order by cpu desc




SELECT TOP 50 qs.creation_time, qs.execution_count, qs.total_worker_time as total_cpu_time, qs.max_worker_time as max_cpu_time, qs.total_elapsed_time, qs.max_elapsed_time, qs.total_logical_reads, qs.max_logical_reads, qs.total_physical_reads, qs.max_physical_reads,t.[text], qp.query_plan, t.dbid, t.objectid, t.encrypted, qs.plan_handle, qs.plan_generation_num FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp ORDER BY qs.total_worker_time DESC


