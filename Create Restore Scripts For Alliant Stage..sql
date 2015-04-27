DECLARE	@OverrideXML		XML		
	,@syntax_out		VarChar(max)	

SET	@OverrideXML		=
'<RestoreFileLocations>
  <Override LogicalName="dv_installappData03"	PhysicalName="E:\Data4\Getty_Master_3.ndf"	New_PhysicalName="E:\Data2\Getty_Master_3.ndf" />
  <Override LogicalName="dv_installappData04"	PhysicalName="I:\Data\Getty_Master_2.ndf"	New_PhysicalName="E:\Data4\Getty_Master_2.ndf" />
  <Override LogicalName="dv_installappData2"	PhysicalName="E:\Data3\Getty_Master_1.NDF"	New_PhysicalName="E:\Data3\Getty_Master_1.NDF" />
  <Override LogicalName="dv_installapplData"	PhysicalName="E:\Data2\Getty_Master.MDF"	New_PhysicalName="E:\Data4\Getty_Master.MDF" />
  <Override LogicalName="getty_master05"	PhysicalName="E:\Data2\Getty_Master_4.ndf"	New_PhysicalName="E:\Data3\Getty_Master_4.ndf" />
  <Override LogicalName="getty_master06"	PhysicalName="I:\Data\Getty_Master_5.ndf"	New_PhysicalName="E:\Data5\Getty_Master_5.ndf" />
  <Override LogicalName="lg_installapplLog"	PhysicalName="F:\Log\Getty_Master_6.LDF"	New_PhysicalName="F:\Log\Getty_Master_6.LDF" />
</RestoreFileLocations>'

EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= 'Getty_Master' 
		,@FilePath		= '\\SEAPSQLRYL0A\post_calc'
		,@Mode			= 'RD' 
		,@Verbose		= -1
		,@FullReset             = 1
		,@IgnoreSpaceLimits	= 1
		,@NoDifRestores		= 0
		,@LeaveNORECOVERY	= 0
		,@UseGO			= 1
		,@syntax_out		= @syntax_out		OUTPUT
		,@OverrideXML		= @OverrideXML		OUTPUT


SET	@OverrideXML		=
'<RestoreFileLocations>
  <Override LogicalName="ContractMaintenanceControl_1_Log"	PhysicalName="F:\log\ContractMaintenanceControl_Log2"		New_PhysicalName="F:\Log\ContractMaintenanceControl_Log2" />
  <Override LogicalName="ContractMaintenanceControl_Data"	PhysicalName="E:\Data2\ContractMaintenanceControl_Data.MDF"	New_PhysicalName="E:\Data2\ContractMaintenanceControl_Data.MDF" />
  <Override LogicalName="ContractMaintenanceControl_Log"	PhysicalName="F:\log\ContractMaintenanceControl_log.LDF"	New_PhysicalName="F:\Log\ContractMaintenanceControl_log.LDF" />
</RestoreFileLocations>'

EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= 'ContractMaintenanceControl' 
		,@FilePath		= '\\SEAPSQLRYL0A\post_calc'
		,@Mode			= 'RD' 
		,@Verbose		= -1
		,@FullReset             = 1
		,@IgnoreSpaceLimits	= 1
		,@NoDifRestores		= 0
		,@LeaveNORECOVERY	= 0
		,@UseGO			= 1
		,@syntax_out		= @syntax_out		OUTPUT
		,@OverrideXML		= @OverrideXML		OUTPUT


SET	@OverrideXML		=
'<RestoreFileLocations>
  <Override LogicalName="rm_integration_dat" PhysicalName="E:\Data3\rm_integration_dat.mdf"	New_PhysicalName="E:\Data2\rm_integration_dat.mdf" />
  <Override LogicalName="rm_integration_log" PhysicalName="F:\log\rm_integration_log.ldf"	New_PhysicalName="F:\Log\rm_integration_log.ldf" />
</RestoreFileLocations>'

EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
		@DBName			= 'RM_Integration' 
		,@FilePath		= '\\SEAPSQLRYL0A\post_calc'
		,@Mode			= 'RD' 
		,@Verbose		= -1
		,@FullReset             = 1
		,@IgnoreSpaceLimits	= 1
		,@NoDifRestores		= 0
		,@LeaveNORECOVERY	= 0
		,@UseGO			= 1
		,@syntax_out		= @syntax_out		OUTPUT
		,@OverrideXML		= @OverrideXML		OUTPUT

exec dbaadmin.dbo.dbasp_PrintLarge @syntax_out 
GO


-- CREATE SAVE DATABASES TO GO BACK TO AFTER EACH TEST.

--DECLARE	@OverrideXML		XML		
--	,@syntax_out		VarChar(max)	

--EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
--		@DBName			= 'Getty_Master' 
--		,@FilePath		= '\\SEAPSQLRYL0A\save'
--		,@Mode			= 'BF' 
--		,@Verbose		= -1
--		,@FullReset             = 1
--		,@IgnoreSpaceLimits	= 1
--		,@NoDifRestores		= 0
--		,@LeaveNORECOVERY	= 0
--		,@UseGO			= 1
--		,@syntax_out		= @syntax_out		OUTPUT
--		,@OverrideXML		= @OverrideXML		OUTPUT


--EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
--		@DBName			= 'ContractMaintenanceControl' 
--		,@FilePath		= '\\SEAPSQLRYL0A\save'
--		,@Mode			= 'BF' 
--		,@Verbose		= -1
--		,@FullReset             = 1
--		,@IgnoreSpaceLimits	= 1
--		,@NoDifRestores		= 0
--		,@LeaveNORECOVERY	= 0
--		,@UseGO			= 1
--		,@syntax_out		= @syntax_out		OUTPUT
--		,@OverrideXML		= @OverrideXML		OUTPUT


--EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
--		@DBName			= 'RM_Integration' 
--		,@FilePath		= '\\SEAPSQLRYL0A\save'
--		,@Mode			= 'BF' 
--		,@Verbose		= -1
--		,@FullReset             = 1
--		,@IgnoreSpaceLimits	= 1
--		,@NoDifRestores		= 0
--		,@LeaveNORECOVERY	= 0
--		,@UseGO			= 1
--		,@syntax_out		= @syntax_out		OUTPUT
--		,@OverrideXML		= @OverrideXML		OUTPUT

--exec dbaadmin.dbo.dbasp_PrintLarge @syntax_out 
--GO


