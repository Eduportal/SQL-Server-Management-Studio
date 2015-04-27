DECLARE		@TimeTillCL				Int
			,@CurrentSizeMB			FLOAT
			,@CurrentLimit			FLOAT
			,@OneYearForcastSizeMB	FLOAT

EXEC	dbaperf.[dbo].[dbasp_ChartData_DBGrowth]
					@DriveLetter			='N'
					,@TimeTillCL			= @TimeTillCL OUTPUT
					,@CurrentSizeMB			= @CurrentSizeMB OUTPUT
					,@CurrentLimit			= @CurrentLimit OUTPUT
					,@NoDataTable			= 0
					,@OutputAsHTML			= 0
					,@NoComments			= 0
					,@OneYearForcastSizeMB	= @OneYearForcastSizeMB OUTPUT
					
SELECT		@TimeTillCL				[Weeks Till Full]
			,@CurrentSizeMB			[Current Size]
			,@CurrentLimit			[Current Limit]
			,@OneYearForcastSizeMB	[Size in one Year]					
			
			
GO

DECLARE		@TimeTillCL				Int
			,@CurrentSizeMB			FLOAT
			,@CurrentLimit			FLOAT
			,@OneYearForcastSizeMB	FLOAT

EXEC	dbaperf.[dbo].[dbasp_ChartData_DBGrowth]
					@DBName					='MessageQueue'
					,@TimeTillCL			= @TimeTillCL OUTPUT
					,@CurrentSizeMB			= @CurrentSizeMB OUTPUT
					,@CurrentLimit			= @CurrentLimit OUTPUT
					,@NoDataTable			= 0
					,@OutputAsHTML			= 0
					,@NoComments			= 0
					,@OneYearForcastSizeMB	= @OneYearForcastSizeMB OUTPUT
					
SELECT		@TimeTillCL				[Weeks Till Full]
			,@CurrentSizeMB			[Current Size]
			,@CurrentLimit			[Current Limit]
			,@OneYearForcastSizeMB	[Size in one Year]					
										