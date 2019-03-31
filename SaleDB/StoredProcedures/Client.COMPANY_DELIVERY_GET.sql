USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Client].[COMPANY_DELIVERY_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT FIO, POS, EMAIL, DATE, PLAN_DATE, OFFER, STATE
	FROM Client.CompanyDelivery
	WHERE ID = @ID	
END
