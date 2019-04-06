USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Client].[COMPANY_DELIVERY_PERSONAL]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT PERSONAL
	FROM Client.CompanyDelivery
	ORDER BY PERSONAL
END
