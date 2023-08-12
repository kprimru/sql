USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[GROUP_PARAMS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[GROUP_PARAMS_SELECT]  AS SELECT 1')
GO


CREATE OR ALTER PROCEDURE [USR].[GROUP_PARAMS_SELECT]
    @FILTER    VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError        VarChar(512),
        @DebugContext    Xml,
        @Params            Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params            = @Params,
        @DebugContext    = @DebugContext OUT

    BEGIN TRY

        SELECT
			[GroupName]		= G.[Name],
            [Id]			= GP.[Id],
            [Group_Id]		= GP.[Group_Id],
            [Code]			= GP.[Code],
            [Name]			= GP.[Name],
            [SortIndex]		= GP.[SortIndex],
            [FieldName]		= GP.[FieldName],
			[ErrorCode]		= GP.[ErrorCode]
        FROM [USR].[Groups_Params]	AS GP
		INNER JOIN [USR].[Groups]	AS G	ON G.[Id] = GP.[Group_Id]
		WHERE @FILTER IS NULL
			OR GP.[Name] LIKE @FILTER
        ORDER BY GP.[SortIndex];

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [USR].[GROUP_PARAMS_SELECT] TO rl_usr_group_params_r;
GO
