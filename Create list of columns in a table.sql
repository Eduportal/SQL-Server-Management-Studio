
select dbaadmin.dbo.dbaudf_Concatenate(name) From sys.columns 
where object_id = object_id('[mRemoteNG].[dbo].[tblCons]')
and is_nullable = 0
and is_identity = 0
and is_computed = 0
and default_object_id = 0
ORDER BY column_id