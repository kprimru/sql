USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[CompanyProcessManagerView]', 'V ') IS NULL EXEC('CREATE VIEW [Client].[CompanyProcessManagerView]  AS SELECT 1')
GO
ALTER VIEW [Client].[CompanyProcessManagerView]
WITH SCHEMABINDING
AS
	SELECT
		a.ID, ID_PERSONAL, c.SHORT
	FROM
		Client.Company a
		INNER JOIN Client.CompanyProcess b ON a.ID = b.ID_COMPANY
		INNER JOIN Personal.OfficePersonal c ON c.ID = b.ID_PERSONAL
	WHERE a.STATUS = 1 AND b.EDATE IS NULL AND PROCESS_TYPE = N'MANAGER'

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyProcessManagerView(ID)] ON [Client].[CompanyProcessManagerView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyProcessManagerView(ID_PERSONAL)] ON [Client].[CompanyProcessManagerView] ([ID_PERSONAL] ASC);
GO
