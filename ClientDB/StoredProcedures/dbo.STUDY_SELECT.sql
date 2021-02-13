USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STUDY_SELECT]
    @CLIENT     Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @Study Table
    (
        [Id]        UniqueIdentifier NOT NULL,
        [UPD_DATE]  DateTime        NOT NULL
        PRIMARY KEY CLUSTERED ([Id])
    );

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        INSERT INTO @Study
        SELECT ID, Z.UPD_DATE
        FROM dbo.ClientStudy a
        CROSS APPLY
        (
            SELECT TOP (1) [UPD_DATE]
            FROM
            (
                SELECT TOP (1) Z.[UPD_DATE]
                FROM dbo.ClientStudy AS Z
                WHERE Z.ID_MASTER = A.ID
                ORDER BY Z.[UPD_DATE]

                UNION ALL

                SELECT A.UPD_DATE
            ) AS Z
            ORDER BY Z.[UPD_DATE]
        ) AS Z
        WHERE   ID_CLIENT = @CLIENT
            AND STATUS = 1;

        SELECT
            [ID]        = A.[ID],
            [MST]       = NULL,
            [ID_STUDY]  = A.[ID],
            [DATE]      = A.[DATE],
            [PLACE]     = [LessonPlaceName],
            [PERS]      = [TeacherName],
            [NOTE]      = [NOTE],
            [NEED]      =
                            REVERSE(STUFF(REVERSE(
                                (
                                    SELECT SystemShortName + ','
                                    FROM
                                        dbo.ClientStudySystem z
                                        INNER JOIN dbo.SystemTable y ON z.ID_SYSTEM = y.SystemID
                                    WHERE z.ID_STUDY = a.ID
                                    ORDER BY systemorder FOR XML PATH('')
                                )
                            ), 1, 1, '')) + CHAR(10) + NEED,
            [RECOMEND]      = [RECOMEND],
            [SERTIFICAT]    = NULL,
            [POSITION]      = NULL,
            [TEACHED]       = [TEACHED],
            [STUDY_TYPE]    = b.[NAME],
            [RIVAL]         = [RIVAL],
            [AGREEMENT]     = CASE AGREEMENT WHEN 1 THEN 'Да' ELSE 'Нет' END,
            [UPD_DATE]      = I.[UPD_DATE]
        FROM @Study                 AS I
        INNER JOIN dbo.ClientStudy  AS A ON I.[ID] = A.[ID]
        LEFT JOIN dbo.TeacherTable ON TeacherID = ID_TEACHER
        LEFT JOIN dbo.LessonPlaceTable ON LessonPlaceID = ID_PLACE
        LEFT JOIN dbo.StudyType b ON b.ID = a.ID_TYPE

        UNION ALL

        SELECT
            [ID]        = A.[ID],
            [MST]       = I.[ID],
            [ID_STUDY]  = A.[ID_STUDY],
            [DATE]      = NULL,
            [PLACE]     = NULL,
            [PERS]      = ISNULL(SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(PATRON, '') + CASE
                                WHEN ISNULL(GR_COUNT, 1) = 1 THEN ''
                                ELSE ' (' + CONVERT(NVARCHAR(32), GR_COUNT) + ')'
                            END,
            [NOTE]      = b.NOTE,
            [NEED]      = b.NEED,
            [RECOMEND]      = b.RECOMEND,
            [SERTIFICAT]    = c.NAME,
            [POSITION]      = a.POSITION,
            [TEACHED]       = B.[TEACHED],
            [STUDY_TYPE]    = D.NAME,
            [RIVAL]         = [RIVAL],
            [AGREEMENT]     = NULL,
            [UPD_DATE]      = I.UPD_DATE
        FROM @Study AS I
        INNER JOIN dbo.ClientStudyPeople a ON A.ID_STUDY = I.ID
        INNER JOIN dbo.ClientStudy AS B ON I.ID = B.ID
        LEFT JOIN dbo.StudyType D ON D.ID = B.ID_TYPE
        LEFT JOIN dbo.SertificatType c ON c.ID = a.ID_SERT_TYPE
        ORDER BY DATE DESC, PERS

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_SELECT] TO rl_client_study_r;
GO