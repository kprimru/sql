USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[ACTION_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[ACTION_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[ACTION_UPDATE]
	@ID				UNIQUEIDENTIFIER,
	@NAME			NVARCHAR(128),
	@DELIVERY		SMALLINT,
	@SUPPORT		SMALLINT,
	@DELIVERY_FIXED	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE Price.Action
		SET NAME			=	@NAME,
			DELIVERY		=	@DELIVERY,
			SUPPORT			=	@SUPPORT,
			DELIVERY_FIXED	=	@DELIVERY_FIXED
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[ACTION_UPDATE] TO rl_action_u;
GO
