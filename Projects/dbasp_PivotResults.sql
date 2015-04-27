IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbasp_PivotResults]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[dbasp_PivotResults]
go

create procedure [dbo].[dbasp_PivotResults]
	@TableName varchar(128) = null,
	@WhereClause varchar(1000) = null
as
set nocount on
declare
	@col sysname,
	@list varchar(4000),
	@sql varchar(8000),
	@crlf varchar(2),
	@tab varchar(1),
	@maxcollen int,
	@maxvallen int,
	@tsql varchar(8000)

set @crlf=char(13)+char(10)
set @tab=char(9)

set @col=''
set @list=''

create table #colvals( col varchar(max), val varchar(max))

select
	@col = min(c.name)
from
	sys.columns c
join
	sys.tables t
	on c.object_id=t.object_id
where
	t.name = @TableName

while @col is not null
begin
	set @sql = 'insert into #colvals select '''+@col+''',cast(' + @col + ' as varchar(max)) from '+@tablename+ ' where '+ COALESCE(@WhereClause,'1=1')
	exec( @sql)

	select
		@col = min(c.name)
	from
		sys.columns c
	join
		sys.tables t
		on c.object_id=t.object_id
	where
		t.name = @TableName
	and
		c.name > @col
end

----------------
if EXISTS (SELECT * FROM #colvals)
BEGIN
	PRINT 'TABLE RESULTS FOR: ' + @TableName + COALESCE(' WHERE ' + @WhereClause,'')
	PRINT ''

	SELECT @maxcollen = MAX(len(col))
		,@maxvallen = MAX(LEN(val))
	FROM	#colvals

			
	set @tsql = 'ALTER TABLE #colvals ALTER COLUMN col varchar('+CAST(@maxcollen AS VarChar(50))+')'
	exec (@TSQL)

	set @tsql = 'ALTER TABLE #colvals ALTER COLUMN val varchar('+CAST(@maxvallen AS VarChar(50))+')'
	exec (@TSQL)

	select	
		col[Column],
		isnull(val,'<null>') as [Value] 
	from 
		#colvals
END

drop table #colvals

return 0
go