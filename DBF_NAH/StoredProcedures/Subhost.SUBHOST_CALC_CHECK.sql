USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_CALC_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_CALC_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_CHECK]
	@SH_ID	SMALLINT,
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

		SELECT PR_ID, Subhost.MinPrice(@SH_ID) AS MIN_PRICE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID
			AND PR_DATE >= '20111101'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_CHECK] TO rl_subhost_calc;
GO
