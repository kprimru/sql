USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[OFFER_DETAIL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[OFFER_DETAIL_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Tender].[OFFER_DETAIL_SELECT]
	@ID	UNIQUEIDENTIFIER
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
			ID, ID_CLIENT, CLIENT, ADDRESS,
			CLIENT + ' (' + ADDRESS + ')' AS CL_STR,
			ID_SYSTEM, ID_OLD_SYSTEM, DISTR, ID_NET, ID_OLD_NET,
			CASE
				WHEN d.SystemID IS NULL OR d.SystemID = b.SystemID THEN b.SystemShortName
				ELSE 'с ' + d.SystemShortName + ' на ' + b.SystemShortName
			END AS SYS_STR,
			CASE
				WHEN e.DistrTypeID IS NULL OR e.DistrTypeID = c.DistrTypeID THEN c.DistrTypeName
				ELSE 'с ' + e.DistrTypeName + ' на ' + c.DistrTypeName
			END AS NET_STR,
			DELIVERY_BASE, DELIVERY,
			EXCHANGE_BASE, EXCHANGE,
			ACTUAL_BASE, ACTUAL,
			SUPPORT_BASE, SUPPORT,
			SUPPORT_TOTAL,
			MON_CNT
		FROM
			Tender.OfferDetail a
			INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
			INNER JOIN dbo.DistrTypeTable c ON a.ID_NET = c.DistrTypeID
			LEFT OUTER JOIN dbo.SystemTable d ON a.ID_OLD_SYSTEM = d.SystemID
			LEFT OUTER JOIN dbo.DistrTypeTable e ON a.ID_OLD_NET = e.DistrTypeID
		WHERE a.ID_OFFER = @ID
		ORDER BY CLIENT, ADDRESS, b.SystemOrder, DISTR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[OFFER_DETAIL_SELECT] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[OFFER_DETAIL_SELECT] TO rl_tender_u;
GO
