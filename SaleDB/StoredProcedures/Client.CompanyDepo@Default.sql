USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@Default]
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
GRANT EXECUTE ON [Client].[CompanyDepo@Default] TO rl_depo_r;
GO