USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_FINANCING_IMPORT]
	@CLIENT	INT,
	@CALC	UNIQUEIDENTIFIER
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
		DECLARE @DATE SMALLDATETIME

		SELECT @XML = CONVERT(XML, SYSTEMS), @DATE = DATE
		FROM [PC275-SQL\ALPHA].ClientDB.Memo.ClientMemo
		WHERE ID = @CALC

		SELECT
			DF_ID, DIS_STR, SN_NAME, DF_FIXED_PRICE, DSS_NAME, b.PRICE,
			CASE
				WHEN DSS_REPORT = 0 AND b.PRICE IS NOT NULL THEN 2
				WHEN ISNULL(DF_FIXED_PRICE, 0) <> ISNULL(b.PRICE, 0) AND b.PRICE IS NOT NULL THEN 1
				ELSE 0
			END AS ERR,
			CASE
				WHEN b.PRICE IS NOT NULL THEN 1
				ELSE 0
			END AS CHECKED
		FROM
			(
				SELECT
					DF_ID, DIS_STR, DIS_ID, SN_ID,
					SN_NAME, PP_ID, PP_NAME, DF_MON_COUNT,
					DF_FIXED_PRICE, DF_DISCOUNT, PR_DATE AS DF_FIRST_MON, DSS_NAME, DSS_REPORT,
					SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, SYS_ORDER
				FROM dbo.DistrFinancingView
				WHERE CD_ID_CLIENT = @CLIENT
						AND DIS_ACTIVE = 1
			) a
			LEFT OUTER JOIN
			(
				SELECT SystemBaseName, DISTR, COMP, b.PRICE
				FROM
					[PC275-SQL\ALPHA].ClientDB.Memo.KGSMemo a
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.Memo.KGSMemoDistr b ON a.ID = b.ID_MEMO
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable c ON b.ID_SYSTEM = c.SystemID
				WHERE a.ID = @CALC

				UNION ALL

				SELECT
					SystemBaseName, DISTR, COMP, PRICE_TOTAL
				FROM
					(
						SELECT
							SystemBaseName,
							CASE CHARINDEX('/', DISTR)
								WHEN 0 THEN CONVERT(INT, DISTR)
								ELSE CONVERT(INT, LEFT(DISTR, CHARINDEX('/', DISTR) - 1))
							END AS DISTR,
							CASE CHARINDEX('/', DISTR)
								WHEN 0 THEN 1
								ELSE CONVERT(INT, RIGHT(DISTR, LEN(DISTR) - CHARINDEX('/', DISTR)))
							END AS COMP,
							--CASE WHEN ISNULL(DELIVERY, 0) = 0 THEN CONVERT(MONEY, ROUND(ROUND(PRICE * COEF, RND) * (100 - DISCOUNT) / 100 * (1 + INFLATION / 100.0), 2)) ELSE 0 END AS PRICE_TOTAL
							CASE
								WHEN @DATE IS NULL OR @DATE < '20180208' THEN
									CASE WHEN ISNULL(DELIVERY, 0) = 0 THEN CONVERT(MONEY, ROUND(ROUND(PRICE * COEF, RND) * (100 - DISCOUNT) / 100 * (1 + INFLATION / 100.0), 0)) ELSE 0 END
								ELSE
									CASE WHEN ISNULL(DELIVERY, 0) = 0 THEN CONVERT(MONEY, ROUND(ROUND(PRICE * COEF, RND) * (100 - DISCOUNT) / 100 * (1 + INFLATION / 100.0), 2)) ELSE 0 END

							END AS PRICE_TOTAL
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
									CONVERT(MONEY, c.value('(@delivery)', 'DECIMAL(10, 4)')) AS DELIVERY,
									ISNULL(c.value('(@mon_cnt)', 'INT'), 0) AS MON_CNT
								FROM @xml.nodes('/root/item') AS a(c)
							) AS a
							INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON a.SYS_ID = b.SystemID
							INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.DistrTypeTable c ON a.NET_ID = c.DistrTypeID
							INNER JOIN [PC275-SQL\ALPHA].ClientDB.Price.SystemPrice d ON ID_MONTH = MON_ID AND ID_SYSTEM = SYS_ID
							INNER JOIN [PC275-SQL\ALPHA].ClientDB.Common.Period e ON e.ID = a.MON_ID
							INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.DistrTypeCoef h ON h.ID_NET = DistrTypeID AND h.ID_MONTH = e.ID
						WHERE ISNULL(DELIVERY, 0) = 0
					) AS o_O
			) b ON a.SYS_REG_NAME = b.SystemBaseName AND a.DIS_NUM = b.DISTR AND a.DIS_COMP_NUM = b.COMP
		ORDER BY ERR DESC, CHECKED DESC, DSS_REPORT DESC, SYS_ORDER, DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_IMPORT] TO rl_distr_financing_w;
GO
