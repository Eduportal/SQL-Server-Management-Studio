USE  [<Database Name,,xxDBNAMExx>]
GO
IF OBJECT_ID('<Schema Name,,dbo>.<Procedure Name,,dbasp_>') IS NOT NULL
	DROP PROCEDURE [<Schema Name,,dbo>].[<Procedure Name,,dbasp_>]
GO
CREATE PROCEDURE [<Schema Name,,dbo>].[<Procedure Name,,dbasp_>]
	(
	<Param1 Name,,@Param1Name>	<Param1 Type,,VarChar(max)> <Param1 Default,,= 'xxx'>
	<Param2 Name,,@Param2Name>	<Param2 Type,,VarChar(max)> <Param2 Default,,= 'xxx'>
	<Param3 Name,,@Param3Name>	<Param3 Type,,VarChar(max)> <Param3 Default,,= 'xxx'>
	)
AS
--#region DOCUMENTATION HEADDER
/****************************************************************************
--
-- REMINDER: REPLACE ALL "[[' WITH "<" AFTER PARAMETER REPLACEMENT CTL-SHIFT-M
--
<CommentHeader>
	<VersionControl>
 		[[DatabaseName><Database Name,,xxDBNAMExx></DatabaseName>				
		[[SchemaName><Schema Name,,dbo></SchemaName>
		<ObjectType>Procedure</ObjectType>
		[[ObjectName><Procedure Name,,dbasp_></ObjectName>
		<Version>1.0.0</Version>
		<Build Number="" Application="" Branch=""/>
		<Created By="" On=""/>
		<Modifications>
			<Mod By="" On="" Reason=""/>
			<Mod By="" On="" Reason=""/>
		</Modifications>
	</VersionControl>
	<Purpose></Purpose>
	<Description></Description>
	<Dependencies>
		<Object Type="" Schema="" Name="" VersionCompare="" Version=""/>
	</Dependencies>
	<Parameters>
		[[Parameter Type="<Param1 Type,,VarChar(max)>"	Name="<Param1 Name,,@Param1Name>"				Desc=""/>
		[[Parameter Type="<Param2 Type,,VarChar(max)>"	Name="<Param2 Name,,@Param2Name>"				Desc=""/>
		[[Parameter Type="<Param3 Type,,VarChar(max)>"	Name="<Param3 Name,,@Param3Name>"				Desc=""/>
	</Parameters>
	<Permissions>
		<Perm Type="" Priv="" To="" With=""/>
	</Permissions>
</CommentHeader>
*****************************************************************************/
--#endregion
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET XACT_ABORT ON;
BEGIN
	DECLARE @trancount int;
	SET @trancount = @@trancount;
	BEGIN TRY
		if @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION <Procedure Name,,dbasp_>;
		-- Do the actual work here






		-- End of Actual Work	
lbexit:
		if @trancount = 0	
			COMMIT;
	END TRY
	BEGIN CATCH
		DECLARE @error int, @message varchar(4000), @xstate int;
		SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
		IF @xstate = -1
			ROLLBACK;
		IF @xstate = 1 and @trancount = 0
			ROLLBACK
		IF @xstate = 1 and @trancount > 0
			ROLLBACK TRANSACTION <Procedure Name,,dbasp_>;

		RAISERROR ('<Procedure Name,,dbasp_>: %d: %s', 16, 1, @error, @message) ;
	END CATCH	
END
GO



