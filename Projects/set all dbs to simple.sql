exec sp_helpdb
GO
exec sp_msforeachdb 'if ''?'' != ''tempdb''
BEGIN
  DECLARE @TSQL VarChar(1000);
  SET @TSQL = ''ALTER DATABASE [?] SET RECOVERY SIMPLE WITH NO_WAIT'';
  EXEC (@TSQL);
END'
GO
exec sp_helpdb
GO