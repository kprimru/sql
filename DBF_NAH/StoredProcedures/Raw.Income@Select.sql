USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Raw].[Income@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Raw].[Income@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [Raw].[Income@Select]
    @Id                 Int,
    @OnlyUnloaded       Bit = 0,
    @HideNotForImport   Bit = 1
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

        SET @HideNotForImport = IsNull(@HideNotForImport, 1);
        SET @OnlyUnloaded = IsNull(@OnlyUnloaded, 0);

        SELECT
            D.[Id],
            [AllowChecked] = AC.[AllowChecked],
            [Checked] = CH.[Checked],
            [CL_ID] = IsNull(CD.[CL_ID], C.[CL_ID]),
            [CL_PSEDO] = IsNull(CD.[CL_PSEDO], C.[CL_PSEDO]),
            CI.[FindByInnCount],
            D.[Date], D.[Inn], D.[Name], D.[Purpose], D.[Num], D.[Price], D.[NotForImport],
            E.[Err]
        FROM [Raw].[Incomes:Details] AS D
        LEFT JOIN [dbo].[IncomeTable] AS I ON I.[Raw_Id] = D.[Id]
        OUTER APPLY
        (
            SELECT [FindByInnCount] = Count(*)
            FROM [dbo].[ClientTable] AS C
            WHERE C.[CL_INN] = D.[Inn]
        ) AS CI
        OUTER APPLY
        (
            SELECT TOP (1)
                C.[CL_ID], C.[CL_PSEDO]
            FROM [dbo].[ClientTable] AS C
            WHERE C.[CL_INN] = D.[Inn]
                AND CI.[FindByInnCount] = 1
        ) AS C
        OUTER APPLY
        (
            SELECT TOP (1) CD.[CL_ID], CD.[CL_PSEDO]
            FROM [dbo].[ClientTable] AS CD
            WHERE CD.[CL_ID] = D.[Client_Id]
        ) AS CD
        OUTER APPLY
        (
            SELECT
                [Err] =
                    CASE
                        WHEN I.[IN_ID] IS NOT NULL THEN 'Платеж уже загружен'
                        WHEN IsNull(CD.[CL_ID], C.[CL_ID]) IS NULL THEN 'Не удалось идентифицировать клиента'
                        WHEN D.[NotForImport] = 1 THEN 'Платеж не для загрузки'
                        WHEN EXISTS
                            (
                                SELECT TOP (1) *
                                FROM [dbo].[PurposesForbiddenWords] AS W
                                WHERE D.[Purpose] LIKE W.[Mask]
                            ) THEN 'В назначении есть запрещенные слова'
                    END
        ) AS E
        OUTER APPLY
        (
            SELECT
                [AllowChecked]  = Cast(CASE WHEN I.[IN_ID] IS NULL AND IsNull(CD.[CL_ID], C.[CL_ID]) IS NOT NULL AND D.[NotForImport] = 0 THEN 1 ELSE 0 END AS Bit)
        ) AS AC
        OUTER APPLY
        (
            SELECT
                [Checked] = Cast(CASE WHEN [AllowChecked] = 1 AND [Err] IS NULL THEN 1 ELSE 0 END AS Bit)
        ) AS CH
        WHERE [Income_Id] = @Id
            AND (@OnlyUnloaded = 0 OR @OnlyUnloaded = 1 AND I.[IN_ID] IS NULL)
            AND (@HideNotForImport = 0 OR D.[NotForImport] = 0)
        ORDER BY D.[Price];

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[Income@Select] TO rl_income_w;
GO
