USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FILES_SERVER_SELECT]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		FL_NAME, CONVERT(DECIMAL(24, 8), CONVERT(DECIMAL(24, 8), FL_SIZE) / 1024 / 1024) AS FL_SIZE, FL_DATE
	FROM dbo.Files
	WHERE FL_TYPE = 3
	ORDER BY FL_DATE DESC
END
