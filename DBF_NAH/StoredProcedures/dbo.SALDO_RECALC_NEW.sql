USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SALDO_RECALC_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SALDO_RECALC_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SALDO_RECALC_NEW]
	@clientid INT
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

		DECLARE @temp TABLE
		(
			SL_ID				BIGINT,
			SL_ID_DISTR 		INT,
			SL_DATE				SMALLDATETIME,
			SL_PRICE			MONEY,
			SL_PRICE_BEZ_NDS	MONEY,
			SL_REST 			MONEY,
			TP					TINYINT
			PRIMARY KEY CLUSTERED(SL_ID)
		);

		INSERT INTO @temp
		SELECT
			SL_ID, SL_ID_DISTR, ACT_DATE,
			- AD_TOTAL_PRICE, -AD_PRICE, 0, SL_TP
		FROM
			dbo.SaldoTable WITH(UPDLOCK)
			INNER JOIN dbo.ActDistrTable ON AD_ID = SL_ID_ACT_DIS
			INNER JOIN dbo.ActTable ON ACT_ID = AD_ID_ACT
		WHERE SL_ID_CLIENT = @clientid AND SL_ID_ACT_DIS IS NOT NULL

		UNION ALL

		SELECT
			SL_ID, SL_ID_DISTR, IN_DATE,
			ID_PRICE, ID_PRICE - ROUND(ID_PRICE * TX_PERCENT / (100.0 + TX_PERCENT), 2), 0, SL_TP
		FROM
			dbo.SaldoTable WITH(UPDLOCK)
			INNER JOIN dbo.IncomeDistrTable ON ID_ID = SL_ID_IN_DIS
			INNER JOIN dbo.IncomeTable ON IN_ID = ID_ID_INCOME
			INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
			INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO
			CROSS APPLY
			(
				SELECT TOP 1 *
				FROM dbo.TaxTable
				WHERE TX_ID IN
					(
						SELECT AD_ID_TAX
						FROM dbo.ActDistrTable
						INNER JOIN dbo.ActTable ON ACT_ID = AD_ID_ACT
						WHERE AD_ID_DISTR = ID_ID_DISTR
							AND AD_ID_PERIOD = ID_ID_PERIOD
							AND ACT_ID_CLIENT = IN_ID_CLIENT
					)

				UNION ALL

				SELECT TOP 1 *
				FROM dbo.TaxTable
				WHERE TX_PERCENT =
					CASE
						WHEN SYS_ID_SO = 1 AND IN_DATE < '20190101' THEN 18
						WHEN SYS_ID_SO = 1 AND IN_DATE >= '20190101' THEN 20
						WHEN SYS_ID_SO = 2 THEN 10
						WHEN SYS_ID_SO = 4 THEN 0
					END
					AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ActDistrTable
						INNER JOIN dbo.ActTable ON ACT_ID = AD_ID_ACT
						WHERE AD_ID_DISTR = ID_ID_DISTR
							AND AD_ID_PERIOD = ID_ID_PERIOD
							AND ACT_ID_CLIENT = IN_ID_CLIENT
					)
			) AS T
		WHERE SL_ID_CLIENT = @clientid AND SL_ID_IN_DIS IS NOT NULL

		UNION ALL

		SELECT
			SL_ID, SL_ID_DISTR, CSG_DATE,
			- CSD_TOTAL_PRICE, -CSD_PRICE, 0, SL_TP
		FROM
			dbo.SaldoTable WITH(UPDLOCK)
			INNER JOIN dbo.ConsignmentDetailTable ON CSD_ID = SL_ID_CONSIG_DIS
			INNER JOIN dbo.ConsignmentTable ON CSG_ID = CSD_ID_CONS
		WHERE SL_ID_CLIENT = @clientid AND SL_ID_CONSIG_DIS IS NOT NULL

		UNION ALL

		SELECT
			SL_ID, SL_ID_DISTR, BD_DATE,
			0, 0, 0, SL_TP
		FROM
			dbo.SaldoTable WITH(UPDLOCK)
			INNER JOIN dbo.BillDistrTable ON BD_ID = SL_ID_BILL_DIS
			INNER JOIN dbo.BillTable ON BL_ID = BD_ID_BILL
		WHERE SL_ID_CLIENT = @clientid AND SL_ID_BILL_DIS IS NOT NULL


		DECLARE @saldo TABLE
		(
			ID INT IDENTITY(1, 1) PRIMARY KEY,
			SL_ID BIGINT,
			SL_ID_DISTR INT,
			SL_DATE SMALLDATETIME,
			SL_PRICE MONEY,
			SL_PRICE_BEZ_NDS MONEY,
			SL_REST MONEY,
			SL_REST_BEZ_NDS MONEY
		)


		INSERT INTO @saldo
		SELECT SL_ID, SL_ID_DISTR, SL_DATE, SL_PRICE, SL_PRICE_BEZ_NDS, SL_REST, 0
		FROM @temp
		ORDER BY SL_DATE, TP , SL_ID

		DECLARE @a MONEY
		SET @a = 0

		DECLARE @b MONEY
		SET @b = 0

		DECLARE @dis INT
		SET @dis = 0

		SET @dis =
		(
			SELECT TOP 1 SL_ID_DISTR
			FROM @saldo
			WHERE SL_ID_DISTR > @dis
			ORDER BY SL_ID_DISTR
		)

		WHILE @dis IS NOT NULL
		BEGIN
			UPDATE @saldo
			SET @a				= @a + SL_PRICE,
				@b				= CASE WHEN @a = 0 THEN 0 ELSE @b + SL_PRICE_BEZ_NDS END,
				SL_REST			= @a,
				SL_REST_BEZ_NDS = CASE WHEN @a = 0 THEN 0 ELSE @b END
			WHERE SL_ID_DISTR = @dis


			SET @dis =
					(
						SELECT TOP 1 SL_ID_DISTR
						FROM @saldo
						WHERE SL_ID_DISTR > @dis
						ORDER BY SL_ID_DISTR
					)
			SET @a = 0
			SET @b = 0
		END

		UPDATE dbo.SaldoTable
		SET SL_DATE = a.SL_DATE,
			SL_REST = a.SL_REST,
			SL_BEZ_NDS = a.SL_REST_BEZ_NDS
		FROM @saldo a
		WHERE SaldoTable.SL_ID = a.SL_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
