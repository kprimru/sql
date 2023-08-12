USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[TENDER_COMISSION]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[TENDER_COMISSION]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[TENDER_COMISSION]
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
			p.PART_SUM AS [Сумма , включая комиссию банку (8,00-35,00 руб.)],
			CASE DATEPART(dw, p.PROTOCOL)
				WHEN 1 THEN p.PROTOCOL + 2       --необходимо показать ближайшую среду или пятницу к дате протокола + 3 дня
				WHEN 2 THEN p.PROTOCOL + 1
				WHEN 3 THEN p.PROTOCOL
				WHEN 4 THEN p.PROTOCOL + 1
				WHEN 5 THEN p.PROTOCOL
				WHEN 6 THEN p.PROTOCOL + 4
				WHEN 7 THEN p.PROTOCOL + 3
			END	AS [Срок оплаты],
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
						WHERE PSEDO = 'TENDER'
							) AND
				p.PROTOCOL IS NOT NULL
			--	(DATEPART(m, p.GK_DATE) = DATEPART(m, GETDATE()))AND
			--	(DATEPART(yy, p.GK_DATE) = DATEPART(yy, GETDATE())) AND
			--	p.CLAIM_PRIVISION IS NOT NULL AND p.CLAIM_PRIVISION <> ''
		--ORDER BY DATE DESC

		UNION ALL

		SELECT
			'Итого : ', NULL, SUM(p.PART_SUM), NULL, NULL, NULL, NULL, NULL
		FROM
			Tender.Tender t
			INNER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
			INNER JOIN dbo.Vendor v ON p.ID_VENDOR = v.ID
			INNER JOIN Purchase.TradeSite TS on p.ID_TRADESITE = ts.TS_ID
		WHERE	ID_STATUS = (
						SELECT ID
						FROM Tender.Status
						WHERE PSEDO = 'TENDER'
							) AND
				p.PROTOCOL IS NOT NULL
			--	(DATEPART(m, p.GK_DATE) = DATEPART(m, GETDATE()))AND
			--	(DATEPART(yy, p.GK_DATE) = DATEPART(yy, GETDATE())) AND
			--	p.CLAIM_PRIVISION IS NOT NULL AND p.CLAIM_PRIVISION <> ''

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[TENDER_COMISSION] TO rl_tender_r;
GO
