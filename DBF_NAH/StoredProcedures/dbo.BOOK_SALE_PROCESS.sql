USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BOOK_SALE_PROCESS]
	@insid	INT
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

		DECLARE @DT	SMALLDATETIME

		SELECT @DT = INS_DATE
		FROM dbo.InvoiceSaleTable
		WHERE INS_ID = @insid

		IF @DT >= '20150101' AND @DT <= '20150331'
			RETURN

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.BookSale
				WHERE ID_INVOICE = @insid
			)
		BEGIN
			INSERT INTO dbo.BookSale(ID_INVOICE, ID_ORG, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE)
				SELECT
					INS_ID, INS_ID_ORG,
					CASE INT_PSEDO WHEN 'INCOME' THEN '02' ELSE '01' END,
					INS_NUM, INS_DATE, INS_CLIENT_NAME, INS_CLIENT_INN, INS_CLIENT_KPP,
					IN_PAY_NUM, IN_DATE
				FROM
					dbo.InvoiceSaleTable
					INNER JOIN dbo.InvoiceTypeTable ON INS_ID_TYPE = INT_ID
					OUTER APPLY
					(
						SELECT TOP (1)
							IN_DATE, IN_PAY_NUM
						FROM dbo.IncomeTable
						INNER JOIN dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME
						INNER JOIN dbo.InvoiceRowTable ON INR_ID_DISTR = ID_ID_DISTR AND INR_ID_PERIOD = ID_ID_PERIOD
						WHERE INR_ID_INVOICE = @insid AND IN_DATE <= @DT
						ORDER BY IN_DATE DESC, IN_PAY_NUM DESC
					) AS I
				WHERE INS_ID = @insid

			INSERT INTO dbo.BookSaleDetail(ID_SALE, ID_TAX, S_ALL, S_NDS, S_BEZ_NDS)
				SELECT
					(
						SELECT ID
						FROM dbo.BookSale z
						WHERE INS_ID = ID_INVOICE
					), INR_ID_TAX, SUM(INR_SALL), SUM(INR_SNDS), SUM(INR_SUM * ISNULL(INR_COUNT, 1))
				FROM
					dbo.InvoiceSaleTable
					INNER JOIN dbo.InvoiceTypeTable ON INS_ID_TYPE = INT_ID
					INNER JOIN dbo.InvoiceRowTable ON INR_ID_INVOICE = INS_ID
				WHERE INS_ID = @insid
				GROUP BY INS_ID, INR_ID_TAX
		END
		ELSE
		BEGIN
			UPDATE a
			SET CODE	=	CASE INT_PSEDO WHEN 'INCOME' THEN '02' ELSE '01' END,
				NUM		=	INS_NUM,
				DATE	=	INS_DATE,
				NAME	=	INS_CLIENT_NAME,
				INN		=	INS_CLIENT_INN,
				KPP		=	INS_CLIENT_KPP,
				IN_NUM	=	IN_PAY_NUM,
				IN_DATE	=	I.IN_DATE
			FROM
				dbo.BookSale a
				INNER JOIN dbo.InvoiceSaleTable b ON a.ID_INVOICE = b.INS_ID
				INNER JOIN dbo.InvoiceTypeTable ON INS_ID_TYPE = INT_ID
				OUTER APPLY
				(
					SELECT TOP (1)
						IN_DATE, IN_PAY_NUM
					FROM dbo.IncomeTable
					INNER JOIN dbo.IncomeDistrTable ON IN_ID = ID_ID_INCOME
					INNER JOIN dbo.InvoiceRowTable ON INR_ID_DISTR = ID_ID_DISTR AND INR_ID_PERIOD = ID_ID_PERIOD
					WHERE INR_ID_INVOICE = @insid AND IN_DATE <= @DT
					ORDER BY IN_DATE DESC, IN_PAY_NUM DESC
				) AS I
			WHERE INS_ID = @insid

			DELETE FROM dbo.BookSaleDetail WHERE ID_SALE IN (SELECT ID FROM dbo.BookSale WHERE ID_INVOICE = @insid)

			INSERT INTO dbo.BookSaleDetail(ID_SALE, ID_TAX, S_ALL, S_NDS, S_BEZ_NDS)
				SELECT
					(
						SELECT ID
						FROM dbo.BookSale z
						WHERE INS_ID = ID_INVOICE
					), INR_ID_TAX, SUM(INR_SALL), SUM(INR_SNDS), SUM(INR_SUM * ISNULL(INR_COUNT, 1))
				FROM
					dbo.InvoiceSaleTable
					INNER JOIN dbo.InvoiceTypeTable ON INS_ID_TYPE = INT_ID
					INNER JOIN dbo.InvoiceRowTable ON INR_ID_INVOICE = INS_ID
				WHERE INS_ID = @insid
				GROUP BY INS_ID, INR_ID_TAX
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
