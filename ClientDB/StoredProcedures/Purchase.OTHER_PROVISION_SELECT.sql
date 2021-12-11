USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[OTHER_PROVISION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[OTHER_PROVISION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[OTHER_PROVISION_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
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

		SELECT OP_ID, OP_NAME, OP_SHORT
		FROM Purchase.OtherProvision
		WHERE @FILTER IS NULL
			OR OP_NAME LIKE @FILTER
			OR OP_SHORT LIKE @FILTER
		ORDER BY OP_SHORT, OP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[OTHER_PROVISION_SELECT] TO rl_other_provision_r;
GO
