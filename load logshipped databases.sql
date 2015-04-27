


---- SEAPSQLEDWLOG01 DATABASE SETUPS REPLACING SEAPSQLLSHP01\SQL2K5
---- AMER DOMAIN : SQL2005
--:CONNECT SEAPSQLEDWLOG01.amer.gettywan.com

----exec dbaadmin.[dbo].[dbasp_dba_sqlsetup] 'G:\SQLFiles\MSSQL.MSSQLSERVER.Backup'

--	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Gins_integration'			,'FREPSQLRYLB01'	,NULL	,NULL	,0,1,1
--	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Gins_Master'				,'FREPSQLRYLB01'	,NULL	,NULL	,0,1,1
--GO


-- SEAPSQLEDWLOG02 DATABASE SETUPS REPLACING SEAPSQLLSHP01
-- AMER DOMAIN : SQL2008R2
:CONNECT SEAPSQLEDWLOG02.amer.gettywan.com

--exec dbaadmin.[dbo].[dbasp_dba_sqlsetup] 'G:\SQLFiles\MSSQL.MSSQLSERVER.Backup'

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_CRM_GENESYS'		,'SEAPCRMSQL1A'		,NULL	,NULL	,0,1,0

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc__MSCRM'		,'SEAPCRMSQL1A'		,NULL	,NULL	,0,1,0
--		,0,NULL,
--'<RestoreFileLocations>
--  <Override LogicalName="ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159" PhysicalName="D:\SQL\MSSQL10_50.MSSQLSERVER\MSSQL\FTData\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\ftrow_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM" PhysicalName="E:\Data\Getty_Images_US_Inc__MSCRM.mdf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Getty_Images_US_Inc__MSCRM.mdf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM_log" PhysicalName="F:\log\Getty_Images_US_Inc__MSCRM_log.LDF" New_PhysicalName="F:\SQLFiles\MSSQL.MSSQLSERVER.Log\Getty_Images_US_Inc__MSCRM_log.LDF" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM2" PhysicalName="m:\data\Getty_Images_US_Inc__MSCRM2.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Getty_Images_US_Inc__MSCRM2.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM3" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM3.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Getty_Images_US_Inc__MSCRM3.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM4" PhysicalName="H:\Data\Getty_Images_US_Inc__MSCRM4.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Getty_Images_US_Inc__MSCRM4.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM5" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM5.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Getty_Images_US_Inc__MSCRM5.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM6" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM6.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Getty_Images_US_Inc__MSCRM6.ndf" />
--  <Override LogicalName="Getty_Images_US_Inc__MSCRM7" PhysicalName="I:\Data\Getty_Images_US_Inc__MSCRM7.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Getty_Images_US_Inc__MSCRM7.ndf" />
--</RestoreFileLocations>'

	--EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc__MSCRM'		,'SEAPCRMSQL1A'		,'\\SEAPCRMSQL1A\SEAPCRMSQL1A_backup\','LSRestore_SEAPCRMSQL1A_Getty_Images_US_Inc__MSCRM',0,1,1

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Images_US_Inc_Custom'		,'SEAPCRMSQL1A'		,NULL	,NULL	,0,1,0
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'RM_Integration'			,'SEAPSQLRYL0A'		,NULL	,NULL	,0,1,0
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Getty_Master'				,'SEAPSQLRYL0A'		,NULL	,NULL	,0,1,0
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Subscription'				,'SEAPSQLRYLINT02'	,NULL	,NULL	,0,1,0

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Gins_integration'			,'SEAPSQLRYL0B'		,NULL	,NULL	,0,1,0
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Gins_Master'				,'SEAPSQLRYL0B'		,NULL	,NULL	,1,1,0
		,0,NULL,
