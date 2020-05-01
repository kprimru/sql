USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@UnStage]
	@Id					UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Company_Id			UniqueIdentifier,
		@Status_STAGE		SmallInt;

	BEGIN TRY
		IF @Id IS NULL
			RaisError('Abstract error: @Id IS NULL!', 16, 1);

		SET @Status_STAGE	= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');
		SET @Company_Id = (SELECT TOP (1) [Company_Id] FROM [Client].[CompanyDepo] WHERE [Id] = @Id);

		IF NOT EXISTS
			(
				SELECT *
				FROM Client.CompanyDepo
				WHERE Company_Id = @Company_Id
					AND Status_Id = @Status_STAGE
			)
			RaisError('Компания не задепонирована на следующий этап!', 16, 1);

		DELETE
		FROM Client.CompanyDepo
		WHERE [Company_Id] = @Company_Id
			AND [Status_Id] = @Status_STAGE;
	END TRY
	BEGIN CATCH

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Client].[CompanyDepo@UnStage] TO rl_depo_w;
GO