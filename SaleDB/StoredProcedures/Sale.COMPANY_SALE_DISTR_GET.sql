USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Sale].[COMPANY_SALE_DISTR_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Sale].[COMPANY_SALE_DISTR_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Sale].[COMPANY_SALE_DISTR_GET]
	@ID	UNIQUEIDENTIFIER
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
		SELECT b.ID AS SYS_ID, b.SHORT AS SYS_SHORT, c.ID AS NT_ID, c.SHORT AS NT_SHORT, CNT
		FROM
			Sale.SaleDistr a
			INNER JOIN System.Systems b ON b.ID = a.ID_SYSTEM
			INNER JOIN System.Net c ON c.ID = a.ID_NET
		WHERE a.ID_SALE = @ID
		ORDER BY ORD

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Sale].[COMPANY_SALE_DISTR_GET] TO rl_sale_r;
GO
