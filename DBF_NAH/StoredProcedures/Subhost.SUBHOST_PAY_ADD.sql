USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PAY_ADD]
	@SH_ID	SMALLINT,
	@ORG_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@DATE	SMALLDATETIME,
	@SUM	MONEY,
	@COMMENT	VARCHAR(200)
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

		DECLARE @ID	INT

		INSERT INTO Subhost.SubhostPay(SHP_ID_SUBHOST, SHP_ID_ORG, SHP_DATE, SHP_SUM, SHP_COMMENT)
			VALUES(@SH_ID, @ORG_ID, @DATE, @SUM, ISNULL(@COMMENT, ''))

		SELECT @ID = SCOPE_IDENTITY()

		INSERT INTO Subhost.SubhostPayDetail(SPD_ID_PAY, SPD_ID_PERIOD, SPD_SUM)
			VALUES(@ID, @PR_ID, @SUM)
		/*
		DECLARE @PR_ID	SMALLINT
		DECLARE @DEBT	MONEY

		SELECT @PR_ID = MAX(SHC_ID_PERIOD)
		FROM Subhost.SubhostPayGet(@DATE)
		WHERE SHC_ID_SUBHOST = @SH_ID AND SHP_ID_ORG = @ORG_ID

		SET @PR_ID = dbo.PERIOD_NEXT(@PR_ID)

		INSERT INTO Subhost.SubhostPayDetail(SPD_ID_PAY, SPD_ID_PERIOD, SPD_SUM)
			VALUES(@ID, @PR_ID, 0)

		SELECT @PR_ID = SHC_ID_PERIOD, @DEBT = SHC_TOTAL - DEBT
		FROM Subhost.SubhostPayGet(@DATE)
		WHERE SHC_ID_SUBHOST = @SH_ID AND SHP_ID_ORG = @ORG_ID
			AND SHC_ID_PERIOD =
				(
					SELECT MAX(SHC_ID_PERIOD)
					FROM Subhost.SubhostPayGet(@DATE)
					WHERE SHC_ID_SUBHOST = @SH_ID AND SHP_ID_ORG = @ORG_ID
				)

		DECLARE @PAY MONEY
		DECLARE @SALDO	MONEY

		IF @DEBT < @SUM
		BEGIN
			SET @PAY = @DEBT
			SET @SALDO = @SUM - @DEBT
		END
		ELSE
		BEGIN
			SET @PAY = @SUM
			SET @SALDO = 0
		END

		--SELECT @PR_ID = dbo.PERIOD_NEXT(@PR_ID)

		INSERT INTO Subhost.SubhostPayDetail(SPD_ID_PAY, SPD_ID_PERIOD, SPD_SUM)
			VALUES(@ID, @PR_ID, @PAY)

		SELECT @PR_ID = dbo.PERIOD_NEXT(@PR_ID)

		IF @SALDO <> 0
			INSERT INTO Subhost.SubhostPayDetail(SPD_ID_PAY, SPD_ID_PERIOD, SPD_SUM)
				VALUES(@ID, @PR_ID, @SALDO)

		DELETE FROM Subhost.SubhostPayDetail
		WHERE SPD_SUM = 0
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PAY_ADD] TO rl_subhost_calc;
GO