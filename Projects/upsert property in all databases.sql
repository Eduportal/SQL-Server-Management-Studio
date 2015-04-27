sp_msForEachDB 'IF NOT EXISTS (SELECT value FROM [?].sys.fn_listextendedproperty(''EnableCodeComments'', default, default, default, default, default, default))
	EXEC [?].sys.sp_addextendedproperty @name = ''EnableCodeComments'', @value = ''0''
ELSE
	EXEC [?].sys.sp_updateextendedproperty @name = ''EnableCodeComments'', @value = ''0'''