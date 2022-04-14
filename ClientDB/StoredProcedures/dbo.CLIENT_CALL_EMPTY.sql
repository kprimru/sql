USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CALL_EMPTY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CALL_EMPTY]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CALL_EMPTY]
	@Begin		SmallDateTime = NULL,
	@End		SmallDateTime = NULL,
	@Manager_Id	Int = NULL,
	@Service_Id	Int = NULL,
	@Kinds_IDs	NVarChar(MAX) = NULL,
	@Types_IDs	NVarChar(MAX) = NULL
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

		IF @Service_Id IS NOT NULL
			SET @Manager_Id = NULL;

		SELECT
			a.ClientID, a.ClientFullName, ServiceName, ManagerName, ClientTypeId,
			(
				SELECT TOP 1 CC_DATE
				FROM dbo.ClientTrustView WITH(NOEXPAND)
				WHERE CC_ID_CLIENT = a.ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_TRUST,
			(
				SELECT TOP 1 CT_TRUST_STR
				FROM dbo.ClientTrustView WITH(NOEXPAND)
				WHERE CC_ID_CLIENT = a.ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_TRUST_STR,
			(
				SELECT TOP 1 CC_DATE
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
					INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
				WHERE CC_ID_CLIENT = a.ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_SATIS,
			(
				SELECT TOP 1 STT_NAME
				FROM
					dbo.ClientCall
					INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
					INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
				WHERE CC_ID_CLIENT = a.ClientID
				ORDER BY CC_DATE DESC
			) AS LAST_SATIS_STR,
			(
				SELECT MIN(ConnectDate)
				FROM dbo.ClientConnectView z WITH(NOEXPAND)
				WHERE z.ClientID = a.CLientID
			) AS CONNECT_DATE
		FROM dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
		WHERE	(@Kinds_IDs IS NULL OR ClientKind_Id IN (SELECT ID FROM dbo.TableIDFromXML(@Kinds_IDs)))
			AND (@Types_IDs IS NULL OR ClientTypeId IN (SELECT ID FROM dbo.TableIDFromXML(@Types_IDs)))
			AND (ManagerID = @Manager_Id OR @Manager_Id IS NULL)
			AND (ServiceID = @Service_Id OR @Service_Id IS NULL)
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientTrustView WITH(NOEXPAND)
					WHERE CC_ID_CLIENT = a.ClientID
						AND CC_DATE BETWEEN @BEGIN AND @END
				)
			AND NOT EXISTS
				(
					SELECT *
					FROM
						dbo.ClientCall
						INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
					WHERE CC_ID_CLIENT = a.ClientID
						AND CC_DATE BETWEEN @BEGIN AND @END
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
GRANT EXECUTE ON [dbo].[CLIENT_CALL_EMPTY] TO rl_call_miss;
GO
