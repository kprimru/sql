USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Files@Refresh(Internal)]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Files@Refresh(Internal)]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[Files@Refresh(Internal)]
	@Document_Id	Int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@PageNumber	Int,
		@FileName	VarChar(4000),
		@PageFileName	VarChar(4000),
		@PageData		VarBinary(Max),
		@Directory	VarChar(4000);

	SELECT
		@Directory =
			'\\BIM\VOL1\LAWDEP\Хозяйственная деятельность\Сканированные Договоры (Авто)\' +
			Cast(DatePart(Year, D.[DATE]) AS VarChar(100)) + '\' +
			[dbo].[PrepareFileName](D.[NAME]) + '_' +
			[dbo].[PrepareFileName](R.[NAME]) + ' (' +
			[dbo].[PrepareFileName](C.[NAME]) + ')_' + Convert(VarChar(20), D.[DATE], 104) + '\'
	FROM dbo.ScanDocument AS D
	INNER JOIN dbo.Company AS C ON C.[ID] = D.[ID_COMPANY]
	INNER JOIN dbo.Direction AS R ON R.ID = D.ID_DIRECTION
	WHERE D.[ID] = @Document_Id;

	IF [File].[Exists](@Directory) = 1 BEGIN
		WHILE (1 = 1) BEGIN
			SELECT TOP (1) @FileName = [FileName]
			FROM [File].[Find](@Directory, '*.*');

			IF @@RowCount < 1
				BREAK;

			EXEC [File].[FileDelete] @FileName = @FileName;
		END;
	END;

	EXEC [File].[Create Directory] @DirName = @Directory;

	SET @PageNumber = 0;

	WHILE (1 = 1) BEGIN
		SELECT TOP (1)
			@PageNumber = P.[NUM],
			@PageFileName = @Directory + P.[NAME] + P.[EXT],
			@PageData = P.[DATA]
		FROM dbo.ScanPages AS P
		WHERE P.[ID_DOCUMENT] = @Document_Id
			AND P.[NUM] > @PageNumber
		ORDER BY
			P.[NUM];

		IF @@RowCount < 1
			BREAK;

		EXEC [File].[Write] @FileName = @PageFileName, @Text = @PageData, @CheckPath = 0;
	END;
END;
GO
