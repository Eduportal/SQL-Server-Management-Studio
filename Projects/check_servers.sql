USE [master]
SET NOCOUNT ON

DECLARE		@cmd					VarChar(8000)
			,@save_servername		sysname
			,@save_id				INT
			,@save_ip				sysname
			,@charpos				INT
			,@save_SQL_install_date	DateTime
			,@NameChangeMsg			sysname
			,@instancename			sysname
			,@ServerName			sysname
			,@machinename			sysname

exec xp_cmdshell 'ipconfig /flushdns', no_output 
			
SELECT	@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
		,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
		,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
		,@save_servername	= convert(nvarchar(100), serverproperty('machinename'))


-- DROP BAD ENTRY
IF 	@machinename != @save_servername AND EXISTS (SELECT * From sys.servers where name = @save_servername)
	EXEC sp_dropserver @save_servername; 

-- RENAME
IF 	@machinename != @@SERVERNAME
BEGIN
	IF EXISTS (SELECT * From sys.servers where name = @machinename) AND NOT EXISTS (SELECT * FROM sys.servers where name = @@SERVERNAME)
		SET @NameChangeMsg = 'SEVER NAME CHANGE PENDING SQL RESTART'
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM sys.servers where name = @@SERVERNAME)
			EXEC sp_dropserver @@servername; 
		IF NOT EXISTS (SELECT * FROM sys.servers where name = @machinename)
			EXEC sp_addserver @machinename, 'local'
		SET @NameChangeMsg = 'SERVER NAME CHANGED TO ' +  @machinename
	END
END
ELSE
	SET @NameChangeMsg = 'SERVER NAME ALREADY SET'




-- Get Install Date
Select @save_SQL_install_date = (select createdate from master.sys.syslogins where name = 'BUILTIN\Administrators')


			
--  Capture IP
CREATE TABLE #temp_tbl1	(tb11_id [int] IDENTITY(1,1) NOT NULL
			,text01	nvarchar(400)
			)
			
delete from #temp_tbl1
Select @cmd = 'nslookup ' + @save_servername
insert #temp_tbl1(text01) exec master.sys.xp_cmdshell @cmd
Delete from #temp_tbl1 where text01 is null or text01 = ''
--select * from #temp_tbl1

	
If (select count(*) from #temp_tbl1) > 0
   begin
	Select @save_id = (select top 1 tb11_id from #temp_tbl1 where text01 like '%Name:%')

	Select @save_ip = (select top 1 text01 from #temp_tbl1 where text01 like '%Address:%' and tb11_id > @save_id order by tb11_id)
	Select @save_ip = ltrim(substring(@save_ip, 9, 20))
	Select @save_ip = rtrim(@save_ip)

	Select @charpos = charindex(':', @save_ip)
	IF @charpos <> 0
	   begin
		select @save_ip = substring(@save_ip, 1, @charpos-1)
	   end
   end
Else
   begin
	Select @save_ip = 'Error'
   end


-- If nslookup didn't work, try ping
--If @save_ip is null or @save_ip = '' or @save_ip = 'Error'
   begin
	delete from #temp_tbl1
	Select @cmd = 'ping ' + @save_servername + ' -4'
	insert #temp_tbl1(text01) exec master.sys.xp_cmdshell @cmd
	Delete from #temp_tbl1 where text01 is null or text01 = ''
	Delete from #temp_tbl1 where text01 not like '%Reply from%'
	--select * from #temp_tbl1
        	
	If (select count(*) from #temp_tbl1) > 0
	   begin
		Select @save_ip = (select top 1 text01 from #temp_tbl1 where text01 like '%Reply from%')
		Select @save_ip = ltrim(substring(@save_ip, 11, 20))
		Select @charpos = charindex(':', @save_ip)
		IF @charpos <> 0
		   begin
			select @save_ip = substring(@save_ip, 1, @charpos-1)
		   end
	   end
	Else
	   begin
		Select @save_ip = 'Error'
	   end
   end

SELECT @machinename,@@ServerName,@NameChangeMsg,@save_ip,@save_SQL_install_date
ORDER BY 1

GO
DROP TABLE #temp_tbl1