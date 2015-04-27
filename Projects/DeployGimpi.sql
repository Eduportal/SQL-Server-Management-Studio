

USE [dbaperf]
GO

/****** Object:  Table [dbo].[dmv_MissingIndexSnapshot]    Script Date: 06/09/2010 11:38:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dmv_MissingIndexSnapshot]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dmv_MissingIndexSnapshot](
	[server_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](4000) NULL,
	[database_id] [smallint] NULL,
	[schema_id] [int] NULL,
	[schema_name] [nvarchar](4000) NULL,
	[object_id] [int] NULL,
	[table_name] [nvarchar](4000) NULL,
	[Improvement] [float] NULL,
	[CompleteQueryPlan] [xml] NULL,
	[Sproc_name] [nvarchar](128) NULL,
	[StatementID] [float] NULL,
	[StatementText] [varchar](4000) NULL,
	[StatementSubTreeCost] [varchar](128) NULL,
	[MissingIndex] [xml] NULL,
	[IndexImpact] [float] NULL,
	[usecounts] [int] NOT NULL,
	[IndexColumns] [nvarchar](4000) NULL,
	[IncludeColumns] [nvarchar](4000) NULL,
	[IndexName] [nvarchar](4000) NULL,
	[SnapShotDate] [datetime] NULL
) ON [PRIMARY]
END
GO


USE [dbaperf]
/****** Object:  Index [_dta_index_dmv_MissingIndexSnapshot_13_1634104862__K3_8_9_10_12_13_14_15_16_17_18]    Script Date: 06/09/2010 11:38:39 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[dmv_MissingIndexSnapshot]') AND name = N'_dta_index_dmv_MissingIndexSnapshot_13_1634104862__K3_8_9_10_12_13_14_15_16_17_18')
CREATE NONCLUSTERED INDEX [_dta_index_dmv_MissingIndexSnapshot_13_1634104862__K3_8_9_10_12_13_14_15_16_17_18] ON [dbo].[dmv_MissingIndexSnapshot] 
(
	[database_id] ASC
)
INCLUDE ( [Improvement],
[CompleteQueryPlan],
[Sproc_name],
[StatementText],
[StatementSubTreeCost],
[MissingIndex],
[IndexImpact],
[usecounts],
[IndexColumns],
[IncludeColumns]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__dmv_Missi__SnapS__104C4D90]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[dmv_MissingIndexSnapshot] ADD  CONSTRAINT [DF__dmv_Missi__SnapS__104C4D90]  DEFAULT (getdate()) FOR [SnapShotDate]
END

GO

USE [dbaperf]
GO

/****** Object:  Table [dbo].[dmv_IndexBaseLine]    Script Date: 06/09/2010 11:39:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dmv_IndexBaseLine]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dmv_IndexBaseLine](
	[row_id] [int] IDENTITY(1,1) NOT NULL,
	[server_name] [sysname] NOT NULL,
	[database_name] [sysname] NOT NULL,
	[database_id] [int] NULL,
	[index_action] [varchar](50) NULL,
	[schema_id] [int] NULL,
	[schema_name] [sysname] NOT NULL,
	[object_id] [int] NULL,
	[table_name] [sysname] NOT NULL,
	[index_id] [int] NULL,
	[index_name] [nvarchar](256) NULL,
	[is_unique] [bit] NULL,
	[has_unique] [bit] NULL,
	[type_desc] [nvarchar](255) NULL,
	[partition_number] [int] NULL,
	[reserved_page_count] [bigint] NULL,
	[page_count] [bigint] NULL,
	[max_key_size] [int] NULL,
	[size_in_mb] [decimal](12, 2) NULL,
	[buffered_page_count] [int] NULL,
	[buffer_mb] [decimal](12, 2) NULL,
	[pct_in_buffer] [decimal](12, 2) NULL,
	[table_buffer_mb] [decimal](12, 2) NULL,
	[row_count] [bigint] NULL,
	[impact] [bigint] NULL,
	[existing_ranking] [bigint] NULL,
	[user_total_read] [bigint] NULL,
	[user_total_read_pct] [decimal](6, 2) NULL,
	[estimated_user_total_read_pct] [decimal](6, 2) NULL,
	[user_total_write] [bigint] NULL,
	[user_total_write_pct] [decimal](6, 2) NULL,
	[estimated_user_total_write_pct] [decimal](6, 2) NULL,
	[index_read_pct] [decimal](6, 2) NULL,
	[index_write_pct] [decimal](6, 2) NULL,
	[user_seeks] [bigint] NULL,
	[user_scans] [bigint] NULL,
	[user_lookups] [bigint] NULL,
	[user_updates] [bigint] NULL,
	[row_lock_count] [bigint] NULL,
	[row_lock_wait_count] [bigint] NULL,
	[row_lock_wait_in_ms] [bigint] NULL,
	[row_block_pct] [decimal](6, 2) NULL,
	[avg_row_lock_waits_ms] [bigint] NULL,
	[page_lock_count] [bigint] NULL,
	[page_lock_wait_count] [bigint] NULL,
	[page_lock_wait_in_ms] [bigint] NULL,
	[page_block_pct] [decimal](6, 2) NULL,
	[avg_page_lock_waits_ms] [bigint] NULL,
	[splits] [bigint] NULL,
	[indexed_columns] [nvarchar](max) NULL,
	[indexed_column_count] [int] NULL,
	[included_columns] [nvarchar](max) NULL,
	[included_column_count] [int] NULL,
	[indexed_columns_compare] [nvarchar](max) NULL,
	[included_columns_compare] [nvarchar](max) NULL,
	[duplicate_indexes] [nvarchar](max) NULL,
	[overlapping_indexes] [nvarchar](max) NULL,
	[related_foreign_keys] [nvarchar](max) NULL,
	[related_foreign_keys_xml] [xml] NULL,
	[SnapShotDate] [datetime] NULL
) ON [PRIMARY]
END
GO


USE [dbaperf]
/****** Object:  Index [_dta_index_dmv_IndexBaseLine_13_55671246__K3_K23D_K8_K25D_K27D_K4_2_5_7_9_11_12_13_14_17_18_19_21_22_24_28_29_30_31_32_33_34_]    Script Date: 06/09/2010 11:39:08 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[dmv_IndexBaseLine]') AND name = N'_dta_index_dmv_IndexBaseLine_13_55671246__K3_K23D_K8_K25D_K27D_K4_2_5_7_9_11_12_13_14_17_18_19_21_22_24_28_29_30_31_32_33_34_')
CREATE NONCLUSTERED INDEX [_dta_index_dmv_IndexBaseLine_13_55671246__K3_K23D_K8_K25D_K27D_K4_2_5_7_9_11_12_13_14_17_18_19_21_22_24_28_29_30_31_32_33_34_] ON [dbo].[dmv_IndexBaseLine] 
(
	[database_name] ASC,
	[table_buffer_mb] DESC,
	[object_id] ASC,
	[impact] DESC,
	[user_total_read] DESC,
	[database_id] ASC
)
INCLUDE ( [server_name],
[index_action],
[schema_name],
[table_name],
[index_name],
[is_unique],
[has_unique],
[type_desc],
[page_count],
[max_key_size],
[size_in_mb],
[buffer_mb],
[pct_in_buffer],
[row_count],
[user_total_read_pct],
[estimated_user_total_read_pct],
[user_total_write],
[user_total_write_pct],
[estimated_user_total_write_pct],
[index_read_pct],
[index_write_pct],
[user_seeks],
[user_scans],
[user_lookups],
[user_updates],
[row_lock_count],
[row_lock_wait_count],
[row_lock_wait_in_ms],
[row_block_pct],
[avg_row_lock_waits_ms],
[page_lock_count],
[page_lock_wait_count],
[page_lock_wait_in_ms],
[page_block_pct],
[avg_page_lock_waits_ms],
[splits],
[indexed_columns],
[indexed_column_count],
[included_columns],
[included_column_count],
[duplicate_indexes],
[overlapping_indexes],
[related_foreign_keys],
[related_foreign_keys_xml]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Statistic [_dta_stat_55671246_8_4_3_23_25_27]    Script Date: 06/09/2010 11:39:08 ******/
if not exists (select * from sys.stats where name = N'_dta_stat_55671246_8_4_3_23_25_27' and object_id = object_id(N'[dbo].[dmv_IndexBaseLine]'))
CREATE STATISTICS [_dta_stat_55671246_8_4_3_23_25_27] ON [dbo].[dmv_IndexBaseLine]([object_id], [database_id], [database_name], [table_buffer_mb], [impact], [user_total_read])
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__dmv_Index__is_un__04459E07]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[dmv_IndexBaseLine] ADD  CONSTRAINT [DF__dmv_Index__is_un__04459E07]  DEFAULT ((0)) FOR [is_unique]
END

GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__dmv_Index__has_u__0539C240]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[dmv_IndexBaseLine] ADD  CONSTRAINT [DF__dmv_Index__has_u__0539C240]  DEFAULT ((0)) FOR [has_unique]
END

GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__dmv_Index__SnapS__114071C9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[dmv_IndexBaseLine] ADD  CONSTRAINT [DF__dmv_Index__SnapS__114071C9]  DEFAULT (getdate()) FOR [SnapShotDate]
END

GO

