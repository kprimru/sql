USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[CompanyImport@Load]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[CompanyImport@Load]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[CompanyImport@Load]
	@Data			Xml
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
		@ErrorNumbers VarChar(Max),
		@DepoStatus_ACTIVE	SmallInt;

	DECLARE @ForImport Table
	(
		[Id]				Integer			Identity(1,1),
		[CompanyName]		VarChar(256),
		[LegalForm]			VarChar(32),
		[Inn]				VarChar(20),
		[Address]			VarChar(256),
		[Surname]			VarChar(256),
		[Name]				VarChar(256),
		[Patron]			VarChar(256),
		[Activity]			VarChar(256),
		[Phones]			VarChar(256),
		[Email]				VarChar(256)
	);

	BEGIN TRY
		INSERT INTO @ForImport
		SELECT *
		FROM [Client].[ImportList@Parse](@Data);

		SELECT
			[CompanyName],
			[LegalForm],
			[Inn],
			[Address],
			[Surname],
			I.[Name],
			[Patron],
			[Activity],
			[Phones],
			I.[Email],
			C.[Company_Id],
			CC.[NUMBER],
			CC.[NAME] AS [SCompanyName],
			Cast(CASE WHEN [Company_Id] IS NOT NULL THEN 0 ELSE 1 END AS Bit) AS [CheckedForCreate],
			Cast(CASE WHEN [Company_Id] IS NOT NULL THEN 1 ELSE 0 END AS Bit) AS [CheckedForUpdate]
		FROM @ForImport AS I
		OUTER APPLY
		(
			SELECT N.[Company_Id]
			FROM [Client].[CompanyInn] AS N
			WHERE N.[Inn] = I.[Inn]
				AND I.[Inn] != ''
			---
			UNION
			---
			SELECT P.[ID_COMPANY]
			FROM [Client].[CompanyPhone] AS P
			INNER JOIN [Client].[Company] AS C ON C.[ID] = P.[ID_COMPANY]
			WHERE EXISTS
				(
					SELECT V.[value]
					FROM String_Split(I.[Phones], ',') AS V
					WHERE Replace(Replace(Replace(Replace(V.[value], '(', ''), ')', ''),  '-', ''),  ' ', '') = P.[PHONE_S]
						OR
						(
							Len(Replace(Replace(Replace(Replace(V.[value], '(', ''), ')', ''),  '-', ''),  ' ', '')) > 7
							AND Len(P.[PHONE_S]) > 7
							AND Right(Replace(Replace(Replace(Replace(V.[value], '(', ''), ')', ''),  '-', ''),  ' ', ''), 7) = Right(P.[PHONE_S], 7)
						)
				)
				AND P.[STATUS] = 1
				AND C.[STATUS] = 1
			---
			UNION
			---
			SELECT C.[ID]
			FROM [Client].[Company] AS C
			WHERE C.[STATUS] = 1
				AND (
						C.[NAME] LIKE '%' + Replace(Replace(Replace(Replace(I.[CompanyName], 'ООО', ''), 'ИП', ''), '"', ''), ' ', '%') + '%'
						--OR
						--Replace(Replace(Replace(Replace(I.[CompanyName], 'ООО', ''), 'ИП', ''), '"', ''), ' ', '%') LIKE '%' + C.[NAME] + '%'
					)
		) AS C
		LEFT JOIN [Client].[Company] AS CC ON CC.[ID] = C.[Company_Id]
		WHERE I.[CompanyName] != ''
		ORDER BY I.[Id], CC.[NUMBER];


	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[CompanyImport@Load] TO rl_company_import;
GO
