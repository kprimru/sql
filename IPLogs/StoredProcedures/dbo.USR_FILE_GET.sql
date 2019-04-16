USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USR_FILE_GET]
	@FILE_NAME NVARCHAR(512)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @REPORT_PATH VARCHAR(512)

	SELECT @REPORT_PATH = ST_VALUE
	FROM dbo.Settings
	WHERE ST_NAME = 'REPORT_PATH'

	SELECT UF_USR_NAME, UF_USR_DATA
	FROM 
		dbo.USRFiles INNER JOIN
		dbo.Files ON UF_ID_FILE = FL_ID
	WHERE FL_NAME = @REPORT_PATH + @FILE_NAME
END
