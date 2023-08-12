USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[TENDER_PROVISION]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[TENDER_PROVISION]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[TENDER_PROVISION]
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
			p.GK_PROVISION_SUM AS [Сумма обеспечения контракта],
			CASE DATEPART(dw, p.PROTOCOL + 3)
				WHEN 1 THEN p.PROTOCOL + 3 + 2       --необходимо показать ближайшую среду или пятницу к дате протокола + 3 дня
				WHEN 2 THEN p.PROTOCOL + 3 + 1
				WHEN 3 THEN p.PROTOCOL + 3
				WHEN 4 THEN p.PROTOCOL + 3 + 1
				WHEN 5 THEN p.PROTOCOL + 3
				WHEN 6 THEN p.PROTOCOL + 3 + 4
				WHEN 7 THEN p.PROTOCOL + 3 + 3
			END	AS [Срок оплаты],
			'' AS [Реквизиты организации],
			GK_SUM AS [НМЦК],
			GK_PROVISION_PRC AS [Размер обеспечения заявки в %],
			CONVERT(VARCHAR, GK_START, 104) + ' - ' + CONVERT(VARCHAR, GK_FINISH, 104) AS [Период действия ГК],
			'' AS [Срок возврата]
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
GRANT EXECUTE ON [Report].[TENDER_PROVISION] TO rl_report;
GO
