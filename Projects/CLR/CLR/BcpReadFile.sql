if not exists (select * from sysobjects
           where  id = object_id('Bcp.ReadFile')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.ReadFile as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- Create date: 2007-12-12
-- Description:	Stored procedure that 
-- =============================================
ALTER PROCEDURE Bcp.ReadFile
	@FileLocation nvarchar(4000),
	@FileContent nvarchar(max) output,
	@ProcessGUID uniqueidentifier=null
AS
/*
<DbDoc>
	<object
description="Compute the MD5 hash of a file."
		>
		<parameters>
			<parameter name="@FileLocation" description="The location of the file to read from."/>
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid(). Used for Evt logging."/>
			<parameter name="@FileContent" description="Outputs the contents of the file" />
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @DoesExtendedLogging bit,
			@EDef xml

	SET @ProcessGUID=coalesce(@ProcessGUID, newid());
	SET @DoesExtendedLogging=coalesce(@DoesExtendedLogging, Cfg.GetBit('BcpTransfer', 'DoesExtendedLogging'));
	SET @EDef=(
			select
				@FileLocation as [@file-location]
			for xml path ('parameter')
			)
	
	exec Evt.MessageHandle
	@MessageSpaceKeyword='EVT_BCP'
	,@MessageKeyword='EVT_READFILE'
	,@TypeKeyword='EVT_START'
	,@ModuleName='Bcp.ReadFile'
	,@ProcessGUID=@ProcessGUID
	,@AdHocDefinition=@EDef

    EXECUTE Bcp.ClrReadFile
    @FileLocation=@FileLocation,
	@ProcessGUID=@ProcessGUID,
	@FileContent=@FileContent output
	

	exec Evt.MessageHandle
	@MessageSpaceKeyword='EVT_BCP'
	,@MessageKeyword='EVT_READFILE'
	,@TypeKeyword='EVT_SUCCESS'
	,@ModuleName='Bcp.ReadFile'
	,@ProcessGUID=@ProcessGUID
	,@AdHocDefinition=@EDef
  
END
go

exec DbDoc.ObjectParse @ObjectName=ReadFile, @SchemaName=Bcp
go