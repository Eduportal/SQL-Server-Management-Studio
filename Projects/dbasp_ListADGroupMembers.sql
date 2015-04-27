USE DBAADMIN
GO
DROP PROCEDURE	dbasp_ListADGroupMembers
GO
CREATE PROCEDURE	dbasp_ListADGroupMembers
	(
	@GroupName	NVarChar(4000)
	,@NameList	VarChar(8000) OUTPUT
	,@EMailList	VarChar(8000) OUTPUT
	)
AS
BEGIN
	CREATE TABLE	#Results
		(
		[displayName]		[nvarchar](256) NULL,
		[distinguishedName]	[nvarchar](256) NULL,
		[mail]			[nvarchar](256) NULL
		)

	DECLARE @Query		NVarChar(4000)
		,@Name		NVarChar(4000)
		
	SET	@Query		= 'SELECT @Name=distinguishedName FROM OPENROWSET(''AdsDsoObject'',''ADSI Flag=0x11;Page Size=10000'',''SELECT distinguishedName FROM ''''LDAP://SEAFREAMERDC25/DC=amer,DC=gettywan,DC=com'''' where objectClass = ''''Group'''' and cn='''''+@GroupName+''''''')'

	exec sp_executesql @Query,N'@Name varchar(2000) OUTPUT',@Name=@Name OUT

	SET	@Query		= 'INSERT INTO #Results SELECT displayName, distinguishedName, mail FROM OPENROWSET(''AdsDsoObject'',''ADSI Flag=0x11;Page Size=10000'',''SELECT displayName, distinguishedName, mail FROM ''''LDAP://SEAFREAMERDC25/DC=amer,DC=gettywan,DC=com'''' where objectClass = ''''User'''' AND memberOf = ''''' + @Name + ''''''')' 

	exec sp_executesql @Query

	SET	@NameList = ''
	SET	@EMailList = ''

	SELECT	@EMailList = @EMailList + mail +'|'
		,@NameList = @NameList + displayName +'|'
	FROM	#Results

	DROP TABLE #Results
END
GO