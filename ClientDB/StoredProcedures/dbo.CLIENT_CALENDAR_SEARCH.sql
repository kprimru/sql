USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CALENDAR_SEARCH]	
	@NAME VARCHAR(500) = NULL,
	@SERVICE INT = NULL,
	@MANAGER INT = NULL,
	@STATUS INT = NULL,
	@CONTRACT INT = NULL,
	@FILE BIT = NULL,
	@NOHISTORY BIT = NULL,
	@PROBLEM BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#client') IS NOT NULL
		DROP TABLE #client

	CREATE TABLE #client
		(
			CL_ID	INT	PRIMARY KEY
		)

	INSERT INTO #client(CL_ID)
		SELECT WCL_ID
		FROM
			(
				SELECT WCL_ID
				FROM dbo.ClientWriteList()

				UNION 

				SELECT RCL_ID
				FROM dbo.ClientReadList()
			) AS o_O
	
	IF @NAME IS NOT NULL
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM dbo.ClientTable
				WHERE ClientFullName LIKE @NAME
					OR EXISTS
						(
							SELECT *
							FROM dbo.ClientNames
							WHERE ID_CLIENT = ClientID
								AND NAME LIKE @NAME
						)
			)

	IF @SERVICE IS NOT NULL
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM dbo.ClientTable
				WHERE ClientServiceID = @SERVICE
			)
		
	IF @MANAGER IS NOT NULL
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM 
					dbo.ClientTable
					INNER JOIN dbo.ServiceTable ON ClientServiceID = ServiceID
				WHERE ManagerID = @MANAGER
			)

	IF @STATUS IS NOT NULL
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM dbo.ClientTable
				WHERE StatusID = @STATUS
			)

	IF @CONTRACT IS NOT NULL
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM dbo.ClientTable
				WHERE ClientContractTypeID = @CONTRACT
			)
	
	IF @FILE = 1
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM dbo.ClientTable a
				WHERE EXISTS (SELECT * FROM dbo.ClientSearchTable e WHERE e.ClientID = a.ClientID)
			)
	
	IF @NOHISTORY = 1
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM dbo.ClientTable a
				WHERE NOT EXISTS (SELECT * FROM dbo.ClientSearchTable e WHERE e.ClientID = a.ClientID)
			)	
	
	IF @PROBLEM = 1
		DELETE FROM #client
		WHERE CL_ID NOT IN
			(
				SELECT ClientID
				FROM dbo.ClientTable z
				WHERE 
					DATEDIFF(MONTH, 
						(
							SELECT MAX(SearchDate) 
							FROM dbo.ClientSearchTable x 
							WHERE x.CLientID = z.ClientID
						), GETDATE()) > 2

				UNION ALL

				SELECT ClientID
				FROM dbo.ClientTable z
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientSearchTable x
						WHERE x.ClientID = z.ClientID
					)
			)

	SELECT 
		a.ClientID, ClientFullName, ServiceName, ManagerName, ServiceStatusIndex,
		ClientLastUpdate,
		REVERSE(STUFF(REVERSE(
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), CONVERT(DATETIME, CM_DATE, 121), 104) + ' ' + CM_TEXT + CHAR(10)
				FROM 
					dbo.ClientSearchComments z CROSS APPLY
					(
						SELECT 
							x.value('@TEXT[1]', 'VARCHAR(500)') AS CM_TEXT,
							x.value('@DATE[1]', 'VARCHAR(50)') AS CM_DATE
						FROM z.CSC_COMMENTS.nodes('/ROOT/COMMENT') t(x)
					) AS o_O
				WHERE z.CSC_ID_CLIENT = a.ClientID
					AND dbo.DateOf(CONVERT(DATETIME, CM_DATE, 121)) = dbo.DateOf(ClientLastUpdate)
				ORDER BY CM_DATE DESC FOR XML PATH('')
			)), 1, 1, '')
		) AS Comment 
	FROM 
		#client 
		INNER JOIN dbo.ClientTable a ON a.ClientID = CL_ID 
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID 
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID 
		INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.StatusID 	
	ORDER BY ClientFullName
END