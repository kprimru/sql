USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SERVICE_GRAPH_REPORT]
	@SERVICE	INT,
	@ALPH		BIT = NULL,
	@MANAGER	VARCHAR(256) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @MANAGER = 'График СИ ' + ServiceName + ' (' + ManagerName + ')'
	FROM 
		dbo.ServiceTable a
		INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
	WHERE a.ServiceID = @SERVICE

	IF @ALPH = 1
		SELECT 
			ROW_NUMBER() OVER(ORDER BY b.ClientFullName) AS 'RowNumber', 
			b.ClientFullName, c.CA_STR,			
			CATEGORY AS ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5) AS ServiceStartStr, 
			ServiceTime, GR_ERROR
		FROM 
			dbo.ClientTable b 
			LEFT OUTER JOIN dbo.ClientAddressView c ON b.ClientID = c.CA_ID_CLIENT
			LEFT OUTER JOIN dbo.DayTable d ON d.DayID = b.DayID 
			LEFT OUTER JOIN dbo.ClientTypeAllView e ON e.ClientID = b.ClientID
			LEFT OUTER JOIN dbo.ClientGraphView f ON f.ClientID = b.ClientID
		WHERE b.ClientServiceID = @SERVICE 
			AND b.StatusID = 2 
			AND STATUS = 1
		ORDER BY b.ClientFullName
	ELSE
		SELECT 
			ROW_NUMBER() OVER(ORDER BY DayOrder, ServiceStart, b.ClientFullName) AS 'RowNumber', 
			b.ClientFullName, c.CA_STR,
			CATEGORY AS ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5) AS ServiceStartStr, 
			ServiceTime, GR_ERROR
		FROM 
			dbo.ClientTable b 
			LEFT OUTER JOIN dbo.ClientAddressView c ON b.ClientID = c.CA_ID_CLIENT
			LEFT OUTER JOIN dbo.DayTable d ON d.DayID = b.DayID 
			LEFT OUTER JOIN dbo.ClientTypeAllView e ON e.ClientID = b.ClientID
			LEFT OUTER JOIN dbo.ClientGraphView f ON f.ClientID = b.ClientID
		WHERE b.ClientServiceID = @SERVICE 
			AND b.StatusID = 2 
			AND STATUS = 1
		ORDER BY DayOrder, ServiceStart, ClientFullName
END
