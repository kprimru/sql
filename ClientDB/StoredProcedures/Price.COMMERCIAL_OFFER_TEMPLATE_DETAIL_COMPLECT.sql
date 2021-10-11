USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_COMPLECT]
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
			SYS_FULL_STR AS SYSTEM, NET_STR AS NET, ISNULL(b.SystemBaseName, d.SystemBaseName) AS SYS_REG,
			ISNULL(b.SystemOrder, c.SystemOrder) AS SYS_ORDER,
			Common.MoneyFormat(DELIVERY_ORIGIN) AS DELIVERY_ORIGIN,
			Common.MoneyFormat(DELIVERY_PRICE) AS DELIVERY_PRICE,
			Common.MoneyFormat(SUPPORT_PRICE) AS SUPPORT_PRICE,
			Common.MoneyFormat(SUPPORT_FURTHER) AS SUPPORT_FURTHER,
			ISNULL(e.NoteWTitle, f.NoteWTitle) AS SYSTEM_NOTE,
			ISNULL(e.NOTE, f.NOTE) AS SYSTEM_NOTE_FULL,
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
		WHERE ID_OFFER = @ID AND Variant = 1
		ORDER BY
			CASE
				WHEN RN = 1 THEN 2
				WHEN RN = (SELECT MAX(RN) FROM Price.CommercialOfferView WHERE ID_OFFER = @ID) THEN 1
				ELSE RN
			END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
