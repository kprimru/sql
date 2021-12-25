﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[CompanyNumberView]
WITH SCHEMABINDING
AS
	SELECT ID, NUMBER
	FROM Client.Company a
	WHERE a.STATUS = 1
		AND NUMBER IS NOT NULL

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CompanyNumberView(ID)] ON [Client].[CompanyNumberView] ([ID] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Client.CompanyNumberView(NUMBER)] ON [Client].[CompanyNumberView] ([NUMBER] ASC);
GO
