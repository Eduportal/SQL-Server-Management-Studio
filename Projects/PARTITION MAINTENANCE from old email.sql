--PARTITION MAINTENANCE

 

DECLARE @TableName   nVarChar(1024)

DECLARE @TableNameExt varchar(25)

DECLARE @PartitionNumber INT

DECLARE @KeepPartitionValue VarChar(1024)

 

SET @TableName = 'ccClickcost_Report_Archive_Partitioned'

SET @TableNameExt = '_STAGED_OLD'

SET @PartitionNumber = 2   -- should always keep at 2,

-- leaving partition 1 as a catch all for old data rather than causing errors on insert.

SET @KeepPartitionValue = CONVERT(VarChar(1024),DATEADD(month,-13,getdate()),121)

 

SET NOCOUNT ON

DECLARE @TSQL VarChar(MAX)

DECLARE @Date DateTime

DECLARE @Partition_ID BigInt

DECLARE @FileGroupName nVarChar(1024)

DECLARE @Data_Space_ID INT

DECLARE @Partition_Scheme_ID INT

DECLARE @Function_ID INT

DECLARE @FunctionName nVarChar(1024)

DECLARE @SchemaName nVarChar(1024)

DECLARE @Range Sql_Variant

DECLARE @IxTableID INT

DECLARE @IxName SYSNAME

DECLARE @IxID INT

DECLARE @IXSQL NVARCHAR(4000)

DECLARE @PKSQL NVARCHAR(4000)

DECLARE @IxColumn SYSNAME

DECLARE @IxFirstColumn BIT

DECLARE @PK varchar(2)

DECLARE @IndID int

DECLARE @IndexName varchar(255)

DECLARE @IndKey int

DECLARE @DataType varchar(40)

DECLARE @Length varchar(4)

DECLARE @Precision varchar(4)

DECLARE @Scale varchar(4)

DECLARE @Isnullable varchar(1)

DECLARE @DefaultValue varchar(255)

DECLARE @GroupName varchar(35)

DECLARE @ColumnName varchar(255)

DECLARE @ConstraintName varchar(255)

DECLARE @collation sysname

DECLARE @TEXTIMAGE_ON bit

DECLARE @IdentityColumn bit

DECLARE @DFQuery varchar(MAX)

DECLARE @IndexNameOrig varchar(255)

DECLARE @UniqueIndex int

DECLARE @Partition_Schema_Name VarChar(255)

DECLARE @Partition_Function_Name VarChar(255)

DECLARE @Rows BigInt

DECLARE @stmt nVarChar(4000)

DECLARE @Params nVarChar(4000)

DECLARE @KeepPartitionNumber INT

 

SET @DFQuery = ''

SET @TEXTIMAGE_ON = 0

SET @PK = ''

SET @IndKey = 1

SET @Date = GetDate()

PRINT 'Start...'

PRINT @Date

 

----Begin creating temp tables

 

--temp table #TableScript is used to gather data needed to generate script that will create the table

 

CREATE TABLE #TableScript (

       ColumnName varchar (30),

       DataType varchar(40),

       Length varchar(4),

       [Precision] varchar(4),

       Scale varchar(4),

       IsNullable varchar(1),

       TableName varchar(30),

       ConstraintName varchar(255),

       DefaultValue varchar (255),

       GroupName varchar(35),

       collation sysname NULL,

       IdentityColumn bit NULL

)

 

--temp table #IndexScript is used to gather data needed to generate script that will create indexes for table

CREATE TABLE #IndexScript (

       IndexName varchar (255),

       IndId int,

       ColumnName varchar (255),

       IndKey int,

       UniqueIndex int

)

 

--End creating temp tables

 

IF OBJECT_ID(@TableName) IS NULL

BEGIN

       PRINT 'Table ' + @TableName + ' not found.'

END

ELSE

