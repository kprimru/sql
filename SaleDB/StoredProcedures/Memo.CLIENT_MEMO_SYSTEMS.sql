USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_SYSTEMS]
	@LIST	NVARCHAR(MAX),
	-- тип списка.
	-- NULL - все
	-- 1 - информационка
	-- 2 - поставка
	@TP		SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML

	SET @XML = CAST(@LIST AS XML)

	SELECT
		SystemID, SystemShortName, SystemOrder,
		DistrTypeID, DistrTypeName, DistrTypeCoef, DistrTypeRound,
		MON_ID, MON_NAME, DISCOUNT, INFLATION,
		SystemTypeID, SystemTypeName, DISTR,
		PRICE,
		CONVERT(MONEY, ROUND(PRICE * DistrTypeCoef, DistrTypeRound)) AS PRICE_NET,
		PRICE_TOTAL,
		CONVERT(MONEY, ROUND(PRICE_TOTAL * 1.18, 2) - PRICE_TOTAL) AS PRICE_NDS,
		CONVERT(MONEY, ROUND(PRICE_TOTAL * 1.18, 2)) AS PRICE_TOTAL_NDS,
		MON_CNT, CONVERT(MONEY, ROUND(PRICE_TOTAL * 1.18, 2)) * MON_CNT AS PRICE_TOTAL_MON_NDS,
		DELIVERY, NOTE,
		CONVERT(MONEY, ROUND(DELIVERY * 1.18, 2) - DELIVERY) AS DELIVERY_NDS,
		CONVERT(MONEY, ROUND(DELIVERY * 1.18, 2)) AS DELIVERY_TOTAL_NDS
	FROM
		(
			SELECT
				b.SystemID, SystemShortName, b.SystemOrder, DistrTypeID, DistrTypeName, COEF AS DistrTypeCoef, RND AS DistrTypeRound, e.ID AS MON_ID, e.NAME AS MON_NAME, DISCOUNT, INFLATION,
				SystemTypeID, SystemTypeName, DISTR,
				MON_CNT,

				CASE WHEN ISNULL(DELIVERY, 0) = 0 THEN PRICE ELSE 0 END AS PRICE,
				CASE WHEN ISNULL(DELIVERY, 0) = 0 THEN CONVERT(MONEY, ROUND(ROUND(PRICE * COEF, RND) * (100 - DISCOUNT) / 100 * (1 + INFLATION / 100.0), 0)) ELSE 0 END AS PRICE_TOTAL,
				DELIVERY, NOTE
			FROM
				(
					SELECT 
						c.value('(@sys)', 'INT') AS SYS_ID,
						c.value('(@distr)', 'VARCHAR(20)') AS DISTR,
						c.value('(@net)', 'INT') AS NET_ID,
						c.value('(@type)', 'INT') AS TP_ID,
						c.value('(@month)', 'UNIQUEIDENTIFIER') AS MON_ID,
						c.value('(@discount)', 'DECIMAL(6, 2)') AS DISCOUNT,
						c.value('(@inflation)', 'DECIMAL(6, 2)') AS INFLATION,
						c.value('(@note)', 'NVARCHAR(128)') AS NOTE,
						CONVERT(MONEY, c.value('(@delivery)', 'DECIMAL(10, 4)')) AS DELIVERY,
						ISNULL(c.value('(@mon_cnt)', 'INT'), 0) AS MON_CNT
					FROM @xml.nodes('/root/item') AS a(c)
				) AS a
				INNER JOIN [PC275-SQL\ALPHA].CLientDB.dbo.SystemTable b ON a.SYS_ID = b.SystemID
				INNER JOIN [PC275-SQL\ALPHA].CLientDB.dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
				INNER JOIN [PC275-SQL\ALPHA].CLientDB.Price.SystemPrice d ON ID_MONTH = MON_ID AND ID_SYSTEM = SYS_ID
				INNER JOIN [PC275-SQL\ALPHA].CLientDB.Common.Period e ON e.ID = a.MON_ID
				INNER JOIN [PC275-SQL\ALPHA].CLientDB.dbo.DistrTypeCoef h ON h.ID_NET = DistrTypeID AND h.ID_MONTH = e.ID
				LEFT OUTER JOIN [PC275-SQL\ALPHA].CLientDB.dbo.SystemTypeTable f ON f.SystemTypeID = a.TP_ID
		) AS o_O
	WHERE (@TP IS NULL OR @TP = 1 AND ISNULL(DELIVERY, 0) = 0 OR @TP = 2 AND ISNULL(DELIVERY, 0) <> 0)
	ORDER BY SystemOrder, DistrTypeCoef
END
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_SYSTEMS] TO rl_client_memo_r;
GO