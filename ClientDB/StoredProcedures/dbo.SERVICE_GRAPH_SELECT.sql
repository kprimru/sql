USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_GRAPH_SELECT]
	@SERVICE	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DT DATETIME

	SET DATEFIRST 1
	SET @DT = dbo.DateOf(DATEADD(dd, - datepart(dw, GETDATE()) + 1, GETDATE()))

	SELECT
		ClientID, ClientFullName, DayOrder, ClientShortName,
		dbo.DateAssign(DATEADD(DAY, DayOrder - 1, @DT), ServiceStart) AS START, 
		DATEADD(MINUTE, ServiceTime, dbo.DateAssign(DATEADD(DAY, DayOrder - 1, @DT), ServiceStart)) AS FINISH,
		ServiceTime, CA_STR,
		CASE 
			WHEN GR_ERROR IS NULL THEN 0
			ELSE 1
		END AS ERR
	FROM 
		dbo.ServiceGraphView
		LEFT OUTER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = ClientID
	WHERE ClientServiceID = @SERVICE 
END
