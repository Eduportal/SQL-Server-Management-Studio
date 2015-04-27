SET NOCOUNT ON

DECLARE	@TimeTillTarget		Int
	,@TimeTillCL		Int
	,@CurrentSizeMB		Float
	,@CurrentLimit		Float
	,@OneYearForcastSizeMB	Float


exec dbasp_ChartData_DBGrowth 
			@DRiveLetter		= 'M'
			, @OutputAsHTML		= 0
			, @NoDataTable		= 0
			, @NoComments		= 0
			, @TimeTillTarget	= @TimeTillTarget	OUTPUT
			, @TimeTillCL		= @TimeTillCL		OUTPUT
			, @CurrentSizeMB	= @CurrentSizeMB	OUTPUT
			, @CurrentLimit		= @CurrentLimit		OUTPUT
			, @OneYearForcastSizeMB	= @OneYearForcastSizeMB	OUTPUT
			
			
SELECT	@TimeTillTarget		
	,@TimeTillCL		
	,@CurrentSizeMB		
	,@CurrentLimit		
	,@OneYearForcastSizeMB		
	
	
	
		