USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@Load]
	@Data			Xml
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@ErrorNumbers VarChar(Max),
		@DepoStatus_ACTIVE	SmallInt;

	DECLARE @DepoFile Table
	(
		[Ric]				SmallInt,
		[Code]				Int,
		[Priority]			Int,
		[Name]				VarChar(256),
		[Inn]				VarChar(20),
		[RegionAndAddress]	VarChar(256),
		[Person1FIO]		VarChar(128),
		[Person1Phone]		VarChar(128),
		[Result]			VarChar(50),
		[Status]			VarChar(50),
		[AlienInn]			VarChar(50),
		[DepoDate]			SmallDateTime,
		[DepoExpireDate]	SmallDateTime,
		[Rival]				VarChar(50),
		Primary Key Clustered([Code])
	);

	BEGIN TRY
		RaisError('Функционал заблокирован.', 16, 2);

		INSERT INTO @DepoFile
		SELECT *
		FROM [Client].[DepoList@Parse](@Data);

		SET @ErrorNumbers = NULL;
		SELECT @ErrorNumbers =
		Reverse(Stuff(Reverse(
			(
				SELECT Cast(D.[Code] AS VarChar(20)) + ','
				FROM @DepoFile D
				WHERE NOT EXISTS
					(
						SELECT *
						FROM Client.Company C
						WHERE	C.STATUS = 1
							AND C.DEPO_NUM = D.[Code]
							AND C.[DEPO] = 1
					)
				ORDER BY D.[Code]
				FOR XML PATH('')
			)
		), 1, 1, ''))
		OPTION (RECOMPILE);

		IF @ErrorNumbers IS NOT NULL
			RaisError('Не найдены компании с номерами %s', 16, 2, @ErrorNumbers);

		SET @ErrorNumbers =
		Reverse(Stuff(Reverse(
			(
				SELECT Cast(DEPO_NUM AS VarCHar(20)) + ','
				FROM Client.Company
				WHERE STATUS = 1
					AND DEPO = 1
					AND DEPO_NUM IS NOT NULL
				GROUP BY DEPO_NUM
				HAVING COUNT(*) > 1
				FOR XML PATH('')
			)
		), 1, 1, ''));

		IF @ErrorNumbers IS NOT NULL
			RaisError('Надены дубликаты номеров ДЕПО: %s', 16, 2, @ErrorNumbers);

		SET @DepoStatus_ACTIVE = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'ACTIVE');

		DELETE FROM Client.CompanyDepo;

		INSERT INTO Client.CompanyDepo(
				[Company_Id], [DateFrom], [Number], [ExpireDate], [Status_Id],
				[Depo:Name], [Depo:Inn], [Depo:Region], [Depo:City], [Depo:Address],
				[Depo:Person1FIO], [Depo:Person1Phone], [Depo:Rival])
		SELECT
			C.[Id], D.[DepoDate], D.[Code], D.[DepoExpireDate], @DepoStatus_ACTIVE,
			D.[Name], D.[Inn], RGN.[Depo:Region], CT.[Depo:City], CT.[Depo:Address?Without Region And City],
			P.[Depo:Person1FIO], [Person1Phone], [Rival]
		FROM @DepoFile AS D
		CROSS APPLY
		(
			SELECT TOP (1) C.[Id]
			FROM Client.Company C
			WHERE	C.[STATUS] = 1
				AND C.[DEPO_NUM] = D.[Code]
				AND C.[DEPO] = 1
		) AS C
		CROSS APPLY
		(
			SELECT
				[Depo:Address?Without Region] = CASE WHEN [RegionAndAddress] LIKE '25,%' THEN Right([RegionAndAddress], Len([RegionAndAddress]) - 3) ELSE [RegionAndAddress] END,
				[Depo:Region] = CASE WHEN [RegionAndAddress] LIKE '25,%' THEN '25' ELSE '' END
		) AS RGN
		CROSS APPLY
		(
			SELECT
				[Depo:City] = CASE WHEN [Depo:Region] != '' THEN Left([Depo:Address?Without Region], CharIndex(',', [Depo:Address?Without Region]) - 1) ELSE '' END,
				[Depo:Address?Without Region And City] = CASE WHEN [Depo:Region] != '' THEN Right([Depo:Address?Without Region], Len([Depo:Address?Without Region]) - CharIndex(',', [Depo:Address?Without Region])) ELSE D.[RegionAndAddress] END
		) AS CT
		CROSS APPLY
		(
			SELECT
				[Depo:Person1FIO] = CASE WHEN Right(D.[Person1FIO], 3) = '(1)' THEN Left(D.[Person1FIO], Len(D.[Person1FIO]) - 3) ELSE D.[Person1FIO] END
		) AS P
		OPTION (RECOMPILE);

	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[CompanyDepo@Load] TO rl_depo_file_process;
GO