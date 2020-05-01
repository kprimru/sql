USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[TENDER_TAKE_MONEY]
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

		DECLARE @LAST_DATE	DATETIME
		SELECT
			t.CLIENT AS [Наименование заказчика],
			SHORT AS [Базис/К-Прим],
			p.CLAIM_PRIVISION AS [Сумма обеспечения заявки],
			p.GK_DATE AS [Дата заключения контракта],
			dbo.GetLastWedFri(p.GK_DATE) AS [Срок возврата],
			TS_SHORT AS [Эл. пл.],
			GK_SUM AS [НМЦК],
			NOTICE_NUM AS [Номер извещения],
			DATE AS [Дата извещения]
		FROM
			Tender.Tender t
			INNER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
			INNER JOIN dbo.Vendor v ON p.ID_VENDOR = v.ID
			INNER JOIN Purchase.TradeSite TS on p.ID_TRADESITE = ts.TS_ID
		WHERE	ID_STATUS = (
						SELECT ID
						FROM Tender.Status
						WHERE PSEDO = 'CONTRACT'
							) AND
				(DATEPART(m, p.GK_DATE) = DATEPART(m, GETDATE()))AND
				(DATEPART(yy, p.GK_DATE) = DATEPART(yy, GETDATE())) AND
				p.CLAIM_PRIVISION IS NOT NULL AND p.CLAIM_PRIVISION <> ''

		UNION ALL

		SELECT
			'Итого :', NULL, SUM(p.CLAIM_PRIVISION), NULL, NULL, NULL, NULL, NULL, NULL
		FROM
			Tender.Tender t
			INNER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
			INNER JOIN dbo.Vendor v ON p.ID_VENDOR = v.ID
			INNER JOIN Purchase.TradeSite TS on p.ID_TRADESITE = ts.TS_ID
		WHERE	ID_STATUS = (
						SELECT ID
						FROM Tender.Status
						WHERE PSEDO = 'CONTRACT'
							) AND
				(DATEPART(m, p.GK_DATE) = DATEPART(m, GETDATE()))AND
				(DATEPART(yy, p.GK_DATE) = DATEPART(yy, GETDATE())) AND
				p.CLAIM_PRIVISION IS NOT NULL AND p.CLAIM_PRIVISION <> ''

		--ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[TENDER_TAKE_MONEY] TO rl_report;
GO