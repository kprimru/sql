USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_EMAIL_LOAD_FROM_FOLDER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_EMAIL_LOAD_FROM_FOLDER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTR_EMAIL_LOAD_FROM_FOLDER]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Files Table
	(
		[Id]		Int Identity(1,1),
		[FileName]	VarChar(512),
		[Data]		VarChar(Max),
		[Distr]		VarChar(100),
		[Email]		VarChar(100)
	);

	DECLARE
		@Id				Int = 0,
		@FileName		VarChar(512);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Files([FileName])
		SELECT F.[FileName]
		FROM [File].[Find]('C:\DATA\MAIL\', '*.eml') AS F;

		WHILE (1 = 1) BEGIN
			SELECT TOP (1)
				@Id = [Id],
				@FileName = [FileName]
			FROM @Files
			WHERE Id > @Id
			ORDER BY [Id];

			IF @@RowCount < 1
				BREAK;

			UPDATE @Files SET
				[Data] = [File].[Read](@FileName)
			WHERE Id = @Id;
		END;

		UPDATE @Files SET
			[Distr] = SubString([Data], CharIndex('=CB=EE=E3=E8=ED', [Data]), 50)
		WHERE CharIndex('=CB=EE=E3=E8=ED', [Data]) != 0

		UPDATE @Files SET
			[Distr] = SubString([Data], CharIndex('> =EC=CF=C7=C9=CE: ', [Data]), 50)
		WHERE CharIndex('> =EC=CF=C7=C9=CE: ', [Data]) != 0

		UPDATE @Files SET
			[Distr] = Replace([Distr], '=CB=EE=E3=E8=ED: ', '')

		UPDATE @Files SET
			[Distr] = Replace([Distr], '> =EC=CF=C7=C9=CE: ', '')

		UPDATE @Files SET
			[Distr] = SubString([Distr], 1, CharIndex('=20', [Distr]) - 1)
		WHERE CharIndex('=20', [Distr]) != 0

		UPDATE @Files SET
			[Distr] = SubString([Distr], 1, CharIndex(Char(10), [Distr]) - 1)
		WHERE CharIndex(Char(10), [Distr]) != 0

		UPDATE @Files SET
			[Distr] = Ltrim(Rtrim(Replace([Distr], Char(13), '')))

		UPDATE @Files SET
			[Email] = SubString([Data], CharIndex('To: ', [Data]) + 4, 100);

		UPDATE @Files SET
			[Email] = SubString([Email], 1, CharIndex(Char(10), [Email]) - 1)
		WHERE CharIndex(Char(10), [Email]) != 0

		UPDATE @Files SET
			[Email] = SubString([Email], CharIndex('<', [Email]) + 1, CharIndex('>', [Email]) - CharIndex('<', [Email]) - 1)
		WHERE CharIndex('<', [Email]) != 0
			AND CharIndex('>', [Email]) != 0

		UPDATE @Files SET
			[Email] = Ltrim(Rtrim(Replace([Email], Char(13), '')))

		DELETE FROM @Files WHERE FileName IS NULL OR Distr IS NULL;

		--SELECT * FROM @Files WHERE Distr LIKE '146540%';

		INSERT INTO dbo.DistrEmail(HostId, Distr, Comp, Email, UpdUser, Date)
		SELECT
			--FileName,
			1,
			CASE WHEN CharIndex('_', F.[Distr]) != 0 THEN Left(F.Distr, CharIndex('_', F.[Distr]) - 1) ELSE F.[Distr] END,
			CASE WHEN CharIndex('_', F.[Distr]) != 0 THEN Right(F.Distr, 1) ELSE 1 END,
			--F.Distr,
			F.Email, 'Автомат', getDate()
		FROM
		(
			SELECT [Distr], [Email], FileName
			FROM @Files
		) AS F
		OUTER APPLY
		(
			SELECT TOP (1) *
			FROM dbo.DistrEmail AS E
			WHERE F.Distr = Cast(E.[Distr] AS VarChar(100)) + CASE WHEN E.[Comp] = 1 THEN '' ELSE '_' + CAst(E.[Comp] AS VarCHar(10)) END
			ORDER BY E.[Date] DESC
		) AS E
		WHERE E.[Email] IS NULL;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
