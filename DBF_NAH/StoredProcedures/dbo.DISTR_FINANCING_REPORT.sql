USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_FINANCING_REPORT]
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

		DECLARE @MONTH SMALLINT

		SELECT @MONTH = PR_ID
		FROM dbo.PeriodTable
		WHERE GETDATE() >= PR_DATE AND GETDATE() < DATEADD(day, 1, PR_END_DATE)

		IF DATEPART(DAY, GETDATE()) > 15
			SET @MONTH = dbo.PERIOD_NEXT(@MONTH)

		SELECT
			CL_ID, CL_PSEDO, DIS_STR, SST_CAPTION, SN_NAME,

			DISCOUNT,	DF_FIXED_PRICE, REAL_DISCOUNT
		FROM
			(
				SELECT
					CL_ID, CL_PSEDO, b.DIS_STR, SST_CAPTION, SN_NAME,

					CONVERT(INT, DF_DISCOUNT) AS DISCOUNT,	DF_FIXED_PRICE,
					--PS_PRICE,
					CASE
						WHEN ISNULL(DIS_PRICE, 0) = 0 THEN 0
						WHEN (ISNULL(DF_FIXED_PRICE, 0) <> 0) THEN
							CONVERT(DECIMAL(8, 2), ROUND((100 * (DIS_ORIGIN - DIS_PRICE) / DIS_ORIGIN), 2))
						WHEN ISNULL(DF_DISCOUNT, 0) <> 0 THEN DF_DISCOUNT
						ELSE 0
					END AS REAL_DISCOUNT, b.SYS_ORDER, DIS_NUM, DIS_COMP_NUM

				FROM
					dbo.ClientTable a
					INNER JOIN dbo.ClientDistrView b ON a.CL_ID = b.CD_ID_CLIENT
					INNER JOIN dbo.DistrFinancingTable e ON b.CD_ID_DISTR = e.DF_ID_DISTR
					INNER JOIN dbo.DistrPriceView AS p ON b.CD_ID_DISTR = p.DIS_ID AND p.PR_ID = @MONTH
					INNER JOIN dbo.SystemTypeTable  ON SST_ID = DF_ID_TYPE
					/*
					INNER JOIN dbo.SystemNetCoef f ON SNCC_ID_SN = e.DF_ID_NET AND SNCC_ID_PERIOD = @MONTH
					INNER JOIN dbo.PriceSystemTable g ON PS_ID_SYSTEM = SYS_ID AND PS_ID_PERIOD = @MONTH AND PS_ID_TYPE = 1

					INNER JOIN dbo.SystemNetTable ON SN_ID = DF_ID_NET
					*/
				WHERE b.DSS_REPORT = 1 AND b.SYS_ID_SO = 1
			) AS o_O
		WHERE REAL_DISCOUNT <> 0
		ORDER BY CL_PSEDO, SYS_ORDER, DIS_NUM, DIS_COMP_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_REPORT] TO rl_distr_financing_w;
GO