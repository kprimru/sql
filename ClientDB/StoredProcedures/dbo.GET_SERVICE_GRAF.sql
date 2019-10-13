USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_SERVICE_GRAF]
	@serviceid INT,
	@alph BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @alph = 1	
		SELECT 
			ROW_NUMBER() OVER(ORDER BY b.ClientFullName) AS 'RowNumber', 
			b.ClientFullName, CATEGORY AS ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5), 
			ServiceTime, GR_ERROR
		FROM dbo.ClientTable b 
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
		LEFT JOIN dbo.DayTable c ON c.DayID = b.DayID
		LEFT JOIN dbo.ClientTypeAllView d ON d.ClientID = b.ClientID
		LEFT JOIN dbo.ClientGraphView a ON a.ClientID = b.ClientID
		WHERE b.ClientServiceID = @serviceid AND STATUS = 1
		ORDER BY b.ClientFullName
	ELSE
		SELECT 
			ROW_NUMBER() OVER(ORDER BY DayOrder, ServiceStart, b.ClientFullName) AS 'RowNumber', 
			b.ClientFullName, CATEGORY AS ClientTypeName, DayName, SUBSTRING(CONVERT(VARCHAR(20), ServiceStart, 108), 1, 5), 
			ServiceTime, GR_ERROR
		FROM dbo.ClientTable b 
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON b.StatusId = s.ServiceStatusId
		LEFT JOIN dbo.DayTable c ON c.DayID = b.DayID
		LEFT JOIN dbo.ClientTypeAllView d ON d.ClientID = b.ClientID
		LEFT JOIN dbo.ClientGraphView a ON a.ClientID = b.ClientID
		WHERE b.ClientServiceID = @serviceid AND STATUS = 1
		ORDER BY DayOrder, ServiceStart, ClientFullName
END