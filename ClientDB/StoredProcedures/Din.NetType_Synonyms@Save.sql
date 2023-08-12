USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Din].[NetType:Synonyms@Save]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Din].[NetType:Synonyms@Save]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Din].[NetType:Synonyms@Save]
	@Net_Id     Int,
	@Synonyms   Xml
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DELETE
		FROM [Din].[NetType:Synonyms]
		WHERE Net_Id = @Net_Id;

		INSERT INTO [Din].[NetType:Synonyms]([Net_Id], [NT_NAME], [NT_NOTE])
		SELECT N.[Net_Id], N.[Name], N.[Note]
		FROM
		(
			SELECT
				[Net_Id]	= @Net_Id,
				[Name]		= c.value('@NT_NAME[1]', 'VarChar(100)'),
				[Note]		= c.value('@NT_NOTE[1]', 'VarChar(100)')
			FROM @Synonyms.nodes('/root/item') a(c)
		) AS N
		WHERE N.[Name] != '' OR N.[Note] != '';

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
