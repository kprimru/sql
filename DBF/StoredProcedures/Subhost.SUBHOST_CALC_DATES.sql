USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_DATES]
	@PR_ID	SMALLINT,
	@DATE	SMALLDATETIME
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

		UPDATE Subhost.SubhostCalcDates
		SET SCD_DATE	=	@DATE
		WHERE SCD_ID_PERIOD = @PR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Subhost.SubhostCalcDates(SCD_ID_PERIOD, SCD_DATE)
				VALUES(@PR_ID, @DATE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_DATES] TO rl_subhost_calc;
GO
