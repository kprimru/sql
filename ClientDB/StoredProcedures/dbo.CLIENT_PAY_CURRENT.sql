USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_PAY_CURRENT]
	@CLIENT	INT,
	@MONTH	UNIQUEIDENTIFIER
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

		DECLARE @MON_DATE SMALLDATETIME

		SELECT @MON_DATE = START FROM Common.Period WHERE ID = @MONTH

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				DisStr		VARCHAR(50),
				SYS_REG		VARCHAR(20),
				SYS_ORD		INT,
				DISTR		INT,
				COMP		TINYINT,
				LAST_PAY	SMALLDATETIME,
				BILL		MONEY,
				INCOME		MONEY,
				LAST_ACT	SMALLDATETIME
			)

		INSERT INTO #distr(DisStr, SYS_REG, SYS_ORD, DISTR, COMP/*, LAST_PAY, BILL, INCOME*/)
			SELECT DistrStr, SystemBaseName, SystemOrder, DISTR, COMP

			FROM
				dbo.ClientDistrView WITH(NOEXPAND)
			WHERE ID_CLIENT = @CLIENT AND DS_REG = 0

		UPDATE #distr
		SET BILL =
			(
				SELECT BD_TOTAL_PRICE
				FROM dbo.DBFBillView WITH(NOLOCK)
				WHERE PR_DATE = @MON_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
			),
			INCOME =
			(
				SELECT ID_PRICE
				FROM dbo.DBFIncomeView WITH(NOLOCK)
				WHERE PR_DATE = @MON_DATE AND SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
			),
			LAST_PAY =
			ISNULL((
				SELECT MAX(PR_DATE)
				FROM dbo.DBFBillRestView z WITH(NOLOCK)
				WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					AND PR_DATE = @MON_DATE AND BD_REST = 0
				),
				ISNULL((
					SELECT MAX(PR_DATE)
					FROM dbo.DBFBillRestView z WITH(NOLOCK)
					WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
						AND PR_DATE <= @MON_DATE AND BD_REST = 0
						/*AND EXISTS
							(
								SELECT *
								FROM dbo.DBFBillRestView y
								WHERE z.SYS_REG_NAME = y.SYS_REG_NAME
									AND z.DIS_NUM = y.DIS_NUM
									AND z.DIS_COMP_NUM = y.DIS_COMP_NUM
									AND y.PR_DATE = DATEADD(MONTH, -1, z.PR_DATE)
							)*/
				),
				(
					SELECT MAX(PR_DATE)
					FROM dbo.DBFBillRestView z WITH(NOLOCK)
					WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
						AND PR_DATE <= @MON_DATE AND BD_REST = 0
				)
			)),
			LAST_ACT =
			(
				SELECT MAX(PR_DATE)
				FROM dbo.DBFActView WITH(NOLOCK)
				WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					AND PR_DATE <= @MON_DATE --AND BD_REST = 0
			)
			/*
			LAST_PAY =
			ISNULL((
				SELECT MAX(PR_DATE)
				FROM dbo.DBFBillRestView z
				WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					AND PR_DATE <= @MON_DATE AND BD_REST = 0
					AND EXISTS
						(
							SELECT *
							FROM dbo.DBFBillRestView y
							WHERE z.SYS_REG_NAME = y.SYS_REG_NAME
								AND z.DIS_NUM = y.DIS_NUM
								AND z.DIS_COMP_NUM = y.DIS_COMP_NUM
								AND y.PR_DATE = DATEADD(MONTH, -1, z.PR_DATE)
						)
			),
			(
				SELECT MAX(PR_DATE)
				FROM dbo.DBFBillRestView z
				WHERE SYS_REG_NAME = SYS_REG AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					AND PR_DATE <= @MON_DATE AND BD_REST = 0
			)
			),
			*/


		SELECT
			DisStr,
			CASE WHEN BILL = INCOME THEN 'Да' ELSE 'Нет' END AS PAY,
			CASE WHEN BILL = INCOME THEN 1 ELSE 0 END AS PAY_FLAG,
			DATEDIFF(MONTH, LAST_PAY, @MON_DATE) AS DEBT_DELTA,
			ROUND(100 * (BILL - ISNULL(INCOME, 0)) / BILL, 2) AS PRC,
			LAST_ACT
		FROM #distr
		ORDER BY SYS_ORD


		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PAY_CURRENT] TO rl_client_pay_current;
GO
