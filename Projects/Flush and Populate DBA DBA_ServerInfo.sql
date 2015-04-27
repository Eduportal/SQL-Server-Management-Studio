

SET NOCOUNT ON

DECLARE @RC int
DECLARE @SiteId uniqueidentifier
DECLARE @WebId uniqueidentifier
DECLARE @ListID UNIQUEIDENTIFIER
DECLARE @UserId int
DECLARE @ServerTemplate int
DECLARE @Id INT
DECLARE @ItemId INT
DECLARE @UseNvarchar1ItemName bit
DECLARE @AuditIfNecessary bit
DECLARE @UserTitle nvarchar(255)
DECLARE @Version int
DECLARE @NeedsAuthorRestriction bit
DECLARE @Basetype int
DECLARE @DeleteOp int
DECLARE @DeleteTransactionId varbinary(16)
DECLARE @Size BIGINT
DECLARE @NextAvailID INT
DECLARE @ItemDirName nvarchar(256)
DECLARE @ItemLeafName nvarchar(128)
DECLARE @TimeNow DATETIME
DECLARE @tp_GUID UNIQUEIDENTIFIER
DECLARE @RowOrdinal int
DECLARE @Columns1 VARCHAR(MAX)
DECLARE @Columns2 VARCHAR(MAX)
DECLARE @Columns3 VARCHAR(MAX)
DECLARE @Columns4 VARCHAR(MAX)
DECLARE	@Counter INT
DECLARE @WebTitle VARCHAR(255)
DECLARE @ListTitle VARCHAR(255)
DECLARE @MaxSize int

DECLARE	@Counter_nvarchar	INT
DECLARE	@Counter_datetime	INT
DECLARE	@Counter_ntext		INT
DECLARE	@Counter_float		INT
DECLARE	@Counter_int		INT
DECLARE	@Counter_bit		INT

SET	@Counter_nvarchar	= 0
SET	@Counter_datetime	= 0
SET	@Counter_ntext		= 0
SET	@Counter_float		= 0
SET	@Counter_int		= 0
SET	@Counter_bit		= 0

SET	@WebTitle = 'DBA'
SET	@ListTitle = 'DBA_ServerInfo'

SET @RowOrdinal = 0

SELECT	@WebId = Id
	,@SiteId = SiteID
FROM	dbo.Webs 
WHERE	Title = @WebTitle

SELECT	@ListID = tp_ID
	,@ServerTemplate = tp_ServerTemplate
FROM	dbo.Lists 
WHERE	tp_Title = @ListTitle

SELECT @UserId = [WSS_Content_eCommOps].[dbo].[fn_UserIDFromSid] (@SiteId,SUSER_SID('Amer\sledridge'))

SELECT		@MaxSize = SUM(COALESCE(CHARACTER_MAXIMUM_LENGTH,10))
FROM		[SEAFRESQLDBA01].[dbaadmin].[INFORMATION_SCHEMA].[COLUMNS] 
WHERE		[TABLE_NAME] = @ListTitle


SELECT	TOP 1
	@ItemId = COALESCE(tp_ID,0)
FROM	dbo.UserData
WHERE	tp_ListId = @ListID
ORDER BY [tp_ID] DESC

WHILE @ItemId > 0
BEGIN
	EXECUTE @RC = [WSS_Content_eCommOps].[dbo].[proc_DropListRecord] 
		@SiteId = @SiteId
		,@WebId = @WebId
		,@ListId = @ListId
		,@ServerTemplate = @ServerTemplate
		,@Id = @ItemId
		,@UserId = @UserId
		,@UserTitle = NULL

	SET @ItemId = NULL
	
	SELECT	TOP 1
		@ItemId = COALESCE(tp_ID,0)
	FROM	dbo.UserData
	WHERE	tp_ListId = @ListID
	ORDER BY [tp_ID] Desc
END


UPDATE dbo.Lists
	SET tp_NextAvailableID = 1
WHERE tp_ID = @ListID


