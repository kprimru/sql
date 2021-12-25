USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[CompanyControlView]
WITH SCHEMABINDING
AS
	SELECT ID, ID_COMPANY
	FROM Client.CompanyControl a
	WHERE a.STATUS = 1 AND a.REMOVE_DATE IS NULL

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyControlView(ID)] ON [Client].[CompanyControlView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyControlView(ID_COMPANY)] ON [Client].[CompanyControlView] ([ID_COMPANY] ASC);
GO
