DECLARE @GearsID		INT
SET		@GearsID		= 58897

exec DEPLcontrol.dbo.dpsp_status @GearsID

--exec DEPLcontrol.dbo.dpsp_Approve @gears_id = @GearsID
--                                 ,@runtype = 'manual'
--                                 ,@DBA_override = 'y'

--exec DEPLcontrol.dbo.dpsp_status @GearsID

--exec DEPLcontrol.dbo.dpsp_Script_PreRelease @gears_id = @GearsID

--exec DEPLcontrol.dbo.dpsp_ManualStart @gears_id = @GearsID, @SQLname = 'ScriptAll'







