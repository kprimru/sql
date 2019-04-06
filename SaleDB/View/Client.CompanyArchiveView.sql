USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Client].[CompanyArchiveView]
WITH SCHEMABINDING
AS
	SELECT ID, ID_COMPANY
	FROM Client.CompanyArchive a
	WHERE a.STATUS = 1
