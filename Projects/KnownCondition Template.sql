		
/*     
------------------------------------------------------------------------------------				
-- TEMPLATE SECTION INSTRUCTIONS	
------------------------------------------------------------------------------------
--	WORK WITH TEST QUERY SECTION BELOW TO DEFINE VALUE LOGIC AND FILTER LOGIC
--	WHEN THE QUERY WORKS, COPY IT TO A NOTEPAD WINDOW TO USE IT FOR CUTTING
--	AND PASTING INTO THE PARAMETER REPLACEMENT DIALOG AFTER STEP 14.
--	THEN FOLLOW THESE STEPS TO ADD A NEW CONDITION SECTION
-- 
--  1. COPY BETWEEN THE START AND END MARKERS BELOW FOR A NEW CONDITION
--  2. PAST NEW CONDITION SECTION
--  3. SELECT NEWLY PASTED SECTION
--  4. PRESS CTRL-H TO OPEN "FIND AND REPLACE" WINDOW
--  5. VERIFY "LOOK IN:" = "IN SELECTION"
--  6. SET "FIND WHAT:" = "{"
--  7. SET "REPLACE WITH" = "<"
--  8. CLICK "REPLACE ALL"
--  9. CHANGE "FIND WHAT:" = "}"
-- 10. CHANGE "REPLACE WITH" = ">"
-- 11. CLICK "REPLACE ALL"
-- 12. CLOSE "FIND AND REPLACE" WINDOW
-- 13. PRESS CTRL-SHFT-M TO BRING UP THE PARAMETER REPLACEMENT DIALOG
-- 14. FILL IN ONLY THE VALUE FIELDS WITH YOUR REPLACEMENT VALUES
--	*** DO NOT HIT ENTER TILL THEY ARE ALL	***
--	*** FILLED IN. USE UP AND DOWN ARROWS	***
--	*** TO MOVE AND YOU CAN REPLACE ALL	***
--      *** VALUES IN ONE PASS			***
-- 15. PRESS "OK" TO APPLY THE REPLACEMENTS
------------------------------------------------------------------------------------				
-- TEMPLATE SECTION START	
------------------------------------------------------------------------------------				
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	-- KNOWN CONDITION: {Condition,,}
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	IF NOT EXISTS (SELECT VALUE FROM fn_listextendedproperty(NULL, 'SCHEMA', 'dbo', 'SYNONYM', 'FileScan_CurrentWorkTable', default, default) WHERE Value = @OwnerID)
		GOTO WorkTableNotOwned
	ELSE
	BEGIN
		PRINT '--Starting Condition: {Condition,,}'
		UPDATE	[dbo].[FilescanImport_CurrentWorkTable]
			SET	[KnownCondition] = '{Condition,,}'
				,[FixData] = REPLACE('{Param1,,}=%{Param1,,}%,{Param2,,}=%{Param2,,}%,{Param3,,}=%{Param3,,}%,{Param4,,}=%{Param4,,}%'
						,'%{Param1,,}%'
						,{ValueLogic1,,}
						),'%{Param2,,}%'
						,{ValueLogic2,,}
						),'%{Param3,,}%'
						,{ValueLogic3,,}
						),'%{Param4,,}%'
						,{ValueLogic4,,}
						)
				,[FixQuery] = NULL 
		WHERE	KnownCondition = 'Unknown'
		-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
		  AND	{FilterLogic,,}

	END 
	-- CONDITION END			
------------------------------------------------------------------------------------				
-- TEMPLATE SECTION END
------------------------------------------------------------------------------------				
*/

-- TEST QUERY
/*

  	     Select	[Message]
  			,REPLACE(RIGHT([Message],LEN([Message])-CHARINDEX('\\',[Message])+1),'.','')
  			--,REPLACE(REPLACE(LEFT(REPLACE(REPLACE(SUBSTRING([Message],CHARINDEX('BACKUP DATABASE',[Message])+16,CHARINDEX('Check',[Message]+'Check')-(CHARINDEX('BACKUP DATABASE',[Message])+16)),'WITH DIFFERENTIAL',''),'.',''),CHARINDEX('TO',REPLACE(REPLACE(SUBSTRING([Message],CHARINDEX('BACKUP DATABASE',[Message])+16,CHARINDEX('Check',[Message]+'Check')-(CHARINDEX('BACKUP DATABASE',[Message])+16)),'WITH DIFFERENTIAL',''),'.','')+'TO')-1),'[',''),']','')
			--,SUBSTRING([Message],CHARINDEX('SID for',[Message])+8,CHARINDEX('found in database',[Message])-(CHARINDEX('SID for',[Message])+9))
  			--,LEFT([Message],CHARINDEX(': Operating system error 112',[Message])-1)

-- USE THIS EXAMPLE TO EXTRACT WHEN A START AND STOP MARKER CAN BE IDENTIFIED (VALUE ALREADY HAS QUOTES)
--			,SUBSTRING	([Message]
--					,CHARINDEX('{StartMarker}',[Message])+{LengthOfStartMarker}+2
--					,CHARINDEX('{EndMarker}',[Message])-(CHARINDEX('{StartMarker}',[Message])+{LengthOfStartMarker}+4)
--					)

-- USE THIS EXAMPLE TO EXTRACT WHEN A START AND STOP MARKER CAN BE IDENTIFIED (VALUE DOES NOT HAVE QUOTES)
--			,SUBSTRING	([Message]
--					,CHARINDEX('{StartMarker}',[Message])+{LengthOfStartMarker}+1
--					,CHARINDEX('{EndMarker}',[Message])-(CHARINDEX('{StartMarker}',[Message])+{LengthOfStartMarker}+2)
--					)


-- USE THIS EXAMPLE TO EXTRACT WHEN A START MARKER CAN BE IDENTIFIED AND THE END IS THE END OF THE FIELD
--			,SUBSTRING	([Message]
--					,CHARINDEX('{StartMarker}',[Message])+{LengthOfStartMarker}+2
--					,LEN([Message])-(CHARINDEX('{StartMarker}',[Message])+{LengthOfStartMarker}+4)
--					)			
	     FROM	[dbaadmin].[dbo].[Filescan_History]
	     WHERE	KnownCondition = 'Unknown'
		-- THIS IS THE LOGIC TO IDENTIFY THE CONDITION
		  AND	[Message] Like '%DBA WARNING: Standard share could not be found%'



DBA WARNING: Standard share could not be found.  \\SEAFRESQLTALTST\SEAFRESQLTALTST_dba_mail.
DBA WARNING: Standard share could not be found.  \\SEAFRESQLTALTST\SEAFRESQLTALTST_ldf.

***Stack Dump being sent to E:\MSSQL.2\MSSQL\LOG\SQLDump0012.txt
SQL Server detected a logical consistency-based I/O error: incorrect pageid (expected 1:733; actual 34:524289). It occurred during a read of page (1:733) in database ID 5 at offset 0x000000005ba000 in file 'E:\MSSQL.2\MSSQL\DATA\dbaadmin.mdf'.  Additional messages in the SQL Server error log or system event log may provide more detail. This is a severe error condition that threatens database integrity and must be corrected immediately. Complete a full database consistency check (DBCC CHECKDB). This error can be caused by many factors; for more information, see SQL Server Books Online.
Error: 824, Severity: 24, State: 2. 


*/

