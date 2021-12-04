USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Act@Recalc?Params]
    @Act_Id     Int
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

        UPDATE A SET
            [IsOnline]          = CASE WHEN [HasOnline] = 1 THEN 1 ELSE 0 END,
            [IsLongService]     = CASE WHEN [HasLongService] = 1 THEN 1 ELSE 0 END
        FROM [dbo].[ActTable] AS A
        OUTER APPLY
        (
            SELECT [HasOnline] = 1
            FROM [dbo].[ActDistrTable]              AS AD
            INNER JOIN [dbo].[DistrFinancingTable]  AS DF ON DF.[DF_ID_DISTR] = AD.[AD_ID_DISTR]
            WHERE AD.[AD_ID_ACT] = A.[ACT_ID]
                AND DF.[DF_ID_NET] IN (
                    SELECT [SNC_ID_SN]
                    FROM [dbo].[NetTypes@Get?Offile]()
                )
        ) AS O
        OUTER APPLY
        (
            SELECT [HasLongService] = 1
            FROM [dbo].[ActDistrTable]              AS AD
            INNER JOIN [dbo].[DistrFinancingTable]  AS DF ON DF.[DF_ID_DISTR] = AD.[AD_ID_DISTR]
            WHERE AD.[AD_ID_ACT] = A.[ACT_ID]
                AND DF.[DF_EXPIRE] IS NOT NULL
        ) AS D
        WHERE A.[ACT_ID] = @Act_Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Act@Recalc?Params] TO rl_act_w;
GO
