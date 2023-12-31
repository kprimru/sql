USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[KBU_SAVE]
	@PR_ID	SMALLINT,
	@KBU	DECIMAL(10, 4),
	@STOCK	DECIMAL(10, 4),
	@TOTAL	DECIMAL(10, 4)
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

		DECLARE @QR_ID	SMALLINT

		SELECT @QR_ID = dbo.PeriodQuarter(@PR_ID)

		UPDATE Ric.KBU
		SET RK_KBU = @KBU,
			RK_STOCK = @STOCK,
			RK_TOTAL = @TOTAL
		WHERE RK_ID_QUARTER = @QR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.KBU(RK_ID_QUARTER, RK_KBU, RK_STOCK, RK_TOTAL)
				SELECT @QR_ID, @KBU, @STOCK, @TOTAL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[KBU_SAVE] TO rl_ric_kbu;
GO
