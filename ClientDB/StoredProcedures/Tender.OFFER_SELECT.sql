USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[OFFER_SELECT]
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
			a.ID, a.DATE, b.SHORT, c.NAME AS TX_NAME,
			(
				SELECT COUNT(DISTINCT CLIENT)
				FROM Tender.OfferDetail z
				WHERE z.ID_OFFER = a.ID
			) AS CL_COUNT,
			(
				SELECT COUNT(*)
				FROM Tender.OfferDetail z
				WHERE z.ID_OFFER = a.ID
			) AS DIS_COUNT
		FROM
			Tender.Offer a
			INNER JOIN dbo.Vendor b ON a.ID_VENDOR = b.ID
			INNER JOIN Common.Tax c ON a.ID_TAX = c.ID
		WHERE a.STATUS = 1
			AND a.ID_TENDER = @TENDER
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
GRANT EXECUTE ON [Tender].[OFFER_SELECT] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[OFFER_SELECT] TO rl_tender_u;
GO