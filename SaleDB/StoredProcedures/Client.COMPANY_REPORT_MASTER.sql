USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_REPORT_MASTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_REPORT_MASTER]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_REPORT_MASTER]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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
		SET @END = DATEADD(DAY, 1, @END)

		SELECT a.UPD_USER, b.SHORT, a.CNT
		FROM
			(
				SELECT UPD_USER, COUNT(*) AS CNT
				FROM Client.CompanyCreateView
				WHERE BDATE >= @BEGIN AND BDATE < @END
				GROUP BY UPD_USER
			) AS a
			LEFT OUTER JOIN Personal.OfficePersonal b ON a.UPD_USER = b.LOGIN
		ORDER BY b.SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Client].[COMPANY_REPORT_MASTER] TO rl_company_report;
GO
