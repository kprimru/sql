USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[REPORT_VERIFY_DATE_SELECT]
	@begindate SMALLDATETIME,
	@enddate SMALLDATETIME,
	@clientid INT,
	@org	SMALLINT = NULL
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

		IF @org IS NULL
			SELECT @org = CL_ID_ORG FROM dbo.ClientTable WHERE CL_ID = @clientid

		SELECT
			IN_DATE, SUM(IN_SUM) AS IN_SUM, IN_PAY_NUM, IN_PAY_DATE,
			NULL AS ACT_SUM, NULL AS INS_NUM, NULL AS INS_DATE
		FROM dbo.IncomeTable
		WHERE IN_ID_CLIENT = @clientid
			AND IN_DATE BETWEEN @begindate AND @enddate
		GROUP BY IN_DATE, IN_PAY_NUM, IN_PAY_DATE

		-- и вот эти два запроса надо UNION.
		-- и добавить накладные на ГК. Так и строится все сальдо O_O

		UNION

		SELECT ACT_DATE, NULL, NULL, NULL,
			(
				SELECT SUM(AD_TOTAL_PRICE)
				FROM dbo.ActDistrTable
				WHERE AD_ID_ACT = ACT_ID
			) AS ACT_SUM, (CONVERT(VARCHAR(20), INS_NUM)) AS INS_NUM, INS_DATE
		FROM
			dbo.ActTable INNER JOIN
			dbo.InvoiceSaleTable ON INS_ID = ACT_ID_INVOICE
		WHERE ACT_ID_CLIENT = @clientid
			AND ACT_DATE BETWEEN @begindate AND @enddate

		UNION

		SELECT CSG_DATE, NULL, NULL, NULL,
			(
				SELECT SUM(CSD_TOTAL_PRICE)
				FROM dbo.ConsignmentDetailTable
				WHERE CSD_ID_CONS = CSG_ID
			) AS CSG_SUM, (CONVERT(VARCHAR(20), INS_NUM)) AS INS_NUM, INS_DATE
		FROM
			dbo.ConsignmentTable INNER JOIN
			dbo.InvoiceSaleTable ON INS_ID = CSG_ID_INVOICE
		WHERE CSG_ID_CLIENT = @clientid
			AND CSG_DATE BETWEEN @begindate AND @enddate

		UNION

		SELECT INS_DATE, NULL, NULL, NULL, SUM(INR_SALL), (CONVERT(VARCHAR(20), INS_NUM)) AS INS_NUM, INS_DATE
		FROM
			dbo.InvoiceSaleTable
			INNER JOIN dbo.InvoiceTypeTable ON INT_ID = INS_ID_TYPE
			INNER JOIN dbo.InvoiceRowTable ON INR_ID_INVOICE = INS_ID
		WHERE INS_ID_ORG = @ORG
			AND INS_DATE BETWEEN @begindate AND @enddate
			AND INT_PSEDO = 'PRIMARY'
			AND INS_ID_CLIENT = @clientid
		GROUP BY INS_DATE, INS_NUM

		ORDER BY IN_DATE, IN_PAY_NUM, INS_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_VERIFY_DATE_SELECT] TO rl_report_verify_r;
GO
