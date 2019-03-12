USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Training].[CLIENT_SEMINAR_VISIT_OFTEN_REPORT]
	@BEGIN SMALLDATETIME,
	@END SMALLDATETIME,
	@SERVICE INT,
	@MANAGER INT,
	@TYPE NVARCHAR(MAX),
	@LESSON	INT,
	@CONNECT SMALLDATETIME,
	@NUM_BEGIN	INT = NULL,
	@NUM_END	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	SELECT 
		ClientID, ClientFullName, ManagerName, ServiceName, ConnectDate, CNT, LAST_UPDATE,
		(
			SELECT TOP 1 DistrStr + ' (' + DistrTypeName + ')'
			FROM dbo.ClientDistrView WITH(NOEXPAND)
			WHERE ClientID = ID_CLIENT
				AND DS_REG = 0
			ORDER BY SystemOrder
		) AS MAIN_DISTR
	FROM
		(
			SELECT 
				a.ClientID, ClientFullName, ManagerName, ServiceName, ConnectDate, COUNT(*) AS CNT,
				(
					SELECT MAX(UF_DATE)
					FROM 
						USR.USRActiveView z		
					WHERE z.UD_ID_CLIENT = a.ClientID
				) AS LAST_UPDATE
			FROM 
				dbo.ClientTable a 
				INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID	
				INNER JOIN dbo.ServiceTable b ON ClientServiceID = ServiceID
				INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
				INNER JOIN dbo.ClientStudy z ON z.ID_CLIENT = a.ClientID
												AND ID_PLACE = @LESSON
												AND DATE BETWEEN @BEGIN AND @END
				LEFT OUTER JOIN 
					(
						SELECT ClientID, MIN(ConnectDate) AS ConnectDate
						FROM dbo.ClientConnectView WITH(NOEXPAND)
						GROUP BY ClientID
					) AS d ON d.ClientID = a.ClientID
			WHERE StatusID = 2
				AND a.STATUS = 1
				AND z.STATUS = 1
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (c.ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ConnectDate <= @CONNECT OR @CONNECT IS NULL OR ConnectDate IS NULL)
			GROUP BY a.ClientID, ClientFullName, ManagerName, ServiceName, ConnectDate
		) AS o_O
	WHERE (CNT >= @NUM_BEGIN OR @NUM_BEGIN IS NULL)
		AND (CNT <= @NUM_END OR @NUM_END IS NULL)
	ORDER BY ManagerName, ServiceName, ClientFullName
END