USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_NOTE_TITLE_SET]
	@ID		INT,
	@NOTE	VARBINARY(MAX)
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

		UPDATE dbo.SystemNote
		SET NOTE_WTITLE = @NOTE
		WHERE ID_SYSTEM = @ID

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.SystemNote(ID_SYSTEM, NOTE_WTITLE)
				VALUES(@ID, @NOTE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SYSTEM_NOTE_TITLE_SET] TO rl_system_u;
GO