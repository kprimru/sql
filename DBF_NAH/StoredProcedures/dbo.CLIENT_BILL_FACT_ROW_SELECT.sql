USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_BILL_FACT_ROW_SELECT]
	@bfmid INT
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
			BFD_ID,
			BFD_ID_BFM,
			BILL_STR,
			TX_PERCENT,
			TX_NAME,
			a.SYS_NAME,
			a.SYS_ORDER,
			a.DIS_ID,
			a.DIS_NUM,
			DIS_STR,
			PR_ID,
			PR_MONTH,
			PR_DATE,
			BD_UNPAY,
			BD_TAX_UNPAY,
			BD_TOTAL_UNPAY
		FROM dbo.BillFactDetailTable a
		LEFT JOIN dbo.DistrView b WITH(NOEXPAND) ON a.DIS_ID = b.DIS_ID
		WHERE BFD_ID_BFM = @bfmid
		ORDER BY SYS_ORDER;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_BILL_FACT_ROW_SELECT] TO rl_bill_w;
GO
