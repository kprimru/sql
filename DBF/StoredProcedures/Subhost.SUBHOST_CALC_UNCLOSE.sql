USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_UNCLOSE]
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

		DELETE
		FROM Subhost.SubhostCalcReport
		WHERE SCR_ID_SUBHOST = @SH_ID
			AND SCR_ID_PERIOD = @PR_ID

		UPDATE Subhost.SubhostCalc
		SET SHC_CLOSED = 0
		WHERE SHC_ID_SUBHOST = @SH_ID
			AND SHC_ID_PERIOD = @PR_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_UNCLOSE] TO rl_subhost_calc;
GO