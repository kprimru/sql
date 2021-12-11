USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[CompanyWarningView]
WITH SCHEMABINDING
AS
	SELECT ID, ID_COMPANY
	FROM Client.CompanyWarning a
	WHERE a.STATUS = 1 AND a.END_DATE IS NULL

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyWarningView(ID_COMPANY,ID)] ON [Client].[CompanyWarningView] ([ID_COMPANY] ASC, [ID] ASC);
GO
