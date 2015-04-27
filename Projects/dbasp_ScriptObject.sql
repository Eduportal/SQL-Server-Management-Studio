CREATE procedure dbasp_ScriptObject
@SourceDB	varchar(128) ,
@SourceObject	varchar(128) ,	-- null for all objects
@SourceUID	varchar(128) ,	-- null for trusted connection
@SourcePWD	varchar(128) ,
@OutFilePath	varchar(256) ,
@OutFileName	varchar(128) ,  -- null for separate file per object script
@ObjectType	varchar(50) ,	-- PROCS, FUNCTIONS, TABLES, VIEWS, INDEXES
@WorkPath	varchar(256) ,
@SourceSVR	varchar(128)
as
/*
exec dbasp_ScriptObject
@SourceDB		= 'dbaadmin' ,
@SourceObject	= 'xxx' ,			-- null for all objects
@SourceUID		=  null ,			-- null for trusted connection
@SourcePWD		=  null ,
@OutFilePath	= 'c:\a\' ,
@OutFileName	= null ,			-- null for separate file per object script
@ObjectType		= 'TABLES' ,		-- PROCS, FUNCTIONS, TABLES, VIEWS, INDEXES
@WorkPath		= 'c:\temp\' ,
@SourceSVR		= 'SVR01'
*/

	set nocount on

declare	@ScriptType	int ,
	@FileName	varchar(256) ,
	@tmpFileName	varchar(256) ,
	@buffer		varchar(8000) ,
	@Collection	varchar(128) ,
	@id		int ,
	@name		varchar(128) ,
	@subname	varchar(128)

declare	@context	varchar(255) ,
	@sql		varchar(1000) ,
	@rc		int

	
	if right(@OutFilePath,1) <> '\'
	begin
		select @OutFilePath = @OutFilePath + '\'
	end

	if right(@WorkPath,1) <> '\'
	begin
		select @WorkPath = @WorkPath + '\'
	end

	select	@SourceDB = replace(replace(@SourceDB,'[',''),'[','')

select	@ScriptType	= 4 | 1 | 64 ,
	@FileName	= @OutFilePath + @OutFileName ,
	@tmpFileName	= @WorkPath + 'ScriptTmp.txt'

