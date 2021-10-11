USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[WEB_PERSONAL_CONFIRM]
    @SCHEDULE   UNIQUEIDENTIFIER,
    @DISTR_S    NVARCHAR(256),
    @PSEDO      NVARCHAR(256),
    @EMAIL      NVARCHAR(256),
    @ADDRESS    NVARCHAR(256),
    @STATUS     SMALLINT OUTPUT,
    @MSG        NVARCHAR(2048) OUTPUT
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

        DECLARE
            @HOST           Int,
            @DISTR          Int,
            @COMP           TinyInt,
            @CLIENT         Int,
            @SubhostName    VarChar(20);

        EXEC Seminar.WEB_DISTR_CHECK @SCHEDULE, @DISTR_S, @MSG OUTPUT, @STATUS OUTPUT, @HOST OUTPUT, @DISTR	OUTPUT, @COMP OUTPUT, @CLIENT OUTPUT, @SubhostName OUTPUT;

        IF @STATUS = 0
        BEGIN
            IF @SubhostName = '' BEGIN
                -- клиент Базиса
                IF (SELECT LIMIT FROM Seminar.Schedule WHERE ID = @SCHEDULE) <=
                                (
                                    SELECT COUNT(*)
                                    FROM Seminar.Personal       AS a
                                    INNER JOIN Seminar.Status   AS b ON a.ID_STATUS = b.ID
                                    WHERE ID_SCHEDULE = @SCHEDULE AND b.INDX = 1 AND a.STATUS = 1
                                ) BEGIN
                    SET @STATUS = 1;
                    SET @MSG = 'Свободные места для записи на семинар закончились';
                END ELSE BEGIN
                    INSERT INTO Seminar.Personal(ID_SCHEDULE, ID_CLIENT, PSEDO, EMAIL, ID_STATUS, ADDRESS)
                    SELECT @SCHEDULE, @CLIENT, @PSEDO, @EMAIL,
                        CASE
                            WHEN (SELECT LIMIT FROM Seminar.Schedule WHERE ID = @SCHEDULE) >
                                    (
                                        SELECT COUNT(*)
                                        FROM Seminar.Personal       AS a
                                        INNER JOIN Seminar.Status   AS b ON a.ID_STATUS = b.ID
                                        WHERE ID_SCHEDULE = @SCHEDULE AND b.INDX = 1 AND a.STATUS = 1
                                    ) THEN
                            (
                                SELECT ID
                                FROM Seminar.Status
                                WHERE INDX = 1
                            )
                            ELSE
                            (
                                SELECT ID
                                FROM Seminar.Status
                                --WHERE INDX = 2
                                -- это не даст записываться в резервный список
                                WHERE INDX = 10
                            )
                        END, @ADDRESS;
                END
            END ELSE BEGIN
                -- клиент подхоста

                -- ToDo сделать нормально
                IF (
                        SELECT LIMIT
                        FROM Seminar.ScheduleSubhosts AS SS
                        INNER JOIN dbo.Subhost AS S ON SS.Subhost_Id = S.SH_ID
                        WHERE SS.Schedule_Id = @SCHEDULE
                            AND S.SH_REG = @SubhostName
                    ) <=
                    (
                        SELECT COUNT(*)
                        FROM Seminar.Personal       AS P
                        INNER JOIN Seminar.Status   AS S ON P.ID_STATUS = S.ID
                        WHERE ID_SCHEDULE = @SCHEDULE
                            AND P.ID_CLIENT = @CLIENT
                            AND S.INDX = 1
                            AND P.STATUS = 1
                    ) BEGIN
                    SET @STATUS = 1;
                    SET @MSG = 'Невозможно записать сотрудника, превышен лимит свободных мест';
                    --RaisError('Невозможно записать сотрудника, превышен лимит свободных мест', 16, 1);
                END ELSE IF (SELECT LIMIT FROM Seminar.Schedule WHERE ID = @SCHEDULE) <=
                                (
                                    SELECT COUNT(*)
                                    FROM Seminar.Personal       AS a
                                    INNER JOIN Seminar.Status   AS b ON a.ID_STATUS = b.ID
                                    WHERE ID_SCHEDULE = @SCHEDULE AND b.INDX = 1 AND a.STATUS = 1
                                ) BEGIN
                    SET @STATUS = 1;
                    SET @MSG = 'Свободные места для записи на семинар закончились';
                    --RaisError('Свободные места для записи на семинар закончились', 16, 1);
                END ELSE BEGIN
                    INSERT INTO Seminar.Personal(ID_SCHEDULE, ID_CLIENT, PSEDO, EMAIL, ID_STATUS, ADDRESS, [Host_Id], Distr, Comp)
                    SELECT @SCHEDULE, @CLIENT, @PSEDO, @EMAIL,
                        CASE
                            WHEN
                                (
                                    SELECT LIMIT
                                    FROM Seminar.ScheduleSubhosts AS SS
                                    INNER JOIN dbo.Subhost AS S ON SS.Subhost_Id = S.SH_ID
                                    WHERE SS.Schedule_Id = @SCHEDULE
                                        AND S.SH_REG = @SubhostName
                                ) >
                                (
                                    SELECT COUNT(*)
                                    FROM Seminar.Personal       AS P
                                    INNER JOIN Seminar.Status   AS S ON P.ID_STATUS = S.ID
                                    WHERE ID_SCHEDULE = @SCHEDULE
                                        AND P.ID_CLIENT = @CLIENT
                                        AND S.INDX = 1
                                        AND P.STATUS = 1
                                ) THEN
                            (
                                SELECT ID
                                FROM Seminar.Status
                                WHERE INDX = 1
                            )
                            ELSE
                            (
                                SELECT ID
                                FROM Seminar.Status
                                --WHERE INDX = 2
                                -- это не даст записываться в резервный список
                                WHERE INDX = 10
                            )
                        END, @ADDRESS, @Host, @Distr, @Comp;
                END;
            END;
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
GRANT EXECUTE ON [Seminar].[WEB_PERSONAL_CONFIRM] TO rl_seminar_web;
GO
