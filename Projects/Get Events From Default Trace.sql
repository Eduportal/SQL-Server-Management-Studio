select * from ::fn_trace_getinfo(0)


SELECT ntusername,loginname, objectname, e.category_id, textdata, starttime,spid,hostname, eventclass,databasename, e.name,getdate()
FROM ::fn_trace_gettable('D:\sql\MSSQL.1\MSSQL\LOG\log_316.trc',0)
      inner join sys.trace_events e
            on eventclass = trace_event_id
       INNER JOIN sys.trace_categories AS cat
            ON e.category_id = cat.category_id
where --databasename = 'msdb' and
      cat.category_id = 2 and --database category
      e.trace_event_id in (92,93,94,95) --db file growth
