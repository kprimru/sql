USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_OPTIMIZE_2]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_OPTIMIZE_2]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_TEMPLATE_DETAIL_OPTIMIZE_2]
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

		IF (
				SELECT COUNT(*)
				FROM Price.CommercialOfferView
				WHERE ID_OFFER = @ID
					AND VARIANT = 1
			) <>
			(
				SELECT COUNT(*)
				FROM Price.CommercialOfferView
				WHERE ID_OFFER = @ID
					AND VARIANT = 1
			)
		BEGIN
			RAISERROR ('Количество записей в каждом варианте должно быть одинаковое!', 16, 1)
			RETURN
		END


		SELECT 
			t.SYS_FULL_STR AS SYSTEM, NET_STR AS NET, SYS_REG,	SYS_ORDER,
			SYSTEM_NOTE, SYSTEM_NOTE_FULL, DOCS,
			Common.MoneyFormat((
				SELECT DELIVERY_PRICE
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 1
					AND ID_OFFER = @ID
			)) AS DELIVERY_1,
			Common.MoneyFormat((
				SELECT DELIVERY_PRICE
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 2
					AND ID_OFFER = @ID
			)) AS DELIVERY_2,
			Common.MoneyFormat((
				SELECT SUPPORT_PRICE
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 1
					AND ID_OFFER = @ID
			)) AS SUPPORT_1,
			Common.MoneyFormat((
				SELECT SUPPORT_PRICE
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 2
					AND ID_OFFER = @ID
			)) AS SUPPORT_2,
			(
				SELECT DEL_DISCOUNT_STR
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 1
					AND ID_OFFER = @ID
			) AS DEL_DISCOUNT_STR_1,
			(
				SELECT DEL_DISCOUNT_STR
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 2
					AND ID_OFFER = @ID
			) AS DEL_DISCOUNT_STR_2,
			(
				SELECT SUP_DISCOUNT_STR
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 1
					AND ID_OFFER = @ID
			) AS SUP_DISCOUNT_STR_1,
			(
				SELECT SUP_DISCOUNT_STR
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 2
					AND ID_OFFER = @ID
			) AS SUP_DISCOUNT_STR_2,
			(
				SELECT FUR_DISCOUNT_STR
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 1
					AND ID_OFFER = @ID
			) AS FUR_DISCOUNT_STR_1,
			(
				SELECT FUR_DISCOUNT_STR
				FROM Price.CommercialOfferView z
				WHERE t.SYS_STR = z.SYS_STR AND t.NET_STR = z.NET_STR
					AND VARIANT = 2
					AND ID_OFFER = @ID
			) AS FUR_DISCOUNT_STR_2,
			OPER, OPER_UNDERLINE, NOTE
		FROM
			(
				SELECT
					MIN(RN) AS RN_MIN,
					MAX(RN) AS RN_MAX,
					SYS_STR, SYS_FULL_STR, NET_STR, ISNULL(b.SystemBaseName, d.SystemBaseName) AS SYS_REG,
					ISNULL(b.SystemOrder, d.SystemOrder) AS SYS_ORDER,
					b.SystemOrder AS BORDER, c.SystemOrder AS CORDER,
					ISNULL(f.NoteWTitle, e.NoteWTitle) AS SYSTEM_NOTE,
					ISNULL(f.NOTE, e.NOTE) AS SYSTEM_NOTE_FULL,
					ISNULL(a.DOCS, a.NEW_DOCS) AS DOCS,
					a.OPER_STRING AS OPER, a.OPER_UNDERLINE, a.FULL_STR AS NOTE
				FROM
					Price.CommercialOfferView a
					LEFT OUTER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
					LEFT OUTER JOIN dbo.SystemTable c ON a.ID_OLD_SYSTEM = c.SystemID
					LEFT OUTER JOIN dbo.SystemTable d ON a.ID_NEW_SYSTEM = d.SystemID
					OUTER APPLY dbo.[System@Get?Note](IsNull(b.SystemID, c.SystemID), IsNull(a.ID_NET, a.ID_OLD_NET)) AS e
			        OUTER APPLY dbo.[System@Get?Note](d.SystemID, a.ID_NEW_NET) AS f
				WHERE a.ID_OFFER = @ID
				GROUP BY
					SYS_STR, SYS_FULL_STR, NET_STR, ISNULL(b.SystemBaseName, d.SystemBaseName),
					ISNULL(b.SystemOrder, d.SystemOrder),
					b.SystemOrder, c.SystemOrder,
					ISNULL(f.NoteWTitle, e.NoteWTitle),
					ISNULL(f.NOTE, e.NOTE),
					ISNULL(a.DOCS, a.NEW_DOCS),
					a.OPER_STRING, a.OPER_UNDERLINE, a.FULL_STR
			) AS t
		ORDER BY
			CASE
				WHEN RN_MIN = 1 THEN 2
				WHEN RN_MAX = (SELECT MAX(RN) FROM Price.CommercialOfferView WHERE ID_OFFER = @ID) THEN 1
				ELSE RN_MIN + 1
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
