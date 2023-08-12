USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Din].[SystemType:Synonyms@Save]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Din].[SystemType:Synonyms@Save]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Din].[SystemType:Synonyms@Save]
	@Type_Id    Int,
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
		FROM [Din].[SystemType:Synonyms]
		WHERE [Type_Id] = @Type_Id;

		INSERT INTO [Din].[SystemType:Synonyms]([Type_Id], [SST_NAME], [SST_NOTE])
		SELECT @Type_Id, c.value('@SST_NAME[1]', 'VarChar(100)'), c.value('@SST_NOTE[1]', 'VarChar(100)')
		FROM @Synonyms.nodes('/root/item') a(c)


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
