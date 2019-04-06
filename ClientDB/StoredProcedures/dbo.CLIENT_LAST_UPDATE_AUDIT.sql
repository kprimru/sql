USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_LAST_UPDATE_AUDIT]
	@SERVICE	INT,
	@MANAGER	INT,
	@DATE		SMALLDATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	DECLARE @LAST_DATE	SMALLDATETIME

	SET @LAST_DATE = dbo.DateOf(GETDATE())

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client (CL_ID INT PRIMARY KEY)

	INSERT INTO #client(CL_ID)
		SELECT ClientID
		FROM dbo.ClientView WITH(NOEXPAND)
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceStatusID = 2)
			AND EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView WITH(NOEXPAND)
					WHERE ID_CLIENT = ClientID 
						AND DS_REG = 0
						AND DistrTypeBaseCheck = 1
				)

	DELETE
	FROM #client
	WHERE EXISTS
		(
			SELECT *
			FROM USR.USRIBDateView WITH(NOEXPAND)
			WHERE CL_ID = UD_ID_CLIENT AND UIU_DATE_S BETWEEN DATEADD(WEEK, -3, @LAST_DATE) AND @LAST_DATE
		) 
		
	IF @DATE IS NOT NULL
		DELETE 
		FROM #client
		WHERE NOT EXISTS		
			(
				SELECT *
				FROM USR.USRIBDateView WITH(NOEXPAND)
				WHERE CL_ID = UD_ID_CLIENT AND UIU_DATE_S >= @DATE
			)

	SELECT 
		ClientID, CLientFullName + ' (' + ServiceTypeShortName + ')' AS ClientFullName, ServiceName, ManagerName, 
		(
			SELECT MAX(UIU_DATE) 
			FROM USR.USRIBDateView WITH(NOEXPAND)
			WHERE CL_ID = UD_ID_CLIENT AND UIU_DATE_S < @LAST_DATE
		) AS LAST_UPDATE,
		(
			SELECT CONVERT(VARCHAR(20), EventDate, 104) + ' ' + EventComment + CHAR(10)
			FROM EventTable z
			WHERE EventActive = 1 
				AND CL_ID = z.ClientID
				AND EventDate BETWEEN DATEADD(WEEK, -3, @LAST_DATE) AND @LAST_DATE
			ORDER BY EventDate FOR XML PATH('')
		) AS EventComment
	FROM 
		#client a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON ClientID = CL_ID
		INNER JOIN dbo.ServiceTypeTable c ON b.ServiceTypeID = c.ServiceTypeID
	ORDER BY ManagerName, ServiceName, ClientFullName

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client
END