USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_SET_TOTAL]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@TOTAL	MONEY
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

		IF EXISTS(
				SELECT *
				FROM Subhost.SubhostCalcReport 
				WHERE SCR_ID_SUBHOST = @SH_ID
					AND SCR_ID_PERIOD = @PR_ID
			)
			RETURN

		UPDATE Subhost.SubhostCalc
		SET SHC_TOTAL = @TOTAL
		WHERE SHC_ID_SUBHOST = @SH_ID AND SHC_ID_PERIOD = @PR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Subhost.SubhostCalc(
					SHC_ID_SUBHOST, SHC_ID_PERIOD, SHC_TOTAL
				)
				VALUES(
					@SH_ID, @PR_ID, @TOTAL
					)
					
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_SET_TOTAL] TO rl_subhost_calc;
GO