USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_SALDO_SELECT]
	@clientid INT
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

		SELECT
			SL_ID, CL_FULL_NAME, SL_DATE, DIS_STR, BD_TOTAL_PRICE, ID_PRICE, AD_TOTAL_PRICE,
			CSD_TOTAL_PRICE, SL_REST, BPR_DATE, IN_DATE, IN_PAY_NUM, APR_DATE, CPR_DATE, IN_ID
		FROM dbo.SaldoDetailView
		WHERE CL_ID = @clientid
		ORDER BY CL_FULL_NAME, DIS_STR, SL_DATE, SL_TP , SL_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SALDO_SELECT] TO rl_saldo_r;
GO