BEGIN

       -- 1 GET VALUES NEEDED FOR PROCESS

       SELECT        @Partition_ID = main.partition_id

                           , @FileGroupName = main.FileGroupName

                           , @Data_Space_ID = main.data_space_id

                           , @Partition_Scheme_ID = main.partition_scheme_id

                           , @Partition_Schema_Name = main.SchemaName

                           , @Function_ID = main.function_id

                           , @Partition_Function_Name = main.FunctionName

                           , @Range = Part.Value

                            , @Rows = main.Rows

       FROM          (

                     select        a.partition_id

                                         , a.partition_number

                                         , c.data_space_id

                                         , c.name FileGroupName

                                         , d.partition_scheme_id

                                         , e.name SchemaName

                                         , e.function_id

                                         , f.name FunctionName

                                         , a.rows

                     from          sys.partitions a

                     inner join    sys.allocation_units b

                           on            a.hobt_id = b.container_id

                     inner join    sys.data_spaces c

                           on            b.data_space_id = c.data_space_id

                     inner join    sys.destination_data_spaces d

                           on            c.data_space_id = d.data_space_id

                     inner join    sys.partition_schemes e

                           on            d.partition_scheme_id = e.data_space_id

                     inner join    sys.partition_functions f

                           on            e.function_id = f.function_id

 

                     where         a.object_id = OBJECT_ID(@TableName)

                           AND           a.partition_number = @PartitionNumber

                           ) main

       left join     (

                           select        a.function_id

                                                , b.value

                                                , case when a.boundary_value_on_right = 0 then b.boundary_id else b.boundary_id + 1 end partition_id

                           from          sys.partition_functions a inner join sys.partition_range_values b on a.function_id = b.function_id

                           ) part

              on            main.function_id = part.function_id

              and           main.partition_number = part.partition_id

 

 

       INSERT INTO #TableScript (ColumnName, DataType, Length, [Precision], Scale, IsNullable, TableName,

                             ConstraintName, DefaultValue, GroupName, collation, IdentityColumn)

       SELECT  LEFT(c.name,30) AS ColumnName,

              LEFT(t.name,30) AS DataType,

              CASE t.length

                     WHEN 8000 THEN c.prec  --This criteria used because Enterprise Manager delivers the length in parenthesis for these datatypes when using its scripting capabilities.

                     ELSE NULL

              END AS Length,

              CASE t.name

                     WHEN 'numeric' THEN c.prec

                     WHEN 'decimal' THEN c.prec

                     ELSE NULL

              END AS [Precision],

              CASE t.name

                     WHEN 'numeric' THEN c.scale

                     WHEN 'decimal' THEN c.scale

                     ELSE NULL

              END AS Scale,

              c.isnullable,

              LEFT(o.name,30) AS TableName,

              d.name AS ConstraintName,

              cm.text AS DefaultValue,

              coalesce(p.name,g1a.groupname) groupname,

              c.collation,

              CASE

                     WHEN c.autoval IS NULL THEN 0

                     ELSE 1

              END AS IdentityColumn

       FROM syscolumns c

       INNER JOIN sysobjects o ON c.id = o.id

       LEFT JOIN systypes t ON t.xusertype = c.xusertype --the first three joins get column names, data types, and column nullability.

       LEFT JOIN sysobjects d ON c.cdefault = d.id --this left join gets column default constraint names.

       LEFT JOIN syscomments cm ON cm.id = d.id --this left join gets default values for default constraints.

       LEFT JOIN sysindexes g1 ON g1.id = o.id --the left join for sysfilegroups and sysindexes with aliases g1 and g1a

       LEFT JOIN sysfilegroups g1a ON g1.groupid = g1a.groupid --are for determining which file group the table is in.

       LEFT JOIN     (

                           SELECT        p1.object_id

                                                , p1.index_id

                                                , p1.Partition_number

                                                , ds.name

                           FROM          sys.partitions p1

                           inner join    sys.allocation_units au

                                  on            p1.hobt_id = au.container_id

                           inner join    sys.data_spaces ds

                                  on            au.data_space_id = ds.data_space_id

                           ) p

              ON            p.object_id = o.id AND P.index_id = g1.indid AND p.partition_number = @PartitionNumber

       WHERE o.name = @TableName

       AND g1.id = o.id AND g1.indid in (0, 1)  --these two conditions are to isolate the file group of the table.

 

 

       INSERT INTO #IndexScript (IndexName, IndId, ColumnName, IndKey, UniqueIndex)

       SELECT        i.name,

              i.indid,

              c.name,

              k.keyno,

              (i.status & 2)  --Learned this will identify a unique index from sp_helpindex

       FROM sysindexes i

       INNER JOIN sysobjects o ON i.id = o.id

       INNER JOIN sysindexkeys k ON i.id = k.id AND i.indid = k.indid

       INNER JOIN syscolumns c ON c.id = k.id AND k.colid = c.colid

       WHERE o.name = @TableName

       AND i.indid > 0 and i.indid < 255 --eliminates non indexes

       AND LEFT(i.name,7) <> '_WA_Sys'  --eliminates statistic indexes

 

 

       -- get oldest partition number to keep

       SET @stmt     = 'SELECT @KeepPartitionNumber = $PARTITION.' + @Partition_Function_Name + '(' + @KeepPartitionValue + ')'

       SET @Params   = '@KeepPartitionNumber INT OUT'

 

       EXEC sp_executesql @stmt = @stmt, @params = @Params,@KeepPartitionNumber = @KeepPartitionNumber OUT

 

       WHILE @PartitionNumber IN  (

                                                       SELECT        partition_number

                                                       From          sys.partitions

                                                       where         object_id = object_id('ccClickcost_Report_Archive_Partitioned')

                                                              AND           partition_number < @KeepPartitionNumber

                                                       )

       BEGIN

 

              -- 1 CREATE STAGING TABLE TO HOLD OLD MONTH

              ------------------------------------------------------------------------------

              SET @TSQL = 'if exists (select * from sysobjects where id = object_id(N' + '''[dbo].['

                     + @TableName + @TableNameExt + ']''' + ') and OBJECTPROPERTY(id, N' + '''IsUserTable''' + ') = 1)'

                     + CHAR(13) + CHAR(10) + 'drop table [dbo].[' + @TableName + @TableNameExt + ']'

                     + CHAR(13) + CHAR(10) + 'GO'

                     + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'CREATE TABLE [dbo].[' + @TableName + @TableNameExt + '] ('

 

              DECLARE ColumnName Cursor For

              SELECT ColumnName

              FROM #TableScript

 

              OPEN ColumnName

 

              FETCH NEXT FROM ColumnName INTO @ColumnName

 

              WHILE (@@fetch_status = 0)

              BEGIN

                     SELECT  @DataType = DataType,

                           @Length = Length,

                           @Precision = [Precision],

                            @Scale = Scale,

                           @Isnullable = isnullable,

                           @DefaultValue = DefaultValue,

                           @ConstraintName = ConstraintName,

                           @collation = collation,

                           @IdentityColumn = IdentityColumn

                     FROM #TableScript

                     WHERE ColumnName = @ColumnName

 

                     IF @DefaultValue IS NOT NULL

                     BEGIN

                           IF @DFQuery = ''

                                  SET @DFQuery = @DFQuery

                                         + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'ALTER TABLE [dbo].[' + @TableName + @TableNameExt + '] WITH NOCHECK ADD'

             

                           SET @DFQuery = @DFQuery

                                  + CHAR(13) + CHAR(10) + CHAR(9) + 'CONSTRAINT [DF_' + @TableName + @TableNameExt + '_'

                                  + @ColumnName + @TableNameExt + '] DEFAULT ' + @DefaultValue

                                  + ' FOR [' + @ColumnName + '],'

                     END

 

                     IF @DataType = 'text' OR @DataType = 'ntext'

                           SET @TEXTIMAGE_ON = 1

 

                     SET @TSQL = @TSQL

                           + CHAR(13) + CHAR(10) + CHAR(9) + '[' + @ColumnName + '] [' + @DataType + ']'

             

                     IF @IdentityColumn = 1

                           SET @TSQL = @TSQL

                                  + ' IDENTITY (' + LTRIM(STR(IDENT_SEED(@TableName))) + ', ' + LTRIM(STR(IDENT_INCR(@TableName))) + ')'

 

                     IF @DataType = 'varchar' OR @DataType = 'nvarchar' OR @DataType = 'char' OR @DataType = 'nchar'

                        OR @DataType = 'varbinary' OR @DataType = 'binary'

                           SET @TSQL = @TSQL

                                  + ' (' + @Length + ')'

 

                     IF @DataType = 'numeric' OR @DataType = 'decimal'

                           SET @TSQL = @TSQL

                                  + ' (' + @Precision + ', ' + @Scale + ')'

             

                     IF @collation IS NOT NULL AND @DataType <> 'sysname' AND @DataType <> 'ProperName'

                           SET @TSQL = @TSQL

                                  + ' COLLATE ' + @collation

 

                     IF @Isnullable = '1'

                           SET @TSQL = @TSQL + ' NULL'

                     ELSE

                           SET @TSQL = @TSQL + ' NOT NULL'

             

                     FETCH NEXT FROM ColumnName INTO @ColumnName

               

                     IF @@fetch_status = 0

                           SET @TSQL = @TSQL + ', '

              END

 

              CLOSE ColumnName

              DEALLOCATE ColumnName

 

              SET @TSQL = @TSQL

                     + CHAR(13) + CHAR(10) + ')'

 

              --Assign file group name

              SELECT DISTINCT @GroupName = GroupName

              FROM #TableScript

 

              IF @GroupName IS NOT NULL

                     SET @TSQL = @TSQL

                           + ' ON [' + @GroupName + ']'

 

              IF @TEXTIMAGE_ON = 1

                     SET @TSQL = @TSQL

                           + ' TEXTIMAGE_ON [' + @GroupName + ']'

 

              IF RIGHT(@DFQuery,1) = ','

                     SET @DFQuery = LEFT(@DFQuery, LEN(@DFQuery) - 1)

 

              SET @TSQL = @TSQL

                     + CHAR(13) + CHAR(10) + 'GO'

 

              SELECT DISTINCT @IndexName = IndexName,

                           @IndID = indid

              FROM #IndexScript

              WHERE LEFT (IndexName, 2) = 'PK'

 

              IF @IndexName IS NOT NULL

              BEGIN

 

                     SET @TSQL = @TSQL

                           + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'ALTER TABLE [dbo].[' + @TableName + @TableNameExt + '] WITH NOCHECK ADD'

                           + CHAR(13) + CHAR(10) + 'CONSTRAINT [PK_' + @TableName + @TableNameExt + @PK + @TableNameExt + '] PRIMARY KEY  '

 

                     IF @IndID = 1

                           SET @TSQL = @TSQL

                                  + 'CLUSTERED'

                     ELSE

                           SET @TSQL = @TSQL

                                  + 'NONCLUSTERED'

 

 

                     SET @TSQL = @TSQL

                           + CHAR(13) + CHAR(10) + '('

 

                     DECLARE @OldColumnName varchar(255)

                    

                     SET @OldColumnName = 'none_yet'

                    

                     WHILE @IndKey <= 16

                     BEGIN

                           SELECT @ColumnName = ColumnName

                           FROM #IndexScript

                           WHERE IndexName = @IndexName AND IndID = @IndID AND IndKey = @IndKey

                    

                           IF @ColumnName IS NOT NULL AND @ColumnName <> @OldColumnName

                           BEGIN

                                  SET @TSQL = @TSQL

                                         + CHAR(13) + CHAR(10) + '[' + @ColumnName + '],'

                           END

                    

                           SET @OldColumnName = @ColumnName

                           SET @IndKey = @IndKey + 1

                     END

 

                     IF RIGHT(@TSQL,1) = ','

                           SET @TSQL = LEFT(@TSQL, LEN(@TSQL) - 1)

 

                     SET @TSQL = @TSQL

                           + CHAR(13) + CHAR(10) + ')'

 

                     --Add file group name

                     IF @GroupName is not null

                           SET @TSQL = @TSQL

                                  + ' ON [' + @GroupName + ']'

 

                     SET @TSQL = @TSQL

                           + CHAR(13) + CHAR(10) + 'GO'

              END

              --End creating primary key script.

 

              --Add default value constraint script to main script.

              SET @TSQL = @TSQL

                     + @DFQuery

                     + CHAR(13) + CHAR(10) + 'GO'

 

              --Begin building index script.

              SET @TSQL = @TSQL + CHAR(13) + CHAR(10)

 

              DECLARE IndexName Cursor For

              SELECT DISTINCT IndexName,

                           indid,

                           UniqueIndex

              FROM #IndexScript

              WHERE LEFT (IndexName, 2) <> 'PK' AND LEFT(IndexName, 4) <> 'hind'

 

              OPEN IndexName

                    

              FETCH NEXT FROM IndexName INTO @IndexName, @IndID, @UniqueIndex

 

              WHILE @@fetch_status = 0

              BEGIN

                     SET @IndexNameOrig = @IndexName

 

                     IF RIGHT(@IndexName,2) = 'PM' OR RIGHT(@IndexName,2) = 'AM'

                           SET @IndexName = LEFT(@IndexName, LEN(@IndexName) - 5)

 

                     IF LEFT(RIGHT(@IndexName,10),1) = '_'

                           SET @IndexName = LEFT(@IndexName, LEN(@IndexName) - 10)

                     ELSE

                           IF LEFT(RIGHT(@IndexName,11),1) = '_'

                                  SET @IndexName = LEFT(@IndexName, LEN(@IndexName) - 11)

                           ELSE

                                  IF LEFT(RIGHT(@IndexName,12),1) = '_'

                                         SET @IndexName = LEFT(@IndexName, LEN(@IndexName) - 12)

 

                     SET @TSQL = @TSQL

                           + CHAR(13) + CHAR(10) + 'CREATE '

 

                     IF @IndID = 1

                           SET @TSQL = @TSQL

                                  + 'CLUSTERED '

 

                     IF @UniqueIndex <> 0

                           SET @TSQL = @TSQL

                                  + 'UNIQUE '

 

                     SET @TSQL = @TSQL

                           + 'INDEX [' + @IndexName + @TableNameExt + '] ON [dbo].[' + @TableName + @TableNameExt + ']('

 

                     SET @IndKey = 1

                     SET @OldColumnName = 'none_yet'

 

                     WHILE @IndKey <= 16

                     BEGIN

                           SELECT @ColumnName = ColumnName

                           FROM #IndexScript

                           WHERE IndexName = @IndexNameOrig AND IndID = @IndID AND IndKey = @IndKey

                    

                           IF @ColumnName IS NOT NULL AND @ColumnName <> @OldColumnName

                           BEGIN

                                  SET @TSQL = @TSQL

                                         + '[' + @ColumnName + '],'

                           END

                    

                           SET @OldColumnName = @ColumnName

                           SET @IndKey = @IndKey + 1

                     END

 

                     IF RIGHT(@TSQL,1) = ','

                           SET @TSQL = LEFT(@TSQL, LEN(@TSQL) - 1)

 

                     SET @TSQL = @TSQL + ')'

 

                     --Add file group name

                     IF @GroupName is not null

                           SET @TSQL = @TSQL

                                  + ' ON [' + @GroupName + ']'

 

                     SET @TSQL = @TSQL

                           + CHAR(13) + CHAR(10) + 'GO' + CHAR(10)

 

                     FETCH NEXT FROM IndexName INTO @IndexName, @IndID, @UniqueIndex

              END

 

              CLOSE IndexName

              DEALLOCATE IndexName

 

              --End building index script.

 

              SET @TSQL = REPLACE(@TSQL,CHAR(10) + 'GO', CHAR(10) + '--GO')

              --PRINT @TSQL

              EXEC (@TSQL)

              PRINT 'Table Created...'

              PRINT DATEDIFF(ms,@Date,Getdate())

 

              -- 2 SWITCH THE OLD DATA OUT

              ------------------------------------------------------------------------------

              SET @TSQL     = 'ALTER TABLE ['+ @TableName + '] SWITCH PARTITION '+ CAST(@PartitionNumber AS VarChar(50)) + ' TO ['+ @TableName + '_STAGED_OLD]'

              --PRINT @TSQL

              EXEC (@TSQL)

              PRINT 'SWITCHED PARTITION OUT...'

              PRINT DATEDIFF(ms,@Date,Getdate())

 

              -- 2 ALTER PARTITION FUNCTION

              ------------------------------------------------------------------------------

              SELECT        @FunctionName = name

              FROM          sys.partition_functions

              WHERE         function_id = @Function_ID

 

              SET @TSQL     = 'ALTER PARTITION FUNCTION ' + @FunctionName + '() MERGE RANGE (''' + CONVERT(VarChar(1024),@Range,121) + ''')'

              --PRINT @TSQL

              EXEC (@TSQL)

              PRINT 'ALTERED PARTITION FUNCTION...'

              PRINT DATEDIFF(ms,@Date,Getdate())

 

              -- 3 DROP TABLE

              ------------------------------------------------------------------------------

              SET @TSQL = 'DROP TABLE [' + @TableName + @TableNameExt + ']'

              --PRINT @TSQL

              EXEC (@TSQL)

              PRINT 'DROPED STAGING TABLE...'

              PRINT DATEDIFF(ms,@Date,Getdate())

 

              -- 4 DROP FILES

              ------------------------------------------------------------------------------

              SET @TSQL = ''

              select @TSQL = @TSQL + 'ALTER DATABASE [' + DB_NAME() + '] REMOVE FILE [' + name +']' + CHAR(13) + CHAR(10)

              from sys.sysfiles

              where groupid in     (

                                                select groupid

                                                from sys.sysfilegroups

                                                where groupname = @FileGroupName

                                                or groupname = REPLACE(@FileGroupName,'_DATA','_INDEX')

                                                or groupname = REPLACE(@FileGroupName,'_INDEX','_DATA')

                                                )

              --PRINT @TSQL

              EXEC (@TSQL)

              PRINT 'DROPED FILES...'

              PRINT DATEDIFF(ms,@Date,Getdate())

 

              -- 5 DROP FILE GROUP

              ------------------------------------------------------------------------------

              SET @TSQL = ''

              select @TSQL = @TSQL + 'ALTER DATABASE [' + DB_NAME() + '] REMOVE FILEGROUP [' + groupname +']' + CHAR(13) + CHAR(10)

                                                from sys.sysfilegroups

                                                where groupname = @FileGroupName

                                                or groupname = REPLACE(@FileGroupName,'_DATA','_INDEX')

                                                or groupname = REPLACE(@FileGroupName,'_INDEX','_DATA')

              --PRINT @TSQL

              EXEC (@TSQL)

              PRINT 'DROPED FILES...'

              PRINT DATEDIFF(ms,@Date,Getdate())

       END

       DROP TABLE #IndexScript

       DROP TABLE #TableScript

       PRINT 'Finished...'

       PRINT DATEDIFF(ms,@Date,Getdate())

END

 

GO