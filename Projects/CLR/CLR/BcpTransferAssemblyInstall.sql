if exists (select * from sys.assemblies where name = 'BcpTransfer')
BEGIN

	/*Drop T-SQL wrapper procedures and functions
		that depend on CLR objects*/
	if exists (select * from sysobjects
           where  id = object_id('Bcp.Transfer')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.Transfer')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.Export')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.Export')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.DirectoryInfo'))
   exec ('drop function Bcp.DirectoryInfo')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ComputeHash')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ComputeHash')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.WriteFile')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.WriteFile')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.Copy')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.Copy')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.[Delete]')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.[Delete]')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.Import')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.Import')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ReadFile')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ReadFile')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.Cleanup')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.Cleanup')
   
   
   /* Drop CLR procedures and functions */
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrTransfer')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrTransfer')
	
	if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrExport')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrExport')

   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrDirectoryInfo'))
   exec ('drop function Bcp.ClrDirectoryInfo')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrComputeHash')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrComputeHash')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrWriteFile')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrWriteFile')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.Clr')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.Clr')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrCopy')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrCopy')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrDelete')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrDelete')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrImport')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrImport')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrReadFile')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrReadFile')
   
   if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrCleanup')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('drop procedure Bcp.ClrCleanup')
   
   /* Finally, drop the actual CLR assembly */
   
	DROP ASSEMBLY BcpTransfer
END

CREATE ASSEMBLY BcpTransfer
AUTHORIZATION [dbo]
FROM '--AssemblyLocation'
WITH PERMISSION_SET = UNSAFE;