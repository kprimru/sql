USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TRUST_STAT_REPORT_NEW]
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

		SELECT
			ServiceName,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				WHERE ServiceID = ClientServiceID
					AND STATUS = 1
			) AS ClientCount,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientTrust ON CT_ID_CALL = CC_ID
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
			) AS CallCount,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientTrust ON CT_ID_CALL = CC_ID
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
					AND CT_TRUST = 1
			) AS TrustCount,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientTrust ON CT_ID_CALL = CC_ID
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
					AND CT_TRUST = 0
			) AS UnTrustCount
		FROM dbo.ServiceTable a
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND EXISTS
			(
				SELECT *
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
					INNER JOIN dbo.ClientTrust ON CT_ID_CALL = CC_ID
				WHERE ServiceID = ClientServiceID
					AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
			)
		ORDER BY ServiceName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TRUST_STAT_REPORT_NEW] TO rl_report_client_trust;
GO