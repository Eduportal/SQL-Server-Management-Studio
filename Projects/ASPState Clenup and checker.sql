SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF EXISTS (SELECT 1 FROM master.sys.databases WHERE name = 'ASPState5')
BEGIN
	USE ASPState5

	BEGIN
		DECLARE @now DATETIME
		DECLARE @save_SessionID NVARCHAR(88)

		SET @now = GETUTCDATE()

		DECLARE @ExpiredSessions TABLE	
		  ( SessionID NVARCHAR(88) NOT NULL 
		      PRIMARY KEY
		  )

		SELECT COUNT(*)
		FROM dbo.ASPStateTempSessions WITH(NOLOCK)
		WHERE Expires < @now 
		
		INSERT @ExpiredSessions (SessionID)
		SELECT TOP 10000 SessionID
		FROM dbo.ASPStateTempSessions WITH(NOLOCK)
		WHERE Expires < @now

		IF (SELECT COUNT(*) FROM @ExpiredSessions) > 0
		BEGIN
			Start_delete:
			RAISERROR('BachDelete',-1,-1) WITH NOWAIT
			
			DELETE TOP(100) 
			FROM dbo.ASPStateTempSessions
			WHERE SessionID IN (SELECT SessionID FROM @ExpiredSessions)

			IF @@ROWCOUNT > 0 GOTO Start_delete
		END
	END
END	

DECLARE @now DATETIME
DECLARE @save_SessionID NVARCHAR(88)
SET @now = GETUTCDATE()

SELECT
(SELECT COUNT(*) FROM ASPState.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState
,(SELECT COUNT(*) FROM ASPState1.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState1
,(SELECT COUNT(*) FROM ASPState2.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState2
,(SELECT COUNT(*) FROM ASPState3.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState3
,(SELECT COUNT(*) FROM ASPState4.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState4
,(SELECT COUNT(*) FROM ASPState5.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState5
,(SELECT COUNT(*) FROM ASPState6.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState6
,(SELECT COUNT(*) FROM ASPState7.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState7
,(SELECT COUNT(*) FROM ASPState8.dbo.ASPStateTempSessions WITH(NOLOCK) WHERE Expires < @now) ASPState8
 