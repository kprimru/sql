USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[OFFER_DETAIL_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[OFFER_DETAIL_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[OFFER_DETAIL_PRINT]
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
			RN					AS DETAIL_NUM,
			a.CLIENT			AS DETAIL_CLIENT,
			a.ADDRESS			AS DETAIL_ADDRESS,
			c.SystemFullName	AS DETAIL_SYSTEM,
			d.DistrTypeName		AS DETAIL_NET,
			DISTR				AS DETAIL_DISTR,
			DELIVERY			AS DETAIL_DELIVERY,
			ACTUAL				AS DETAIL_ACTUAL,
			EXCHANGE			AS DETAIL_EXCHANGE,
			SUPPORT				AS DETAIL_SUPPORT,
			SUPPORT_TOTAL		AS DETAIL_SUPPORT_TOTAL,
			(
				SELECT COUNT(*)
				FROM Tender.OfferDetail z
				WHERE z.ID_OFFER = a.ID_OFFER
					AND z.CLIENT = a.CLIENT
					AND z.ADDRESS = a.ADDRESS
			)					AS DETAIL_CNT
		FROM
			Tender.OfferDetail a
			INNER JOIN
				(
					SELECT ROW_NUMBER() OVER(PARTITION BY z.CLIENT, z.ADDRESS ORDER BY z.CLIENT, z.ADDRESS) AS RN, z.CLIENT, z.ADDRESS
					FROM
						(
							SELECT DISTINCT CLIENT, ADDRESS
							FROM Tender.OfferDetail y
							WHERE ID_OFFER = @ID
						) AS z
				) b ON a.CLIENT = b.CLIENT AND a.ADDRESS = b.ADDRESS
			INNER JOIN dbo.SystemTable c ON a.ID_SYSTEM = c.SystemID
			INNER JOIN dbo.DistrTypeTable d ON a.ID_NET = d.DistrTypeID
		WHERE ID_OFFER = @ID
		ORDER BY a.CLIENT, a.ADDRESS, c.SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
