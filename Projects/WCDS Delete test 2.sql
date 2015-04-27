USE WCDS 
GO   


DECLARE @rowcount		INT
DECLARE	@OriginalSystem	TABLE	
						(
						[iOriginalSystemID] INT NOT NULL,
						[vchOriginalSystemName] nVARCHAR(100) NOT NULL,
						[iCreatedBy] INT NOT NULL,
						[dtCreated] DATETIME NOT NULL,
						[iModifiedBy] INT NOT NULL,
						[dtModified] DATETIME NOT NULL
						)

DECLARE	@SecuritySystem	TABLE
						(
						[SystemId] INT NOT NULL,
						[SystemName] [nvarchar](100) NULL,
						[DateCreated] [datetime] NOT NULL,
						[CreatedBy] [int] NOT NULL,
						[SearchScopingMethod] [int] NULL,
						[OwningCompanyId] INT NULL,
						[DownloadAuthorization] [int] NULL,
						[SystemTypeId] [int] NULL,
						[IsActive] [bit] NULL,
						[CreativeSortOrder] [int] NULL,
						[BillableSku] [nvarchar](100) NULL,
						[DownloadSourceId] [int] NULL
						)



BEGIN TRY 

	PRINT 'Deleting OriginalSystem Test Data' 

	DELETE	TOP (100)
	FROM	dbo.OriginalSystem
	OUTPUT  deleted.*
	INTO	@OriginalSystem
	WHERE	vchOriginalSystemName IN (SELECT SystemName FROM dbo.SecuritySystem WITH(NOLOCK) WHERE OwningCompanyId IN (1,100,123) AND SystemId != 9999 )

	SET @rowcount = @@ROWCOUNT

	WHILE @rowcount = 100
	BEGIN
		DELETE	TOP (100)
		FROM	dbo.OriginalSystem
		OUTPUT  deleted.*
		INTO	@OriginalSystem
		WHERE	vchOriginalSystemName IN (SELECT SystemName FROM dbo.SecuritySystem WITH(NOLOCK) WHERE OwningCompanyId IN (1,100,123) AND SystemId != 9999 )

		SET @rowcount = @@ROWCOUNT
	END


	PRINT 'Deleting SecuritySystem Test Data' 

	DELETE	TOP (10)
	FROM	dbo.SecuritySystem 
	OUTPUT  deleted.*
	INTO	@SecuritySystem
	WHERE	OwningCompanyId IN (1,100,123) AND SystemId != 9999
	
	SET @rowcount = @@ROWCOUNT
	
	WHILE @rowcount = 10
	BEGIN
			DELETE	TOP (10)
			FROM	dbo.SecuritySystem 
			OUTPUT  deleted.*
			INTO	@SecuritySystem
			WHERE	OwningCompanyId IN (1,100,123) AND SystemId != 9999
	
			SET @rowcount = @@ROWCOUNT
	END	

	PRINT 'Finished delete' 
END TRY 
        
BEGIN CATCH 
    PRINT 'Delete not successful' 

	INSERT INTO [WCDS].[dbo].[SecuritySystem]
			   ([SystemId]
			   ,[SystemName]
			   ,[DateCreated]
			   ,[CreatedBy]
			   ,[SearchScopingMethod]
			   ,[OwningCompanyId]
			   ,[DownloadAuthorization]
			   ,[SystemTypeId]
			   ,[IsActive]
			   ,[CreativeSortOrder]
			   ,[BillableSku]
			   ,[DownloadSourceId])
	SELECT		[SystemId]
				,[SystemName]
				,[DateCreated]
				,[CreatedBy]
				,[SearchScopingMethod]
				,[OwningCompanyId]
				,[DownloadAuthorization]
				,[SystemTypeId]
				,[IsActive]
				,[CreativeSortOrder]
				,[BillableSku]
				,[DownloadSourceId]
	  FROM		[WCDS].[dbo].[SecuritySystem]
	  
	  

	SET IDENTITY_INSERT dbo.OriginalSystem ON

	INSERT INTO [WCDS].[dbo].[OriginalSystem]
				(
				[iOriginalSystemID]
				,[vchOriginalSystemName]
				,[iCreatedBy]
				,[dtCreated]
				,[iModifiedBy]
				,[dtModified]
				)
	SELECT		[iOriginalSystemID]
				,[vchOriginalSystemName]
				,[iCreatedBy]
				,[dtCreated]
				,[iModifiedBy]
				,[dtModified]
	FROM		@OriginalSystem
		
	SET IDENTITY_INSERT dbo.OriginalSystem OFF
END CATCH 

GO
ROLLBACK TRANSACTION