USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVER_GET]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SRV_ID, SRV_NAME
	FROM dbo.Servers
	ORDER BY SRV_ID
END
