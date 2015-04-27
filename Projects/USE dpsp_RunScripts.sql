exec DEPLinfo.dbo.dpsp_RunScripts 
                 @script_path = '\\seascrmsql01\SEASCRMSQL01_backup\abc_scripts' --  Drive Letter Path or share to the source script Folder  
                ,@DBname = 'Getty_Images_US_Inc__MSCRM'  --  Database Name (optional) 
                ,@output_foldername = 'Gears_62110'      --  Output Foldername (optional) 


