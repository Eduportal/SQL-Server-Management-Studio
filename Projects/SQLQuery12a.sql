EXEC sp_addlinkedserver 'ADSI', 'Active Directory Services 2.5', 'ADSDSOObject', 'adsdatasource' 
GO
exec sp_configure 'show advanced options', 1
reconfigure with override

exec sp_configure 'Ad Hoc Distributed Queries', 1 
reconfigure 
GO

SELECT * FROM OpenQuery(ADSI, 'SELECT * FROM ''LDAP://DC=amer,DC=gettywan,DC=com''') 

GO

SELECT *

FROM OPENROWSET(
'AdsDsoObject'
,'User ID= UserID; Password= Pwd; ADSI Flag=0x11;Page Size=10000'
,'SELECT * FROM
''LDAP://SEAFREAMERDC25/DC=amer,DC=gettywan,DC=com''') 


