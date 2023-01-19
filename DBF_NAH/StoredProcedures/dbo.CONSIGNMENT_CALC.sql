USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONSIGNMENT_CALC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONSIGNMENT_CALC]  AS SELECT 1')
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

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @consid INT

		SELECT TOP 1 @consid = CSG_ID
		FROM dbo.ConsignmentTable
		WHERE CSG_ID_CLIENT = @clientid
			--AND	CSG_ID_INVOICE IS NULL
			AND
				(
					SELECT INS_RESERVE
					FROM dbo.InvoiceSaleTable
					WHERE INS_ID = CSG_ID_INVOICE
				) = 1

		DECLARE @soid SMALLINT

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

		DECLARE @docstring varchar(1000)
			SET @docstring = ''

		IF OBJECT_ID('tempdb..#doc') IS NOT NULL
			DROP TABLE #doc

		CREATE TABLE #doc
			(
				IN_DATE SMALLDATETIME,
				IN_PAY_NUM VARCHAR(20)
			)

		INSERT INTO #doc
			SELECT DISTINCT	IN_PAY_DATE, IN_PAY_NUM
				FROM
					dbo.ConsignmentTable INNER JOIN
					dbo.ConsignmentDetailTable ON CSG_ID = CSD_ID_CONS INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_DISTR = CSD_ID_DISTR
									AND ID_ID_PERIOD = CSD_ID_PERIOD INNER JOIN
					dbo.IncomeTable ON IN_ID = ID_ID_INCOME
								--AND ACT_ID_CLIENT = IN_ID_CLIENT

				WHERE	CSG_ID = @consid

		SELECT @docstring = @docstring + '№ ' + IN_PAY_NUM + ' от ' + CONVERT(VARCHAR, IN_DATE, 104) + '; '
		FROM
			(
				SELECT
				T.IN_DATE,
				STUFF(
						(
							SELECT ',' + TT.IN_PAY_NUM
							FROM
								(
									SELECT DISTINCT IN_PAY_NUM
									FROM #doc O_O
									WHERE O_O.IN_DATE = T.IN_DATE
								) TT
							ORDER BY TT.IN_PAY_NUM FOR XML PATH('')
						), 1, 1, ''
					) IN_PAY_NUM
				FROM #doc T
				GROUP BY T.IN_DATE
			) AS O_O
		ORDER BY O_O.IN_DATE

		IF OBJECT_ID('tempdb..#doc') IS NOT NULL
			DROP TABLE #doc

		IF @docstring <> ''
			SET @docstring = LEFT(@docstring, LEN(@docstring) - 1)

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
