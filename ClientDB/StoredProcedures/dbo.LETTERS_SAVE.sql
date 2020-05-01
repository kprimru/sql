USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[LETTERS_SAVE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(256),
	@GRP	NVARCHAR(256),
	@DATA	NVARCHAR(MAX),
	@TXT	NVARCHAR(MAX)
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

		IF @ID IS NULL
			INSERT INTO dbo.Letter(ID, NAME, GRP, DATA, TXT)
				VALUES(@ID, @NAME, @GRP, @DATA, @TXT)
		ELSE
			UPDATE dbo.Letter
			SET	NAME	=	@NAME,
				GRP		=	@GRP,
				DATA	=	@DATA,
				TXT		=	@TXT
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[LETTERS_SAVE] TO rl_letter_u;
GO