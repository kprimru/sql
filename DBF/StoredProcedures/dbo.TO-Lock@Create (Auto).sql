USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TO-Lock@Create (Auto)]
    @To_Id          Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @ExpireDate     SmallDateTime,
        @PeriodStart    SmallDateTime,
        @PeriodFinish   SmallDateTime;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SELECT
            @PeriodStart = PR_BREPORT,
            @PeriodFinish = PR_EREPORT
        FROM dbo.PeriodTable
        WHERE GetDate() >= PR_BREPORT AND GetDate() < DateAdd(Day, 1, PR_EREPORT);

        IF NOT EXISTS
            (
                SELECT *
                FROM [dbo].[TODistrView]    AS D
                INNER JOIN dbo.RegNodeTable AS R ON R.RN_SYS_NAME = D.SYS_REG_NAME
                                                AND R.RN_DISTR_NUM = D.DIS_NUM
                                                AND R.RN_COMP_NUM = D.DIS_COMP_NUM
                WHERE TD_ID_TO = @TO_Id
                    AND R.RN_SERVICE = 0
                    AND IsNull(R.RN_FIRST_REG, R.RN_REG_DATE) BETWEEN @PeriodStart AND @PeriodFinish
                    AND R.RN_DISTR_TYPE NOT IN ('NCT', 'HSS', 'SPF', 'DSP')
            ) BEGIN
            SET @ExpireDate = DateAdd(Day, 4, DateAdd(Month, 1, dbo.MonthOf(@PeriodFinish)));

            EXEC [dbo].[TO-Lock@Create]
                @TO_Id      = @TO_Id,
                @ExpireDate = @ExpireDate;
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
