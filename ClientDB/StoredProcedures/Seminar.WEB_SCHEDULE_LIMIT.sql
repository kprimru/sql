USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_SCHEDULE_LIMIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_SCHEDULE_LIMIT]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[WEB_SCHEDULE_LIMIT]
    @ID         UniqueIdentifier,
    @LIMIT      SmallInt            = NULL OUTPUT,
    @DISTR_S    VarChar(256)        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @HOST           Int,
        @DISTR          Int,
        @COMP           TinyInt,
        @CLIENT         Int,
        @SubhostName    VarChar(20),
        @MSG            VarChar(1000),
        @Status         SmallInt,

		@UseSubhostQuotes	Bit,
        @Subhost_Id     UniqueIdentifier,
        @Current        SmallInt;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @DISTR_S = NullIf(@DISTR_S, '');

		SET @UseSubhostQuotes = IsNull((SELECT TOP (1) [UseSubhostQuotes] FROM [Seminar].[Schedule] WHERE [ID] = @ID), 0);

        IF @DISTR_S IS NOT NULL
            EXEC Seminar.WEB_DISTR_CHECK @ID, @DISTR_S, @MSG OUTPUT, @STATUS OUTPUT, @HOST OUTPUT, @DISTR	OUTPUT, @COMP OUTPUT, @CLIENT OUTPUT, @SubhostName OUTPUT;

        -- это РИЦ или номер неизвестен
        IF @STATUS IS NULL OR @STATUS != 0 OR IsNull(@SubhostName, '') = '' OR @UseSubhostQuotes = 0 BEGIN
            SET @LIMIT = (SELECT TOP (1) LIMIT FROM Seminar.Schedule WHERE ID = @ID);

            SET @Current =
                (
                    SELECT Count(*)
                    FROM Seminar.Personal AS P
                    INNER JOIN Seminar.Status AS S ON P.ID_STATUS = S.ID
                    WHERE P.ID_SCHEDULE = @ID
                        AND S.INDX = 1
                        AND P.STATUS = 1
                );
        END ELSE BEGIN
            SET @Subhost_Id = (SELECT TOP (1) SH_ID FROM dbo.Subhost WHERE SH_REG = @SubhostName);
            SET @Limit = (SELECT TOP (1) LIMIT FROM Seminar.ScheduleSubhosts WHERE Schedule_Id = @ID AND Subhost_Id = @Subhost_Id);

            SET @Current =
                (
                    SELECT Count(*)
                    FROM Seminar.Personal AS P
                    INNER JOIN Seminar.Status AS S ON P.ID_STATUS = S.ID
                    WHERE P.ID_SCHEDULE = @ID
                        AND P.ID_CLIENT = @CLIENT
                        AND S.INDX = 1
                        AND P.STATUS = 1
                );
        END;

        SET @Limit = @Limit - IsNull(@Current, 0);

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[WEB_SCHEDULE_LIMIT] TO rl_seminar_web;
GO
