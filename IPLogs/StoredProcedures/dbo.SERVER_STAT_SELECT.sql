USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVER_STAT_SELECT]
	@BEGIN	DATETIME	= NULL,
	@END	DATETIME	= NULL,
	@LOAD	BIT			= NULL,
	@RC		INT			= NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SSD_DATE, SSD_HOSTCOUNT, SSD_QUERY, SSD_SESSIONCOUNT, 
		ROUND(CONVERT(DECIMAL(24, 8), (CONVERT(DECIMAL(24, 8), SSD_TRAFIN) / 1024 / 1024)), 2) AS SSD_TRAFIN, 
		ROUND(CONVERT(DECIMAL(24, 8), (CONVERT(DECIMAL(24, 8), SSD_TRAFOUT) / 1024 / 1024)), 2) AS SSD_TRAFOUT
	FROM dbo.ServerStatDetail
	WHERE (SSD_DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (SSD_DATE <= @END OR @END IS NULL)
		AND ((SSD_TRAFIN <> 0 OR SSD_TRAFOUT <> 0) OR @LOAD = 0)	
	ORDER BY SSD_DATE DESC
	
	SET @RC = @@ROWCOUNT
END
