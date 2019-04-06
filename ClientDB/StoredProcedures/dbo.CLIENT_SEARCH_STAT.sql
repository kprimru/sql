USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SEARCH_STAT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SearchMonth, COUNT(*) AS SearchCount 
	FROM dbo.ClientSearchTable
	WHERE ClientID = @CLIENT
	GROUP BY SearchMonth, SearchMonthDate	
	ORDER BY SearchMonthDate DESC
END