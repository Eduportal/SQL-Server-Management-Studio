if not exists (select * from sysobjects
           where  id = object_id('Bcp.ComputeHash')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.ComputeHash as return')
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
ALTER PROCEDURE Bcp.ComputeHash
	@FileLocation nvarchar(4000),
	@ProcessGUID uniqueidentifier=null,
	@HashValue uniqueidentifier output
AS
/*
<DbDoc>
	<object
description="Compute the MD5 hash of a file."
		>
		<parameters>
			<parameter name="@FileLocation" description="The location of the file to compute a hash for."/>
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid(). Used for Evt logging."/>
			<parameter name="@HashValue" description="Outputs the MD5 hash value of the file as a GUID (32-byte hex value)" />
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @UsesEvtLogging bit,
			@DoesExtendedLogging bit,
			@EDef xml

	SET @UsesEvtLogging=coalesce(@UsesEvtLogging, Cfg.GetBit('BcpTransfer', 'UseEvtLogging'));
	SET @ProcessGUID=coalesce(@ProcessGUID, newid());
	SET @DoesExtendedLogging=coalesce(@DoesExtendedLogging, Cfg.GetBit('BcpTransfer', 'DoesExtendedLogging'));
	SET @EDef=(
			select
				@FileLocation as [@file-location]
				,@DoesExtendedLogging as [@does-extended-logging]
			for xml path ('parameter')
			)
	
	if @UsesEvtLogging=1
	begin
		exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_HASH'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.ComputeHash'
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
	end

    EXECUTE Bcp.ClrComputeHash
    @FileLocation=@FileLocation,
	@UsesEvtLogging=@UsesEvtLogging,
	@DoesExtendedLogging=@DoesExtendedLogging,
	@ProcessGUID=@ProcessGUID,
	@HashValue=@HashValue output
	
	
	if @UsesEvtLogging=1
	begin
		set @EDef=(
				select
					@FileLocation as [@file-location]
					,@DoesExtendedLogging as [@does-extended-logging]
					,@HashValue as [@hash-guid]
				for xml path ('parameter')
				)
	
		exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_HASH'
		,@TypeKeyword='EVT_INFO'
		,@ModuleName='Bcp.ComputeHash'
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
	end
  
END
go

exec DbDoc.ObjectParse @ObjectName=ComputeHash, @SchemaName=Bcp
go