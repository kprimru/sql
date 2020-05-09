USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CALL_MISS_FILTER]
	@SERVICE	INT,
	@MANAGER	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TRUST		BIT,
	@SATISFACT	BIT
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

		IF @END IS NULL
			SET @END = dbo.DateOf(GETDATE())

		SELECT
			ClientID, ClientFullName, ServiceName, ManagerName,
			(
				SELECT TOP 1 CC_DATE
				FROM dbo.ClientTrustView WITH(NOEXPAND)
				WHERE CC_ID_CLIENT = ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_TRUST,
			(
				SELECT TOP 1 CT_TRUST_STR
				FROM dbo.ClientTrustView WITH(NOEXPAND)
				WHERE CC_ID_CLIENT = ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_TRUST_STR,
			(
				SELECT TOP 1 CC_DATE
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
					INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
				WHERE CC_ID_CLIENT = ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_SATIS,
			(
				SELECT TOP 1 STT_NAME
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
					INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
				WHERE CC_ID_CLIENT = ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_SATIS_STR,
			(
				SELECT MIN(ConnectDate)
				FROM dbo.ClientConnectView z WITH(NOEXPAND)
				WHERE z.ClientID = a.CLientID
			) AS CONNECT_DATE
		FROM dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
		WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND
				(
					@TRUST = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.ClientTrustView WITH(NOEXPAND)
							WHERE CC_ID_CLIENT = ClientID
								AND CC_DATE BETWEEN @BEGIN AND @END
						)

					OR

					@SATISFACT = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM
								dbo.ClientCall
								INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
							WHERE CC_ID_CLIENT = ClientID
								AND CC_DATE BETWEEN @BEGIN AND @END
						)
				)
		ORDER BY ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CALL_MISS_FILTER] TO rl_call_miss;
GO