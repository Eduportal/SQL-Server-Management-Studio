--Create the needed Empty ASPDatabases first Then code populates them.

--CREATE DATABASE ASPState
--CREATE DATABASE ASPState1
--CREATE DATABASE ASPState2
--CREATE DATABASE ASPState3
--CREATE DATABASE ASPState4
--CREATE DATABASE ASPState5
--CREATE DATABASE ASPState6
--CREATE DATABASE ASPState7
--CREATE DATABASE ASPState8


-- THIS TABLE NEEDS CREATED BEFORE ANY STATUS MESSAGES CAN BE CREATED
IF (OBJECT_ID('tempdb..#StatusOutput'))	IS NULL
	CREATE	TABLE	#StatusOutput		([rownum] int identity primary key,[TextOutput] VARCHAR(8000));
	
DECLARE		@DBName				sysname
			,@DynamicCode		VarChar(8000)
			,@Feature_NetSend	bit
			,@NetSendRecip		VarChar(8000)
			,@Msg				VarChar(8000)
			,@MsgCommand		VarChar(8000)

-- DOUBLE CHECK ASP_WEB_USER LOGIN
		if not exists (select 1 from syslogins where name = 'asp_web_user')
			create login asp_web_user with password ='Webl0g1'
				
		DECLARE ASPStateDB_Cursor CURSOR FOR
			SELECT name FROM master..sysdatabases where name like 'aspstate%'
		OPEN ASPStateDB_Cursor
		FETCH NEXT FROM ASPStateDB_Cursor INTO @DBName
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @Msg =	'                    -- Rebuilding '+@DBName;IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg; INSERT INTO #StatusOutput(TextOutput) Values(@Msg);
				SELECT	@DynamicCode	= 'C:\WINDOWS\Microsoft.NET\Framework64\v2.0.50727\aspnet_regsql.exe -E -S '+@@SERVERNAME+' -ssadd -sstype c -d ' + @DBName
				exec xp_cmdshell @DynamicCode, no_output

				SET @Msg =	'                      -- Setting Permissions on '+@DBName;IF @Feature_NetSend=1 BEGIN SET @MsgCommand = 'NET SEND ' + @NetSendRecip + ' ' + @Msg; exec xp_CmdShell @MsgCommand, no_output; END Print @Msg; INSERT INTO #StatusOutput(TextOutput) Values(@Msg);
				SET		@DynamicCode	= '
				USE '+@DBName+';

				if not exists (select 1 from sysusers where name = ''asp_web_user'')
					exec sp_adduser ''asp_web_user''

				grant exec on GetMajorVersion to asp_web_user
				grant exec on CreateTempTables to asp_web_user
				grant exec on TempGetVersion to asp_web_user
				grant exec on GetHashCode to asp_web_user
				grant exec on TempGetAppID to asp_web_user
				grant exec on TempGetStateItem to asp_web_user
				grant exec on TempGetStateItem2 to asp_web_user
				grant exec on TempGetStateItem3 to asp_web_user
				grant exec on TempGetStateItemExclusive to asp_web_user
				grant exec on TempGetStateItemExclusive2 to asp_web_user
				grant exec on TempGetStateItemExclusive3 to asp_web_user
				grant exec on TempReleaseStateItemExclusive to asp_web_user
				grant exec on TempInsertUninitializedItem to asp_web_user
				grant exec on TempInsertStateItemShort to asp_web_user
				grant exec on TempInsertStateItemLong to asp_web_user
				grant exec on TempUpdateStateItemShort to asp_web_user
				grant exec on TempUpdateStateItemShortNullLong to asp_web_user
				grant exec on TempUpdateStateItemLong to asp_web_user
				grant exec on TempUpdateStateItemLongNullShort to asp_web_user
				grant exec on TempRemoveStateItem to asp_web_user
				grant exec on TempResetTimeout to asp_web_user
				grant exec on DeleteExpiredSessions to asp_web_user

				USE master;
				ALTER AUTHORIZATION ON DATABASE::'+@DBName+' TO sa;
				  
				USE '+@DBName+';
				Alter database '+@DBName+' set recovery simple;'

				EXEC (@DynamicCode)
			END
			FETCH NEXT FROM ASPStateDB_Cursor INTO @DBName
		END
		CLOSE ASPStateDB_Cursor
		DEALLOCATE ASPStateDB_Cursor

