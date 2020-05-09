USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SALDO_DEBT_SELECT]
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

		SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, SL_REST, SN_ID, SN_NAME
		FROM
			dbo.SaldoLastView LEFT OUTER JOIN
			dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID LEFT OUTER JOIN
			dbo.SystemNetTable ON SN_ID = DF_ID_NET
		WHERE SL_REST < 0
		ORDER BY CL_PSEDO, CL_ID, DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SALDO_DEBT_SELECT] TO rl_saldo_r;
GO