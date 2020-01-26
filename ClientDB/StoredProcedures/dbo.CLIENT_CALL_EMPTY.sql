USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CALL_EMPTY]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	INT,
	@TYPE		NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		a.ClientID, a.ClientFullName, ServiceName, ManagerName, 
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
	FROM 
		dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
	WHERE	(@TYPE IS NULL OR ClientKind_Id IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)))
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
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
END
