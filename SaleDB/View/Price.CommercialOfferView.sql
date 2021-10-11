USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Price].[CommercialOfferView]
AS
	SELECT 
		a.ID, a.ID_OFFER, VARIANT, ID_OPERATION, b.NAME AS OPER_NAME,
		b.UNDERLINE_STRING AS OPER_UNDERLINE, b.STRING AS OPER_STRING, a.ID_TAX, c.NAME AS TAX_NAME,
		a.ID_ACTION, d.NAME AS ACT_NAME, a.ID_PERIOD, e.NAME AS PR_NAME, MON_CNT,
		a.ID_SYSTEM, a.ID_OLD_SYSTEM, a.ID_NEW_SYSTEM,
		CASE
			WHEN f.ID IS NOT NULL THEN f.ORD
			ELSE g.ORD
		END AS SYS_ORDER,
		CASE
			WHEN f.ID IS NOT NULL THEN f.SHORT
			ELSE '� ' + g.SHORT + ' �� ' + h.SHORT
		END AS SYS_STR,
		CASE
			WHEN f.ID IS NOT NULL THEN f.NAME
			ELSE /*'� ' + g.SystemFullName + ' �� ' + */h.NAME
		END AS SYS_FULL_STR,
		a.ID_NET, a.ID_OLD_NET, a.ID_NEW_NET,
		CASE
			WHEN i.ID IS NOT NULL THEN i.NAME
			ELSE /*'� ' + j.DistrTypeFull + ' �� ' + */k.NAME
		END AS NET_STR,
		CASE
			WHEN i.ID IS NOT NULL THEN i.SHORT
			ELSE '� ' + j.SHORT + ' �� ' + k.SHORT
		END AS NET_STR_SHORT,
		CASE
			WHEN f.ID IS NOT NULL AND i.ID IS NOT NULL THEN ''
			WHEN f.ID IS NOT NULL AND i.ID IS NULL THEN '� ' + j.NAME + ' �� ' + k.NAME
			WHEN f.ID IS NULL AND i.ID IS NOT NULL THEN '� ' + g.NAME + ' �� ' + h.NAME
			WHEN f.ID IS NULL AND i.ID IS NULL THEN '� ' + g.NAME + ' ' + j.NAME + ' �� ' + h.NAME + ' ' + k.NAME
			ELSE '!!!������!!!'
		END AS FULL_STR,
		a.DELIVERY_DISCOUNT, a.SUPPORT_DISCOUNT, a.FURTHER_DISCOUNT,
		a.DELIVERY_INFLATION, a.SUPPORT_INFLATION, a.FURTHER_INFLATION,
		a.DEL_FREE, a.DELIVERY_ORIGIN, a.DELIVERY_PRICE, a.SUPPORT_ORIGIN, a.SUPPORT_PRICE,
		a.SUPPORT_FURTHER,
		CASE ISNULL(z.DISCOUNT, 0)
			WHEN 0 THEN
				CASE ISNULL(a.DELIVERY_DISCOUNT, 0)
					WHEN 0 THEN ''
					ELSE '������ ' + CONVERT(VARCHAR(20), CONVERT(INT, a.DELIVERY_DISCOUNT)) + ' %'
				END
			ELSE ''
		END AS DEL_DISCOUNT_STR,
		CASE ISNULL(z.DISCOUNT, 0)
			WHEN 0 THEN
				CASE ISNULL(a.SUPPORT_DISCOUNT, 0)
					WHEN 0 THEN ''
					ELSE '������ ' + CONVERT(VARCHAR(20), CONVERT(INT, a.SUPPORT_DISCOUNT)) + ' %'
				END
			ELSE ''
		END AS SUP_DISCOUNT_STR,
		CASE ISNULL(z.DISCOUNT, 0)
			WHEN 0 THEN
				CASE ISNULL(a.FURTHER_DISCOUNT, 0)
					WHEN 0 THEN ''
					ELSE '������ ' + CONVERT(VARCHAR(20), CONVERT(INT, a.FURTHER_DISCOUNT)) + ' %'
				END
			ELSE ''
		END AS FUR_DISCOUNT_STR,
		ISNULL(d.SUPPORT, a.MON_CNT) AS TOTAL_MON_CNT,
		Common.MonthString(a.ID_PERIOD, ISNULL(d.SUPPORT, a.MON_CNT)) AS MON_STRING,
		OLD_SYSTEM_DISCOUNT,

		l.Docs, m.Docs AS OLD_DOCS, n.Docs AS NEW_DOCS,

		ROW_NUMBER() OVER(PARTITION BY ID_OFFER ORDER BY f.ORD, g.ORD) AS RN
	FROM
		Price.CommercialOffer z
		INNER JOIN Price.CommercialOfferDetail a ON z.ID = a.ID_OFFER
		INNER JOIN Price.CommercialOperation b ON a.ID_OPERATION = b.ID
		INNER JOIN Common.Tax c ON a.ID_TAX = c.ID
		LEFT OUTER JOIN Price.Action d ON a.ID_ACTION = d.ID
		LEFT OUTER JOIN Common.Month e ON a.ID_PERIOD = e.ID
		LEFT OUTER JOIN System.Systems f ON a.ID_SYSTEM = f.ID
		LEFT OUTER JOIN System.Systems g ON a.ID_OLD_SYSTEM = g.ID
		LEFT OUTER JOIN System.Systems h ON a.ID_NEW_SYSTEM = h.ID
		LEFT OUTER JOIN System.Net i ON a.ID_NET = i.ID
		LEFT OUTER JOIN System.Net j ON a.ID_OLD_NET = j.ID
		LEFT OUTER JOIN System.Net k ON a.ID_NEW_NET = k.ID
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemDocsView l ON l.SystemBaseName = f.REG
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemDocsView m ON m.SystemBaseName = g.REG
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemDocsView n ON n.SystemBaseName = h.REG
GO
