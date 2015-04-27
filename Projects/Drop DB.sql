If Not Exists (SELECT * FROM [DEPLinfo].[dbo].[enviro_info] WHERE env_type = 'ENVnum' AND [env_name] = 'production')
BEGIN
 PRINT @@ServerName + ' Drop DB'
 ALTER DATABASE [DataExtract] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
 DROP DATABASE [DataExtract]
END 
ELSE
 PRINT @@ServerName + ' Dont Drop DB' 
