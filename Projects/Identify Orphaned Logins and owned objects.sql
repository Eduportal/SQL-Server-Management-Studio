Set Nocount on
Declare @OrphLogins Table (SID Varchar(200), NTlogin Varchar(200))
 -- Inserting the orphaned NT user into temp table
Insert into @OrphLogins EXEC Sp_ValidateLogins
 --Display the number of Orphaned Users
Select NTLogin As "Orphaned Logins" From @OrphLogins
DECLARE @Login varchar(200)
DECLARE Orphcursor CURSOR FOR
SELECT NTLogin from @OrphLogins
OPEN OrphCursor
FETCH NEXT FROM OrphCursor INTO @Login
WHILE @@FETCH_STATUS = 0
BEGIN
 
Declare @TSequel Varchar(MAX), @DatabaseO Varchar(MAX)
    Select @DatabaseO = ' SrPri.name COLLATE DATABASE_DEFAULT as Login, DbPri.Name  COLLATE DATABASE_DEFAULT as [User],
 orph.name COLLATE DATABASE_DEFAULT As [Name],
 orph.type_desc COLLATE DATABASE_DEFAULT As [Object Type]
 From %D%.sys.objects orph
    Join %D%.sys.database_principals DbPri ON Coalesce(orph.principal_id,
 (Select Sch.Principal_ID From %D%.sys.schemas Sch Where Sch.Schema_ID = orph.schema_id)) = DbPri.principal_id
    Left Join %D%.sys.server_principals SrPri On SrPri.sid = DbPri.sid '
    Select @TSequel = 'SELECT * FROM
    (Select '+Cast(database_id as varchar(9))+' as DBID, ''master'' as DBName, '
                     + Replace(@DatabaseO, '%D%', [name])
    From master.sys.databases
    Where [name] = 'master'
    Select @TSequel = @TSequel + 'UNION ALL Select '+Cast(database_id as varchar(9))+', '''+[name]+''', '
                     + Replace(@DatabaseO, '%D%', [name])
    From master.sys.databases
    Where [name] != 'master'
    Select @TSequel = @TSequel + ') LL  Where Login = ''' + @Login + ''''
    --print @sql
    EXEC (@TSequel)
  
   FETCH NEXT FROM OrphCursor
   INTO @Login
END
 
CLOSE OrphCursor
DEALLOCATE OrphCursor
GO
 