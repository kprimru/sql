USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_EXCHANGE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemID, SystemShortName, HostID
	FROM dbo.SystemTable a
	WHERE EXISTS
		(
			SELECT *
			FROM dbo.SystemTable b
			WHERE a.HostID = b.HostID
				AND a.SystemID <> b.SystemID
		) AND SystemActive = 1
	ORDER BY SystemOrder
END