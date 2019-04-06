USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Client].[CompanyRivalView]
AS
	SELECT ID
	FROM
		(
			SELECT ID, ROW_NUMBER() OVER(PARTITION BY ID_COMPANY ORDER BY INFO_DATE DESC, BDATE DESC) AS RN			
			FROM Client.CompanyRival
			WHERE STATUS = 1
		) AS o_O
	WHERE RN = 1