USE [dbaperf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_CalculateHeapSize]    Script Date: 06/09/2010 11:43:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_CalculateHeapSize]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE function [dbo].[fn_CalculateHeapSize]
(@database_id INT, @object_id INT)
Returns varchar(100)
AS
Begin
	-- Calculate the space used taken at leaf level 
	Declare @Num_Rows float
		,@Num_Cols int
		,@Fixed_data_size int
		,@Num_var_Cols int
		,@Max_var_size int
		,@Null_Bitmap int
		,@Variable_Data_Size int
		,@Heap_size bigint
		,@Row_Size int
		,@Rows_per_page float
		,@Num_Pages float
	
	select	@Num_Rows = [rows] 
	from	dbaperf.dbo.vw_AllDB_sysindexes 
	where	database_id = @database_id
	and	id=@object_id 
	and	indid=1 
	
	select	@Num_Cols = count(*) 
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @database_id
	AND	object_id=@object_id
	
	select	@Fixed_data_size = sum(max_lenGth) 
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @database_id 
	and	object_id=@object_id 
	and	system_type_id not in (165,167,231,34,35,99)
	
	select	@Num_var_Cols = count(*) 
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @Database_id
	and	object_id=@object_id
	and	system_type_id in (165,167,231,34,35,99)
	
	select	@Max_var_size = sum(max_lenGth) 
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @database_id
	AND	object_id=@object_id
	and	system_type_id in (165,167,231,34,35,99)
	
	set @Null_Bitmap= 2 + (@Num_Cols + 7)/8
	
	If( @Num_var_Cols = 0)
	BEGIN
		set @Variable_Data_Size = 0
	END
	ELSE
	begin
	set @Variable_Data_Size = 2 + (@Num_var_Cols * 2) + @Max_var_size
	END
	
	set @Row_Size = @Fixed_data_size + @Variable_Data_Size + @Null_Bitmap + 4 -- Row header info
	
	set @Rows_per_page= 8096/(@Row_Size + 2)
	
	-- No. of pages needed to store rows
	set @Num_Pages= ceiling(@Num_Rows/@Rows_per_page)
	
	set @Heap_size = (8192 * @Num_Pages)/1024
	-- Space used to store index info
	return Ltrim(str(@Heap_size))-- + '' KB''
	End
	
' 
END

GO
USE [dbaperf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_ClusteredIndexSize]    Script Date: 06/09/2010 11:43:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_ClusteredIndexSize]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE function [dbo].[fn_ClusteredIndexSize]
(@database_id INT, @object_id INT)
Returns BigInt
AS
Begin
	-- Calculate the space used taken at leaf level 
	Declare	@Num_Rows float
		,@Num_Cols int
		,@Fixed_data_size int
		,@Num_var_Cols int
		,@Max_var_size int
		,@fill_factor int
		,@uniquifier smallint
		,@uniquefiersize smallint
		,@Null_Bitmap int
		,@Variable_Data_Size int
		,@Total_Space varchar(100)
		,@Row_Size int
		,@Rows_per_page float
		,@Free_rows_per_page float
		,@level float 
		,@Num_Pages float
		,@Leaf_level_space int
	
	SELECT	@uniquifier=1
		,@uniquefiersize=4
		,@Num_Rows = [rows] 
	from	dbaperf.dbo.vw_AllDB_sysindexes 
	where	database_id = @database_id
	AND	id = @object_id
	AND	indid=1 
	
	select	@Num_Cols = count(*) 
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @database_id
	AND	object_id=@object_id 
	
	select	@Fixed_data_size = sum(max_lenGth) 
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @database_id
	AND	object_id = @object_id
	and	system_type_id not in (165,167,231,34,35,99)
	
	select	@Num_var_Cols = count(*) 
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @database_id
	AND	object_id = @object_id 
	and system_type_id in (165,167,231,34,35,99)
	
	select	@Max_var_size = sum(max_lenGth)
	from	dbaperf.dbo.vw_AllDB_columns 
	where	database_id = @database_id
	AND	object_id = @object_id 
	and system_type_id in (165,167,231,34,35,99)
	
	If ( (select is_unique from dbaperf.dbo.vw_AllDB_indexes where database_id = @database_id and object_id = @object_id and type=1) = 0 ) 
		Begin
			set @Num_Cols = @Num_Cols + @uniquifier
			set @Num_var_Cols = @Num_var_Cols + @uniquifier
			set @Max_var_size = @Max_var_size + @uniquefiersize
		End 
	set @Null_Bitmap= 2 + (@Num_Cols + 7)/8
	
	set @Variable_Data_Size = 2 + (@Num_var_Cols * 2) + @Max_var_size
	
	set @Row_Size = @Fixed_data_size + @Variable_Data_Size + @Null_Bitmap + 4 -- Row header info
	
	set @Rows_per_page= 8096/(@Row_Size + 2)
	
	select	@fill_factor = fill_factor 
	from	dbaperf.dbo.vw_AllDB_indexes 
	where	database_id = @database_id 
	AND	object_id = @object_id 
	and	type =1
	
	-- No. of reserved free rows per page
	set @Free_rows_per_page = 8096 * (((100 - @Fill_Factor) / 100) / (@Row_Size + 2))
	
	-- No. of pages needed to store rows
	set @Num_Pages= ceiling((@Num_Rows/(@Rows_per_page - @Free_rows_per_page)))
	
	set @Leaf_level_space = 8192 * @Num_Pages
	
	-- Space used to store index info
	Declare	@Num_Key_cols int
		,@Fixed_key_size int
		,@Num_var_key_cols int
		,@Max_var_key_size int
		,@Index_Null_Bitmap int
		,@Variable_Key_size int
		,@Index_row_size int
		,@Index_row_per_page float
		,@levels int
		,@Num_Index_pages int
		,@Index_level_space int
		,@Null_Cols int

	select	@Num_Key_cols = Keycnt 
	from	dbaperf.dbo.vw_AllDB_sysindexes 
	where	database_id = @database_id 
	AND	id = @object_id 
	and	indid=1
	
	select	@Fixed_key_size = sum(max_length) 
	from	dbaperf.dbo.vw_AllDB_index_columns a
	JOIN	dbaperf.dbo.vw_AllDB_indexes b
	ON	a.database_id = b.database_id
	AND	a.object_id = b.object_id
	AND	a.index_id=b.index_id
	JOIN	dbaperf.dbo.vw_AllDB_columns c
	ON	c.database_id = b.database_id
	AND	c.object_id = b.object_id
	AND	c.column_id = a.column_id
	where	b.database_id = @database_id
	and	b.object_id = @object_id
	and	type=1 
	and	system_type_id not in (165,167,231,34,35,99)
	
	select	@Num_var_key_cols = count(c.name) 
	from	dbaperf.dbo.vw_AllDB_index_columns a
	JOIN	dbaperf.dbo.vw_AllDB_indexes b
	ON	a.database_id = b.database_id
	AND	a.object_id = b.object_id
	AND	a.index_id=b.index_id
	JOIN	dbaperf.dbo.vw_AllDB_columns c
	ON	c.database_id = b.database_id
	AND	c.object_id = b.object_id
	AND	c.column_id = a.column_id
	where	b.database_id = @database_id
	and	b.object_id = @object_id
	and	type=1 
	and	system_type_id in (165,167,231,34,35,99)
	
	select	@Max_var_key_size = IsNull(sum(max_length),0) 
	from	dbaperf.dbo.vw_AllDB_index_columns a
	JOIN	dbaperf.dbo.vw_AllDB_indexes b
	ON	a.database_id = b.database_id
	AND	a.object_id = b.object_id
	AND	a.index_id=b.index_id
	JOIN	dbaperf.dbo.vw_AllDB_columns c
	ON	c.database_id = b.database_id
	AND	c.object_id = b.object_id
	AND	c.column_id = a.column_id
	where	b.database_id = @database_id
	and	b.object_id = @object_id
	and	type=1 
	and	system_type_id in (165,167,231,34,35,99)
	
	If ( (select is_unique from dbaperf.dbo.vw_AllDB_indexes where database_id = @database_id and object_id = @object_id and type=1) = 0 ) 
		Begin
			set @Num_Key_cols = @Num_Key_cols + @uniquifier
			set @Num_var_key_cols = @Num_var_key_cols + @uniquifier
			set @Max_var_key_size = @Max_var_key_size + @uniquefiersize
		End 
	
	select	@Null_Cols = IsNull(count(c.name),0) 
	from	dbaperf.dbo.vw_AllDB_index_columns a
	JOIN	dbaperf.dbo.vw_AllDB_indexes b
	ON	a.database_id = b.database_id
	AND	a.object_id = b.object_id
	AND	a.index_id=b.index_id
	JOIN	dbaperf.dbo.vw_AllDB_columns c
	ON	c.database_id = b.database_id
	AND	c.object_id = b.object_id
	AND	c.column_id = a.column_id
	where	b.database_id = @database_id
	and	b.object_id = @object_id 
	and	type=1 
	and	c.is_nullable=1
	
	select @Index_level_space = dbo.fn_getIndexSpace	(
								@Null_Cols
								,@Num_var_key_cols
								,@Max_var_key_size
								,@Fixed_key_size
								,@Num_Rows
								)
	set @Total_space = Ltrim(str((@Index_level_space+@Leaf_level_space)/(1024)))
	return @Total_space
End
' 
END

GO

USE [dbaperf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_getIndexSpace]    Script Date: 06/09/2010 11:43:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_getIndexSpace]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE Function [dbo].[fn_getIndexSpace]
( @Num_Null_key_cols int,@Num_var_key_cols int,@Max_var_key_size int,@Fixed_key_size int,@Num_Rows float )
returns Bigint 
AS
	BEGIN		
	Declare @Index_Null_Bitmap bigint,@Var_Key_Size bigint,@Index_row_Size bigint,@Index_Row_per_Page float
	Declare @level float,@Num_Index_pages bigint,@Index_Space_Used bigint
		If (@Num_Null_key_cols>0)
			Begin
			set @Index_Null_Bitmap = 2 + ((@Num_Null_key_cols+7)/8)
			End
			Else
			Begin
			set @Index_Null_Bitmap=0
			End
			
			IF (@Num_var_key_cols>0)
			BEGIN
			set @Var_Key_Size = 2 + (@Num_var_key_cols*2) + @Max_var_key_size
			END
			ELSE
			begin
				set @Var_Key_Size=0
			END	
	
			set @Index_row_Size=@Fixed_key_size + @Var_Key_Size + @Index_Null_Bitmap + 1+6
			set @Index_Row_per_Page = 8096/(@Index_row_Size +2)
			set @level = 1 + floor(abs((log10(@Num_Rows/@Index_row_per_page)/log10(@Index_row_per_page))))
			set @Num_Index_pages=0
				Declare @i int
					if (@level>0)
					Begin
						set @i=1
						while(@i<=@Level)
						Begin
						set @Num_Index_pages = @Num_Index_pages + power(@Index_row_per_page,@level - @i)
						set @i= @i + 1
						End	
					END
		
		set @Index_Space_Used = (8192 * @Num_Index_pages)
		Return @Index_Space_Used

