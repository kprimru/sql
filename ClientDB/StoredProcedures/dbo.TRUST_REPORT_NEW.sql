USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TRUST_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF OBJECT_ID('tempdb..#trust') IS NOT NULL
			DROP TABLE #trust

		SELECT (
			   SELECT dbo.DateOf(MIN(g.CC_DATE))
			   FROM
					dbo.ClientCall g
					INNER JOIN dbo.ClientTrust ON CC_ID = CT_ID_CALL
			   WHERE g.CC_ID_CLIENT = b.ClientID
					AND dbo.DateOf(g.CC_DATE) BETWEEN @BEGIN AND @END
			 ) AS CC_FIRST, ClientFullName, CC_DATE,
			 CC_USER, CASE CT_TRUST WHEN 1 THEN 'Достоверен' ELSE 'Не достоверен' END AS CT_TRUST

			INTO #trust

		FROM
			dbo.ClientCall a
			INNER JOIN dbo.ClientTable b ON a.CC_ID_CLIENT = b.ClientID
			INNER JOIN dbo.ClientTrust c ON CT_ID_CALL = CC_ID
			INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
		WHERE dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
			AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY CC_FIRST, ClientFullName, CC_DATE

		SELECT CC_FIRST, ClientFullName, CC_DATE, CC_USER, CT_TRUST,
			(
				SELECT COUNT(*)
				FROM #trust b
				WHERE a.ClientFullName = b.ClientFullName
			) AS CallCount
		FROM #trust a
		ORDER BY CC_FIRST, ClientFullName, CC_DATE

		IF OBJECT_ID('tempdb..#trust') IS NOT NULL
			DROP TABLE #trust

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TRUST_REPORT_NEW] TO rl_report_client_trust;
GO
