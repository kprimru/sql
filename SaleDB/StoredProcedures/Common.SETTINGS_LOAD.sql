USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[SETTINGS_LOAD]
    @ID_USER        UNIQUEIDENTIFIER
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
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        SELECT TOP (1)
            DEFAULT_RUS, SEARCH_EXT, MULTY_SEARCH, WARNING_TIME, FONT_SIZE, OFFER_PATH,
            AUTH, ROBOT_HOST, ROBOT_LOGIN, ROBOT_PASS
        FROM
        (
            SELECT
                1 AS ORD, DEFAULT_RUS, SEARCH_EXT, MULTY_SEARCH, WARNING_TIME, FONT_SIZE, OFFER_PATH
            FROM Common.Settings
            WHERE ID_USER = @ID_USER

            UNION ALL

            SELECT
                2 AS ORD, DEFAULT_RUS, SEARCH_EXT, MULTY_SEARCH, WARNING_TIME, FONT_SIZE, OFFER_PATH
            FROM Common.Settings
            WHERE ID_USER IS NULL
        ) AS S
        OUTER APPLY
        (
            SELECT AUTH = VALUE
            FROM Common.GlobalSettings
            WHERE NAME = N'AUTH'
        ) AS A
        OUTER APPLY
        (
            SELECT ROBOT_HOST = VALUE
            FROM Common.GlobalSettings
            WHERE NAME = N'ROBOT_HOST'
        ) AS RH
        OUTER APPLY
        (
            SELECT ROBOT_LOGIN = VALUE
            FROM Common.GlobalSettings
            WHERE NAME = N'ROBOT_LOGIN'
        ) AS RL
        OUTER APPLY
        (
            SELECT ROBOT_PASS = VALUE
            FROM Common.GlobalSettings
            WHERE NAME = N'ROBOT_PASS'
        ) AS RP
        ORDER BY S.ORD;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Common].[SETTINGS_LOAD] TO public;
GO
