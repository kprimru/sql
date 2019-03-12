USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SERVICE_STATUS_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceStatusID, ServiceStatusName, ServiceImage, ServiceDefault, ServiceStatusReg
	FROM dbo.ServiceStatusTable
	WHERE @FILTER IS NULL
		OR ServiceStatusName LIKE @FILTER
	ORDER BY ServiceStatusIndex
END