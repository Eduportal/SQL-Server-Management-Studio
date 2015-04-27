


DECLARE		@TSQL		VarChar(max)
SET			@TSQL		=
'SELECT		getdate() AS [CaptureDate]
			,'''+@@SERVERNAME+''' AS [Origin]
			,(SELECT * From DBA_ServerInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_ServerInfo''),XMLSCHEMA)
			,(SELECT * From DBA_ClusterInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_ClusterInfo''),XMLSCHEMA)
			,(SELECT * From DBA_CommentInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_CommentInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DBInfo			WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DBInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DeplInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DeplInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DiskInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DiskInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DiskPerfinfo	WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DiskPerfinfo''),XMLSCHEMA)
			,(SELECT * From DBA_UserLoginInfo	WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_UserLoginInfo''),XMLSCHEMA)
FROM		dbo.DBA_ServerInfo RunBook FOR XML AUTO,TYPE,ROOT(''DBA_RunBooks'')'

EXEC (@TSQL)

