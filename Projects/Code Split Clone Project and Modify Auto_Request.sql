-- CLONE PROJECT

EXECUTE [gears].[dbo].[clone_project] 
   @project_name = 'WEaD'
  ,@project_version = '13.5'
  ,@add_project = 1

GO

-- MODIFY [AUTO_Request]

SELECT *
  FROM [gears].[dbo].[AUTO_Request]
  
  
UPDATE [gears].[dbo].[AUTO_Request]
   SET [Project_num] = '13.5'
 WHERE [Project_num] = '13.4'
GO


SELECT *
  FROM [gears].[dbo].[AUTO_Request]






















