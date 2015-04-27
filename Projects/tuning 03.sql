-- IO BOTTLENECKS
/*

PhysicalDisk Object: Avg. Disk Queue Length represents the average number of physical read and write requests that were queued on the selected physical disk during the sampling period. If your I/O system is overloaded, more read/write operations will be waiting. If your disk queue length frequently exceeds a value of 2 during peak usage of SQL Server, then you might have an I/O bottleneck.

Avg. Disk Sec/Read is the average time, in seconds, of a read of data from the disk. Any number
	Less than 10 ms - very good 
	Between 10 - 20 ms - okay 
	Between 20 - 50 ms - slow, needs attention 
	Greater than 50 ms – Serious I/O bottleneck

Avg. Disk Sec/Write is the average time, in seconds, of a write of data to the disk. Please refer to the guideline in the previous bullet.

Physical Disk: %Disk Time is the percentage of elapsed time that the selected disk drive was busy servicing read or write requests. A general guideline is that if this value is greater than 50 percent, it represents an I/O bottleneck.

Avg. Disk Reads/Sec is the rate of read operations on the disk. You need to make sure that this number is less than 85 percent of the disk capacity. The disk access time increases exponentially beyond 85 percent capacity.

Avg. Disk Writes/Sec is the rate of write operations on the disk. Make sure that this number is less than 85 percent of the disk capacity. The disk access time increases exponentially beyond 85 percent capacity.

you may need to adjust the values for RAID configurations using the following formulas.

Raid 0 -- I/Os per disk = (reads + writes) / number of disks 
Raid 1 -- I/Os per disk = [reads + (2 * writes)] / 2 
Raid 5 -- I/Os per disk = [reads + (4 * writes)] / number of disks 
Raid 10 -- I/Os per disk = [reads + (2 * writes)] / number of disks

*/


/*You can also identify I/O bottlenecks by examining the latch waits. These latch waits account for the physical I/O waits when a page is accessed for reading or writing and the page is not available in the buffer pool. When the page is not found in the buffer pool, an asynchronous I/O is posted and then the status of the I/O is checked. If I/O has already completed, the worker proceeds normally. Otherwise, it waits on PAGEIOLATCH_EX or PAGEIOLATCH_SH, depending upon the type of request. The following DMV query can be used to find I/O latch wait statistics.*/
/*Here the latch waits of interest are the underlined ones. When the I/O completes, the worker is placed in the runnable queue. The time between I/O completions until the time the worker is actually scheduled is accounted under the signal_wait_time_ms column. You can identify an I/O problem if your waiting_task_counts and wait_time_ms deviate significantly from what you see normally. For this, it is important to get a baseline of performance counters and key DMV query outputs when SQL Server is running smoothly. These wait_types can indicate whether your I/O subsystem is experiencing a bottleneck, but they do not provide any visibility on the physical disk(s) that are experiencing the problem.*/

Select  wait_type,  
        waiting_tasks_count,  
        wait_time_ms 
from    sys.dm_os_wait_stats   
where    wait_type like 'PAGEIOLATCH%'   
order by wait_type 



-- You can use the following DMV query to find currently pending I/O requests. You can execute this query periodically to check the health of I/O subsystem and to isolate physical disk(s) that are involved in the I/O bottlenecks.
select  
    database_id,  
    file_id,  
    io_stall, 
    io_pending_ms_ticks, 
    scheduler_address  
from    sys.dm_io_virtual_file_stats(NULL, NULL)t1, 
        sys.dm_io_pending_io_requests as t2 
where    t1.file_handle = t2.io_handle

--The following DMV query can be used to find which batches/requests are generating the most I/O. You will notice that we are not accounting for physical writes. This is ok if you consider how databases work. The DML/DDL statements within a request do not directly write data pages to disk. Instead, the physical writes of pages to disks is triggered by statements only by committing transactions. Usually physical writes are done by either by Checkpoint or by the SQL Server lazy writer. A DMV query like the following can be used to find the top five requests that generate the most I/Os. Tuning those queries so that they perform fewer logical reads can relieve pressure on the buffer pool. This allows other requests to find the necessary data in the buffer pool in repeated executions (instead of performing physical I/O). Hence, overall system performance is improved.
select top 5  
    (total_logical_reads/execution_count) as avg_logical_reads, 
    (total_logical_writes/execution_count) as avg_logical_writes, 
    (total_physical_reads/execution_count) as avg_phys_reads, 
     Execution_count,  
    statement_start_offset as stmt_start_offset,  
    sql_handle,  
    plan_handle 
