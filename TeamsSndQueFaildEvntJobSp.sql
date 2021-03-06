USE [EventServiceDb]
GO
/****** Object:  StoredProcedure [dbo].[TeamsSndQueFaildEvntJobSp]    Script Date: 8/27/2014 11:59:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[TeamsSndQueFaildEvntJobSp]
as
begin
	-- THIS PROCESSESS SHOULD BE MODIFIED
	-- http://rusanu.com/2006/04/06/fire-and-forget-good-for-the-military-but-not-for-service-broker-conversations/


	-- Suppress all "(xxx row(s) affected)" messages, and their empty recordsets:

		set nocount on
		set arithabort on

	declare @xml table (EventXml xml)
	insert into @xml
	select CAST(message_body AS XML) AS EventXml
	FROM [EditorialSiteDB].[dbo].[TeamsSndRcvLoPrtyQu] WITH(NOLOCK)
	where message_body is not null

	declare @EvntI int
	
	declare failed_event_cursor cursor for
	select	EvntI 
	from	EvntTb with (nolock)
	where	TeamsStatC = 'F'
	and		(TeamsErrT is null or (
						TeamsErrT != 'A call to the MediaEventUpdate action returned a status of Error. Check detail messages for more information.<br />Error: ASE-001: TEAMS Error : Invalid Event Id,<br />Error: TES-004: Failed To Update Event,<br />'
				and		TeamsErrT not like 'A call to the MediaEventUpdate action returned a status of Error. Check detail messages for more information.<br />Error: ASE-001: TEAMS Error : Bad controlled data: ''id 0%'
				and		TeamsErrT != 'A call to the MediaEventUpdate action returned a status of Error. Check detail messages for more information.<br />Error: ASE-001: TEAMS Error : Event Manager ID and TEAMS Event ID do not match,<br />Error: TES-004: Failed To Update Event,<br />'
				and		TeamsErrT != 'A call to the MediaEventUpdate action returned a status of Error. Check detail messages for more information.<br />Error: ASE-001: TEAMS Error : Event ID is shared by more than one event in TEAMS,<br />Error: TES-004: Failed To Update Event,<br />'
				)
			)
	and EvntI not in (select distinct T.Col.value('EventId[1]', 'int') as EvntI		-- Prevent duplicate failed events from getting requeued
					  from @xml x
					  cross apply x.EventXml.nodes('/SendToTeamsItem') as T(Col))


	open failed_event_cursor
	
	fetch next from		failed_event_cursor
	into				@EvntI
	
	while @@fetch_status = 0
	begin
	
		declare @DialogHandle uniqueidentifier
		
		begin transaction
		/*
		PLEASE NOTE: the below transaction moves records from the TeamsSndSndSv broker queue, which resides in the EventServiceDb,
					 to the TeamsSndRcvLoPrtySv broker queue, which resides in the EditorialSiteDb.
					 To enable such cross-DB transfer, make sure the TRUSTWORTHY flag is set on the EventServiceDb:
					 ALTER DATABASE EventServiceDb SET TRUSTWORTHY ON
		*/
		begin dialog @DialogHandle
		from service
			TeamsSndSndSv
		to service
			 'TeamsSndRcvLoPrtySv'
		on contract
			TeamsSndCn
		with
			encryption = off
			,lifetime = 600000; -- 1 WEEK (7 days)
			
		send on conversation @DialogHandle
				message type
				TeamsSndMt
				('<SendToTeamsItem><EventId>'+ convert(nvarchar(20), @EvntI) +'</EventId><UserName>TeamsFailedService</UserName><TeamsId>eintegration</TeamsId></SendToTeamsItem>');
			
		end conversation @DialogHandle --WITH CLEANUP
	 
		update EvntTb set TeamsStatC = 'X', TeamsErrT = null where EvntI= @EvntI
	 		
		commit transaction
		
		fetch next from		failed_event_cursor
		into				@EvntI

	end
	
	close failed_event_cursor
	deallocate failed_event_cursor
	
end