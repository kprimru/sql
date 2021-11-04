USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OnlineActivity@Load?Batch]
    @Data Xml
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @Activity Table
    (
        [Week_Id]       UniqueIdentifier    NOT NULL,
        [Login]         VarChar(256)        NOT NULL,
        [Host_Id]       Int                 NOT NULL,
        [Distr]         Int                 NOT NULL,
        [Comp]          TinyInt             NOT NULL,
        [Activity]      Bit                 NOT NULL,
        [LoginCnt]      SmallInt                NULL,
        [SessionTime]   SmallInt                NULL,
        [Email]         VarChar(256)            NULL,
        [FIO]           VarChar(256)            NULL,
        PRIMARY KEY CLUSTERED ([Week_Id], [Login])
    );

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        INSERT INTO @Activity([Week_Id], [Login], [Host_Id], [Distr], [Comp], [Activity], [LoginCnt], [SessionTime], [Email], [FIO])
        SELECT [Week_Id], [Login], [Host_Id], [Distr], [Comp], [Activity], [LoginCnt], [SessionTime], [Email], [FIO]
        FROM [dbo].[OnlineActivity@Parse](@Data);

        UPDATE A SET
            [ID_HOST]       = TA.[Host_Id],
            [DISTR]         = TA.[Distr],
            [COMP]          = TA.[Comp],
            [ACTIVITY]      = TA.[Activity],
            [LOGIN_CNT]     = TA.[LoginCnt],
            [SESSION_TIME]  = TA.[SessionTime],
            [Email]         = TA.[Email],
            [FIO]           = TA.[FIO]
        FROM @Activity TA
        INNER JOIN dbo.OnlineActivity AS A ON   A.[ID_WEEK] = TA.[Week_Id]
                                            AND A.[LGN] = TA.[Login]
        WHERE  [Common].[Is Equal(Int)](TA.[Host_Id], A.[ID_HOST]) = 0
            OR [Common].[Is Equal(Int)](TA.[Distr], A.[DISTR]) = 0
            OR [Common].[Is Equal(TinyInt)](TA.[Comp], A.[COMP]) = 0
            OR [Common].[Is Equal(Bit)](TA.[Activity], A.[ACTIVITY]) = 0
            OR [Common].[Is Equal(SmallInt)](TA.[LoginCnt], A.[LOGIN_CNT]) = 0
            OR [Common].[Is Equal(SmallInt)](TA.[SessionTime], A.[SESSION_TIME]) = 0
            OR [Common].[Is Equal(VarChar)](TA.[Email], A.[Email]) = 0
            OR [Common].[Is Equal(VarChar)](TA.[FIO], A.[FIO]) = 0;

        INSERT INTO dbo.OnlineActivity([ID_WEEK], [ID_HOST], [DISTR], [COMP], [LGN], [ACTIVITY], [LOGIN_CNT], [SESSION_TIME], [Email], [FIO])
        SELECT TA.[Week_Id], TA.[Host_Id], TA.[Distr], TA.[Comp], TA.[Login], TA.[Activity], TA.[LoginCnt], TA.[SessionTime], TA.[Email], TA.[FIO]
        FROM @Activity AS TA
        WHERE NOT EXISTS
            (
                SELECT *
                FROM [dbo].[OnlineActivity] AS A
                WHERE   A.[ID_WEEK] = TA.[Week_Id]
                    AND A.[LGN] = TA.[Login]
            );

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[OnlineActivity@Load?Batch] TO rl_import_data;
GO