End
' 
END

GO

USE [dbaperf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetLeafLevelIndexSpace]    Script Date: 06/09/2010 11:43:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetLeafLevelIndexSpace]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE Function [dbo].[fn_GetLeafLevelIndexSpace]
(@Num_Leaf_Cols int,@Num_Var_leaf_Cols int,@Max_var_leaf_size int,@Fixed_Leaf_Size int,@Fill_Factor int,@Num_Rows float)
Returns bigint
AS 
BEGIN

	Declare @Leaf_Null_Bitmap int,@Variable_leaf_size int,@Leaf_Row_Size int,@Leaf_Rows_per_page int
	Declare @Free_Rows_Per_Page int,@Num_Leaf_Pages float, @Leaf_Space_Used bigint
		
	set @Leaf_Null_Bitmap= 2 + ((@Num_Leaf_Cols + 7)/8)
	
	If (@Num_Var_leaf_Cols>0)
		Begin
			set @Variable_leaf_size = 2 + (@Num_Var_leaf_Cols * 2) + @Max_var_leaf_size
		END
		ELSE
		Begin 
			set @Variable_leaf_size = 0
		END


	set @Leaf_Row_Size = @Fixed_Leaf_Size + @Variable_leaf_size + @Leaf_Null_Bitmap + 1+ 6

	set @Leaf_Rows_per_page = 8096 / (@Leaf_Row_Size + 2)

	set @Free_Rows_Per_Page= 8096 * (((100 - @Fill_Factor) / 100) / (@Leaf_Row_Size + 2))
	
	set @Num_Leaf_Pages = ceiling((@Num_Rows/(@Leaf_Rows_per_page - @Free_Rows_Per_Page)))
	
	set @Leaf_Space_Used = 8192 * @Num_Leaf_Pages

	return @Leaf_Space_Used
END
' 
END

GO
USE [dbaperf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetNonClusteredIndexSize]    Script Date: 06/09/2010 11:44:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetNonClusteredIndexSize]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE function [dbo].[fn_GetNonClusteredIndexSize] 
(@database_id INT, @object_id INT)
Returns bigint
AS
Begin

Declare	@Num_Rows float
	,@Num_Key_cols int
	,@Fixed_key_size int
	,@Num_var_key_cols int
	,@Max_var_key_size int
	,@is_clustered int
	,@index_id int
	,@is_unique bit
	,@Num_Diff_cols int
	,@Num_Null_key_cols int
	,@Num_Index_pages int
	,@Index_Space_Used int
	,@Total_Index_space bigint
	,@Num_Leaf_Cols int
	,@Num_Included_Cols int
	,@Leaf_Level_Space int
	,@Fill_Factor int
-- CALCULATE THE SPACE USED TO SAVE INDEX INFORMATION AT NON-LEAF LEVEL
-- No of Rows in a table
	set @Total_Index_space=0
	set @Leaf_Level_Space=0	
	-- insert info intom temp table
	select	@Num_Rows = [rows] 
	from	dbaperf.dbo.vw_AllDB_sysindexes 
	where	database_id = @database_id
	and	id = @object_id
	and	indid=1 
	
	Declare @Tmp_Info Table 
		( 
		Index_id int
		,Num_key_cols int
		,type int
		,is_unique bit
		,is_included smallint
		,fill_factor int
		,Num_Var_Key_cols int
		,Fixed_Key_Size int
		,Max_Var_Key_Size int
		)

	Declare @tmp_Index_info Table
		(
		sno int identity(1,1)
		,index_id int
		,Num_key_cols int
		,type int
		,is_unique bit
		,Num_Var_Key_cols int
		,Fixed_Key_Size int
		,Max_Var_Key_Size int
		,Num_Included_Col int
		,fill_factor int
		)

	insert into	 @Tmp_Info
	
	select		b.Index_id
			,count(c.name) Num_key_cols
			,b.type
			,b.is_unique
			,is_included_column
			,fill_factor
			,IsNull((select count(c.name) from dbaperf.dbo.vw_AllDB_columns e where e.database_id = c.database_id AND e.object_id=c.object_id and a.column_id=e.column_id and c.system_type_id in (165,167,231,34,35,99)),0) As Num_Var_Key_cols
			,ISNULL((select sum(max_length) from dbaperf.dbo.vw_AllDB_indexes d where d.database_id=c.database_id and d.object_id=c.object_id and d.index_id=b.index_id and c.system_type_id not in (165,167,231,34,35,99)),0) As Fixed_Key_Size
			,ISNULL((select sum(max_length) from dbaperf.dbo.vw_AllDB_indexes d where d.database_id=c.database_id and d.object_id=c.object_id and d.index_id=b.index_id and c.system_type_id in (165,167,231,34,35,99)),0) As Max_Var_Key_Size
	--into @Tmp_Info
	from		dbaperf.dbo.vw_AllDB_index_columns a
	JOIN		dbaperf.dbo.vw_AllDB_columns c
	ON		a.database_id = c.database_id
	AND		a.object_id = c.object_id
	AND		a.column_id=c.column_id
	JOIN		dbaperf.dbo.vw_AllDB_indexes b
	ON		a.database_id = b.database_id
	AND		a.object_id = b.object_id
	AND		a.index_id=b.index_id
	
	where		b.database_id = @database_id
	and		b.object_id = @object_id
	--and b.type>1

	group by	c.name
			,b.index_id
			,c.database_id
			,c.object_id
			,c.system_type_id
			,a.column_id
			,b.type
			,b.is_unique
			,is_included_column
			,fill_factor
	order by	b.index_id

	
	insert into	@tmp_Index_info
	select		index_id As Index_id
			,sum(num_key_cols) as num_key_cols
			,type,is_unique
			,sum(Num_var_key_cols) as Num_var_key_cols
			,sum(Fixed_key_size) as Fixed_key_size
			,sum(max_var_key_size) as max_var_key_size
			,sum(is_included)
			,fill_factor
	--into @tmp_Index_info
	from		@Tmp_Info 
	where		type>1 
	group by	index_id
			,type
			,is_unique
			,fill_factor
		
	IF Exists(select 1 from @Tmp_Info where type=1)
	Begin 
		Set @is_clustered = 1
		
	END
	ELSE
	BEGIN
		Set @is_clustered = 0
		
	END

	Declare @row_Count int
	set @row_Count=(select count(*) from @tmp_Index_info where type>1)
	while (@row_Count>0)
	begin
			
		select	@index_id=index_id
			,@Num_Key_cols=num_key_cols
			,@Fixed_key_size=fixed_key_size
			,@Num_var_key_cols=Num_var_key_cols
			,@Max_var_key_size=Max_var_key_size
			,@is_unique=is_unique
			,@Num_Included_Cols=Num_Included_Col
			,@Fill_Factor=fill_factor
		from	@tmp_Index_info 
		where	sno=@row_Count

		If (@is_clustered=0)
			Begin	
				set @Num_Key_cols = @Num_Key_cols + 1
				set @Num_Leaf_Cols= @Num_Key_cols + @Num_Included_Cols + 1
			END
			ELSE
				BEGIN
				select	@Num_Diff_cols=count(column_id) 
				from	dbaperf.dbo.vw_AllDB_index_columns x
				join	dbaperf.dbo.vw_AllDB_indexes y
				ON	x.database_id = y.database_id
				AND	x.object_id=y.object_id
				AND	x.index_id=y.index_id
				where	x.database_id = @database_id
				and	x.object_id = @object_id
				AND	y.type=1
				AND	column_id not in 
				(
				 select	column_id 
				 from	dbaperf.dbo.vw_AllDB_index_columns a
				 join	dbaperf.dbo.vw_AllDB_indexes b 
				 ON	a.database_id = b.database_id
				 AND	a.object_id = b.object_id
				 AND	a.index_id = b.index_id
				 where	a.database_id = @database_id
				 and	a.object_id = @object_id 
				 and	a.index_id = @index_id
				 and	type>1 
				)
		
				set @Num_Key_cols = @Num_Key_cols + @Num_Diff_cols + @is_unique

				set @Num_Leaf_Cols = @Num_Key_cols + @Num_Included_Cols + @Num_Diff_cols + @is_unique
					
			END

			select	@Num_Null_key_cols=ISNULL(count(x.column_id),0) 
			from	dbaperf.dbo.vw_AllDB_index_columns x
			join	dbaperf.dbo.vw_AllDB_columns y 
			ON	x.database_id = y.database_id	
			AND	x.object_id = y.object_id
			AND	x.column_id=y.column_id
			where	x.database_id = @database_id
			and	x.object_id = @object_id
			and	x.index_id=@index_id 
			and	y.is_nullable=1
			
		declare @index_name varchar(100)
		
		select	@index_name = name 
		from	dbaperf.dbo.vw_AllDB_indexes 
		where	database_id = @database_id
		AND	object_id = @object_id
		and	index_id = @index_id
		
		select	@Index_Space_Used=dbo.fn_getIndexSpace	(
								@Num_Null_key_cols
								,@Num_var_key_cols
								,@Max_var_key_size
								,@Fixed_key_size
								,@Num_Rows
								)
								
		select	@Leaf_Level_Space=dbo.fn_GetLeafLevelIndexSpace	(
									@Num_Leaf_Cols
									,@Num_var_key_cols
									,@Max_var_key_size
									,@Fixed_key_size
									,@Fill_Factor
									,@Num_Rows
									)
		
		set	@Total_Index_space= @Total_Index_space + @Index_Space_Used + @Leaf_Level_Space
		
		set	@row_Count=@row_count-1	
END			
			
			return Ltrim(str((@Total_Index_space))/(1024))
END
' 
END

GO

