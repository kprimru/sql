USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:
Описание:
Дата изменения:	18.06.2009
Описание:		Период всячески исключаем из-за отсутствия его необходимости,
				название не меняем.
И все же период включаем как ограничение сверху.
*/
ALTER PROCEDURE [dbo].[CLIENT_BILL_PERIOD_SELECT]
	@clientid INT,
	@periodid SMALLINT,
	@doctype VARCHAR(50),
	@psoid SMALLINT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PR_DATE	SMALLDATETIME
	DECLARE @SQL NVARCHAR(MAX)

	SELECT @PR_DATE = PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @periodid

	IF @doctype = 'ACT'
	BEGIN
		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act

		CREATE TABLE #act
			(
				AD_ID_PERIOD	SMALLINT,
				AD_ID_DISTR		INT
			)

		INSERT INTO #act(AD_ID_PERIOD, AD_ID_DISTR)
			SELECT AD_ID_PERIOD, AD_ID_DISTR
			FROM
				dbo.ActTable INNER JOIN
				dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
			WHERE ACT_ID_CLIENT = @clientid

		SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #act (AD_ID_DISTR, AD_ID_PERIOD)'
		EXEC (@SQL)

		SELECT
			BD_ID,
			PR_ID, PR_DATE, a.DIS_ID, a.DIS_STR, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
			(
				BD_TOTAL_PRICE -
					ISNULL((
						SELECT SUM(ID_PRICE)
						FROM
							dbo.IncomeDistrTable INNER JOIN
							dbo.IncomeTable ON IN_ID = ID_ID_INCOME INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
							dbo.SaleObjectTable c ON SO_ID = SYS_ID_SO
						WHERE IN_ID_CLIENT = BL_ID_CLIENT
							AND ID_ID_PERIOD = PR_ID
							AND ID_ID_DISTR = a.DIS_ID
							AND c.SO_ID = a.SO_ID
					), 0)
			) BD_UNPAY,
			(
				SELECT TOP 1 CO_ID
				FROM
					dbo.ContractDistrTable LEFT OUTER JOIN
					dbo.ContractTable ON CO_ID = COD_ID_CONTRACT AND CO_ID_CLIENT = @clientid --AND CO_ACTIVE = 1
				WHERE COD_ID_DISTR = a.DIS_ID
				ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
			) AS CO_ID,
			(
				SELECT TOP 1 CO_NUM
				FROM
					dbo.ContractDistrTable LEFT OUTER JOIN
					dbo.ContractTable ON CO_ID = COD_ID_CONTRACT AND CO_ID_CLIENT = @clientid --AND CO_ACTIVE = 1
				WHERE COD_ID_DISTR = a.DIS_ID
				ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
			) AS CO_NUM
		FROM
			dbo.BillDistrView a INNER JOIN
			dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID
		WHERE BL_ID_CLIENT = @clientid
			AND DOC_PSEDO = @doctype
			AND DD_PRINT = 1
			AND SO_ID = @psoid
			-- 18.06.2009
			AND PR_DATE <= @PR_DATE--(SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @periodid)
			AND NOT EXISTS
				(
					SELECT *
					FROM #act
					WHERE AD_ID_PERIOD = PR_ID
						AND AD_ID_DISTR = a.DIS_ID
				)
		ORDER BY CO_NUM, SYS_ORDER, DIS_NUM

		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act
	END
	ELSE IF @doctype = 'CONS'
	BEGIN
		SELECT
			PR_ID, PR_DATE, a.DIS_ID, a.DIS_STR, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
			(
				BD_TOTAL_PRICE -
					ISNULL((
						SELECT SUM(ID_PRICE)
						FROM
							dbo.IncomeDistrTable INNER JOIN
							dbo.IncomeTable ON IN_ID = ID_ID_INCOME INNER JOIN
							dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR INNER JOIN
							dbo.SaleObjectTable c ON SO_ID = SYS_ID_SO
						WHERE IN_ID_CLIENT = BL_ID_CLIENT
							AND ID_ID_PERIOD = PR_ID
							AND ID_ID_DISTR = a.DIS_ID
							AND c.SO_ID = a.SO_ID
					), 0)
			) BD_UNPAY, CO_ID, CO_NUM
		FROM
			dbo.BillDistrView a INNER JOIN
			dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID  LEFT OUTER JOIN
			dbo.ContractDistrTable ON COD_ID_DISTR = a.DIS_ID LEFT OUTER JOIN
			dbo.ContractTable ON CO_ID = COD_ID_CONTRACT AND CO_ID_CLIENT = @clientid
		WHERE BL_ID_CLIENT = @clientid
			AND DOC_PSEDO = @doctype
			AND CO_ACTIVE = 1
			AND DD_PRINT = 1
			AND SO_ID = @psoid
			-- 18.06.2009
			AND PR_DATE <= @PR_DATE--(SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @periodid)
			AND NOT EXISTS
				(
					SELECT *
					FROM
						dbo.ConsignmentTable INNER JOIN
						dbo.ConsignmentDetailTable ON CSG_ID = CSD_ID_CONS
					WHERE CSG_ID_CLIENT = @clientid
						AND CSD_ID_PERIOD = PR_ID
						AND CSD_ID_DISTR = a.DIS_ID
				)
		ORDER BY CO_NUM, SYS_ORDER, DIS_NUM
	END
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_BILL_PERIOD_SELECT] TO rl_bill_r;
GO