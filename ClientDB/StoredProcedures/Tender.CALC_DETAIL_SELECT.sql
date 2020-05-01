USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[CALC_DETAIL_SELECT]
	@DATA	NVARCHAR(MAX)
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

		DECLARE @XML XML

		SET @XML = CAST(@DATA AS XML)

		DECLARE @DefaultTax UNIQUEIDENTIFIER

		SELECT @DefaultTax = ID
		FROM Common.TaxDefaultSelect(NULL)

		SELECT
			SYS_ID, SYS_OLD_ID, SYS_STR, DISTR, NET_ID, NET_OLD_ID, NET_STR, NET_COEF, NET_RND,
			SystemTypeID, SystemTypeName, MON_ID, MON_NAME, DISCOUNT, INFLATION,
			LOC_PRICE, PRICE, MON_CNT, TAX_ID,

			CONVERT(MONEY, ROUND(LOC_PRICE * NET_COEF, NET_RND)) AS NET_PRICE,

			CONVERT(MONEY, ROUND(PRICE * TAX_RATE, 2)) AS NDS, CONVERT(MONEY, PRICE + ROUND(PRICE * TAX_RATE, 2)) AS PRICE_NDS,
			CONVERT(MONEY, MON_CNT * (PRICE + ROUND(PRICE * TAX_RATE, 2))) AS TOTAL_PRICE
		FROM
			(
				SELECT
					SYS_ID, SYS_OLD_ID,
					CASE
						WHEN SYS_OLD_ID IS NOT NULL THEN 'с ' + z.SystemShortName + ' на ' + b.SystemShortName
						ELSE b.SystemShortName
					END AS SYS_STR,
					DISTR, NET_ID, NET_OLD_ID,
					CASE
						WHEN NET_OLD_ID IS NOT NULL THEN 'с ' + y.DistrTypeName + ' на ' + c.DistrTypeName
						ELSE c.DistrTypeName
					END AS NET_STR,
					SystemTypeID, SystemTypeName,
					MON_ID, e.NAME AS MON_NAME, DISCOUNT, INFLATION,
					d.PRICE AS LOC_PRICE,
					dbo.DistrCoef(SYS_ID, NET_ID, f.SystemTypeName, e.START) AS NET_COEF,
					dbo.DistrCoefRound(SYS_ID, NET_ID, f.SystemTypeName, e.START) AS NET_RND,
					a.PRICE, MON_CNT,
					b.SystemOrder, t.TAX_RATE, TAX_ID
				FROM
					(
						SELECT
							c.value('(@sys)', 'INT') AS SYS_ID,
							c.value('(@sys_old)', 'INT') AS SYS_OLD_ID,
							c.value('(@distr)', 'VARCHAR(20)') AS DISTR,
							c.value('(@net)', 'INT') AS NET_ID,
							c.value('(@net_old)', 'INT') AS NET_OLD_ID,
							c.value('(@type)', 'INT') AS TP_ID,
							c.value('(@month)', 'UNIQUEIDENTIFIER') AS MON_ID,
							c.value('(@discount)', 'DECIMAL(6, 2)') AS DISCOUNT,
							c.value('(@inflation)', 'DECIMAL(6, 2)') AS INFLATION,
							c.value('(@price)', 'MONEY') AS PRICE,
							ISNULL(c.value('(@tax)', 'UNIQUEIDENTIFIER'), @DefaultTax) AS TAX_ID,
							ISNULL(c.value('(@mon_cnt)', 'INT'), 0) AS MON_CNT
						FROM @xml.nodes('/root/item') AS a(c)
					) AS a
					INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
					INNER JOIN dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
					INNER JOIN Common.Period e ON e.ID = a.MON_ID
					INNER JOIN dbo.SystemTypeTable f ON f.SystemTypeID = a.TP_ID
					INNER JOIN Price.SystemPrice d ON d.ID_MONTH = a.MON_ID AND d.ID_SYSTEM = a.SYS_ID
					INNER JOIN Common.Tax t ON t.ID = a.TAX_ID
					LEFT OUTER JOIN dbo.SystemTable z ON z.SystemID = a.SYS_OLD_ID
					LEFT OUTER JOIN dbo.DistrTypeTable y ON y.DistrTypeID = a.NET_OLD_ID
			) AS o_O
		ORDER BY SystemOrder, NET_COEF

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Tender].[CALC_DETAIL_SELECT] TO public;
GRANT EXECUTE ON [Tender].[CALC_DETAIL_SELECT] TO rl_tender_u;
GO