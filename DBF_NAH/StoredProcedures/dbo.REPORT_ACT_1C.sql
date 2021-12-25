USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_ACT_1C]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SYS	VARCHAR(MAX),
	@ORG	INT,
	@TOTAL	BIT = 0
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

		IF OBJECT_ID('tempdb..#tmpsystem') IS NOT NULL
			DROP TABLE #tmpsystem

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

		SELECT
			CL_ID, CL_FULL_NAME, CL_INN,
			SUM(AD_PRICE) AS ACT_PRICE, SUM(AD_TAX_PRICE) AS ACT_NDS, SUM(AD_TOTAL_PRICE) AS ACT_TOTAL,
			SYS_ORDER, CL_PSEDO
		FROM 
			dbo.ClientTable INNER JOIN
			dbo.ActTable ON ACT_ID_CLIENT = CL_ID INNER JOIN
			dbo.ActDistrTable ON AD_ID_ACT = ACT_ID INNER JOIN
			dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR INNER JOIN
			#tmpsystem ON a.SYS_ID = TSYS_ID
		WHERE ACT_DATE BETWEEN @begin AND @end
			AND (ACT_ID_ORG = @org OR @org IS NULL)
		GROUP BY CL_ID, CL_FULL_NAME, CL_INN, SYS_ORDER, CL_PSEDO

		UNION ALL

		SELECT
			CL_ID, CL_FULL_NAME, CL_INN,
			SUM(CSD_PRICE) AS ACT_PRICE, SUM(CSD_TAX_PRICE) AS ACT_NDS, SUM(CSD_TOTAL_PRICE) AS ACT_TOTAL,
			SYS_ORDER, CL_PSEDO
		FROM 
			dbo.ClientTable INNER JOIN
			dbo.ConsignmentTable ON CSG_ID_CLIENT = CL_ID INNER JOIN
			dbo.ConsignmentDetailTable ON CSD_ID_CONS = CSG_ID INNER JOIN
			dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR INNER JOIN
			#tmpsystem ON a.SYS_ID = TSYS_ID
		WHERE CSG_DATE BETWEEN @begin AND @end
			AND (CSG_ID_ORG = @org OR @org IS NULL)
		GROUP BY CL_ID, CL_FULL_NAME, CL_INN, SYS_ORDER, CL_PSEDO

		ORDER BY a.SYS_ORDER, CL_PSEDO, CL_ID

		IF OBJECT_ID('tempdb..#tmpsystem') IS NOT NULL
			DROP TABLE #tmpsystem

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REPORT_ACT_1C] TO rl_report_act_r;
GO