USE [dbaperf]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetTableSize]    Script Date: 06/09/2010 11:44:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetTableSize]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
Create Function [dbo].[fn_GetTableSize]
(@database_id INT, @object_id INT)
returns varchar(25)
AS
Begin
Declare @TableSize varchar(25)
If Exists(select 1 from dbaperf.dbo.vw_AllDB_indexes where database_id = @database_id AND object_id = @object_id and type = 1)
	Begin
		select @TableSize	= dbo.fn_ClusteredIndexSize(@database_id,@object_id) 
					+ dbo.fn_GetNonClusteredIndexSize(@database_id,@object_id)
	END
	ELSE
	BEGIN	 
		select @TableSize	= dbo.fn_CalculateHeapSize(@database_id,@object_id) 
					+ dbo.fn_GetNonClusteredIndexSize(@database_id,@object_id)
	END
	set @TableSize = Ltrim(str(@TableSize)) + '' KB''
return @TableSize
END
' 
END

GO






USE [dbaperf]
GO

/****** Object:  StoredProcedure [dbo].[dbasp_GIMPI_CaptureAndExport]    Script Date: 06/09/2010 11:36:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_GIMPI_CaptureAndExport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC	[dbo].[dbasp_GIMPI_CaptureAndExport]
	(
	@UNCPath		VarChar(6000)	= NULL
	,@target_env		VarChar(50)	= ''amer''
	,@target_server		sysname		= ''SEAFRESQLDBA01''
	,@target_share		VarChar(2048)	= ''SEAFRESQLDBA01_dbasql\IndexAnalysis''
	,@retry_limit		INT		= 5
	,@Fill_Factor		int		= 98
	,@PopulateDMVsForAll	bit		= 1
	,@database_name		sysname		= NULL
	,@schema_name		sysname		= NULL
	,@table_name		sysname		= NULL
	)

/***************************************************************
 **  Stored Procedure dbasp_GIMPI_CaptureAndExport                 
 **  Written by Steve Ledridge, Getty Images                
 **  June 2010                                      
 **
 **  
 **  Description: Generates two DMV''s used for the GIMPI Reports and sends the data 
 **		  To SEAFRESQLDBA01 to be aggregated.
 **
 **
 **  This proc accepts the following input parameters:
 **  
 **  	@UNCPath		= Whether or not online reindexing is used.
 **  	@target_env		= Passed to [dbasp_File_Transit]. 
 **  	@target_server		= Passed to [dbasp_File_Transit].
 **  	@target_share		= Passed to [dbasp_File_Transit].
 **  	@retry_limit		= Value User for FILLFACTOR on REBUILDS when Read Percentage > 60%
 **  	@Fill_Factor		= Value User for FILLFACTOR on REBUILDS when Read Precentage < 30%			
 **  	@PopulateDMVsForAll	= Ignore any specific DB,SCHEMA,or TABLE VALUES (GET IT ALL)
 **	@database_name		= FILTER - Only repopulate with tables in the specific Database.
 **	@schema_name		= FILTER - Only repopulate with tables in the specific Schema. 
 **	@table_name		= FILTER - Only repopulate with tables with the specific Name.
 **
 ***************************************************************/
  as
set nocount on


--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	2010-00-00	Steve Ledridge		Created
--	2010-06-07	Steve Ledridge		Modified deletes to use truncates when they can.
--						Added missing delete for one of the DMV''s		
--	======================================================================================

/***
DECLARE	@UNCPath		VarChar(6000)	
	,@target_env		VarChar(50)	
	,@target_server		sysname		
	,@target_share		VarChar(2048)	
	,@retry_limit		INT		
	,@Fill_Factor		int		
	,@PopulateDMVsForAll	bit		
	,@database_name		sysname		
	,@schema_name		sysname		
	,@table_name		sysname		
	
SELECT	@UNCPath		= ''\\g1sqla\G1SQLA$A_dbasql\dba_reports''
	,@target_env		= ''amer''
	,@target_server		= ''SEAFRESQLDBA01''
	,@target_share		= ''SEAFRESQLDBA01_dbasql\IndexAnalysis''
	,@retry_limit		= 5
	,@Fill_Factor		= 98
	,@PopulateDMVsForAll	= 1
	,@database_name		= NULL
	,@schema_name		= NULL
	,@table_name		= NULL
--***/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE		@TSQL1			VarChar(max)
		,@TSQL2			VarChar(max)
		,@TSQL3			VarChar(max)
		,@Object		sysname
		,@object_id		int
		,@database_id		int
		,@IndexScript		nvarchar(max)
		,@RC			int
		,@Script		VarChar(6000)
		,@Export_Source		sysname
		,@LocalPath		VarChar(6000)
		,@FileName		VarChar(6000)
		

