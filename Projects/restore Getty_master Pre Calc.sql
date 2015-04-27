







DECLARE @Restore_cmd nvarchar(max)

EXEC [dbaadmin].[dbo].[dbasp_format_BackupRestore] 
               @DBName = 'Getty_master'
              ,@NewDBName = 'Getty_master'
              ,@Mode = 'RD' 
              ,@FilePath = '\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\'
              ,@FullReset = 1 
	      ,@IgnoreSpaceLimits = 1
              ,@OverrideXML =
              '<RestoreFileLocations>
		  <Override LogicalName="dv_installappData03" PhysicalName="J:\Data\dv_installappData03.ndf" New_PhysicalName="G:\Data\dv_installappData03.ndf" />
		  <Override LogicalName="dv_installappData04" PhysicalName="H:\Data\dv_installappData04.ndf" New_PhysicalName="G:\Data\dv_installappData04.ndf" />
		  <Override LogicalName="dv_installappData2"  PhysicalName="E:\Data\getty_master_1.NDF"      New_PhysicalName="E:\Data\getty_master_1.NDF" />
		  <Override LogicalName="dv_installapplData"  PhysicalName="E:\Data\getty_master.MDF"        New_PhysicalName="E:\Data\getty_master.MDF" />
		  <Override LogicalName="getty_master05"      PhysicalName="E:\Data\getty_master05.ndf"      New_PhysicalName="G:\Data\getty_master05.ndf" />
		  <Override LogicalName="getty_master06"      PhysicalName="J:\Data\getty_master06.ndf"      New_PhysicalName="I:\Data\getty_master06.ndf" />
		  <Override LogicalName="lg_installapplLog"   PhysicalName="F:\Log\getty_master_log.LDF"     New_PhysicalName="F:\Log\getty_master_log.LDF" />
		</RestoreFileLocations>'
              ,@syntax_out = @Restore_cmd OUTPUT 

exec dbaadmin.dbo.dbasp_PrintLarge @Restore_cmd
GO






EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Getty_Master'
GO
USE [master]
GO
ALTER DATABASE [Getty_Master] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
DROP DATABASE [Getty_Master]
GO
Exec master.dbo.sqlbackup '-SQL "RESTORE DATABASE [Getty_master] FROM DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_01_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_02_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_03_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_04_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_05_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_06_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_07_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_08_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_09_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_10_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_11_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_12_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_13_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_14_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_15_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_16_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_17_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_18_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_19_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_20_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_21_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_22_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_23_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_24_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_25_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_26_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_27_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_28_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_29_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_30_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_31_OF_32.SQB'' ,DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DB_20140310161412_SET_32_OF_32.SQB'' WITH NORECOVERY, REPLACE   ,MOVE ''dv_installapplData'' TO ''E:\Data\getty_master.MDF''   ,MOVE ''dv_installappData2'' TO ''E:\Data\getty_master_1.NDF''   ,MOVE ''dv_installappData04'' TO ''G:\Data\dv_installappData04.ndf''   ,MOVE ''dv_installappData03'' TO ''G:\Data\dv_installappData03.ndf''   ,MOVE ''getty_master05'' TO ''G:\Data\getty_master05.ndf''   ,MOVE ''getty_master06'' TO ''I:\Data\getty_master06.ndf''   ,MOVE ''lg_installapplLog'' TO ''F:\Log\getty_master_log.LDF''"'
Exec master.dbo.sqlbackup '-SQL "RESTORE DATABASE [Getty_master] FROM DISK = ''\\Frepsqlryla01\FREPSQLRYLA01_backup\pre_calc\GETTY_MASTER_DFNTL_20140310161412.SQD'' WITH NORECOVERY, REPLACE "'
RESTORE DATABASE [Getty_master] WITH RECOVERY

