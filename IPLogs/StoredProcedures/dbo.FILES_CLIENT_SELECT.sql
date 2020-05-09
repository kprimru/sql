USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[FILES_CLIENT_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		FL_NAME, CONVERT(DECIMAL(24, 8), CONVERT(DECIMAL(24, 8), FL_SIZE) / 1024 / 1024) AS FL_SIZE, FL_DATE
	FROM dbo.Files
	WHERE FL_TYPE = 2
	ORDER BY FL_DATE DESC
END
GO
GRANT EXECUTE ON [dbo].[FILES_CLIENT_SELECT] TO rl_files_client;
GO