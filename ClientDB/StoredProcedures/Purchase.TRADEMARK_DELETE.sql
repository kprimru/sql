USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[TRADEMARK_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[TRADEMARK_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[TRADEMARK_DELETE]
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

		DELETE
		FROM Purchase.ClientConditionTrademark
		WHERE CCT_ID_TM = @ID

		DELETE
		FROM Purchase.Trademark
		WHERE TM_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[TRADEMARK_DELETE] TO rl_trademark_d;
GO
