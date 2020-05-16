USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_SAVE]
	@Id					UniqueIdentifier,
	@Company_Id			UniqueIdentifier,
	@DepoName			VarChar(256),
	@DepoInn			VarChar(20),
	@DepoRegion			VarChar(10),
	@DepoCity			VarChar(128),
	@DepoAddress		VarChar(256),
	@DepoPerson1FIO		VarChar(256),
	@DepoPerson1Phone	VarChar(256),
	@DepoPerson2FIO		VarChar(256),
	@DepoPerson2Phone	VarChar(256),
	@DepoPerson3FIO		VarChar(256),
	@DepoPerson3Phone	VarChar(256),
	@DepoRival			VarChar(10),
	@Stage				Bit					= 0,
	@Tag				Bit					= 0
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
		@Number			Int,
		@SortIndex		Int,
		@Status			SmallInt,
		@Status_NEW		SmallInt,
		@Status_STAGE	SmallInt;

	BEGIN TRY
		IF @Id IS NULL BEGIN
			IF EXISTS
				(
					SELECT *
					FROM Client.CompanyDepo D
					INNER JOIN [Client].[Depo->Statuses] S ON D.[Status_Id] = S.[Id]
					WHERE D.[Company_Id] = @Company_Id
						AND D.[Status] = 1
						AND S.[Code] NOT IN ('REFUSED', 'TERMINATION')
				) AND @Stage = 0
				RaisError('Компания уже зарегистрирована в программе ДЕПО!', 16, 1);
			ELSE IF @Id IS NULL AND @Stage = 1
				IF EXISTS
					(
						SELECT *
						FROM Client.CompanyDepo D
						INNER JOIN [Client].[Depo->Statuses] S ON D.[Status_Id] = S.[Id]
						WHERE D.[Company_Id] = @Company_Id
							AND D.[Status] = 1
							AND S.[Code] IN ('STAGE')
					)
					RaisError('Компания уже задепонирована на следующий этап!', 16, 1);

			SET @Status_NEW		= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'NEW');
			SET @Status_STAGE	= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');

			IF @Stage = 0 BEGIN
				SELECT TOP (1)
					@Number	= [Number]
				FROM [Client].[Depo@Get Number]();

				IF @Number IS NULL
					RaisError('Не удалось получить новый номер для Депонирования!', 16, 1);

				SET @Status = @Status_NEW
			END ELSE BEGIN
				SET @SortIndex = IsNull((SELECT TOP (1) [SortIndex] FROM Client.CompanyDepo WHERE STATUS = 1 AND [Status_Id] = @Status_STAGE AND [SortIndex] IS NOT NULL ORDER BY [SortIndex] DESC) + 1, 1)
				SET @Status = @Status_STAGE
			END;

			INSERT INTO Client.CompanyDepo(
						[Company_Id], [Number], [Status_Id], [Depo:Name], [Depo:Inn], [Depo:Region], [Depo:City], [Depo:Address],
						[Depo:Person1FIO], [Depo:Person1Phone], [Depo:Person2FIO], [Depo:Person2Phone],
						[Depo:Person3FIO], [Depo:Person3Phone], [Depo:Rival], [SortIndex])
			VALUES
				(
					@Company_Id, @Number, @Status, @DepoName, @DepoInn, @DepoRegion, @DepoCity, @DepoAddress,
					@DepoPerson1FIO, @DepoPerson1Phone, @DepoPerson2FIO, @DepoPerson2Phone,
					@DepoPerson3FIO, @DepoPerson3Phone, @DepoRival, @SortIndex
				)
		END ELSE BEGIN
			IF
				(
					SELECT S.[Code]
					FROM Client.CompanyDepo D
					INNER JOIN [Client].[Depo->Statuses] S ON D.[Status_Id] = S.[Id]
					WHERE D.[Id] = @Id
				) NOT IN ('NEW', 'STAGE', 'TAG')
				RaisError('В данном статусе ДЕПО запрещено изменение данных!', 16, 1);

			IF @Tag = 1
				UPDATE Client.CompanyDepo
				SET [Status_Id]				= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'TAG'),
					[Depo:Rival]			= @DepoRival
				WHERE [Id] = @Id
			ELSE
				UPDATE Client.CompanyDepo
				SET [Depo:Name]				= @DepoName,
					[Depo:Inn]				= @DepoInn,
					[Depo:Region]			= @DepoRegion,
					[Depo:City]				= @DepoCity,
					[Depo:Address]			= @DepoAddress,
					[Depo:Person1FIO]		= @DepoPerson1FIO,
					[Depo:Person1Phone]		= @DepoPerson1Phone,
					[Depo:Person2FIO]		= @DepoPerson2FIO,
					[Depo:Person2Phone]		= @DepoPerson2Phone,
					[Depo:Person3FIO]		= @DepoPerson3FIO,
					[Depo:Person3Phone]		= @DepoPerson3Phone,
					[Depo:Rival]			= @DepoRival
				WHERE [Id] = @Id
		END;
	END TRY
	BEGIN CATCH

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DEPO_SAVE] TO rl_depo_w;
GO