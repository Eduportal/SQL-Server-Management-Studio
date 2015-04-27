-- Version 4

DECLARE @ObjectID int
--SELECT @ObjectID = OBJECT_ID('SubscriptionDetail')

;WITH IndexSize
AS(
    SELECT object_id
        ,index_id
        ,CAST((SUM(reserved_page_count) * CAST(8 as float))/1024 as decimal(12,2)) as size_in_mb
    FROM sys.dm_db_partition_stats
    GROUP BY object_id, index_id
)
,preIndexAnalysis
AS (
    SELECT 
        OBJECT_SCHEMA_NAME(t.object_id) as schema_name
        ,t.name as table_name
        ,COALESCE(i.name, 'N/A') as index_name
        ,CASE WHEN i.is_unique = 1 THEN 'UNIQUE ' ELSE '' END + i.type_desc as type_desc
        ,iz.size_in_mb
        ,NULL as impact
        ,ROW_NUMBER() 
            OVER (PARTITION BY i.object_id ORDER BY i.is_primary_key desc, ius.user_seeks + ius.user_scans + ius.user_lookups desc) as ranking
        ,ius.user_seeks + ius.user_scans + ius.user_lookups as user_total
        ,COALESCE(CAST(100 * (ius.user_seeks + ius.user_scans + ius.user_lookups)
            /(NULLIF(SUM(ius.user_seeks + ius.user_scans + ius.user_lookups) 
            OVER(PARTITION BY i.object_id), 0) * 1.) as decimal(6,2)),0) as user_total_pct
        ,ius.user_seeks
        ,ius.user_scans
        ,ius.user_lookups
        ,STUFF((SELECT ', ' + QUOTENAME(c.name)
                FROM sys.index_columns ic
                    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
                WHERE i.object_id = ic.object_id
                AND i.index_id = ic.index_id
                AND is_included_column = 0
                ORDER BY key_ordinal ASC
                FOR XML PATH('')), 1, 2, '') AS indexed_columns
        ,STUFF((SELECT ', ' + QUOTENAME(c.name)
                FROM sys.index_columns ic
                    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
                WHERE i.object_id = ic.object_id
                AND i.index_id = ic.index_id
                AND is_included_column = 1
                ORDER BY key_ordinal ASC
                FOR XML PATH('')), 1, 2, '') AS included_columns
        ,i.object_id
        ,i.index_id
        ,(SELECT QUOTENAME(ic.column_id,'(')
                FROM sys.index_columns ic
                WHERE i.object_id = ic.object_id
                AND i.index_id = ic.index_id
                AND is_included_column = 0
                ORDER BY key_ordinal ASC
                FOR XML PATH('')) AS indexed_columns_compare
        ,COALESCE((SELECT QUOTENAME(ic.column_id, '(')
                FROM sys.index_columns ic
                WHERE i.object_id = ic.object_id
                AND i.index_id = ic.index_id
                AND is_included_column = 1
                ORDER BY key_ordinal ASC
                FOR XML PATH('')), SPACE(0)) AS included_columns_compare
    FROM sys.tables t
        INNER JOIN sys.indexes i ON t.object_id = i.object_id
        LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id AND ius.database_id = db_id()
        INNER JOIN IndexSize iz ON i.object_id = iz.object_id AND i.index_id = iz.index_id
    WHERE t.object_id = @ObjectID OR @ObjectID IS NULL
    UNION ALL
    SELECT 
        OBJECT_SCHEMA_NAME(mid.object_id) as schema_name
        ,OBJECT_NAME(mid.object_id) as table_name
        ,'--MISSING--'
        ,'--NONCLUSTERED--'
        ,NULL
        ,(migs.user_seeks + migs.user_scans) * migs.avg_user_impact as impact
        ,0 as ranking
        ,migs.user_seeks + migs.user_scans as user_total
        ,NULL as user_total_pct
        ,migs.user_seeks 
        ,migs.user_scans
        ,0 as user_lookups
        ,COALESCE(equality_columns + ', ', SPACE(0)) + COALESCE(inequality_columns, SPACE(0)) as indexed_columns
        ,included_columns
        ,mid.object_id
        ,NULL
        ,NULL
        ,NULL
    FROM sys.dm_db_missing_index_details mid
        INNER JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
        INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
    WHERE database_id = db_id()
    AND (mid.object_id = @ObjectID OR @ObjectID IS NULL)
)
,ForeignKeys
AS (
    SELECT fk.name + '|PARENT' AS name
        ,fkc.parent_object_id AS object_id
        ,STUFF((SELECT ', ' + QUOTENAME(c.name)
                FROM sys.foreign_key_columns ifkc
                    INNER JOIN sys.columns c ON ifkc.parent_object_id = c.object_id AND ifkc.parent_column_id = c.column_id
                WHERE fk.object_id = ifkc.constraint_object_id
                ORDER BY ifkc.constraint_column_id
                FOR XML PATH('')), 1, 2, '') AS fk_columns
        ,(SELECT QUOTENAME(ifkc.parent_column_id,'(')
                FROM sys.foreign_key_columns ifkc
                WHERE fk.object_id = ifkc.constraint_object_id
                ORDER BY ifkc.constraint_column_id
                FOR XML PATH('')) AS fk_columns_compare
    FROM sys.foreign_keys fk
        INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    WHERE fkc.constraint_column_id = 1
    AND (fkc.parent_object_id = @ObjectID OR @ObjectID IS NULL)
    UNION ALL
    SELECT fk.name + '|REFERENCED' as name
        ,fkc.referenced_object_id AS object_id
        ,STUFF((SELECT ', ' + QUOTENAME(c.name)
                FROM sys.foreign_key_columns ifkc
                    INNER JOIN sys.columns c ON ifkc.referenced_object_id = c.object_id AND ifkc.referenced_column_id = c.column_id
                WHERE fk.object_id = ifkc.constraint_object_id
                ORDER BY ifkc.constraint_column_id
                FOR XML PATH('')), 1, 2, '') AS fk_columns
        ,(SELECT QUOTENAME(ifkc.referenced_column_id,'(')
                FROM sys.foreign_key_columns ifkc
                WHERE fk.object_id = ifkc.constraint_object_id
                ORDER BY ifkc.constraint_column_id
                FOR XML PATH('')) AS fk_columns_compare
    FROM sys.foreign_keys fk
        INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    WHERE fkc.constraint_column_id = 1
    AND (fkc.parent_object_id = @ObjectID OR @ObjectID IS NULL)
)
,MemoryBuffer
AS (
    SELECT 
        obj.object_id
        ,obj.index_id
        ,COUNT(*)AS Buffered_Page_Count
        ,CAST(COUNT(*) as bigint)*CAST(8 as float)/1024 as Buffer_MB
    FROM sys.dm_os_buffer_descriptors AS bd 
        INNER JOIN 
        (
            SELECT object_name(object_id) AS name 
                ,index_id ,allocation_unit_id, object_id
            FROM sys.allocation_units AS au
                INNER JOIN sys.partitions AS p 
                    ON au.container_id = p.hobt_id 
                        AND (au.type = 1 OR au.type = 3)
            UNION ALL
            SELECT object_name(object_id) AS name   
                ,index_id, allocation_unit_id, object_id
            FROM sys.allocation_units AS au
                INNER JOIN sys.partitions AS p 
                    ON au.container_id = p.hobt_id 
                        AND au.type = 2
        ) AS obj ON bd.allocation_unit_id = obj.allocation_unit_id
    WHERE database_id = db_id()
    GROUP BY obj.object_id ,obj.index_id
)
, IndexAnalysis
AS (
    SELECT ia.object_id
        ,ia.index_id
        ,schema_name
        ,table_name
        ,index_name
        ,type_desc
        ,size_in_mb
        ,impact
        ,ranking
        ,user_total
        ,user_total_pct
        ,CAST(100 * (user_seeks + user_scans + user_lookups)
            /(NULLIF(SUM(user_seeks + user_scans + user_lookups) 
            OVER(PARTITION BY schema_name, table_name), 0) * 1.) as decimal(6,2)) as estimated_percent
        ,user_seeks
        ,user_scans
        ,user_lookups
        ,indexed_columns
        ,included_columns
        ,STUFF((SELECT ', ' + index_name AS [data()]
            FROM preIndexAnalysis iia
            WHERE ia.object_id = iia.object_id
            AND ia.index_id <> iia.index_id
            AND ia.indexed_columns_compare = iia.indexed_columns_compare
            AND ia.included_columns_compare = iia.included_columns_compare
            FOR XML PATH('')), 1, 2, '') AS duplicate_indexes
        ,STUFF((SELECT ', ' + index_name AS [data()]
            FROM preIndexAnalysis iia
            WHERE ia.object_id = iia.object_id
            AND ia.index_id <> iia.index_id
            AND (ia.indexed_columns_compare LIKE iia.indexed_columns_compare + '%' 
                OR iia.indexed_columns_compare LIKE ia.indexed_columns_compare + '%')
            AND ia.indexed_columns_compare <> iia.indexed_columns_compare 
            FOR XML PATH('')), 1, 2, '') AS overlapping_indexes
        ,STUFF((SELECT ', ' + name AS [data()]
            FROM ForeignKeys ifk
            WHERE ifk.object_id = ia.object_id
            AND ia.indexed_columns_compare LIKE ifk.fk_columns_compare + '%'
            FOR XML PATH('')), 1, 2, '') AS related_foreign_keys
        ,CAST((SELECT name
            FROM ForeignKeys
            WHERE ForeignKeys.object_id = ia.object_id
            AND ia.indexed_columns_compare LIKE ForeignKeys.fk_columns_compare + '%'
            FOR XML AUTO) as xml) AS related_foreign_keys_xml
    FROM preIndexAnalysis ia
    UNION ALL
    SELECT fk.object_id
        ,NULL
        ,OBJECT_SCHEMA_NAME(fk.object_id) AS schema_name
        ,OBJECT_NAME(fk.object_id) AS table_name
        ,fk.name AS index_name
        ,'--MISSING FOREIGN KEY--'
        ,NULL
        ,NULL 
        ,NULL
        ,NULL 
        ,NULL 
        ,NULL 
        ,NULL 
        ,NULL 
        ,NULL
        ,fk.fk_columns
        ,NULL 
        ,NULL 
        ,NULL 
        ,NULL 
        ,NULL
    FROM ForeignKeys fk
        LEFT OUTER JOIN preIndexAnalysis ia
    ON fk.object_id = ia.object_id
    AND ia.indexed_columns_compare LIKE fk.fk_columns_compare + '%'
    WHERE ia.index_name IS NULL
)
SELECT schema_name
    ,table_name
    ,index_name
    ,type_desc
    ,size_in_mb
    ,mb.Buffer_MB
    ,CAST(100*mb.Buffer_MB/NULLIF(size_in_mb,0) AS decimal(6,2)) AS buffer_pct
    ,impact
    ,user_total
    ,user_total_pct
    ,estimated_percent
    ,user_seeks
    ,user_scans
    ,user_lookups
    ,indexed_columns
    ,included_columns
    ,duplicate_indexes
    ,overlapping_indexes
    ,related_foreign_keys
FROM IndexAnalysis ia
    LEFT OUTER JOIN MemoryBuffer mb ON ia.object_id = mb.object_id AND ia.index_id = mb.index_id
ORDER BY SUM(Buffer_MB) OVER (PARTITION BY ia.object_id) desc, table_name, user_total desc, buffer_mb