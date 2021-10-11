USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_1C_COMPARE]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ORG	INT,
	@DATE	DATETIME,
	@ACT1	DATETIME = NULL,
	@ACT2	DATETIME = NUL
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

		IF OBJECT_ID('tempdb..#old') IS NOT NULL
			DROP TABLE #old

		IF OBJECT_ID('tempdb..#new') IS NOT NULL
			DROP TABLE #new

		CREATE TABLE #old
			(
				CL_ID		INT,
				CL_PSEDO	VARCHAR(50),
				SYS_ID		INT,
				SYS_SHORT	VARCHAR(50),
				SYS_ORDER	INT,
				ACT_PRICE	MONEY,
				ACT_NDS		MONEY
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #old (CL_ID, SYS_ID)'
		EXEC (@SQL)

		CREATE TABLE #new
			(
				CL_ID		INT,
				CL_PSEDO	VARCHAR(50),
				SYS_ID		INT,
				SYS_SHORT	VARCHAR(50),
				SYS_ORDER	INT,
				ACT_PRICE	MONEY,
				ACT_NDS		MONEY
			)

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #new (CL_ID, SYS_ID)'
		EXEC (@SQL)

		IF @ACT1 IS NOT NULL AND @ACT2 IS NOT NULL
		BEGIN
			INSERT INTO #old(CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT, SYS_ORDER, ACT_PRICE, ACT_NDS)
				SELECT ID_CLIENT, CL_PSEDO, SYS_ID, SYS_SHORT_NAME, SYS_ORDER, ACT_PRICE, ACT_NDS
				FROM
					 dbo.Act1C a
					 INNER JOIN dbo.Act1CDetail b ON a.ID = b.ID_MASTER
					 INNER JOIN dbo.SystemTable c ON ID_SYSTEM = SYS_ID
				WHERE a.DATE = @ACT1

			INSERT INTO #new(CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT, SYS_ORDER, ACT_PRICE, ACT_NDS)
				SELECT ID_CLIENT, CL_PSEDO, SYS_ID, SYS_SHORT_NAME, SYS_ORDER, ACT_PRICE, ACT_NDS
				FROM
					 dbo.Act1C a
					 INNER JOIN dbo.Act1CDetail b ON a.ID = b.ID_MASTER
					 INNER JOIN dbo.SystemTable c ON ID_SYSTEM = SYS_ID
				WHERE a.DATE = @ACT2
		END
		ELSE
		BEGIN
			INSERT INTO #old(CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT, SYS_ORDER, ACT_PRICE, ACT_NDS)
				SELECT ID_CLIENT, CL_PSEDO, SYS_ID, SYS_SHORT_NAME, SYS_ORDER, ACT_PRICE, ACT_NDS
				FROM
					 dbo.Act1C a
					 INNER JOIN dbo.Act1CDetail b ON a.ID = b.ID_MASTER
					 INNER JOIN dbo.SystemTable c ON ID_SYSTEM = SYS_ID
				WHERE a.DATE = @DATE

			INSERT INTO #new(CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT, SYS_ORDER, ACT_PRICE, ACT_NDS)
				SELECT
					CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT_NAME, SYS_ORDER, SUM(AD_PRICE), SUM(AD_TAX_PRICE)
				FROM 
					dbo.ClientTable
					INNER JOIN dbo.ActTable ON ACT_ID_CLIENT = CL_ID
					INNER JOIN dbo.ActDistrTable ON AD_ID_ACT = ACT_ID
					INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR 
				WHERE ACT_DATE BETWEEN @begin AND @end
					AND (ACT_ID_ORG = @org OR @org IS NULL)
				GROUP BY CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT_NAME, SYS_ORDER

				UNION ALL

				SELECT
					CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT_NAME, SYS_ORDER, SUM(CSD_PRICE), SUM(CSD_TAX_PRICE)
				FROM 
					dbo.ClientTable
					INNER JOIN dbo.ConsignmentTable ON CSG_ID_CLIENT = CL_ID
					INNER JOIN dbo.ConsignmentDetailTable ON CSD_ID_CONS = CSG_ID
					INNER JOIN dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR
				WHERE CSG_DATE BETWEEN @begin AND @end
					AND (CSG_ID_ORG = @org OR @org IS NULL)
				GROUP BY CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT_NAME, SYS_ORDER
		END

		SELECT
			'Дорасчитан' AS TP, CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT, SYS_ORDER,
			CONVERT(MONEY, NULL) AS ACT_OLD_PRICE, ACT_PRICE AS ACT_NEW_PRICE,
			ISNULL(ACT_NDS, ACT_PRICE * CASE SYS_SHORT WHEN 'ГК' THEN 0.1 WHEN 'Лицензия' THEN 0 ELSE 0.18 END) AS ACT_NDS
		FROM #new a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #old b
				WHERE a.CL_ID = b.CL_ID AND a.SYS_ID = b.SYS_ID
			)

		UNION ALL

		SELECT
			'Удален' AS TP, CL_ID, CL_PSEDO, SYS_ID, SYS_SHORT, SYS_ORDER,
			ACT_PRICE, NULL,
			NULL
		FROM #old a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #new b
				WHERE a.CL_ID = b.CL_ID AND a.SYS_ID = b.SYS_ID
			)

		UNION ALL

		SELECT
			'Изменилась сумма' AS TP, a.CL_ID, a.CL_PSEDO, a.SYS_ID, a.SYS_SHORT, a.SYS_ORDER,
			a.ACT_PRICE, b.ACT_PRICE,
			ISNULL(b.ACT_NDS, b.ACT_PRICE * CASE b.SYS_SHORT WHEN 'ГК' THEN 0.1 WHEN 'Лицензия' THEN 0 ELSE 0.18 END)
		FROM
			#old a
			INNER JOIN #new b ON a.CL_ID = b.CL_ID AND a.SYS_ID = b.SYS_ID
		WHERE a.ACT_PRICE <> b.ACT_PRICE

		ORDER BY CL_PSEDO, SYS_ORDER

		IF OBJECT_ID('tempdb..#new') IS NOT NULL
			DROP TABLE #new

		IF OBJECT_ID('tempdb..#old') IS NOT NULL
			DROP TABLE #old

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_1C_COMPARE] TO rl_report_act_r;
GO
