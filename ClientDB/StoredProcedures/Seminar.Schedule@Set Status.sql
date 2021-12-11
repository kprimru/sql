USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Schedule@Set Status]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[Schedule@Set Status]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[Schedule@Set Status]
    @Id         UniqueIdentifier,
    @Status_Id  Char(1)
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

        UPDATE [Seminar].[Schedule] SET
            [Status_Id] = @Status_Id
        WHERE [Id] = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