DECLARE	@SQLServerID int
	,@ServerName nvarchar(128)
	,@ServerType nvarchar(128)
	,@SQLName nvarchar(128)
	,@SQLEnv nvarchar(128)
	,@Active char(1)
	,@Filescan char(1)
	,@SQLmail char(1)
	,@modDate datetime
	,@SQLver nvarchar(500)
	,@SQLinstallDate datetime
	,@SQLinstallBy nvarchar(128)
	,@SQLrecycleDate nvarchar(128)
	,@SQLSvcAcct nvarchar(128)
	,@SQLAgentAcct nvarchar(128)
	,@SQLStartupParms nvarchar(128)
	,@SQLScanforStartupSprocs char(1)
	,@dbaadmin_Version nvarchar(128)
	,@backup_type nvarchar(128)
	,@LiteSpeed char(1)
	,@RedGate char(1)
	,@awe_enabled char(1)
	,@MAXdop_value nvarchar(5)
	,@Memory nvarchar(128)
	,@SQLmax_memory nvarchar(20)
	,@tempdb_filecount nvarchar(10)
	,@FullTextCat char(1)
	,@Assemblies char(1)
	,@Mirroring char(1)
	,@Repl_Flag char(1)
	,@LogShipping char(1)
	,@LinkedServers char(1)
	,@ReportingSvcs char(1)
	,@LocalPasswords char(1)
	,@DEPLstatus char(1)
	,@OracleClient nvarchar(128)
	,@TNSnamesPath nvarchar(128)
	,@DomainName nvarchar(128)
	,@iscluster char(1)
	,@SAN char(1)
	,@Port nvarchar(10)
	,@Location nvarchar(128)
	,@IPnum nvarchar(128)
	,@CPUphysical nvarchar(128)
	,@CPUcore nvarchar(128)
	,@CPUlogical nvarchar(128)
	,@CPUtype nvarchar(128)
	,@OSname nvarchar(128)
	,@OSver nvarchar(128)
	,@OSinstallDate nvarchar(128)
	,@OSuptime nvarchar(128)
	,@MDACver nvarchar(128)
	,@IEver nvarchar(128)
	,@AntiVirus_type nvarchar(128)
	,@AntiVirus_Excludes char(1)
	,@boot_3gb char(1)
	,@boot_pae char(1)
	,@boot_userva char(1)
	,@Pagefile_size nvarchar(128)
	,@Pagefile_path nvarchar(128)
	,@SystemModel nvarchar(128)
	,@MOMverifyDate datetime

DECLARE NewItemCursor CURSOR
FOR
SELECT		*
FROM		SEAFRESQLDBA01.dbaadmin.dbo.DBA_ServerInfo




DECLARE @name varchar(40)
OPEN NewItemCursor

