USE [dbaperf]
GO
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbasp_GetMonitorHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbasp_GetMonitorHistory]
GO


create procedure dbo.dbasp_GetMonitorHistory
as
/*******************************************************************************************************
*	dbaperf.dbo.dbasp_GetMonitorHistory
*
*	Outline:	Sample the current System Statistical Functions values into  a tracking table
*			
*	usage:
	   EXECUTE dbaperf.dbo.dbasp_GetMonitorHistory

*	Notes: simulate sp_monitor captuire, but use the system functions 
*               instead of sp_monitor to avoid data type overflow errors
*			
*	Modifications   
*	 name		   date		  description
*	-------		----------	------------------------------------------------------------
*	Steve Ledridge	09/10/2013	New Procedure
********************************************************************************************************/
set nocount on

if object_id('dbaperf.dbo.MonitorHistory','U') is null
BEGIN 
	create table	dbaperf.dbo.MonitorHistory 
			( 
			id int identity(1,1)
			, lastrun datetime not null
			, cpu_busy bigint not null 
			, io_busy bigint not null 
			, idle bigint not null
			, pack_received bigint not null
			, pack_sent bigint not null
			, connections bigint not null
			, pack_errors bigint not null 
			, total_read bigint not null 
			, total_write bigint not null
			, total_errors bigint not null 
			constraint pkc_MonitorHistory__id primary key (id)
			) 

	CREATE NONCLUSTERED INDEX	[_dta_index_MonitorHistory_11_1679409848__K2_K1_3_4_5_6_7_8_9_10_11_12] ON [dbo].[MonitorHistory]
					(
					[lastrun] ASC,
					[id] ASC
					)
			INCLUDE		(
			 		[cpu_busy],
					[io_busy],
					[idle],
					[pack_received],
					[pack_sent],
					[connections],
					[pack_errors],
					[total_read],
					[total_write],
					[total_errors]
					)

END
	insert		dbaperf.dbo.MonitorHistory 
			(
			lastrun
			, cpu_busy
			, io_busy 
			, idle
			, pack_received
			, pack_sent
			, connections
			, pack_errors 
			, total_read 
			, total_write
			, total_errors
			) 
	values		(
			getdate()
			, @@cpu_busy
			, @@io_busy
			, @@idle
			, @@pack_received
			, @@pack_sent
			, @@connections
			, @@packet_errors
			, @@total_read
			, @@total_write
			, @@total_errors
			)    

GO
