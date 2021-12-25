USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Schedule@Get?Subhosts]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[Schedule@Get?Subhosts]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[Schedule@Get?Subhosts]
    @Id     UniqueIdentifier
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY
        SELECT
            [Subhost_Id]    = SH_ID,
            [SubhostName]   = SH_NAME,
            [Limit]         = IsNull(SS.Limit, SH_SEMINAR_DEFAULT_COUNT)
        FROM dbo.Subhost                    AS S
        LEFT JOIN Seminar.ScheduleSubhosts  AS SS ON S.SH_ID = SS.Subhost_Id AND SS.Schedule_Id = @Id
        WHERE S.SH_REG != ''
        ORDER BY SH_NAME;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[Schedule@Get?Subhosts] TO rl_seminar_admin;
GO
