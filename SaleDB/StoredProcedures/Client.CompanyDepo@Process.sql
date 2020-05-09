USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@Process]
	@GUIds		VarChar(Max),
	@Data		Xml
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Status_Id_NEW			SmallInt,
		@Status_Id_TAG			SmallInt,
		@Status_Id_ACCEPT		SmallInt,
		@Status_Id_ACTIVE		SmallInt,
		@Status_Id_REFUSED		SmallInt,
		@Status_Id_TERMINATION	SmallInt,
		@Status_Id_STAGE		SmallInt;

	DECLARE @DepoFile Table
	(
		[Ric]					SmallInt,
		[Code]					Int,
		[Priority]				Int,
		[Name]					VarChar(256),
		[Inn]					VarChar(20),
		[RegionAndAddress]		VarChar(256),
		[Person1FIO]			VarChar(128),
		[Person1Phone]			VarChar(128),
		[Result]				VarChar(50),
		[Status]				VarChar(50),
		[AlienInn]				VarChar(50),
		[DepoDate]				SmallDateTime,
		[DepoExpireDate]		SmallDateTime,
		[Rival]					VarChar(50),
		Primary Key Clustered([Code])
	);

	DECLARE @IDs Table
	(
		[Id]				UniqueIdentifier,
		PRIMARY KEY CLUSTERED([Id])
	);

	BEGIN TRY
		INSERT INTO @DepoFile
		SELECT *
		FROM [Client].[DepoList@Parse](@Data);

		INSERT INTO @IDs
		SELECT DISTINCT [Id]
		FROM Common.TableGUIDFromXML(@GUIds);

		SET @Status_Id_NEW			= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'NEW');
		SET @Status_Id_TAG			= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'NEW');
		SET @Status_Id_ACCEPT		= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'ACCEPT');
		SET @Status_Id_ACTIVE		= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'ACTIVE');
		SET @Status_Id_REFUSED		= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'REFUSED');
		SET @Status_Id_TERMINATION	= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'TERMINATION');
		SET @Status_Id_STAGE		= (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');

		BEGIN TRAN;

		INSERT INTO Client.CompanyDepo(
				[Master_Id], [Company_Id], [DateFrom], [DateTo], [Number], [ExpireDate], [Status_Id],
				[Depo:Name], [Depo:Inn], [Depo:Region], [Depo:City], [Depo:Address],
				[Depo:Person1FIO], [Depo:Person1Phone], [Depo:Person2FIO], [Depo:Person2Phone],
				[Depo:Person3FIO], [Depo:Person3Phone], [Depo:Rival], [Status], [UpdDate], [UpdUser])
		SELECT
			D.[Id], D.[Company_Id], D.[DateFrom], D.[DateTo], D.[Number], D.[ExpireDate], D.[Status_Id],
			D.[Depo:Name], D.[Depo:Inn], D.[Depo:Region], D.[Depo:City], D.[Depo:Address],
			D.[Depo:Person1FIO], D.[Depo:Person1Phone], D.[Depo:Person2FIO], D.[Depo:Person2Phone],
			D.[Depo:Person3FIO], D.[Depo:Person3Phone], D.[Depo:Rival], 2, GetDate(), Original_Login()
		FROM @IDs						AS I
		INNER JOIN Client.CompanyDepo	AS D ON I.[Id] = D.[Id];

		/*ToDo Переписать как один запрос, если будет тормозить
		Можно сделать LEFT JOIN на таблицу @DepoFile и с помощью CASE выбрать поля для UPDATE
		*/

		-- если есть запись ДЕПО со статусом "Новый" или "Ожидает акцепта" или "TAG", то делаем ее действующей и
		UPDATE D
		SET [Status_Id] 	= @Status_Id_ACTIVE,
			[DateFrom]		= F.[DepoDate],
			[ExpireDate]	= F.[DepoExpireDate],
			[UpdDate]		= GetDate(),
			[UpdUser]		= Original_Login()
		FROM Client.CompanyDepo 				AS D
		INNER JOIN @IDs							AS I ON D.[Id] = I.[Id]
		INNER JOIN @DepoFile					AS F ON F.[Code] = D.[Number]
		WHERE	D.[Status] = 1
			AND D.[Status_Id] IN (@Status_Id_NEW, @Status_Id_ACCEPT, @Status_Id_TAG);

		DELETE D
		FROM Client.CompanyDepo AS D
		WHERE D.Status = 1
			AND D.Status_Id IN (@Status_Id_STAGE)
			AND D.Company_Id IN
			(
				SELECT D.[Company_Id]
				FROM Client.CompanyDepo 				AS D
				INNER JOIN @IDs							AS I ON D.[Id] = I.[Id]
				WHERE	D.[Status] = 1
					AND D.[Status_Id] IN (@Status_Id_ACTIVE, @Status_Id_ACCEPT, @Status_Id_NEW, @Status_Id_TERMINATION)
					AND NOT EXISTS
						(
							SELECT *
							FROM @DepoFile					AS F
							WHERE F.[Code] = D.[Number]
						)
			);

		UPDATE D
		SET [Status_Id] 	= @Status_Id_REFUSED,
			[DateTo]		= CASE WHEN D.[DateFrom] IS NULL THEN NULL ELSE Common.DateOf(GetDate()) END,
			[UpdDate]		= GetDate(),
			[UpdUser]		= Original_Login()
		FROM Client.CompanyDepo 				AS D
		INNER JOIN @IDs							AS I ON D.[Id] = I.[Id]
		WHERE	D.[Status] = 1
			AND D.[Status_Id] IN (@Status_Id_ACTIVE, @Status_Id_ACCEPT, @Status_Id_TERMINATION)
			AND NOT EXISTS
				(
					SELECT *
					FROM @DepoFile					AS F
					WHERE F.[Code] = D.[Number]
				);

		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[CompanyDepo@Process] TO rl_depo_file_process;
GO