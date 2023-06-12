USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_PHONE_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_PHONE_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_PHONE_PRINT]
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
			PHONE, NOTE, b.NAME AS PH_NAME, c.NAME AS OF_NAME
		FROM
			Client.CompanyPhone a
			LEFT OUTER JOIN Client.PhoneType b ON b.ID = a.ID_TYPE
			LEFT OUTER JOIN Client.Office c ON c.ID = a.ID_OFFICE
		WHERE a.ID_COMPANY = @ID AND a.STATUS = 1
		ORDER BY c.NAME, b.NAME, PHONE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PHONE_PRINT] TO rl_company_p;
GO
