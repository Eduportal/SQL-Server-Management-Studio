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
			,@RedgateInstalled		bit
			,@RedgateConfigured		bit
			,@RegKey				VarChar(8000)
			,@InstanceNumber		VarChar(50)
			,@LoginMode				int
			,@OldPort				VarChar(5)
			
			
-- GET CURRENT INSTANCE NUMBER VALUES
SET		@RegKey			= 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL' 
EXEC	master..xp_regread 
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= @@SERVICENAME
			,@value			= @InstanceNumber OUTPUT

-- GET CURRENT AUTHENTICATION VALUE
SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLServer'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'LoginMode'
			,@value			= @LoginMode OUTPUT

--SET @LoginMode = CASE @LoginMode WHEN '2' THEN 'Mixed' ELSE 'Not Mixed' END

-- GET CURRENT PORT VALUES
SET		@RegKey				= 'SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceNumber+'\MSSQLSERVER\SuperSocketNetLib\Tcp\IPAll\'
EXEC	master..xp_regread
			@rootkey		= 'HKEY_LOCAL_MACHINE' 
			,@key			= @RegKey 
			,@value_name	= 'TcpPort'
			,@value			= @OldPort OUTPUT			
			

exec xp_cmdshell 'ipconfig /flushdns', no_output 
			
SELECT	@instancename		= isnull('\'+nullif(REPLACE(@@SERVICENAME,'MSSQLSERVER',''),''),'')
		,@ServerName		= REPLACE(@@SERVERNAME,@instancename,'')
		,@machinename		= convert(nvarchar(100), serverproperty('machinename')) + @instancename
		,@save_servername	= convert(nvarchar(100), serverproperty('machinename'))

-- RENAME
IF 	@machinename != @@SERVERNAME
BEGIN
	IF EXISTS (SELECT * From sys.servers where name = @machinename) AND NOT EXISTS (SELECT * FROM sys.servers where name = @@SERVERNAME)
		SET @NameChangeMsg = 'SEVER NAME CHANGE PENDING SQL RESTART'
	ELSE
	BEGIN
		SET @NameChangeMsg = 'SERVER NAME NEEDS CHANGED TO ' +  @machinename
	END
END
ELSE
	SET @NameChangeMsg = 'SERVER NAME ALREADY SET'



-- Get Install Date
Select @save_SQL_install_date = (select createdate from master..syslogins where name = 'BUILTIN\Administrators')

		
--  Capture IP
CREATE TABLE #temp_tbl1	(tb11_id [int] IDENTITY(1,1) NOT NULL
			,text01	nvarchar(400)
			)
			
delete from #temp_tbl1
Select @cmd = 'nslookup ' + @save_servername
insert #temp_tbl1(text01) exec master..xp_cmdshell @cmd
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
	insert #temp_tbl1(text01) exec master..xp_cmdshell @cmd
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



-- CHECK FOR REDGATE
CREATE	TABLE		#FileExists			(isFile bit, isDir bit, hasParentDir bit)

SELECT		@RedgateInstalled		= 0
			,@RedgateConfigured		= 0
			
TRUNCATE TABLE #FileExists
INSERT INTO #FileExists exec master.dbo.xp_fileexist 'C:\Program Files (x86)\Red Gate\SQL Backup 6\SQBServerSetup.exe'
IF EXISTS (SELECT * FROM #FileExists WHERE isFile = 1 AND isDir = 0)
	SET		@RedgateInstalled		= 1

TRUNCATE TABLE #FileExists
INSERT INTO #FileExists exec master.dbo.xp_fileexist 'C:\Program Files\Red Gate\SQL Backup 6\SQBServerSetup.exe'
IF EXISTS (SELECT * FROM #FileExists WHERE isFile = 1 AND isDir = 0)
	SET		@RedgateInstalled		= 1

IF EXISTS (SELECT * from MASTER.dbo.sysobjects WHERE NAME = 'sqbutility')
	SET		@RedgateConfigured		= 1


SELECT		CASE
				WHEN Parsename(@save_ip,3) IN('196','200','206','207') 
				THEN 'Relocation Done' 
				ELSE 'Relocation Pending' 
				END						[Relocation Status]
			,@machinename				[Machine Name]
			,@@ServerName				[@@SERVERNAME]
			,@NameChangeMsg				[Name Verification]
			,@InstanceNumber			[Instance Number]
			,@LoginMode					[Login Mode]
			,@OldPort					[Port]
			,@save_ip					[IP Address]
			,@save_SQL_install_date		[SQL Install Date]
			,@RedgateInstalled			[RedGate Installed]
			,@RedgateConfigured			[RedGate Configured]
			,CAST(convert(sysname, serverproperty('ProductLevel')) AS VarChar(255))		[ProductLevel]
			,CAST(convert(sysname, serverproperty('ProductVersion')) AS VarChar(255))	[ProductVersion]
			
ORDER BY 1

GO
DROP TABLE #temp_tbl1
GO
DROP TABLE #FileExists	