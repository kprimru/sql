USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_SIMPLE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_SIMPLE]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_SIMPLE]
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
			[SortIndex] = CASE
				WHEN RN = 1 THEN 2
				WHEN RN = (SELECT MAX(RN) FROM Price.CommercialOfferView WHERE ID_OFFER = @ID) THEN 1
				ELSE RN
			END,
			[SortIndex2] = 1,
			SYS_FULL_STR AS SYSTEM, NET_STR AS NET, ISNULL(b.SystemBaseName, d.SystemBaseName) AS SYS_REG,
			ISNULL(b.SystemOrder, d.SystemOrder) AS SYS_ORDER,
			Common.MoneyFormat(DELIVERY_ORIGIN) AS DELIVERY_ORIGIN,
			Common.MoneyFormat(DELIVERY_PRICE) AS DELIVERY_PRICE,
			Common.MoneyFormat(SUPPORT_PRICE) AS SUPPORT_PRICE,
			Common.MoneyFormat(SUPPORT_FURTHER) AS SUPPORT_FURTHER,
			ISNULL(f.NoteWTitle, e.NoteWTitle) AS SYSTEM_NOTE,
			ISNULL(f.NOTE, e.NOTE) AS SYSTEM_NOTE_FULL,
			ISNULL(a.DOCS, a.NEW_DOCS) AS DOCS,
			a.OPER_STRING AS OPER, a.OPER_UNDERLINE,
			a.DEL_DISCOUNT_STR, a.SUP_DISCOUNT_STR, a.FUR_DISCOUNT_STR
		FROM
			Price.CommercialOfferView a
			LEFT OUTER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
			LEFT OUTER JOIN dbo.SystemTable c ON a.ID_OLD_SYSTEM = c.SystemID
			LEFT OUTER JOIN dbo.SystemTable d ON a.ID_NEW_SYSTEM = d.SystemID
			OUTER APPLY dbo.[System@Get?Note](IsNull(b.SystemID, c.SystemID), IsNull(a.ID_NET, a.ID_OLD_NET)) AS e
			OUTER APPLY dbo.[System@Get?Note](d.SystemID, a.ID_NEW_NET) AS f
		WHERE ID_OFFER = @ID

		UNION ALL

		SELECT
			[SortIndex] = CASE
				WHEN RN = 1 THEN 2
				WHEN RN = (SELECT MAX(RN) FROM Price.CommercialOfferView WHERE ID_OFFER = @ID) THEN 1
				ELSE RN
			END,
			[SortIndex2] = 1,
			'Подключение ' + SYS_FULL_STR AS SYSTEM, NET_STR AS NET, ISNULL(b.SystemBaseName, d.SystemBaseName) AS SYS_REG,
			ISNULL(b.SystemOrder, d.SystemOrder) AS SYS_ORDER,
			Common.MoneyFormat(CONNECT_PRICE) AS DELIVERY_ORIGIN,
			Common.MoneyFormat(CONNECT_PRICE) AS DELIVERY_PRICE,
			Common.MoneyFormat(0) AS SUPPORT_PRICE,
			Common.MoneyFormat(0) AS SUPPORT_FURTHER,
			ISNULL(f.NoteWTitle, e.NoteWTitle) AS SYSTEM_NOTE,
			ISNULL(f.NOTE, e.NOTE) AS SYSTEM_NOTE_FULL,
			ISNULL(a.DOCS, a.NEW_DOCS) AS DOCS,
			a.OPER_STRING AS OPER, a.OPER_UNDERLINE,
			a.DEL_DISCOUNT_STR, a.SUP_DISCOUNT_STR, a.FUR_DISCOUNT_STR
		FROM
			Price.CommercialOfferView a
			LEFT OUTER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
			LEFT OUTER JOIN dbo.SystemTable c ON a.ID_OLD_SYSTEM = c.SystemID
			LEFT OUTER JOIN dbo.SystemTable d ON a.ID_NEW_SYSTEM = d.SystemID
			OUTER APPLY dbo.[System@Get?Note](IsNull(b.SystemID, c.SystemID), IsNull(a.ID_NET, a.ID_OLD_NET)) AS e
			OUTER APPLY dbo.[System@Get?Note](d.SystemID, a.ID_NEW_NET) AS f
		WHERE ID_OFFER = @ID
			AND a.CONNECT_PRICE IS NOT NULL
			AND a.CONNECT_PRICE != 0

		ORDER BY [SortIndex], [SortIndex2] DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
