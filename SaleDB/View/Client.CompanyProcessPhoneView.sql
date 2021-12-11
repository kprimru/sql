USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[CompanyProcessPhoneView]
WITH SCHEMABINDING
AS
	SELECT
		a.ID, ID_PERSONAL, c.SHORT
	FROM
		Client.Company a
		INNER JOIN Client.CompanyProcess b ON a.ID = b.ID_COMPANY
		INNER JOIN Personal.OfficePersonal c ON c.ID = b.ID_PERSONAL
	WHERE a.STATUS = 1 AND b.EDATE IS NULL AND PROCESS_TYPE = N'PHONE'

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyProcessPhoneView(ID)] ON [Client].[CompanyProcessPhoneView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcessPhoneView(ID_PERSONAL)] ON [Client].[CompanyProcessPhoneView] ([ID_PERSONAL] ASC);
GO
