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
ALTER PROCEDURE [dbo].[ACT_PRINT_BY_INVOICE]
	@invoiceid INT,
	@actdate SMALLDATETIME,
	@actperiod SMALLINT,
	@conum VARCHAR(100),
	@codate SMALLDATETIME
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

		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master

		CREATE TABLE #master
			(
				AFM_ID bigint IDENTITY(1,1),
				CL_ID int,
				CL_PSEDO varchar(50),
				CL_FULL_NAME varchar(500),
				CL_SHORT_NAME varchar(100),
				CL_FOUNDING VARCHAR(500),
				CO_ID int,
				CO_NUM varchar(500),
				CO_DATE smalldatetime,
				CK_HEADER	VARCHAR(50),
				CK_CENTER	VARCHAR(50),
				CK_FOOTER	VARCHAR(50),
				POS_NAME varchar(100),
				PER_FAM varchar(250),
				PER_NAME varchar(50),
				PER_OTCH varchar(50),
				ORG_ID smallint,
				ORG_FULL_NAME varchar(250),
				ORG_SHORT_NAME varchar(50),
				ORG_INN varchar(50),
				ORG_KPP varchar(50),
				ORG_ACCOUNT varchar(50),
				ORG_LORO varchar(50),
				ORG_BIK varchar(50),
				ORG_DIR_FAM varchar(50),
				ORG_DIR_NAME varchar(50),
				ORG_DIR_OTCH varchar(50),
				ORG_DIR_SHORT varchar(50),
				BA_NAME varchar(150),
				PR_MONTH varchar(15),
				PR_END_DATE smalldatetime
			)

		INSERT INTO #master (
					CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
					CO_ID, CO_NUM, CO_DATE, CK_HEADER, CK_CENTER, CK_FOOTER,
					POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
					ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME,
					ORG_INN, ORG_KPP, ORG_ACCOUNT, ORG_LORO, ORG_BIK,
					ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH, ORG_DIR_SHORT,
					BA_NAME,
					PR_MONTH,
					PR_END_DATE
					)
			SELECT
					CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
					NULL, @conum, @codate, CK_HEADER, CK_CENTER, CK_FOOTER,
					POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
					ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME,
					ORG_INN, ORG_KPP, ISNULL(ORGC_ACCOUNT, ORG_ACCOUNT), BA_LORO, BA_BIK,
					ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH,
					(ORG_DIR_FAM + ' ' + LEFT(ORG_DIR_NAME, 1) + '.' + LEFT(ORG_DIR_OTCH, 1) + '.')
						AS ORG_DIR_SHORT,
					BA_NAME,
					(
						SELECT TOP 1 DATENAME(MM, PR_DATE)
						FROM dbo.PeriodTable
						WHERE PR_ID = @actperiod
						ORDER BY PR_DATE DESC
					) AS PR_MONTH,
					@actdate AS PR_END_DATE
			FROM
				dbo.InvoiceSaleTable	A	INNER JOIN
				--dbo.ActDistrTable		Z	ON	Z.AD_ID_ACT		= A.ACT_ID	INNER JOIN
				dbo.ClientTable			B	ON	A.INS_ID_CLIENT = B.CL_ID	LEFT JOIN
				dbo.ClientPersonalTable	E	ON	E.PER_ID_CLIENT	= B.CL_ID	LEFT JOIN
				dbo.PositionTable		F	ON	E.PER_ID_POS	= F.POS_ID	LEFT JOIN
				dbo.OrganizationTable	G	ON	B.CL_ID_ORG		= G.ORG_ID	LEFT JOIN
				dbo.OrganizationCalc	J	ON  J.ORGC_ID = B.CL_ID_ORG_CALC LEFT OUTER JOIN
				dbo.BankTable			H	ON	G.ORG_ID_BANK	= H.BA_ID
				CROSS APPLY
					(
						SELECT TOP 1 CK_HEADER, CK_FOOTER, CK_CENTER
						FROM
							(
								SELECT TOP 1 2 AS TP, CO_ID
								FROM
									dbo.ContractTable INNER JOIN
									dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID

								WHERE CO_ID_CLIENT = INS_ID_CLIENT
								ORDER BY CO_DATE DESC, CO_ACTIVE DESC

								UNION ALL

								SELECT TOP 1 3 AS TP, CO_ID
								FROM
									dbo.ContractTable INNER JOIN
									dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID
								WHERE CO_ID_CLIENT = INS_ID_CLIENT AND CO_ACTIVE = 1
							) AS o_O
							INNER JOIN dbo.ContractTable p ON p.CO_ID = o_O.CO_ID
							INNER JOIN dbo.ContractKind ON CK_ID = CO_ID_KIND
						ORDER BY TP
					) AS t
			WHERE ISNULL(PER_ID_REPORT_POS, 1) = 1
				AND INS_ID = @invoiceid
			--	LEFT JOIN			dbo.PeriodTable			I	ON	Z.AD_ID_PERIOD	= I.PR_ID


		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		CREATE TABLE #detail
			(
				AFD_ID_AFM bigint,
				PR_ID smallint,
				DIS_ID int,
				DIS_NUM varchar(50),
				SYS_NAME varchar(500),
				SYS_ORDER int,
				AD_PRICE money,
				AD_TAX_PRICE money,
				AD_TOTAL_PRICE money,
				TX_PERCENT decimal,
				TX_NAME varchar(50),
				SO_ID smallint,
				SO_BILL_STR varchar(150),
				SO_INV_UNIT varchar(150),
				AD_PAYED_PRICE money,
			)

		INSERT INTO #detail (
				AFD_ID_AFM, 
				DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
				AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
				TX_PERCENT, TX_NAME,
				SO_BILL_STR, SO_INV_UNIT
				)
			SELECT
					(
						SELECT TOP 1 AFM_ID
						FROM #master
					),
					INR_ID_DISTR, NULL, INR_NAME, NULL,
					ROUND(INR_SUM * ISNULL(INR_COUNT, 1), 2),
					INR_SNDS, INR_SALL,
					TX_PERCENT, TX_NAME,
					INR_GOOD, --SO_BILL_STR,
					INR_UNIT
				FROM
					dbo.InvoiceSaleTable		A			INNER JOIN
					dbo.InvoiceRowTable		Z	ON	Z.INR_ID_INVOICE= A.INS_ID	INNER JOIN
					dbo.TaxTable			D	ON	D.TX_ID			= Z.INR_ID_TAX
				WHERE INS_ID = @invoiceid


		SELECT
			AFM_ID, CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
			CO_ID, CO_NUM, CO_DATE, CK_HEADER, CK_CENTER, CK_FOOTER, POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
			ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INN, ORG_KPP, ORG_ACCOUNT,
			ORG_LORO, ORG_BIK, ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH, ORG_DIR_SHORT,
			BA_NAME, PR_MONTH, PR_END_DATE, 0 AS ACT_TO, '18' AS TAX_STR
		FROM #master
		ORDER BY CL_PSEDO, CL_ID

		SELECT
			AFD_ID_AFM,
			NULL AS TO_NUM,
			--PR_ID, PR_DATE, PR_MONTH, PR_END_DATE,
			DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
			SUM(AD_PRICE) AS AD_PRICE, SUM(AD_TAX_PRICE) AS AD_TAX_PRICE,
			SUM(AD_TOTAL_PRICE) AS AD_TOTAL_PRICE,
			TX_PERCENT, TX_NAME, SO_ID,
			SO_BILL_STR, SO_INV_UNIT, SUM(AD_PAYED_PRICE) AS AD_PAYED_PRICE
		FROM #detail
		GROUP BY
			AFD_ID_AFM, DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
			TX_PERCENT, TX_NAME,
			SO_ID, SO_INV_UNIT, SO_BILL_STR
		ORDER BY AFD_ID_AFM, SYS_ORDER, DIS_NUM

		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master

		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT_BY_INVOICE] TO rl_invoice_r;
GO
