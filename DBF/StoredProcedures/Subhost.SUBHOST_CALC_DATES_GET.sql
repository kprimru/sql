USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_CALC_DATES_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_CALC_DATES_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_DATES_GET]
	@PR_ID	SMALLINT
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

		SELECT SCD_DATE
		FROM Subhost.SubhostCalcDates
		WHERE SCD_ID_PERIOD = @PR_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_DATES_GET] TO rl_subhost_calc;
GO
