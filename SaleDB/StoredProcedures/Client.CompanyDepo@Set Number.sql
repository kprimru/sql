USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@Set Number]
	@Id		UniqueIdentifier,
	@Number	Int
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE Client.CompanyDepo
		SET [Number] = @Number
		WHERE [Id] = @Id
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[CompanyDepo@Set Number] TO rl_depo_number;
GO