USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_PROTOCOL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_PROTOCOL]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_PROTOCOL]
	@ACT	INT,
	@CLIENT	INT OUTPUT,
	@TXT	VARCHAR(MAX) OUTPUT
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

		SELECT @CLIENT = ACT_ID_CLIENT
		FROM dbo.ActTable
		WHERE ACT_ID = @ACT

		SELECT @TXT =
			'Акт от ' + CONVERT(VARCHAR(20), ACT_DATE, 104) +
			CASE
				WHEN ACT_ID_INVOICE IS NULL THEN ''
				ELSE ', сч/ф №' +
					(
						SELECT CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR)
						FROM dbo.InvoiceSaleTable
						WHERE INS_ID = ACT_ID_INVOICE
					)
			END +
			CASE
				WHEN ACT_SIGN IS NULL THEN ''
				ELSE ', подписан ' + CONVERT(VARCHAR(20), ACT_SIGN, 104)
			END +
			CASE ACT_PRINT
				WHEN 1 THEN ', Напечатан'
				ELSE ''
			END + ', сумма: ' +
			(
				SELECT dbo.MoneyFormat(SUM(AD_TOTAL_PRICE))
				FROM dbo.ActDistrTable
				WHERE AD_ID_ACT = @ACT
			)
		FROM dbo.ActTable
		WHERE ACT_ID = @ACT

		SET @TXT = @TXT + '('

		SELECT @TXT = @TXT +
			CONVERT(VARCHAR(20), a.PR_DATE, 104) +
				':' +
					REVERSE(STUFF(REVERSE(
						(
							SELECT DIS_STR + ' - ' + dbo.MoneyFormat(AD_TOTAL_PRICE) + ', '
							FROM
								dbo.ActDistrTable
								INNER JOIN dbo.DistrView WITH(NOEXPAND) ON AD_ID_DISTR = DIS_ID
							WHERE AD_ID_ACT = @ACT AND AD_ID_PERIOD = PR_ID
							ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM FOR XML PATH('')
						)), 1, 2, ''))
					+ ')' + CHAR(10)
		FROM
			(
				SELECT DISTINCT PR_DATE, PR_ID
				FROM
					dbo.ActDistrTable
					INNER JOIN dbo.PeriodTable ON AD_ID_PERIOD = PR_ID
				WHERE AD_ID_ACT = @ACT
			) AS a


		SET @TXT = LEFT(@TXT, LEN(@TXT) - 1)

		SET @TXT = @TXT + ')'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
