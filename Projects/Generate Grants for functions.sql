select XTYPE,
	'GRANT '
	+ CASE XTYPE
		WHEN 'AF' THEN  'EXECUTE'
		WHEN 'FS' THEN  'EXECUTE'
		WHEN 'IF' THEN  'SELECT'
		WHEN 'TF' THEN  'SELECT'
		WHEN 'FN' THEN  'EXECUTE'
		END
	+ ' ON [' + name + '] TO [Public]'
From sysobjects
WHERE XTYPE IN
(
'IF' --IN-LINE TABLE FUNCTION
,'TF' --TABLE FUNCTION
,'FN' --SCALAR FUNCTION
,'AF' --AGGREGATE FUNCTIONS
,'FS'
)
order by xtype

  
 
  
