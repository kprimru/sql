USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_SIMPLE]
	@ID	UNIQUEIDENTIFIER
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	SELECT
		SYS_FULL_STR AS SYSTEM, NET_STR_SHORT AS NET_SHORT, NET_STR AS NET, ISNULL(b.REG, d.REG) AS SYS_REG,
		ISNULL(b.ORD, d.ORD) AS SYS_ORDER,
		Common.MoneyFormat(DELIVERY_ORIGIN) AS DELIVERY_ORIGIN,
		Common.MoneyFormat(DELIVERY_PRICE) AS DELIVERY_PRICE,
		Common.MoneyFormat(SUPPORT_PRICE) AS SUPPORT_PRICE,
		Common.MoneyFormat(SUPPORT_FURTHER) AS SUPPORT_FURTHER,
		ISNULL(e.NOTE_WTITLE, f.NOTE_WTITLE) AS SYSTEM_NOTE,
		ISNULL(e.NOTE, f.NOTE) AS SYSTEM_NOTE_FULL,
		ISNULL(a.DOCS, a.NEW_DOCS) AS DOCS,
		a.OPER_STRING AS OPER, a.OPER_UNDERLINE,
		CHAR(10) + a.DEL_DISCOUNT_STR AS DEL_DISCOUNT_STR,
		CHAR(10) + a.SUP_DISCOUNT_STR AS SUP_DISCOUNT_STR,
		CHAR(10) + a.FUR_DISCOUNT_STR AS FUR_DISCOUNT_STR,
		g.SUPPORT AS MON_CNT
	FROM
		Price.CommercialOfferView a
		LEFT OUTER JOIN System.Systems b ON a.ID_SYSTEM = b.ID
		--LEFT OUTER JOIN dbo.SystemTable c ON a.ID_OLD_SYSTEM = c.SystemID
		LEFT OUTER JOIN System.Systems d ON a.ID_NEW_SYSTEM = d.ID
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable z ON z.SystemBaseName = b.REG
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable y ON y.SystemBaseName = d.REG
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemNote e ON e.ID_SYSTEM = z.SystemID
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemNote f ON f.ID_SYSTEM = y.SystemID
		LEFT OUTER JOIN Price.Action g ON g.ID = a.ID_ACTION
	WHERE ID_OFFER = @ID
	--ORDER BY b.SystemOrder, c.SystemOrder
	ORDER BY
		CASE
			WHEN RN = 1 THEN 2
			WHEN RN = (SELECT MAX(RN) FROM Price.CommercialOfferView WHERE ID_OFFER = @ID) THEN 1
			ELSE RN
		END
END
GO
