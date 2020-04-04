USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[CompanyDepo@Default]
	@Company_Id UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			[Depo:Region] = '25'
	END TRY
	BEGIN CATCH
			
		EXEC [Maintenance].[ReRaise Error];
	END CATCH	
END