'<RestoreFileLocations>
  <Override LogicalName="dv_installapplData" PhysicalName="E:\Data\gins_prod.mdf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\gins_prod.mdf" />
  <Override LogicalName="dv_installapplData02" PhysicalName="L:\Data\dv_installapplData02.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\dv_installapplData02.ndf" />
  <Override LogicalName="gins_master03" PhysicalName="L:\Data\gins_master03.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\gins_master03.ndf" />
  <Override LogicalName="gins_master04" PhysicalName="I:\Data\gins_master04.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\gins_master04.ndf" />
  <Override LogicalName="gins_master06" PhysicalName="L:\Data\gins_master06.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\gins_master06.ndf" />
  <Override LogicalName="gins_master07" PhysicalName="E:\Data\gins_master07.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\gins_master07.ndf" />
  <Override LogicalName="gins_master08" PhysicalName="I:\data\gins_master08.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\gins_master08.ndf" />
  <Override LogicalName="gins_master09" PhysicalName="L:\data\gins_master09.ndf" New_PhysicalName="E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\gins_master09.ndf" />
  <Override LogicalName="lg_installapplLog" PhysicalName="F:\log\gins_prod_log.ldf" New_PhysicalName="F:\SQLFiles\MSSQL.MSSQLSERVER.Log\gins_prod_log.ldf" />
  <Override LogicalName="lg_installapplLog2" PhysicalName="F:\Log\lg_installapplLog2.ldf" New_PhysicalName="F:\SQLFiles\MSSQL.MSSQLSERVER.Log\lg_installapplLog2.ldf" />
  <Override LogicalName="lg_installapplLog3" PhysicalName="E:\log\lg_installapplLog3.ldf" New_PhysicalName="F:\SQLFiles\MSSQL.MSSQLSERVER.Log\lg_installapplLog3.ldf" />
  <Override LogicalName="lg_installapplLog4" PhysicalName="E:\log\lg_installapplLog4.ldf" New_PhysicalName="F:\SQLFiles\MSSQL.MSSQLSERVER.Log\lg_installapplLog4.ldf" />
  <Override LogicalName="lg_installapplLog5" PhysicalName="E:\log\lg_installapplLog5.ldf" New_PhysicalName="F:\SQLFiles\MSSQL.MSSQLSERVER.Log\lg_installapplLog5.ldf" />
</RestoreFileLocations>'



GO


-- SEAPSQLEDWLOG03 DATABASE SETUPS REPLACING SEAPSQLLSHP01\SQL2012ENT
-- AMER DOMAIN : SQL2012
:CONNECT SEAPSQLEDWLOG03.amer.gettywan.com

--exec dbaadmin.[dbo].[dbasp_dba_sqlsetup] 'G:\SQLFiles\MSSQL.MSSQLSERVER.Backup'

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'DeliveryDB'				,'SQLDISTG0A'		,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'DeliveryArchiveDB'			,'SQLDISTG0A'		,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'EditorialSiteDB'			,'EDSQLG0A'		,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'EventServiceDB'			,'EDSQLG0A'		,NULL	,NULL	,0,1,1
GO



-- SEAPSQLEDWLOG04 DATABASE SETUPS REPLACING SEAPLOGSQL01
-- PRODUCTION DOMAIN : SQL2008R2 
:CONNECT SEAPSQLEDWLOG04.production.local 

--exec dbaadmin.[dbo].[dbasp_dba_sqlsetup] 'G:\SQLFiles\MSSQL.MSSQLSERVER.Backup'

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'AssetUsage_Archive'			,'G1SQLB\B'		,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'DeliveryLog'				,'SEAPSCFWSQLA\A'	,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'Product'				,'G1SQLB\B'		,NULL	,NULL	,0,1,1
--	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ReportServer'				,'SEAPSQLRYLINT02'	,NULL	,NULL	,0,1,1
--	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ReportServerTempDB'			,'SEAPSQLRYLINT02'	,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'RightsPrice'				,'G1SQLB\B'		,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'WCDS'					,'G1SQLA\A'		,NULL	,NULL	,0,1,1
	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'WCDSwork'				,'G1SQLA\A'		,NULL	,NULL	,0,1,1
GO


-- SEAPSQLEDWLOG05 DATABASE SETUPS REPLACING SEAPLOGSQL01\A
-- PRODUCTION DOMAIN : SQL2012
:CONNECT SEAPSQLEDWLOG05.production.local

--exec dbaadmin.[dbo].[dbasp_dba_sqlsetup] 'G:\SQLFiles\MSSQL.MSSQLSERVER.Backup'

	EXEC dbaadmin.dbo.dbasp_Logship_MS_Fix_2 'ContributorSystemsContract'		,'SEAPCTBSQLA'		,NULL	,NULL	,0,1,1
GO



INSERT INTO	[DBAAdmin].[dbo].[Local_Control]

SELECT		'restore_override','Gins_Master','dv_installapplData',	'E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\' UNION ALL
SELECT		'restore_override','Gins_Master','dv_installapplData02','E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\' UNION ALL
SELECT		'restore_override','Gins_Master','gins_master03',	'E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\' UNION ALL
SELECT		'restore_override','Gins_Master','gins_master04',	'E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\' UNION ALL
SELECT		'restore_override','Gins_Master','gins_master06',	'E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\' UNION ALL
SELECT		'restore_override','Gins_Master','gins_master07',	'E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\' UNION ALL
SELECT		'restore_override','Gins_Master','gins_master08',	'E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\' UNION ALL
SELECT		'restore_override','Gins_Master','gins_master09',	'E:\SQLFiles\MSSQL.MSSQLSERVER.Data\Gins_Master\'
