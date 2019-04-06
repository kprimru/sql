USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SEARCH_GRAPH]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SearchMonthDate, COUNT(DISTINCT ClientID) AS CNT
	FROM dbo.ClientSearchTable
	WHERE SearchDay BETWEEN @BEGIN AND @END
	GROUP BY SearchMonthDate
	ORDER BY SearchMonthDate
END