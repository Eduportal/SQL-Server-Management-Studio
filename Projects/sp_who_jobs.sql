-- sp_who_jobs

SELECT   p.SPID,
        Blocked_By = p.Blocked,
        p.Status,
        p.LogiName,
        p.HostName,
        p.open_tran,
        Program = coalesce('Job: ' + j.name, p.program_name),
        p.program_name,
        job_name = coalesce(j.[name], ''),
        jobstep_id = coalesce(js.[step_id], ''),
        jobstep_name = coalesce(js.[step_name], ''),
        js.[command],
        dts_name = coalesce(d.name, ''),
        DBName = db_name(p.dbid), 
        Command = p.cmd,
        CPUTime = p.cpu,
        DiskIO = p.physical_io,
        LastBatch = p.Last_Batch,
        -- LastQuery = coalesce( (select [text] from sys.dm_exec_sql_text(p.sql_handle)), '' ), -- SQL Server 2005+
        -- LastQuery = coalesce( (select * from ::fn_get_sql(p.sql_handle)), '' ), -- SQL Server 2000 ? FAILS
        p.WaitTime,   
        p.LastWaitType,   
        LoginTime = p.Login_Time,   
        RunDate = GetDate(),
        [Server] = serverproperty('machinename'),   
        [Duration(s)] = datediff(second, p.last_batch, getdate())  
FROM master.dbo.sysprocesses p  
        left outer join msdb.dbo.sysjobs j on master.dbo.fn_varbintohexstr(j.job_id) = substring(p.program_name,30,34)
        left outer join msdb.dbo.sysjobsteps js on j.job_id = js.job_id and js.step_id = SUBSTRING( p.program_name, 72, LEN(p.program_name)-72 ) 
        left outer join msdb.dbo.sysdtspackages d on js.command like ('%dtsrun%'+cast(d.[name] as varchar(100))+'%')
where p.spid > 50  
        and p.status <> 'sleeping' 
        and p.spid <> @@spid  
order by p.spid

