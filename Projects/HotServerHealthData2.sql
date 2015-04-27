USE [dbacentral]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [dbacentral]
--GO
--IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[HotServerHealthData]'))
--DROP VIEW [dbo].[HotServerHealthData]
--GO
--USE [dbacentral]
--GO
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

ALTER VIEW	[dbo].[HotServerHealthData]
AS
WITH		LastCheckIn
			AS
			(
			SELECT		SQLname
						,MAX(CAST(CONVERT(VARCHAR(12),check_date,101)AS DATETIME)) AS last_date
						,MAX(hl_id) last_hl_id
			FROM		[dbacentral].[dbo].[SQLHealth_Central]
			WHERE		dbacentral.[dbo].[dbaudf_GetServerClass] ([SQLName]) = 'High'
			GROUP BY	SQLname
			)
			,PreferedMinimumSQLBuilds
			AS
			(
						SELECT	'9.00.3042.00' AS [PreferedBuild]	-- 2005 SP2 Origional
			UNION ALL	SELECT	'10.50.1600.1'						-- 2008R2 RTM
			)
			,SQLBuildList -- INFO FROM http://www.sqlteam.com/article/sql-server-versions
			AS
			(
	-- 2005
						SELECT	'9.00.1399.00' [SQLBuildNumber]
												, NULL [KBArticle]
															, NULL [URL]																									, 'RTM' [Description]
			UNION ALL	SELECT	'9.00.1406.00'	,'932557'	,'http://support.microsoft.com/kb/932557'																		,'FIX: A script task or a script component may not run correctly when you run an SSIS package in SQL Server 2005 build 1399'
			UNION ALL	SELECT	'9.00.1519.00'	,'913494'	,'http://support.microsoft.com/?kbid=913494'																	,'FIX: The merge agent does not use a specified custom user update to handle conflicting UPDATE statements in SQL Server 2005'
			UNION ALL	SELECT	'9.00.1528.00'	,'915307'	,'http://support.microsoft.com/?kbid=915307'																	,'FIX: You experience a slow uploading process if conflicts occur when many merge agents upload changes'
			UNION ALL	SELECT	'9.00.1528.00'	,'915306'	,'http://support.microsoft.com/?kbid=915306'																	,'FIX: The merge agent fails and a "permission denied" error message is logged when you synchronize a SQL Server 2005-based merge publication'
			UNION ALL	SELECT	'9.00.1528.00'	,'915309'	,'http://support.microsoft.com/?kbid=915309'																	,'FIX: When you start a merge agent, synchronization between the subscriber and the publisher takes a long time to be completed in SQL Server 2005'
			UNION ALL	SELECT	'9.00.1528.00'	,'915308'	,'http://support.microsoft.com/?kbid=915308'																	,'FIX: The CPU usage of the server reaches 100% when many DML activities occur in SQL Server 2005'
			UNION ALL	SELECT	'9.00.1532.00'	,'916046'	,NULL																											,'KB916046 : FIX: Indexes may grow very large when you insert a row into a table and then update the same row in SQL Server 2005http://support.microsoft.com/?kbid=916046'
			UNION ALL	SELECT	'9.00.1545.00'	,'919193'	,'http://support.microsoft.com/?kbid=919193'																	,'FIX: A forward-only cursor may be implicitly converted to a keyset cursor in SQL Server 2005'
			UNION ALL	SELECT	'9.00.1551.00'	,'922527'	,'http://support.microsoft.com/?kbid=922527'																	,'FIX: Error message when you schedule some SQL Server 2005 Integration Services packages to run as jobs: "Package has been cancelled"'
			UNION ALL	SELECT	'9.00.1558.00'	,'926493'	,'http://support.microsoft.com/?kbid=926493'																	,'FIX: Error message when you restore a transaction-log backup that is generated in SQL Server 2000 SP4 to an instance of SQL Server 2005'
			UNION ALL	SELECT	'9.00.1561.00'	,'932556'	,'http://support.microsoft.com/kb/932556'																		,'FIX: A script task or a script component may not run correctly when you run an SSIS package in SQL Server 2005 build 1500 and later builds'
			UNION ALL	SELECT	'9.00.2047.00'	,NULL		,NULL																											,'Service Pack 1'
			UNION ALL	SELECT	'9.00.2050.00'	,NULL		,'http://www.microsoft.com/downloads/details.aspx?familyid=4F1B3710-F101-4D4C-AF46-DF1BEB05D1CE&displaylang=en'	,'Update for SQL Server 2005 Service Pack 1 - .NET Vulnerability'
			UNION ALL	SELECT	'9.00.2050.00'	,'932555'	,'http://support.microsoft.com/kb/932555'																		,'FIX: A script task or a script component may not run correctly when you run an SSIS package in SQL Server 2005 build 2047'
			UNION ALL	SELECT	'9.00.2153.00'	,'918222'	,'http://support.microsoft.com/kb/918222/en-us'																	,'Cumulative hotfix package (build 2153) for SQL Server 2005 is available'
			UNION ALL	SELECT	'9.00.2153.00'	,'919224'	,'http://support.microsoft.com/kb/919224/en-us'																	,'Error message when you connect to an instance of SQL Server 2005 Integration Services by using SQL Server Management Studio on a computer that has a 64-bit processor'
			UNION ALL	SELECT	'9.00.2164.00'	,'919243'	,'http://support.microsoft.com/?kbid=919243'																	,'FIX: Some rows in the Text Data column are always displayed for a trace that you create by using SQL Server Profiler in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2164.00'	,'918832'	,'http://support.microsoft.com/?kbid=918832'																	,'FIX: An inefficient or incorrect SQL query is generated when you try to use SQL Server 2005 to browse a ROLAP dimension'
			UNION ALL	SELECT	'9.00.2167.00'	,'921295'	,'http://support.microsoft.com/?kbid=921295'																	,'FIX: You may receive an incorrect result when you try to run a Multidimensional Expressions (MDX) query by using SQL Server 2005'
			UNION ALL	SELECT	'9.00.2167.00'	,'921293'	,'http://support.microsoft.com/?kbid=921293'																	,'FIX: The description for the Dimension field is not set in the local cube file when you use the CREATE LOCAL CUBE statement in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2175.00'	,'921536'	,'http://support.microsoft.com/?kbid=921536'																	,'FIX: A handled access violation may occur in the CValSwitch::GetDataX function when you run a complex query in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2175.00'	,'920794'	,'http://support.microsoft.com/?kbid=920794'																	,'FIX: The size of the e-mail message is very large when you use Database Mail in SQL Server 2005 to send query results to users'
			UNION ALL	SELECT	'9.00.2175.00'	,'922579'	,'http://support.microsoft.com/?kbid=922579'																	,'FIX: The operation may take longer than you expect when you run a warm query to obtain information from the Microsoft Search service in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2176.00'	,'922594'	,'http://support.microsoft.com/?kbid=922594'																	,'FIX: Error message when you use SQL Server 2005: "High priority system task thread Operating system error Exception 0xAE encountered"'
			UNION ALL	SELECT	'9.00.2181.00'	,'923605'	,'http://support.microsoft.com/?kbid=923605'																	,'FIX: A deadlock occurs and a query never finishes when you run the query on a computer that is running SQL Server 2005 and has multiple processors'
			UNION ALL	SELECT	'9.00.2183.00'	,'924291'	,'http://support.microsoft.com/?kbid=924291'																	,'FIX: Error message when you execute a user-defined function in SQL Server 2005: "Invalid length parameter passed to the SUBSTRING function"'
			UNION ALL	SELECT	'9.00.2195.00'	,'926240'	,'http://support.microsoft.com/?kbid=926240'																	,'FIX: SQL Server 2005 may stop responding when you use the SqlBulkCopy class to import data from another data source'
			UNION ALL	SELECT	'9.00.2196.00'	,'926024'	,'http://support.microsoft.com/?kbid=926024'																	,'FIX: The query performance is very slow when you use a fast forward-only cursor to run a query in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2198.00'	,'926613'	,'http://support.microsoft.com/?kbid=926613'																	,'FIX: You may receive inconsistent results when you query a table that is published in a transactional replication in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2198.00'	,'926612'	,'http://support.microsoft.com/?kbid=926612'																	,'FIX: SQL Server Agent does not send an alert quickly or does not send an alert when you use an alert of the SQL Server event alert type in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2198.00'	,'926106'	,'http://support.microsoft.com/?kbid=926106'																	,'FIX: You receive an error message when you use the Print Preview option on a large report in SQL Server 2005 Reporting Services'
			UNION ALL	SELECT	'9.00.2198.00'	,'925277'	,'http://support.microsoft.com/?kbid=925277'																	,'FIX: You may experience very large growth increments of a principal database after you manually fail over a database mirroring session in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2198.00'	,'924807'	,'http://support.microsoft.com/?kbid=924807'																	,'FIX: The restore operation may take a long time to finish when you restore a database in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2198.00'	,'924686'	,'http://support.microsoft.com/?kbid=924686'																	,'FIX: The database mirroring session may remain in the synchronizing state and may stop responding when a database failover occurs in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2201.00'	,'927289'	,'http://support.microsoft.com/?kbid=927289'																	,'FIX: Updates to the SQL Server Mobile subscriber may not be reflected in the SQL Server 2005 merge publication'
			UNION ALL	SELECT	'9.00.2202.00'	,'927643'	,'http://support.microsoft.com/?kbid=927643'																	,'FIX: Some search results are missing when you perform a full-text search operation on a Windows SharePoint Services 2.0 site after you upgrade to SQL Server 2005'
			UNION ALL	SELECT	'9.00.2206.00'	,'928083'	,'http://support.microsoft.com/?kbid=928083'																	,'FIX: You may receive an error message when you run a CLR stored procedure or CLR function that uses a context connection in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2207.00'	,'928372'	,'http://support.microsoft.com/?kbid=928372'																	,'FIX: Error message when you use a synonym for a stored procedure in SQL Server 2005: "A severe error occurred on the current command"'
			UNION ALL	SELECT	'9.00.2207.00'	,'928789'	,'http://support.microsoft.com/?kbid=928789'																	,'FIX: Error message in the database mail log when you try to use the sp_send_dbmail stored procedure to send an e-mail in SQL Server 2005: "Invalid XML message format received on the ExternalMailQueue"'
			UNION ALL	SELECT	'9.00.2207.00'	,'928394'	,'http://support.microsoft.com/?kbid=928394'																	,'FIX: The changes are not reflected in the publication database after you reinitialize the subscriptions in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2208.00'	,'929404'	,'http://support.microsoft.com/?kbid=929404'																	,'FIX: Error message when you perform a transaction log backup operation and another data backup operation in parallel in SQL Server 2005: "Error 3633"'
			UNION ALL	SELECT	'9.00.2208.00'	,'929179'	,'http://support.microsoft.com/?kbid=929179'																	,'FIX: A memory leak may occur every time that you synchronize a SQL Server Mobile subscriber in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2209.00'	,'929278'	,'http://support.microsoft.com/?kbid=929278'																	,'FIX: SQL Server 2005 may not perform histogram amendments when you use trace flags 2389 and 2390'
			UNION ALL	SELECT	'9.00.2211.00'	,'930284'	,'http://support.microsoft.com/?kbid=930284'																	,'FIX: You receive error 1456 when you try to add a witness to a DBM session in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2211.00'	,'930283'	,'http://support.microsoft.com/?kbid=930283'																	,'FIX: You receive error 1456 when you add a witness to a database mirroring session and the database name is the same as an existing database mirroring session in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2214.00'	,'930775'	,'http://support.microsoft.com/?kbid=930775'																	,'FIX: Error message when you try to retrieve rows from a cursor that uses the OPTION (RECOMPILE) query hint in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2214.00'	,'930505'	,'http://support.microsoft.com/?kbid=930505'																	,'FIX: Error message when you run DML statements against a table that is published for merge replication in SQL Server 2005: "Could not find stored procedure"'
			UNION ALL	SELECT	'9.00.2214.00'	,'929240'	,'http://support.microsoft.com/?kbid=929240'																	,'FIX: I/O requests that are generated by the checkpoint process may cause I/O bottlenecks if the I/O subsystem is not fast enough to sustain the IO requests in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2215.00'	,'931666'	,'http://support.microsoft.com/?kbid=931666'																	,'FIX: An assertion violation may be logged after you install SQL Server 2005 or after you add more processors to a server that is running SQL Server 2005'
			UNION ALL	SELECT	'9.00.2218.00'	,'931843'	,'http://support.microsoft.com/kb/931843'																		,'FIX: SQL Server 2005 does not reclaim the disk space that is allocated to the temporary table if the stored procedure is stopped'
			UNION ALL	SELECT	'9.00.2219.00'	,'931329'	,'http://support.microsoft.com/kb/931329'																		,'FIX: Error message when you run a query in Microsoft SQL Server 2005: "Msg 8624 State 116 Internal Query Processor Error00:00.0'
			UNION ALL	SELECT	'9.00.2221.00'	,'931593'	,'http://support.microsoft.com/kb/932555'																		,'FIX: A script task or a script component may not run correctly when you run an SSIS package in SQL Server 2005 build 2047'
			UNION ALL	SELECT	'9.00.2224.00'	,'932990'	,'http://support.microsoft.com/kb/932990'																		,'FIX: You cannot obtain statements in the current batch in SQL Server 2005 by using the DBCC INPUTBUFFER statement deadlock graph event class or Activity Monitor00:00.0'
			UNION ALL	SELECT	'9.00.2227.00'	,'934066'	,'http://support.microsoft.com/kb/934066'																		,'FIX: The row of data on the publisher and the row of data on the subscriber may be inconsistent in a merge publication after synchronization has occurred in SQL Server 2005'
			UNION ALL	SELECT	'9.00.2233.00'	,'937544'	,'http://support.microsoft.com/kb/937544'																		,'FIX: You may receive error 3456 when you try to restore a transaction log for a SQL Server 2005 database'
			UNION ALL	SELECT	'9.00.3026.00'	,'929376'	,'http://support.microsoft.com/?kbid=929376'																	,'FIX: A "17187" error message may be logged in the Errorlog file when an instance of SQL Server 2005 is under a heavy load'
			UNION ALL	SELECT	'9.00.3042.00'	,NULL		,NULL																											,'Service Pack 2 Original'
			UNION ALL	SELECT	'9.00.3043.00'	,NULL		,'http://www.microsoft.com/technet/prodtechnol/sql/2005/downloads/servicepacks/sp2.mspx'						,'Service Pack 2 Refresh'
			UNION ALL	SELECT	'9.00.3050.00'	,'933508'	,'http://support.microsoft.com/?kbid=933508'																	,'Microsoft SQL Server 2005 Service Pack 2 issue: Cleanup tasks run at different intervals than intended'
			UNION ALL	SELECT	'9.00.3054.00'	,'934458'	,'http://support.microsoft.com/kb/934458'																		,'FIX: The Check Database Integrity task and the Execute T-SQL Statement task in a maintenance plan may lose database context in certain circumstances in SQL Server 2005 builds 3042 through 3053'
			UNION ALL	SELECT	'9.00.3073.00'	,'954606'	,'http://support.microsoft.com/kb/954606/'																		,'MS08-052: Description of the security update for GDI+ for SQL Server 2005 Service Pack 2 GDR: September 9, 2008'
			UNION ALL	SELECT	'9.00.3152.00'	,'9333097'	,'http://support.microsoft.com/?kbid=933097'																	,'Cumulative hotfix package (build 3152) for SQL Server 2005 Service Pack 2 is available'
			UNION ALL	SELECT	'9.00.3152.00'	,'9333097'	,'http://support.microsoft.com/?kbid=933097'																	,'Cumulative hotfix package (build 3152) for SQL Server 2005 Service Pack 2 is available'
			UNION ALL	SELECT	'9.00.3153.00'	,'933564'	,'http://support.microsoft.com/kb/933564'																		,'FIX: A gradual increase in memory consumption for the USERSTORE_TOKENPERM cache store occurs in SQL Server 2005'
			UNION ALL	SELECT	'9.00.3154.00'	,'934109'	,'http://support.microsoft.com/?kbid=934109'																	,'FIX: The Distribution Agent generates an access violation when you configure a transaction publication to run an additional script after the snapshot is applied'
			UNION ALL	SELECT	'9.00.3154.00'	,'934188'	,'http://support.microsoft.com/?kbid=934188'																	,'FIX: The Distribution Agent does not deliver commands to the Subscriber even if the Distribution Agent is running in SQL Server 2005'
			UNION ALL	SELECT	'9.00.3154.00'	,'934106'	,'http://support.microsoft.com/kb/934106'																		,'FIX: SQL Server 2005 database engine generates failed assertion errors when you use the Replication Monitor to monitor the distribution database'
			UNION ALL	SELECT	'9.00.3155.00'	,'933549'	,'http://support.microsoft.com/kb/933549'																		,'FIX: You may receive an access violation when you perform a bulk copy operation in SQL Server 2005'
			UNION ALL	SELECT	'9.00.3156.00'	,'934226'	,'http://support.microsoft.com/?kbid=934226'																	,'FIX: Error message when you try to use Database Mail to send an e-mail message in SQL Server 2005: "profile name is  Error 14607)"not valid'
			UNION ALL	SELECT	'9.00.3159.00'	,'934459'	,'http://support.microsoft.com/kb/934459'																		,'FIX: The Check Database Integrity task and the Execute T-SQL Statement task in a maintenance plan may lose database context'
			UNION ALL	SELECT	'9.00.3161.00'	,'935356'	,'http://support.microsoft.com/kb/935356'																		,'Cumulative update package (build 3161) for SQL Server 2005 Service Pack 2 is available'
			UNION ALL	SELECT	'9.00.3162.00'	,'935360'	,'http://support.microsoft.com/kb/935360/'																		,'FIX: Error message when you run an MDX query that retrieves data from an Analysis Services database: "An error occurred while the dimension...'
			UNION ALL	SELECT	'9.00.3162.00'	,'935922'	,'http://support.microsoft.com/kb/935922/'																		,'FIX: Error message when you install Microsoft Dynamics CRM 3.0: "Setup failed to validate specified Reporting Services Report Server"'
			UNION ALL	SELECT	'9.00.3162.00'	,'932610'	,'http://support.microsoft.com/kb/932610/'																		,'FIX: Error message when you run an MDX query in SQL Server 2005 Analysis Services: "An unexpected error occurred...'
			UNION ALL	SELECT	'9.00.3162.00'	,'935829'	,'http://support.microsoft.com/kb/935829/'																		,NULL
			UNION ALL	SELECT	'9.00.3162.00'	,'935830'	,'http://support.microsoft.com/kb/935830/'																		,'FIX: A server may start slowly if you have SQL Server 2005 Analysis Services installed and if many objects are stored on the server'
			UNION ALL	SELECT	'9.00.3162.00'	,'935832'	,'http://support.microsoft.com/kb/935832/'																		,'FIX: You cannot cancel an MDX query that runs for a long time in SQL Server 2005 Analysis Services'
			UNION ALL	SELECT	'9.00.3166.00'	,'936185'	,'http://support.microsoft.com/kb/936185'																		,'FIX: Blocking and performance problems may occur when you enable trace flag 1118 in SQL Server 2005 if the temporary table creation workload is high'
			UNION ALL	SELECT	'9.00.3169.00'	,'937041'	,'http://support.microsoft.com/kb/93704'																		,'FIX: Changes in the publisher database are not replicated to the subscribers in a transactional replication if the publisher database runs exposed'
			UNION ALL	SELECT	'9.00.3171.00'	,'937745'	,'http://support.microsoft.com/kb/937745'																		,'FIX: You may receive error messages when you try to log in to an instance of SQL Server 2005 and SQL Server handles many concurrent connections'
			UNION ALL	SELECT	'9.00.3175.00'	,'936305'	,'http://support.microsoft.com/kb/936305'																		,'Cumulative update package 2 for SQL Server 2005 Service Pack 2 is available'
			UNION ALL	SELECT	'9.00.3177.00'	,'N/A'		,'N/A'																											,'On-demand build with hotfixes: 50001391, 50001379, 50001408, and 50001397'
			UNION ALL	SELECT	'9.00.3178.00'	,'N/A'		,'N/A'																											,'On-demand build with hotfixes: 50001193 and 50001352'
			UNION ALL	SELECT	'9.00.3179.00'	,'N/A'		,'N/A'																											,'On-demand build with hotfixes: 50001482 and 50001194'
			UNION ALL	SELECT	'9.00.3180.00'	,'939942'	,'http://support.microsoft.com/kb/939942/'																		,'FIX: You receive an error message when you try to access a report after you configure SQL Server 2005 Reporting Services to run under the SharePoint integrated mode'
			UNION ALL	SELECT	'9.00.3182.00'	,'N/A'		,'N/A'																											,'On-demand build with hotfixes: 50001298 and 5000144'
			UNION ALL	SELECT	'9.00.3200.00'	,'941450'	,'http://support.microsoft.com/default.aspx?scid=kb;en-us;941450'												,'Cumulative Update 4 contains hotfixes for SQL Server 2005 issues that have been fixed since the release of Service Pack 2.'
			UNION ALL	SELECT	'9.00.3215.00'	,'943656'	,'http://support.microsoft.com/kb/943656/'																		,'Cumulative Update 5 contains hotfixes for SQL Server 2005 issues that have been fixed since the release of Service Pack 2.'
			UNION ALL	SELECT	'9.00.3228.00'	,'946608'	,'http://support.microsoft.com/kb/946608/'																		,'Cumulative Update 6 contains hotfixes for SQL Server 2005 issues that have been fixed since the release of Service Pack 2.'
			UNION ALL	SELECT	'9.00.3231.00'	,'949687'	,'http://support.microsoft.com/kb/949687/'																		,'FIX: Error message when you run a transaction from a remote server by using a linked server in SQL Server 2005: "This operation conflicts with another pending operation on this transaction"'
			UNION ALL	SELECT	'9.00.3232.00'	,'949959'	,'http://support.microsoft.com/kb/949959/'																		,'Merge Replication Hotfix'
			UNION ALL	SELECT	'9.00.3239.00'	,'949095'	,'http://support.microsoft.com/kb/949095/'																		,'Cumulative update package 7 for SQL Server 2005 Service Pack 2 available as of April 28, 2008'
			UNION ALL	SELECT	'9.00.3257.00'	,'951217'	,'http://support.microsoft.com/kb/951217/'																		,'Cumulative update package 8 for SQL Server 2005 Service Pack 2 as of June 16, 2008'
			UNION ALL	SELECT	'9.00.3282.00'	,'953752'	,'http://support.microsoft.com/kb/953752/'																		,'Cumulative update package 9 for SQL Server 2005 Service Pack 2 as of June 16, 2008'
			UNION ALL	SELECT	'9.00.3294.00'	,'956854'	,'http://support.microsoft.com/kb/956854/'																		,'Cumulative update package 10 for SQL Server 2005 Service Pack 2 as of Octboer 21, 2008'
			UNION ALL	SELECT	'9.00.3295.00'	,'959132'	,'http://support.microsoft.com/kb/959132/'																		,'FIX: Error message when you install Cumulative Update 10 or Cumulative Update 9 for SQL Server 2005 Service Pack 2 on a drive that uses the FAT32 file'
			UNION ALL	SELECT	'9.00.3301.00'	,'958735'	,'http://support.microsoft.com/kb/958735'																		,'Cumulative update package 11 for SQL Server 2005 Service Pack 2'
			UNION ALL	SELECT	'9.00.3315.00'	,'962970'	,'http://support.microsoft.com/kb/962970'																		,'Cumulative update package 12 for SQL Server 2005 Service Pack 2'
			UNION ALL	SELECT	'9.00.3325.00'	,'967908'	,'http://support.microsoft.com/kb/967908'																		,'Cumulative update package 13 for SQL Server 2005 Service Pack 2'
			UNION ALL	SELECT	'9.00.3328.00'	,'970278'	,'http://support.microsoft.com/kb/970278/en-us'																	,'Cumulative update package 14 for SQL Server 2005 Service Pack 2'
			UNION ALL	SELECT	'9.00.3330.00'	,'972510'	,'http://support.microsoft.com/kb/972510'																		,'Cumulative update package 15 for SQL Server 2005 Service Pack 2'
			UNION ALL	SELECT	'9.00.3355.00'	,'974647'	,'http://support.microsoft.com/kb/974647/en-us'																	,'Cumulative update package 16 for SQL Server 2005 Service Pack 2' 
			UNION ALL	SELECT	'9.00.4035.00'	,'955706'	,'http://support.microsoft.com/?kbid=955706'																	,'Service Pack 3'
			UNION ALL	SELECT	'9.00.4207.00'	,'959195'	,'http://support.microsoft.com/kb/959195'																		,'Cumulative Update 1 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4211.00'	,'961930'	,'http://support.microsoft.com/kb/961930'																		,'Cumulative Update 2 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4220.00'	,'961930'	,'http://support.microsoft.com/kb/967909'																		,'Cumulative Update 3 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4226.00'	,'970279'	,'http://support.microsoft.com/kb/970279'																		,'Cumulative Update 4 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4230.00'	,'972511'	,'http://support.microsoft.com/kb/972511'																		,'Cumulative Update 5 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4266.00'	,'974648'	,'http://support.microsoft.com/kb/974648'																		,'Cumulative update package 6 for SQL Server 2005 Service Pack 3'
			UNION ALL	SELECT	'9.00.4273.00'	,'960598'	,'http://support.microsoft.com/kb/960598'																		,'Cumulative Update 7 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4285.00'	,'978915'	,'http://support.microsoft.com/default.aspx?scid=kb;en-us;978915'												,'Cumulative Update 8 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4290.00'	,'960598'	,'http://support.microsoft.com/kb/960598'																		,'Post SP3 Hot fix, documented on the "All Builds" page at Microsoft for this SP.'
			UNION ALL	SELECT	'9.00.4294.00'	,'980176'	,'http://support.microsoft.com/kb/980176/'																		,'Cumulative Update 9 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4305.00'	,'983329'	,'http://support.microsoft.com/kb/983329/'																		,'Cumulative Update 10 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4309.00'	,'2258854'	,'http://support.microsoft.com/kb/2258854'																		,'Cumulative Update 11 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4311.00'	,'2345449'	,'http://support.microsoft.com/kb/2345449'																		,'Cumulative Update 12 for Service Pack 3'
			UNION ALL	SELECT	'9.00.4315.00'	,'2438344'	,'http://support.microsoft.com/kb/2438344'																		,'Cumulative update package 13 for SQL Server 2005 Service Pack 3'
			UNION ALL	SELECT	'9.00.4317.00'	,'2489375'	,'http://support.microsoft.com/kb/2489375'																		,'Cumulative update package 14 for SQL Server 2005 Service Pack 3'
			UNION ALL	SELECT	'9.00.5000.00'	,'2463332'	,'http://support.microsoft.com/kb/2463332'																		,'Service Pack 4'
			UNION ALL	SELECT	'9.00.5054.00'	,'2463332'	,'http://support.microsoft.com/kb/2464079'																		,'Cumulative Update 1 for SQL Server 2005 Service Pack 4'
			UNION ALL	SELECT	'9.00.5259.00'	,'2489409'	,'http://support.microsoft.com/kb/2489409'																		,'Cumulative Update 2 for SQL Server 2005 Service Pack 4'
			UNION ALL	SELECT	'9.00.5266.00'	,'2507769'	,'http://support.microsoft.com/kb/2507769'																		,'Cumulative Update 3 for SQL Server 2005 Service Pack 4'
	-- 2008
			UNION ALL	SELECT	'10.00.1600.22'	,NULL		,NULL																											,'The first public, supported version of SQL Server 2008'
			UNION ALL	SELECT	'10.00.1755.00'	,'957387'	,'http://support.microsoft.com/kb/960484'																		,'FIX: No records may be returned when you call the SQLExecute function to execute a prepared statement and you use the SQL Native Client ODBC Driver in SQL Server 2008'
			UNION ALL	SELECT	'10.00.1763.00'	,'956717'	,'http://support.microsoft.com/default.aspx/kb/956717'															,'Cumulative update package 1 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1779.00'	,'958186'	,'http://support.microsoft.com/default.aspx/kb/958186/en-us'													,'Cumulative update package 2 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1787.00'	,'960484'	,'http://support.microsoft.com/kb/960484'																		,'Cumulative update package 3 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1798.00'	,'963036'	,'http://support.microsoft.com/kb/963036'																		,'Cumulative Update 4 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1806.00'	,'969531'	,'http://support.microsoft.com/kb/969531/en-us'																	,'Cumulative Update 5 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1812.00'	,'971490'	,'http://support.microsoft.com/kb/971490/en-us'																	,'Cumulative Update 6 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1818.00'	,'973601'	,'http://support.microsoft.com/kb/973601/en-us'																	,'Cumulative Update 7 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1823.00'	,'975976'	,'http://support.microsoft.com/kb/975976/en-us'																	,'Cumulative Update 8 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1828.00'	,'977444'	,'http://support.microsoft.com/kb/977444/en-us'																	,'Cumulative Update 9 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.1835.00'	,'979064'	,'http://support.microsoft.com/kb/979064/en-us'																	,'Cumulative Update 10 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.2531.00'	,'968369'	,'http://support.microsoft.com/kb/968369'																		,'Service Pack 1 for SQL Server 2008'
			UNION ALL	SELECT	'10.00.2710.00'	,'969099'	,'http://support.microsoft.com/kb/969099/en-us'																	,'Cumulative Update 1 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2714.00'	,'970315'	,'http://support.microsoft.com/kb/970315/en-us'																	,'Cumulative Update 2 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2723.00'	,'971491'	,'http://support.microsoft.com/kb/971491/en-us'																	,'Cumulative Update 3 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2734.00'	,'973602'	,'http://support.microsoft.com/kb/973602/en-us'																	,'Cumulative Update 4 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2746.00'	,'975977'	,'http://support.microsoft.com/default.aspx/kb/975977/en-us'													,'Cumulative Update 5 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2757.00'	,'977443'	,'http://support.microsoft.com/default.aspx/kb/977443/en-us'													,'Cumulative Update 6 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2766.00'	,'979065'	,'http://support.microsoft.com/kb/979065/'																		,'Cumulative Update 7 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2775.00'	,'981702'	,'http://support.microsoft.com/default.aspx?scid=kb;en-us;981702'												,'Cumulative Update 8 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2789.00'	,'2083921'	,'http://support.microsoft.com/kb/2083921/en-us'																,'Cumulative Update 9 for SQL Server 2008 SP1'
			UNION ALL	SELECT	'10.00.2799.00'	,'2279604'	,'http://support.microsoft.com/kb/2279604/LN/'																	,'Cumulative Update 10 for SQL Server 2008 SP1 The tenth rollup of patches for Service Pack 1.'
			UNION ALL	SELECT	'10.00.2804.00'	,'2413738'	,'http://support.microsoft.com/kb/2413738/'																		,'Cumulative Update 11 for SQL Server 2008 SP1 The 11th rollup of patches for Service Pack 1. Fixed include fixes for too many VLFs during recovery, MDX issues in BIDS, and a few analysis services fixes.'
			UNION ALL	SELECT	'10.00.2808.00'	,'2467236'	,'http://support.microsoft.com/kb/2467236'																		,'Cumulative Update 12 for SQL Server 2008 SP1 The 12th rollup of patches for Service Pack 1. Fixes include clustering IPv6 problems, join performance fixes, and SSAS crashes.'
			UNION ALL	SELECT	'10.00.2816.00'	,'2497673'	,'http://support.microsoft.com/kb/2497673/en-us'																,'Cumulative Update 13 for SQL Server 2008 SP1 The 13th rollup of patches for Service Pack 1. Fixes include mirroring issues, Agent scheduling issues, and various T-SQL fixes.'
			UNION ALL	SELECT	'10.00.2821.00'	,'2527187'	,'http://support.microsoft.com/kb/2527187/en-us'																,'Cumulative Update 14 for SQL Server 2008 SP1 The 14th rollup of patches for Service Pack 1. Fixes include backup issues, Browser issues, and various other fixes.'
			UNION ALL	SELECT	'10.00.4000.00'	,'2285068'	,'http://support.microsoft.com/kb/2285068'																	,'SQL Server 2008 SP2 The second service pack for SQL Server 2008.'
			UNION ALL	SELECT	'10.00.4266.00'	,'2289254'	,'http://support.microsoft.com/kb/2289254'																		,'SQL Server 2008 SP2 CU 1 The first CU after SQL Server 2008 Service Pack 2.'
			UNION ALL	SELECT	'10.00.4272.00'	,'2467239'	,'http://support.microsoft.com/kb/2467239'																		,'SQL Server 2008 SP2 CU 2 CU#2 for SQL Server 2008 Service Pack 2. Fixes include recovering LOB pages from failed inserts, custom resolver issues in replication, and issues with online index rebuilds among others.'
			UNION ALL	SELECT	'10.00.4279.00'	,'2498535'	,'http://support.microsoft.com/kb/2498535'																,'SQL Server 2008 SP2 CU 3 CU#3 for SQL Server 2008 Service Pack 2. Fixes include issues with Merge replication, mirroring suspension issues, various T-SQL issues among others.'
			UNION ALL	SELECT	'10.00.4285.00'	,'2527180'	,'http://support.microsoft.com/kb/2527180'																,'SQL Server 2008 SP2 CU 4 CU#4 for SQL Server 2008 Service Pack 2. Fixes include issues with Filestream, various T-SQL issues and some SSIS items among others.'
			UNION ALL	SELECT	'10.00.4316.00'	,'2582285'	,'http://support.microsoft.com/kb/2582285'																		,'SQL Server 2008 SP2 Cumulative Update 5'
			UNION ALL	SELECT	'10.00.4321.00'	,'2582285'	,'http://support.microsoft.com/kb/2582285'																											,'SQL Server 2008 SP2 Cumulative Update 6'
			UNION ALL	SELECT	'10.00.4323.00'	,'2617148'	,'http://support.microsoft.com/kb/2617148'																											,'SQL Server 2008 SP2 Cumulative Update 7'
			UNION ALL	SELECT	'10.00.5500.00'	,'2546951'	,'http://support.microsoft.com/kb/2546951'																											,'SQL Server 2008 Service Pack 3'
			UNION ALL	SELECT	'10.00.5766.00'	,'2617146'	,'http://support.microsoft.com/kb/2617146'																											,'Cumulative update package 1 for SQL Server 2008 Service Pack 3'
			UNION ALL	SELECT	'10.00.5768.00'	,'2633143'	,'http://support.microsoft.com/kb/2633143'																											,'Cumulative update package 2 for SQL Server 2008 Service Pack 3'
	-- 2008 R2
			UNION ALL	SELECT	'10.50.1450.3'	,NULL		,NULL																											,'SQL Server 2008 R2 RC0'
			UNION ALL	SELECT	'10.50.1600.1'	,NULL		,NULL																											,'SQL Server 2008 R2 RTM'
			UNION ALL	SELECT	'10.50.1702.0'	,'981355'	,'http://support.microsoft.com/kb/981355'																	,'CU 1 for SQL Server 2008 R2 RTM'
			UNION ALL	SELECT	'10.50.1720.0'	,'2072493'	,'http://support.microsoft.com/kb/2072493'																		,'CU 2 for SQL Server 2008 R2 RTM'
			UNION ALL	SELECT	'10.50.1734.0'	,'2261464'	,'http://support.microsoft.com/kb/2261464'																		,'CU 3 for SQL Server 2008 R2 RTM'
			UNION ALL	SELECT	'10.50.1746.0'	,'2345451'	,'http://support.microsoft.com/kb/2345451'																		,'CU 4 for SQL Server 2008 R2 RTM includes fixes for TDE and full-text search with compression enabled.'
			UNION ALL	SELECT	'10.50.1753.0'	,'2438347'	,'http://support.microsoft.com/kb/2438347'																		,'CU 5 for SQL Server 2008 R2 RTM includes fixes for Reporting Services, replication with XML columns, and a number of engine fixes for various items'
			UNION ALL	SELECT	'10.50.1765.0'	,'2489376'	,'http://support.microsoft.com/kb/2489376'																,'CU 6 for SQL Server 2008 R2 RTM includes fixes for better performance for some self joins, Filestream with third party filters, and a number of SSAS filters.'
			UNION ALL	SELECT	'10.50.1777.0'	,'2507770'	,'http://support.microsoft.com/kb/2507770'																		,'CU 7 for SQL Server 2008 R2 RTM includes fixes for better performance for some bcp operations, merge replication issues, SQL Agent job scheduling, and SSRS performance among others.'
			UNION ALL	SELECT	'10.50.1797.0'	,'2534352'	,'http://support.microsoft.com/kb/2534352'																		,'CU 8 for SQL Server 2008 R2 RTM includes fixes for BIDS,replication issues with large stored procedures, timeouts with snapshot isolation, and SSRS dynamic images among others.'
			UNION ALL	SELECT	'10.50.1804.0'	,'2567713'	,'http://support.microsoft.com/kb/2567713'																		,'CU9 includes fixes for SSIS, MDX, XML, and SSRS'
			UNION ALL	SELECT	'10.50.1807.0'	,'2591746'	,'http://support.microsoft.com/kb/2591746'																,'CU10 includes fixed for deadlocks, various query issues, CDC problems, and XML data used in replication.'
			UNION ALL	SELECT	'10.50.1809.0'	,'981356'	,'http://support.microsoft.com/kb/981356'																		,'Cumulative update package 11 for SQL Server 2008 R2 includes fixes for replication, deadlocks, and MDX query issues.'
			UNION ALL	SELECT	'10.50.2500.0'	,'2528583'	,'http://support.microsoft.com/kb/2528583'																		,'Service Pack 1 for SQL Server 2008 R2'
			UNION ALL	SELECT	'10.50.2769.0'	,'2544793'	,'http://support.microsoft.com/kb/2544793'																,'CU 1 for SQL Server 2008 R2 SP1 includes fixes for TDS, timeouts, CDC, and BIDS among others.'
			UNION ALL	SELECT	'10.50.2772.0'	,'2567714'	,'http://support.microsoft.com/kb/2567714'																		,'CU 2 for SQL Server 2008 R2 SP1 includes fixes for T-SQL query results, trace erros with TVPs, data collector network port issues among others.'
			UNION ALL	SELECT	'10.50.2789.0'	,'2591748'	,'http://support.microsoft.com/kb/2591748'																,'CU#3 for SQL Server 2008 R2 SP1'
			UNION ALL	SELECT	'10.50.2796.0'	,'2633146'	,'http://support.microsoft.com/kb/2633146'																		,'Cumulative update package 4 for SQL Server 2008 R2 Service Pack 1'
			UNION ALL	SELECT	'10.50.2806.0'	,'2659694'	,'http://support.microsoft.com/kb/2659694'																		,'Cumulative update package 5 for SQL Server 2008 R2 Service Pack 1'
			UNION ALL	SELECT	'10.50.2811.0'	,'2679367'	,'http://support.microsoft.com/kb/2679367'																		,'Cumulative update package 5 for SQL Server 2008 R2 Service Pack 1'
			)
