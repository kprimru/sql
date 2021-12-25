USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[STOCK_CALC]
	@PR_ALG	SMALLINT,
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

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ALG

		DECLARE @STOCK	DECIMAL(10, 4)

		DECLARE @ST1	DECIMAL(10, 4)
		DECLARE @ST2	DECIMAL(10, 4)

		SELECT @ST1 = RK_KBU
		FROM Ric.KBU
		WHERE RK_ID_QUARTER = dbo.PeriodQuarter(dbo.PeriodDelta(@PR_ID, -12))

		SELECT @ST2 = RK_KBU
		FROM Ric.KBU
		WHERE RK_ID_QUARTER = dbo.PeriodQuarter(dbo.PeriodDelta(@PR_ID, -24))

		IF @PR_DATE >= '20111201' AND @PR_DATE <= '20120901'
		BEGIN
			SET @STOCK = @ST1
		END
		ELSE IF @PR_DATE >= '20121001' AND @PR_DATE <= '20130901'
		BEGIN
			SET @STOCK = @ST2 / 3 + @ST1 * 2 / 3
		END
		ELSE IF @PR_DATE >= '20131001'
		BEGIN
			SET @STOCK = @ST2 / 3 + @ST1 * 2 / 3
		END

		SELECT @STOCK AS STOCK_VALUE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[STOCK_CALC] TO rl_ric_kbu;
GO
