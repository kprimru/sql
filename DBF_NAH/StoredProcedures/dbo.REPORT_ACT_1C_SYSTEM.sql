USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_ACT_1C_SYSTEM]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ORG	INT,
	@SYS	VARCHAR(MAX),
	@TOTAL	BIT
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

		CREATE TABLE #tmpsystem
			(
				TSYS_ID INT
			)

		IF @sys IS NOT NULL
			INSERT INTO #tmpsystem
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@SYS, ',')
		ELSE
			INSERT INTO #tmpsystem
				SELECT SYS_ID
				FROM dbo.SystemTable
				WHERE SYS_ACTIVE = 1

		IF @TOTAL = 1
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER, ID_SYSTEM SMALLINT)

			INSERT INTO dbo.Act1C(ID_ORG, START, FINISH, ID_SYSTEM, TOTAL)
				OUTPUT inserted.ID, inserted.ID_SYSTEM INTO @TBL
				SELECT @ORG, @BEGIN, @END, TSYS_ID, @TOTAL
				FROM #tmpsystem

			INSERT INTO dbo.Act1CDetail(ID_MASTER, ID_CLIENT, CL_FULL_NAME, CL_INN, CL_PSEDO, ACT_PRICE, ACT_NDS, ACT_NOTE)
				SELECT
					(
						SELECT ID
						FROM @TBL
						WHERE ID_SYSTEM = SYS_ID
					), CL_ID, CL_FULL_NAME, CL_INN, CL_PSEDO, SUM(AD_PRICE), SUM(AD_TAX_PRICE),
					REVERSE(STUFF(REVERSE(
						(
							SELECT PR_NAME + ', '
							FROM
								(
									SELECT DISTINCT PR_NAME
									FROM
										dbo.ActTable
										INNER JOIN dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
										INNER JOIN dbo.PeriodTable ON PR_ID = AD_ID_PERIOD
									WHERE ACT_ID_CLIENT = CL_ID
										AND ACT_DATE BETWEEN @begin AND @end
										AND (ACT_ID_ORG = @org OR @org IS NULL)
								) AS o_O
							ORDER BY PR_NAME FOR XML PATH('')
						)
					), 1, 2, ''))
				FROM
					dbo.ClientTable INNER JOIN
					dbo.ActTable ON ACT_ID_CLIENT = CL_ID INNER JOIN
					dbo.ActDistrTable ON AD_ID_ACT = ACT_ID INNER JOIN
					dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR INNER JOIN
					#tmpsystem ON a.SYS_ID = TSYS_ID
				WHERE ACT_DATE BETWEEN @begin AND @end
					AND (ACT_ID_ORG = @org OR @org IS NULL)
				GROUP BY CL_ID, CL_FULL_NAME, CL_INN, SYS_ID, CL_PSEDO

				UNION ALL

				SELECT
					(
						SELECT ID
						FROM @TBL
						WHERE ID_SYSTEM = SYS_ID
					), CL_ID, CL_FULL_NAME, CL_INN, CL_PSEDO, SUM(CSD_PRICE), SUM(CSD_TAX_PRICE),
					REVERSE(STUFF(REVERSE(
						(
							SELECT PR_NAME + ', '
							FROM
								(
									SELECT DISTINCT PR_NAME
									FROM
										dbo.ConsignmentTable
										INNER JOIN dbo.ConsignmentDetailTable ON CSG_ID = CSD_ID_CONS
										INNER JOIN dbo.PeriodTable ON PR_ID = CSD_ID_PERIOD
									WHERE CSG_ID_CLIENT = CL_ID
										AND CSG_DATE BETWEEN @begin AND @end
										AND (CSG_ID_ORG = @org OR @org IS NULL)
								) AS o_O
							ORDER BY PR_NAME FOR XML PATH('')
						)
					), 1, 2, ''))
				FROM 
					dbo.ClientTable INNER JOIN
					dbo.ConsignmentTable ON CSG_ID_CLIENT = CL_ID INNER JOIN
					dbo.ConsignmentDetailTable ON CSD_ID_CONS = CSG_ID INNER JOIN
					dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR INNER JOIN
					#tmpsystem ON a.SYS_ID = TSYS_ID
				WHERE CSG_DATE BETWEEN @begin AND @end
					AND (CSG_ID_ORG = @org OR @org IS NULL)
				GROUP BY CL_ID, CL_FULL_NAME, CL_INN, SYS_ID, CL_PSEDO

			UPDATE dbo.Act1C
			SET DATE = DATEADD(ms, -DATEPART(ms, DATE), DATE)
		END

		SELECT SYS_ID, SYS_SHORT_NAME
		FROM #tmpsystem INNER JOIN dbo.SystemTable ON SYS_ID = TSYS_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REPORT_ACT_1C_SYSTEM] TO rl_report_act_r;
GO