declare	@objServer		int ,
	@objTransfer		int ,
	@strResult		varchar(255) ,
	@strCommand		varchar(255)

	-- get objects to script and object type
	create table #Objects (name varchar(128), subname varchar(128) default null, id int identity(1,1))

	if @SourceObject is not null
	begin
		insert	#Objects
			(name)
		select @SourceObject
	end

	if @ObjectType = 'TABLES'
	begin
		if @SourceObject is null
		begin
			select @sql =   	'select 	TABLE_NAME, null '
			select @sql = @sql + 	'from	[' + @SourceDB + '].INFORMATION_SCHEMA.TABLES '
			select @sql = @sql + 	'where	TABLE_TYPE = ''BASE TABLE'''
		end
		select @Collection = 'tables'
	end
	else if @ObjectType in ('PROCS', 'PROCEDURES')
	begin
		if @SourceObject is null
		begin
			select @sql =   	'select 	ROUTINE_NAME, null '
			select @sql = @sql + 	'from	[' + @SourceDB + '].INFORMATION_SCHEMA.ROUTINES '
			select @sql = @sql + 	'where	ROUTINE_TYPE = ''PROCEDURE'''
		end
		select @Collection = 'storedprocedures'
	end
	else if @ObjectType = 'FUNCTIONS'
	begin
		if @SourceObject is null
		begin
			select @sql =   	'select 	ROUTINE_NAME, null '
			select @sql = @sql + 	'from	[' + @SourceDB + '].INFORMATION_SCHEMA.ROUTINES '
			select @sql = @sql + 	'where	ROUTINE_TYPE = ''FUNCTION'''
		end
		select @Collection = 'userdefinedfunctions'
	end
	else if @ObjectType = 'VIEWS'
	begin
		if @SourceObject is null
		begin
			select @sql = 	 	'select 	TABLE_NAME, null '
			select @sql = @sql + 	'from	[' + @SourceDB + '].INFORMATION_SCHEMA.VIEWS '
			select @sql = @sql + 	'where	TABLE_NAME not like ''sys%'''
		end
		select @Collection = 'views'
	end
	else if @ObjectType = 'INDEXES'
	begin
		if @SourceObject is null
		begin
			select @sql = 	 	'select 	o.name, i.name '
			select @sql = @sql + 	'from	[' + @SourceDB + ']..sysobjects o, [' + @SourceDB + ']..sysindexes i '
			select @sql = @sql + 	'where	o.type = ''U'' '
			select @sql = @sql + 	'and 	i.id = o.id and i.indid <> 0 '
			select @sql = @sql + 	'and 	i.name not like ''_WA_%'''
			select @sql = @sql + 	'and 	o.name not like ''dtprop%'''
			select @sql = @sql + 	'and 	i.name not in (select name from [' + @SourceDB + ']..sysobjects)'
		end
		select @Collection = 'tables'
	end
	else if @ObjectType = 'TRIGGERS'
	begin
		if @SourceObject is null
		begin
			select @sql = 	 	'select o2.name, o.name '
			select @sql = @sql + 	'from	[' + @SourceDB + ']..sysobjects o,  [' + @SourceDB + ']..sysobjects o2 '
			select @sql = @sql + 	'where	o.xtype = ''TR'' '
			select @sql = @sql + 	'and	o.parent_obj = o2.id '
		end
		select @Collection = 'tables'
	end
	else if @ObjectType = 'DEFAULTS'
	begin
		if @SourceObject is null
		begin
			select @sql = 	 	'select 	o.name, null '
			select @sql = @sql + 	'from	[' + @SourceDB + ']..sysobjects o '
			select @sql = @sql + 	'where o.type = ''D'' and o.parent_obj = ''0'''
		end
		select @Collection = 'Defaults'
	end
	else if @ObjectType = 'RULES'
	begin
		if @SourceObject is null
		begin
			select @sql = 	 	'select 	o.name, null '
			select @sql = @sql + 	'from	[' + @SourceDB + ']..sysobjects o '
			select @sql = @sql + 	'where type = ''R'''
		end
		select @Collection = 'Rules'
	end
	else if @ObjectType = 'JOBS'
	begin
		if @SourceObject is null
		begin
			select @sql = 	 	'select 	j.name, null '
			select @sql = @sql + 	'from	msdb..sysjobs j '
		end
		select @Collection = 'jobs'
	end
	else if @ObjectType = 'DTS'
	begin
		select	@sql = 'dtsrun /NScript_DTS_Packages /S(local) /E '
					+ '/A"ServerName":8="' + @SourceSVR + '" ' 
					+ '/A"Path":8="' + @OutFilePath + '" ' 
					+ '/A"UserName":8="' + coalesce(@SourceUID,'') + '" ' 
					+ '/A"Password":8="' + coalesce(@SourcePWD,'') + '" ' 
		exec master..xp_cmdshell @sql
		return
	end
	else
	begin
		select 'invalid @ObjectType'
		return
	end
	
	if @SourceSVR <> @@servername
	begin
		select @sql = replace(@sql,'''','''''')
		insert	#Objects (name, subname) exec ('select * from openquery(' + @SourceSVR + ',''' + @sql + ''')')
	end
	else
	begin
		insert	#Objects (name, subname) exec (@sql)
	end
	
	-- create empty output file
	if @OutFileName is not null
	begin
		select	@sql = 'echo. > ' + @FileName
		exec master..xp_cmdshell @sql
	end
	
	-- prepare scripting object
	select @context = 'create dmo object'
	exec @rc = sp_OACreate 'SQLDMO.SQLServer', @objServer OUT
	if @rc <> 0 or @@error <> 0 goto ErrorHnd
	
	if @SourceUID is null
	begin
		select @context = 'set integrated security ' + @SourceSVR
		exec @rc = sp_OASetProperty @objServer, LoginSecure, 1
		if @rc <> 0 or @@error <> 0 goto ErrorHnd
	end
 	
	select @context = 'connect to server ' + @SourceSVR
	exec @rc = sp_OAMethod @objServer , 'Connect', NULL, @SourceSVR , @SourceUID , @SourcePWD
	if @rc <> 0 or @@error <> 0 goto ErrorHnd
	
	select @context = 'scripting'
	-- Script all the objects
	select @id = 0
	while exists (select * from #Objects where id > @id)
	begin
		select	@id = min(id) from #Objects where id > @id
		select @name = name, @subname = subname from #Objects where id = @id
		if @OutFileName is null
		begin
			select	@FileName = @OutFilePath + 'dbo."' + @name + coalesce('[' + @subname + ']','') + '.sql"'
			select	@sql = 'echo. > ' + @FileName
			exec master..xp_cmdshell @sql
		end
		--select @sql = 'echo print ''Create = dbo.[' + @name + ']'+ coalesce('[' + @subname + ']','') + ''' >> ' + @FileName
		--exec master..xp_cmdshell @sql
		if @ObjectType = 'INDEXES'
		begin
			Set @sql = 'databases("' + @SourceDB + '").' + @Collection + '("' + @name + '").indexes("' + @subname + '").script'
		end
		else if @ObjectType = 'TRIGGERS'
		begin
			Set @sql = 'databases("' + @SourceDB + '").' + @Collection + '("' + @name + '").triggers("' + @subname + '").script'
		end
		else if @ObjectType = 'JOBS'
		begin
			Set @sql = 'Jobserver.Jobs("' + @name + '").Script'
		end
		else
		begin
			Set @sql = 'databases("' + @SourceDB + '").' + @Collection + '("' + @name + '").script'
		end
		exec @rc = sp_OAMethod @objServer, @sql , @buffer OUTPUT, @ScriptType , @tmpFileName
		select @sql = 'type ' + @tmpFileName + ' >> ' + @FileName
		exec master..xp_cmdshell @sql
	end
	-- delete tmp file
	select @sql = 'del ' + @tmpFileName
	exec master..xp_cmdshell @sql, no_output

	-- clear up dmo
	exec @rc = sp_OAMethod @objServer, 'Disconnect'
	if @rc <> 0 or @@error <> 0 goto ErrorHnd

	exec @rc = sp_OADestroy @objServer
	if @rc <> 0 or @@error <> 0 goto ErrorHnd

	-- clear up temp table
	drop table #Objects

return
ErrorHnd:
select 'fail', @context
GO
