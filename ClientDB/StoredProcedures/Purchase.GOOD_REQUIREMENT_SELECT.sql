USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[GOOD_REQUIREMENT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[GOOD_REQUIREMENT_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Purchase].[GOOD_REQUIREMENT_SELECT]
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

		SELECT GR_ID, GR_NAME, GR_SHORT
		FROM Purchase.GoodRequirement
		WHERE @FILTER IS NULL
			OR GR_NAME LIKE @FILTER
			OR GR_SHORT LIKE @FILTER
		ORDER BY GR_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[GOOD_REQUIREMENT_SELECT] TO rl_good_requirement_r;
GO
