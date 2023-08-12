USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[JOB_EXECUTION_NOTIFY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[JOB_EXECUTION_NOTIFY]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Maintenance].[JOB_EXECUTION_NOTIFY]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @JobMaxDuration SmallInt,
        @Prefix         NVarChar(Max),
        @Text           NVarChar(Max);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        SET @JobMaxDuration = 10;
        SET @Prefix = 'Следующие задания выполняются слишком долго:' + Char(10);
        SET @Text = '';

        SELECT @Text = @Text + JT.[Name] + '     последний запуск  ' + Convert(VarChar(20), Start, 104) + ' ' + Convert(VarChar(20), Start, 108) + ' (' + Cast(DateDiff(minute, START, GetDate()) AS VarChar(20)) + ' минут)' + Char(10)
        FROM Maintenance.JobType AS JT
        CROSS APPLY
        (
            SELECT TOP (1)
                START, FINISH
            FROM Maintenance.Jobs AS J
            WHERE J.Type_Id = JT.Id
            ORDER BY START DESC
        ) AS J
        WHERE FINISH IS NULL
            AND DateDiff(minute, START, GetDate()) > @JobMaxDuration;

        IF @Text != '' BEGIN
            SET @Text = @Prefix + @Text;

            EXEC [Maintenance].[MAIL_SEND]
                @TEXT = @Text;
        END

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
