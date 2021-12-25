USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[RIC_CALC_SELECT]
	@PR_ALG	SMALLINT,
	@PR_ID	SMALLINT,
	@PK		DECIMAL(10, 4)
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

		DECLARE @CUR_DATE	SMALLDATETIME

		SELECT @CUR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		IF OBJECT_ID('tempdb..#weight') IS NOT NULL
			DROP TABLE #weight

		CREATE TABLE #weight
			(
				ID			INT PRIMARY KEY,
				ID_MASTER	INT,
				SYS_ID		SMALLINT,
				SYS_SHORT	VARCHAR(50),
				SST_CAPTION	VARCHAR(50),
				NET			VARCHAR(50),
				SH_SUBHOST	VARCHAR(50),
				SH_COEF		DECIMAL(4, 2),
				SST_COEF	DECIMAL(4, 2),
				NET_COEF	DECIMAL(4, 2),
				SYS_COUNT	INT,
				SYS_RESTORE	INT,
				WEIGHT		DECIMAL(12, 4),
				RES_LIST	VARCHAR(MAX)
			)

		INSERT INTO #weight
			EXEC dbo.REG_WEIGHT_REPORT @PR_ID, 1


		IF OBJECT_ID('tempdb..#calc') IS NOT NULL
			DROP TABLE #calc

		CREATE TABLE #calc
			(
				ID			INT	IDENTITY(1, 1),
				ID_MASTER	INT,
				HST_ID		SMALLINT,
				PR_DATE		SMALLDATETIME,
				SPU_PRICE	MONEY,
				SYS_ID		SMALLINT,
				SYS_SHORT	VARCHAR(50),
				SST_CAPTION	VARCHAR(50),
				SN_NAME		VARCHAR(50),
				SH_SUBHOST	VARCHAR(50),
				SST_COEF	DECIMAL(8, 4),
				SN_COEF		DECIMAL(8, 4),
				SH_COEF		DECIMAL(8, 4),
				SYS_COUNT	INT,
				RES_COUNT	INT,
				WEIGHT		DECIMAL(12, 4),
				PS_PRICE	MONEY,
				INC_PREF	TINYINT,
				SERVICE_SUM	MONEY,
				MSVUD_SUM	MONEY,
				BASE_SUM	MONEY,
				CALC_SUM	MONEY,
				INC_DISCOUNT	DECIMAL(8, 4),
				PREPAY_DISCOUNT	DECIMAL(8, 4),
				TOTAL_DISCOUNT	DECIMAL(8, 4),
				TOTAL_SUM	MONEY
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(NVARCHAR(100), NEWID()) + N'] ON #calc (ID_MASTER, ID)'
		EXEC (@SQL)

		INSERT INTO #calc(HST_ID, SYS_SHORT, PR_DATE, SPU_PRICE, MSVUD_SUM, INC_PREF)
			SELECT HST_ID, HST_SHORT, PR_DATE, PS_PRICE, 0, ISNULL(INC_PREF, 0)
			FROM
				(
					SELECT
						HST_ID, HST_SHORT, PR_DATE, PS_PRICE, INC_PREF,
						(
							SELECT MIN(SYS_ORDER)
							FROM dbo.SystemTable
							WHERE SYS_ID_HOST = HST_ID
						) AS HST_ORDER
					FROM
						dbo.HostTable
						LEFT OUTER JOIN
							(
								SELECT PR_DATE, HP_ID_HOST
								FROM
									Ric.HostPeriod
									LEFT OUTER JOIN dbo.PeriodTable ON PR_ID = HP_ID_PERIOD
							) AS a ON HST_ID = a.HP_ID_HOST
						LEFT OUTER JOIN
							(
								SELECT HP_ID_HOST, 1 AS INC_PREF
								FROM
									Ric.HostPeriod
									INNER JOIN dbo.PeriodTable ON PR_ID = HP_ID_INC_PREF
								WHERE PR_DATE <= @CUR_DATE
							) AS c ON HST_ID = c.HP_ID_HOST
						LEFT OUTER JOIN
							(
								SELECT DISTINCT SYS_ID_HOST, PS_PRICE
								FROM
									dbo.SystemTable
									INNER JOIN dbo.PriceSystemTable ON PS_ID_SYSTEM = SYS_ID
								WHERE PS_ID_PERIOD = @PR_ID AND PS_ID_TYPE = 10 AND ISNULL(PS_PRICE, 0) <> 0
							) AS b ON SYS_ID_HOST = HST_ID
					WHERE EXISTS
						(
							SELECT *
							FROM
								dbo.PeriodRegExceptView
								INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
								INNER JOIN dbo.SystemTable ON REG_ID_SYSTEM = SYS_ID
							WHERE REG_ID_PERIOD = @PR_ID AND SYS_ID_HOST = HST_ID AND DS_REG = 0
						)
				) AS o_O
			ORDER BY HST_ORDER

		INSERT INTO #calc(ID_MASTER, SYS_ID, SYS_SHORT, PS_PRICE, MSVUD_SUM, INC_PREF)
			SELECT
				(
					SELECT ID
					FROM #calc
					WHERE HST_ID = SYS_ID_HOST
				), SYS_ID, SYS_SHORT_NAME, PS_PRICE,
				(
					SELECT PS_PRICE
					FROM dbo.PriceSystemTable
					WHERE PS_ID_PERIOD = @PR_ID
						AND PS_ID_SYSTEM = SYS_ID
						AND PS_ID_TYPE = 15
				) *
				(
					SELECT SUM(
							CASE SNC_NET_COUNT
								WHEN 50 THEN 3
								WHEN 100 THEN 6
								WHEN 150 THEN 9
							END
							)
					FROM
						dbo.PeriodRegExceptView
						INNER JOIN dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE
						INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
						INNER JOIN dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET
					WHERE REG_ID_PERIOD = @PR_ID AND DS_REG = 0
						AND REG_ID_SYSTEM = SYS_ID AND SST_NAME = 'MSVUD'
				) / @PK,
				(
					SELECT INC_PREF
					FROM #calc
					WHERE HST_ID = SYS_ID_HOST
				)
			FROM
				dbo.SystemTable
				INNER JOIN dbo.PriceSystemTable ON PS_ID_SYSTEM = SYS_ID
			WHERE PS_ID_TYPE = 15 AND PS_ID_PERIOD = @PR_ID
				AND EXISTS
					(
						SELECT * FROM #calc
						WHERE HST_ID = SYS_ID_HOST
					)

		INSERT INTO #calc(ID_MASTER, SST_CAPTION, SN_NAME, SH_SUBHOST, SST_COEF, SN_COEF, SH_COEF, SYS_COUNT, RES_COUNT, WEIGHT)
			SELECT
				(
					SELECT ID
					FROM #calc b
					WHERE a.SYS_ID = b.SYS_ID
				),
				SST_CAPTION, NET, SH_SUBHOST, SST_COEF, NET_COEF, SH_COEF, SYS_COUNT, SYS_RESTORE, WEIGHT
			FROM
				#weight a
			WHERE ID_MASTER IS NOT NULL
			ORDER BY ID


		UPDATE a
		SET SYS_COUNT =
			(
				SELECT SUM(SYS_COUNT)
				FROM #calc b
				WHERE b.ID_MASTER = a.ID
			),
			RES_COUNT =
			(
				SELECT SUM(RES_COUNT)
				FROM #calc b
				WHERE b.ID_MASTER = a.ID
			),
			WEIGHT =
			(
				SELECT SUM(WEIGHT)
				FROM #calc b
				WHERE b.ID_MASTER = a.ID
			)
		FROM #calc a
		WHERE ID_MASTER IN
			(
				SELECT ID
				FROM #calc
				WHERE ID_MASTER IS NULL
			)


		UPDATE #calc
		SET SERVICE_SUM = ROUND(WEIGHT * PS_PRICE, 2)
		WHERE ID_MASTER IN
			(
				SELECT ID
				FROM #calc
				WHERE ID_MASTER IS NULL
			)

		/*
		UPDATE a
		SET SERVICE_SUM =
			(
				SELECT SUM(SERVICE_SUM)
				FROM #calc b
				WHERE b.ID_MASTER = a.ID
			)
		FROM #calc a
		WHERE ID_MASTER IS NULL
		*/

		DECLARE @BASE	MONEY
		DECLARE @KBU	DECIMAL(10, 4)

		SELECT @KBU = RK_TOTAL
		FROM Ric.KBU
		WHERE RK_ID_QUARTER = dbo.PeriodQuarter(@PR_ID)

		SELECT
			ID, ID_MASTER,
			CASE
				WHEN PR_DATE = @CUR_DATE THEN 'Первый месяц СПУ'
				ELSE ''
			END AS SPU_FIRST,
			SYS_SHORT, SST_CAPTION, SN_NAME, SH_SUBHOST,
			SST_COEF, SN_COEF, SH_COEF, SYS_COUNT, RES_COUNT,
			WEIGHT, PS_PRICE, INC_PREF,

			SERVICE_SUM, SPU_PRICE,

			MSVUD_SUM, BASE_SUM, CALC_SUM,
			INC_DISCOUNT, PREPAY_DISCOUNT, TOTAL_DISCOUNT,
			TOTAL_SUM
		FROM #calc
		ORDER BY ID

		IF OBJECT_ID('tempdb..#weight') IS NOT NULL
			DROP TABLE #weight

		IF OBJECT_ID('tempdb..#calc') IS NOT NULL
			DROP TABLE #calc

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[RIC_CALC_SELECT] TO rl_ric_kbu;
GO
