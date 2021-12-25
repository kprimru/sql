USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_COEF_SAVE]
	@PR_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@VALUE	DECIMAL(8, 4),
	@COEF	DECIMAL(8, 4)
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

		IF @VALUE IS NULL
			DELETE
			FROM dbo.PriceCoef
			WHERE PC_ID_SYSTEM = @SYS_ID
				AND PC_ID_PERIOD = @PR_ID
		ELSE
		BEGIN
			UPDATE dbo.PriceCoef
			SET PC_COEF = @VALUE
			WHERE PC_ID_SYSTEM = @SYS_ID
				AND PC_ID_PERIOD = @PR_ID

			IF @@ROWCOUNT = 0
				INSERT INTO dbo.PriceCoef(PC_ID_SYSTEM, PC_ID_PERIOD, PC_COEF)
					VALUES(@SYS_ID, @PR_ID, @VALUE)
		END

		IF @COEF IS NULL
			DELETE
			FROM dbo.SystemSubhostCoef
			WHERE SSC_ID_SYSTEM = @SYS_ID
				AND SSC_ID_PERIOD = @PR_ID
		ELSE
		BEGIN
			UPDATE dbo.SystemSubhostCoef
			SET SSC_COEF = @COEF
			WHERE SSC_ID_SYSTEM = @SYS_ID
				AND SSC_ID_PERIOD = @PR_ID

			IF @@ROWCOUNT = 0
				INSERT INTO dbo.SystemSubhostCoef(SSC_ID_SYSTEM, SSC_ID_PERIOD, SSC_COEF)
					VALUES(@SYS_ID, @PR_ID, @COEF)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_COEF_SAVE] TO rl_price_calc;
GO
