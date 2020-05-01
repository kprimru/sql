USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@Set Status]
	@Id			UniqueIdentifier,
	@Status_Id	SmallInt
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE Client.CompanyDepo
		SET [Status_Id] = @Status_Id
		WHERE [Id] = @Id
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Client].[CompanyDepo@Set Status] TO rl_depo_status;
GO