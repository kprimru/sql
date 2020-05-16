USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_OFFICE_PRINT]
	@ID		UNIQUEIDENTIFIER
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
			NAME, SHORT, AD_STR, AR_NAME
		FROM
			Client.Office b
			LEFT OUTER JOIN Client.OfficeAddressView c ON b.ID = c.ID_OFFICE
		WHERE b.ID_COMPANY = @ID AND STATUS = 1
		ORDER BY NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_OFFICE_PRINT] TO rl_company_p;
GO