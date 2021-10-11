USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_REPORT_DETAIL]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@LGN	NVARCHAR(128)
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
		SELECT b.ID, b.NUMBER, b.NAME, Common.DateOf(a.BDATE) AS DT
		FROM
			Client.CompanyCreateView a
			INNER JOIN Client.Company b ON a.ID = b.ID
		WHERE a.BDATE >= @BEGIN
			AND a.BDATE < @END
			AND a.UPD_USER = @LGN
		ORDER BY b.NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Client].[COMPANY_REPORT_DETAIL] TO rl_company_report;
GO
