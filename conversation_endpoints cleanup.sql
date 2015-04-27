DECLARE @CH	UniqueIdentifier
DECLARE @CH2	VarChar(50)
DECLARE @Count	INT
DECLARE ClosedCoversationCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
select	conversation_handle 
from	sys.conversation_endpoints 
where	state = 'DO' 

SET @COUNT = 0
OPEN ClosedCoversationCursor;
FETCH ClosedCoversationCursor INTO @CH;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
		SET @COUNT = @COUNT + 1;
		if @COUNT >= 1000
		BEGIN
			RAISERROR('Cleand Up 1000 Conversation',-1,-1) WITH NOWAIT
			SET @COUNT = 0

		END
		END CONVERSATION @CH WITH CLEANUP

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM ClosedCoversationCursor INTO @CH;
END
CLOSE ClosedCoversationCursor;
DEALLOCATE ClosedCoversationCursor;
