USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[CompanyDepo@Stage]
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
			
		IF EXISTS
			(
				SELECT *
				FROM Client.CompanyDepo
				WHERE Company_Id = @Company_Id
					AND Status_Id = @Status_STAGE
					AND STATUS = 1
			)
			RaisError('Компания уже задепонирована на следующий этап!', 16, 1);
			
		INSERT INTO Client.CompanyDepo(
					[Company_Id], [Number], [Status_Id], [Depo:Name], [Depo:Inn], [Depo:Region], [Depo:City], [Depo:Address],
					[Depo:Person1FIO], [Depo:Person1Phone], [Depo:Person2FIO], [Depo:Person2Phone],
					[Depo:Person3FIO], [Depo:Person3Phone], [Depo:Rival], [SortIndex])
		SELECT
					[Company_Id], NULL, @Status_STAGE, [Depo:Name], [Depo:Inn], [Depo:Region], [Depo:City], [Depo:Address],
					[Depo:Person1FIO], [Depo:Person1Phone], [Depo:Person2FIO], [Depo:Person2Phone],
					[Depo:Person3FIO], [Depo:Person3Phone], [Depo:Rival],
					IsNull((SELECT TOP (1) [SortIndex] FROM Client.CompanyDepo WHERE STATUS = 1 AND [Status_Id] = @Status_STAGE AND [SortIndex] IS NOT NULL ORDER BY [SortIndex] DESC) + 1, 1)
		FROM Client.CompanyDepo
		WHERE [Id] = @Id
	END TRY
	BEGIN CATCH
	
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
