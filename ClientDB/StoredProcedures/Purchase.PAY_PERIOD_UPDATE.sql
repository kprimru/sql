USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[PAY_PERIOD_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[PAY_PERIOD_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[PAY_PERIOD_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(500),
	@SHORT	VARCHAR(100)
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

		UPDATE Purchase.PayPeriod
		SET PP_NAME		=	@NAME,
			PP_SHORT	=	@SHORT
		WHERE PP_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[PAY_PERIOD_UPDATE] TO rl_pay_period_u;
GO
