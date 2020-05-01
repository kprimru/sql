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
ALTER PROCEDURE [dbo].[INVOICE_CREATE_BY_PRPAY_ALL]
	@invdate SMALLDATETIME,
	@print BIT = 1
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

		DECLARE CL CURSOR LOCAL FOR
			SELECT CL_ID
			FROM
				dbo.ClientTable Z
			WHERE
				EXISTS
					(
						SELECT *
						FROM
							dbo.PrimaryPayTable		A	INNER JOIN
							dbo.DistrTable			B	ON	B.DIS_ID = A.PRP_ID_DISTR	INNER JOIN
							dbo.ClientDistrTable	C	ON	B.DIS_ID = C.CD_ID_DISTR	INNER JOIN --LEFT JOIN
	/*						dbo.ClientTable			D	ON	D.CL_ID	= C.CD_ID_CLIENT	INNER JOIN
							dbo.SystemTable			E	ON	E.SYS_ID= B.DIS_ID_SYSTEM 	INNER JOIN
							dbo.SaleObjectTable		F	ON	F.SO_ID = E.SYS_ID_SO		INNER JOIN
							dbo.TaxTable			G	ON	G.TX_ID	= F.SO_ID_TAX		INNER JOIN
	*/						dbo.DistrDocumentView	H	ON	H.DIS_ID= B.DIS_ID		--	INNER JOIN
	--						dbo.GoodTable			I	ON	I.GD_ID=H.GD_ID
						WHERE
							Z.CL_ID = C.CD_ID_CLIENT
							AND PRP_ID_INVOICE IS NULL
	/*						AND	NOT EXISTS (
							SELECT * FROM
								dbo.InvoiceRowTable		J	INNER JOIN
								dbo.InvoiceSaleTable	L	ON	L.INS_ID = J.INR_ID_INVOICE INNER JOIN
	--							dbo.DistrDocumentView	K	ON	J.INR_ID_DISTR=K.DIS_ID
								dbo.InvoiceTypeTable	M	ON	M.INT_ID = L.INS_ID_TYPE
								WHERE	J.INR_ID_DISTR = B.DIS_ID
	--									AND K.DOC_PSEDO='INV_FIRST'
										AND M.INT_PSEDO='PRIMARY'
								)
	*/						AND DOC_PSEDO = 'INV_FIRST'
							AND DD_PRINT = 1
					)

		DECLARE @clid INT

		DECLARE @invoiceid INT
		DECLARE @invoicestr VARCHAR(MAX)

		SET @invoicestr=''

		OPEN CL

		FETCH NEXT FROM CL INTO @clid

		WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC dbo.INVOICE_CREATE_BY_PRPAY @clid, @invdate, 0, @invoiceid OUTPUT, 0	--ноль - это не печатать

				IF @invoiceid IS NOT NULL
					SET @invoicestr = @invoicestr + CONVERT(VARCHAR, @invoiceid) + ','

				FETCH NEXT FROM CL INTO @clid
			END

		IF ISNULL(@invoicestr, '') <> ''
			SET @invoicestr = LEFT(@invoicestr, LEN(@invoicestr) - 1)

		CLOSE CL
		DEALLOCATE CL

		IF @print = 1
			EXEC dbo.INVOICE_PRINT_BY_ID_LIST @invoicestr
		ELSE
			SELECT * FROM dbo.GET_TABLE_FROM_LIST(@invoicestr, ',')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INVOICE_CREATE_BY_PRPAY_ALL] TO rl_invoice_w;
GO