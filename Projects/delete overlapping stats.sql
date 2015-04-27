/*
Statistics are used by SQL Server's query optimizer to help determine the most efficient execution plan for a query. 
When the option to automatically create statistics is enabled (which it is by default) SQL Server will create statistics 
on columns used in a query's predicate as necessary, which usually means when statistics don't already exist for the 
column in question.

Statistics are also created on the key columns of an index when the index is created. SQL Server understands the 
difference between auto created column statistics and index statistics and maintains both - you can see this by 
querying the sys.stats system view. As I found out firsthand not too long ago having both auto created statistics 
and index statistics on the same column caused the query optimizer to choose a different - and less than optimal - 
execution plan than when only the index statistics existed.

According to the MSDN article Statistics Used by the Query Optimizer in Microsoft SQL Server 2000 auto created 
statistics are automatically dropped over time if they are not used but that can take an undetermined amount of time. 
What if we're experiencing the kind of problem I previously wrote about? In most of the cases I've seen it makes sense 
to help SQL Server out by manually dropping the auto created statistics in favor of index statistics that exist for the 
same column.

Fortunately SQL Server contains everything we need to know to figure out when column statistics are overlapped by 
index statistics. The following query will identify overlapped\overlapping statistics and generate the statements 
you can use to drop the overlapped statistics. All the usual warnings apply here - although this has not caused any 
problems for me your mileage may vary so wield this with an appropriate degree of caution:




*/
/* For SQL 2008 and up - takes filtered indexes into consideration */ 
WITH    cteAutostats ( object_id, stats_id, name, has_filter, filter_definition, column_id ) 
          AS ( SELECT   ColumnStats.object_id , 
                        ColumnStats.stats_id , 
                        ColumnStats.name , 
                        ColumnStats.has_filter , 
                        ColumnStats.filter_definition , 
                        StatsColumns.column_id 
               FROM     sys.stats AS ColumnStats 
                        INNER JOIN sys.stats_columns AS StatsColumns ON ColumnStats.object_id = StatsColumns.object_id 
                                                              AND ColumnStats.stats_id = StatsColumns.stats_id 
               WHERE    ColumnStats.auto_created = 1 
                        AND StatsColumns.stats_column_id = 1 
             ) 
    SELECT  OBJECT_SCHEMA_NAME(ColumnStats.object_id) AS SchemaName , 
            OBJECT_NAME(ColumnStats.object_id) AS TableName , 
            ObjectColumns.name AS ColumnName , 
            ColumnStats.name AS Overlapped , 
            cteAutostats.name AS Overlapping , 
            'DROP STATISTICS ' + QUOTENAME(OBJECT_SCHEMA_NAME(ColumnStats.object_id)) + '.' + QUOTENAME(OBJECT_NAME(ColumnStats.object_id)) + '.' + QUOTENAME(cteAutostats.name) + ';' AS DropStatement 
    FROM    sys.stats AS ColumnStats 
            INNER JOIN sys.stats_columns AS StatsColumns ON ColumnStats.object_id = StatsColumns.object_id 
                                                            AND ColumnStats.stats_id = StatsColumns.stats_id 
            INNER JOIN cteAutostats ON StatsColumns.object_id = cteAutostats.object_id 
                                       AND StatsColumns.column_id = cteAutostats.column_id 
            INNER JOIN sys.columns AS ObjectColumns ON ColumnStats.object_id = ObjectColumns.object_id 
                                                       AND StatsColumns.column_id = ObjectColumns.column_id 
    WHERE   ColumnStats.auto_created = 0 
            AND StatsColumns.stats_column_id = 1 
            AND StatsColumns.stats_id != cteAutostats.stats_id 
            AND ( ( cteAutostats.has_filter = 1 
                    AND ColumnStats.has_filter = 1 
                    AND cteAutostats.filter_definition = ColumnStats.filter_definition 
                  ) 
                  OR ( cteAutostats.has_filter = 0 
                       AND ColumnStats.has_filter = 0 
                     ) 
                ) 
            AND OBJECTPROPERTY(ColumnStats.object_id, 'IsMsShipped') = 0 
    ORDER BY OBJECT_SCHEMA_NAME(ColumnStats.object_id) , 
            OBJECT_NAME(ColumnStats.object_id) , 
            ObjectColumns.name ; 
GO 

/* For SQL 2005 only */ 
WITH    cteAutostats ( object_id, stats_id, name, column_id ) 
          AS ( SELECT   ColumnStats.object_id , 
                        ColumnStats.stats_id , 
                        ColumnStats.name , 
                        StatsColumns.column_id 
               FROM     sys.stats AS ColumnStats 
                        INNER JOIN sys.stats_columns AS StatsColumns ON ColumnStats.object_id = StatsColumns.object_id 
                                                              AND ColumnStats.stats_id = StatsColumns.stats_id 
               WHERE    ColumnStats.auto_created = 1 
                        AND StatsColumns.stats_column_id = 1 
             ) 
    SELECT  OBJECT_SCHEMA_NAME(ColumnStats.object_id) AS SchemaName , 
            OBJECT_NAME(ColumnStats.object_id) AS TableName , 
            ObjectColumns.name AS ColumnName , 
            ColumnStats.name AS Overlapped , 
            cteAutostats.name AS Overlapping , 
            'DROP STATISTICS ' + QUOTENAME(OBJECT_SCHEMA_NAME(ColumnStats.object_id)) + '.' + QUOTENAME(OBJECT_NAME(ColumnStats.object_id)) + '.' + QUOTENAME(cteAutostats.name) + ';' AS DropStatement 
    FROM    sys.stats AS ColumnStats 
            INNER JOIN sys.stats_columns AS StatsColumns ON ColumnStats.object_id = StatsColumns.object_id 
                                                            AND ColumnStats.stats_id = StatsColumns.stats_id 
            INNER JOIN cteAutostats ON StatsColumns.object_id = cteAutostats.object_id 
                                       AND StatsColumns.column_id = cteAutostats.column_id 
            INNER JOIN sys.columns AS ObjectColumns ON ColumnStats.object_id = ObjectColumns.object_id 
                                                       AND StatsColumns.column_id = ObjectColumns.column_id 
    WHERE   ColumnStats.auto_created = 0 
            AND StatsColumns.stats_column_id = 1 
            AND StatsColumns.stats_id != cteAutostats.stats_id 
            AND OBJECTPROPERTY(ColumnStats.object_id, 'IsMsShipped') = 0 
    ORDER BY OBJECT_SCHEMA_NAME(ColumnStats.object_id) , 
            OBJECT_NAME(ColumnStats.object_id) , 
            ObjectColumns.name ; 
GO