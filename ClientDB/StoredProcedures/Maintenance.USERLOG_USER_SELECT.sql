USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[USERLOG_USER_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT USR
	FROM Maintenance.Userlog
	ORDER BY USR
END
