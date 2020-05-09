USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientSearchView]
WITH SCHEMABINDING
AS
	SELECT
		ClientID, SearchMonthDate, COUNT_BIG(*) AS CNT
	FROM dbo.ClientSearchTable
	GROUP BY ClientID, SearchMonthDate
GO
