
 
DECLARE @build_request_id INT
SET	@build_request_id = 

EXEC dbo.dpsp_Cancel_Gears @build_request_id
EXEC gears.dbo.CloneTicket @build_request_id,1 
EXEC dbo.dpsp_ImportGears


GO
DECLARE @build_request_id	INT
	,@rundate		VarChar(50)
	
SELECT	@build_request_id	= 
	,@rundate		= LEFT(REPLACE(CONVERT(varchar(50),getdate(),120),'-',''),14)

exec DEPLcontrol.dbo.dpsp_update @gears_id = @build_request_id
                                ,@start_dt = @rundate
                                
exec DEPLcontrol.dbo.dpsp_Approve @gears_id = @build_request_id
                                 ,@runtype = 'auto'
                                 ,@DBA_override = 'y'
                                 
                                 
                                 
                                 
