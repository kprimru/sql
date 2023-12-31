USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_LIST_1C_SELECT]
	@ORG_ID	SMALLINT,
	@CNT	INT = NULL
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

		IF @CNT IS NULL OR @CNT <= 0
			SET @CNT = 20000000

		SELECT --TOP 300
			a.CL_ID, CL_PSEDO, CL_INN, CL_KPP,
			CAST( ISNULL((
				SELECT SH_SUBHOST
				FROM dbo.SubhostTable
				WHERE SH_ID = CL_ID_SUBHOST
			), 0) AS INT) AS CL_SUBHOST,
			CASE
				WHEN EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView
						WHERE DSS_REPORT = 1
							AND CD_ID_CLIENT = a.CL_ID
					) THEN 1
				ELSE 0
			END AS CL_STATUS,

			CAST(ISNULL((
				SELECT SUM(ROUND(SL_REST / (1 + ROUND((TX_PERCENT / 100), 2)), 2))
				FROM
					dbo.SaldoLastView b INNER JOIN
					dbo.SaleObjectTable ON SO_ID = SYS_ID_SO INNER JOIN
					dbo.TaxTable ON SO_ID_TAX = TX_ID
				WHERE a.CL_ID = b.CL_ID
			), 0) AS MONEY) AS CL_SALDO
		FROM
			dbo.ClientTable a
			INNER JOIN
				(
					SELECT CL_ID, ROW_NUMBER() OVER(ORDER BY CL_ID DESC, CL_PSEDO) AS RN
					FROM dbo.ClientTable
					WHERE CL_ID_ORG = @ORG_ID
				) AS z ON a.CL_ID = z.CL_ID
		WHERE CL_ID_ORG = @ORG_ID AND RN <= @CNT
		ORDER BY CL_ID DESC, CL_PSEDO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_LIST_1C_SELECT] TO rl_client_fin_r;
GO
