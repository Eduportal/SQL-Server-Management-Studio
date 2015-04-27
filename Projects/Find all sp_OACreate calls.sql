select		OBJECT_NAME(id)
		,dbaadmin.dbo.dbaudf_ReturnPart(REPLACE(SUBSTRING(text,CHARINDEX('sp_OACreate',text,1)+12,40),',','|'),1)
		


From		syscomments where text like '%sp_oaCreate%'
order by 1