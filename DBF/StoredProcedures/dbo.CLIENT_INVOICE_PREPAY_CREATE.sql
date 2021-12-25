USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		Денисов Алексей/Богдан Владимир
Дата:		23-04-2009
Описание:	счет-фактура на аванс за период
*/
ALTER PROCEDURE [dbo].[CLIENT_INVOICE_PREPAY_CREATE]
	@clientid INT,
	@periodid SMALLINT,
	@invdate SMALLDATETIME,
	@begnum	INT,
	@soid SMALLINT = 1
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

		-- проверяем, есть ли уже (неавансовая) счет-фактура клиенту за этот период
		IF NOT EXISTS (SELECT * FROM dbo.InvoiceSaleTable INNER JOIN dbo.InvoiceRowTable ON INR_ID_INVOICE=INS_ID
						WHERE INS_ID_CLIENT=@clientid AND INR_ID_PERIOD=@periodid AND INS_PREPAY=0)
		BEGIN
			-- получаем строку документов и айдишников платежей
			DECLARE @docstring varchar(1000)
			SET @docstring = ''
			DECLARE @idstring varchar(1000)
			SET @idstring = ''
			SELECT	@docstring = @docstring + ('№'+IN_PAY_NUM +' от '+CONVERT(varchar,IN_PAY_DATE,104)) + '; ',
					@idstring = @idstring + CONVERT(varchar,IN_ID) + ','
					FROM
						(
							SELECT DISTINCT	IN_PAY_NUM, IN_ID_CLIENT, ID_ID_PERIOD, IN_PAY_DATE,
											IN_ID
							FROM
								dbo.IncomeTable inner join
								dbo.IncomeDistrTable on IN_ID = ID_ID_INCOME
							WHERE	ID_ID_PERIOD = @periodid	and
									IN_ID_CLIENT = @clientid
						)	AS O_o
			SET @docstring = LEFT(@docstring, LEN(@docstring)-1)
			SET @idstring = LEFT(@idstring, LEN(@idstring)-1)

			-- каким же номером нумеровать создаваемую с/ф?
			DECLARE @num INT
			SET @num = 0
			IF EXISTS (SELECT INS_NUM FROM dbo.InvoiceSaleTable WHERE INS_NUM=@begnum)
				BEGIN
					SET @num=(SELECT MAX(INS_NUM)+1 FROM InvoiceSaleTable)
				END
			ELSE
				BEGIN
					SET @num = @begnum
				END

			-- сначала добавляем саму счет-фактуру

			INSERT INTO dbo.InvoiceSaleTable(
				INS_ID_ORG,
				INS_DATE,
				INS_NUM,
				INS_NUM_YEAR,
				INS_ID_CLIENT,
				INS_CLIENT_NAME,
				INS_CLIENT_ADDR,
				INS_CONSIG_NAME,
				INS_CONSIG_ADDR,
				INS_CLIENT_INN,
				INS_CLIENT_KPP,
				INS_DOC_STRING,
				INS_STORNO,
				INS_COMMENT,
				INS_PREPAY
				)
			SELECT
				(SELECT CL_ID_ORG FROM dbo.ClientTable WHERE CL_ID=@clientid),

				@invdate,

				@num,

				RIGHT(DATEPART(yy,@invdate),2),

				@clientid,

				(SELECT CL_FULL_NAME FROM dbo.ClientTable WHERE CL_ID = @clientid),

				(SELECT CT_PREFIX+CT_NAME+', '+ST_PREFIX+ST_NAME+', д.'+CA_HOME
					FROM	dbo.ClientAddressView			A	INNER JOIN
							dbo.FinancingAddressTypeTable	B	ON	A.CA_ID_TYPE=B.FAT_ID_ADDR_TYPE
					WHERE CA_ID_CLIENT = @clientid AND FAT_DOC='INV_BUY'),

				(SELECT CL_FULL_NAME FROM dbo.ClientTable WHERE CL_ID = @clientid),

				(SELECT CT_PREFIX+CT_NAME+', '+ST_PREFIX+ST_NAME+', д.'+CA_HOME
					FROM	dbo.ClientAddressView			A	INNER JOIN
							dbo.FinancingAddressTypeTable	B	ON	A.CA_ID_TYPE=B.FAT_ID_ADDR_TYPE
					WHERE CA_ID_CLIENT = @clientid AND FAT_DOC='INV_CONS'),

				(SELECT CL_INN FROM dbo.ClientTable WHERE CL_ID = @clientid),
				(SELECT CL_KPP FROM dbo.ClientTable WHERE CL_ID = @clientid),
				@docstring,
				NULL,
				NULL,
				1
			WHERE
				NOT EXISTS	(
					SELECT *
					FROM
						dbo.IncomeDistrView	A									INNER JOIN
						dbo.DistrView		B WITH(NOEXPAND)	ON	A.DIS_ID=B.DIS_ID
					WHERE PR_ID = @periodid	and
						IN_ID_CLIENT =	@clientid	and
						SYS_ID_SO	  =	@soid		and

						EXISTS	(
								SELECT *
								FROM
									dbo.InvoiceSaletable		INNER JOIN
									dbo.InvoiceRowTable		ON	INS_ID=INR_ID_INVOICE
								WHERE
									INR_ID_PERIOD=@periodid	AND
									B.DIS_ID=INR_ID_DISTR
								)
							)
						AND
							(SELECT	SUM(ID_PRICE)
							FROM
								(
									SELECT IN_ID_CLIENT, ID_ID_DISTR, SUM(ID_PRICE) AS ID_PRICE, ID_ID_PERIOD
									FROM
										dbo.IncomeDistrTable	A			INNER JOIN
										dbo.IncomeTable			Z	ON	A.ID_ID_INCOME = Z.IN_ID
									WHERE IN_ID_CLIENT = @clientid AND ID_ID_PERIOD = @periodid
									GROUP BY ID_ID_DISTR, ID_ID_PERIOD, IN_ID_CLIENT
								)				AS	O_o									INNER JOIN
								dbo.DistrTable			B	ON	O_o.ID_ID_DISTR=B.DIS_ID	INNER JOIN
								dbo.SystemTable			C	ON	B.DIS_ID_SYSTEM=C.SYS_ID	INNER JOIN
								dbo.SaleObjectTable		D	ON	C.SYS_ID_SO=D.SO_ID			INNER JOIN
								dbo.TaxTable			E	ON	D.SO_ID_TAX=E.TX_ID
							WHERE
								ID_ID_PERIOD =	@periodid	and
								IN_ID_CLIENT =	@clientid	and
								SO_ID		  =	@soid		and
								NOT EXISTS (
											SELECT *
											FROM
												dbo.InvoiceSaletable								INNER JOIN
												dbo.InvoiceRowTable		ON	INS_ID=INR_ID_INVOICE
											WHERE
													INR_ID_PERIOD=@periodid	AND
													B.DIS_ID=INR_ID_DISTR
											)
							 ) > 0




			DECLARE @newinvid INT
			SET @newinvid = SCOPE_IDENTITY()
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

			-- потом добавляем строки таблицы счета-фактуры
			INSERT INTO dbo.InvoiceRowTable (INR_ID_INVOICE,
										 INR_NAME, INR_SUM, INR_ID_TAX, INR_TNDS, INR_SNDS, INR_SALL,
										 INR_ID_DISTR, INR_ID_PERIOD)
			SELECT
					@newinvid,

					'Предоплата за '+SO_INV_STR+' '+C.SYS_NAME,

					CONVERT(money, ROUND(ID_PRICE / (1 + TX_PERCENT / 100), 2)),
					SO_ID_TAX, TX_PERCENT,
					(ID_PRICE - CONVERT(money, ROUND(ID_PRICE / (1 + TX_PERCENT / 100), 2))),
					ID_PRICE,
					DIS_ID, ID_ID_PERIOD

			FROM
				(
					SELECT IN_ID_CLIENT, ID_ID_DISTR, SUM(ID_PRICE) AS ID_PRICE, ID_ID_PERIOD
					FROM
						dbo.IncomeDistrTable	A			INNER JOIN
						dbo.IncomeTable			Z	ON	A.ID_ID_INCOME = Z.IN_ID
					WHERE IN_ID_CLIENT = @clientid AND ID_ID_PERIOD = @periodid
					GROUP BY ID_ID_DISTR, ID_ID_PERIOD, IN_ID_CLIENT
				)				AS	O_o									INNER JOIN
				dbo.DistrTable			B	ON	O_o.ID_ID_DISTR=B.DIS_ID	INNER JOIN
				dbo.SystemTable			C	ON	B.DIS_ID_SYSTEM=C.SYS_ID	INNER JOIN
				dbo.SaleObjectTable		D	ON	C.SYS_ID_SO=D.SO_ID			INNER JOIN
				dbo.TaxTable			E	ON	D.SO_ID_TAX=E.TX_ID
			WHERE
				ID_ID_PERIOD =	@periodid	and
				IN_ID_CLIENT =	@clientid	and
				SO_ID		  =	@soid		and
				NOT EXISTS (
							SELECT *
							FROM
								dbo.InvoiceSaletable								INNER JOIN
								dbo.InvoiceRowTable		ON	INS_ID=INR_ID_INVOICE
							WHERE
									INR_ID_PERIOD=@periodid	AND
									B.DIS_ID=INR_ID_DISTR
							)
			-- теперь обрабатываем id-шники платежей
				IF OBJECT_ID('tempdb..#incomes') IS NOT NULL
					DROP TABLE #incomes

				CREATE TABLE #incomes ( inc_id INT NOT NULL )
				INSERT INTO #incomes
					SELECT * FROM dbo.GET_TABLE_FROM_LIST(@idstring, ',')

				-- заносим в Income сведения о созданной с/ф (в ID_ID_INVOCIE)
				UPDATE dbo.IncomeTable SET IN_ID_INVOICE=@newinvid
				WHERE IN_ID IN (SELECT inc_id FROM #incomes)

				IF OBJECT_ID('tempdb..#incomes') IS NOT NULL
					DROP TABLE #incomes

			EXEC dbo.BOOK_SALE_PROCESS @newinvid
			EXEC dbo.BOOK_PURCHASE_PROCESS @newinvid
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
GRANT EXECUTE ON [dbo].[CLIENT_INVOICE_PREPAY_CREATE] TO rl_invoice_w;
GO
