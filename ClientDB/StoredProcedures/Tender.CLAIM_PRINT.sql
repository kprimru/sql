USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[CLAIM_PRINT]
	@ID		UNIQUEIDENTIFIER
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

			b.CLIENT, d.FULL_NAME AS VENDOR, e.TS_URL AS TRADESITE, a.CLAIM_DATE AS DATE_LIMIT,
			CASE a.TP
				WHEN 1 THEN CLAIM_PRIVISION
				WHEN 2 THEN c.GK_PROVISION_SUM
			END AS CLAIM_SUM,
			c.NOTICE_NUM + ' ' + CONVERT(NVARCHAR(32), c.DATE, 104) AS TENDER_DATA,
			a.PARAMS AS DETAILS, a.PROVISION_RETURN AS RTRN,
			CONVERT(NVARCHAR(32), GK_START, 104) + ' - ' + CONVERT(NVARCHAR(32), GK_FINISH, 104) + ', ' + CONVERT(NVARCHAR(12), GK_PROVISION_PRC) + '%, ' + CONVERT(NVARCHAR(32), GK_SUM) AS CONTRACT_DATA,
			PART_SUM, EDO_SUM, TARIFF_SUM, ECP_SUM
		FROM
			Tender.Claim a
			INNER JOIN Tender.Tender b ON a.ID_TENDER = b.ID
			INNER JOIN Tender.Placement c ON c.ID_TENDER = b.ID
			INNER JOIN Purchase.Tradesite e ON e.TS_ID = c.ID_TRADESITE
			LEFT OUTER JOIN dbo.Vendor d ON d.ID = c.ID_VENDOR
		WHERE a.ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[CLAIM_PRINT] TO rl_tender_u;
GO
