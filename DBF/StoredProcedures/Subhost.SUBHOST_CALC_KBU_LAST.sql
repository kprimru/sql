USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_KBU_LAST]
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
		FROM Subhost.SubhostKbuTable
		WHERE SK_ID_PERIOD = @PR_ID
			AND SK_ID_HOST = @SH_ID

		DELETE
		FROM Subhost.SubhostPriceSystemTable
		WHERE SPS_ID_PERIOD = @PR_ID
			AND SPS_ID_HOST = @SH_ID

		INSERT INTO Subhost.SubhostPriceSystemTable(SPS_ID_SYSTEM, SPS_ID_PERIOD, SPS_ID_HOST, SPS_ID_TYPE, SPS_PRICE, SPS_ACTIVE)
			SELECT SPS_ID_SYSTEM, @PR_ID, @SH_ID, SPS_ID_TYPE, SPS_PRICE, 1
			FROM Subhost.SubhostPriceSystemTable
			WHERE SPS_ID_HOST = @SH_ID
				AND SPS_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)

		INSERT INTO Subhost.SubhostKbuTable(SK_ID_PERIOD, SK_ID_HOST, SK_ID_SYSTEM, SK_KBU, SK_ACTIVE)
			SELECT @PR_ID, @SH_ID, SK_ID_SYSTEM, SK_KBU, 1
			FROM Subhost.SubhostKbuTable
			WHERE SK_ID_HOST = @SH_ID
				AND SK_ID_PERIOD = dbo.PERIOD_PREV(@PR_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_KBU_LAST] TO rl_subhost_calc;
GO