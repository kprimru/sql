USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_DETAIL_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID, 
		VARIANT, CASE ISNULL(VARIANT, 0) WHEN 0 THEN '<<���>>' ELSE '������� ' + CONVERT(VARCHAR(20), VARIANT) END AS VARIANT_NAME,
		ID_OPERATION, OPER_NAME, ID_TAX, TAX_NAME, ID_ACTION, ACT_NAME, ID_PERIOD, PR_NAME, MON_CNT,
		ID_SYSTEM, ID_OLD_SYSTEM, ID_NEW_SYSTEM, SYS_STR, ID_NET, ID_OLD_NET, ID_NEW_NET, NET_STR,
		DELIVERY_DISCOUNT, SUPPORT_DISCOUNT, FURTHER_DISCOUNT,
		DELIVERY_INFLATION, SUPPORT_INFLATION, FURTHER_INFLATION,
		DEL_FREE,
		DELIVERY_ORIGIN, DELIVERY_PRICE, SUPPORT_ORIGIN, SUPPORT_PRICE, SUPPORT_FURTHER,
		ISNULL(DELIVERY_PRICE, 0) + ISNULL(SUPPORT_PRICE, 0) AS TOTAL_PRICE,
		OLD_SYSTEM_DISCOUNT, FURTHER_RND
	FROM Price.CommercialOfferView
	WHERE ID_OFFER = @ID
	ORDER BY VARIANT, SYS_ORDER
END