SELECT		HR.*
			,SBL.*
			,(SELECT MAX(SQLBuildNumber) FROM SQLBuildList BN where PARSENAME(BN.SQLBuildNumber,4)=PARSENAME(SBL.SQLBuildNumber,4) AND PARSENAME(BN.SQLBuildNumber,3)=PARSENAME(SBL.SQLBuildNumber,3)) [MostRecentBuildNumber]
			,(SELECT COUNT(*)-1 FROM SQLBuildList SL WHERE SQLBuildNumber between SBL.SQLBuildNumber AND (SELECT MAX(SQLBuildNumber) FROM SQLBuildList BN where PARSENAME(BN.SQLBuildNumber,4)=PARSENAME(SBL.SQLBuildNumber,4) AND PARSENAME(BN.SQLBuildNumber,3)=PARSENAME(SBL.SQLBuildNumber,3))) [UpdatesBehind]
			,DATEDIFF(day,SI.OSuptime,getdate())						[DaysSinceRebooted]
			,DATEDIFF(day,SI.SQLrecycleDate,getdate())					[DaysSinceRestart]
			,SI.dbaadmin_Version
			,(SELECT MAX(dbaadmin_Version) FROM dbo.DBA_ServerInfo WITH(NOLOCK) WHERE ServerName != 'SQLDEPLOYER02' AND LEFT(dbaadmin_Version+'X',1) = '2' AND SQLEnv = SI.SQLEnv)	[dbaadmin_GoldVersion]
			,SI.dbaperf_Version	
			,(SELECT MAX(dbaperf_Version) FROM dbo.DBA_ServerInfo WITH(NOLOCK) WHERE ServerName != 'SQLDEPLOYER02' AND LEFT(dbaperf_Version+'X',1) = '2' AND SQLEnv = SI.SQLEnv)	[dbaperf_GoldVersion]
			,SI.DEPLinfo_Version
			,(SELECT MAX(DEPLinfo_Version) FROM dbo.DBA_ServerInfo WITH(NOLOCK) WHERE ServerName != 'SQLDEPLOYER02' AND LEFT(DEPLinfo_Version+'X',1) = '2' AND SQLEnv = SI.SQLEnv)	[deplinfo_GoldVersion]
			,SI.TimeZone
			,SI.SystemModel
			,SI.AntiVirus_type
			,SI.AntiVirus_Excludes
