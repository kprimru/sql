USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[TENDER_NEED_PAY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[TENDER_NEED_PAY]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[TENDER_NEED_PAY]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT
			t.CLIENT AS [Наименование заказчика],
			SHORT AS [Базис/К-Прим],
			p.CLAIM_PRIVISION AS [Сумма обеспечения заявки],
			CASE DATEPART(dw, p.DATE)
				WHEN 1 THEN p.DATE+2
				WHEN 2 THEN p.DATE+1
				WHEN 3 THEN p.DATE+2
				WHEN 4 THEN p.DATE+1
				WHEN 5 THEN p.DATE+5
				WHEN 6 THEN p.DATE+4
				WHEN 7 THEN p.DATE+3
			END AS [Срок оплаты],
			TS_SHORT AS [Эл. пл.],
			GK_SUM AS [НМЦК],
			NOTICE_NUM AS [Номер извещения],
			DATE AS [Дата извещения]
		FROM
			Tender.Tender t
			INNER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
			INNER JOIN dbo.Vendor v ON p.ID_VENDOR = v.ID
			INNER JOIN Purchase.TradeSite TS on p.ID_TRADESITE = ts.TS_ID
		WHERE ID_STATUS = (
						SELECT ID
						FROM Tender.Status
						WHERE PSEDO = 'TENDER'
							)


		UNION ALL

		SELECT
			'Итого : ', '', SUM(p.CLAIM_PRIVISION), NULL, NULL, NULL, NULL, NULL
		FROM
			Tender.Tender t
			INNER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
			INNER JOIN dbo.Vendor v ON p.ID_VENDOR = v.ID
			INNER JOIN Purchase.TradeSite TS on p.ID_TRADESITE = ts.TS_ID
		WHERE ID_STATUS = (
						SELECT ID
						FROM Tender.Status
						WHERE PSEDO = 'TENDER'
							)
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[TENDER_NEED_PAY] TO rl_report;
GO
