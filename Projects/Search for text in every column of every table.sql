DROP PROCEDURE spSearchStringInTable
GO

CREATE PROCEDURE spSearchStringInTable
(@SearchString NVARCHAR(MAX),
 @Table_Schema_Name sysname)
 AS
 BEGIN
 
DECLARE @Columns NVARCHAR(MAX), @Cols NVARCHAR(MAX), @PkColumn NVARCHAR(MAX)

 DECLARE @Table_Schema sysname, @Table_Name sysname

SELECT	@Table_Schema = Parsename(@Table_Schema_Name,2)
		,@Table_Name = Parsename(@Table_Schema_Name,1)

RAISERROR(@Table_Schema_Name,-1,-1) WITH NOWAIT

-- Get all character columns
SET @Columns = STUFF((SELECT ', ' + QUOTENAME(Column_Name) 
 FROM INFORMATION_SCHEMA.COLUMNS 
 WHERE DATA_TYPE IN ('text','ntext','varchar','nvarchar','char','nchar')
 AND TABLE_NAME = @Table_Name 
 ORDER BY COLUMN_NAME 
 FOR XML PATH('')),1,2,'')

IF @Columns IS NULL -- no character columns
   RETURN -1

-- Get columns for select statement - we need to convert all columns to nvarchar(max)
SET @Cols = STUFF((SELECT ', cast(' + QUOTENAME(Column_Name) + ' as nvarchar(max)) as ' + QUOTENAME(Column_Name)
 FROM INFORMATION_SCHEMA.COLUMNS 
 WHERE DATA_TYPE IN ('text','ntext','varchar','nvarchar','char','nchar')
 AND TABLE_NAME = @Table_Name 
 ORDER BY COLUMN_NAME 
 FOR XML PATH('')),1,2,'')
 
 SET @PkColumn = STUFF((SELECT N' + ''|'' + ' + ' cast(' + QUOTENAME(CU.COLUMN_NAME) + ' as nvarchar(max))' 
 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
 INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CU ON TC.TABLE_NAME = CU.TABLE_NAME
 AND TC.TABLE_SCHEMA = CU.TABLE_SCHEMA 
 AND Tc.CONSTRAINT_NAME = CU.CONSTRAINT_NAME 
 WHERE TC.CONSTRAINT_TYPE ='PRIMARY KEY' AND TC.TABLE_SCHEMA = @Table_Schema AND TC.TABLE_NAME = @Table_Name 
 ORDER BY CU.COLUMN_NAME
 FOR XML PATH('')),1,9,'') 

 IF @PkColumn IS NULL
    SELECT @PkColumn = 'cast(NULL as nvarchar(max))' 
    
 -- set select statement using dynamic UNPIVOT
 DECLARE @SQL NVARCHAR(MAX)
 SET @SQL = 'select *, ' + QUOTENAME(@Table_Schema,'''') + 'as [Table Schema], ' + QUOTENAME(@Table_Name,'''') + ' as [Table Name]' +
  ' from 
  (select '+ @PkColumn + ' as [PK Column], ' + @Cols + ' from ' + QUOTENAME(@Table_Schema) + '.' + QUOTENAME(@Table_Name) + ' WITH(NOLOCK) ' +
 ' )src UNPIVOT ([Column Value] for [Column Name] IN (' + @Columns + ')) unpvt 
 WHERE [Column Value] LIKE ''%'' + @SearchString + ''%'''
 
 --print @SQL
 
EXECUTE sp_ExecuteSQL @SQL, N'@SearchString nvarchar(max)', @SearchString 
END
GO

sp_msforeachtable 'exec spSearchStringInTable ''All Advertising Pack'',''?'''


DROP PROCEDURE spSearchStringInTable
GO