FROM		(
			SELECT		SL.SQLName
						,SL.ServerName
						,Domain
						,EnvName
						,Check_Date
						,[Health_Status]
						,Apps
						,DBs
						,'file://'+SL.[ServerName]+'/'+REPLACE(SL.[SQLName],'\','$')+'_dbasql/dba_reports/SQLHealthReport_'+REPLACE(SL.[SQLName],'\','$')+'.txt' [ReportLink]
			FROM		(
						SELECT		SQLname	
									,RTRIM(LTRIM(REPLACE(dbaadmin.dbo.dbaudf_Concatenate(Subject01+ISNULL('('+NULLIF(Value01,' ')+') ',' ')+ISNULL(NULLIF(Notes01,' '),'')+CHAR(13)+CHAR(10)),CHAR(13)+CHAR(10)+',',CHAR(13)+CHAR(10)))) [Health_Status]
									,MAX(Check_date) AS [Check_date]
						FROM		(
									SELECT		RANK() OVER (Partition BY SQLName ORDER BY Check_date desc) ReportOrder
												,*
									FROM		[dbacentral].[dbo].[SQLHealth_Central] 
									WHERE		dbacentral.[dbo].[dbaudf_GetServerClass] ([SQLName]) = 'High'
									) SHC	 
						WHERE		ReportOrder = 1
						GROUP BY	SQLname	
						) SHC
			JOIN		(
						SELECT		UPPER(SI.[SQLName])																			[SQLName]
									,UPPER(SI.[ServerName])																		[ServerName]
									,MAX(UPPER(COALESCE(SI.SQLEnv,'--')))														[EnvName]
									,MAX(UPPER(COALESCE(SI.DomainName,'--')))													[Domain]
									,LTRIM((
												SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
												FROM		(
															SELECT		DISTINCT TOP 100 PERCENT
																		LTRIM(RTRIM(ExtractedText)) [ExtractedText]
															FROM		[DBAcentral].dbo.dbaudf_StringToTable(UPPER(isnull(NULLIF(dbaadmin.dbo.dbaudf_Concatenate(REPLACE(REPLACE(DI.[Appl_desc],'(',','),')',',')),''),'OTHER')),',')
															WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
															))			[Apps]
									,LTRIM((
												SELECT		dbaadmin.dbo.dbaudf_Concatenate(' '+ExtractedText)
												FROM		(
															SELECT		DISTINCT TOP 100 PERCENT
																		LTRIM(RTRIM(ExtractedText)) [ExtractedText]
															FROM		[DBAcentral].dbo.dbaudf_StringToTable(dbaadmin.dbo.dbaudf_Concatenate(UPPER(DI.[DBName])),',')
															WHERE		nullif(ExtractedText,'') IS NOT NULL ORDER BY 1) Data
															))			[DBs]
						FROM		[DBAcentral].[dbo].[DBA_ServerInfo] SI
						LEFT JOIN	[DBAcentral].[dbo].[DBA_DBInfo] DI
							ON		SI.SQLName = DI.SQLName
						WHERE		dbacentral.[dbo].[dbaudf_GetServerClass] (SI.[SQLName]) = 'High' 
						GROUP BY	SI.[SQLName],SI.[ServerName]
						) SL
					ON	SL.SQLname = SHC.[SQLname]
			) HR
JOIN		dbo.DBA_ServerInfo SI WITH(NOLOCK)
		ON	HR.SQLName = SI.SQLName
		
		
		
LEFT JOIN	(
			SELECT		T1.*
						,CASE WHEN CAST(PARSENAME(T1.SQLBuildNumber,2)+'.'+PARSENAME(T1.SQLBuildNumber,1)AS FLOAT) < CAST(PARSENAME(T2.PreferedBuild,2)+'.'+PARSENAME(T2.PreferedBuild,1)AS FLOAT) THEN 0 ELSE 1 END AS [MeetsMinimum]
			FROM		SQLBuildList T1
			JOIN		PreferedMinimumSQLBuilds T2
					ON	CAST(PARSENAME(T1.SQLBuildNumber,4)+'.'+PARSENAME(T1.SQLBuildNumber,3)AS FLOAT) = CAST(PARSENAME(T2.PreferedBuild,4)+'.'+PARSENAME(T2.PreferedBuild,3)AS FLOAT)
			)SBL
		ON	SBL.SQLBuildNumber = dbaadmin.dbo.Returnword(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SI.SQLver,'- ',''),'(SP1) ',''),'Intel ',''),'(',''),')',''),1)


GO


