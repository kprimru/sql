USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_NOTE_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_NOTE_SET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SYSTEM_NOTE_SET]
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
		SET NOTE = @NOTE
		WHERE ID_SYSTEM = @ID

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.SystemNote(ID_SYSTEM, NOTE)
				VALUES(@ID, @NOTE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_NOTE_SET] TO rl_system_note_w;
GO
