USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Web@Get?Limit]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[Web@Get?Limit]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[Web@Get?Limit]
    @ID         UniqueIdentifier,
    @DISTR_S    VarChar(256)        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Limit			SmallInt;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        EXEC [Seminar].[WEB_SCHEDULE_LIMIT]
			@ID			= @ID,
			@DISTR_S	= @DISTR_S,
			@LIMIT		= @Limit OUT;

		SELECT [LIMIT] = @Limit;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
