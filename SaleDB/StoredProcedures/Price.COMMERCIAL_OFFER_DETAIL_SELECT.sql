USE [SaleDB]
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
		1 AS TP,
		ID, 
		VARIANT, 
		CASE ISNULL(VARIANT, 0) 
			WHEN 0 THEN '<<���>>' 
			ELSE '������� ' + CONVERT(VARCHAR(20), VARIANT) 
		END AS VARIANT_NAME,
		ID_OPERATION, OPER_NAME, ID_TAX, TAX_NAME, ID_ACTION, ACT_NAME, ID_PERIOD, PR_NAME, MON_CNT,
		ID_SYSTEM, ID_OLD_SYSTEM, ID_NEW_SYSTEM, SYS_STR, SYS_ORDER,
		ID_NET, ID_OLD_NET, ID_NEW_NET, NET_STR_SHORT AS NET_STR,
		DELIVERY_DISCOUNT, SUPPORT_DISCOUNT, FURTHER_DISCOUNT,
		DELIVERY_INFLATION, SUPPORT_INFLATION, FURTHER_INFLATION,
		DEL_FREE,
		DELIVERY_ORIGIN, DELIVERY_PRICE, SUPPORT_ORIGIN, SUPPORT_PRICE, SUPPORT_FURTHER,
		ISNULL(DELIVERY_PRICE, 0) + ISNULL(SUPPORT_PRICE, 0) AS TOTAL_PRICE,
		OLD_SYSTEM_DISCOUNT
	FROM Price.CommercialOfferView
	WHERE ID_OFFER = @ID
	
	UNION ALL
	
	SELECT
		2 AS TP,
		a.ID, 
		NULL AS VARIANT, 
		NULL AS VARIANT_NAME,
		NULL AS ID_OPERATION, NULL AS OPER_NAME, ID_TAX, d.NAME AS TAX_NAME, NULL AS ID_ACTION, NULL AS ACT_NAME, ID_PERIOD, c.NAME AS PR_NAME, NULL AS MON_CNT,
		b.ID AS ID_SYSTEM, NULL AS ID_OLD_SYSTEM, NULL AS ID_NEW_SYSTEM, b.NAME AS SYS_STR, NULL,
		NULL AS ID_NET, NULL AS ID_OLD_NET, NULL AS ID_NEW_NET, NULL AS NET_STR,
		NULL AS DELIVERY_DISCOUNT, NULL AS SUPPORT_DISCOUNT, NULL AS FURTHER_DISCOUNT,
		NULL AS DELIVERY_INFLATION, NULL AS SUPPORT_INFLATION, NULL AS FURTHER_INFLATION,
		NULL AS DEL_FREE,
		NULL AS DELIVERY_ORIGIN, a.PRICE AS DELIVERY_PRICE, NULL AS SUPPORT_ORIGIN, NULL AS SUPPORT_PRICE, NULL AS SUPPORT_FURTHER,
		a.PRICE AS DELIVERY_PRICE,
		NULL AS OLD_SYSTEM_DISCOUNT
	FROM 
		Price.CommercialOfferOther a
		INNER JOIN Price.OtherService b ON a.ID_SERVICE = b.ID
		INNER JOIN Common.Month c ON a.ID_PERIOD = c.ID
		INNER JOIN Common.Tax d ON a.ID_TAX = d.ID
	WHERE ID_OFFER = @ID
	
	ORDER BY TP, VARIANT, SYS_ORDER
END