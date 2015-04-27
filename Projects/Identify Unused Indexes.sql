SELECT OBJECT_NAME(I.object_id) Object_Name
    ,I.name Index_Name 
    ,CASE WHEN I.type = 1 THEN 'Clustered' 
          WHEN I.type = 2 THEN 'Non-Clustered' 
          ELSE 'Unknown' END Index_Type   
   
FROM sys.dm_db_index_usage_stats S RIGHT OUTER JOIN sys.indexes I
 ON S.index_id= I.index_id 
 and S.object_id = I.object_Id
 and s.database_id = DB_ID()
WHERE
    S.object_id is null
and I.type in (1,2)