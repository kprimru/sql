USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_CALC_CONFIRM]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_CALC_CONFIRM]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_CALC_CONFIRM]
	@ID	UNIQUEIDENTIFIER
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

		UPDATE dbo.ActCalc
		SET CONFIRM_NEED = 0,
			CONFIRM_USER = ORIGINAL_LOGIN(),
			CONFIRM_DATE = GETDATE()
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
GRANT EXECUTE ON [dbo].[ACT_CALC_CONFIRM] TO rl_act_calc_confirm;
GO
