USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[TENDER_SUMMARY]
	@CURDATE	DATETIME
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
			p.DATE,-- AS [Дата размещения],
			p.CLAIM_PRIVISION,-- AS [Сумма обеспечения заявки],
			p.DATE + 6 AS [SPECBILL_TIME],-- AS [Срок внесения на спецсчет],
			p.DATE + 4 AS [REQUEST_DATE],-- AS [Дата подачи заявки],
			p.PROTOCOL AS [PROTOCOL_DATE],-- AS [Дата протокола],
			p.GK_PROVISION_SUM,-- AS [Сумма обеспечения контракта],
			p.PROTOCOL + 3 AS [TRANSACTION TIME],-- AS [Срок перевода на р/с Заказчика],
			p.PART_SUM,-- AS [Сумма оплаты эл. пл.],
			p.PROTOCOL + 3 AS [SPECBILL_TIME2],-- AS [Срок внесения на спецсчет],
			p.GK_SIGN_FACT,-- AS [Срок подписания ГК],
			dbo.GetLastWeekDay(4, @CURDATE) AS [CASHBACK_TIME],-- AS [Отзыв обеспечения заявки], -- последний четверг текущего месяца
			CONVERT(VARCHAR, p.GK_START, 4) + ' - ' + CONVERT(VARCHAR, p.GK_FINISH, 4) AS [GK_TIME],--	AS [Срок действия контракта],
			(SELECT COUNT(NAME)
			FROM Common.Period
			WHERE TYPE = 3 AND			--узнаем сколько кварталов будет затронуто
					FINISH > p.GK_START AND
					START < p.GK_FINISH) AS [QUART_COUNT],
			CONVERT(VARCHAR, CONVERT(INT, p.GK_PROVISION_SUM)/(SELECT COUNT(NAME)
												FROM Common.Period
												WHERE TYPE = 3 AND			--узнаем сколько кварталов будет затронуто
													FINISH > p.GK_START AND
													START < p.GK_FINISH)) AS [QUART_SUM],
			CONVERT(VARCHAR, CONVERT(INT, p.GK_PROVISION_SUM)/(SELECT COUNT(NAME)
												FROM Common.Period
												WHERE TYPE = 3 AND			--узнаем сколько кварталов будет затронуто
													FINISH > p.GK_START AND
													START < p.GK_FINISH) +  p.GK_PROVISION_SUM%(SELECT COUNT(NAME)
																								FROM Common.Period
																								WHERE TYPE = 3 AND			--узнаем сколько кварталов будет затронуто
																									FINISH > p.GK_START AND
																									START < p.GK_FINISH)) AS [LAST_QUART_SUM],
			CONVERT(VARCHAR, p.GK_PROVISION_SUM)	AS [CASHBACK]
		FROM
			Tender.Placement p
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
