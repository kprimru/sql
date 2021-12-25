USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[CompanyArchiveView]
WITH SCHEMABINDING
AS
	SELECT ID, ID_COMPANY
	FROM Client.CompanyArchive a
	WHERE a.STATUS = 1

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyArchiveView(ID)] ON [Client].[CompanyArchiveView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyArchiveView(ID_COMPANY)] ON [Client].[CompanyArchiveView] ([ID_COMPANY] ASC);
GO