FETCH NEXT FROM NewItemCursor INTO @SQLServerID,@ServerName,@ServerType,@SQLName,@SQLEnv,@Active,@Filescan,@SQLmail,@modDate,@SQLver,@SQLinstallDate,@SQLinstallBy,@SQLrecycleDate,@SQLSvcAcct,@SQLAgentAcct,@SQLStartupParms,@SQLScanforStartupSprocs,@dbaadmin_Version,@backup_type,@LiteSpeed,@RedGate,@awe_enabled,@MAXdop_value,@Memory,@SQLmax_memory,@tempdb_filecount,@FullTextCat,@Assemblies,@Mirroring,@Repl_Flag,@LogShipping,@LinkedServers,@ReportingSvcs,@LocalPasswords,@DEPLstatus,@OracleClient,@TNSnamesPath,@DomainName,@iscluster,@SAN,@Port,@Location,@IPnum,@CPUphysical,@CPUcore,@CPUlogical,@CPUtype,@OSname,@OSver,@OSinstallDate,@OSuptime,@MDACver,@IEver,@AntiVirus_type,@AntiVirus_Excludes,@boot_3gb,@boot_pae,@boot_userva,@Pagefile_size,@Pagefile_path,@SystemModel,@MOMverifyDate
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @RowOrdinal = @RowOrdinal + 1
		SET @TimeNow = GETDATE()
		SET @tp_GUID = NEWID()
		
		Select @NextAvailID = tp_NextAvailableID
		From dbo.Lists
		WHERE tp_ID = @ListID
		
		SET @Size = COALESCE(LEN(@ServerName+@ServerType+@SQLName+@SQLEnv+@Active+@Filescan+@SQLmail+@SQLver+@SQLinstallBy+@SQLrecycleDate+@SQLSvcAcct+@SQLAgentAcct+@SQLStartupParms+@SQLScanforStartupSprocs+@dbaadmin_Version+@backup_type+@LiteSpeed+@RedGate+@awe_enabled+@MAXdop_value+@Memory+@SQLmax_memory+@tempdb_filecount+@FullTextCat+@Assemblies+@Mirroring+@Repl_Flag+@LogShipping+@LinkedServers+@ReportingSvcs+@LocalPasswords+@DEPLstatus+@OracleClient+@TNSnamesPath+@DomainName+@iscluster+@SAN+@Port+@Location+@IPnum+@CPUphysical+@CPUcore+@CPUlogical+@CPUtype+@OSname+@OSver+@OSinstallDate+@OSuptime+@MDACver+@IEver+@AntiVirus_type+@AntiVirus_Excludes+@boot_3gb+@boot_pae+@boot_userva+@Pagefile_size+@Pagefile_path+@SystemModel)+40,@MaxSize)

		SET @ItemId = NULL
		SET @ItemDirName = NULL
		SET @ItemLeafName = NULL
					
		EXECUTE @RC = [WSS_Content_eCommOps].[dbo].[proc_AddListItem]
			@SiteId = @SiteId
			,@WebId = @WebId
			,@ListID = @ListID
			,@RowOrdinal = 0--@RowOrdinal
			,@ItemId = @ItemId OUTPUT
			,@ItemDirName = @ItemDirName OUTPUT
			,@ItemLeafName = @ItemLeafName OUTPUT
			,@UserID = @UserID
			,@TimeNow = @TimeNow
			,@ServerTemplate = @ServerTemplate
			,@Basetype= 0
			,@Level= 1
			,@tp_GUID = @tp_GUID
			,@AddNamespace = 1
			,@CheckDiskQuota = 1
			,@tp_ID = @NextAvailID

			,@float1 = @SQLServerID
			,@nvarchar1 = @ServerName
			,@nvarchar3 = @ServerType
			,@nvarchar4 = @SQLName
			,@nvarchar5 = @SQLEnv
			,@nvarchar6 = @Active
			,@nvarchar7 = @Filescan
			,@nvarchar8 = @SQLmail
			,@datetime1 = @modDate
			,@nvarchar9 = @SQLver
			,@datetime2 = @SQLinstallDate
			,@nvarchar10 = @SQLinstallBy
			,@nvarchar11 = @SQLrecycleDate
			,@nvarchar12 = @SQLSvcAcct
			,@nvarchar13 = @SQLAgentAcct
			,@nvarchar14 = @SQLStartupParms
			,@nvarchar15 = @SQLScanforStartupSprocs
			,@nvarchar16 = @dbaadmin_Version
			,@nvarchar17 = @backup_type
			,@nvarchar18 = @LiteSpeed
			,@nvarchar19 = @RedGate
			,@nvarchar20 = @awe_enabled
			,@nvarchar21 = @MAXdop_value
			,@nvarchar22 = @Memory
			,@nvarchar23 = @SQLmax_memory
			,@nvarchar24 = @tempdb_filecount
			,@nvarchar25 = @FullTextCat
			,@nvarchar26 = @Assemblies
			,@nvarchar27 = @Mirroring
			,@nvarchar28 = @Repl_Flag
			,@nvarchar29 = @LogShipping
			,@nvarchar30 = @LinkedServers
			,@nvarchar31 = @ReportingSvcs
			,@nvarchar32 = @LocalPasswords
			,@nvarchar33 = @DEPLstatus
			,@nvarchar34 = @OracleClient
			,@nvarchar35 = @TNSnamesPath
			,@nvarchar36 = @DomainName
			,@nvarchar37 = @iscluster
			,@nvarchar38 = @SAN
			,@nvarchar39 = @Port
			,@nvarchar40 = @Location
			,@nvarchar41 = @IPnum
			,@nvarchar42 = @CPUphysical
			,@nvarchar43 = @CPUcore
			,@nvarchar44 = @CPUlogical
			,@nvarchar45 = @CPUtype
			,@nvarchar46 = @OSname
			,@nvarchar47 = @OSver
			,@nvarchar48 = @OSinstallDate
			,@nvarchar49 = @OSuptime
			,@nvarchar50 = @MDACver
			,@nvarchar51 = @IEver
			,@nvarchar52 = @AntiVirus_type
			,@nvarchar53 = @AntiVirus_Excludes
			,@nvarchar54 = @boot_3gb
			,@nvarchar55 = @boot_pae
			,@nvarchar56 = @boot_userva
			,@nvarchar57 = @Pagefile_size
			,@nvarchar58 = @Pagefile_path
			,@nvarchar59 = @SystemModel
			,@datetime3 = @MOMverifyDate

			,@tp_Modified = @TimeNow
			,@tp_Created = @TimeNow
			,@tp_ModerationStatus = 0
			,@Size = @Size
			,@ExtraItemSize = 0
			
			,@tp_InstanceID = 1
			,@tp_ContentType = 'Item'
			,@tp_ContentTypeId = 0x0100D7035EF13D43984981578788F0F762F7

	END
	FETCH NEXT FROM NewItemCursor INTO @SQLServerID,@ServerName,@ServerType,@SQLName,@SQLEnv,@Active,@Filescan,@SQLmail,@modDate,@SQLver,@SQLinstallDate,@SQLinstallBy,@SQLrecycleDate,@SQLSvcAcct,@SQLAgentAcct,@SQLStartupParms,@SQLScanforStartupSprocs,@dbaadmin_Version,@backup_type,@LiteSpeed,@RedGate,@awe_enabled,@MAXdop_value,@Memory,@SQLmax_memory,@tempdb_filecount,@FullTextCat,@Assemblies,@Mirroring,@Repl_Flag,@LogShipping,@LinkedServers,@ReportingSvcs,@LocalPasswords,@DEPLstatus,@OracleClient,@TNSnamesPath,@DomainName,@iscluster,@SAN,@Port,@Location,@IPnum,@CPUphysical,@CPUcore,@CPUlogical,@CPUtype,@OSname,@OSver,@OSinstallDate,@OSuptime,@MDACver,@IEver,@AntiVirus_type,@AntiVirus_Excludes,@boot_3gb,@boot_pae,@boot_userva,@Pagefile_size,@Pagefile_path,@SystemModel,@MOMverifyDate
END

CLOSE NewItemCursor
DEALLOCATE NewItemCursor
GO
