USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemNote@Save]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SystemNote@Save]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SystemNote@Save]
    @System_Id      SmallInt,
    @DistrType_Id   SmallInt,
    @Note           VarBinary(Max),
    @NoteWTitle     VarBinary(Max)
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

        IF @DistrType_Id IS NULL BEGIN
            UPDATE [dbo].[SystemNote] SET
                [NOTE]          = @Note,
                [NOTE_WTITLE]   = @NoteWTitle
            WHERE [ID_SYSTEM] = @System_Id;

            IF @@RowCount = 0
                INSERT INTO [dbo].[SystemNote]([ID_SYSTEM], [NOTE], [NOTE_WTITLE])
                VALUES (@System_Id, @Note, @NoteWTitle);
        END ELSE BEGIN
            UPDATE [dbo].[SystemNote:DistrType] SET
                [Note]          = @Note,
                [NoteWTitle]    = @NoteWTitle
            WHERE   [System_Id] = @System_Id
                AND [DistrType_Id] = @DistrType_Id;

            IF @@RowCount = 0
                INSERT INTO [dbo].[SystemNote:DistrType]([System_Id], [DistrType_Id], [Note], [NoteWTitle])
                VALUES (@System_Id, @DistrType_Id, @Note, @NoteWTitle);
        END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SystemNote@Save] TO rl_system_note_w;
GO
