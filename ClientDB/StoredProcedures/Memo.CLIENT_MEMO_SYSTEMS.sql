USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[CLIENT_MEMO_SYSTEMS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[CLIENT_MEMO_SYSTEMS]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Memo].[CLIENT_MEMO_SYSTEMS]
	@LIST	NVARCHAR(MAX),
	-- тип списка.
	-- NULL - все
	-- 1 - информационка
	-- 2 - поставка
	@TP		SMALLINT = NULL,
	@DATE	SMALLDATETIME = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@XML XML,
		@DefaultTax UNIQUEIDENTIFIER,
		@Setting_PRICE_COEF	Decimal(8, 2);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @XML = CAST(@LIST AS XML);

		SELECT @DefaultTax = ID
		FROM Common.TaxDefaultSelect(@DATE);

		SET @Setting_PRICE_COEF = Cast([Maintenance].[GlobalSetting@Get]('PRICE_COEF') AS Decimal(8, 2));

		SELECT
			SystemID, SystemShortName, SystemFullName, SystemOrder,
			DistrTypeID, DistrTypeName, DistrTypeCoef, DistrTypeRound,
			MON_ID, MON_NAME, DISCOUNT, INFLATION, TAX_ID, TAX_NAME, TAX_RATE, TOTAL_RATE,
			SystemTypeID, SystemTypeName, DISTR,
			PRICE,
			[DistrPrice] AS PRICE_NET,
			PRICE_TOTAL,
			CONVERT(MONEY, ROUND(PRICE_TOTAL * TOTAL_RATE, 2) - PRICE_TOTAL) AS PRICE_NDS,
			CONVERT(MONEY, ROUND(PRICE_TOTAL * TOTAL_RATE, 2)) AS PRICE_TOTAL_NDS,
			MON_CNT, CONVERT(MONEY, ROUND(PRICE_TOTAL * TOTAL_RATE, 2)) * MON_CNT AS PRICE_TOTAL_MON_NDS,
			DELIVERY, NOTE,
			CONVERT(MONEY, ROUND(DELIVERY * TOTAL_RATE, 2) - DELIVERY) AS DELIVERY_NDS,
			CONVERT(MONEY, ROUND(DELIVERY * TOTAL_RATE, 2)) AS DELIVERY_TOTAL_NDS,
			@Setting_PRICE_COEF AS PRICE_COEF
		FROM
		(
			SELECT
				SystemID, SystemShortName, SystemOrder, DistrTypeID, DistrTypeName, DistrTypeCoef, DistrTypeRound,
				MON_ID, MON_NAME, DISCOUNT, INFLATION, SystemTypeID, SystemTypeName, DISTR,
				MON_CNT,
				CASE WHEN ISNULL(DELIVERY, 0) = 0 THEN PRICE ELSE 0 END AS PRICE,
				CASE WHEN ISNULL(DELIVERY, 0) = 0 THEN CONVERT(MONEY, Round(@Setting_PRICE_COEF * ROUND(ROUND(PRICE * DistrTypeCoef, DistrTypeRound) * (100 - DISCOUNT) / 100 * (1 + INFLATION / 100.0), 0), 2)) ELSE 0 END AS PRICE_TOTAL,
				DELIVERY, NOTE,
				DP.[DistrPrice],
				TAX_ID, TAX_NAME, TAX_RATE, TOTAL_RATE,
				SystemFullName
			FROM
			(
				SELECT
					b.SystemID, SystemShortName, b.SystemOrder, DistrTypeID, DistrTypeName,
					PC.[DistrCoef] AS DistrTypeCoef,
					PC.[DistrCoefRound] AS DistrTypeRound,
					e.ID AS MON_ID, e.NAME AS MON_NAME, DISCOUNT, INFLATION,
					SystemTypeID, SystemTypeName, DISTR,
					MON_CNT, PC.[Price],
					t.ID AS TAX_ID, t.NAME AS TAX_NAME, TAX_RATE, TOTAL_RATE,

					DELIVERY, NOTE,
					b.SystemFullName AS SystemFullName
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
							ISNULL(c.value('(@tax)', 'UNIQUEIDENTIFIER'), @DefaultTax) AS TAX_ID,
							CONVERT(MONEY, c.value('(@delivery)', 'DECIMAL(10, 4)')) AS DELIVERY,
							ISNULL(c.value('(@mon_cnt)', 'INT'), 0) AS MON_CNT
						FROM @xml.nodes('/root/item') AS a(c)
					) AS a
					INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
					INNER JOIN dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
					INNER JOIN Common.Period e ON e.ID = a.MON_ID
					LEFT JOIN dbo.SystemTypeTable f ON f.SystemTypeID = a.TP_ID
					LEFT JOIN Common.Tax t ON t.ID = a.TAX_ID
					OUTER APPLY
					(
						SELECT
							[Price],
							[DistrCoef],
							[DistrCoefRound]
						FROM [Price].[DistrPriceWrapper](b.SystemID, DistrTypeID, f.SystemTypeID, f.SystemTypeName, e.START)
					) AS PC
			) AS o_O
			OUTER APPLY
			(
				SELECT [DistrPrice] = [dbo].[DistrPrice](PRICE, DistrTypeCoef, DistrTypeRound)
			) AS DP
		) AS o_O
		WHERE (@TP IS NULL OR @TP = 1 AND ISNULL(DELIVERY, 0) = 0 OR @TP = 2 AND ISNULL(DELIVERY, 0) <> 0)
		ORDER BY SystemOrder, DistrTypeCoef

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_SYSTEMS] TO rl_client_memo_r;
GO
