USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[LETTER_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[LETTER_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[LETTER_UPDATE]
	@id INT,
	@directory VARCHAR(100),
	@name VARCHAR(100)
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

		UPDATE dbo.LetterTable
		SET LetterDirectory = @directory,
			LetterName = @name
		WHERE LetterID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[LETTER_UPDATE] TO rl_letter_u;
GO
