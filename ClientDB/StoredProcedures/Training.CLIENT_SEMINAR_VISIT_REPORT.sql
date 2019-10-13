USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Training].[CLIENT_SEMINAR_VISIT_REPORT]
	@BEGIN SMALLDATETIME,
	@END SMALLDATETIME,
	@SERVICE INT,
	@MANAGER INT,
	@TYPE NVARCHAR(MAX),
	@LESSON	INT,
	@CONNECT SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	SELECT 
		a.ClientID, ClientFullName, ManagerName, ServiceName, ConnectDate,
		(
			SELECT MAX(UF_DATE)
			FROM 
				USR.USRActiveView z		
			WHERE z.UD_ID_CLIENT = a.ClientID
		) AS LAST_UPDATE
	FROM 
		dbo.ClientTable a
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
		INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID	
		INNER JOIN dbo.ServiceTable b ON ClientServiceID = ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		LEFT OUTER JOIN 
			(
				SELECT ClientID, MIN(ConnectDate) AS ConnectDate
				FROM dbo.ClientConnectView WITH(NOEXPAND)
				GROUP BY ClientID
			) AS d ON d.ClientID = a.ClientID
	WHERE STATUS = 1
		AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		AND (c.ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND (ConnectDate <= @CONNECT OR @CONNECT IS NULL OR ConnectDate IS NULL)
		AND NOT EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientStudy z		
				WHERE z.ID_CLIENT = a.ClientID
					AND ID_PLACE = @LESSON
					AND DATE BETWEEN @BEGIN AND @END
					AND STATUS = 1
			)
	ORDER BY ManagerName, ServiceName, ClientFullName
END