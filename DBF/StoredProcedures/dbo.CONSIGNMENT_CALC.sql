USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[CONSIGNMENT_CALC]
	-- Список параметров процедуры
	@clientid INT,
	@periodid SMALLINT,
	@distrid INT,
	@date SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@docstring		VarChar(1000),
		@soid			SmallInt,
		@consid			Int;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT TOP 1 @consid = CSG_ID
		FROM dbo.ConsignmentTable
		WHERE CSG_ID_CLIENT = @clientid
			AND
				(
					SELECT INS_RESERVE
					FROM dbo.InvoiceSaleTable
					WHERE INS_ID = CSG_ID_INVOICE
				) = 1

		SELECT @soid = SYS_ID_SO
		FROM dbo.DistrView WITH(NOEXPAND)
		WHERE DIS_ID = @distrid

		IF @consid IS NULL
		BEGIN
			EXEC dbo.CONSIGNMENT_CREATE @clientid, @periodid, @date, @soid, @consid	OUTPUT
		END

		INSERT INTO dbo.ConsignmentDetailTable
			(
				CSD_ID_CONS, CSD_ID_DISTR, CSD_ID_PERIOD,
				CSD_ID_TAX, CSD_COST, CSD_PRICE, CSD_TAX_PRICE,
				CSD_TOTAL_PRICE, CSD_PAYED_PRICE, CSD_COUNT,
				CSD_UNIT, CSD_OKEI, CSD_NAME
			)
			SELECT
				@consid, BD_ID_DISTR, @periodid,
				BD_ID_TAX, BD_PRICE / 2, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
				(
					ISNULL((
						SELECT SUM(ID_PRICE)
						FROM
							dbo.IncomeDistrTable INNER JOIN
							dbo.IncomeTable ON IN_ID = ID_ID_INCOME INNER JOIN
							dbo.DistrView WITH (NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
							dbo.SaleObjectTable a ON SO_ID = SYS_ID_SO
						WHERE IN_ID_CLIENT = BL_ID_CLIENT
							AND ID_ID_PERIOD = BL_ID_PERIOD
							AND ID_ID_DISTR = BD_ID_DISTR
							--AND ID_PREPAY = 0
							AND a.SO_ID = b.SYS_ID_SO
						), 0)
				) AS AD_PAYED_PRICE, 2, UN_NAME, UN_OKEI,
				GD_NAME + ' ' + SYS_NAME
			FROM
				dbo.BillDistrTable INNER JOIN
				dbo.BillTable ON BL_ID = BD_ID_BILL INNER JOIN
				dbo.DistrDocumentView c ON DIS_ID = BD_ID_DISTR INNER JOIN
				dbo.DistrView b WITH(NOEXPAND) ON c.DIS_ID = b.DIS_ID INNER JOIN
				dbo.SaleObjectTable d ON d.SO_ID = b.SYS_ID_SO
			WHERE	BL_ID_PERIOD = @periodid
				AND BL_ID_CLIENT = @clientid
				AND	BD_ID_DISTR = @distrid
				AND DOC_PSEDO = 'CONS'
				AND DD_PRINT = 1

		DECLARE @num INT

		SET @num = 0

		UPDATE dbo.ConsignmentDetailTable
		SET CSD_NUM = @num, @num = @num + 1
		WHERE CSD_ID_CONS = @consid

		SELECT @docstring = String_Agg('№ ' + [IN_PAY_NUMS] + ' от ' + CONVERT(VARCHAR, [IN_PAY_DATE], 104), '; ')
		FROM
		(
			SELECT IN_PAY_DATE, [IN_PAY_NUMS] = String_Agg(I.IN_PAY_NUM, ',')
			FROM
			(
				SELECT DISTINCT	IN_PAY_DATE, IN_PAY_NUM
				FROM dbo.ConsignmentTable
				INNER JOIN dbo.ConsignmentDetailTable ON CSG_ID = CSD_ID_CONS
				INNER JOIN dbo.IncomeDistrTable ON	ID_ID_DISTR = CSD_ID_DISTR
												AND ID_ID_PERIOD = CSD_ID_PERIOD
				INNER JOIN dbo.IncomeTable ON IN_ID = ID_ID_INCOME
				WHERE	CSG_ID = @consid
			) AS I
			GROUP BY IN_PAY_DATE
		) AS I;

		UPDATE dbo.ConsignmentTable
		SET CSG_FOUND = @docstring
		WHERE CSG_ID = @consid AND CSG_FOUND <> @docstring

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_CALC] TO rl_consignment_w;
GO
