USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[CLAIM_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[CLAIM_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[CLAIM_SELECT]
	@TENDER	UNIQUEIDENTIFIER
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
			ID, TP,
			CASE TP
				WHEN 1 THEN 'Обеспечение заявки'
				WHEN 2 THEN 'Обеспечение контракта'
				WHEN 3 THEN 'Оплата за участие'
				WHEN 4 THEN 'Оплата за тариф'
				WHEN 5 THEN 'Оплата за ЭЦП'
				WHEN 6 THEN 'Оплата за ЭДО'
				ELSE 'Неведома зверушка'
			END AS TP_STR,
			CLAIM_DATE
		FROM Tender.Claim
		WHERE ID_TENDER = @TENDER
		ORDER BY CLAIM_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[CLAIM_SELECT] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[CLAIM_SELECT] TO rl_tender_u;
GO
