INSERT INTO [gears].[dbo].[AUTO_Request]
           ([active]
           ,[Project_name]
           ,[Project_num]
           ,[Environment]
           ,[APPLlist]
           ,[request_notes]
           ,[run_sun]
           ,[run_mon]
           ,[run_tue]
           ,[run_wed]
           ,[run_thu]
           ,[run_fri]
           ,[run_sat]
           ,[restore_only]
           ,[restore_all]
           ,[start_date]
           ,[start_time])
     VALUES
           ('N'
           ,'Test'
           ,'0.0.1'
           ,'Test'
           ,'test'
           ,'test'
           ,'y'
           ,'y'
           ,'y'
           ,'y'
           ,'y'
           ,'y'
           ,'y'
           ,'y'
           ,'y'
           ,'1/1/2020'
           ,'05:02')
GO


update [AUTO_Request] SET [active] = 'y' WHERE AR_ID = 18 