from sys.dm_exec_query_stats   
order by  
 (total_logical_reads + total_logical_writes) Desc
 
--You can, of course, change this query to get different views on the data. For example, to generate the top five requests that generate most I/Os in single execution, you can order by:
--    (total_logical_reads + total_logical_writes)/execution_count 

/*Alternatively, you may want to order by physical I/Os and so on. However, logical read/write numbers are very helpful in determining whether or not the plan chosen by the query is optimal. For example, it may be doing a table scan instead of using an index. Some queries, such as those that use nested loop joins may have high logical counters but be more cache-friendly since they revisit the same pages.

Example: Let us take the following two batches consisting of two SQL queries where each table has 1000 rows and rowsize > 8000 (one row per page).

Batch-1

select  
    c1,  
    c5 
from t1 INNER HASH JOIN t2 ON t1.c1 = t2.c4 
order by c2 
 
Batch-2 
select * from t1
For the purpose of this example, before running the DMV query, we clear the buffer pool and the procedure cache by running the following commands.

checkpoint 
dbcc freeproccache 
dbcc dropcleanbuffers
Here is the output of the DMV query. You will notice two rows representing the two batches.

Avg_logical_reads Avg_logical_writes Avg_phys_reads Execution_count  
stmt_start_offset  
----------------------------------------------------------------------- 
--------------- 
2794                1                385                1                  
    0                       
1005                0                0                  1                  
    146          
 
sql_handle                                         plan_handle 
----------------------------------------------------------------------- 
----- 
0x0200000099EC8520EFB222CEBF59A72B9BDF4DBEFAE2B6BB 
                x0600050099EC8520A8619803000000000000000000000000 
0x0200000099EC8520EFB222CEBF59A72B9BDF4DBEFAE2B6BB  
                x0600050099EC8520A8619803000000000000000000000000
You will notice that the second batch only incurs logical reads but no physical I/O. This is because the data it needs was already cached by the first query (assuming there was sufficient memory).

You can get the text of the query by running the following query.

select text  
from sys.dm_exec_sql_text( 
     0x0200000099EC8520EFB222CEBF59A72B9BDF4DBEFAE2B6BB) 
 
Here is the output. 
 
select  
    c1,  
    c5 
from t1 INNER HASH JOIN t2 ON t1.c1 = t2.c4 
order by c2
You can also find out the string for the individual statement by executing the following:

select  
    substring(text,  
              (<statement_start_offset>/2), 
              (<statement_end_offset> -<statement_start_offset>)/2)   
from sys.dm_exec_sql_text                 
(0x0200000099EC8520EFB222CEBF59A72B9BDF4DBEFAE2B6BB)
The value of statement_start_offest and statement_end_offset need to be divided by two in order to compensate for the fact that SQL Server stores this kind of data in Unicode. A statement_end_offset value of -1, indicates that the statement does go up to the end of the batch. However the substring() function does not accommodate -1 as a valid value. Instead of using -1 as (<statement_end_offset> -<statement_start_offset>)/2, one should enter the value 64000, which should make sure that the statement is covered in all cases. With this method, a long-running or resource-consuming statement can be filtered out of a large stored procedure or batch.

Similarly, you can run the following query to find to the query plan to identify if the large number of I/Os is a result of a poor plan choice.

select *  
from sys.dm_exec_query_plan  
    (0x0600050099EC8520A8619803000000000000000000000000)*/
     
     




 auto create statistics = yes
 auto update statistics = yes
 Aynch Auto Update = NO


select	CASE
	WHEN sysindexes.rows > 500 
	THEN	CASE
		WHEN sysindexes.rows * 0.20 >= sysindexes.rowmodctr  --//500 change leeway
		THEN 'disable autostats log autostats disable'
		ELSE 'stats ok'
		END
	WHEN sysindexes.rowmodctr >= 425 --//75 change leeway
        THEN 'disable autostats log autostats disable'
        END
		
from sysindexes






GO


















