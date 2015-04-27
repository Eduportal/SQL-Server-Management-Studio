exec dpsp_status 58819


exec DEPLcontrol.dbo.dpsp_Approve @gears_id = 58819
                                 ,@runtype = 'auto'
                                 ,@DBA_override = 'y'
