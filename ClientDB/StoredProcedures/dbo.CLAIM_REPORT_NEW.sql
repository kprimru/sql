USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLAIM_REPORT_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLAIM_REPORT_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLAIM_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT
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

		IF OBJECT_ID('tempdb..#tech') IS NOT NULL
			DROP TABLE #tech

		SELECT
			(
				SELECT dbo.DateOf(MIN(b.CLM_DATE))
				FROM dbo.ClaimTable b
				WHERE a.CLM_ID_CLIENT = b.CLM_ID_CLIENT
					AND (dbo.DateOf(b.CLM_DATE) BETWEEN @BEGIN AND @END)
			) AS CLM_FIRST,
			ClientFullName, dbo.DateOf(CLM_DATE) AS ClaimDate,
			CLM_STATUS, dbo.DateOf(CLM_EX_DATE) AS CLM_EX_DATE

			INTO #tech

		FROM
			dbo.ClaimTable a
			INNER JOIN dbo.ClientTable ON ClientID = CLM_ID_CLIENT
		WHERE (dbo.DateOf(CLM_DATE) BETWEEN @BEGIN AND @END)
			AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
			AND STATUS = 1
		ORDER BY CLM_FIRST, ClientFullName, ClaimDate

		SELECT CLM_FIRST, ClientFullName, ClaimDate, CLM_STATUS, CLM_EX_DATE,
			(
				SELECT COUNT(*)
				FROM #tech b
				WHERE a.ClientFullName = b.ClientFullName
			) AS ClaimCount
		FROM #tech a
		ORDER BY CLM_FIRST, ClientFullName, ClaimDate

		IF OBJECT_ID('tempdb..#tech') IS NOT NULL
			DROP TABLE #tech

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLAIM_REPORT_NEW] TO rl_report_client_tech;
GO
