USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[KGS_MEMO_CALC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[KGS_MEMO_CALC]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Memo].[KGS_MEMO_CALC]
	@LIST		NVARCHAR(MAX),
	@MONTH		UNIQUEIDENTIFIER,
	@KIND		TINYINT,
	@PRICE		MONEY,
	@MON_CNT	SMALLINT,
	@CURVED		TINYINT
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

		SET @XML = CAST(@LIST AS XML)

		DECLARE @TotalRate DECIMAL(8,4)

		DECLARE @DATE SMALLDATETIME

		SELECT @DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		IF @DATE >= '20181001'
			SET @DATE = '20190101'

		SELECT @TotalRate = TOTAL_RATE
		FROM Common.TaxDefaultSelect(@DATE)

		/*
		СТРОИМ СПИСОК С ЦЕНАМИ, ПОТОМ, ЕСЛИ НУЖНО ОТ ОБЩЕЙ СУММЫ - НАЧИНАЕМ ПРОПОРЦИОНАЛЬНО РАЗБИВАТЬ.
		ЕСЛИ НЕ НАДО - ТО НЕ РАЗБЮИВАЕМ
		*/

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				ID_CLIENT			INT,
				NUM					INT,
				SystemID			INT,
				SystemShortName		VARCHAR(50),
				SystemOrder			INT,
				DistrTypeID			INT,
				DistrTypeName		VARCHAR(50),
				DistrTypeCoef		DECIMAL(8, 4),
				DistrTypeOrder		INT,
				DISCOUNT			INT,
				INFLATION			DECIMAL(6, 2),
				SystemTypeID		INT,
				SystemTypeName		VARCHAR(50),
				DISTR				INT,
				COMP				TINYINT,
				MON_CNT				SMALLINT,
				PRICE				MONEY,
				TAX_PRICE			MONEY,
				TOTAL_PRICE			MONEY,
				TOTAL_PERIOD		MONEY
			)

		INSERT INTO #result
		SELECT
			CL_ID AS ID_CLIENT, CL_NUM AS NUM,
			SystemID, SystemShortName, SystemOrder,
			DistrTypeID, DistrTypeName, DistrTypeCoef, DistrTypeOrder,
			DISCOUNT, INFLATION,
			SystemTypeID, SystemTypeName,
			DISTR, COMP,
			@MON_CNT,
			PRICE_TOTAL AS PRICE,
			CONVERT(MONEY, ROUND(PRICE_TOTAL * @TotalRate, 2) - PRICE_TOTAL) AS TAX_PRICE,
			CONVERT(MONEY, ROUND(PRICE_TOTAL * @TotalRate, 2)) AS TOTAL_PRICE,
			CONVERT(MONEY, ROUND(PRICE_TOTAL * @TotalRate, 2)) * @MON_CNT AS TOTAL_PERIOD
		FROM
		(
			SELECT
				CL_ID, CL_NUM, DISTR, COMP,
				SystemID, SystemShortName, SystemOrder,
				DistrTypeID, DistrTypeName, DistrTypeCoef, DistrTypeOrder,
				SystemTypeID, SystemTypeName,
				DISCOUNT, INFLATION,
				[Price],

				CONVERT(MONEY,
					DP.[DistrPrice] *
					(100 - DISCOUNT) / 100 *
					(1 + INFLATION / 100.0), 0) AS PRICE_TOTAL
			FROM
			(
				SELECT
					CL_ID, CL_NUM, DISTR, COMP,
					b.SystemID, SystemShortName, b.SystemOrder,
					DistrTypeID, DistrTypeName,
					PC.[DistrCoef] AS DistrTypeCoef,
					PC.[DistrCoefRound] AS DistrTypeRound,
					DistrTypeOrder,
					SystemTypeID, SystemTypeName,
					DISCOUNT, INFLATION,
					PC.[Price]
				FROM
					(
						SELECT
							c.value('@client[1]', 'INT') AS CL_ID,
							c.value('@num[1]', 'INT') AS CL_NUM,
							c.value('@sys[1]', 'INT') AS SYS_ID,
							c.value('@distr[1]', 'INT') AS DISTR,
							c.value('@comp[1]', 'INT') AS COMP,
							c.value('@net[1]', 'INT') AS NET_ID,
							c.value('@type[1]', 'INT') AS TP_ID,
							c.value('@discount[1]', 'INT') AS DISCOUNT,
							c.value('@inflation[1]', 'DECIMAL(6, 2)') AS INFLATION
							FROM @xml.nodes('/root[1]/item') AS a(c)
						) AS a
					INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
					INNER JOIN dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
					INNER JOIN Common.Period e ON e.ID = @MONTH
					LEFT JOIN dbo.SystemTypeTable f ON f.SystemTypeID = a.TP_ID
					OUTER APPLY
					(
						SELECT
							[Price],
							[DistrCoef],
							[DistrCoefRound]
						FROM [Price].[DistrPriceWrapper](SystemID, DistrTypeID, SystemTypeID, SystemTypeName, START)
					) AS PC
			) AS o_O
			OUTER APPLY
			(
				SELECT [DistrPrice] = [dbo].[DistrPrice](PRICE, DistrTypeCoef, DistrTypeRound)
			) AS DP
		) AS o_O
		ORDER BY CL_NUM, SystemOrder, DistrTypeOrder

		IF @KIND = 1
		BEGIN
			SELECT
				*,
				dbo.DistrString(NULL, DISTR, COMP) AS DISTR_STR
			FROM #result
			ORDER BY NUM, SystemOrder, DistrTypeOrder
		END
		ELSE
		BEGIN
			DECLARE @SPLIT	TABLE
				(
					TP			TINYINT,
					SystemID	INT,
					DistrTypeID	INT,
					CNT			INT,
					PRICE		MONEY,
					TAX_PRICE	MONEY,
					TOTAL_PRICE	MONEY
				)

			INSERT INTO @SPLIT
				SELECT *
				FROM Memo.MemoSplit(@LIST, @MONTH, @MON_CNT, @PRICE)

			SELECT
				a.ID_CLIENT, a.NUM,
				a.SystemID, a.SystemShortName, a.SystemOrder,
				a.DistrTypeID, a.DistrTypeName, a.DistrTypeCoef, a.DistrTypeOrder,
				a.DISCOUNT, a.INFLATION,
				a.SystemTypeID, a.SystemTypeName,
				a.DISTR, a.COMP,
				CASE
					WHEN @MON_CNT = 1 OR @CURVED = 2 THEN @MON_CNT
					ELSE
						CASE
							WHEN EXISTS
								(
									SELECT *
									FROM @SPLIT
									WHERE TP = 2
								) THEN (@MON_CNT - 1)
							ELSE @MON_CNT
						END
				END AS MON_CNT,
				b.PRICE, b.TAX_PRICE, b.TOTAL_PRICE,
				CASE
					WHEN @MON_CNT = 1 OR @CURVED = 2 THEN b.TOTAL_PRICE
					ELSE
						CASE
							WHEN EXISTS
								(
									SELECT *
									FROM @SPLIT
									WHERE TP = 2
								) THEN b.TOTAL_PRICE * (@MON_CNT - 1)
							ELSE b.TOTAL_PRICE * @MON_CNT
						END
				END AS TOTAL_PERIOD,
				dbo.DistrString(NULL, DISTR, COMP) AS DISTR_STR
			FROM
				#result a
				INNER JOIN @SPLIT b ON a.SystemID = b.SystemID
									AND a.DistrTypeID = b.DistrTypeID
									AND TP = @CURVED
			ORDER BY NUM, SystemOrder, DistrTypeOrder
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
GRANT EXECUTE ON [Memo].[KGS_MEMO_CALC] TO rl_kgs_complect_calc;
GO
