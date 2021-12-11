USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientSearchView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientSearchView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientSearchView]
WITH SCHEMABINDING
AS
	SELECT
		ClientID, SearchMonthDate, COUNT_BIG(*) AS CNT
	FROM dbo.ClientSearchTable
	GROUP BY ClientID, SearchMonthDate

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientSearchView(ClientID,SearchMonthDate)] ON [dbo].[ClientSearchView] ([ClientID] ASC, [SearchMonthDate] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientSearchView(SearchMonthDate)+(ClientID,CNT)] ON [dbo].[ClientSearchView] ([SearchMonthDate] ASC) INCLUDE ([ClientID], [CNT]);
GO
