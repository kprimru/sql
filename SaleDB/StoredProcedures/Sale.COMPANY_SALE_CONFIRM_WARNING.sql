USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Sale].[COMPANY_SALE_CONFIRM_WARNING]
	@RC			INT	= NULL OUTPUT
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
		SELECT
			b.ID, b.NAME, a.DATE,
			REVERSE(STUFF(REVERSE((
				SELECT y.SHORT + '(' + x.SHORT + '), '
				FROM
					Sale.SaleDistr z
					INNER JOIN System.Systems y ON z.ID_SYSTEM = y.ID
					INNER JOIN System.Net x ON z.ID_NET = x.ID
				WHERE z.ID_SALE = a.ID
				ORDER BY ORD FOR XML PATH('')
			)), 1, 2, '')) AS SYS_STR,
			REVERSE(STUFF(REVERSE((
				SELECT y.SHORT + '(' + CONVERT(VARCHAR(20), [VALUE]) + '), '
				FROM
					Sale.SalePersonal z
					INNER JOIN Personal.OfficePersonal y ON z.ID_PERSONAL = y.ID
				WHERE z.ID_SALE = a.ID
				ORDER BY [VALUE] DESC, y.SHORT FOR XML PATH('')
			)), 1, 2, '')) AS PERS_STR
		FROM
			Sale.SaleCompany a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
		WHERE a.STATUS = 1
			AND CONFIRMED = 0
		ORDER BY a.DATE

		SET @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Sale].[COMPANY_SALE_CONFIRM_WARNING] TO rl_warning_sale;
GO