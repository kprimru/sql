USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemNote@Get]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SystemNote@Get]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SystemNote@Get]
    @System_Id      SmallInt    =   NULL,
    @DistrType_Id   SmallInt    =   NULL
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

        SELECT
            [Note] = NOTE,
            [NoteWTitle] = NOTE_WTITLE
        FROM [dbo].[SystemNote]
        WHERE   @DistrType_Id IS NULL
            AND ID_SYSTEM = @System_Id

        UNION ALL

        SELECT
            [Note] = [Note],
            [NoteWTitle] = [NoteWTitle]
        FROM [dbo].[SystemNote:DistrType]
        WHERE   [System_Id] = @System_Id
            AND [DistrType_Id] = @DistrType_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SystemNote@Get] TO rl_system_note_r;
GO
