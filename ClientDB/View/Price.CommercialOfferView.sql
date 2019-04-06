USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Price].[CommercialOfferView]
AS
	SELECT 	
		a.ID, a.ID_OFFER, VARIANT, ID_OPERATION, b.NAME AS OPER_NAME, 
		b.UNDERLINE_STRING AS OPER_UNDERLINE, b.STRING AS OPER_STRING, a.ID_TAX, c.NAME AS TAX_NAME, 
		a.ID_ACTION, d.NAME AS ACT_NAME, a.ID_PERIOD, e.NAME AS PR_NAME, MON_CNT,
		a.ID_SYSTEM, a.ID_OLD_SYSTEM, a.ID_NEW_SYSTEM,
		CASE 
			WHEN f.SystemID IS NOT NULL THEN f.SystemOrder
			ELSE g.SystemOrder
		END AS SYS_ORDER,
		CASE 
			WHEN f.SystemID IS NOT NULL THEN f.SystemShortName
			ELSE 'с ' + g.SystemShortName + ' на ' + h.SystemShortName
		END AS SYS_STR,
		CASE 
			WHEN f.SystemID IS NOT NULL THEN f.SystemFullName
			ELSE /*'с ' + g.SystemFullName + ' на ' + */h.SystemFullName
		END AS SYS_FULL_STR,
		a.ID_NET, a.ID_OLD_NET, a.ID_NEW_NET,
		CASE
			WHEN i.DistrTypeID IS NOT NULL THEN i.DistrTypeFull
			ELSE /*'с ' + j.DistrTypeFull + ' на ' + */k.DistrTypeFull
		END AS NET_STR,
		CASE 
			WHEN f.SystemID IS NOT NULL AND i.DistrTypeID IS NOT NULL THEN ''
			WHEN f.SystemID IS NOT NULL AND i.DistrTypeID IS NULL THEN 'с ' + j.DistrTypeFull + ' на ' + k.DistrTypeFull
			WHEN f.SystemID IS NULL AND i.DistrTypeID IS NOT NULL THEN 'с ' + g.SystemFullName + ' на ' + h.SystemFullName
			WHEN f.SystemID IS NULL AND i.DistrTypeID IS NULL THEN 'с ' + g.SystemFullName + ' ' + j.DistrTypeFull + ' на ' + h.SystemFullName + ' ' + k.DistrTypeFull
			ELSE '!!!ќЎ»Ѕ ј!!!'
		END AS FULL_STR,
		a.DELIVERY_DISCOUNT, a.SUPPORT_DISCOUNT, a.FURTHER_DISCOUNT, 
		a.DELIVERY_INFLATION, a.SUPPORT_INFLATION, a.FURTHER_INFLATION,
		a.DEL_FREE, a.DELIVERY_ORIGIN, a.DELIVERY_PRICE, a.SUPPORT_ORIGIN, a.SUPPORT_PRICE,
		a.SUPPORT_FURTHER,
		CASE ISNULL(z.DISCOUNT, 0)
			WHEN 0 THEN 
				CASE ISNULL(a.DELIVERY_DISCOUNT, 0)
					WHEN 0 THEN ''
					ELSE 'скидка ' + CONVERT(VARCHAR(20), CONVERT(INT, a.DELIVERY_DISCOUNT)) + ' %'
				END
			ELSE ''
		END AS DEL_DISCOUNT_STR,
		CASE ISNULL(z.DISCOUNT, 0)
			WHEN 0 THEN 
				CASE ISNULL(a.SUPPORT_DISCOUNT, 0)
					WHEN 0 THEN ''
					ELSE 'скидка ' + CONVERT(VARCHAR(20), CONVERT(INT, a.SUPPORT_DISCOUNT)) + ' %'
				END
			ELSE ''
		END AS SUP_DISCOUNT_STR,
		CASE ISNULL(z.DISCOUNT, 0)
			WHEN 0 THEN 
				CASE ISNULL(a.FURTHER_DISCOUNT, 0)
					WHEN 0 THEN ''
					ELSE 'скидка ' + CONVERT(VARCHAR(20), CONVERT(INT, a.FURTHER_DISCOUNT)) + ' %'
				END
			ELSE ''
		END AS FUR_DISCOUNT_STR,			
		ISNULL(d.SUPPORT, a.MON_CNT) AS TOTAL_MON_CNT,
		Common.MonthString(a.ID_PERIOD, ISNULL(d.SUPPORT, a.MON_CNT)) AS MON_STRING,
		OLD_SYSTEM_DISCOUNT, l.Docs, m.Docs AS OLD_DOCS, n.Docs AS NEW_DOCS,
		FURTHER_RND,
		ROW_NUMBER() OVER(PARTITION BY ID_OFFER ORDER BY f.SystemOrder, g.SystemOrder) AS RN
	FROM 
		Price.CommercialOffer z
		INNER JOIN Price.CommercialOfferDetail a ON z.ID = a.ID_OFFER
		INNER JOIN Price.CommercialOperation b ON a.ID_OPERATION = b.ID
		INNER JOIN Common.Tax c ON a.ID_TAX = c.ID
		LEFT OUTER JOIN Price.Action d ON a.ID_ACTION = d.ID
		LEFT OUTER JOIN Common.Period e ON a.ID_PERIOD = e.ID
		LEFT OUTER JOIN dbo.SystemTable f ON a.ID_SYSTEM = f.SystemID
		LEFT OUTER JOIN dbo.SystemTable g ON a.ID_OLD_SYSTEM = g.SystemID
		LEFT OUTER JOIN dbo.SystemTable h ON a.ID_NEW_SYSTEM = h.SystemID
		LEFT OUTER JOIN dbo.DistrTypeTable i ON a.ID_NET = i.DistrTypeID
		LEFT OUTER JOIN dbo.DistrTypeTable j ON a.ID_OLD_NET = j.DistrTypeID
		LEFT OUTER JOIN dbo.DistrTypeTable k ON a.ID_NEW_NET = k.DistrTypeID
		LEFT OUTER JOIN dbo.SystemDocsView l ON l.SystemID = f.SystemID
		LEFT OUTER JOIN dbo.SystemDocsView m ON m.SystemID = g.SystemID
		LEFT OUTER JOIN dbo.SystemDocsView n ON n.SystemID = h.SystemID
