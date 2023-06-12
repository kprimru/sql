USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[CompanyCallView]', 'V ') IS NULL EXEC('CREATE VIEW [Client].[CompanyCallView]  AS SELECT 1')
GO
ALTER VIEW [Client].[CompanyCallView]
WITH SCHEMABINDING
AS
	SELECT a.ID, COUNT_BIG(*) AS CNT
	FROM
		Client.Company a
		INNER JOIN Client.Call b ON a.ID = b.ID_COMPANY
	WHERE a.STATUS = 1 AND b.STATUS = 1
	GROUP BY a.ID

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyCallView(ID)] ON [Client].[CompanyCallView] ([ID] ASC);
GO