SELECT		@UNCPath		= COALESCE(@UNCPath,''\\'' + LEFT(@@SERVERNAME,(CHARINDEX(''\'',@@SERVERNAME+''\'')-1)) + ''\'' + REPLACE(@@SERVERNAME,''\'',''$'') + ''_dbasql\dba_reports'')
		,@object_id		= OBJECT_ID(@database_name+''.''+@schema_name+''.''+@table_name)
		,@database_id		= db_id(@database_name)
		,@IndexScript		= ''''
		,@LocalPath		= @UNCPath
		
If @PopulateDMVsForAll = 0 AND @database_name IS NULL
BEGIN
	PRINT ''A DATABASE NAME MUST BE SPECIFIED IF @PopulateDMVsForAll=0''
	RETURN -1
END		


IF OBJECT_ID(''tempdb..#ForeignKeys'') IS NOT NULL
    DROP TABLE #ForeignKeys

CREATE TABLE #ForeignKeys
    (
    database_id int
    ,foreign_key_name sysname
    ,object_id int
    ,fk_columns nvarchar(max)
    ,fk_columns_compare nvarchar(max)
    );
    
if @@SERVERNAME IN (''SEADCASPSQLA\A'')
 GOTO SkipCreateViews
    
DECLARE CreateAllDBViews CURSOR
FOR
SELECT ''sys'',''tables''
UNION ALL
SELECT ''sys'',''schemas''
UNION ALL
SELECT ''sys'',''sysindexes''
UNION ALL
SELECT ''sys'',''indexes''
UNION ALL
SELECT ''sys'',''dm_db_partition_stats''
UNION ALL
SELECT ''sys'',''allocation_units''
UNION ALL
SELECT ''sys'',''partitions''
UNION ALL
SELECT ''sys'',''columns''
UNION ALL
SELECT ''sys'',''index_columns''
UNION ALL
SELECT ''sys'',''foreign_keys''
UNION ALL
SELECT ''sys'',''foreign_key_columns''


OPEN CreateAllDBViews
FETCH NEXT FROM CreateAllDBViews INTO @TSQL2,@TSQL3
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET	@TSQL1	= ''IF OBJECT_ID(''''[dbo].[vw_AllDB_''+@TSQL3+'']'''') IS NOT NULL'' +CHAR(13)+CHAR(10)
		+ ''DROP VIEW [dbo].[vw_AllDB_''+@TSQL3+'']'' +CHAR(13)+CHAR(10)
		SET	@TSQL1	= ''USE [dbaperf];''+CHAR(13)+CHAR(10)+''EXEC ('''''' + REPLACE(@TSQL1,'''''''','''''''''''') + '''''')''
		EXEC	(@TSQL1)

		SET	@TSQL1	= ''CREATE VIEW [dbo].[vw_AllDB_''+@TSQL3+''] AS'' +CHAR(13)+CHAR(10)+''SELECT	''''master'''' AS database_name, DB_ID(''''master'''') AS database_id, * From [master].[''+@TSQL2+''].[''+@TSQL3+'']''+CHAR(13)+CHAR(10)
		SELECT	@TSQL1 = @TSQL1 +
		''UNION ALL''+CHAR(13)+CHAR(10)+''SELECT	''''''+name+'''''', DB_ID(''''''+name+''''''), * From [''+name+''].[''+@TSQL2+''].[''+@TSQL3+'']''+CHAR(13)+CHAR(10)
		FROM	master.sys.databases
		WHERE	name != ''master''
		SET	@TSQL1	= ''USE [dbaperf];''+CHAR(13)+CHAR(10)+''EXEC ('''''' + REPLACE(@TSQL1,'''''''','''''''''''') + '''''')''
		EXEC	(@TSQL1)
	END
	FETCH NEXT FROM CreateAllDBViews INTO @TSQL2,@TSQL3
END

CLOSE CreateAllDBViews
DEALLOCATE CreateAllDBViews    

SkipCreateViews:
    

BEGIN -- POPULATE DMVs or TEMP TABLES

	-------------------------------------------------------
	-------------------------------------------------------
	-- POPULATE dmv_MissingIndexSnapshot
	-------------------------------------------------------
	-------------------------------------------------------

SELECT		@database_name		= QUOTENAME(@database_name)
		,@schema_name		= QUOTENAME(@schema_name)
		,@table_name		= QUOTENAME(@table_name)
		

if @PopulateDMVsForAll = 1
	TRUNCATE TABLE [dbo].[dmv_MissingIndexSnapshot]
ELSE		
DELETE		dmv_MissingIndexSnapshot		
WHERE		(
		QUOTENAME(database_name) = @database_name
		OR @database_name IS NULL
		OR @PopulateDMVsForAll = 1
		)
	AND	(
		QUOTENAME(table_name) = @table_name
		OR @table_name IS NULL
		OR @PopulateDMVsForAll = 1
		)		
				

	;WITH	XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan'')
		, PlanData AS
		( 
		SELECT		ecp.plan_handle
				, MissingIndex.value (''(.//MissingIndex/@Database)[1]'',''sysname'')	AS database_name
				, MissingIndex.value (''(.//MissingIndex/@Schema)[1]'',''sysname'')		AS schema_name
				, MissingIndex.value (''(.//MissingIndex/@Table)[1]'',''sysname'')		AS table_name
				, MissingIndex.query (''.'')						AS Statements 
				, MissingIndex.value (''(./@StatementId)[1]'', ''int'')			AS StatementID 
				, MissingIndex.value (''(./@StatementText)[1]'', ''varchar(max)'')		AS StatementText 
				, MissingIndex.value (''(./@StatementSubTreeCost)[1]'', ''float'')		AS StatementSubTreeCost
				, MissingIndex.value (''(.//MissingIndexGroup/@Impact)[1]'',''float'')	AS Impact
				, usecounts								AS UseCounts
				, eqp.[dbid]
				, eqp.[objectid]
				, ecp.objtype

		FROM		sys.dm_exec_cached_plans		AS ecp
		CROSS APPLY	sys.dm_exec_query_plan(ecp.plan_handle)	AS eqp
		CROSS APPLY	query_plan.nodes
				 (''for $stmt in .//Statements/*
				where	count($stmt/Condition/QueryPlan/MissingIndexes) > 0
				or	count($stmt/QueryPlan/MissingIndexes) > 0
				return $stmt'')				AS qp(MissingIndex)
		WHERE		(
				MissingIndex.exist 
				 (''.//MissingIndex[@Database = sql:variable("@database_name")]'') = 1
				OR @database_name IS NULL
				OR @PopulateDMVsForAll = 1
				)
			AND	(
				MissingIndex.exist 
				 (''.//MissingIndex[@Table = sql:variable("@table_name")]'') = 1
				OR @table_name IS NULL
				OR @PopulateDMVsForAll = 1
				)
		)
		, FormatedData AS
		(	
		SELECT		@@ServerName				AS server_name
				, REPLACE(REPLACE(
				  [database_name]
				  ,''['',''''),'']'','''')			AS database_name
				, DB_ID(REPLACE(REPLACE(
				  [database_name]
				  ,''['',''''),'']'',''''))			AS database_id
				, SCHEMA_ID(REPLACE(REPLACE(
				  [schema_name]
				  ,''['',''''),'']'',''''))			AS schema_id
				, REPLACE(REPLACE(
				  [schema_name]
				  ,''['',''''),'']'','''')			AS schema_name
				, OBJECT_ID(
				  [database_name]
				  +''.''+[schema_name]
				  +''.''+[table_name]
				  )					AS object_id
				, REPLACE(REPLACE(
				  [table_name]
				   ,''['',''''),'']'','''')			AS table_name
				, [StatementSubTreeCost]
				  * ISNULL([Impact], 0) 
				  * usecounts				AS Improvement 
				, [Statements]				AS CompleteQueryPlan 
				, OBJECT_NAME([objectid],[dbid])	AS Sproc_name
				, [StatementId]				AS StatementID 
				, [StatementText]			AS StatementText 
				, [StatementSubTreeCost]		AS StatementSubTreeCost
				, NULL					AS MissingIndex 
				, [Impact]				AS IndexImpact 
				, [usecounts]				AS UseCounts
				
				, REPLACE(CAST(Mi.query
				   (''data( for $cg in .//ColumnGroup
					where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
					return $cg/Column/@Name	)'')
					AS NVarchar(4000)),''] ['',''], ['')				AS IndexColumns
					
				, REPLACE(CAST(Mi.query
				   (''data( for $cg in .//ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@Name	)'')
					AS NVarchar(4000)),''] ['',''], ['')				AS IncludeColumns
					
				,REPLACE(REPLACE(REPLACE(CAST(Mi.query
				    (''data( for $cg in .//ColumnGroup
					where $cg/@Usage="EQUALITY" or $cg/@Usage="INEQUALITY"
					return $cg/Column/@ColumnId )'')
					AS NVarchar(4000)),''['',''''),'']'',''''),'' '',''_'')			AS IndexColumnIDs
				,REPLACE(REPLACE(REPLACE(CAST(Mi.query
				   (''data( for $cg in .//ColumnGroup
					where $cg/@Usage="INCLUDE"
					return $cg/Column/@ColumnId )'')
					AS NVarchar(4000)),''['',''''),'']'',''''),'' '',''_'')			AS IncludeColumnIDs
				
		From		PlanData				AS pd
		CROSS APPLY	Statements.nodes
				 (''.//MissingIndex'')			AS St(Mi)
		)
				
	INSERT INTO	dmv_MissingIndexSnapshot		
	SELECT		server_name
			, database_name
			, database_id
			, schema_id
			, schema_name
			, object_id
			, table_name
			, Improvement 
			, CompleteQueryPlan 
			, Sproc_name
			, StatementID 
			, StatementText 
			, StatementSubTreeCost
			, MissingIndex 
			, IndexImpact 
			, UseCounts
			, IndexColumns
			, '', '' + [IncludeColumns]		AS IncludeColumns
			, ''IX_'' 
			+ REPLACE(REPLACE(
			  [table_name]
			   ,''['',''''),'']'','''')
			+ ''_''
			+ [IndexColumnIDs]
			+ CASE
			  WHEN [IncludeColumnIDs] = ''''
			  THEN ''''
			  ELSE ''_INC_'' + [IncludeColumnIDs]
			  END					AS IndexName
			,getdate()				
		
			
			
	FROM		FormatedData
				
	ORDER BY	Improvement DESC

	-------------------------------------------------------
	-------------------------------------------------------
	-- POPULATE dmv_IndexBaseLine
	-------------------------------------------------------
	-------------------------------------------------------
	
	SELECT		@database_name		= REPLACE(REPLACE(
						  @database_name
						  ,''['',''''),'']'','''')
			,@schema_name		= REPLACE(REPLACE(
						  @schema_name
						  ,''['',''''),'']'','''')
			,@table_name		= REPLACE(REPLACE(
						  @table_name
						  ,''['',''''),'']'','''')


if @PopulateDMVsForAll = 1
	TRUNCATE TABLE [dbo].[dmv_IndexBaseLine]
ELSE
DELETE		dmv_IndexBaseLine		
WHERE		(
		database_name = @database_name
		OR @database_name IS NULL
		OR @PopulateDMVsForAll = 1
		)
	AND	(
		table_name = @table_name
		OR @table_name IS NULL
		OR @PopulateDMVsForAll = 1
		)		
			

	

	;WITH	AllocationUnits
		AS	(
			SELECT	p.database_id
				,p.object_id
				,p.index_id
				,p.partition_number 
				,au.allocation_unit_id
			FROM	dbaperf.dbo.vw_AllDB_allocation_units AS au
			JOIN	dbaperf.dbo.vw_AllDB_partitions AS p 
			 ON	au.container_id = p.hobt_id 
			 AND	au.database_id = p.database_id
			 AND	(au.type = 1 OR au.type = 3)
			 WHERE	(p.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
			  AND	(p.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
			UNION ALL
			SELECT	p.database_id
				,p.object_id
				,p.index_id
				,p.partition_number 
				,au.allocation_unit_id
			FROM	dbaperf.dbo.vw_AllDB_allocation_units AS au
			JOIN	dbaperf.dbo.vw_AllDB_partitions AS p 
			 ON	au.container_id = p.partition_id
			 AND	au.database_id = p.database_id 
			 AND	au.type = 2
			 WHERE	(p.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
			  AND	(p.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
			)
		,MemoryBuffer
		AS	(
			SELECT	au.database_id
				,au.object_id
				,au.index_id
				,au.partition_number
				,COUNT(*)AS buffered_page_count
				,CONVERT(decimal(12,2), CAST(COUNT(*) as bigint)*CAST(8 as float)/1024) as buffer_mb
			FROM	sys.dm_os_buffer_descriptors AS bd 
			JOIN	AllocationUnits au 
			ON bd.allocation_unit_id = au.allocation_unit_id
			AND bd.database_id = au.database_id
			 WHERE	(au.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
			  AND	(au.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
			GROUP BY au.database_id, au.object_id, au.index_id, au.partition_number
			)
	INSERT INTO dmv_IndexBaseLine
	    (server_name, database_name, database_id, schema_id, schema_name, object_id, table_name, index_id, index_name, is_unique, type_desc, partition_number, reserved_page_count, size_in_mb, buffered_page_count, buffer_mb, pct_in_buffer, row_count, page_count, existing_ranking
	    , user_total_read, user_total_read_pct
	    , user_total_write, user_total_write_pct
	    , user_seeks, user_scans, user_lookups,user_updates
	    , row_lock_count, row_lock_wait_count, row_lock_wait_in_ms, row_block_pct, avg_row_lock_waits_ms
	    , page_lock_count, page_lock_wait_count, page_lock_wait_in_ms, page_block_pct, avg_page_lock_waits_ms
	    , splits, indexed_columns, included_columns, indexed_columns_compare, included_columns_compare)
	SELECT	@@SERVERNAME
		,DB_Name(t.database_id)
		,t.database_id 
		,s.schema_id
		,s.name as schema_name
		,t.object_id
		,t.name as table_name
		,i.index_id
		,COALESCE(i.name, ''N/A'') as index_name
		,i.is_unique
		,CASE WHEN i.is_unique = 1 THEN ''UNIQUE '' ELSE '''' END + i.type_desc as type_desc
		,ps.partition_number
		,ps.reserved_page_count 
		,CAST(reserved_page_count * CAST(8 as float) / 1024 as decimal(12,2)) as size_in_mb
		,mb.buffered_page_count
		,mb.buffer_mb
		,CAST(100*buffer_mb/NULLIF(CAST(reserved_page_count * CAST(8 as float) / 1024 as decimal(12,2)),0) AS decimal(12,2)) as pct_in_buffer
		,row_count
		,used_page_count
		,ROW_NUMBER()
			OVER (PARTITION BY i.object_id ORDER BY i.is_primary_key desc, ius.user_seeks + ius.user_scans + ius.user_lookups desc) as existing_ranking

		,ius.user_seeks + ius.user_scans + ius.user_lookups as user_total_read
		,COALESCE(CAST(100 * (ius.user_seeks + ius.user_scans + ius.user_lookups)
			/(NULLIF(SUM(ius.user_seeks + ius.user_scans + ius.user_lookups) 
			OVER(PARTITION BY i.object_id), 0) * 1.) as decimal(6,2)),0) as user_total_read_pct

		,ius.user_updates as user_total_write
		,COALESCE(CAST(100 * (ius.user_updates)
			/(NULLIF(SUM(ius.user_updates) 
			OVER(PARTITION BY i.object_id), 0) * 1.) as decimal(6,2)),0) as user_total_write_pct
			
		,ius.user_seeks
		,ius.user_scans
		,ius.user_lookups
		,ius.user_updates

		,ios.row_lock_count 
		,ios.row_lock_wait_count 
		,ios.row_lock_wait_in_ms 
		,CAST(100.0 * ios.row_lock_wait_count/NULLIF(ios.row_lock_count, 0) AS decimal(12,2)) AS row_block_pct 
		,CAST(1. * ios.row_lock_wait_in_ms /NULLIF(ios.row_lock_wait_count, 0) AS decimal(12,2)) AS avg_row_lock_waits_ms 

		,ios.page_lock_count 
		,ios.page_lock_wait_count 
		,ios.page_lock_wait_in_ms 
		,CAST(100.0 * ios.page_lock_wait_count/NULLIF(ios.page_lock_count, 0) AS decimal(12,2)) AS page_block_pct 
		,CAST(1. * ios.page_lock_wait_in_ms /NULLIF(ios.page_lock_wait_count, 0) AS decimal(12,2)) AS avg_page_lock_waits_ms 

		,ios.leaf_allocation_count + ios.nonleaf_allocation_count AS [Splits]

		,STUFF((SELECT	'', '' + QUOTENAME(c.name)
			FROM	dbaperf.dbo.vw_AllDB_index_columns ic
			JOIN	dbaperf.dbo.vw_AllDB_columns c 
			ON	ic.database_id		= c.database_id 
			AND	ic.object_id		= c.object_id 
			AND	ic.column_id		= c.column_id
		    WHERE	is_included_column	= 0
		     AND	i.database_id		= ic.database_id 
		     AND	i.object_id		= ic.object_id
		     AND	i.index_id		= ic.index_id
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('''')), 1, 2, '''') AS indexed_columns
	    ,STUFF((SELECT '', '' + QUOTENAME(c.name)
		    FROM dbaperf.dbo.vw_AllDB_index_columns ic
		    JOIN dbaperf.dbo.vw_AllDB_columns c 
			ON ic.database_id = c.database_id 
			AND ic.object_id = c.object_id 
			AND ic.column_id = c.column_id
		    WHERE i.database_id = ic.database_id 
		    AND i.object_id = ic.object_id
		    AND i.index_id = ic.index_id
		    
		    AND is_included_column = 1
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('''')), 1, 2, '''') AS included_columns
	    ,(SELECT QUOTENAME(ic.column_id,''('')
		    FROM dbaperf.dbo.vw_AllDB_index_columns ic
		    WHERE i.database_id = ic.database_id 
		    AND i.object_id = ic.object_id
		    AND i.index_id = ic.index_id
		    AND is_included_column = 0
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('''')) AS indexed_columns_compare
	    ,COALESCE((SELECT QUOTENAME(ic.column_id, ''('')
		    FROM dbaperf.dbo.vw_AllDB_index_columns ic
		    WHERE i.database_id = ic.database_id 
		    AND i.object_id = ic.object_id
		    AND i.index_id = ic.index_id
		    AND is_included_column = 1
		    ORDER BY key_ordinal ASC
		    FOR XML PATH('''')), SPACE(0)) AS included_columns_compare
	FROM		dbaperf.dbo.vw_AllDB_tables t
	JOIN		dbaperf.dbo.vw_AllDB_schemas s 
	    ON		t.database_id		= s.database_id
	    AND		t.schema_id		= s.schema_id
	    
	JOIN		dbaperf.dbo.vw_AllDB_indexes i 
	    ON		t.database_id		= i.database_id
	    AND		t.object_id		= i.object_id
	    
	JOIN		dbaperf.dbo.vw_AllDB_dm_db_partition_stats ps 
	    ON		i.database_id		= ps.database_id
	    AND		i.object_id		= ps.object_id 
	    AND		i.index_id		= ps.index_id
	    
	LEFT JOIN	sys.dm_db_index_usage_stats ius 
	    ON		i.database_id		= ius.database_id
	    AND		i.object_id		= ius.object_id 
	    AND		i.index_id		= ius.index_id 
	    
	LEFT JOIN	sys.dm_db_index_operational_stats(@database_id, @object_id, NULL, NULL) ios 
	    ON		ps.database_id		= ios.database_id
	    AND		ps.object_id		= ios.object_id 
	    AND		ps.index_id		= ios.index_id 
	    AND		ps.partition_number	= ios.partition_number
	    
	LEFT JOIN	MemoryBuffer mb 
	    ON		ps.database_id		= mb.database_id
	    AND		ps.object_id		= mb.object_id 
	    AND		ps.index_id		= mb.index_id 
	    AND		ps.partition_number	= mb.partition_number
	    
	WHERE		(t.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
	    AND		(t.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)


	INSERT INTO dmv_IndexBaseLine
	    (server_name, database_name, database_id, schema_id, schema_name, object_id, table_name, index_name
	    , type_desc, impact, existing_ranking, user_total_read, user_seeks, user_scans, user_lookups, indexed_columns
	    , indexed_column_count, included_columns, included_column_count)
	SELECT		@@Servername
			,db_name(mid.database_id)
			,mid.database_id
			,s.schema_id
			,s.name AS schema_name
			,t.object_id
			,t.name AS table_name
			,''IX_''+t.name
			+COALESCE((SELECT	''_''+CAST(column_id AS VarChar)
				FROM	dbaadmin.dbo.dbaudf_split(equality_columns,'','') T1
				JOIN	dbaperf.dbo.vw_AllDB_columns T2
				ON	LTRIM(RTRIM(REPLACE(REPLACE(T1.SplitValue,''['',''''),'']'',''''))) = T2.name
				AND	T2.database_id		= t.database_id
				AND	T2.object_id		= t.object_id
				order by OccurenceId
				FOR XML PATH('''')),'''')
			+COALESCE((SELECT	''_''+CAST(column_id AS VarChar)
				FROM	dbaadmin.dbo.dbaudf_split(inequality_columns,'','') T1
				JOIN	dbaperf.dbo.vw_AllDB_columns T2
				ON	LTRIM(RTRIM(REPLACE(REPLACE(T1.SplitValue,''['',''''),'']'',''''))) = T2.name
				AND	T2.database_id		= t.database_id
				AND	T2.object_id		= t.object_id
				order by OccurenceId
				FOR XML PATH('''')),'''')	
			+CASE WHEN included_columns IS NULL THEN '''' ELSE ''_INC'' END
			+COALESCE((SELECT	''_''+CAST(column_id AS VarChar)
				FROM	dbaadmin.dbo.dbaudf_split(included_columns,'','') T1
				JOIN	dbaperf.dbo.vw_AllDB_columns T2
				ON	LTRIM(RTRIM(REPLACE(REPLACE(T1.SplitValue,''['',''''),'']'',''''))) = T2.name
				AND	T2.database_id		= t.database_id
				AND	T2.object_id		= t.object_id
				order by OccurenceId
				FOR XML PATH('''')),'''')
			,''--NONCLUSTERED--'' AS type_desc
			,(migs.user_seeks + migs.user_scans) * migs.avg_user_impact as impact
			,0 AS existing_ranking
			,migs.user_seeks + migs.user_scans as user_total_read
			,migs.user_seeks 
			,migs.user_scans
			,0 as user_lookups
			,COALESCE(equality_columns,'''')
			+COALESCE(CASE WHEN equality_columns IS NULL THEN '''' ELSE '', '' END + inequality_columns,'''') as indexed_columns
			,(LEN(COALESCE(equality_columns + '', '', SPACE(0)) + COALESCE(inequality_columns, SPACE(0))) - LEN(REPLACE(COALESCE(equality_columns + '', '', SPACE(0)) + COALESCE(inequality_columns, SPACE(0)),''['',''''))) indexed_column_count
			,'', ''+ included_columns 
			,(LEN(included_columns) - LEN(REPLACE(included_columns,''['',''''))) included_column_count
			
	FROM		dbaperf.dbo.vw_AllDB_tables t
	JOIN		dbaperf.dbo.vw_AllDB_schemas s 
		ON	t.database_id		= s.database_id
		AND	t.schema_id		= s.schema_id
		
	JOIN		sys.dm_db_missing_index_details mid 
		ON	t.database_id		= mid.database_id
		AND	t.object_id		= mid.object_id
		
	JOIN		sys.dm_db_missing_index_groups mig 
		ON	mid.index_handle	= mig.index_handle
		
	JOIN		sys.dm_db_missing_index_group_stats migs 
		ON	mig.index_group_handle	= migs.group_handle
	   
	WHERE		(t.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
		AND	(t.object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)

	UPDATE		T1
		SET	size_in_mb = 
					[dbaperf].[dbo].[fn_GetLeafLevelIndexSpace] 
					(
					T1.indexed_column_count
					,0
					,0
					,T3.TotalIndexKeySize
					,98
					,T2.row_count)/1000.00/1000.00
					+
					[dbaperf].[dbo].[fn_getIndexSpace] (
					T1.indexed_column_count
					,0
					,0
					,T3.TotalIndexKeySize
					,T2.row_count)/1000.00/1000.00
			,max_key_size = T3.TotalIndexKeySize
	FROM		dmv_IndexBaseLine T1
	JOIN		dmv_IndexBaseLine T2
		ON	T1.database_id		= T2.database_id
		AND	T1.object_id		= T2.Object_id
		AND	T2.type_desc		IN (''CLUSTERED'', ''HEAP'', ''UNIQUE CLUSTERED'')
	JOIN		(
			Select		T1.row_id
					,SUM(T3.max_length)AS TotalIndexKeySize
			FROM		dmv_IndexBaseLine				T1
			CROSS APPLY	dbaadmin.dbo.dbaudf_split(indexed_columns,'','')	T2
			JOIN		dbaperf.dbo.vw_AllDB_columns			T3
				ON	T1.database_id			= T3.database_id
				AND	T1.object_id			= T3.object_id
				AND	ltrim(rtrim(T2.SplitValue))	= QUOTENAME(T3.name)
			WHERE type_desc = ''--NONCLUSTERED--''
			GROUP BY	T1.row_id
			) T3
		ON	T1.row_id = T3.row_id
	where	T2.row_count > 0



	INSERT INTO #ForeignKeys
	    (database_id, foreign_key_name, object_id, fk_columns, fk_columns_compare)
	SELECT fk.database_id, fk.name + ''|PARENT'' AS foreign_key_name
	    ,fkc.parent_object_id AS object_id
	    ,STUFF((SELECT '', '' + QUOTENAME(c.name)
		FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
		JOIN	dbaperf.dbo.vw_AllDB_columns c
		ON	ifkc.database_id	= c.database_id  
		AND	ifkc.parent_object_id	= c.object_id 
		AND	ifkc.parent_column_id	= c.column_id
		WHERE	fk.database_id		= ifkc.database_id
		AND	fk.object_id		= ifkc.constraint_object_id
		ORDER BY ifkc.constraint_column_id
		FOR XML PATH('''')), 1, 2, '''') AS fk_columns
	    ,(	SELECT	QUOTENAME(ifkc.parent_column_id,''('')
		FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
		WHERE	fk.database_id	= ifkc.database_id
		AND	fk.object_id	= ifkc.constraint_object_id
		ORDER BY ifkc.constraint_column_id
		FOR XML PATH('''')) AS fk_columns_compare
	FROM	dbaperf.dbo.vw_AllDB_foreign_keys fk
	JOIN	dbaperf.dbo.vw_AllDB_foreign_key_columns fkc 
	ON	fk.database_id			= fkc.database_id
	AND	fk.object_id			= fkc.constraint_object_id
	WHERE	fkc.constraint_column_id	= 1
	AND	(fkc.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
	AND	(fkc.parent_object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)
	
	UNION ALL
	SELECT fk.database_id, fk.name + ''|REFERENCED'' as foreign_key_name
	    ,fkc.referenced_object_id AS object_id
	    ,STUFF((	SELECT	'', '' + QUOTENAME(c.name)
			FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
			JOIN	dbaperf.dbo.vw_AllDB_columns c 
			ON	ifkc.database_id		= c.database_id 
			AND	ifkc.referenced_object_id	= c.object_id 
			AND	ifkc.referenced_column_id	= c.column_id
			WHERE	fk.database_id			= ifkc.database_id
			AND	fk.object_id			= ifkc.constraint_object_id
			ORDER BY ifkc.constraint_column_id
			FOR XML PATH('''')), 1, 2, '''') AS fk_columns
	    ,(	SELECT	QUOTENAME(ifkc.referenced_column_id,''('')
		FROM	dbaperf.dbo.vw_AllDB_foreign_key_columns ifkc
		WHERE	fk.database_id		= ifkc.database_id
		AND	fk.object_id		= ifkc.constraint_object_id
		ORDER BY ifkc.constraint_column_id
		FOR XML PATH('''')) AS fk_columns_compare
	FROM dbaperf.dbo.vw_AllDB_foreign_keys fk
	JOIN dbaperf.dbo.vw_AllDB_foreign_key_columns fkc 
	ON	fk.database_id			= fkc.database_id
	AND	fk.object_id			= fkc.constraint_object_id
	WHERE	fkc.constraint_column_id	= 1
	AND	(fkc.database_id = @database_id OR @database_id IS NULL OR @PopulateDMVsForAll = 1)
	AND	(fkc.referenced_object_id = @object_id OR @object_id IS NULL OR @PopulateDMVsForAll = 1)

	UPDATE		ibl
		SET	duplicate_indexes	= STUFF((	SELECT	'', '' + index_name AS [data()]
								FROM	dmv_IndexBaseLine iibl
								WHERE	ibl.database_id			= iibl.database_id
								 AND	ibl.object_id			= iibl.object_id
								 AND	ibl.index_id			<> iibl.index_id
								 AND	ibl.indexed_columns_compare	= iibl.indexed_columns_compare
								 AND	ibl.included_columns_compare	= iibl.included_columns_compare
								FOR XML PATH('''')), 1, 2, '''')
								
			,overlapping_indexes	= STUFF((	SELECT	'', '' + index_name AS [data()]
								FROM	dmv_IndexBaseLine iibl
								WHERE	ibl.object_id			= iibl.object_id
								 AND	ibl.index_id			<> iibl.index_id
								 AND	(ibl.indexed_columns_compare	LIKE iibl.indexed_columns_compare + ''%'' 
								 OR	iibl.indexed_columns_compare	LIKE ibl.indexed_columns_compare + ''%'')
								 AND	ibl.indexed_columns_compare	<> iibl.indexed_columns_compare 
								FOR XML PATH('''')), 1, 2, '''')
								
			,related_foreign_keys = STUFF((		SELECT	'', '' + foreign_key_name AS [data()]
								FROM	#ForeignKeys ifk
								WHERE	ifk.object_id			= ibl.object_id
								 AND	ibl.indexed_columns_compare	LIKE ifk.fk_columns_compare + ''%''
								FOR XML PATH('''')), 1, 2, '''')
								
			,related_foreign_keys_xml = CAST((	SELECT	foreign_key_name
								FROM	#ForeignKeys ForeignKeys
								WHERE	ForeignKeys.object_id		= ibl.object_id
								 AND	ibl.indexed_columns_compare	LIKE ForeignKeys.fk_columns_compare + ''%''
								FOR XML AUTO) as xml) 
	FROM		dmv_IndexBaseLine ibl

	INSERT INTO dmv_IndexBaseLine
	    (server_name, database_name, database_id, schema_id, schema_name, object_id, table_name, index_name, type_desc, existing_ranking, indexed_columns)
	SELECT		@@ServerName
			,DB_Name(t.database_id)
			,t.database_id
			,s.schema_id
			,s.name AS schema_name
			,t.object_id
			,t.name AS table_name
			,fk.foreign_key_name AS index_name
			,''--MISSING FOREIGN KEY--'' as type_desc
			,9999
			,fk.fk_columns
	FROM		dbaperf.dbo.vw_AllDB_tables t
	JOIN		dbaperf.dbo.vw_AllDB_schemas s 
		ON	t.database_id			= s.database_id
		AND	t.schema_id			= s.schema_id
	JOIN		#ForeignKeys fk 
		ON	t.database_id			= fk.database_id
		AND	t.object_id			= fk.object_id
	LEFT JOIN	dmv_IndexBaseLine ia 
		ON	fk.database_id			= ia.database_id 
		AND	fk.object_id			= ia.object_id 
		AND	ia.indexed_columns_compare	LIKE fk.fk_columns_compare + ''%''
	WHERE		ia.index_name			IS NULL;


	;WITH	ReadAggregation
		AS	(
			SELECT	row_id
				,CAST(100. * (user_seeks + user_scans + user_lookups)
				    /(NULLIF(SUM(user_seeks + user_scans + user_lookups) 
				    OVER(PARTITION BY database_id, schema_name, table_name), 0) * 1.) as decimal(12,2)) AS estimated_user_total_pct
				,SUM(buffer_mb) OVER(PARTITION BY database_id, schema_name, table_name) as table_buffer_mb
			FROM	dmv_IndexBaseLine
			)
		,WriteAggregation
		AS	(
			SELECT	row_id
				,CAST((100.00 * user_updates)
				    /(NULLIF(SUM(user_updates) 
				    OVER(PARTITION BY database_id, schema_name, table_name), 0) * 1.) as decimal(12,2)) AS estimated_user_total_pct
			FROM	dmv_IndexBaseLine 
			)
	UPDATE		ibl
		SET	estimated_user_total_read_pct		= COALESCE(r.estimated_user_total_pct, 0.00)
			,estimated_user_total_write_pct		= COALESCE(w.estimated_user_total_pct, 0.00)
			,table_buffer_mb			= r.table_buffer_mb
			,index_read_pct				= (COALESCE(user_total_read,0.00) * 100.00) / CASE WHEN COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) = 0.00 THEN 1.00 ELSE COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) END
			,index_write_pct			= (COALESCE(user_total_write,0.00) * 100.00) / CASE WHEN COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) = 0.00 THEN 1.00 ELSE COALESCE(user_total_read,0.00) + COALESCE(user_total_write,0.00) END
	FROM		dmv_IndexBaseLine ibl
	JOIN		ReadAggregation r 
		ON	ibl.row_id = r.row_id
	JOIN		WriteAggregation w 
		ON	ibl.row_id = w.row_id


	;WITH IndexAction
	AS (
	    SELECT row_id
		,CASE WHEN user_lookups > user_seeks AND type_desc IN (''CLUSTERED'', ''HEAP'', ''UNIQUE CLUSTERED'') THEN ''REALIGN''
		    WHEN type_desc = ''--MISSING FOREIGN KEY--'' THEN ''CREATE''
		    WHEN type_desc = ''XML'' THEN ''---''
		    WHEN is_unique = 1 THEN ''---''
		    WHEN type_desc = ''--NONCLUSTERED--'' AND ROW_NUMBER() OVER (PARTITION BY table_name ORDER BY user_total_read desc) <= 10 AND estimated_user_total_read_pct > 1 THEN ''CREATE''
		    WHEN type_desc = ''--NONCLUSTERED--'' THEN ''BLEND''
		    WHEN ROW_NUMBER() OVER (PARTITION BY database_id, table_name ORDER BY user_total_read desc, existing_ranking) > 10 THEN ''DROP'' 
		    WHEN user_total_read = 0 THEN ''DROP'' 
		    ELSE ''---'' END AS index_action
	    FROM dmv_IndexBaseLine
	)
	UPDATE		ibl
		SET	index_action = ia.index_action
	FROM		dmv_IndexBaseLine ibl 
	JOIN		IndexAction ia
		ON	ibl.row_id	= ia.row_id

	UPDATE		ibl
		SET	has_unique = 1
	FROM		dmv_IndexBaseLine ibl
	JOIN		(
			SELECT		DISTINCT
					database_id 
					,object_id 
			FROM		dbaperf.dbo.vw_AllDB_indexes i 
			WHERE		i.is_unique = 1
			) x 
		ON	ibl.database_id		= x.database_id
		AND	ibl.object_id		= x.object_id
END




SELECT	@Database_Name		= COALESCE(@Database_Name,''NULL'')
	,@Schema_Name		= COALESCE(@Schema_Name,''NULL'')
	,@Table_Name		= COALESCE(@Table_Name,''NULL'')

	-------------------------------------------------------
	-------------------------------------------------------
	-- EXPORT DATA dbaperf.dbo.dmv_IndexBaseLine
	-------------------------------------------------------
	-------------------------------------------------------


SET	@Export_Source		= ''dbaperf.dbo.dmv_IndexBaseLine''
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbaudf_base64_encode] (@@SERVERNAME+''|''+REPLACE(@Export_Source,''dbaperf.dbo.'','''')+''|''+@Database_Name+''|''+@Schema_Name+''|''+@Table_Name)+''.dat'',''='',''$'')
SET	@SCRIPT			= ''bcp ''+@Export_Source+'' out "''+@LocalPath+''\''+@FileName+''" -S ''+@@Servername+'' -T -N''
--Print	@Script

Print ''Exporting Data from '' + @Export_Source
PRINT ''To File: '' + @FileName
EXEC	xp_cmdshell		@SCRIPT, no_output

Print ''Sending Data from '' + @Export_Source
EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= @target_env
		,@target_server		= @target_server
		,@target_share		= @target_share
		,@retry_limit		= @retry_limit
  
waitfor delay ''00:00:05''  
  
-- DELETE FILE AFTER SENDING
SET	@Script = ''DEL "''+ @UNCPath+''\''+@FileName+''"''
--Print	@Script

Print ''Deleting File from '' + @Export_Source
exec	master..xp_cmdshell @Script, no_output


	-------------------------------------------------------
	-------------------------------------------------------
	-- EXPORT DATA dbaperf.dbo.dmv_MissingIndexSnapshot
	-------------------------------------------------------
	-------------------------------------------------------

		
SET	@Export_Source		= ''dbaperf.dbo.dmv_MissingIndexSnapshot''
SELECT	@FileName		= REPLACE([dbaadmin].[dbo].[dbaudf_base64_encode] (@@SERVERNAME+''|''+REPLACE(@Export_Source,''dbaperf.dbo.'','''')+''|''+@Database_Name+''|''+@Schema_Name+''|''+@Table_Name)+''.dat'',''='',''$'')
SET	@SCRIPT			= ''bcp ''+@Export_Source+'' out "''+@LocalPath+''\''+@FileName+''" -S ''+@@Servername+'' -T -N''
--Print	@Script

Print ''Exporting Data from '' + @Export_Source
PRINT ''To File: '' + @FileName
EXEC	xp_cmdshell		@SCRIPT, no_output

Print ''Sending Data from '' + @Export_Source
EXEC	[dbaadmin].[dbo].[dbasp_File_Transit] 
		@source_name		= @FileName
		,@source_path		= @UNCPath
		,@target_env		= @target_env
		,@target_server		= @target_server
		,@target_share		= @target_share
		,@retry_limit		= @retry_limit
  
waitfor delay ''00:00:05''  
  
-- DELETE FILE AFTER SENDING
SET	@Script = ''DEL "''+ @UNCPath+''\''+@FileName+''"''
--Print	@Script

Print ''Deleting File from '' + @Export_Source
exec	master..xp_cmdshell @Script, no_output
' 
END
GO


/**************************************************************
Generated SQL - SYSaddjobs
For Server: G1SQLA\A on Jun  9 2010 12:02:32:860PM
 
NOTE:  The following SQL jobs were scripted using the input parm
       @leave_enabled = 'y'.
**************************************************************/
use [msdb]
go
 
/*************************************************************************************************
Create new job: UTIL - PERF - GIMPI Collect and Export
**************************************************************************************************/
BEGIN TRANSACTION
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  DECLARE @charpos INT
  DECLARE @miscprint nvarchar(500)
  DECLARE @save_servername sysname
  DECLARE @save_servername2 sysname
  DECLARE @save_servername3 sysname
  DECLARE @save_servername4b sysname
  DECLARE @save_output_filename sysname
  DECLARE @save_jname sysname
  DECLARE @save_sname sysname
  DECLARE @parm01 sysname
  DECLARE @logpath sysname
  Select  @ReturnCode = 0
 
  -- Set up the servername variables
  Select @save_servername = @@servername
  Select @save_servername2 = @@servername
  Select @save_servername3 = @@servername
  Select @save_servername4b = @@servername
 
  Select @charpos = charindex('\', @save_servername)
  IF @charpos <> 0
     begin
        Select @save_servername = substring(@@servername, 1, (CHARINDEX('\', @@servername)-1))
        Select @save_servername2 = stuff(@save_servername2, @charpos, 1, '$')
        Select @save_servername3 = stuff(@save_servername3, @charpos, 1, '(')
        Select @save_servername3 = @save_servername3 + ')'
        Select @save_servername4b = stuff(@save_servername4b, @charpos, 1, '_')
     end
 
  -- Set up the output file path variable
  Select @parm01 = @save_servername2 + '_SQLjob_logs'
  If exists(select 1 from master.sys.sysdatabases where name = 'dbaadmin')
     begin
        exec dbaadmin.dbo.dbasp_get_share_path @parm01, @logpath output
     end
 
  -- Verify the proper category exists
  IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
     begin
        EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'Job', @type=N'Local', @name=N'[Uncategorized (Local)]'
        IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
     end
 
  -- Delete the job with the same name (if it exists)
  Select @JobID = job_id
  from   msdb.dbo.sysjobs
  where (name = N'UTIL - PERF - GIMPI Collect and Export')
  If (@JobID is not null)
     begin
        -- Check if the job is a multi-server job
        IF (exists (Select * From msdb.dbo.sysjobservers
                    Where (job_id = @JobID) and (server_id <> 0)))
           begin
              -- This is a mult server job, so abort the script
              Select @miscprint = 'Unable to delete job ''UTIL - PERF - GIMPI Collect and Export'' since there is already a multi-server job with this name.'
              RAISERROR (@miscprint, 16, 1)
              GOTO QuitWithRollback
           end
        Else
           begin
              -- Delete the [local] job
              Select @miscprint = N'UTIL - PERF - GIMPI Collect and Export'
              EXEC msdb.dbo.sp_delete_job @job_name = @miscprint
              Select @JobID = null
           end
     end
 
  -- Add the job
  Select @save_jname = N'UTIL - PERF - GIMPI Collect and Export'
  EXEC @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT
                                           ,@job_name = @save_jname
                                           ,@owner_login_name = N'sa'
                                           ,@description = N'Collect and Export Index Performance Data to support the GIMPI Reports'
                                           ,@category_name = N'[Uncategorized (Local)]'
                                           ,@enabled = 1
                                           ,@notify_level_email = 0
                                           ,@notify_level_page = 0
                                           ,@notify_level_netsend = 0
                                           ,@notify_level_eventlog = 0
                                           ,@delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
 
  -- Preparation for job step 1
 
  -- Move the output file name and path to a variable
  Select @save_output_filename = '\\g1sqla\G1SQLA$A_SQLjob_logs\UTIL_PERF_EXPORT_IndexAnalysisReport_Data.txt'
 
  -- Move the command syntax for this job step to a variable
  Declare @command_vrb1  NVARCHAR(MAX)
  Select @command_vrb1 = ''
  Select  @command_vrb1 = @command_vrb1 + 'exec dbaperf.dbo.dbasp_GIMPI_CaptureAndExport'
 
  -- Add job step 1
  Select @save_sname = N'Export Data'
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID
                                               ,@step_id = 1
                                               ,@step_name = @save_sname
                                               ,@command = @command_vrb1
                                               ,@database_name = N'master'
                                               ,@server = N''
                                               ,@database_user_name = N''
                                               ,@subsystem = N'TSQL'
                                               ,@cmdexec_success_code = 0
                                               ,@flags = 6
                                               ,@retry_attempts = 0
                                               ,@retry_interval = 0
                                               ,@os_run_priority = 0
                                               ,@output_file_name = @save_output_filename
                                               ,@on_success_step_id = 0
                                               ,@on_success_action = 1
                                               ,@on_fail_step_id = 0
                                               ,@on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID
                                                   ,@name = N'Daily at 1AM'
                                                   ,@enabled = 1
                                                   ,@freq_type = 4
                                                   ,@active_start_date = 20100507
                                                   ,@active_start_time = 10000
                                                   ,@freq_interval = 1
                                                   ,@freq_subday_type = 1
                                                   ,@freq_subday_interval = 1
                                                   ,@freq_relative_interval = 0
                                                   ,@freq_recurrence_factor = 0
                                                   ,@active_end_date = 99991231
                                                   ,@active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
  -- Update the job start step
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)'
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
  -- Update Production Job Status Info
  IF exists(select * from master.sys.sysdatabases where name = 'DEPLinfo')
     begin
	  IF exists(select * from DEPLinfo.sys.objects where name = 'ProdJobStatus')
	     begin
		  IF exists(select * from DEPLinfo.dbo.ProdJobStatus where JobName = 'UTIL - PERF - GIMPI Collect and Export')
		     begin
			  update DEPLinfo.dbo.ProdJobStatus set JobStatus = 1 where JobName = 'UTIL - PERF - GIMPI Collect and Export'
		     end
		  ELSE
		     begin
			  insert into DEPLinfo.dbo.ProdJobStatus (JobName, JobStatus) values ('UTIL - PERF - GIMPI Collect and Export', 1)
		     end
	     end
     end
 
COMMIT TRANSACTION
GOTO   EndSave
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave:
GO