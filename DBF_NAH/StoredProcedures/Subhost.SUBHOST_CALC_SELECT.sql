USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_SELECT]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@LAST	BIT	=	NULL OUTPUT
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

		IF (@LAST = 1) AND
			NOT EXISTS(
				SELECT *
				FROM Subhost.SubhostCalc
				WHERE SHC_ID_SUBHOST = @SH_ID
					AND SHC_ID_PERIOD = @PR_ID
				)
			SET @PR_ID = dbo.PERIOD_PREV(@PR_ID)
		ELSE
			SET @LAST = 0

		SELECT
			TX_TOTAL_RATE,
			SHC_ID, SH_CALC_STUDY, SH_CALC_SYSTEM,
			SH_FULL_NAME, SH_SHORT_NAME,
			SHC_DELIVERY,
			SHC_PAPPER_COUNT, SHC_PAPPER_PRICE,
			SHC_TRAFFIC,
			(
				SELECT SUM(SS_COUNT * SLP_PRICE)
				FROM
					Subhost.SubhostStudy a INNER JOIN
					Subhost.SubhostLessonPrice b ON a.SS_ID_PERIOD = b.SLP_ID_PERIOD
										AND SS_ID_LESSON = SLP_ID_LESSON
				WHERE SLP_ID_PERIOD = @PR_ID AND SS_ID_SUBHOST = @SH_ID
			) AS SHC_SEMINAR,
			(
				SELECT SUM(SPC_COUNT * SPP_PRICE)
				FROM
					Subhost.SubhostProductPrice INNER JOIN
					Subhost.SubhostProductCalc ON SPC_ID_PERIOD = SPP_ID_PERIOD
										AND SPP_ID_PRODUCT = SPC_ID_PROD INNER JOIN
					Subhost.SubhostProduct ON SP_ID = SPP_ID_PRODUCT
				WHERE SPC_ID_PERIOD = @PR_ID
					AND SPC_ID_SUBHOST = @SH_ID
					AND SP_ID_GROUP = 2
			) AS SHC_STUDY,
			(
				SELECT SUM(SPC_COUNT * SPP_PRICE)
				FROM
					Subhost.SubhostProductPrice INNER JOIN
					Subhost.SubhostProductCalc ON SPC_ID_PERIOD = SPP_ID_PERIOD
										AND SPP_ID_PRODUCT = SPC_ID_PROD INNER JOIN
					Subhost.SubhostProduct ON SP_ID = SPP_ID_PRODUCT
				WHERE SPC_ID_PERIOD = @PR_ID
					AND SPC_ID_SUBHOST = @SH_ID
					AND SP_ID_GROUP = 3
			) AS SHC_MARKET,
			(
				SELECT SUM(SPC_COUNT * SPP_PRICE)
				FROM
					Subhost.SubhostProductPrice INNER JOIN
					Subhost.SubhostProductCalc ON SPC_ID_PERIOD = SPP_ID_PERIOD
										AND SPP_ID_PRODUCT = SPC_ID_PROD INNER JOIN
					Subhost.SubhostProduct ON SP_ID = SPP_ID_PRODUCT
				WHERE SPC_ID_PERIOD = @PR_ID
					AND SPC_ID_SUBHOST = @SH_ID
					AND SP_ID_GROUP = 1
			) AS SHC_10,
			SHC_DIU, SHC_KBU,
			SHC_TOTAL, SHC_TOTAL_STUDY,
			SHC_INV_DATE, SHC_INV_NUM, SHC_INV_STUDY_DATE, SHC_INV_STUDY_NUM,
			CONVERT(BIT,
				CASE @LAST
					WHEN 1 THEN (SELECT COUNT(*) FROM Subhost.SubhostCalcReport WHERE SCR_ID_PERIOD = dbo.PERIOD_NEXT(@PR_ID) AND SCR_ID_SUBHOST = @SH_ID)
					ELSE (SELECT COUNT(*) FROM Subhost.SubhostCalcReport WHERE SCR_ID_PERIOD = @PR_ID AND SCR_ID_SUBHOST = @SH_ID)
				END
			) AS SHC_CLOSED
			--CONVERT(BIT, CASE @LAST WHEN 1 THEN 0 ELSE SHC_CLOSED END) AS SHC_CLOSED
		FROM Subhost.SubhostCalc
		INNER JOIN dbo.SubhostTable ON SH_ID = SHC_ID_SUBHOST
		INNER JOIN dbo.PeriodTable ON PR_ID = SHC_ID_PERIOD
		CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
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

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_SELECT] TO rl_subhost_calc;
GO
