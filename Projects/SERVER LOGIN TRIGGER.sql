USE MASTER
GO
IF OBJECT_ID('IP_RESTRICTION_BlackList') IS NOT NULL
	DROP TABLE [dbo].[IP_RESTRICTION_BlackList]
GO	
CREATE TABLE [dbo].[IP_RESTRICTION_BlackList](
        [UserName] [varchar](255) NOT NULL,
        [ValidIP] [varchar](15) NOT NULL,
        [Comment] [nvarchar](255) NULL,
 CONSTRAINT [PK_IP_RESTRICTION_BlackList] PRIMARY KEY CLUSTERED 
([UserName] ASC, [ValidIP] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO
IF OBJECT_ID('IP_RESTRICTION_WhiteList') IS NOT NULL
	DROP TABLE [dbo].[IP_RESTRICTION_WhiteList]
GO
CREATE TABLE [dbo].[IP_RESTRICTION_WhiteList](
        [UserName] [varchar](255) NOT NULL,
        [ValidIP] [varchar](15) NOT NULL,
        [Comment] [nvarchar](255) NULL,
 CONSTRAINT [PK_IP_RESTRICTION_WhiteList] PRIMARY KEY CLUSTERED 
([UserName] ASC, [ValidIP] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO

IF OBJECT_ID('IP_RESTRICTION_LOG') IS NOT NULL
	DROP TABLE [dbo].[IP_RESTRICTION_LOG]
GO
CREATE TABLE [dbo].[IP_RESTRICTION_LOG](
		[LoginEventID] [Int] IDENTITY(1,1) PRIMARY KEY CLUSTERED,
        [UserName] [varchar](255) NOT NULL,
        [ValidIP] [varchar](15) NOT NULL,
        [LoginDate] [datetime] NOT NULL,
        [Status] [varchar](2048) NULL
) ON [PRIMARY]
GO


GRANT INSERT ON [dbo].[IP_RESTRICTION_LOG] TO [public]
GO
GRANT REFERENCES ON [dbo].[IP_RESTRICTION_LOG] TO [public]
GO
GRANT SELECT ON [dbo].[IP_RESTRICTION_LOG] TO [public]
GO

GRANT REFERENCES ON [dbo].[IP_RESTRICTION_WhiteList] TO [public]
GO
GRANT SELECT ON [dbo].[IP_RESTRICTION_WhiteList] TO [public]
GO

GRANT REFERENCES ON [dbo].[IP_RESTRICTION_BlackList] TO [public]
GO
GRANT SELECT ON [dbo].[IP_RESTRICTION_BlackList] TO [public]
GO





USE master
GO
IF  EXISTS (SELECT * FROM master.sys.server_triggers WHERE parent_class_desc = 'SERVER' AND name = N'LOGIN_IP_RESTRICTION')
DROP TRIGGER [LOGIN_IP_RESTRICTION] ON ALL SERVER
GO
CREATE TRIGGER [LOGIN_IP_RESTRICTION]
        ON ALL SERVER FOR LOGON
AS
BEGIN
        DECLARE @host NVARCHAR(255);
		DECLARE @Fail bit
		
        SET @host = EVENTDATA().value('(/EVENT_INSTANCE/ClientHost)[1]', 'nvarchar(max)');
		SET	@Fail = 0

		--INSERT INTO MASTER.dbo.IP_RESTRICTION_LOG(UserName,ValidIP,LoginDate)
		--SELECT SYSTEM_USER,@host,getdate()

        IF(EXISTS(SELECT * FROM MASTER.dbo.IP_RESTRICTION_WhiteList 
                WHERE UserName = SYSTEM_USER))
        BEGIN
                IF(NOT EXISTS(SELECT * FROM MASTER.dbo.IP_RESTRICTION_WhiteList
                        WHERE UserName = SYSTEM_USER AND ValidIP = @host))
                BEGIN
						RAISERROR('Login Failed Due to Missing Whitelist Entry',16,1) WITH NOWAIT,LOG
						SET @Fail = 1
                END
        END

        ELSE IF(EXISTS(SELECT * FROM MASTER.dbo.IP_RESTRICTION_BlackList 
                WHERE UserName = SYSTEM_USER))
        BEGIN
                IF(EXISTS(SELECT * FROM MASTER.dbo.IP_RESTRICTION_BlackList 
                        WHERE UserName = SYSTEM_USER AND ValidIP = @host))
                BEGIN
						RAISERROR('Login Failed Due to Blacklist Entry',16,1) WITH NOWAIT,LOG
						SET @Fail = 1
                END
        END
        
        IF @Fail = 1
			ROLLBACK
		--ELSE 
  --      BEGIN
		--	INSERT INTO MASTER.dbo.IP_RESTRICTION_LOG(UserName,ValidIP,LoginDate,Status)
		--	SELECT SYSTEM_USER,@host,getdate(),'Login Succeded'        
  --      END
			
        
END;


SELECT * FROM MASTER.dbo.IP_RESTRICTION_LOG



--TRUNCATE TABLE MASTER.dbo.IP_RESTRICTION_LOG
--TRUNCATE TABLE MASTER.dbo.IP_RESTRICTION_BlackList


INSERT INTO MASTER.dbo.IP_RESTRICTION_BlackList (UserName,ValidIP)
--SELECT 'AMER\s-sledridge','<local machine>'
--SELECT 'DSSUser','10.196.193.148'
SELECT 'DSSUser','10.196.193.160'