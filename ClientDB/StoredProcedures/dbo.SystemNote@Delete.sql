USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemNote@Delete]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SystemNote@Delete]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SystemNote@Delete]
    @System_Id      SmallInt,
    @DistrType_Id   SmallInt
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

        DELETE [dbo].[SystemNote:DistrType]
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
GRANT EXECUTE ON [dbo].[SystemNote@Delete] TO rl_system_note_w;
GO
