USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@StageAll]
	@IDs					VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	DECLARE
		@Status_STAGE		SmallInt;

	DECLARE @TIDs Table
	(
		Id	UniqueIdentifier Primary Key Clustered
	);

	BEGIN TRY
		IF @IDs IS NULL
			RaisError('Abstract error: @Id IS NULL!', 16, 1);

		SET @Status_STAGE	= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');

		INSERT INTO @TIDs
		SELECT ID
		FROM Common.TableGUIDFromXML(@IDs)

		IF EXISTS
			(
				SELECT *
				FROM Client.CompanyDepo D
				WHERE Company_Id IN (SELECT Company_Id FROM Client.CompanyDepo I WHERE I.Id IN (SELECT L.Id FROM @TIDs L))
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
		FROM Client.CompanyDepo D
		INNER JOIN @TIDs		I ON D.[Id] = I.[Id]
	END TRY
	BEGIN CATCH

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[CompanyDepo@StageAll] TO rl_depo_w;
GO
