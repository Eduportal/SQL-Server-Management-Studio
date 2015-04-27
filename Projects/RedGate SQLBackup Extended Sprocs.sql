USE [master]
GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbdata]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbdata]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbdata', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbdir]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbdir]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbdir', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbmemory]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbmemory]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbmemory', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbstatus]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbstatus]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbstatus', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbtest]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbtest]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbtest', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbtestcancel]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbtestcancel]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbtestcancel', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbteststatus]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbteststatus]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbteststatus', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqbutility]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqbutility]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqbutility', 'xp_sqlbackup.dll'

GO

/****** Object:  ExtendedStoredProcedure [dbo].[sqlbackup]    Script Date: 05/18/2010 12:30:22 ******/
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sqlbackup]') AND OBJECTPROPERTY(id,N'IsExtendedProc') = 1)
EXEC dbo.sp_addextendedproc N'sqlbackup', 'xp_sqlbackup.dll'

GO


