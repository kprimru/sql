USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD?BATCH]
    @Org_Id     SmallInt,
    @ActDate    SmallDateTime
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @IDs    Table
    (
        [Id]    Int PRIMARY KEY CLUSTERED
    );

    DECLARE @Upd Table
    (
        [Folder]        VarChar(256),
        [FileName]      VarChar(256),
        [Data]          Xml,
        Primary Key Clustered ([FileName])
    );

    DECLARE @Act_Id     Int;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        INSERT INTO @IDs
        SELECT A.ACT_ID
        FROM dbo.ClientFinancing AS F
        INNER JOIN dbo.ActTable AS A ON F.ID_CLIENT = A.ACT_ID_CLIENT
        WHERE F.UPD_PRINT = 1
            AND A.ACT_DATE = @ActDate
            AND (A.ACT_ID_ORG = @Org_Id OR @Org_Id IS NULL);

        SET @Act_Id = 0;

        WHILE (1 = 1) BEGIN
            SELECT TOP (1)
                @Act_Id = [Id]
            FROM @IDs
            WHERE [Id] > @Act_Id
            ORDER BY
                [Id];

            IF @@RowCount < 1
                BREAK;

            INSERT INTO @Upd
            EXEC [dbo].[ACT_PRINT?UPD] @Act_id = @Act_Id;
        END;

        SELECT *
        FROM @Upd;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT?UPD?BATCH] TO rl_act_p;
GO